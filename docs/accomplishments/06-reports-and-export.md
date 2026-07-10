# Accomplishment 06 — Reporting and Data Export

**Objective mapping:** Portal Objective 5 (reporting and data export functionality for event organisers). *Not in the written proposal — added to match the portal listing.*

## What was built

- Four CSV exports ([ReportController.php](../../app/Http/Controllers/Api/ReportController.php)), organiser-gated:
  - `GET /api/events/{event}/reports/attendance.csv`
  - `GET /api/events/{event}/reports/meals.csv`
  - `GET /api/events/{event}/reports/sessions.csv`
  - `GET /api/events/{event}/reports/notifications.csv`
- Mobile reports screen: download-and-open via `path_provider` + `open_filex`, or copy the report URL ([reports feature](../../mobile/lib/features/reports/)).

## Verified behaviour (run on 2026-07-09)

All four endpoints returned well-formed CSV with headers, e.g.:

```csv
Attendee,"Meal Category","Redeemed At","Device ID"
"Demo Attendee",Breakfast,"2026-07-09 18:10:16",seed-scanner
```

The notifications report reflected the live send performed during this review (30 recipients).

## Limitations

- The sessions CSV reports capacity status as `ok` while the analytics endpoints use `available`/`near_capacity`/`over_capacity` — the vocabularies should be unified.
- CSV only; no PDF/Excel export.
