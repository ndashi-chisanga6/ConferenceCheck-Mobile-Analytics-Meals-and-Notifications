# Accomplishment 01 — Authentication and Role-Based Access

**Objective mapping:** Proposal Objective 1 (mobile application for conference management — security foundation); portal prerequisite "REST API integration".

## What was built

- Token-based authentication with Laravel Sanctum: `POST /api/auth/register`, `POST /api/auth/login`, `POST /api/auth/logout`, `GET /api/auth/me` ([AuthController.php](../../app/Http/Controllers/Api/AuthController.php)).
- Three roles seeded and enforced: **organiser**, **scanner**, **attendee**.
- Per-event role enforcement via [EnsureEventRole](../../app/Http/Middleware/EnsureEventRole.php) middleware — organisers own their events; scanners/attendees act only through an event-scoped pivot role.

## Verified behaviour (run on 2026-07-09, local PostgreSQL)

| Check | Result |
| --- | --- |
| `POST /api/auth/login` (organiser) | `success: true`, Sanctum bearer token returned |
| Analytics without a token | **HTTP 401** |
| `notifications/send` as attendee | **HTTP 403** (role blocked) |
| Auth feature tests | pass (part of 48/48 suite, 174 assertions) |

## Limitations

- Email verification and two-factor exist in the starter scaffold but are not part of the mobile API flow.
