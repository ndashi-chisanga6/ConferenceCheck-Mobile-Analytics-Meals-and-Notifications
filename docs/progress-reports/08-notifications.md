# Progress Report 08 — Notification System with Delivery Records

## What was built
The attendee communication pipeline: a device token registry (mobile clients register their Firebase Cloud Messaging tokens per user), organiser-composed notifications targeted at all attendees, organisers, scanners, or the attendees of a specific session, and a dispatch service. Sending resolves the target audience into individual `notification_recipients` rows before any delivery is attempted, so every notification has an auditable per-recipient record with status and delivery timestamp. Notifications are also readable through an authenticated in-app feed, giving attendees without working push a second channel.

## How it maps to the objectives
Objective 4 (push notification system for attendee communications and schedule updates). Targeting, recipient resolution, delivery bookkeeping and the in-app feed are done end to end.

## Blockers
Live FCM delivery is not wired yet: the Firebase service class is currently a stub pending a Firebase project and service-account credentials, and the Android app still needs its `google-services.json`. The surrounding pipeline (tokens, recipients, statuses) is real, so swapping the stub for genuine FCM v1 sends is an isolated change.

## Next steps
Analytics endpoints for the organiser dashboard, and CSV report exports.
