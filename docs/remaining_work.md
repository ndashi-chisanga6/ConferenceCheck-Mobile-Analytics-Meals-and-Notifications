# Remaining Work, dated from the resubmission

**Project:** ConferenceCheck Mobile: Analytics, Meals and Notifications (component 4.3b)
**Student:** Ndashi Bwalya Chisanga (2021470105) · **Supervisor:** Mr. Mofya Phiri
**Written:** 10 October 2026, after the supervisor's comments on submissions 116 (final report), 117 (validation document) and 118 (proposal v3)

This is the dated account of remaining work asked for on the proposal. It
lists what has been done since the comments, with the commit and test that
evidence each item, and what is still to do, with a date for each. Dates are
from this account, not from the proposal's 28/03/2026 cover date. The
milestone tags in the repository were created in September and mark
representative commits; they do not by themselves show when work happened,
which is why each item below links its own commit.

## Done since the comments

### Authorisation (submission 117, priority 1)

Each fix has a feature test in `tests/Feature/ConferenceApiTest.php` that
expects 403 and was checked to fail against the code before the fix.

| Date | Item | Commit | Test |
|---|---|---|---|
| 07/10/2026 | Attendees can no longer read the attendee list, every voucher, redemption history, session attendance or the reports; reports are organiser only | [`a6596e8`](https://github.com/ndashi-chisanga6/ConferenceCheck-Mobile-Analytics-Meals-and-Notifications/commit/a6596e8) | `test_attendee_cannot_read_staff_or_organiser_routes`, `test_scanner_cannot_download_reports` |
| 07/10/2026 | Attendees can only open their own voucher | [`9bc2869`](https://github.com/ndashi-chisanga6/ConferenceCheck-Mobile-Analytics-Meals-and-Notifications/commit/9bc2869) | `test_attendee_can_only_open_their_own_voucher` |
| 07/10/2026 | Notifications are listed and opened only by their recipients | [`ec7d6de`](https://github.com/ndashi-chisanga6/ConferenceCheck-Mobile-Analytics-Meals-and-Notifications/commit/ec7d6de) | `test_notifications_are_only_readable_by_their_recipients` |
| 07/10/2026 | Registration can no longer choose the organiser role | [`c78b236`](https://github.com/ndashi-chisanga6/ConferenceCheck-Mobile-Analytics-Meals-and-Notifications/commit/c78b236) | `test_register_cannot_pick_organiser_role` |
| 07/10/2026 | Only a device token's owner can delete it | [`95058ab`](https://github.com/ndashi-chisanga6/ConferenceCheck-Mobile-Analytics-Meals-and-Notifications/commit/95058ab) | `test_only_the_owner_can_delete_a_device_token` |
| 07/10/2026 | The `custom` notification target, which sent to every attendee, is removed | [`4988a92`](https://github.com/ndashi-chisanga6/ConferenceCheck-Mobile-Analytics-Meals-and-Notifications/commit/4988a92) | `test_custom_target_is_rejected_instead_of_sent_to_everyone` |
| 09/10/2026 | Linking an attendee record no longer demotes a scanner or organiser | [`85b529c`](https://github.com/ndashi-chisanga6/ConferenceCheck-Mobile-Analytics-Meals-and-Notifications/commit/85b529c) | `test_linking_an_attendee_record_does_not_demote_staff` |

Scanners keep read access to the meal redemption history, because the
scanner app's history tab uses it; reports are organiser only.

### Backend correctness (submissions 116 and 117)

| Date | Item | Commit | Test |
|---|---|---|---|
| 09/10/2026 | Redemptions cannot be edited or deleted, and no longer cascade away with an event, attendee, category or user | [`da5a91d`](https://github.com/ndashi-chisanga6/ConferenceCheck-Mobile-Analytics-Meals-and-Notifications/commit/da5a91d) | `test_redemptions_cannot_be_edited_or_deleted_away` |
| 09/10/2026 | A double meal scan caught by the unique constraint returns 409, not 500; both 409s carry the earlier redemption time | [`5d6f3c3`](https://github.com/ndashi-chisanga6/ConferenceCheck-Mobile-Analytics-Meals-and-Notifications/commit/5d6f3c3) | `test_constraint_rejection_returns_409_not_500` |
| 09/10/2026 | Session scans lock the session row; a constraint hit returns 409 | [`593fb07`](https://github.com/ndashi-chisanga6/ConferenceCheck-Mobile-Analytics-Meals-and-Notifications/commit/593fb07) | `test_session_scan_that_loses_a_race_gets_409_not_500` |
| 09/10/2026 | Same fix for the check-in stub | [`6077851`](https://github.com/ndashi-chisanga6/ConferenceCheck-Mobile-Analytics-Meals-and-Notifications/commit/6077851) | `test_check_in_that_loses_a_race_is_a_duplicate_not_a_500` |
| 09/10/2026 | CSV exports read rows in chunks instead of loading the whole result | [`ce05285`](https://github.com/ndashi-chisanga6/ConferenceCheck-Mobile-Analytics-Meals-and-Notifications/commit/ce05285) | `test_every_export_has_one_row_per_database_record` |
| 09/10/2026 | Firebase demo mode is off by default, a missing configuration fails, and demo sends are recorded as `demo`, never `sent` | [`1f66e52`](https://github.com/ndashi-chisanga6/ConferenceCheck-Mobile-Analytics-Meals-and-Notifications/commit/1f66e52) | `test_missing_firebase_config_fails_instead_of_faking_success`, `test_notification_send_in_demo_mode` |
| 09/10/2026 | Pushes are sent after the recipient rows commit, outside the transaction | [`ab206f4`](https://github.com/ndashi-chisanga6/ConferenceCheck-Mobile-Analytics-Meals-and-Notifications/commit/ab206f4) | `test_pushes_go_out_after_the_recipient_rows_are_committed` |

### Offline replay (submissions 116 and 117)

| Date | Item | Commit | Test |
|---|---|---|---|
| 09/10/2026 | Replay keeps a queued scan on 401, 403, 429, 5xx or no connection; only 404, 409 and 422 settle it | [`3387288`](https://github.com/ndashi-chisanga6/ConferenceCheck-Mobile-Analytics-Meals-and-Notifications/commit/3387288) | `mobile/test/scan_replay_test.dart` |
| 10/10/2026 | A scan queued during a replay is no longer overwritten | [`6ebc456`](https://github.com/ndashi-chisanga6/ConferenceCheck-Mobile-Analytics-Meals-and-Notifications/commit/6ebc456) | `mobile/test/scan_replay_test.dart` |
| 10/10/2026 | Replay after a restart, including session scans and a scan kept after a 401 | [`33d3c89`](https://github.com/ndashi-chisanga6/ConferenceCheck-Mobile-Analytics-Meals-and-Notifications/commit/33d3c89) | `mobile/test/scan_replay_restart_test.dart` |

### Evaluation

| Date | Item | Commit | Evidence |
|---|---|---|---|
| 10/10/2026 | Concurrent redemption on PostgreSQL behind five server processes, with every combination of row lock and unique constraint on and off as controls | [`e9aab32`](https://github.com/ndashi-chisanga6/ConferenceCheck-Mobile-Analytics-Meals-and-Notifications/commit/e9aab32) | `tools/concurrency-results.json` |
| 10/10/2026 | All four CSV exports checked against direct SQL, rows and totals; full evaluation rerun on the current code | [`907f237`](https://github.com/ndashi-chisanga6/ConferenceCheck-Mobile-Analytics-Meals-and-Notifications/commit/907f237) | `tools/evaluation-results.json` |
| 10/10/2026 | Dashboard freshness measured by injecting 20 check-ins at random moments and timing their appearance through the app's refresh cycle | [`094e5e1`](https://github.com/ndashi-chisanga6/ConferenceCheck-Mobile-Analytics-Meals-and-Notifications/commit/094e5e1) | `tools/freshness-results.json` |

## Still to do

| Item | Asked on | Due |
|---|---|---|
| Report and validation document: replace "every criterion met" with a per-criterion status table, and "all six objectives met" with an objective-by-objective statement | 116, 117 | 12/10/2026 |
| Report and validation document: correct the concurrency and export-correctness wording to match the code and the new evidence; use one run throughout; drop "byte-exact", "780/780" and the unmeasured "no overhead" claim; present push delivery as single observations | 116, 117 | 12/10/2026 |
| Report: describe the proposal as resubmitted and under review, the backend as a standalone Laravel API with a check-in stub, and the July history reconstruction; add the newer literature and concurrency-control sources; expand the AI disclosure by phase | 116 | 13/10/2026 |
| Proposal v4: evaluation objective, the two literature corrections, and this account | 118 | 13/10/2026 |
| Rebuild both PDFs from the same source, tag the final commit afresh, upload to the Final Report, validation and Project Proposal slots | 116, 117, 118 | 14/10/2026 |
