# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working in this environment.
Machine-specific context is in `~/CLAUDE.md` on each machine.

## Git — Always Keep Repos Up To Date

**This is mandatory, no exceptions.**

- **At session start**: `git pull` in every relevant repo before doing anything else.
- **Before making any changes**: `git pull` to ensure you're working from the latest state.
- **After making any changes**: stage, commit, and push immediately — never leave uncommitted changes.
- **If a change is made outside a git repo**: flag it to the user and ask whether a git repo should be initialised for that location.

## Session Start

1. `git pull` in all relevant repos (listed in machine-specific `~/CLAUDE.md`).
2. Read the worklog (location in `~/CLAUDE.md`) — last 3 entries minimum.
3. Check Asana for open or in-progress tasks.
4. If context is unclear, ask before making assumptions.

## Session End

When told "we're done for the day" or similar, use the `wrap-up` skill:
1. Add a dated entry to the worklog summarising what was done.
2. Mark completed Asana tasks as done.
3. Note any outstanding items or blockers.

## Asana

- **Before starting any work**, check if a relevant Asana task exists. If not, create one first.
- Mark tasks complete immediately when finished — don't batch completions.
- Add meaningful notes to completed tasks (what was done, key paths, decisions).
- If new work is discovered mid-session, create an Asana task for it before continuing.

## Wiki

- **Every completed task gets a wiki page** (or an update to an existing one).
- Done means: task complete + documented.
- Use the GraphQL API to create/update pages programmatically.
- Use Mermaid diagrams for architecture and pipelines wherever helpful.
- Standard page structure:
  - `/home` — overview, network diagram, services table
  - `/infrastructure/*` — servers, networking, storage, tunnels
  - `/services/*` — individual Docker services
  - `/operations/*` — runbooks, how-tos
  - `/worklog` — running session log

## Docker & Services

- All compose files: `/srv/docker/<service>/docker-compose.yml`
- Global env vars: `/srv/docker/.env`
- Services needing Cloudflare tunnel access must join the `tunnel-net` external network.
- Never publish ports for tunnel-only services.
- After changing a compose file: `docker compose up -d` from the service directory.
- For `.env` symlink: `ln -sf /srv/docker/.env /srv/docker/<service>/.env`

## Safety Rules

- Never delete config directories without confirming with the user first.
- Never remove a running container without checking what depends on it.
- Before any destructive action, state what will be deleted and wait for confirmation.
- Prefer `docker compose down` over `docker rm -f`.
- Never touch NAS data files without explicit instruction.

## Communication

- Keep responses concise — lead with action or answer, not explanation.
- When something unexpected is found, flag it and create an Asana task.
- If a task is more complex than expected, say so before diving in.
- Document decisions and rationale in both worklog and the relevant wiki page.
