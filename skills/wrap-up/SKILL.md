---
name: wrap-up
description: End-of-session wrap-up — update worklog, complete Asana tasks, note outstanding items
---

You are wrapping up the current work session. Follow these steps in order:

1. **Summarise the session** — review what was done in this conversation and write a concise summary.

2. **Update the worklog** — append a new dated entry, then push to wiki via two steps:

   **a) Append to `/srv/wiki-content/worklog.md`** (strip frontmatter, keep `---` section separator), then `git add worklog.md && git commit && git push`.

   The entry should include:
   - Date header (## YYYY-MM-DD — Title)
   - What was worked on and completed
   - Any decisions made and why
   - Outstanding items / blockers for next session (as a table with Priority and Task columns)

   **b) Update the live Wiki.js page (id: 6) via GraphQL** — `tags: []` is required or the mutation fails:
   ```python
   query = """mutation UpdatePage($id: Int!, $content: String!) {
     pages {
       update(id: $id, content: $content, isPublished: true, editor: "markdown",
              locale: "en", path: "worklog", title: "Worklog", description: "", tags: []) {
         responseResult { succeeded message }
       }
     }
   }"""
   # Load token from ~/.claude/settings.json env.WIKI_TOKEN
   # Strip frontmatter before passing content
   ```

3. **Mark Asana tasks complete** — for any tasks that were fully completed this session, mark them done in Asana and add a note summarising what was done.

4. **Create Asana tasks for outstanding items** — every row in the Outstanding table MUST have a matching Asana task. Use the **exact worklog task text** as the Asana task name (copy it verbatim from the table). This ensures the VSCode dashboard can always link tasks to Asana. If an existing Asana task covers the same work but has a different name, update the worklog text to match the Asana name instead.

5. **Regenerate `/srv/wiki-content/asana-tasks.json`** — fetch all incomplete tasks from the trillian2 project (GID: 1213656559375019) and write them to this file in the format:
   ```json
   {
     "project": "trillian2 — Server Overhaul",
     "project_url": "https://app.asana.com/1/1207033739051298/project/1213656559375019",
     "updated": "YYYY-MM-DD",
     "tasks": [
       { "name": "Task name", "url": "https://app.asana.com/..." }
     ]
   }
   ```
   Then `cd /srv/wiki-content && git add asana-tasks.json && git commit -m "update asana-tasks.json" && git push`.
   This keeps the homelab VSCode dashboard task links in sync.

6. **Confirm** — report back with:
   - What was logged to the worklog
   - Which Asana tasks were marked complete
   - Which new Asana tasks were created
