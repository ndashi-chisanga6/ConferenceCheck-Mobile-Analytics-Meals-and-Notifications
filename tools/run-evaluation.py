"""Simulated-event evaluation exercise for ConferenceCheck Mobile.

Measures the acceptance criteria from the revised proposal (Table 3)
against a seeded 500-attendee event (tools/seed-evaluation-event.php):

  1. Scan validation latency (sequential batch of voucher scans)
  2. Duplicate redemption rejection (sequential re-scans)
  3. Concurrent duplicate rejection (parallel scans of the same token)
  4. Cross-category independence (redeeming one category leaves the others)
  5. Session scan latency and duplicate rejection
  6. Analytics endpoint latency (dashboard freshness bound)
  7. CSV export correctness: all four exports against direct SQL (rows and totals)

Usage:  python tools/run-evaluation.py  (backend must be running)
Writes: tools/evaluation-results.json
"""

import concurrent.futures
import csv
import io
import json
import os
import statistics
import subprocess
import time
import urllib.request
from collections import Counter
from pathlib import Path

BASE = 'http://127.0.0.1:8000/api'
EVENT_NAME = 'Evaluation Simulated Event'
ROOT = Path(__file__).resolve().parent.parent
bundled = ROOT.parent / '.tools' / 'php-8.5.8' / 'php.exe'
PHP = os.environ.get('PHP') or (str(bundled) if bundled.exists() else 'php')


def call(method, path, token=None, body=None, raw=False):
    started = time.perf_counter()
    request = urllib.request.Request(BASE + path, method=method)
    request.add_header('Accept', 'application/json')
    if token:
        request.add_header('Authorization', f'Bearer {token}')
    data = None
    if body is not None:
        data = json.dumps(body).encode()
        request.add_header('Content-Type', 'application/json')
    try:
        with urllib.request.urlopen(request, data) as response:
            payload = response.read()
            status = response.status
    except urllib.error.HTTPError as error:
        payload = error.read()
        status = error.code
    elapsed_ms = (time.perf_counter() - started) * 1000
    if raw:
        return status, payload, elapsed_ms
    return status, json.loads(payload), elapsed_ms


def sql(statement):
    """Runs a read-only query on the application's database through artisan,
    so the ground truth comes from the database rather than from the API."""
    result = subprocess.run([PHP, 'artisan', 'tinker', '--execute', f'echo json_encode(DB::select("{statement}"));'],
                            cwd=ROOT, capture_output=True, text=True, check=True)
    return json.loads(result.stdout)


def pct(values, p):
    ordered = sorted(values)
    index = max(0, min(len(ordered) - 1, round(p / 100 * len(ordered)) - 1))
    return ordered[index]


def summarise(values):
    return {
        'n': len(values),
        'mean_ms': round(statistics.mean(values), 1),
        'median_ms': round(statistics.median(values), 1),
        'p95_ms': round(pct(values, 95), 1),
        'max_ms': round(max(values), 1),
    }


results = {}

# --- authentication -------------------------------------------------------
_, login, _ = call('POST', '/auth/login', body={'email': 'organiser@example.com', 'password': 'password'})
organiser = login['data']['token']
_, login, _ = call('POST', '/auth/login', body={'email': 'scanner@example.com', 'password': 'password'})
scanner = login['data']['token']

_, events, _ = call('GET', '/events', organiser)
event = next(e for e in events['data'] if e['name'] == EVENT_NAME)
eid = event['id']
print(f"Evaluation event id {eid}")

_, vouchers, _ = call('GET', f'/events/{eid}/meal-vouchers', organiser)
pending = [v for v in vouchers['data'] if v['status'] == 'unused']

by_attendee = {}
for voucher in pending:
    by_attendee.setdefault(voucher['attendee_id'], []).append(voucher)
categories = sorted({v['meal_category_id'] for v in pending})
print(f"{len(pending)} unused vouchers across {len(categories)} categories "
      f"for {len(by_attendee)} attendees")

# Reserve attendees who hold a voucher in every category for the cross-category
# check, and keep their tokens out of every other step, so that check starts
# from a known-unredeemed set rather than from whatever the earlier steps left.
CROSS_CATEGORY_ATTENDEES = 20
reserved = [
    vs for vs in by_attendee.values()
    if len({v['meal_category_id'] for v in vs}) == len(categories)
][:CROSS_CATEGORY_ATTENDEES]
reserved_tokens = {v['qr_token'] for vs in reserved for v in vs}

# The scan batches draw from every category rather than from one, so the
# latency figures cover the whole voucher population.
unused = [v['qr_token'] for v in pending if v['qr_token'] not in reserved_tokens]

# --- 1. sequential voucher scan latency (200 scans) -----------------------
latencies, outcomes = [], []
for tok in unused[:200]:
    status, _, ms = call('POST', f'/events/{eid}/meal-vouchers/scan', scanner,
                         {'qr_token': tok, 'device_id': 'eval-device-1'})
    latencies.append(ms)
    outcomes.append(status)
results['voucher_scan_latency'] = summarise(latencies)
results['voucher_scan_success'] = outcomes.count(200)
print('scan latency', results['voucher_scan_latency'])

# --- 2. sequential duplicate rejection (100 re-scans) ---------------------
rejected = 0
for tok in unused[:100]:
    status, body, _ = call('POST', f'/events/{eid}/meal-vouchers/scan', scanner, {'qr_token': tok})
    if status == 409:
        rejected += 1
results['sequential_duplicate_rejection'] = {'attempts': 100, 'rejected': rejected}
print('sequential duplicates rejected', rejected, '/ 100')

# --- 3. concurrent duplicate rejection ------------------------------------
# For 20 fresh vouchers, fire 5 simultaneous scans of the same token.
concurrent_ok = 0
race_tokens = unused[200:220]


def scan_once(tok):
    status, _, _ = call('POST', f'/events/{eid}/meal-vouchers/scan', scanner,
                        {'qr_token': tok, 'device_id': 'eval-race'})
    return status


for tok in race_tokens:
    with concurrent.futures.ThreadPoolExecutor(max_workers=5) as pool:
        statuses = list(pool.map(scan_once, [tok] * 5))
    if statuses.count(200) == 1 and statuses.count(409) == 4:
        concurrent_ok += 1
results['concurrent_duplicate_rejection'] = {'races': len(race_tokens), 'exactly_one_success': concurrent_ok}
print('concurrent races with exactly one success', concurrent_ok, '/', len(race_tokens))

# --- 4. cross-category independence ----------------------------------------
# For each reserved attendee, redeem every one of their vouchers in turn. The
# guarantee under test is that the unique (attendee, category) pair binds a
# redemption to one category: redeeming breakfast must not consume lunch. Each
# scan after the first is the same attendee, a different category, and must be
# accepted; re-scanning the first must still be refused.
independent = 0
cross_category_scans = 0
for group in reserved:
    ordered = sorted(group, key=lambda v: v['meal_category_id'])
    accepted = 0
    for voucher in ordered:
        status, _, _ = call('POST', f'/events/{eid}/meal-vouchers/scan', scanner,
                            {'qr_token': voucher['qr_token'], 'device_id': 'eval-cross-category'})
        cross_category_scans += 1
        if status == 200:
            accepted += 1
    # every category accepted once, and the first is now a duplicate
    repeat, _, _ = call('POST', f'/events/{eid}/meal-vouchers/scan', scanner,
                        {'qr_token': ordered[0]['qr_token'], 'device_id': 'eval-cross-category'})
    if accepted == len(ordered) and repeat == 409:
        independent += 1
results['cross_category_independence'] = {
    'attendees': len(reserved),
    'categories_per_attendee': len(categories),
    'all_categories_redeemable': independent,
    'redemptions': cross_category_scans,
}
print('attendees whose categories redeemed independently', independent, '/', len(reserved))

# --- 5. session scan latency + duplicates ---------------------------------
_, sessions, _ = call('GET', f'/events/{eid}/sessions', organiser)
session_id = sessions['data'][0]['id']
_, attendees, _ = call('GET', f'/events/{eid}/attendees', organiser)
attendee_ids = [a['id'] for a in attendees['data'][:40]]

session_lat = []
for aid in attendee_ids:
    status, _, ms = call('POST', f'/events/{eid}/sessions/{session_id}/scan', scanner,
                         {'attendee_id': aid, 'device_id': 'eval-device-1'})
    session_lat.append(ms)
results['session_scan_latency'] = summarise(session_lat)
session_dupes = sum(
    1 for aid in attendee_ids[:20]
    if call('POST', f'/events/{eid}/sessions/{session_id}/scan', scanner, {'attendee_id': aid})[0] == 409
)
results['session_duplicate_rejection'] = {'attempts': 20, 'rejected': session_dupes}

# the same 40 attendees are checked in to the event, so the attendance export
# check below compares a real checked-in total rather than zero
for aid in attendee_ids:
    call('POST', f'/events/{eid}/attendees/{aid}/check-in', scanner)
print('session scan latency', results['session_scan_latency'], '| dupes rejected', session_dupes, '/ 20')

# --- 6. analytics endpoint latency ----------------------------------------
analytics_lat = []
for _ in range(20):
    _, _, ms = call('GET', f'/events/{eid}/analytics/summary', organiser)
    analytics_lat.append(ms)
results['analytics_summary_latency'] = summarise(analytics_lat)
print('analytics latency', results['analytics_summary_latency'])

# --- 7. export correctness -------------------------------------------------
# Each export is checked against SQL run directly on the database, not
# against another API endpoint, on its row count and on a total per export.


def export(name):
    _, payload, _ = call('GET', f'/events/{eid}/reports/{name}', organiser, raw=True)
    return list(csv.DictReader(io.StringIO(payload.decode())))


def check(name, csv_values, sql_values):
    match = csv_values == sql_values
    print(f'{name:<34} csv {csv_values}  sql {sql_values}  {"match" if match else "MISMATCH"}')
    return {'csv': csv_values, 'sql': sql_values, 'match': match}


attendance_rows = export('attendance.csv')
meal_rows = export('meals.csv')
session_rows = export('sessions.csv')
notification_rows = export('notifications.csv')

results['export_correctness'] = {
    'attendance.csv': {
        'rows': check('attendance.csv rows', len(attendance_rows),
                      sql(f'select count(*) as n from attendees where event_id = {eid}')[0]['n']),
        'checked_in': check('attendance.csv checked in', sum(1 for r in attendance_rows if r['Checked In At']),
                            sql(f'select count(*) as n from attendees where event_id = {eid} and checked_in_at is not null')[0]['n']),
    },
    'meals.csv': {
        'rows': check('meals.csv rows', len(meal_rows),
                      sql(f'select count(*) as n from meal_redemptions where event_id = {eid}')[0]['n']),
        'per_category': check('meals.csv per category', dict(sorted(Counter(r['Meal Category'] for r in meal_rows).items())),
                              {r['name']: r['n'] for r in sql(f'select c.name, count(*) as n from meal_redemptions m join meal_categories c on c.id = m.meal_category_id where m.event_id = {eid} group by c.name order by c.name')}),
    },
    'sessions.csv': {
        'rows': check('sessions.csv rows', len(session_rows),
                      sql(f'select count(*) as n from event_sessions where event_id = {eid}')[0]['n']),
        'attendance_per_session': check('sessions.csv attendance', dict(sorted((r['Title'], int(r['Attendance'])) for r in session_rows)),
                                        {r['title']: r['n'] for r in sql(f'select s.title, count(a.id) as n from event_sessions s left join session_attendance a on a.session_id = s.id where s.event_id = {eid} group by s.title order by s.title')}),
    },
    'notifications.csv': {
        'rows': check('notifications.csv rows', len(notification_rows),
                      sql(f'select count(*) as n from notifications where event_id = {eid}')[0]['n']),
        'recipients': check('notifications.csv recipients', sum(int(r['Recipients']) for r in notification_rows),
                            sql(f'select count(*) as n from notification_recipients r join notifications n on n.id = r.notification_id where n.event_id = {eid}')[0]['n']),
    },
}
results['export_correctness']['all_match'] = all(
    check_result['match'] for checks in results['export_correctness'].values() for check_result in checks.values()
)

with open('tools/evaluation-results.json', 'w') as fh:
    json.dump(results, fh, indent=2)
print('\nresults written to tools/evaluation-results.json')
