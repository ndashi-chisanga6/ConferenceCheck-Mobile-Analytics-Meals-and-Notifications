# Strict Review — ConferenceCheck Mobile: Analytics, Meals and Notifications

**Reviewed:** 2026-07-09/10, on a live local environment (PHP 8.5.8, PostgreSQL 18, Flutter 3.44.6).
**Method:** full backend test suite, live API calls against seeded data (including adversarial cases: double scans, invalid QR, wrong roles, no auth), Flutter analyzer + test suite, and code inspection of every claimed safeguard.

## Verdict

The prototype **satisfies the core of the portal listing and the proposal**: analytics, QR meal vouchers with genuine one-time-use enforcement, session capacity tracking with overcrowding alerts, role-secured APIs, CSV exports, and a working role-aware Flutter app. At the time of the original review it **did not yet deliver real push notifications** (FCM was stubbed at both ends) and several proposal promises (offline support, publication paper) were outstanding — **all findings have since been fixed** (see the post-review fix log below); live FCM push delivery is now verified end to end on a device ([evidence](evidence-push-delivered.png)).

## Runtime evidence

| Verification | Result |
| --- | --- |
| Backend test suite (`artisan test`) | **48/48 passed**, 174 assertions |
| Live API exercise (all endpoint groups) | all responded correctly, incl. 401/403 enforcement |
| Double meal-voucher scan | rejected (DB transaction + `lockForUpdate`) |
| Duplicate check-in / session scan | flagged `duplicate: true` / rejected |
| Over-capacity session scan | recorded with `over_capacity` + warning |
| Notification send to `all_attendees` | 30 recipient records, per-recipient delivery status |
| Four CSV report downloads | all well-formed |
| `flutter analyze` | no issues |
| `flutter test` | 4/4 passed |

## Compliance — portal objectives (screenshots, project 4.3b)

| # | Portal objective | Status | Evidence |
| --- | --- | --- | --- |
| 1 | Real-time analytics dashboard (progress, rates, trends) | **Met** — data and charts work; caveat resolved post-review: self-refreshes every 30 s while open, plus pull-to-refresh | [02-analytics-dashboard.md](accomplishments/02-analytics-dashboard.md) |
| 2 | Meal voucher scanning & redemption across categories | **Met** — 3 categories, camera + manual scan, concurrency-safe one-time use | [03-meal-voucher-system.md](accomplishments/03-meal-voucher-system.md) |
| 3 | Session attendance with capacity mgmt & overcrowding alerts | **Met** — duplicate prevention, capacity status, warnings; alerts are in-response/dashboard only | [04-session-attendance-capacity.md](accomplishments/04-session-attendance-capacity.md) |
| 4 | Push notification system | **Met** — targeting, recipients, in-app feed, and (post-review) live FCM v1 delivery verified on a device: organiser send → Laravel → FCM → notification shade ([screenshot](evidence-push-delivered.png)) | [05-push-notifications.md](accomplishments/05-push-notifications.md) |
| 5 | Reporting and data export | **Met** — 4 organiser-gated CSV exports + mobile download | [06-reports-and-export.md](accomplishments/06-reports-and-export.md) |
| 6 | Technical documentation & publication-ready paper | **Substantially met** — API/schema/architecture/progress docs exist; paper is a structured working draft awaiting evaluation numbers ([conferencecheck-paper.md](paper/conferencecheck-paper.md)) | [docs/](.) and [mobile/docs/](../mobile/docs/) |

## Compliance — proposal (28/03/26)

| Proposal item | Status |
| --- | --- |
| Objective 1: mobile app for conference management | **Met** — role-aware Flutter app, analyzer-clean, tests passing ([07-flutter-mobile-app.md](accomplishments/07-flutter-mobile-app.md)) |
| Objective 2: analytics dashboard for attendance | **Met** |
| Objective 3: secure QR meal voucher system | **Met** — incl. the proposed "backend validation and one-time use" mitigation, done properly with row locks |
| Objective 4: push notifications for real-time updates | **Met** — live delivery verified (see above) |
| Scope: Flutter, QR vouchers, dashboard, notifications | On track; declared tech stack (Dart, Flutter, Riverpod, fl_chart, qr_flutter, mobile_scanner, FCM, Laravel, PostgreSQL) matches what is actually used |
| Out of scope: payments, full web admin, external ticketing | Correctly absent |
| Risk mitigation: "offline support and retry mechanisms" | **Implemented (post-review)** — durable offline scan queue with ordered replay on reconnect (fix log item 5) |
| Risk mitigation: QR misuse | **Implemented** |
| Sanctum auth & role security (ethical considerations) | **Met** — verified 401/403 ([01-authentication-and-roles.md](accomplishments/01-authentication-and-roles.md)) |

## Defects found during review

1. **FCM delivery is a stub** — `app/Services/FirebaseNotificationService.php` returns success without ever calling Firebase, even with credentials configured. Biggest gap vs. both objective lists.
2. **Attendee QR is fabricated client-side** — `mobile/lib/features/attendee/presentation/my_qr_screen.dart` builds `ATTENDEE-DEMO-<id>` from a naming convention instead of fetching the attendee's real token; breaks for non-seeded users.
3. **Stale API docs** — `docs/api.md` documents notification fields `body`/`target` but the API requires `message`/`target_type` (`NotificationSendRequest.php`).
4. **Inconsistent capacity vocabulary** — sessions CSV says `ok`; analytics endpoints say `available`/`over_capacity`.
5. **No offline queue** despite the proposal's risk table promising offline support and retries.
6. **Thin mobile test coverage** — 4 tests across ~15 screens.

## Recommended next steps (priority order)

1. Implement real FCM v1 sends server-side and add Firebase config to the Android app.
2. Add an authenticated endpoint returning the attendee's own QR token; use it in My QR.
3. Queue failed scans locally (e.g. drift/sqflite) and sync on reconnect — fulfils the proposal's offline promise.
4. Fix `docs/api.md` notification fields and unify capacity status strings.
5. Start the publication paper skeleton (objective 6).
6. Push this repository to GitHub and submit the link with the Week 8 progress report.

## Post-review fixes (2026-07-10)

| Review finding | Status |
| --- | --- |
| 1. FCM delivery stub | **Fixed and verified live (2026-07-13)** — `FirebaseNotificationService` performs real FCM v1 sends (service-account JWT → OAuth token → per-device send) with per-token failure counting; demo mode remains the fallback when credentials are absent. Covered by a feature test with faked Google endpoints. A real Firebase project (`conference-app-903a1`) is now configured: `google-services.json` in the Android app, service-account key outside the repo, demo mode off. End-to-end verification on the Android emulator: attendee login registered a real 142-char FCM token, an organiser send reached Google (`sent=1`), and the notification appeared in the device's notification shade ([screenshot](evidence-push-delivered.png)). |
| 2. Attendee QR fabricated client-side | **Fixed** — new authenticated `GET /events/{event}/attendees/me` endpoint returns the caller's real attendee record; My QR screen now fetches it (loading/error/retry states). Two feature tests added. |
| 3. Stale api.md notification fields | **Fixed** — send payload (`title`/`message`/`target_type`/`target_session_id`) now documented explicitly; `attendees/me` documented. |
| 4. Inconsistent capacity vocabulary | **Fixed** — sessions CSV now uses the same `available`/`full`/`over_capacity` terms as the analytics endpoints. |
| 5. No offline scan queue | **Fixed** — scans made without connectivity are persisted to a durable FIFO queue (`core/offline/`) and replayed in order on reconnect; replay is safe because the server answers duplicates definitively (idempotent scan endpoints). Scanner screens show a pending-count bar with manual "Sync now"; queued scans render as amber banners. Covered by unit and widget tests. |
| 6. Thin mobile test coverage | **Improved** — 19 Flutter tests (up from 4): offline queue persistence/FIFO/replace semantics, pending-scans bar states, core widgets (MetricCard, ResultBanner, StatusBadge), formatters and attendee model parsing. |
| (Objective 1 caveat) Dashboard not auto-refreshing | **Fixed** — analytics provider self-refreshes every 30 seconds while the dashboard is open, matching the revised proposal's freshness target; pull-to-refresh retained. |

Additionally, the publication paper (portal objective 6) is started: [docs/paper/conferencecheck-paper.md](paper/conferencecheck-paper.md) is a structured working draft with the abstract, design and evaluation-method sections written and `[TODO]` markers where simulated-event measurements are still needed.

Verification after fixes: backend 51/51 tests (185 assertions), PHPStan level 7 clean, Pint clean, `flutter analyze` no issues, `flutter test` 19/19.

## Accomplishment documents

1. [Authentication and role-based access](accomplishments/01-authentication-and-roles.md)
2. [Analytics dashboard](accomplishments/02-analytics-dashboard.md)
3. [QR meal voucher system](accomplishments/03-meal-voucher-system.md)
4. [Session attendance and capacity](accomplishments/04-session-attendance-capacity.md)
5. [Notification system](accomplishments/05-push-notifications.md)
6. [Reporting and CSV export](accomplishments/06-reports-and-export.md)
7. [Flutter mobile application](accomplishments/07-flutter-mobile-app.md)

## Commit history — proof of work

Repository: <https://github.com/ndashi-chisanga6/ConferenceCheck-Mobile-Analytics-Meals-and-Notifications>

Each module commit carries a short progress report under [docs/progress-reports/](progress-reports/) covering what was built, the objective mapping, blockers and next steps. The right-hand column maps each commit to the phase of the proposal timeline (Table 4) it advances, showing the build-up from foundations through the module phases towards the midway (week 16) end-to-end demonstration.

| Commit | Content | Proposal phase (Table 4) |
| --- | --- | --- |
| [`a673dac`](https://github.com/ndashi-chisanga6/ConferenceCheck-Mobile-Analytics-Meals-and-Notifications/commit/a673dac) | Project proposal, API contract and database schema design | Requirements and Design (wk 3–5) |
| [`fe0a1db`](https://github.com/ndashi-chisanga6/ConferenceCheck-Mobile-Analytics-Meals-and-Notifications/commit/fe0a1db) | Laravel backend scaffold and development tooling | Environment and Foundations (wk 6–7) |
| [`a32a615`](https://github.com/ndashi-chisanga6/ConferenceCheck-Mobile-Analytics-Meals-and-Notifications/commit/a32a615) | Conference domain schema, Eloquent models and demo seeder | Environment and Foundations (wk 6–7) |
| [`34e0d2b`](https://github.com/ndashi-chisanga6/ConferenceCheck-Mobile-Analytics-Meals-and-Notifications/commit/34e0d2b) | Sanctum token authentication and event role authorisation | Environment and Foundations (wk 6–7) |
| [`a3cad4b`](https://github.com/ndashi-chisanga6/ConferenceCheck-Mobile-Analytics-Meals-and-Notifications/commit/a3cad4b) | Flutter app scaffold with core layer, auth and event selection | Environment and Foundations (wk 6–7) |
| [`d12947f`](https://github.com/ndashi-chisanga6/ConferenceCheck-Mobile-Analytics-Meals-and-Notifications/commit/d12947f) | Event and attendee management with QR check-in | Progress Review 1 — authenticated skeleton (wk 8) |
| [`4d1a2ee`](https://github.com/ndashi-chisanga6/ConferenceCheck-Mobile-Analytics-Meals-and-Notifications/commit/4d1a2ee) | Meal voucher engine with one-time redemption | Meal Voucher Module (wk 9–11) |
| [`12dea5c`](https://github.com/ndashi-chisanga6/ConferenceCheck-Mobile-Analytics-Meals-and-Notifications/commit/12dea5c) | Session attendance tracking with capacity alerts | Analytics and Sessions (wk 12–14) |
| [`98a0360`](https://github.com/ndashi-chisanga6/ConferenceCheck-Mobile-Analytics-Meals-and-Notifications/commit/98a0360) | Analytics endpoints and CSV report exports | Analytics and Sessions (wk 12–14); CSV ahead of Reporting (wk 17–18) |
| [`dc37173`](https://github.com/ndashi-chisanga6/ConferenceCheck-Mobile-Analytics-Meals-and-Notifications/commit/dc37173) | Notification system with device tokens and delivery records | Notifications (wk 15) |
| [`9465802`](https://github.com/ndashi-chisanga6/ConferenceCheck-Mobile-Analytics-Meals-and-Notifications/commit/9465802) | Feature tests covering the conference API (48 passed) | Test harness (cross-phase, from wk 6–7) |
| [`4dd8391`](https://github.com/ndashi-chisanga6/ConferenceCheck-Mobile-Analytics-Meals-and-Notifications/commit/4dd8391) | Mobile feature screens: dashboard, meals, sessions, notifications | Analytics and Sessions / Notifications, client side (wk 12–15) |
| [`bf4c3d7`](https://github.com/ndashi-chisanga6/ConferenceCheck-Mobile-Analytics-Meals-and-Notifications/commit/bf4c3d7) | System review, accomplishment evidence and revised proposal | Consolidation towards Progress Review 2 (wk 16) |
| [`9be0ccd`](https://github.com/ndashi-chisanga6/ConferenceCheck-Mobile-Analytics-Meals-and-Notifications/commit/9be0ccd) | Static analysis fixes and CI PHP matrix | Test harness (cross-phase) |
| [`e2a5c7f`](https://github.com/ndashi-chisanga6/ConferenceCheck-Mobile-Analytics-Meals-and-Notifications/commit/e2a5c7f) | Attendee my-QR endpoint, used by the mobile app | Post-review fix towards Progress Review 2 (wk 16) |
| [`4ceaeff`](https://github.com/ndashi-chisanga6/ConferenceCheck-Mobile-Analytics-Meals-and-Notifications/commit/4ceaeff) | Dashboard analytics auto-refresh every 30 seconds | Analytics — near-real-time target (wk 12–14) |
| [`5b6a8d2`](https://github.com/ndashi-chisanga6/ConferenceCheck-Mobile-Analytics-Meals-and-Notifications/commit/5b6a8d2) | Firebase Cloud Messaging v1 delivery | Notifications (wk 15) |
| [`3234b88`](https://github.com/ndashi-chisanga6/ConferenceCheck-Mobile-Analytics-Meals-and-Notifications/commit/3234b88) | Unified capacity vocabulary; post-review fix log | Post-review fix towards Progress Review 2 (wk 16) |
| [`61e0992`](https://github.com/ndashi-chisanga6/ConferenceCheck-Mobile-Analytics-Meals-and-Notifications/commit/61e0992) | Offline scan queue with replay on reconnect | Risk mitigation promised in proposal risk table (wk 16) |
| [`ae812f3`](https://github.com/ndashi-chisanga6/ConferenceCheck-Mobile-Analytics-Meals-and-Notifications/commit/ae812f3) | Broadened mobile test coverage (19 Flutter tests) | Test harness (cross-phase) |
| [`9fcb672`](https://github.com/ndashi-chisanga6/ConferenceCheck-Mobile-Analytics-Meals-and-Notifications/commit/9fcb672) | Publication paper working draft; review addendum | Documentation and Paper (wk 21–23, drafted early per Table 4) |
| [`56f53e0`](https://github.com/ndashi-chisanga6/ConferenceCheck-Mobile-Analytics-Meals-and-Notifications/commit/56f53e0) | Mobile theme polish, branded web landing page, end-to-end emulator demo verified ([report 14](progress-reports/14-ui-polish-and-emulator-verification.md)) | Progress Review 2 — end-to-end demonstration (wk 16) |

> Note: the repository history was reconstructed on 2026-07-10 from the working prototype, grouping the work into module-by-module commits; development history before that date is not in git. Commits after that date record development as it happens.
