# Progress Report 15 — Live Push Delivery Verified

## What was built
Firebase project `conference-app-903a1` connected at both ends: `google-services.json` registered in the Android app (package `com.example.conference_check_mobile`) with the Google Services Gradle plugin wired into the Kotlin-DSL build files, and the service-account key configured server-side (stored outside the repository; `FIREBASE_DEMO_MODE=false`). A missing CA certificate bundle in the bundled PHP was fixed (`curl.cainfo`/`openssl.cafile`) so the backend can complete TLS to Google's OAuth and FCM endpoints.

## How it maps to the objectives
Objective 4 (push notification system) is now fully met and verified end to end on the Android emulator: attendee login registered a real 142-character FCM device token; an organiser send travelled Laravel → service-account OAuth → FCM v1 → Google → the device's notification shade ([evidence](../evidence-push-delivered.png)). Delivery records in `notification_recipients` reflect the send. Verified twice, including after a full machine restart.

## Blockers
None. The old seeded demo token predictably fails (`failed=1`) on every send — cosmetic; real tokens deliver.

## Next steps
Run the simulated-event evaluation exercise (scan latency, concurrent double-scan, throughput vs. manual baseline, CSV-vs-SQL correctness) and fill the results table in the paper draft.
