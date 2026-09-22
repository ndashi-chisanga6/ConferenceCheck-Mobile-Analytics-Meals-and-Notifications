# Progress Report 20 — Multi-Category Evaluation and Verification Pass

## What was built
A verification pass that re-ran every command in the report's Appendix D and checked each claim against the behaviour of the running system rather than against the code's intent, plus the evaluation changes that pass made necessary.

The evaluation dataset now seeds three meal categories with a voucher per attendee per category, 1,500 vouchers in all, rather than one category with 500. The second project objective is redemption across multiple meal categories, and with a single category nothing distinguished the per-(attendee, category) guarantee from a per-attendee one. `tools/run-evaluation.py` gained a cross-category measurement: twenty attendees are reserved before any other step, each holding a voucher in every category, and each has all three redeemed in turn.

Two defects were found by checking claims rather than code, and both are fixed:

1. **Per-recipient delivery records were not per-recipient.** `NotificationDispatchService::deliver()` applied one aggregate outcome to every recipient row, so a send in which Firebase accepted one device token and refused three still marked every recipient `sent`, with a delivery timestamp and no failure reason; the refusals appeared only in the log. The report claims these records make delivery auditable per user, and they could not answer that question. `FirebaseNotificationService::send()` now returns per-token outcomes and the dispatch service maps each token back to its recipient: `sent` only on that recipient's own accepted token, `failed` with a reason when all of theirs were refused, `pending` when they have no registered device and the in-app inbox is their channel.
2. **Multi-category redemption was implemented but unevidenced.** No test proved that redeeming one category leaves the attendee's other categories redeemable.

## Results
- **Duplicate rejection: 100%** — 100/100 sequential re-scans rejected; 20/20 concurrency races resolved to exactly one success each.
- **Cross-category independence: 20/20 attendees** redeemed all three categories, sixty redemptions accepted, every repeat of the first refused.
- **Scan latency: median 187.5 ms, p95 286.7 ms** (target <500 ms / <1 s), n=200; session scans median 174.5 ms.
- **Dashboard freshness: ≈30.2 s worst case** (30 s poll + 211.6 ms median summary endpoint).
- **Export correctness: exact** — attendance.csv 500/500, meals.csv 280/280 against the database.
- **Live Firebase path confirmed** — an organiser-targeted send reached Google, which answered with a structured FCM v1 error for a deliberately invalid probe token, and the service pruned it.
- Backend 55/55 tests, 213 assertions; PHPStan level 7 zero errors; Pint clean; `flutter analyze` clean; `flutter test` 19/19.

Latency is slower than report 19 recorded because that run was on an idle machine and this one was not. Three runs are now on record with medians of 114.0 ms, 199.0 ms and 187.5 ms; every correctness figure was identical across all three. The validation report states that envelope rather than quoting one run as though it were a property of the system.

## Blockers
Unchanged from report 19: no human-staffed manual baseline, and push-delivery timing still rests on a single device.

## Next steps
Expand related work with recent event-technology papers; re-check every reference against its source, since one is currently cited for measurements it does not report.
