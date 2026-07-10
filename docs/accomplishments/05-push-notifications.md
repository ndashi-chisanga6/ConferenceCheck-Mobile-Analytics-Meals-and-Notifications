# Accomplishment 05 — Notification System

**Objective mapping:** Portal Objective 4 (push notification system for attendee communications and schedule updates); Proposal Objective 4.

## What was built

- `POST /api/events/{event}/notifications/send` with target types `all_attendees`, `session_attendees`, `organisers`, `scanners`, `custom`; recipient resolution and per-recipient delivery records run in a `DB::transaction`.
- Notification list and details endpoints for the in-app notification feed.
- Device token registration (`POST /api/device-tokens`) so the backend knows each mobile device's FCM token.
- Mobile: notifications feed, send screen (organiser), details screen, and [FirebaseMessagingService](../../mobile/lib/features/notifications/application/firebase_messaging_service.dart) that requests permission, obtains the FCM token and registers it with the backend — failing safely when Firebase config is absent.

## Verified behaviour (run on 2026-07-09)

| Check | Result |
| --- | --- |
| Send "Schedule update" to `all_attendees` (organiser) | `status: sent`, 30 recipient records created with delivery timestamps |
| Send as attendee | **HTTP 403** |
| Validation | missing `message`/`target_type` rejected with field errors |

## Limitations — important for the report

- **Delivery is demo-mode only.** [FirebaseNotificationService](../../app/Services/FirebaseNotificationService.php) logs the send and returns success; it never calls the real FCM HTTP API, even when credentials are configured. No push notification reaches a device yet.
- The mobile app has no `google-services.json`, so `Firebase.initializeApp()` is skipped gracefully and device tokens are never actually registered.
- To fully meet the objective, wire the FCM v1 send call (google/auth JWT + `projects/{id}/messages:send`) and add the Firebase Android config. Until then this is an **in-app notification system with FCM scaffolding**, not a working push pipeline.
