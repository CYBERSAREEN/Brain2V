# Efficiency: what makes Brain2V get cheaper over time

The goal is real: a second similar project should cost less time and fewer tokens than
the first. This doc is an honest account of *how* — and where the limits are — so nobody
mistakes reuse for magic.

## The four real mechanisms

1. **Index lookups replace vault scans.** Resolving "`<persona>` personality" or "everything
   tagged pentest" is a hash lookup or a directory `ls`, not a content search across
   every note. As the vault grows, a scan gets more expensive; an index lookup does not.
   This is the single biggest per-request saving, and it compounds as the vault grows.

2. **Distillation replaces raw dumps (storage-side).** When a large source is handed in —
   a whole PDF, an over-explained brief, a long transcript — Brain2V stores only the
   *required* essence plus a pointer to the original file, never the raw material (see
   `knowledge/obs-distillation-protocol.md` and the `/obs-distil` skill). A note that's a
   fraction of the source but still complete is a fraction of the tokens on *every* future
   read. The full source is never lost — the note points at it.

3. **Persisted reuse replaces re-derivation.** Learnings, mistakes-and-fixes, templates,
   and prior solutions are written back every time the loop closes. The next similar
   task reads those instead of re-deriving from scratch — fewer tokens spent re-thinking
   what's already known, and fewer repeated mistakes.

4. **The organiser loads only what a task needs.** `/obs-organiser` initializes on the
   most recent journal + context snapshot + a `by-label/` listing — a near-zero-cost
   situational load — rather than reading the whole vault to "get oriented."

## The honest limits

- There is **no self-optimizing agent** that silently makes each run cheaper on its own.
  The saving is a consequence of the four mechanisms above actually being used. If prior
  work was never persisted, there is nothing to reuse and no speed-up appears.
- **Distillation is lossy on purpose** (it keeps what's *required*), so it always keeps a
  pointer to the untouched source — nothing is actually lost, only the cost of re-reading
  it later. When "required" is uncertain, it keeps more rather than less.
- **Hooks nudge, they don't execute** (see `docs/trigger-points.md`), so "capture on
  failure" and "offer connect" depend on the model acting on the nudge.
- A claim like "4 months → 4 days" is only true when the second project genuinely overlaps
  the first and that overlap was captured. Treat such numbers as a target the reuse
  mechanisms move you toward, never a guarantee.
