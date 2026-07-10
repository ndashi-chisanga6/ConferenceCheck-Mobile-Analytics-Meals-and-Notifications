# API Integration

Default API URL:

```dart
String.fromEnvironment('API_BASE_URL', defaultValue: 'http://10.0.2.2:8000/api')
```

Physical devices should pass:

```bash
flutter run --dart-define=API_BASE_URL=http://YOUR_LAN_IP:8000/api
```

The Laravel backend response envelope is:

```json
{
  "success": true,
  "message": "...",
  "data": {}
}
```

Implemented endpoint groups:

- `POST /api/auth/login`
- `GET /api/auth/me`
- `POST /api/auth/logout`
- `GET /api/events`
- `GET /api/events/{event}/analytics/*`
- `GET /api/events/{event}/meal-categories`
- `GET /api/events/{event}/meal-vouchers`
- `POST /api/events/{event}/meal-vouchers/scan`
- `GET /api/events/{event}/meal-redemptions`
- `GET /api/events/{event}/sessions`
- `POST /api/events/{event}/sessions/{session}/scan`
- `GET /api/events/{event}/notifications`
- `POST /api/events/{event}/notifications/send`
- `POST /api/device-tokens`
- `GET /api/events/{event}/reports/*.csv`

Known API assumption: the backend does not expose the linked attendee QR token directly from `/api/auth/me`. The attendee QR screen documents this and uses the seeded demo attendee token convention for presentation.
