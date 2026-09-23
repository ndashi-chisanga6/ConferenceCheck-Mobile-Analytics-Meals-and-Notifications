# Evidence Index

**Project:** ConferenceCheck Mobile: Analytics, Meals and Notifications (component 4.3b)
**Student:** Ndashi Bwalya Chisanga (2021470105) · **Supervisor:** Mr. Mofya Phiri
**Repository:** https://github.com/ndashi-chisanga6/ConferenceCheck-Mobile-Analytics-Meals-and-Notifications (branch `main`)

One page that maps every milestone and deliverable to its proof in the
repository. Each link opens either a file or the exact commit that produced it.

## Point-at-everything links

- Full commit history: https://github.com/ndashi-chisanga6/ConferenceCheck-Mobile-Analytics-Meals-and-Notifications/commits/main
- Backend source: https://github.com/ndashi-chisanga6/ConferenceCheck-Mobile-Analytics-Meals-and-Notifications/tree/main/app
- Mobile source: https://github.com/ndashi-chisanga6/ConferenceCheck-Mobile-Analytics-Meals-and-Notifications/tree/main/mobile/lib
- Tests: https://github.com/ndashi-chisanga6/ConferenceCheck-Mobile-Analytics-Meals-and-Notifications/tree/main/tests
- Evaluation tooling: https://github.com/ndashi-chisanga6/ConferenceCheck-Mobile-Analytics-Meals-and-Notifications/tree/main/tools
- Milestone tracker: https://github.com/ndashi-chisanga6/ConferenceCheck-Mobile-Analytics-Meals-and-Notifications/blob/main/docs/milestone_tracker.md
- Validation report: https://github.com/ndashi-chisanga6/ConferenceCheck-Mobile-Analytics-Meals-and-Notifications/blob/main/docs/validation_report.md
- Strict review: https://github.com/ndashi-chisanga6/ConferenceCheck-Mobile-Analytics-Meals-and-Notifications/blob/main/docs/STRICT-REVIEW.md

## Milestones, with proof

Due dates below mirror the proposal's Table 4 timeline (Section 6), computed
from the submission date of 28/03/2026.

| Milestone | Due | Tag | Proof: commits | Proof: files |
|---|---|---|---|---|
| Proposal and Planning | 11/04/2026 | [`milestone-01-proposal-and-planning`](https://github.com/ndashi-chisanga6/ConferenceCheck-Mobile-Analytics-Meals-and-Notifications/releases/tag/milestone-01-proposal-and-planning) | [`a673dac`](https://github.com/ndashi-chisanga6/ConferenceCheck-Mobile-Analytics-Meals-and-Notifications/commit/a673dac) | `docs/Project_proposal_Ndashi_v3.docx`, `docs/api.md`, `docs/database-schema.md` |
| Requirements and Design | 02/05/2026 | [`milestone-02-requirements-and-design`](https://github.com/ndashi-chisanga6/ConferenceCheck-Mobile-Analytics-Meals-and-Notifications/releases/tag/milestone-02-requirements-and-design) | [`a32a615`](https://github.com/ndashi-chisanga6/ConferenceCheck-Mobile-Analytics-Meals-and-Notifications/commit/a32a615) | conference domain schema, Eloquent models, demo seeder |
| Environment and Foundations | 16/05/2026 | [`milestone-03-environment-and-foundations`](https://github.com/ndashi-chisanga6/ConferenceCheck-Mobile-Analytics-Meals-and-Notifications/releases/tag/milestone-03-environment-and-foundations) | [`fe0a1db`](https://github.com/ndashi-chisanga6/ConferenceCheck-Mobile-Analytics-Meals-and-Notifications/commit/fe0a1db), [`34e0d2b`](https://github.com/ndashi-chisanga6/ConferenceCheck-Mobile-Analytics-Meals-and-Notifications/commit/34e0d2b), [`a3cad4b`](https://github.com/ndashi-chisanga6/ConferenceCheck-Mobile-Analytics-Meals-and-Notifications/commit/a3cad4b) | Laravel scaffold, Sanctum auth/roles, Flutter scaffold |
| Progress Review 1 | 23/05/2026 | [`milestone-04-progress-review-1`](https://github.com/ndashi-chisanga6/ConferenceCheck-Mobile-Analytics-Meals-and-Notifications/releases/tag/milestone-04-progress-review-1) | [`d12947f`](https://github.com/ndashi-chisanga6/ConferenceCheck-Mobile-Analytics-Meals-and-Notifications/commit/d12947f) | authenticated skeleton: event and attendee management with QR check-in |
| Meal Voucher Module | 13/06/2026 | [`milestone-05-meal-voucher-module`](https://github.com/ndashi-chisanga6/ConferenceCheck-Mobile-Analytics-Meals-and-Notifications/releases/tag/milestone-05-meal-voucher-module) | [`4d1a2ee`](https://github.com/ndashi-chisanga6/ConferenceCheck-Mobile-Analytics-Meals-and-Notifications/commit/4d1a2ee) | `app/Http/Controllers/Api/MealController.php` (voucher engine, one-time redemption) |
| Analytics and Sessions | 04/07/2026 | [`milestone-06-analytics-and-sessions`](https://github.com/ndashi-chisanga6/ConferenceCheck-Mobile-Analytics-Meals-and-Notifications/releases/tag/milestone-06-analytics-and-sessions) | [`12dea5c`](https://github.com/ndashi-chisanga6/ConferenceCheck-Mobile-Analytics-Meals-and-Notifications/commit/12dea5c), [`98a0360`](https://github.com/ndashi-chisanga6/ConferenceCheck-Mobile-Analytics-Meals-and-Notifications/commit/98a0360) | `app/Http/Controllers/Api/SessionController.php`, `app/Http/Controllers/Api/AnalyticsController.php` |
| Notifications | 11/07/2026 | [`milestone-07-notifications`](https://github.com/ndashi-chisanga6/ConferenceCheck-Mobile-Analytics-Meals-and-Notifications/releases/tag/milestone-07-notifications) | [`dc37173`](https://github.com/ndashi-chisanga6/ConferenceCheck-Mobile-Analytics-Meals-and-Notifications/commit/dc37173), [`5b6a8d2`](https://github.com/ndashi-chisanga6/ConferenceCheck-Mobile-Analytics-Meals-and-Notifications/commit/5b6a8d2) | `app/Http/Controllers/Api/NotificationController.php`, `docs/evidence-push-delivered.png` |
| Progress Review 2 (Midway) | 18/07/2026 | [`milestone-08-progress-review-2-midway`](https://github.com/ndashi-chisanga6/ConferenceCheck-Mobile-Analytics-Meals-and-Notifications/releases/tag/milestone-08-progress-review-2-midway) | [`7c44415`](https://github.com/ndashi-chisanga6/ConferenceCheck-Mobile-Analytics-Meals-and-Notifications/commit/7c44415) | `docs/progress-reports/14-ui-polish-and-emulator-verification.md` |
| Reporting and Integration | 01/08/2026 | [`milestone-09-reporting-and-integration`](https://github.com/ndashi-chisanga6/ConferenceCheck-Mobile-Analytics-Meals-and-Notifications/releases/tag/milestone-09-reporting-and-integration) | [`c1688a1`](https://github.com/ndashi-chisanga6/ConferenceCheck-Mobile-Analytics-Meals-and-Notifications/commit/c1688a1) | `app/Http/Controllers/Api/ReportController.php`, live FCM verification |
| Evaluation | 15/08/2026 | [`milestone-10-evaluation`](https://github.com/ndashi-chisanga6/ConferenceCheck-Mobile-Analytics-Meals-and-Notifications/releases/tag/milestone-10-evaluation) | [`2d1f446`](https://github.com/ndashi-chisanga6/ConferenceCheck-Mobile-Analytics-Meals-and-Notifications/commit/2d1f446) | `docs/validation_report.md`, `tools/evaluation-results.json` |
| Documentation and Paper | 05/09/2026 | [`milestone-11-documentation-and-paper`](https://github.com/ndashi-chisanga6/ConferenceCheck-Mobile-Analytics-Meals-and-Notifications/releases/tag/milestone-11-documentation-and-paper) | [`9fcb672`](https://github.com/ndashi-chisanga6/ConferenceCheck-Mobile-Analytics-Meals-and-Notifications/commit/9fcb672), [`cf423c9`](https://github.com/ndashi-chisanga6/ConferenceCheck-Mobile-Analytics-Meals-and-Notifications/commit/cf423c9) | `docs/paper/conferencecheck-paper.md` |
| Progress Review 3 / Final Submission | 12/09/2026 | [`milestone-12-final-submission`](https://github.com/ndashi-chisanga6/ConferenceCheck-Mobile-Analytics-Meals-and-Notifications/releases/tag/milestone-12-final-submission) | [`85ad3e7`](https://github.com/ndashi-chisanga6/ConferenceCheck-Mobile-Analytics-Meals-and-Notifications/commit/85ad3e7) | `docs/deliverables/` (Word and PDF), `docs/validation_report.md`, `docs/paper/conferencecheck-paper.md`, `tools/evaluation-results.json` |

## What each tag points at

Tags are annotated; each one marks the commit at which that milestone's work
was actually complete, not merely started. All are listed at
https://github.com/ndashi-chisanga6/ConferenceCheck-Mobile-Analytics-Meals-and-Notifications/tags

| Tag | Commit | Date | What is verifiably present at that commit |
|---|---|---|---|
| `milestone-01-proposal-and-planning` | `a673dac` | 2026-07-10 | Proposal document, API contract (`docs/api.md`) and database schema design added to the repository |
| `milestone-02-requirements-and-design` | `a32a615` | 2026-07-10 | Conference domain migrations, Eloquent models and demo seeder realising the schema design |
| `milestone-03-environment-and-foundations` | `a3cad4b` | 2026-07-10 | Laravel backend scaffold, Sanctum auth and role model, Flutter app scaffold |
| `milestone-04-progress-review-1` | `d12947f` | 2026-07-10 | Event and attendee management with QR check-in — the authenticated skeleton demoed at Progress Review 1 |
| `milestone-05-meal-voucher-module` | `4d1a2ee` | 2026-07-10 | Meal voucher engine with one-time redemption |
| `milestone-06-analytics-and-sessions` | `98a0360` | 2026-07-10 | Session attendance with capacity alerts, analytics endpoints and CSV report exports |
| `milestone-07-notifications` | `dc37173` | 2026-07-10 | Notification system with device tokens and delivery records |
| `milestone-08-progress-review-2-midway` | `7c44415` | 2026-07-13 | Mobile theme polish, branded landing page, end-to-end demonstration verified on the emulator |
| `milestone-09-reporting-and-integration` | `c1688a1` | 2026-07-13 | Live FCM push delivery verified end to end (integration hardening; CSV export itself shipped in milestone 6) |
| `milestone-10-evaluation` | `2d1f446` | 2026-07-14 | Simulated-event evaluation run and results filled into the paper |
| `milestone-11-documentation-and-paper` | `cf423c9` | 2026-07-14 | Documentation and review consolidation (paper drafting started earlier, in `9fcb672`) |
| `milestone-12-final-submission` | `85ad3e7` | 2026-09-23 | Multi-category evaluation run, per-recipient delivery records, Word and PDF deliverables, and the validation report and paper that describe them |

Note: the git history behind these tags was reconstructed on 2026-07-10 from
the working prototype, grouping development into module-by-module commits
(see the note at the end of `docs/STRICT-REVIEW.md`); commits from 2026-07-13
onward record development as it happened. Several tags (6, 9, 11) are the
closest available commit for their phase rather than an exact one-to-one
match, because some deliverables shipped ahead of their nominal week — this
is stated explicitly rather than left implicit.

## Deliverables (Proposal §4), with location

| Deliverable | Location |
|---|---|
| Flutter mobile application (dashboard, meals, sessions, notifications, reports) | [`mobile/lib/features/`](https://github.com/ndashi-chisanga6/ConferenceCheck-Mobile-Analytics-Meals-and-Notifications/tree/main/mobile/lib/features), [`docs/accomplishments/`](https://github.com/ndashi-chisanga6/ConferenceCheck-Mobile-Analytics-Meals-and-Notifications/tree/main/docs/accomplishments) |
| Backend API extensions with test coverage | [`app/Http/Controllers/Api/`](https://github.com/ndashi-chisanga6/ConferenceCheck-Mobile-Analytics-Meals-and-Notifications/tree/main/app/Http/Controllers/Api), [`tests/Feature/ConferenceApiTest.php`](https://github.com/ndashi-chisanga6/ConferenceCheck-Mobile-Analytics-Meals-and-Notifications/blob/main/tests/Feature/ConferenceApiTest.php) |
| Documented REST API contract | [`docs/api.md`](https://github.com/ndashi-chisanga6/ConferenceCheck-Mobile-Analytics-Meals-and-Notifications/blob/main/docs/api.md) |
| Evaluation report | [`docs/validation_report.md`](https://github.com/ndashi-chisanga6/ConferenceCheck-Mobile-Analytics-Meals-and-Notifications/blob/main/docs/validation_report.md), [`tools/evaluation-results.json`](https://github.com/ndashi-chisanga6/ConferenceCheck-Mobile-Analytics-Meals-and-Notifications/blob/main/tools/evaluation-results.json) |
| Technical documentation | [`docs/api.md`](https://github.com/ndashi-chisanga6/ConferenceCheck-Mobile-Analytics-Meals-and-Notifications/blob/main/docs/api.md), [`docs/database-schema.md`](https://github.com/ndashi-chisanga6/ConferenceCheck-Mobile-Analytics-Meals-and-Notifications/blob/main/docs/database-schema.md) |
| Publication-ready paper | [`docs/paper/conferencecheck-paper.md`](https://github.com/ndashi-chisanga6/ConferenceCheck-Mobile-Analytics-Meals-and-Notifications/blob/main/docs/paper/conferencecheck-paper.md) |
| AI-Assisted Development Statement (Proposal §9) | Declared at the project level in the proposal itself; individual commits carry no AI trailer by design |
| Release metadata | [`LICENSE`](https://github.com/ndashi-chisanga6/ConferenceCheck-Mobile-Analytics-Meals-and-Notifications/blob/main/LICENSE), [`CITATION.cff`](https://github.com/ndashi-chisanga6/ConferenceCheck-Mobile-Analytics-Meals-and-Notifications/blob/main/CITATION.cff) |
| Word deliverables and the script that builds them | [`docs/deliverables/`](https://github.com/ndashi-chisanga6/ConferenceCheck-Mobile-Analytics-Meals-and-Notifications/tree/main/docs/deliverables), [`tools/build_docx_deliverables.py`](https://github.com/ndashi-chisanga6/ConferenceCheck-Mobile-Analytics-Meals-and-Notifications/blob/main/tools/build_docx_deliverables.py), [`tools/paginate_report.py`](https://github.com/ndashi-chisanga6/ConferenceCheck-Mobile-Analytics-Meals-and-Notifications/blob/main/tools/paginate_report.py) |

## Key commits, what each one proves

| Commit | Proves |
|---|---|
| [`a673dac`](https://github.com/ndashi-chisanga6/ConferenceCheck-Mobile-Analytics-Meals-and-Notifications/commit/a673dac) | Proposal, API contract and schema design committed |
| [`4d1a2ee`](https://github.com/ndashi-chisanga6/ConferenceCheck-Mobile-Analytics-Meals-and-Notifications/commit/4d1a2ee) | Concurrency-safe single-use voucher redemption |
| [`61e0992`](https://github.com/ndashi-chisanga6/ConferenceCheck-Mobile-Analytics-Meals-and-Notifications/commit/61e0992) | Offline scan queue with replay on reconnect (risk mitigation promised in the proposal) |
| [`5b6a8d2`](https://github.com/ndashi-chisanga6/ConferenceCheck-Mobile-Analytics-Meals-and-Notifications/commit/5b6a8d2) | Real Firebase Cloud Messaging v1 delivery implemented |
| [`c1688a1`](https://github.com/ndashi-chisanga6/ConferenceCheck-Mobile-Analytics-Meals-and-Notifications/commit/c1688a1) | Live FCM push delivery verified end to end on a device |
| [`2c24a1a`](https://github.com/ndashi-chisanga6/ConferenceCheck-Mobile-Analytics-Meals-and-Notifications/commit/2c24a1a) | Automatic capacity alerts and per-device scan identity |
| [`2d1f446`](https://github.com/ndashi-chisanga6/ConferenceCheck-Mobile-Analytics-Meals-and-Notifications/commit/2d1f446) | Simulated-event evaluation run, results filled into the paper |
| [`46cee57`](https://github.com/ndashi-chisanga6/ConferenceCheck-Mobile-Analytics-Meals-and-Notifications/commit/46cee57) | God controller split into five per-resource controllers plus `NotificationDispatchService` |

Links resolve for anyone with access to the repository. To confirm a single
point live, open the commits page and read the message and changed files for
the hash named above.
