# ConferenceCheck Mobile Flutter App

Flutter Android app for **ConferenceCheck Mobile: Analytics, Meals and Notifications**. It consumes the Laravel API in `C:\Users\Max\Dev\Meal\meal` using Sanctum Bearer tokens.

## Setup

```bash
cd C:\Users\Max\Dev\Meal\meal\mobile
flutter pub get
```

## Backend Requirement

Start the Laravel backend first. The backend `.env` is configured for local PostgreSQL at `postgresql://postgres:password@localhost/conferencecheck`.

```bash
cd C:\Users\Max\Dev\Meal\meal
.\serve-pgsql.bat
```

Default API URL for Android emulator:

```text
http://10.0.2.2:8000/api
```

Physical device example:

```bash
flutter run --dart-define=API_BASE_URL=http://YOUR_LAN_IP:8000/api
```

Android emulator:

```bash
flutter run
```

## Dependencies

- Riverpod
- go_router
- Dio
- flutter_secure_storage
- shared_preferences
- mobile_scanner
- qr_flutter
- fl_chart
- firebase_messaging
- intl
- url_launcher
- path_provider
- open_filex

## Demo Credentials

All passwords are `password`.

- `organiser@example.com`
- `scanner@example.com`
- `attendee@example.com`

## Main Features

- Splash and login with persisted token
- Event selection
- Role-based navigation
- Organiser analytics dashboard
- Meal voucher scan, manual fallback, and redemption history
- Session attendance scan and capacity status
- Notification list/send flow
- Firebase Messaging token registration with safe fallback
- CSV report download/open and URL copy
- Attendee home, notifications, QR, and profile/logout

## Troubleshooting

- If login fails on Android emulator, confirm the backend is running at `http://localhost:8000` on the host.
- For a physical phone, use `--dart-define=API_BASE_URL=http://YOUR_LAN_IP:8000/api`.
- Firebase configuration is optional. Missing Firebase config is caught and logged in debug mode.
- Camera permission is required for QR scanning; a manual token field is available for demos.
