# Strict Review — ConferenceCheck Mobile: Analytics, Meals and Notifications

**Reviewed:** 2026-07-09/10, on a live local environment (PHP 8.5.8, PostgreSQL 18, Flutter 3.44.6).
**Method:** full backend test suite, live API calls against seeded data (including adversarial cases: double scans, invalid QR, wrong roles, no auth), Flutter analyzer + test suite, and code inspection of every claimed safeguard.

## Verdict

The prototype **satisfies the core of the portal listing and the proposal**: analytics, QR meal vouchers with genuine one-time-use enforcement, session capacity tracking with overcrowding alerts, role-secured APIs, CSV exports, and a working role-aware Flutter app. **It does not yet deliver real push notifications** (FCM is stubbed at both ends) and several proposal promises (offline support, publication paper) are outstanding. Suitable evidence for an early progress review; not yet a finished solution.

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
| 1 | Real-time analytics dashboard (progress, rates, trends) | **Met with caveat** — data and charts work; "real-time" is pull-to-refresh, no auto-refresh/push | [02-analytics-dashboard.md](accomplishments/02-analytics-dashboard.md) |
| 2 | Meal voucher scanning & redemption across categories | **Met** — 3 categories, camera + manual scan, concurrency-safe one-time use | [03-meal-voucher-system.md](accomplishments/03-meal-voucher-system.md) |
| 3 | Session attendance with capacity mgmt & overcrowding alerts | **Met** — duplicate prevention, capacity status, warnings; alerts are in-response/dashboard only | [04-session-attendance-capacity.md](accomplishments/04-session-attendance-capacity.md) |
| 4 | Push notification system | **Partially met** — targeting, recipients, in-app feed, FCM scaffolding all work; **no real FCM delivery** (backend service is a stub; no `google-services.json` in the app) | [05-push-notifications.md](accomplishments/05-push-notifications.md) |
| 5 | Reporting and data export | **Met** — 4 organiser-gated CSV exports + mobile download | [06-reports-and-export.md](accomplishments/06-reports-and-export.md) |
| 6 | Technical documentation & publication-ready paper | **Partially met** — API/schema/architecture/progress docs exist; **no paper started** | [docs/](.) and [mobile/docs/](../mobile/docs/) |

## Compliance — proposal (28/03/26)

| Proposal item | Status |
| --- | --- |
| Objective 1: mobile app for conference management | **Met** — role-aware Flutter app, analyzer-clean, tests passing ([07-flutter-mobile-app.md](accomplishments/07-flutter-mobile-app.md)) |
| Objective 2: analytics dashboard for attendance | **Met** |
| Objective 3: secure QR meal voucher system | **Met** — incl. the proposed "backend validation and one-time use" mitigation, done properly with row locks |
| Objective 4: push notifications for real-time updates | **Partially met** (see above) |
| Scope: Flutter, QR vouchers, dashboard, notifications | On track; declared tech stack (Dart, Flutter, Riverpod, fl_chart, qr_flutter, mobile_scanner, FCM, Laravel, PostgreSQL) matches what is actually used |
| Out of scope: payments, full web admin, external ticketing | Correctly absent |
| Risk mitigation: "offline support and retry mechanisms" | **Not implemented** — only manual retry buttons; scans fail without connectivity, nothing is queued |
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

## Accomplishment documents

1. [Authentication and role-based access](accomplishments/01-authentication-and-roles.md)
2. [Analytics dashboard](accomplishments/02-analytics-dashboard.md)
3. [QR meal voucher system](accomplishments/03-meal-voucher-system.md)
4. [Session attendance and capacity](accomplishments/04-session-attendance-capacity.md)
5. [Notification system](accomplishments/05-push-notifications.md)
6. [Reporting and CSV export](accomplishments/06-reports-and-export.md)
7. [Flutter mobile application](accomplishments/07-flutter-mobile-app.md)

## Commit history (local — becomes clickable links after pushing to GitHub as `<repo-url>/commit/<hash>`)

Each module commit carries a short progress report under [docs/progress-reports/](progress-reports/) covering what was built, the objective mapping, blockers and next steps.

| Commit | Content |
| --- | --- |
| `fe0a1db` | Laravel backend scaffold and development tooling |
| `a673dac` | Project proposal, API contract and database schema design |
| `a32a615` | Conference domain schema, Eloquent models and demo seeder |
| `34e0d2b` | Sanctum token authentication and event role authorisation |
| `d12947f` | Event and attendee management with QR check-in |
| `4d1a2ee` | Meal voucher engine with one-time redemption |
| `12dea5c` | Session attendance tracking with capacity alerts |
| `dc37173` | Notification system with device tokens and delivery records |
| `98a0360` | Analytics endpoints and CSV report exports |
| `9465802` | Feature tests covering the conference API (48 passed) |
| `a3cad4b` | Flutter app scaffold with core layer, auth and event selection |
| `4dd8391` | Mobile feature screens: dashboard, meals, sessions, notifications |

> Note: the repository history was reconstructed on 2026-07-10 from the working prototype, grouping the work into module-by-module commits; development history before that date is not in git.
