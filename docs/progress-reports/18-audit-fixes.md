# Progress Report 18 — Hardening Pass from the Self-Audit

## What was built
Four fixes from an audit of hardcoded values and unimplemented promises. (1) Automatic capacity alerts: when a door scan pushes a session across its warning threshold (`CAPACITY_WARNING_THRESHOLD`, default 90%) or over capacity, organisers now receive a push notification automatically, dispatched after the attendance transaction commits and recorded in the notifications feed — verified live on the emulator ([evidence](../evidence-capacity-alerts.png)). (2) Real device identity: the hardcoded `flutter-mobile` device id is replaced by a per-install identifier persisted on first launch and reported with every meal *and* session scan (new `device_id` column on `session_attendance`), completing the audit-trail story. (3) The offline scan queue now also drains on app launch, not just after a successful scan or manual sync. (4) The check-ins chart gained hour labels on its x-axis. Bonus: FCM sends now prune device tokens Google reports as permanently invalid, so stale demo tokens stop polluting delivery counts.

## How it maps to the objectives
Objective 3's "overcrowding alerts" is now fully delivered as proposed (proactive push, configurable threshold), not just dashboard state. Objectives 2/3's audit trail now genuinely distinguishes scanning devices. Backend: 53 tests / 199 assertions passing (two new tests cover the alert transitions and device recording), PHPStan level 7 clean. Mobile: analyzer clean, 19 tests passing.

## Blockers
None.

## Next steps
The simulated-event evaluation exercise remains the last outstanding item before the paper's results section can be completed.
