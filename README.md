# ConferenceCheck Mobile API

Laravel REST API backend for **ConferenceCheck Mobile: Analytics, Meals and Notifications**. This module supports organiser analytics, meal voucher QR redemption, session attendance scanning, Firebase Cloud Messaging demo notifications, and CSV reports for a Flutter mobile frontend.

## Requirements

- PHP 8.3+
- Composer
- PostgreSQL for local testing, or SQLite/MySQL if you change `.env`
- Node/npm only if you want to use the starter frontend assets

## Installation

```bash
composer install
cp .env.example .env
.\php-pgsql.bat artisan key:generate
.\php-pgsql.bat artisan migrate --seed
```

By default `.env.example` is configured for the local PostgreSQL database `conferencecheck` using `postgres/password` on `localhost:5432`. For SQLite or MySQL, update `DB_CONNECTION`, `DB_HOST`, `DB_PORT`, `DB_DATABASE`, `DB_USERNAME`, and `DB_PASSWORD`.

## Run the API

```bash
.\php-pgsql.bat artisan serve
```

Or use the convenience wrapper:

```bash
.\serve-pgsql.bat
```

The API will be available at `http://localhost:8000/api`.

## Demo Credentials

All seeded demo accounts use the password `password`.

| Role | Email |
| --- | --- |
| organiser | organiser@example.com |
| scanner | scanner@example.com |
| attendee | attendee@example.com |

## Main Endpoints

- `POST /api/auth/login`
- `GET /api/events`
- `GET /api/events/{event}/analytics/summary`
- `POST /api/events/{event}/attendees/check-in/scan`
- `POST /api/events/{event}/meal-vouchers/scan`
- `POST /api/events/{event}/sessions/{session}/scan`
- `POST /api/events/{event}/notifications/send`
- `GET /api/events/{event}/reports/attendance.csv`

Use the `token` returned by login as a Bearer token:

```http
Authorization: Bearer <token>
Accept: application/json
```

## Firebase Demo Mode

Real push needs a Firebase project and a service-account key:

```env
FIREBASE_PROJECT_ID=
FIREBASE_CREDENTIALS_PATH=
FIREBASE_DEMO_MODE=false
```

If the credentials are missing the send fails and the notification is marked `failed`. To try the app without Firebase, set `FIREBASE_DEMO_MODE=true`: nothing is pushed, a warning is logged, the response says `"demo": true`, and the notification and its recipients are marked `demo`, never `sent`, so a demo run can't be mistaken for delivery.

## Testing

```bash
.\php-pgsql.bat artisan test --filter=ConferenceApiTest
.\php-pgsql.bat artisan test
```

## Documentation

- [API Reference](docs/api.md)
- [Database Schema](docs/database-schema.md)
- [Demo Credentials](docs/demo-credentials.md)
- [Backend Progress Review](docs/progress-review-backend.md)
