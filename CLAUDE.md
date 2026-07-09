# Brain2V — Claude Code self-setup

You (Claude Code) are the installer. When a user opens this freshly-cloned repo and asks
to set up Brain2V (or says anything like "install", "set this up", "make my second
brain"), run this sequence — confirming with the user only at the two marked points.

## Setup sequence

1. **Skills + protocols (the v1 core)** — run `./install.sh`. It copies `commands/` into
   `~/.claude/commands/`, `knowledge/` into `~/.claude/knowledge/`, and shows the hook
   block from `hooks/` to merge into `~/.claude/settings.json`. **[confirm with user
   before merging hooks]**
2. **Services** — run `./setup/setup-services.sh`. Installs Graphify (graphify.net) and
   n8n, adds the plugin marketplaces from `plugins.json`, and scaffolds
   `app/config.json`. Report any `[warn]` lines to the user instead of hiding them.
3. **Vault wiring** — ask the user for their Obsidian vault path, write it into
   `app/config.json` (`vaultPath`). Never guess a vault path.
4. **First graph** — run `graphify <vaultPath>` so the semantic graph exists; it lands in
   `<vaultPath>/graphify-out/` and the dashboard serves it at `/graphify`.
5. **First boot** — start `node app/server.js`, confirm `http://localhost:7180` returns
   the dashboard with real numbers, then start `n8n start` and confirm
   `http://localhost:5678/healthz`. Show the user both URLs.
6. **Onboard the human** — run `/obs-introduction` so Brain2V learns who this installer
   is and generates their profession-specific skills via `/obs-skill-maker`.

## Standing rules once installed

- `/obs-organiser` is the router for every request; plugin choice follows
  `knowledge/obs-plugin-routing.md` — do not hardcode plugin usage.
- Every mistake goes to `/obs-mistakes`, every lesson to `/obs-learn` — this is how the
  brain compounds. Never skip it to save time.
- The vault is the user's private brain: nothing from it is ever committed to this repo,
  and credentials live outside both (see `docs/` security notes).
- n8n workflows the user builds are captured via `/obs-n8n` so the organiser can route
  automation work through them later.
