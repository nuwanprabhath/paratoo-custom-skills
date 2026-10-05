# GitLab Issues

## What this source contains

paratoo-fdcp tracks work as GitLab issues on `gitlab.com/ternandsparrow/paratoo-fdcp`. Issues hold the *product* reason for a change — what the field teams, data managers, or funders asked for — which commit messages rarely repeat.

- Issue body: the reported problem or requested feature, often with screenshots and protocol names
- Comments: scope clarifications from maintainers, things already tried, decisions to defer
- Labels: protocol/area labels, priority, release milestone
- Linked and related issues, and the MRs that closed them
- Milestones (release versions like `1.0.12`)

## How to search it

`glab` must be authenticated (`glab auth status`). Commands below are read-only.

```bash
# Read one issue in full, including every comment
glab issue view <n> --comments

# Keyword search (open and closed)
glab issue list --search "<keyword>" --all --per-page 50

# Narrow by label or milestone
glab issue list --label "<label>" --all
glab issue list --milestone "<version>" --all

# MRs that closed or reference an issue
glab api "projects/:id/issues/<n>/closed_by"
glab api "projects/:id/issues/<n>/related_merge_requests"

# Linked issues
glab api "projects/:id/issues/<n>/links"
```

Good search keys: the issue number from the branch name (`2961-regression` → `#2961`), protocol names and UUIDs, Strapi content-type names, the exact UI label or error message the target produces, and the symbol names.

## What good evidence looks like here

- A maintainer comment that states a decision and its reason ("we can't require this field because tablets offline for weeks won't have the LUT yet")
- A field-team report describing the exact bug the target guards against
- An issue closed by the MR that introduced the target, with discussion of alternatives
- A follow-up issue reopening or reversing an earlier decision

## Common pitfalls

- **Issue number ≠ MR number.** `#` is an issue, `!` is an MR. Don't cross them.
- **Duplicates and moved issues.** An issue closed as duplicate often has the real discussion on the other one. Follow the link.
- **Title drift.** Titles get edited; quote the body and comments, not just the title.
- **Confidential issues** may be invisible to the token in use. If a referenced issue 404s, record it as a gap, don't guess its content.

## What to return

Every issue or comment that bears on the question, with:
- The exact text (quoted)
- `#<number>`, comment author, and date
- Whether it's direct (explicitly addresses the question) or circumstantial
- Any MR (`!n`) or other issue it links to, under Additional Leads if outside your scope
