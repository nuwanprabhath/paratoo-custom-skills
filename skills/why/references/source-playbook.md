# Source playbooks

The `why` skill spawns one investigator per available evidence source. Each investigator reads exactly one playbook below. If another MCP is connected (chat, a docs wiki, observability), adapt the closest playbook rather than skipping the source.

| Source | Playbook | Backed by |
|---|---|---|
| Source control history | [`code-archaeology.md`](./sources/code-archaeology.md) | `git`, `glab mr` |
| GitLab issues | [`gitlab-issues.md`](./sources/gitlab-issues.md) | `glab issue` / `glab api` (or a GitLab MCP) |
| In-repo long-form docs | [`in-repo-docs.md`](./sources/in-repo-docs.md) | `rg`, `git log` over `docs/`, `plans/`, `*.md` |
| Error / exception tracking | [`sentry.md`](./sources/sentry.md) | Sentry MCP, only if connected |

Cross-cutting:

- [`incident-postmortem.md`](./sources/incident-postmortem.md). Append for any investigator when the target looks defensive (null/zero guards, retries, timeouts, swallowed errors, Sentry calls, offline-sync fallbacks).

Upstream pstack also ships playbooks for Linear, Notion, Slack, Datadog, and Databricks. They were dropped here because paratoo-fdcp doesn't use those tools; see `THIRD_PARTY_NOTICES.md` for where to find them if that changes.
