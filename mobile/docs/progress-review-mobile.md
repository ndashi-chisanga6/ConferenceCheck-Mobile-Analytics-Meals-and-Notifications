# Mobile Progress Review

## Completed

- Flutter Android app created in `mobile/`.
- API base URL supports emulator default and `--dart-define`.
- Token persistence uses secure storage.
- Selected event persistence uses shared preferences.
- Dio API client attaches Bearer token and converts backend errors.
- Role-based navigation is implemented for organiser, scanner, and attendee.
- Organiser dashboard loads backend analytics and charts.
- Meal scan and session scan call real backend endpoints with manual demo fallback.
- Notifications list/send flows use backend endpoints.
- Firebase Messaging setup is safe when config is missing.
- Reports screen downloads/opens CSV files or copies URLs.
- Attendee home, QR, and profile/logout screens are implemented.
- Practical tests were added for envelope parsing, capacity helper, login screen, and token parsing.

## Validation Commands

```bash
flutter pub get
dart format .
flutter analyze
flutter test
```

## Backend Mismatches

No blocking backend mismatch was found. The only documented limitation is attendee QR access: `/api/auth/me` returns the user, not the attendee record. The attendee QR screen documents the assumption and uses the seeded demo token convention.
