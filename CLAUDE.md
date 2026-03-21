# Claude — Working Rules

Rules and conventions for Claude when working on the trillian2 home lab.
Source of truth is the wiki at http://192.168.1.100:3000/claude-rules

---

## Session Start

- Read the worklog (http://192.168.1.100:3000/worklog) to understand what was last worked on
- Check the Asana project for any open or in-progress tasks
- If context is unclear, ask before making assumptions

## Session End

- When told "we're done for the day" or similar:
  1. Add a dated entry to the wiki worklog (/worklog) summarising what was done
  2. Mark completed Asana tasks as done (if not already)
  3. Note any outstanding items or blockers in the worklog

## Asana

- **Before starting any work**, check if a relevant Asana task exists. If not, create one first.
- Mark tasks complete immediately when finished — don't batch completions
- Add meaningful notes to completed tasks (what was done, key paths, decisions)
- If new work is discovered mid-session, create an Asana task for it before continuing

## Wiki

- **Every completed task gets a wiki page** (or an update to an existing one)
- Done means: task complete + documented
- Wiki: http://192.168.1.100:3000 — use the GraphQL API to create/update pages programmatically
- Use Mermaid diagrams for architecture and pipelines wherever helpful
- Page structure:
  - /home — overview, network diagram, services table
  - /infrastructure/* — servers, networking, storage, tunnels
  - /services/* — individual Docker services
  - /operations/* — runbooks, how-tos
  - /worklog — running session log

## Docker & Services

- All compose files: /srv/docker/<service>/docker-compose.yml
- Global env vars: /srv/docker/.env
- Services needing Cloudflare tunnel access must join the tunnel-net external network
- Never publish ports for tunnel-only services
- After changing a compose file: docker compose up -d from the service directory
- For .env symlink: ln -sf /srv/docker/.env /srv/docker/<service>/.env

## Safety Rules

- Never delete config directories without confirming with the user first
- Never touch /marvin/ data files without explicit instruction — NAS is at 95% capacity
- Never remove a running container without checking what depends on it
- Before any destructive action, state what will be deleted and wait for confirmation
- Prefer docker compose down over docker rm -f

## Communication

- Keep responses concise — lead with action or answer, not explanation
- When something unexpected is found, flag it and create an Asana task
- If a task is more complex than expected, say so before diving in
- Document decisions and rationale in both worklog and the relevant wiki page

## Key References

| Resource | Location |
|----------|----------|
| Asana project | https://app.asana.com/1/1207033739051298/project/1213656559375019 |
| Wiki | http://192.168.1.100:3000 |
| Docker configs | /srv/docker/ |
| Global env | /srv/docker/.env |
| Worklog | http://192.168.1.100:3000/worklog |
| Wiki API | http://192.168.1.100:3000/graphql |
| Wiki API Token | see `~/.claude/secrets.md` |
