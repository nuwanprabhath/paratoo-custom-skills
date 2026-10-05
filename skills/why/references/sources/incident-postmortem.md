# Incident & Postmortem Context

Not a separate source, a **cross-cutting angle**. Incidents often motivate defensive code ("we added this check after the X outage"), so if the target looks defensive (null/zero guards, retry logic, timeouts, swallowed errors, feature flags, offline-sync fallbacks), specifically hunt for incident history across every available source:

- **GitLab issues**: search for issues mentioning the error string, the protocol, or labels like `bug`, `regression`, `prod`, `hotfix`; field-team reports of data loss or app crashes
- **In-repo docs**: `docs/debugging-*.md`, `docs/HANDOVER-*.md`, `*_ANALYSIS.md`, `ACTUAL_FIX.md` — this repo writes its postmortems as markdown in the tree
- **Git**: commits with messages like "fix: … crash", "hotfix", "revert" followed by "re-apply with…", or a `fix:` merged straight into a release branch are strong signals
- **Sentry** (if connected): issues whose first-seen/last-seen window aligns with the target's MR merge date, stack traces through the target. `paratooErrorHandler` / `paratooWarnHandler` and `createSentryBreadcrumb` calls near the target tell you what was being reported

If you find an incident link, fetch the full postmortem. Postmortems and handovers often list follow-up actions that tie directly to code changes. When multiple sources corroborate (a Sentry issue is linked from a GitLab issue, which is closed by the MR that added the target, and a handover note describes the fix), the evidence is especially strong.

Worth spending time on when the code's defensive character makes an incident-driven origin plausible. Skip it for code that doesn't look defensive.
