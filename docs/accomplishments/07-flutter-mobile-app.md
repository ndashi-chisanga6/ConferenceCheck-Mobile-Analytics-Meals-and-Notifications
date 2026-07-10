# Accomplishment 07 — Flutter Mobile Application

**Objective mapping:** Proposal Objective 1 (mobile application for conference management); portal technologies Flutter 3.x, Dart, Provider/Riverpod, fl_chart, REST API.

## What was built

A feature-first Flutter app ([mobile/](../../mobile/)) with 73 Dart source files:

- **Architecture:** Riverpod state management, go_router navigation, Dio API client with bearer-token injection and error envelope conversion, secure token storage (`flutter_secure_storage`), selected-event persistence (`shared_preferences`).
- **Role-based navigation:** organiser (dashboard/meals/sessions/notifications/reports tabs), scanner (scan-focused tabs), attendee (home, personal QR via `qr_flutter`, notifications).
- **Scanning:** `mobile_scanner` camera scanning with a debounce lock plus manual token entry fallback, for both meal vouchers and session attendance.
- **Dashboard:** metric cards, fl_chart check-in trend and meal charts, session capacity list.
- **Reports:** CSV download/open (`path_provider` + `open_filex`) or copy URL.
- API base URL configurable via `--dart-define=API_BASE_URL=...` (defaults to Android-emulator `10.0.2.2:8000`).

## Verified behaviour (Flutter 3.44.6 / Dart 3.12.2, 2026-07-10)

| Check | Result |
| --- | --- |
| `flutter pub get` | resolves cleanly |
| `flutter analyze` | **No issues found** (68.7s) |
| `flutter test` | **All 4 tests passed** (API envelope parsing, capacity threshold helper, login screen widget, QR token parsing) |

## Limitations

- Verified via analyzer + test suite on this machine; end-to-end device/emulator run still to be demonstrated (no Android emulator installed here).
- Attendee "My QR" screen derives its token from the seeded demo naming convention instead of fetching the real attendee record — works for demo accounts only (documented in the code itself).
- Widget-test coverage is thin (4 tests) relative to the number of screens.
