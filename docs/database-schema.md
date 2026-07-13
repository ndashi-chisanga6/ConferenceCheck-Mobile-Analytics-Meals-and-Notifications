# Database Schema

The backend uses standard Laravel migrations. Local development is configured for PostgreSQL at `localhost:5432`, database `conferencecheck`, user `postgres`, password `password`. SQLite and MySQL are still supported by changing `.env`.

## Tables

- `users`: application accounts with `role` as `organiser`, `scanner`, or `attendee`.
- `events`: organiser-owned events.
- `event_users`: assigns users to events with an event-specific role.
- `attendees`: event attendee records, optionally linked to a user account.
- `check_ins`: attendee event check-in history.
- `meal_categories`: event meal windows such as Breakfast, Lunch, Supper, or VIP Lunch.
- `meal_vouchers`: one voucher per attendee and meal category, with unique QR token.
- `meal_redemptions`: immutable redemption record for redeemed vouchers.
- `event_sessions`: conference session records exposed by the API as `/sessions`.
- `session_attendance`: attendee check-ins for sessions, including the scanning `device_id` for the audit trail.
- `device_tokens`: Firebase device tokens by user.
- `notifications`: organiser-created event notifications.
- `notification_recipients`: resolved delivery records per user or attendee.
- `personal_access_tokens`: Laravel Sanctum API tokens.

## Note About Session Table Name

Laravel's starter kit already reserves the database table `sessions` for framework web session storage. To avoid a collision, the conference domain stores agenda sessions in `event_sessions` while keeping REST URLs as `/api/events/{event}/sessions`.

## Important Constraints

- `attendees.ticket_code` is unique.
- `attendees.qr_token` is unique.
- `meal_vouchers.qr_token` is unique.
- `meal_vouchers` prevents duplicate vouchers for the same attendee and meal category.
- `meal_redemptions.meal_voucher_id` is unique.
- `session_attendance` prevents duplicate attendee attendance per session.
- `event_users` prevents duplicate user assignment per event.
