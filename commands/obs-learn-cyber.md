---
description: Learns cybersecurity + AI knowledge alongside you — PDFs, course/book notes, MCP concepts, or "what I just did" — acknowledges understanding back to you, and files it so /trace can show how your understanding evolved.
argument-hint: <pasted text | path to a PDF/notes file | a topic to log, e.g. "MCP server security">
---

If `$ARGUMENTS` is empty, ask what to feed in (paste text, a PDF/file path, or a short
description of what you just did) and stop — do not guess content.

## 0. Tool setup
If the `mcp__obsidian__*` tools aren't loaded yet, call ToolSearch with
`select:mcp__obsidian__vault_read,mcp__obsidian__vault_write,mcp__obsidian__vault_list,mcp__obsidian__tag_list`
to load them. Determine the vault path via `notesmd-cli list-vaults` (ask if ambiguous).
Read `~/.claude/knowledge/obs-index-protocol.md` and
`~/.claude/knowledge/obs-linking-protocol.md` once this session if not already done.

## 1. Classify what came in
`$ARGUMENTS` (plus anything attached/pasted in the same turn) is one of:
- **PDF or file path** — a cybersecurity/AI automation doc, whitepaper, cheat sheet. Read
  it directly (the `Read` tool handles PDFs natively).
- **Course/book excerpt** — pasted text from a course transcript, book chapter, or notes.
- **MCP concept** — anything about the Model Context Protocol itself: server/client
  architecture, tool-calling security, auth models, the Burp Suite or Obsidian MCP
  connections already live in this environment. Treat this as its own recognized
  category, not generic text.
- **"What I did" activity log** — the user describing something they just did (ran a
  scan, configured an MCP server, read a CVE writeup, finished a course module). This is
  not a document to summarize — it's the user's own action; see step 3.

If it's ambiguous which, ask in one line rather than guessing which mode to run in.

## 2. Extract and understand
- **PDF/file**: Read it in full (or in chunks if long). Pull out: core concepts, specific
  techniques/tools named, anything that connects cybersecurity and AI specifically
  (AI-assisted pentesting, LLM security, prompt injection as an attack class, AI in
  SOC/automation, etc.) — this command's scope is the *intersection*, not cybersecurity
  or AI alone, so always ask "how does this connect the two?" even when the source
  doesn't frame it that way.
- **Course/book excerpt**: same extraction, plus note the source (course name/module,
  book title/chapter) so it's traceable later.
- **MCP concept**: extract the architectural point being made and its security angle
  specifically — MCP is a live, present topic in this user's own environment (Burp Suite
  MCP proxy, Obsidian MCP), so tie abstract MCP concepts back to those concrete instances
  where possible.
- **Activity log**: don't extract from a document — extract from the user's own
  description. What did they do, what did they learn from doing it, what would they do
  differently next time.

## 3. Acknowledge before filing (do this in the chat reply, not just the saved note)
Restate back, in 2-4 sentences, what you understood — the core concept(s), and
specifically how you're framing the cybersecurity↔AI connection if there is one. This is
a "did I get this right" check, not a summary for its own sake. If you're not sure you
understood a part correctly, say so explicitly rather than filing a confident-sounding
note built on a guess. This step happens whether or not the user asked for it — treat it
as *this command's actual job*, with saving as the persistence step, not the other way
around.

## 4. File it as its own dated note (not appended to one giant log)
Path: `<vault>/CyberAI/<YYYY-MM-DD>-<topic-slug>.md` (create `CyberAI/` if missing).
**Each learning event gets its own note file** — this is deliberate: `/trace <topic>`
builds its timeline from multiple notes scattered across time, and a single
ever-growing log file would collapse that into one appearance instead of a visible
evolution. Frontmatter:
```yaml
---
date: <YYYY-MM-DD>
topic: <short topic name>
source-type: pdf | course | book | mcp-concept | activity
source: <filename, course/book name, or "self-reported activity">
tags: [cyberai, obs, <source-type>]
---
```
Body:
```markdown
# <topic> — <date>

## What this covers
<the extracted concepts, in your own words>

## Cybersecurity <-> AI connection
<the specific intersection point — never skip this section, even if you have to note
"source didn't make this connection explicitly; here's the plausible link" or "no clear
AI connection in this source — logged for cybersecurity-only reference">

## My reflection / open questions
<anything genuinely uncertain, a question worth revisiting, or a place your
understanding and the source's framing differ — this is a shared knowledge base, not a
one-way summary>

## Related
- [[CyberAI/CyberAI-index]]
- [[Journal/<today>]]
- <any specific Pentest/, Personalities/, or other CyberAI note this connects to>
```

## 5. Update the hub note
`<vault>/CyberAI/CyberAI-index.md` is the map into everything filed under this command —
maintain four running lists (append, don't rewrite): **MCP concepts**, **PDFs/courses/
books**, **Activity log**, **Cybersecurity+AI intersection highlights** (the best
cross-connections found so far, curated, not everything). Each entry is a one-line
`[[wikilink]]` to the dated note plus a 3-6 word gist. This index is what makes
`/obs-guide` and `/obs-connect` able to survey the whole knowledge base at a glance
instead of opening every dated note.

## 6. Update the index and cross-link
Upsert `kind: cyberlearn` → this note's path in `.obs-index/index.json`, per the shared
protocol. Per the linking protocol, this note's `## Related` already points at today's
Journal and the hub — also check whether it connects to an existing `Pentest/*` engagement
or `Personalities/*` note and link both ways if so (edit the other note's own `## Related`
to add a link back here).

## 7. Point at /trace when it's earned
If this is at least the second note filed under a given `topic` slug (check the index or
just search `CyberAI/` for the topic), mention to the user in one line that
`/trace <topic>` will now show real evolution across sessions — don't oversell it on the
first note about a brand-new topic, there's nothing to trace yet.

## 8. Confirm
One line: what got saved, where, and the `/trace` pointer from step 7 if applicable.
