"""Dashboard freshness measurement for ConferenceCheck Mobile.

Measures how long a check-in takes to appear on the organiser dashboard, the
way the proposal describes: inject check-ins and time their appearance.

A poller reproduces the app's dashboard refresh exactly
(mobile/lib/features/dashboard/application/analytics_providers.dart): it
fetches the same four analytics endpoints in parallel, and schedules the next
fetch REFRESH_SECONDS after the previous one started. Check-ins are injected
one at a time at random moments through the check-in API. Each one is timed
from the start of the injecting request (before the database commit, so the
figure is never flattering) to the end of the first dashboard fetch whose
summary includes it.

This measures the data path to the app: polling plus API. It does not include
the few milliseconds Flutter takes to repaint the widgets.

Usage:  python tools/measure-dashboard-freshness.py  (backend must be running,
        evaluation event seeded by tools/seed-evaluation-event.php)
Writes: tools/freshness-results.json
"""

import concurrent.futures
import json
import random
import statistics
import threading
import time
import urllib.error
import urllib.request

BASE = 'http://127.0.0.1:8000/api'
EVENT_NAME = 'Evaluation Simulated Event'
REFRESH_SECONDS = 30
TRIALS = 20
TARGET_SECONDS = 30


def call(method, path, token=None, body=None):
    request = urllib.request.Request(BASE + path, method=method)
    request.add_header('Accept', 'application/json')
    if token:
        request.add_header('Authorization', f'Bearer {token}')
    data = json.dumps(body).encode() if body is not None else None
    if data:
        request.add_header('Content-Type', 'application/json')
    try:
        with urllib.request.urlopen(request, data, timeout=60) as response:
            return response.status, json.loads(response.read())
    except urllib.error.HTTPError as error:
        return error.code, json.loads(error.read() or b'null')


_, login = call('POST', '/auth/login', body={'email': 'organiser@example.com', 'password': 'password'})
organiser = login['data']['token']
_, login = call('POST', '/auth/login', body={'email': 'scanner@example.com', 'password': 'password'})
scanner = login['data']['token']
_, events = call('GET', '/events', organiser)
eid = next(e for e in events['data'] if e['name'] == EVENT_NAME)['id']
_, attendees = call('GET', f'/events/{eid}/attendees', organiser)
fresh = [a['id'] for a in attendees['data'] if not a['checked_in_at']]
random.shuffle(fresh)

observations = []  # (fetch_started, fetch_finished, checked_in_attendees)
lock = threading.Lock()
stop = threading.Event()


def poll():
    paths = ['summary', 'check-ins', 'meals', 'sessions']
    with concurrent.futures.ThreadPoolExecutor(max_workers=4) as pool:
        while not stop.is_set():
            started = time.perf_counter()
            responses = list(pool.map(lambda p: call('GET', f'/events/{eid}/analytics/{p}', organiser), paths))
            finished = time.perf_counter()
            with lock:
                observations.append((started, finished, responses[0][1]['data']['checked_in_attendees']))
            stop.wait(max(0.0, REFRESH_SECONDS - (time.perf_counter() - started)))


poller = threading.Thread(target=poll, daemon=True)
poller.start()
while not observations:
    time.sleep(0.1)

delays = []
for trial in range(TRIALS):
    time.sleep(random.uniform(0, REFRESH_SECONDS))
    with lock:
        before = observations[-1][2]
    injected_at = time.perf_counter()
    status, _ = call('POST', f'/events/{eid}/attendees/{fresh[trial]}/check-in', scanner)
    assert status == 200, status
    while True:
        with lock:
            seen = [o for o in observations if o[0] > injected_at and o[2] > before]
        if seen:
            delays.append(round(seen[0][1] - injected_at, 2))
            break
        time.sleep(0.05)
    print(f'check-in {trial + 1:>2}/{TRIALS} appeared after {delays[-1]:.2f} s')

stop.set()
ordered = sorted(delays)
results = {
    'method': 'check-ins injected at random moments, timed to the first app-equivalent dashboard fetch that shows them',
    'refresh_seconds': REFRESH_SECONDS,
    'target_seconds': TARGET_SECONDS,
    'trials': TRIALS,
    'median_s': round(statistics.median(delays), 2),
    'p95_s': ordered[max(0, round(0.95 * len(ordered)) - 1)],
    'max_s': ordered[-1],
    'within_target': sum(1 for d in delays if d <= TARGET_SECONDS),
    'delays_s': delays,
}
with open('tools/freshness-results.json', 'w') as fh:
    json.dump(results, fh, indent=2)
print(f"\nmedian {results['median_s']} s, p95 {results['p95_s']} s, max {results['max_s']} s, "
      f"{results['within_target']}/{TRIALS} within {TARGET_SECONDS} s")
