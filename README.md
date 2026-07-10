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

Notifications are safe to run without Firebase credentials:

```env
FIREBASE_PROJECT_ID=
FIREBASE_CREDENTIALS_PATH=
FIREBASE_DEMO_MODE=true
```

When demo mode is enabled or credentials are missing, notifications are logged and marked as sent without making an external Firebase call.

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
