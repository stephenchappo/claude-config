---
name: wrap-up
description: End-of-session wrap-up — update worklog, complete Vikunja tasks, note outstanding items
---

You are wrapping up the current work session. Read the `## Wrap-Up Config` section from `~/CLAUDE.md`
to get the machine-specific values used in the steps below. Only perform steps for which the relevant
config values are present — skip steps whose config keys are absent or marked "none".

**IMPORTANT — confirmation flow:**
1. Draft everything first (worklog entry, Vikunja completions, Vikunja creations, wiki update).
2. Present a single summary to the user showing exactly what will be written/changed.
3. Ask **once**: "Shall I make all of these changes?"
4. Only proceed after the user confirms. Do not ask for any further permissions during execution.

---

1. **Summarise the session** — review what was done this conversation and write a concise summary.

2. **Update the worklog file** — append a new dated entry to the configured `Worklog file`, then:
   ```bash
   cd <Worklog git repo> && git add worklog.md && git commit -m "worklog: <date>" && git push
   ```
   Entry format:
   - `## YYYY-MM-DD — Title`
   - What was worked on and completed
   - Decisions made and why
   - **Troubleshooting notes**: Any errors hit, gotchas, workarounds, or non-obvious fixes encountered
     during the session. Capture explicitly — feature flags needed, encoding issues, service restarts,
     unexpected behaviour. Format as:
     ```
     ### Troubleshooting Notes
     - **Issue**: [what went wrong or was unexpected]
       **Fix**: [what resolved it]
       **Why**: [root cause if known]
     ```
   - Outstanding items / blockers (table with Priority and Task columns)

3. **Update the live Wiki.js worklog page** *(skip if `Wiki API` not configured)* —
   Update page using the configured `Wiki API`, `Wiki worklog page ID`, and `Wiki worklog page path`.
   Load token from the configured `Wiki API token` env var. `tags: []` is required or the mutation fails:
   ```python
   query = """mutation UpdatePage($id: Int!, $content: String!) {
     pages {
       update(id: $id, content: $content, isPublished: true, editor: "markdown",
              locale: "en", path: "<Wiki worklog page path>", title: "Worklog",
              description: "", tags: []) {
         responseResult { succeeded message }
       }
     }
   }"""
   # Strip frontmatter before passing content
   ```

4. **Update wiki service/feature pages** *(skip if `Wiki API` not configured)* —
   For every service or feature worked on this session, create or update its wiki page under
   `/services/*` or `/operations/*`. Each page must include a **Troubleshooting** section capturing
   any gotchas, non-obvious setup steps, known issues, and their fixes from this session.
   This is mandatory — do not skip even if the fix seemed minor.

4a. **Update the Plans Registry** *(skip if `Wiki API` not configured)* —
    Check `~/.claude/plans/` for any plans created or updated this session. For each:
    - If **new**: add a row to the Plans Registry (http://192.168.1.100:3000/en/claude/plans, page ID 29) with status ⏳ Pending.
    - If **approved/executed this session**: update the row's status to ✅ Completed or 🔄 In Progress as appropriate.
    Update the page via the Wiki.js GraphQL API using the `WIKI_TOKEN` env var.

5. **Mark Vikunja tasks complete** *(skip if `Vikunja project GID` not configured)* —
   For any tasks fully completed this session, mark them done in Vikunja with a summary note.

6. **Create Vikunja tasks for outstanding items** *(skip if `Vikunja project GID` not configured)* —
   Every row in the Outstanding table MUST have a matching Vikunja task. Use the **exact worklog task
   text** as the Vikunja task name (verbatim). If an existing task covers the same work but has a
   different name, update the worklog text to match the Vikunja name instead.

7. **Regenerate Vikunja tasks file** *(skip if `Vikunja tasks file` not configured)* —
   Fetch all incomplete tasks from the configured Vikunja project GID and write to `Vikunja tasks file`:
   ```json
   {
     "project": "<project name>",
     "project_url": "https://tasks.example.com/projects/<id>",
     "updated": "YYYY-MM-DD",
     "tasks": [{ "name": "Task name", "url": "https://tasks.example.com/tasks/<id>" }]
   }
   ```
   Then: `cd <Worklog git repo> && git add <Vikunja tasks file> && git commit -m "update vikunja-tasks.json" && git push`

8. **Confirm** — report back with what was logged, which Vikunja tasks were completed, and which were created.
