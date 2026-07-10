# Demo Credentials

Run:

```bash
.\php-pgsql.bat artisan migrate --seed
```

All demo accounts use password `password`.

| Role | Email | Purpose |
| --- | --- | --- |
| organiser | organiser@example.com | Manage event, analytics, meals, sessions, notifications, reports |
| scanner | scanner@example.com | Scan meal vouchers and attendee/session QR codes |
| attendee | attendee@example.com | Linked to one seeded attendee and device token |

Seeded event:

- `ConferenceCheck Demo Conference 2026`

Seeded data includes 30 attendees, 4 sessions, Breakfast/Lunch/Supper vouchers, sample check-ins, redemptions, attendance records, and a sent notification.
