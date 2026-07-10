# Accomplishment 02 — Real-Time Analytics Dashboard

**Objective mapping:** Portal Objective 1 (analytics dashboard showing check-in progress, rates and trends); Proposal Objective 2.

## What was built

Backend ([ConferenceController.php](../../app/Http/Controllers/Api/ConferenceController.php)):

- `GET /api/events/{event}/analytics/summary` — attendee totals, check-in %, voucher redemption %, session totals, overcrowded-session count, notifications sent.
- `GET /api/events/{event}/analytics/check-ins` — hourly check-in trend buckets.
- `GET /api/events/{event}/analytics/meals` — redemption counts per meal category.
- `GET /api/events/{event}/analytics/sessions` — per-session attendance, % full, capacity status.

Mobile ([dashboard feature](../../mobile/lib/features/dashboard/)):

- Organiser dashboard with metric cards (attendees, check-in rate, meals, sessions, overcrowding), an `fl_chart` check-in trend chart, meal redemption chart, and session capacity list.
- Pull-to-refresh plus a retry-on-error view (Riverpod `FutureProvider` invalidation).

## Verified behaviour (run on 2026-07-09, seeded demo event)

```json
{"total_attendees":30,"checked_in_attendees":18,"check_in_percentage":60,
 "total_meal_vouchers":90,"redeemed_meal_vouchers":20,"meal_redemption_percentage":22.22,
 "total_sessions":4,"total_session_attendance":56,"overcrowded_sessions_count":1,
 "notifications_sent":1}
```

Check-in trend returned 8 hourly buckets; meal analytics split across Breakfast/Lunch/Supper; session analytics flagged "AI in Event Analytics" at 133% capacity as `over_capacity`.

## Limitations

- "Real-time" is implemented as on-demand refresh (pull-to-refresh), not server push/polling — there is no auto-refresh timer or websocket. Defensible for a demo, but the dashboard only updates when the organiser refreshes.
