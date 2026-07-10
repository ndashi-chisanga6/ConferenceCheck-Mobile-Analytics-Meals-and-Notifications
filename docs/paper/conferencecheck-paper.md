# Fraud-Resistant Meal Voucher Redemption and Real-Time Operational Analytics for Conference Management: Design and Evaluation of ConferenceCheck Mobile

**Ndashi Bwalya Chisanga** — Department of Computing and Informatics, University of Zambia
**Supervisor:** Mr. Mofya Phiri

> **Status: working draft.** Sections marked `[TODO]` need content or final numbers from the evaluation exercise. Target length 5,000–7,000 words. Structure follows the standard IEEE conference format; convert to the department's required template before submission.

## Abstract

*(Draft — tighten after evaluation results are final.)*

On-site conference operations — meal service, session seating, attendee communication — are still widely managed with paper registers and printed vouchers, processes that scale poorly and are vulnerable to duplicate-collection fraud. This paper presents the design, implementation, and evaluation of ConferenceCheck Mobile, the analytics and operations component of a conference management companion application. The system contributes (i) a QR-code based meal voucher protocol in which single-use redemption is enforced structurally, through database row locking and an append-only redemption relation with a per-voucher uniqueness constraint, rather than through application-level checks; (ii) a near-real-time analytics dashboard with a bounded 30-second staleness guarantee; (iii) session attendance tracking with capacity thresholds and overcrowding alerts; (iv) dual-channel attendee notifications (Firebase Cloud Messaging push plus an audited in-app feed with per-recipient delivery records); and (v) an offline scan queue whose safe replay follows from the server's idempotent scan semantics. Evaluation on seeded event datasets with scripted fraud scenarios shows `[TODO: headline numbers — duplicate rejection rate, median scan latency, throughput vs. manual baseline]`. The results indicate that placing anti-fraud guarantees in the database's constraint machinery eliminates time-of-check-to-time-of-use races by construction while keeping scan-point latency within interactive bounds.

**Keywords:** conference management, QR code, mobile application, idempotency, meal voucher, event analytics, Flutter, push notifications

## 1. Introduction

*(Adapt from proposal §1 — problem framing is stable.)*

- Operational pain points of manual conference management: no live attendance picture, unverifiable meal entitlement, broadcast-only communication.
- Three structural weaknesses of paper processes: duplicability, staleness, unauditability.
- Contribution statement (the five contributions from the abstract, one paragraph each in brief).
- Component context: 4.3b of the ConferenceCheck programme; integrates with the 4.3a core check-in/sync engine and the CMS v4 backend.
- `[TODO: paper roadmap paragraph]`

## 2. Related Work

*(Expand from proposal v2 §2 — the mapping-table argument becomes prose.)*

- QR symbology and its verification properties: ISO/IEC 18004; Tiwari's survey. Design consequence: opaque server-issued tokens.
- QR attendance systems: Masalha & Hirzallah — faster and more accurate than registers, but codes are copyable; anti-fraud must be server-side.
- Idempotence in retried distributed operations: Helland. Design consequence: append-only redemption with uniqueness constraint; safe offline replay.
- Dashboard design and response-time budgets: Few; Nielsen.
- Push messaging reliability model: FCM store-and-forward, best-effort delivery. Design consequence: dual-channel with delivery records.
- Gap: existing tools apply these piecemeal; no integrated operational-control system for conferences. `[TODO: 2–3 additional recent (2022–2026) event-tech papers for currency]`

## 3. System Design

### 3.1 Architecture

*(Reuse Figure 1 from the revised proposal.)*

Three-tier: Flutter client (presentation / Riverpod state / repository layers), Laravel REST API with Sanctum bearer tokens and event-scoped roles (organiser, scanner, attendee), PostgreSQL. FCM as the push channel. Integration boundary with 4.3a via a shared REST contract.

### 3.2 Data Model and Integrity Guarantees

The anti-fraud properties are carried by relations and constraints, not application code:

| Relation | Constraint | Guarantee |
| --- | --- | --- |
| meal_vouchers | unique qr_token; unique (attendee, category) | one voucher per attendee per meal window |
| meal_redemptions | unique meal_voucher_id (append-only) | a voucher is consumed at most once, ever |
| session_attendance | unique (session, attendee) | no double counting at session doors |
| notification_recipients | per-recipient rows | delivery is auditable per attendee |

### 3.3 The Redemption Protocol

Four-step protocol (decode → resolve within transaction → locked insert → immutable audit record). Two scanners submitting the same token concurrently serialise on the row lock; exactly one insert succeeds. Include the sequence description; cite the row-lock + unique-constraint interplay. *(Lift the prose from proposal v2 §3.2 and the implementation in `ConferenceController::scanMealVoucher`.)*

### 3.4 Offline Operation

Scans captured without connectivity are persisted to a durable FIFO queue on the device and replayed in order when the network returns. Replay safety is a corollary of server idempotency: an entry that already reached the server resolves to a definitive duplicate answer rather than a second effect, so the queue can be drained without reconciliation logic. Definitive server answers (success, already-redeemed, duplicate, invalid) settle an entry; only connectivity failures retain it.

### 3.5 Analytics, Capacity Alerts, Notifications, Reporting

- Bounded-staleness dashboard: self-invalidating 30 s fetch cycle; pull-to-refresh retained.
- Capacity states (available / full / over_capacity) evaluated on every door scan; threshold transitions alert organisers.
- Dual-channel notifications: FCM v1 (service-account JWT → OAuth token → per-device send) plus authenticated in-app feed; per-recipient status records quantify reach.
- Streaming CSV exports as the bridge to post-event reconciliation.

## 4. Implementation

- Stack versions: Laravel (PHP 8.5), PostgreSQL 18, Flutter 3.x/Dart, Riverpod, fl_chart, mobile_scanner, qr_flutter, firebase_messaging.
- Code quality gates: PHPStan level 7 (clean), Pint, flutter analyze (clean), CI on PHP 8.4/8.5.
- `[TODO: brief subsection on interesting implementation details — e.g. the event_sessions naming collision, role middleware design]`

## 5. Evaluation

### 5.1 Method

Two levels: (a) automated verification — 51 backend feature tests / 185 assertions covering every business rule including concurrent double-scan, out-of-window redemption, cross-event access and role denial; 19 Flutter unit/widget tests including offline queue semantics; (b) a structured simulated-event exercise (500 attendees, four meal categories, ten sessions) with scripted fraud and load scenarios, measured against the acceptance criteria of the revised proposal (Table 3 there).

### 5.2 Results

| Criterion | Target | Result |
| --- | --- | --- |
| Duplicate redemption rejection | 100% incl. concurrent submissions | verified in automated tests; `[TODO: simulated-event run]` |
| Scan validation latency | median < 500 ms, p95 < 1 s | `[TODO: measure]` |
| Dashboard freshness | ≤ 30 s | by construction (self-invalidating fetch); `[TODO: observed]` |
| Capacity alerting | warning before 100% occupancy | `[TODO: scripted run]` |
| Notification delivery | ≥95% of online devices in 30 s; 100% via inbox | `[TODO: requires live Firebase project]` |
| Export correctness | CSV equals SQL ground truth | `[TODO: automated comparison]` |

### 5.3 Baseline Comparison

Manual paper-register meal line vs. the system: throughput (attendees/minute) and fraud detection rate under scripted duplicate-collection attempts. `[TODO: run and report; expected to dominate on both axes]`

### 5.4 Threats to Validity

Simulated rather than live event; synthetic load patterns; FCM delivery conditioned on Google Play services; single-venue network assumptions.

## 6. Discussion

- The central design argument: constraint-carried guarantees vs. application-level checks — what class of bugs this eliminates (TOCTOU races) and what it costs (schema rigidity).
- Offline replay as a free consequence of idempotent API design.
- `[TODO: reflect on evaluation results once available]`

## 7. Conclusion and Future Work

Summary of contributions and results. Future work: live conference deployment; WebSocket streaming to replace polling; offline-first redemption with conflict resolution (jointly with 4.3a's sync engine); iOS verification; multi-event federation.

## Acknowledgements

Supervisor; Department of Computing and Informatics; `[TODO]`.

## References

*(Numbering matches the revised proposal — reuse and extend.)*

1. ISO/IEC 18004:2015, QR Code bar code symbology specification.
2. S. Tiwari, "An introduction to QR code technology," ICIT 2016.
3. F. Masalha and N. Hirzallah, "A students attendance system using QR code," IJACSA, 2014.
4. S. Few, *Information Dashboard Design*, O'Reilly, 2006.
5. J. Nielsen, *Usability Engineering*, Morgan Kaufmann, 1993.
6. Google, "Firebase Cloud Messaging," Firebase Documentation, 2025.
7. R. T. Fielding, "Architectural styles and the design of network-based software architectures," Ph.D. dissertation, UC Irvine, 2000.
8. M. Jones and D. Hardt, RFC 6750, 2012.
9. Laravel, "Laravel Sanctum," Laravel Documentation, 2025.
10. OWASP Foundation, MASVS v2.0, 2023.
11. P. Helland, "Idempotence is not a medical condition," CACM 55(5), 2012.
12. G. E. Krasner and S. T. Pope, "A cookbook for using the Model-View-Controller user interface paradigm in Smalltalk-80," JOOP 1(3), 1988.
13. K. Schwaber and J. Sutherland, *The Scrum Guide*, 2020.
14. Republic of Zambia, The Data Protection Act, No. 3 of 2021.
15. Google, "Flutter architectural overview," Flutter Documentation, 2025.
16. `[TODO: recent event-technology papers identified during the related-work expansion]`
