"""Concurrent redemption experiment for ConferenceCheck Mobile.

Tests whether the voucher redemption path gives exactly one success when the
same voucher is scanned several times at the same instant, under real
parallel load on PostgreSQL, and which safeguard is responsible.

Every race fires WORKERS scans of one fresh voucher at once, each to a
different PHP server process, so the requests really overlap in the
database. Four configurations are run, a 2x2 of the two safeguards (the
application's status check is present in all of them):

  row lock    unique constraint
  on          on                 the system as built
  off         on                 lock removed (negative control for the lock)
  on          off                constraint removed (control for the constraint)
  off         off                plain check-then-insert (expected to fail)

Each configuration is served from a scratch git worktree of HEAD, so the
code under test is otherwise identical: the lock is removed by deleting
lockForUpdate() from the redemption query, and the constraint is dropped on a
scratch database.

The grid is run twice. In the natural run the code is unchanged. In the
widened run a DELAY_MS pause is injected between the status check and the
write, in all four configurations alike, so the window in which two scans
can both pass the check is held open on purpose. The widened run is there so
the result doesn't depend on how often the natural timing happens to
overlap on a given machine.

Usage:  python tools/run-concurrency-experiment.py
        (needs PostgreSQL as configured in .env; creates and drops a scratch
        database named conferencecheck_concurrency)
Writes: tools/concurrency-results.json
"""

import json
import os
import platform
import shutil
import subprocess
import tempfile
import threading
import time
import urllib.error
import urllib.request
from collections import Counter
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
SCRATCH_DB = 'conferencecheck_concurrency'
WORKERS = 5
RACES = 50
FIRST_PORT = 8101
DELAY_MS = 50
EVENT_NAME = 'Evaluation Simulated Event'
CONSTRAINT = 'meal_redemptions_meal_voucher_id_unique'

bundled = ROOT.parent / '.tools' / 'php-8.5.8' / 'php.exe'
PHP = os.environ.get('PHP') or (str(bundled) if bundled.exists() else 'php')


def artisan(*args, cwd=ROOT, database=SCRATCH_DB):
    env = dict(os.environ, DB_DATABASE=database)
    result = subprocess.run([PHP, 'artisan', *args], cwd=cwd, env=env, capture_output=True, text=True)
    if result.returncode != 0:
        raise RuntimeError(f"artisan {' '.join(args)} failed:\n{result.stdout}\n{result.stderr}")
    return result.stdout.strip()


def sql(statement, database=SCRATCH_DB):
    return json.loads(artisan('tinker', '--execute', f'echo json_encode(DB::select("{statement}"));', database=database))


def ddl(statement, database=SCRATCH_DB):
    artisan('tinker', '--execute', f'DB::statement("{statement}");', database=database)


def call(port, method, path, token=None, body=None):
    request = urllib.request.Request(f'http://127.0.0.1:{port}/api{path}', method=method)
    request.add_header('Accept', 'application/json')
    if token:
        request.add_header('Authorization', f'Bearer {token}')
    data = None
    if body is not None:
        data = json.dumps(body).encode()
        request.add_header('Content-Type', 'application/json')
    try:
        with urllib.request.urlopen(request, data, timeout=60) as response:
            return response.status, json.loads(response.read() or b'null')
    except urllib.error.HTTPError as error:
        payload = error.read()
        try:
            return error.code, json.loads(payload)
        except ValueError:
            return error.code, None


def start_servers(app_dir):
    env = dict(os.environ, DB_DATABASE=SCRATCH_DB)
    router = app_dir / 'vendor' / 'laravel' / 'framework' / 'src' / 'Illuminate' / 'Foundation' / 'resources' / 'server.php'
    # laravel's router script expects to be started from inside public/
    servers = [
        subprocess.Popen([PHP, '-S', f'127.0.0.1:{FIRST_PORT + i}', str(router)],
                         cwd=app_dir / 'public', env=env, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
        for i in range(WORKERS)
    ]
    try:
        for i in range(WORKERS):
            for _ in range(100):
                try:
                    status, _ = call(FIRST_PORT + i, 'GET', '/auth/me')
                    if status == 401:
                        break
                except (OSError, ValueError):
                    pass
                time.sleep(0.2)
            else:
                raise RuntimeError(f'server on port {FIRST_PORT + i} did not start')
    except BaseException:
        stop_servers(servers)
        raise
    return servers


def stop_servers(servers):
    for server in servers:
        server.terminate()
    for server in servers:
        server.wait(timeout=10)


def make_worktree(lock, delay_ms):
    path = Path(tempfile.mkdtemp(prefix='cc-race-'))
    path.rmdir()
    subprocess.run(['git', 'worktree', 'add', '--detach', str(path), 'HEAD'], cwd=ROOT, check=True, capture_output=True)
    controller = path / 'app' / 'Http' / 'Controllers' / 'Api' / 'MealController.php'
    source = controller.read_text(encoding='utf-8')
    write = "$voucher->update(['status' => 'redeemed'"
    if source.count('->lockForUpdate()') != 1 or source.count(write) != 1:
        raise RuntimeError('MealController no longer matches what this experiment patches')
    if not lock:
        source = source.replace('->lockForUpdate()', '')
    if delay_ms:
        source = source.replace(write, f'usleep({delay_ms * 1000}); {write}')
    controller.write_text(source, encoding='utf-8')
    shutil.copy(ROOT / '.env', path / '.env')

    # composer's autoloader finds app/ relative to its own folder, and php
    # resolves links to their real path, so linking the whole vendor folder
    # would load the main checkout's classes. The worktree gets its own copy
    # of the autoloader and links to the packages only.
    vendor = path / 'vendor'
    vendor.mkdir()
    shutil.copytree(ROOT / 'vendor' / 'composer', vendor / 'composer')
    shutil.copy(ROOT / 'vendor' / 'autoload.php', vendor / 'autoload.php')
    for entry in (ROOT / 'vendor').iterdir():
        if entry.name in ('composer', 'autoload.php'):
            continue
        if os.name == 'nt' and entry.is_dir():
            subprocess.run(['cmd', '/c', 'mklink', '/J', str(vendor / entry.name), str(entry)], check=True, capture_output=True)
        else:
            os.symlink(entry, vendor / entry.name, target_is_directory=entry.is_dir())

    loaded = artisan('tinker', '--execute',
                     r'echo (new ReflectionClass(App\Http\Controllers\Api\MealController::class))->getFileName();',
                     cwd=path)
    if Path(loaded).resolve() != controller.resolve():
        raise RuntimeError(f'worktree loads {loaded}, not its own patched controller')
    return path


def remove_worktree(path):
    vendor = path / 'vendor'
    if vendor.exists():
        for entry in vendor.iterdir():
            if entry.is_symlink() or (os.name == 'nt' and entry.is_dir() and entry.name != 'composer'):
                os.rmdir(entry) if os.name == 'nt' and entry.is_dir() else entry.unlink()
    subprocess.run(['git', 'worktree', 'remove', '--force', str(path)], cwd=ROOT, check=True, capture_output=True)


def race(token, voucher):
    barrier = threading.Barrier(WORKERS)
    statuses = [None] * WORKERS

    def fire(i):
        barrier.wait()
        statuses[i], _ = call(FIRST_PORT + i, 'POST', f"/events/{voucher['event_id']}/meal-vouchers/scan", token,
                              {'qr_token': voucher['qr_token'], 'device_id': f'race-worker-{i}'})

    threads = [threading.Thread(target=fire, args=(i,)) for i in range(WORKERS)]
    for thread in threads:
        thread.start()
    for thread in threads:
        thread.join()
    return statuses


def run_variant(name, app_dir, vouchers):
    servers = start_servers(app_dir)
    try:
        _, login = call(FIRST_PORT, 'POST', '/auth/login', body={'email': 'scanner@example.com', 'password': 'password'})
        scanner = login['data']['token']
        all_statuses = Counter()
        exactly_one = 0
        for voucher in vouchers:
            statuses = race(scanner, voucher)
            all_statuses.update(str(s) for s in statuses)
            if statuses.count(200) == 1 and statuses.count(409) == WORKERS - 1:
                exactly_one += 1
    finally:
        stop_servers(servers)

    ids = ','.join(str(v['id']) for v in vouchers)
    rows = sql(f'select meal_voucher_id, count(*) as n from meal_redemptions where meal_voucher_id in ({ids}) group by meal_voucher_id')
    per_voucher = {row['meal_voucher_id']: row['n'] for row in rows}
    doubled = sum(1 for v in vouchers if per_voucher.get(v['id'], 0) > 1)
    result = {
        'races': len(vouchers),
        'exactly_one_success': exactly_one,
        'vouchers_redeemed_more_than_once': doubled,
        'redemption_rows': sum(per_voucher.values()),
        'responses': dict(sorted(all_statuses.items())),
    }
    print(f"{name:<34} one winner {exactly_one:>3}/{len(vouchers)}   double-redeemed {doubled:>3}   responses {result['responses']}")
    return result


def main():
    ddl(f'drop database if exists {SCRATCH_DB}', database='postgres')
    ddl(f'create database {SCRATCH_DB}', database='postgres')
    postgres = sql('select version() as v', database='postgres')[0]['v']
    windows = {'natural': 0, 'widened': DELAY_MS}
    worktrees = {}
    results = {window: {} for window in windows}
    try:
        artisan('migrate:fresh', '--seed', '--force')
        artisan('tinker', 'tools/seed-evaluation-event.php')

        vouchers = sql(f"select v.id, v.event_id, v.qr_token from meal_vouchers v join events e on e.id = v.event_id "
                       f"where e.name = '{EVENT_NAME}' and v.status = 'unused' order by v.id limit {8 * RACES}")
        batches = iter(vouchers[i:i + RACES] for i in range(0, 8 * RACES, RACES))
        for window, delay in windows.items():
            for lock in (True, False):
                worktrees[(window, lock)] = make_worktree(lock, delay)

        print(f'{WORKERS} parallel scans per race, {RACES} races per configuration, widened window {DELAY_MS} ms')
        for constraint in (True, False):
            if not constraint:
                ddl(f'alter table meal_redemptions drop constraint {CONSTRAINT}')
            for window in windows:
                for lock in (True, False):
                    key = f"lock_{'on' if lock else 'off'}_constraint_{'on' if constraint else 'off'}"
                    label = f"{window:<8} lock {'on ' if lock else 'off'} constraint {'on ' if constraint else 'off'}"
                    results[window][key] = run_variant(label, worktrees[(window, lock)], next(batches))
    finally:
        for path in worktrees.values():
            remove_worktree(path)
        ddl(f'drop database if exists {SCRATCH_DB}', database='postgres')

    commit = subprocess.run(['git', 'rev-parse', '--short', 'HEAD'], cwd=ROOT, capture_output=True, text=True).stdout.strip()
    php_version = subprocess.run([PHP, '-r', 'echo PHP_VERSION;'], capture_output=True, text=True).stdout.strip()
    output = {
        'setup': {
            'commit': commit,
            'workers': WORKERS,
            'races_per_configuration': RACES,
            'server': f'{WORKERS} separate php -S processes, one request per process per race',
            'widened_window_delay_ms': DELAY_MS,
            'database': f'{postgres} (scratch database, fresh seed)',
            'php': php_version,
            'os': platform.platform(),
        },
        'results': results,
    }
    with open(ROOT / 'tools' / 'concurrency-results.json', 'w') as fh:
        json.dump(output, fh, indent=2)
    print('\nresults written to tools/concurrency-results.json')


if __name__ == '__main__':
    main()
