# Obsidian distillation protocol — store the minimum required, never the raw dump

A native Brain2V efficiency principle: when the user hands over something large — a whole
PDF, an over-explained project brief, a long transcript, a pasted document — and wants it
"remembered," the vault should receive **only what future work will actually need**, not
the raw material. Every stored token is a token re-read on every future lookup, so a note
that's 10x smaller but still complete is 10x cheaper forever. This is the storage-side
half of Brain2V's efficiency (the index is the read-side half).

## The rule
**Distil, don't dump.** For any capture larger than a few lines:
1. Extract only the reusable essence — decisions, specs, constraints, exact values,
   gotchas, the "what future-me needs to act on this." Drop verbose restatement,
   pleasantries, throat-clearing, one-off context, and anything a fresh reader could
   re-derive trivially.
2. **Keep a pointer to the source, not its full text.** Record the file path / URL and,
   if truly needed, quote only the specific passages that must be verbatim. Do not paste
   an entire PDF/brief into a note "just in case" — the source file already exists; the
   note is the distilled index into it.
3. **Success test:** "Would future work still have everything it needs from this shorter
   note, without re-reading the original?" If yes, the distillation is correct. If you'd
   have to go back to the source for something load-bearing, that something belongs in
   the note.
4. **Never store secrets** — scrub tokens/keys/passwords to placeholders and record where
   the real value lives, per the linking/personality conventions.

## How much to keep (calibration)
- A 40-page PDF about, say, pentest automation → a note of the handful of techniques,
  tools, and config facts the user will actually reuse, plus the file path. Not 40 pages.
- An over-explained project brief → the goal, the hard constraints, the decisions made,
  the acceptance criteria. Not the paragraph-by-paragraph retelling.
- If the user explicitly says "keep the whole thing verbatim," honour it — but say plainly
  that it costs more tokens on every future read, and offer the distilled version
  alongside.

## Who applies this
- `/obs-distil` — the dedicated skill for "remember this, minimally."
- Every capture skill (`/obs-learn`, `/obs-learn-cyber`, `/obs-mistakes`, `/obs-n8n`,
  `/obs-crewai`, `/obs-hermes`, `/obs-code-personality`) distils by default — none of
  them should paste a raw dump into the vault.
- `/obs-organiser` prefers distilled notes and, when it sees a bloated raw-dump note,
  offers to distil it.

## Honest limit
Distillation is lossy on purpose — it keeps what's *required*, and "required" is a
judgement. When unsure whether something is load-bearing, keep it (or keep the pointer to
the source so nothing is truly lost). Better a slightly larger correct note than a tiny
one missing the one fact a future project needed.
