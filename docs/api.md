# API Reference

All protected endpoints require `Authorization: Bearer <token>` and return JSON:

```json
{
  "success": true,
  "message": "...",
  "data": {}
}
```

Errors use:

```json
{
  "success": false,
  "message": "...",
  "errors": {}
}
```

## Authentication

- `POST /api/auth/register`
- `POST /api/auth/login`
- `POST /api/auth/logout`
- `GET /api/auth/me`

Login body:

```json
{
  "email": "organiser@example.com",
  "password": "password"
}
```

## Events

- `GET /api/events`
- `POST /api/events`
- `GET /api/events/{event}`
- `PUT/PATCH /api/events/{event}`
- `DELETE /api/events/{event}`

## Attendees

- `GET /api/events/{event}/attendees`
- `GET /api/events/{event}/attendees/me` — the authenticated user's own attendee record (including `qr_token`)
- `POST /api/events/{event}/attendees`
- `GET /api/events/{event}/attendees/{attendee}`
- `PUT/PATCH /api/events/{event}/attendees/{attendee}`
- `DELETE /api/events/{event}/attendees/{attendee}`
- `POST /api/events/{event}/attendees/{attendee}/check-in`
- `POST /api/events/{event}/attendees/check-in/scan`

QR scan body:

```json
{
  "qr_token": "ATTENDEE-DEMO-001"
}
```

Duplicate attendee check-ins return `duplicate: true`.

## Analytics

- `GET /api/events/{event}/analytics/summary`
- `GET /api/events/{event}/analytics/check-ins`
- `GET /api/events/{event}/analytics/meals`
- `GET /api/events/{event}/analytics/sessions`

## Meal Categories and Vouchers

- `GET /api/events/{event}/meal-categories`
- `POST /api/events/{event}/meal-categories`
- `GET /api/events/{event}/meal-categories/{mealCategory}`
- `PUT/PATCH /api/events/{event}/meal-categories/{mealCategory}`
- `DELETE /api/events/{event}/meal-categories/{mealCategory}`
- `POST /api/events/{event}/meal-vouchers/generate`
- `GET /api/events/{event}/meal-vouchers`
- `GET /api/events/{event}/meal-vouchers/{mealVoucher}`
- `POST /api/events/{event}/meal-vouchers/scan`
- `GET /api/events/{event}/meal-redemptions`

Voucher scan body:

```json
{
  "qr_token": "MEAL-DEMO-11-1",
  "device_id": "scanner-phone-1"
}
```

## Sessions

- `GET /api/events/{event}/sessions`
- `POST /api/events/{event}/sessions`
- `GET /api/events/{event}/sessions/{session}`
- `PUT/PATCH /api/events/{event}/sessions/{session}`
- `DELETE /api/events/{event}/sessions/{session}`
- `POST /api/events/{event}/sessions/{session}/scan`
- `GET /api/events/{event}/sessions/{session}/attendance`

Session scan body can use either field, plus an optional scanning-device
identifier that is stored on the attendance record:

```json
{
  "attendee_qr_token": "ATTENDEE-DEMO-001",
  "device_id": "door-scanner-1"
}
```

```json
{
  "attendee_id": 1
}
```

When a scan pushes a session across its warning threshold
(`CAPACITY_WARNING_THRESHOLD`, default 90% of capacity) or over capacity,
the event's organisers automatically receive a push notification and the
alert appears in the notifications feed.

## Device Tokens

- `POST /api/device-tokens`
- `DELETE /api/device-tokens/{deviceToken}`

## Notifications

- `GET /api/events/{event}/notifications`
- `POST /api/events/{event}/notifications/send`
- `GET /api/events/{event}/notifications/{notification}`

Send body:

```json
{
  "title": "Schedule update",
  "message": "Lunch starts in 10 minutes.",
  "target_type": "all_attendees",
  "target_session_id": null
}
```

Supported `target_type` values: `all_attendees`, `session_attendees` (requires `target_session_id`), `organisers`, `scanners`, `custom`.

## Reports

- `GET /api/events/{event}/reports/attendance.csv`
- `GET /api/events/{event}/reports/meals.csv`
- `GET /api/events/{event}/reports/sessions.csv`
- `GET /api/events/{event}/reports/notifications.csv`
