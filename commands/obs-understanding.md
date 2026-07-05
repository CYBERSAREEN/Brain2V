---
description: Builds Claude's understanding of the user's personal workflow, methodology, and philosophy — how they work and how they want Claude to work — by reading their Obsidian vault and existing memory. TRIGGER — invoke this proactively via the Skill tool whenever "Obsidian" is mentioned in any form anywhere in the conversation (Obsidian, the vault, vault notes, obs-* commands), not only when /obs-understanding is typed explicitly. Run the full search once per session on first mention; on later mentions in the same session, just apply what was already learned rather than re-running it.
argument-hint: (none)
---

Ignore `$ARGUMENTS` if present — this command takes no parameters.

## 0. Once-per-session guard
Before doing anything else, check whether this has already run earlier in this same
conversation (look back for a prior "Workflow understanding loaded" confirmation from
you). If it already ran this session, skip straight to step 4 — apply what you already
learned, don't re-search or re-announce it. Only redo the full search if the user
explicitly asks for a refresh, or this is a new session.

## 1. Tool setup
If the `mcp__obsidian__*` tools aren't loaded yet, call ToolSearch with
`select:mcp__obsidian__search_query,mcp__obsidian__search_simple,mcp__obsidian__vault_read,mcp__obsidian__vault_get_document_map,mcp__obsidian__vault_list,mcp__obsidian__tag_list`
to load them. Confirm `notesmd-cli` is on PATH (`/usr/local/bin/notesmd-cli` if not) and
enumerate registered vaults via `notesmd-cli list-vaults`.

## 2. Search for workflow/methodology signals
This is about *how they work*, not project content — look specifically for:
- Notes about their note-taking system/method itself (PARA, Zettelkasten, a custom
  system), or titled things like "Workflow", "Process", "Principles", "Philosophy",
  "How I work", "System".
- Tags like `#workflow`, `#methodology`, `#principles`, `#meta`.
- Any explicit statement anywhere about how they want an AI assistant/Claude to behave —
  tone, autonomy, verbosity, when to ask vs. just act.
Use the same multi-method search as `/trace`: `notesmd-cli search-content`,
`mcp__obsidian__search_query`/`search_simple`, and a `grep -rniE` pass over each vault's
real path for these markers.

## 3. Cross-reference existing memory — don't duplicate
Read `~/.claude/projects/-home-kali/memory/MEMORY.md` and the `feedback`/`user`-type
memory files it points to. This step is about finding what the vault reveals that isn't
already captured there — not repeating what you already know.

## 4. Synthesize and apply — don't just report it back
The goal is to actually adjust how you operate for the rest of the session (autonomy
level, verbosity, how much to confirm vs. act, what they value) — not to lecture the
user about their own philosophy.

Only surface a short summary the first time this runs in a session:
```
Workflow understanding loaded: <2-4 bullets on what was found/reinforced>
```
If nothing new turned up beyond what's already in memory, say that briefly ("nothing new
beyond what I already had") instead of padding it out.

## 5. Persist conclusions to memory, not the vault
This command builds *Claude's* model of the user — that belongs in
`~/.claude/projects/-home-kali/memory/` as `user`/`feedback`-type entries, per the
existing memory conventions (see the memory protocol), not as a new note inside the
Obsidian vault itself. The vault is the user's own knowledge base; this command reads it
but writes conclusions back into Claude's own memory index (update or create the
relevant memory file, then add/update its one-line pointer in MEMORY.md).
