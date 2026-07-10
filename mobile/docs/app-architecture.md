# App Architecture

The app is organized by feature with shared core services.

- `app/`: Material app, theme, and go_router configuration.
- `core/api`: Dio client, backend envelope parsing, and API exceptions.
- `core/storage`: token and selected event persistence.
- `core/widgets`: reusable UI components.
- `features/auth`: login, token bootstrap, logout, and user state.
- `features/events`: event loading and selected event state.
- `features/dashboard`: analytics API, charts, and metrics.
- `features/meals`: categories, voucher scanning, redemptions, and generation.
- `features/sessions`: session list, attendance, and scanner flow.
- `features/notifications`: Firebase token registration, history, and send form.
- `features/reports`: CSV report definitions, download/open, and URL copy.
- `features/attendee`: attendee home and QR screen.
- `features/profile`: profile, change event, and logout.

Riverpod owns state and dependency injection. Dio attaches the Sanctum Bearer token from secure storage to every API request.
