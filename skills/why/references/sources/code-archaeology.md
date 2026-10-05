# Code Archaeology (git + GitLab MRs)

## What this source contains

- Commit history (messages, dates, authors, diffs)
- MR descriptions, review comments (human and CodeRabbit), and discussion threads (via `glab`)
- Inline code comments, TODOs, FIXMEs, deprecation notes
- ADRs (architectural decision records) if the repo keeps them
- Tests. Names and assertions often encode the edge cases that motivated a change
- Related files modified in the same commits (co-change signal)
- CHANGELOG entries, release notes in the repo
- GitLab issue numbers (`#n`) in commit messages, branch names, and MR bodies

The most trustworthy source, tied directly to the code, and the most complete. Everything that went through the repo should be here.

## How to search it

Expand the seed commit list:

```bash
# Full history of the file through renames
git log --follow --oneline -- <file>

# Pickaxe: commits that added or removed this exact text
git log -S '<exact_string_from_code>' -- <file>

# Or for patterns:
git log -G '<regex>' -- <file>

# Who wrote each line and when
git blame -L <start>,<end> <file>

# The full diff of a specific commit
git show <hash>

# Commits between two points affecting this file
git log <old>..<new> -p -- <file>
```

For each substantive commit, pull the MR context:

```bash
# Merge commits read "Merge branch '<issue>-<slug>' into '<target>'"; the body often carries "See merge request ...!<n>"
git log -1 --format=%B <hash>

# Which MR(s) contain this commit
glab api "projects/:id/repository/commits/<hash>/merge_requests"

# Full MR context: description, review threads, discussion
glab mr view <n> --comments

# Diff-anchored review threads (where reviewers explain constraints)
glab api "projects/:id/merge_requests/<n>/discussions" --paginate
```

Get past merge commits and back-merges (`dev/1.0.x` into `dev/1.0.y`) with `git blame -w -C -C`, `git log --no-merges`, and `git log --first-parent`.

Look for out-of-band docs:

```bash
# Design docs live in docs/ and plans/ (the in-repo docs investigator covers them in depth)
rg -l -i 'architecture.decision' --glob '*.md'

# TODOs and FIXMEs near the target
rg -n -C2 '(TODO|FIXME|HACK|XXX|NOTE)' <target_file>

# Related tests. Names often encode the "why"
rg -l '<symbol>' --glob '*test*'
```

## What good evidence looks like here

- An MR description that explains the problem being solved, not just the change ("This fixes the pagination bug that caused X")
- A long review thread where alternatives were debated
- An inline comment near the target line that explains a non-obvious constraint
- A test named `test_handles_edge_case_when_X` that reveals an edge case motivating the code
- A commit message that references a issue or incident ID
- A changelog entry that summarizes the user-visible rationale

## Common pitfalls

- **Squash-merge flatlands.** If an MR was squashed, individual commits in the branch history are lost. Fall back to the MR description and discussions.
- **Misleading commit messages.** "Small refactor" sometimes hides an intentional behavior change. Look at the diff, not the message.
- **Cargo-culted patterns.** The author may have copied a pattern without understanding why. Check if the pattern originated earlier in the codebase and investigate *that* commit.
- **Bot commits and auto-merges.** Dependabot, Renovate, and automated backports usually don't carry motivation. Skip them when trying to find intent.
- **Treating code as evidence of intent.** The code itself isn't evidence for why it exists. Evidence comes from commit messages, MRs, comments, tests, docs. Don't cite "the function is named X" as evidence of intent.

## What to return

Every commit/MR/comment that bears on the question, with:
- The exact text (quoted)
- The hash / MR number / file:line
- Author and date
- Whether it's direct (explicitly addresses the question) or circumstantial
