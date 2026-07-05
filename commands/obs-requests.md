---
description: Fires just before a session ends — reviews this session's prompts, researches the ambiguous/typo-heavy/misrouted ones, and drafts a clean "what you meant" version of each. Next time a similar prompt comes in, Claude checks this first, proposes that refined interpretation, and asks "is this what you meant?" before proceeding.
argument-hint: (none) — fires at SessionEnd; or "review <topic>" to check refined prompts for a topic
---

If `$ARGUMENTS` is empty and this wasn't fired by the SessionEnd hook, ask what to review
and stop.

## 0. Tool setup
If `mcp__obsidian__*` isn't loaded, ToolSearch
`select:mcp__obsidian__vault_read,mcp__obsidian__vault_write,mcp__obsidian__vault_list`.
Vault path via `notesmd-cli list-vaults`. Read
`~/.claude/knowledge/obs-index-protocol.md` and `~/.claude/knowledge/obs-linking-protocol.md`
once this session if not already done.

## 1. Collect this session's prompts (honest limit up front)
Look back over **this conversation's own context** for what the user actually typed —
there is no separate transcript store to query; whatever has already scrolled out of
context (via compaction/clear) is not recoverable here. If `Context/session-log.md`
snapshots exist from `/obs-retain-context`, they can fill some of that gap. Say plainly
if you know the review is partial for this reason — don't imply you saw the whole
session when you didn't.

## 2. Pick candidates worth researching
Not every prompt needs this — routine, clear requests don't. Flag a prompt as a
candidate when it shows any of: typos/unclear phrasing that needed re-reading, required
a clarifying question before you could act, got corrected or redirected after you acted,
was misrouted (e.g. content dropped into the wrong command's argument — see
`[[trace_as_input_box]]`-style patterns), or the user had to repeat/rephrase to get the
result they wanted.

## 3. Research each candidate
For each: compare what was literally typed against what the user demonstrably meant —
use the clarifying questions asked, corrections given, and the final accepted outcome as
evidence, not guesswork. Write a **refined version**: the same request, restated clearly,
typo-free, unambiguous, structured the way it should have been phrased to get the right
result on the first pass with no back-and-forth. Do not sanitize the *original* — keep it
verbatim, typos and all, since the raw phrasing is itself the signature used for matching
later.

## 4. File as its own dated note
Path: `<vault>/Requests/<YYYY-MM-DD>-<slug>.md` (create `Requests/` if missing) — one
note per refined prompt, so `/trace <topic>` can show how your phrasing/intent on a
recurring kind of request evolved. Frontmatter: `date`, `kind: request`,
`tags: [requests, obs]`. Body:
```markdown
# <short label> — refined <date>

## Original (verbatim)
<exact original prompt, typos included — this is the match signature>

## What you actually meant (researched)
<the evidence: what clarified it, what got corrected, what was finally accepted>

## Refined prompt
<the clean, unambiguous restatement>

## Related
- [[Requests/Requests-index]]
- [[Journal/<today>]]
```
Maintain `Requests/Requests-index.md` as the map (one line per entry: date, short label,
gist of the refinement).

## 5. Apply next time — state it, then just ask permission (this is the point)
Whenever a new prompt arrives that plausibly matches a filed request (same topic,
overlapping phrasing/keywords — check via `.obs-index/by-label/request/` and the index,
not a full-vault search), do this **before** producing the full response:
1. **State the inferred requirement plainly and confidently** — don't hedge with a long
   re-explanation of your reasoning. The whole point of accumulating history in
   `Requests/`, `CodePersonality/`, `Life/`, etc. is that Claude should increasingly know
   what the user means without re-deriving it from scratch each time. A one-line
   statement of the interpretation is the goal, not a paragraph justifying it.
2. Ask a **fast permission check**, not a full re-confirmation: "→ proceeding on that
   basis — go ahead?" rather than a drawn-out "is this what you meant, here's my
   reasoning, please confirm every part." The confidence should visibly grow as more
   matching history accumulates — a topic with one prior refined entry still deserves a
   fuller check; a topic with many consistent prior entries deserves a short one.
3. Only proceed once permission is given; if the user says no or redirects, treat the
   new prompt on its own terms and consider filing *that* as a new refined entry (the
   correction itself is signal — a mismatch here is exactly the kind of thing worth
   researching at the next `/obs-requests` run).
Matching is **best-effort** (keyword/topic overlap via the index), not guaranteed
semantic matching — that imprecision is exactly why a permission check happens every
time a match is used, even a fast one. "Fast" is not "skipped."

## 6. Index it
Upsert per the shared protocol — hash index + `by-label/request/` symlink.

## 7. Confirm
One line: how many candidates were found and filed this run (or "none found — nothing
this session needed refining"), and whether the review was partial due to lost context.
