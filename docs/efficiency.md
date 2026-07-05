# Efficiency: what makes Brain2V get cheaper over time

The goal is real: a second similar project should cost less time and fewer tokens than
the first. This doc is an honest account of *how* — and where the limits are — so nobody
mistakes reuse for magic.

## The three real mechanisms

1. **Index lookups replace vault scans.** Resolving "vedant personality" or "everything
   tagged pentest" is a hash lookup or a directory `ls`, not a content search across
   every note. As the vault grows, a scan gets more expensive; an index lookup does not.
   This is the single biggest per-request saving, and it compounds as the vault grows.

2. **Persisted reuse replaces re-derivation.** Learnings, mistakes-and-fixes, templates,
   and prior solutions are written back every time the loop closes. The next similar
   task reads those instead of re-deriving from scratch — fewer tokens spent re-thinking
   what's already known, and fewer repeated mistakes.

3. **The organiser loads only what a task needs.** `/obs-organiser` initializes on the
   most recent journal + context snapshot + a `by-label/` listing — a near-zero-cost
   situational load — rather than reading the whole vault to "get oriented."

## The honest limits

- There is **no self-optimizing agent** that silently makes each run cheaper on its own.
  The saving is a consequence of the three mechanisms above actually being used. If prior
  work was never persisted, there is nothing to reuse and no speed-up appears.
- **Hooks nudge, they don't execute** (see `docs/trigger-points.md`), so "capture on
  failure" and "offer connect" depend on the model acting on the nudge.
- A claim like "4 months → 4 days" is only true when the second project genuinely overlaps
  the first and that overlap was captured. Treat such numbers as a target the reuse
  mechanisms move you toward, never a guarantee.

## Environment-level efficiency (separate from this repo)

Brain2V reduces token cost at the *application* layer (index lookups, reuse, targeted
loads). Separately, at the *environment* layer, the maintainer runs **zap** — a
third-party tool (https://github.com/zerx-lab/zap) that reduces a Claude Code session's
token usage substantially — installed into their Claude Code. zap is **not authored here,
not part of this repo, and not installed by Brain2V's `install.sh`**; it's an independent
tool that anyone can add to their own Claude Code. It's mentioned only to record that
Brain2V is designed to sit *on top of* an already token-optimized environment: the two
compose (zap trims the session, Brain2V avoids re-deriving work), but neither depends on
the other. For zap's own install/config, see its repository — Brain2V does not
re-document it.
