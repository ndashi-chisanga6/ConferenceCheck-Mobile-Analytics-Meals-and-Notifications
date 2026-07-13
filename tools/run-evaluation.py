"""Simulated-event evaluation exercise for ConferenceCheck Mobile.

Measures the acceptance criteria from the revised proposal (Table 3)
against a seeded 500-attendee event (tools/seed-evaluation-event.php):

  1. Scan validation latency (sequential batch of voucher scans)
  2. Duplicate redemption rejection (sequential re-scans)
  3. Concurrent duplicate rejection (parallel scans of the same token)
  4. Session scan latency and duplicate rejection
  5. Analytics endpoint latency (dashboard freshness bound)
  6. CSV export correctness vs. database ground truth

Usage:  python tools/run-evaluation.py  (backend must be running)
Writes: tools/evaluation-results.json
"""

import concurrent.futures
import csv
import io
import json
import statistics
import time
import urllib.request

BASE = 'http://127.0.0.1:8000/api'
EVENT_NAME = 'Evaluation Simulated Event'


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
unused = [v['qr_token'] for v in vouchers['data'] if v['status'] == 'unused']
print(f"{len(unused)} unused vouchers")

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

# --- 4. session scan latency + duplicates ---------------------------------
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
print('session scan latency', results['session_scan_latency'], '| dupes rejected', session_dupes, '/ 20')

# --- 5. analytics endpoint latency ----------------------------------------
analytics_lat = []
for _ in range(20):
    _, _, ms = call('GET', f'/events/{eid}/analytics/summary', organiser)
    analytics_lat.append(ms)
results['analytics_summary_latency'] = summarise(analytics_lat)
print('analytics latency', results['analytics_summary_latency'])

# --- 6. export correctness -------------------------------------------------
status, meals_csv, _ = call('GET', f'/events/{eid}/reports/meals.csv', organiser, raw=True)
csv_rows = len(list(csv.reader(io.StringIO(meals_csv.decode())))) - 1  # minus header
_, redemptions, _ = call('GET', f'/events/{eid}/meal-redemptions', organiser)
db_rows = len(redemptions['data'])
results['export_correctness'] = {'meals_csv_rows': csv_rows, 'db_redemptions': db_rows, 'match': csv_rows == db_rows}
print('meals.csv rows', csv_rows, 'vs db redemptions', db_rows)

status, att_csv, _ = call('GET', f'/events/{eid}/reports/attendance.csv', organiser, raw=True)
att_rows = len(list(csv.reader(io.StringIO(att_csv.decode())))) - 1
results['export_correctness']['attendance_csv_rows'] = att_rows
results['export_correctness']['db_attendees'] = len(attendees['data'])
results['export_correctness']['attendance_match'] = att_rows == len(attendees['data'])
print('attendance.csv rows', att_rows, 'vs attendees', len(attendees['data']))

with open('tools/evaluation-results.json', 'w') as fh:
    json.dump(results, fh, indent=2)
print('\nresults written to tools/evaluation-results.json')
