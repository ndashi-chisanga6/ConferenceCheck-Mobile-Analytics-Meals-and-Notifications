# Demo Guide

1. Start Laravel backend with .\php-pgsql.bat artisan serve.
2. Run Flutter app.
3. Login as organiser.
4. Select ConferenceCheck demo event.
5. Show analytics dashboard.
6. Open meals.
7. Scan or manually enter a voucher token.
8. Redeem voucher successfully.
9. Try the same voucher again and show duplicate rejection.
10. Open sessions.
11. Scan attendee into a session.
12. Show session capacity update.
13. Send notification.
14. View notification history.
15. Open reports.
16. Logout.
17. Login as scanner and show scanner-focused navigation.
18. Login as attendee and show attendee QR/profile.

Useful seeded QR examples:

- Attendee token: `ATTENDEE-DEMO-001`
- Meal voucher pattern: `MEAL-DEMO-<attendee_id>-<meal_category_id>`

If scanning with a camera is not convenient during a presentation, use the manual token entry fields.
