# Backend Progress Review

## Completed

- Laravel API routes enabled through `routes/api.php`.
- Sanctum bearer-token authentication endpoints implemented.
- Role-aware event access middleware added for organisers, scanners, and attendees.
- Core domain migrations and Eloquent models added.
- REST endpoints implemented for events, attendees, analytics, meals, sessions, device tokens, notifications, and reports.
- Meal voucher redemption uses a database transaction and row lock.
- Attendee event check-in uses a database transaction.
- Session attendance scan uses a database transaction and duplicate prevention.
- Notification creation and recipient resolution use a database transaction.
- Firebase notification service supports safe demo mode when credentials are absent.
- CSV exports implemented for attendance, meals, sessions, and notifications.
- Demo seeder creates organiser, scanner, attendee, event, attendees, sessions, meals, vouchers, check-ins, redemptions, attendance, and notifications.
- Feature tests cover critical mobile API paths.

## Validation

Run:

```bash
php artisan test --filter=ConferenceApiTest
```

The focused API test suite covers login, analytics summary, meal voucher scanning, session attendance scanning, demo notifications, and CSV downloads.

## Ready For Flutter Integration

The Flutter app can log in with seeded credentials, store the returned Bearer token, call event endpoints, scan seeded QR tokens, and download CSV reports. Demo mode means notification calls are safe during presentation without Firebase setup.
