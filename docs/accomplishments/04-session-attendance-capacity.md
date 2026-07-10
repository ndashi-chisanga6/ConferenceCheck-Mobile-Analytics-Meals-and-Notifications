# Accomplishment 04 — Session Attendance and Capacity Management

**Objective mapping:** Portal Objective 3 (session attendance tracking with capacity management and overcrowding alerts). *Not in the written proposal — added to match the portal listing.*

## What was built

- Session CRUD per event (`/api/events/{event}/sessions`) with venue, times and capacity.
- Attendance scan (`POST .../sessions/{session}/scan`) accepting either `attendee_qr_token` or `attendee_id`, inside a `DB::transaction` with duplicate prevention.
- Attendance listing (`GET .../sessions/{session}/attendance`).
- Every scan response returns a `capacity_status` (`available` / `near_capacity` / `over_capacity`) and a `warning` when capacity is exceeded.
- Mobile: session list with capacity badges, session details, camera + manual scanner ([sessions feature](../../mobile/lib/features/sessions/)), and a session capacity list on the organiser dashboard.

## Verified behaviour (run on 2026-07-09)

| Check | Result |
| --- | --- |
| Scan attendee into session 2 | recorded; `capacity_status: available`, `warning: null` |
| Same attendee scanned again | **rejected** — `duplicate: true` |
| Scan into over-capacity session 3 (16/12 seats) | recorded with `capacity_status: over_capacity`, `warning: "Session capacity exceeded."` |
| Analytics | session 3 reported at 133.33% full, `overcrowded_sessions_count: 1` |

## Limitations

- Over-capacity scans are recorded with a warning rather than refused; that is a reasonable product choice (door staff can still admit) but should be stated in the report.
- Overcrowding "alerts" surface in scan responses and the dashboard; no push notification is fired automatically on overcrowding.
