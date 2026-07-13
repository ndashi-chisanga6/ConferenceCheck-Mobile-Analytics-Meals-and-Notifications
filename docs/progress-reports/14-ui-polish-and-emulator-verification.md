# Progress Report 14 — UI Polish and End-to-End Emulator Verification

## What was built
A consolidated design pass over both user-facing surfaces. The Flutter app gained a full Material 3 theme — consistent typography weights, button and input shapes, themed navigation bar, snackbars and chips — replacing the minimal seed-colour theme, and the dashboard metric cards were restyled with tinted icon chips and muted labels. The Laravel welcome page, until now the framework's default starter screen, was replaced with a branded ConferenceCheck landing page presenting the six delivered modules (analytics, meal vouchers, session attendance, notifications, offline scanning, CSV reports) with light/dark support.

Alongside the code, the local Android toolchain was completed: Flutter 3.44.6 SDK, Android SDK 36 with accepted licences, and a Pixel 7 (API 36) virtual device, allowing the app to be exercised on an emulator rather than only through analyzer and unit tests.

## How it maps to the objectives
This work targets the proposal's midway checkpoint (Table 4, Progress Review 2: "end-to-end demonstration"). The demonstration path was executed and screenshot-verified on the emulator against the live local backend: login as the seeded organiser, event selection, and the organiser analytics dashboard rendering real aggregates (30 attendees, 19 check-ins, 63.33% check-in rate, 90 vouchers issued, 21 redeemed, 4 sessions). The web landing page was verified in a browser against the running API. Screenshot-driven verification also caught and fixed a theme regression (invisible chip labels on the login screen) before it reached the demo.

## Blockers
None for the demonstration flow. Live push delivery still awaits a Firebase project (`google-services.json` and server credentials); demo mode covers the flow meanwhile. Local disk pressure and an unstable connection made the toolchain installation retry-heavy, which is worth budgeting for on evaluation day.

## Next steps
Run the simulated-event evaluation exercise (proposal Table 3) to collect the acceptance measurements, fill the `[TODO]` markers in the paper draft, and prepare the midway review presentation from the accomplishment documents.
