# AI Usage Log

**Project:** ConferenceCheck Mobile: Analytics, Meals and Notifications (component 4.3b)
**Student:** Ndashi Bwalya Chisanga (2021470105) · **Supervisor:** Mr. Mofya Phiri

Supports Appendix A of the report. Tool: Claude (Anthropic), through Claude Code.

## Use

| Period | Use |
|---|---|
| To 30/09/2026 | Boilerplate, library and syntax questions, proofreading; help with the strict review and evaluation scripts |
| 07/10 to 14/10/2026 | Code and tests for the fixes the supervisor asked for, the concurrency and freshness scripts, the My meals screen, `tools/build_proposal_v4.py`, and drafts of the revised report, validation document and proposal |

From 7 October this went beyond the proposal's scope (Section 9). The student
chose what to fix and in what order, reviewed every change before committing
it, and checked the test and experiment results. Each change is a commit in
the repository history.

## Representative prompts

1. 07/10: the supervisor's comments pasted in, then "what would we start with fixing".
2. 09/10 and 10/10: "do the next 6 commits".
3. 14/10: the supervisor's comments pasted in, then "work on everything he wants us to".

## Checks

Each fix has a test that fails on the old code and passes now. The concurrency
experiment has a negative control that failed as expected. All tests and static
analysis were run before each commit.

## Data

Only project code, drafts and test output were given to the tool. All
evaluation data is synthetic; no real attendee data was used.

## Gap

The per-use log promised in proposal Section 9.4 was not kept before October.
