# CLAUDE.md — trillian

Machine-specific context for trillian (primary homelab server).
Universal rules are in `~/.claude/CLAUDE.md`.

## Context

trillian is the primary homelab server running Docker services, with Cloudflare tunnel access for external services. Wiki and Asana are the sources of truth for tasks and documentation.

## Session Start Additions

Repos to `git pull` at session start:
- `/srv/docker/`

Read last 3 entries in the worklog at http://192.168.1.100:3000/worklog for recent context.

## Key References

| Resource | Location |
|----------|----------|
| Asana project | https://app.asana.com/1/1207033739051298/project/1213656559375019 |
| Wiki | http://192.168.1.100:3000 |
| Docker configs | `/srv/docker/` |
| Global env | `/srv/docker/.env` |
| Worklog | http://192.168.1.100:3000/worklog |
| Wiki API | http://192.168.1.100:3000/graphql |
| Wiki API Token | see `~/.claude/secrets.md` |

## Critical Constraints

- **Always ask before rebooting the machine.**
- Never touch `/marvin/` data files without explicit instruction — NAS may be near capacity.
