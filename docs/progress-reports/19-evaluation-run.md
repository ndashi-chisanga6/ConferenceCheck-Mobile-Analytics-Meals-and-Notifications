# Progress Report 19 — Simulated-Event Evaluation

## What was built
The quantitative evaluation exercise from the revised proposal (Table 3), run against a seeded 500-attendee event with a voucher per attendee and ten sessions. Tooling is committed for reproducibility: `tools/seed-evaluation-event.php` builds the dataset and `tools/run-evaluation.py` drives the measurements; raw numbers are in `tools/evaluation-results.json`.

## Results vs. targets
- **Duplicate rejection: 100%** — 100/100 sequential re-scans rejected; 20/20 concurrency races (five simultaneous scans of one token) resolved to exactly one success each. Ground truth: exactly 220 redemption rows for 200 scans + 20 race winners.
- **Scan latency: median 114 ms, p95 210 ms** (target <500 ms / <1 s), n=200; session scans median 108 ms.
- **Dashboard freshness: ≈30.1 s worst case** (30 s poll + 107 ms median summary endpoint) — within the 30 s target.
- **Capacity alerting:** verified live previously (report 18) and covered by automated tests.
- **Export correctness: exact** — attendance.csv 500/500, meals.csv 220/220 against the database.
- **Notification delivery:** FCM accepted 100% of valid tokens; device receipt ~5 s (single test device; fleet measurement is future work).

The paper's abstract, results table, baseline discussion and threats-to-validity sections are now filled with these measurements; only related-work expansion and supervisor-feedback sections remain open.

## Blockers
A human-trial manual baseline (paper register) was not conducted; the paper frames throughput comparison qualitatively and cites the measured 114 ms turnaround as the system-side bound.

## Next steps
Expand related work with 2–3 recent event-technology papers; convert the paper to the department template after supervisor feedback.
