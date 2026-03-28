---
name: wrap-up
description: End-of-session wrap-up — update worklog, complete Asana tasks, note outstanding items
---

You are wrapping up the current work session. Read the `## Wrap-Up Config` section from `~/CLAUDE.md`
to get the machine-specific values used in the steps below. Only perform steps for which the relevant
config values are present — skip steps whose config keys are absent or marked "none".

**IMPORTANT — confirmation flow:**
1. Draft everything first (worklog entry, Asana completions, Asana creations, wiki update).
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

5. **Mark Asana tasks complete** *(skip if `Asana project GID` not configured)* —
   For any tasks fully completed this session, mark them done in Asana with a summary note.

6. **Create Asana tasks for outstanding items** *(skip if `Asana project GID` not configured)* —
   Every row in the Outstanding table MUST have a matching Asana task. Use the **exact worklog task
   text** as the Asana task name (verbatim). If an existing task covers the same work but has a
   different name, update the worklog text to match the Asana name instead.

7. **Regenerate Asana tasks file** *(skip if `Asana tasks file` not configured)* —
   Fetch all incomplete tasks from the configured Asana project GID and write to `Asana tasks file`:
   ```json
   {
     "project": "<project name>",
     "project_url": "https://app.asana.com/...",
     "updated": "YYYY-MM-DD",
     "tasks": [{ "name": "Task name", "url": "https://app.asana.com/..." }]
   }
   ```
   Then: `cd <Worklog git repo> && git add <Asana tasks file> && git commit -m "update asana-tasks.json" && git push`

8. **Confirm** — report back with what was logged, which Asana tasks were completed, and which were created.
