---
name: recurring-items
description: >-
  Creates a new copy of a recurring Top Level Task and all its Child
  items from a fixed template in references/templates.md, assigned to
  the person configured there, on the current sprint. Manual mode shows
  the buttons from that file in table order. Auto mode (argument
  `auto`, used by a scheduled task) creates the monthly items that are
  due and not yet created this month, tags them, and sends a
  notification. Updates the month name or date in the text where the
  template defines it. A button may reuse another button's template,
  skip Child items listed in its Child filter, and shorten the title.
  Sample button labels are fictional: סקירה חודשית, עדכון אמצע חודש,
  דיווח תחילת חודש, דיווח קצר. Replace those labels in this
  description when you change the Buttons table. Use when the user
  says recurring items, אייטמים חוזרים, אייטמים חודשיים,
  תפתח את האייטמים החודשיים, דיווח קצר, רק דיווח קצר, names a button
  label from references/templates.md, or asks to create the same
  items as last month.
argument-hint: <optional: auto | button number or label from references/templates.md>
---

# /recurring-items — Create recurring items from a template

Create one new Top Level Task and a new copy of each of its Child items
from a fixed template.

Use this skill for the workflow.
The buttons, auto schedule, template IDs, fixed field values, and text
replacements live only in
[references/templates.md](references/templates.md).

Sample organization, project, people, template IDs, and button labels
in that file are fictional. Replace them before use.

Use the connected Azure DevOps MCP server for all Azure DevOps reads
and writes.

Do not use Azure CLI, PowerShell, Bash, REST calls, or local scripts.

---

## Prerequisites

- Azure DevOps MCP is connected and authenticated.
- Organization: the URL in [references/templates.md](references/templates.md)
- Template config: [references/templates.md](references/templates.md)

---

## Modes

- **Manual** — the user runs `/recurring-items`, optionally with a
  button number or label. Ask when something is unclear.
- **Auto** — the argument is `auto`. A scheduled task runs it every
  workday morning. Nobody is watching, so:
  - Never use `AskUserQuestion` and never wait for an answer.
  - When a manual run would ask, skip that button, create nothing for
    it, and report it as a failure.
  - Create only the buttons that are due (step 1).

---

## Execution Rules

- Read this skill and `references/templates.md`.
- Do not search unrelated workspace files, previous chats, or old scripts.
- Use Azure DevOps MCP for all Azure DevOps operations.
- Create exactly one Top Level Task per button, plus one new Child item
  per template Child item.
- Never edit, close, or relink the template or its Child items.
- Never create a second set of items to correct the first one.
- Never guess the template ID, sprint, Area Path, or Assigned To.
- If the user asks for a preview or dry run, perform read operations
  only and show what would be created.

---

## Workflow

### 1. Pick the buttons

#### Manual

If the user's request or the argument names a button by number or
label, match it loosely against the Buttons table in
`references/templates.md` and use it. When one label contains
another, the longer label wins. In the sample table, `דיווח תחילת`
is button 3, and `דיווח קצר` or `רק קצר` is button 4.

Otherwise ask with `AskUserQuestion`, one question, single select,
header `אייטמים חוזרים`, question `איזה אייטמים לפתוח?`, and the
options from the Buttons table in `references/templates.md`, in that
order, with the frequency as each option's description.

If the user picks more than one button in one request, run steps 2–7
for each button in table order.

#### Auto

For each row of the Auto schedule table in `references/templates.md`,
in table order:

1. If today's day of the month is lower than "Create from day", the
   button is not due. Skip it.
2. Otherwise check whether it was already created this month with
   `wit_query` `wiql`. Use the Project value from
   `references/templates.md` (sample: `Operations`):

```sql
SELECT [System.Id], [System.Title]
FROM WorkItems
WHERE [System.TeamProject] = '<Project>'
  AND [System.WorkItemType] = 'Top Level Task'
  AND [System.Title] CONTAINS '<already-created check text>'
  AND [System.CreatedDate] >= @StartOfMonth
  AND [System.State] <> 'Removed'
```

   Replace `<current month name>` in the check text with today's Hebrew
   month name. A match means it is already done, whether it was created
   manually or automatically. Skip the button.
3. If there is no match, the button is due. Run steps 2–6 for it.

If no button is due, reply with one line saying nothing was due, send
no notification, and stop.

### 2. Read the template

1. Get the template Top Level Task with Azure DevOps MCP `wit_work_item`
   `get`, project from `references/templates.md`, `expand: Relations`.
2. Collect the Child IDs from relations with
   `rel: System.LinkTypes.Hierarchy-Forward`, in relation order.
3. Get the Child items with `get_batch`, same project, fields
   `System.Title`, `System.WorkItemType`, `System.Description`,
   `Microsoft.VSTS.Scheduling.OriginalEstimate`.

If the button has a Child filter in `references/templates.md`, keep
only the Child items that pass it and ignore the rest.

If no Child items are left, create only the Top Level Task.

### 3. Build the new text

For the Top Level Task and each Child item, copy:

- `System.Title`
- `System.Description` (only when not empty)
- `Microsoft.VSTS.Scheduling.OriginalEstimate` (only when set)

Then apply that button's text replacements from
`references/templates.md`. Use today's date for "today" and
"current month".

### 4. Resolve the current sprint

Do not trust the team's `timeframe: current` result alone. It can still
point to a sprint that already ended, and new sprints are not always
assigned to the team yet.

Use the Project and Team values from `references/templates.md`
(samples: `Operations`, `Operations Team`).

1. Call Azure DevOps MCP `work` with `action: list_team_iterations`,
   that project, that team, and no `timeframe`.
   Pick the iteration whose `startDate` ≤ today ≤ `finishDate`
   (compare dates only, inclusive). Use its `path` exactly
   (for example `Operations\2026\Sprint 23`).
2. If none matches, call `work` with `action: list_iterations`,
   that project, `depth: 3`. The result is large and may be
   saved to a file; search it for `startDate` / `finishDate` around
   today. Pick the iteration that contains today.
   If today falls between two sprints (for example a weekend), pick
   the next upcoming sprint: the earliest `startDate` after today.
   Its `path` looks like `\Operations\Iteration\2026\Sprint 23`.
   Remove the leading `\` and the `\Iteration` segment:
   `Operations\2026\Sprint 23`.
   In the reply, warn that this sprint is not assigned to the
   configured team, so the items will not show on the team's sprint
   board until it is added in Team Settings.
3. If no sprint contains today and no later sprint exists, manual mode
   asks the user which sprint to use. Auto mode creates nothing and
   reports it as a failure.

Resolve the sprint once per run and reuse it for every button.

### 5. Check for duplicates (manual only)

Auto mode already checked in step 1. Skip this step in auto mode.

Run `wit_query` `wiql` on the configured project:

```sql
SELECT [System.Id], [System.Title], [System.State]
FROM WorkItems
WHERE [System.TeamProject] = '<Project>'
  AND [System.WorkItemType] = 'Top Level Task'
  AND [System.Title] = '<new title>'
  AND [System.IterationPath] = '<sprint path>'
  AND [System.State] <> 'Removed'
```

Escape a single quote in the title by doubling it.

If any item matches, show its ID and State and ask:
`כבר קיים אייטם עם אותה כותרת בספרינט הזה. ליצור בכל זאת?`
with buttons `צור בכל זאת` and `בטל`. Create only on `צור בכל זאת`.

### 6. Create the items

1. Create the Top Level Task with `wit_work_item_write` `create`,
   the configured project, `workItemType: Top Level Task`, with:
   - the fields from step 3 (Description with `format: Html`)
   - `System.AreaPath`, `System.AssignedTo` from `references/templates.md`
   - `System.IterationPath` from step 4
   - in auto mode, `System.Tags` from `references/templates.md`
2. Create each Child item the same way, with the template Child's
   `System.WorkItemType` and the same Area Path, Assigned To, Iteration
   Path, and (in auto mode) Tags.
3. Link every new Child to the new Top Level Task in one call to
   `wit_work_item_link_write` `link`, same project:

```
updates:
  - id: <new Top Level Task ID>
    linkToId: <new Child ID>
    type: child
```

If a Child create or the link fails, keep what was created. Do not
retry by creating new items. Report the failure and the IDs that exist.

### 7. Reply

Reply in Hebrew with:

- the button that ran (or, in auto mode, each button that ran)
- the sprint path
- a table: ID (as a link to
  `https://dev.azure.com/<your-org>/<Project>/_workitems/edit/<id>`),
  type, title, Original Estimate
- any text replacement that was applied (old → new)
- any failure, and in auto mode any button skipped as already created

`<your-org>` is the organization slug from `references/templates.md`.
`<Project>` is the Project value from that file.

In auto mode, after the reply, if anything was created or anything
failed, send one notification with `PushNotification`
(`status: proactive`), one line in Hebrew, under 200 characters.
Lead with the button and the main ID, for example:

`נוצרו אייטמי דיווח תחילת חודש: 10041 (ראשי), 10042, 10043`

On failure, lead with what failed, for example:

`אייטמים חוזרים נכשלו: עדכון אמצע חודש – לא נמצא ספרינט`

Send no notification when nothing was due.

Then stop.
