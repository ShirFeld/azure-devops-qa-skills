---
name: add-item
description: >-
  Creates a new Azure DevOps work item (Bug, User Story, or Top Level Task)
  from natural language using the connected Azure DevOps MCP server.
  Supports the Azure projects listed in references/projects.md.
  Optionally links the created item to existing work items using Related.
  Use when the user says add bug, new bug, report bug, log bug,
  צור באג, פתח באג, תפתח באג, יצירת באג,
  add item, תפתח אייטם, פתח אייטם, צור אייטם,
  user story, US, סטורי, תפתח סטורי, תפתח user story,
  top level task, TLT, משימה עליונה, טופ לבל, תפתח טאסק,
  including when they attach screenshots or pasted images,
  and when they ask to שייך, תשייך, קשר, or Related the item
  to a work item ID.
argument-hint: <type + project name + title and description; optional assignee, current sprint, related work item ID>
---

# /add-item — Create Azure DevOps work item

Create exactly one work item in Azure DevOps from the user's request.

Supported types:

- Bug
- User Story
- Top Level Task

Use this skill for the business rules and item structure.

This is one skill for every supported Azure project.
Do not look for a per-project copy of this `SKILL.md`.
Project differences (Area Path, Iteration Path, Team, Assigned To,
Priority, Severity, Language) and Allowed assignees live only in
[references/projects.md](references/projects.md).
Type-specific writing rules live only in
[references/item-types.md](references/item-types.md).
Bug login URLs and mandatory first Repro steps live only in
[references/login.md](references/login.md).

Use the connected Azure DevOps MCP server for reading Azure DevOps data
and creating the work item.

Do not use Azure CLI, PowerShell, Bash, REST calls, or local scripts
to create the work item.

---

## Prerequisites

- Azure DevOps MCP is connected and authenticated.
- Organization: the URL in [references/projects.md](references/projects.md)
- Project configuration: [references/projects.md](references/projects.md)
- Type writing rules: [references/item-types.md](references/item-types.md)
- Bug login steps: [references/login.md](references/login.md)

---

## Execution Rules

- Read this skill, the Allowed assignees section, and only the matching
  project section from `references/projects.md`.
- After the type is known, read only that type's section from
  `references/item-types.md`.
- When the type is Bug and the template is not skipped, also read
  `references/login.md`.
- Do not search unrelated workspace files, previous chats, or old scripts.
- Use Azure DevOps MCP for Azure DevOps operations.
- Do not use `az`, Azure CLI, PowerShell, Bash, or REST API calls
  to create the work item.
- REST and the helper scripts are allowed **only** via
  `scripts/extract-chat-images.ps1` and `scripts/attach-images.ps1`,
  and **only** to attach images from this request after the work item
  already exists.
- Never guess:
  - Work item type
  - Project
  - Area Path
  - Iteration Path (project backlog, or the current sprint from Azure
    only when the user asked)
  - Assigned To (project default, or a person from Allowed assignees
    only when the user named them)
  - Priority
  - Severity
  - Related work item IDs
- Create exactly **one work item** per user request.
- Never create a second work item to correct the first one.
- Do not modify an existing work item unless the user explicitly asks,
  except:
  - one update after create to attach images from this request
  - creating a Related link to a work item ID the user explicitly provided
- Do not create, update, or delete any other Azure DevOps work item.
  A Related link to a user-provided work item ID is allowed.
  Do not change fields on that existing work item.
- After successful creation, return the type, title, ID, URL,
  Assigned To, and Iteration Path.
  If Related links were requested, include the linked work item IDs
  or report link failures. Then stop.
- Do not perform an additional read/update after successful creation
  unless required to obtain the created item's ID or URL, to attach
  images from this request, or to create the requested Related links.
- If the user explicitly asks for a preview, dry run, or asks what would
  be created, do not create anything in Azure DevOps.

---

## Workflow

### 1. Identify the work item type

Choose the type **only** from explicit wording. Do not infer the type
from the content of the request.

| User said | Azure `workItemType` |
| --- | --- |
| באג, bug, תפתח באג, צור באג, פתח באג, report bug | `Bug` |
| user story, US, סטורי, תפתח סטורי, תפתח user story | `User Story` |
| top level task, TLT, משימה עליונה, טופ לבל, תפתח טאסק | `Top Level Task` |

If the type is not explicit, ask:

`באג, User Story, או Top Level Task?`

Do not create anything until the type is known.

---

### 2. Identify the project

Supported projects are the project sections in
[references/projects.md](references/projects.md).
Do not hardcode a project list in this file.

If the project is not clear from the request, ask:

`באיזה פרויקט לפתוח את האייטם?`

Do not create the work item until the project is known.

Do not infer a project only from the description unless the mapping
is explicitly defined in `references/projects.md`.

---

### 3. Load project configuration

Read the Allowed assignees section and only the matching project
section from:

[references/projects.md](references/projects.md)

Use the values from that section exactly:

- Project
- Team
- Area Path
- Iteration Path
- Assigned To
- Default Priority
- Default Severity
- Language

Area Path is always the project's configured Product path.
Do not modify or normalize it.

Assigned To is the project's default unless step 4
overrides it from Allowed assignees.

Iteration Path is the project's backlog path unless step 4
overrides it with the current sprint.

---

### 4. Resolve Assigned To and Iteration Path

These two overrides are independent. Apply only what the user
explicitly asked for. If they asked for neither, keep the project
defaults from step 3.

#### Assigned To

Keep the project's default Assigned To unless the user explicitly
named a person, or used an alias from Allowed assignees that maps
to themselves (sample: עלי / עליי / me).

Treat phrases such as these as an assignee request:

- שים על
- תשימי על
- assign
- Assigned To
- עלי
- עליי

Do not treat Related-link wording (`תשייך` / `שייך` / `קשר` plus a
work item ID) as an assignee change.

Match the named person case-insensitively against Display name,
first name, and Aliases in Allowed assignees.

If there is a single match, use that person's Email exactly as
Assigned To. Do not look up identities at runtime.

If there is no match, or the name is ambiguous, ask who to assign
to. Do not create the work item yet.

If the user did not name anyone, keep the project's default Assigned To.

#### Iteration Path

Keep the project's configured backlog Iteration Path unless the
user explicitly asked to put the item on the current sprint.

Treat phrases such as these as a current-sprint request:

- ספרינט נוכחי
- בספרינט הנוכחי
- current sprint
- על הספרינט

Then:

1. Call Azure DevOps MCP `work` with:
   - `action`: `list_team_iterations`
   - `project`: the selected project
   - `team`: the project's Team from `references/projects.md`
   - `timeframe`: `current`
2. Confirm today's date is between `startDate` and `finishDate`
   (inclusive).
3. Use the returned `path` as `System.IterationPath`.
   Do not modify or normalize that path.

If no current iteration matches today's dates, stop and ask.
Do not guess a sprint name. Do not create the work item yet.

If the user did not ask for the current sprint, keep the project
backlog Iteration Path.

---

### 5. Parse the user's request

Build the work item only from information supplied by the user and from
the selected project's configuration.

Read the matching type section in
[references/item-types.md](references/item-types.md)
and follow it.

When the type is Bug and the template is not skipped, also read
[references/login.md](references/login.md).
Start שחזור with the mandatory Navigate and Login steps from that
file. Then continue with the user's steps.

The user often writes in simple, informal Hebrew.
Do not copy that wording into the work item unless they asked to skip
the template and write the text as given.

Rewrite Title and body fields into professional QA Hebrew:

- Complete sentences.
- Imperative verbs in steps (`התחבר`, `נווט`, `הזן`, `לחץ`).
- Consistent terms: `משתמש` not `יוזר`; `אינו מתבצע` / `לא מוצגת תוצאה` not `לא קורה`.

Do not invent facts the user did not state or directly imply:

- screens
- URLs, except the saved login URLs in `references/login.md`
- browsers
- operating systems
- users
- versions
- devices
- environments
- test data
- additional actions, except the mandatory login steps in
  `references/login.md`

Professional rephrasing of what the user said is required.
Adding new product behavior, screens, or data is not allowed,
except the mandatory Bug login steps from `login.md`.

If the user explicitly asks not to use the template
(`לא צריך טמפלייט`, `פשוט תכתוב`), follow the skip-template rule
in that type's section of `item-types.md`.

#### Title

- Professional QA summary, maximum 80 characters.
- If project language is Hebrew, write the title in Hebrew.
- Do not paste the user's free-form sentence.
- Do not add technical details the user did not provide.
- Use the title format from the selected type section in
  `item-types.md`.

#### System Info

Include System Info only if the user explicitly supplied environment
information such as:

- browser
- operating system
- device
- app version
- environment
- URL
- build/version

If none was supplied, omit System Info.
Do not copy a saved login URL from `login.md` into System Info.
That URL belongs only in Bug שחזור.

#### Related work items (optional)

Linking is optional.

Do not create a Related link unless the user asked to associate
the new work item with an existing work item, or explicitly gave a work
item ID for linking.

Treat phrases such as these as a link request when they refer
to a work item ID:

- תשייך
- שייך
- קשר
- Related
- link

Do not treat those phrases as an Assigned To change. A person
from Allowed assignees is Assigned To. A work item ID is Related.

If the user asked to link but did not give a work item ID, ask:

`מה מספר האייטם לשייך?`

Do not create the work item until the ID is known.

The user may give one work item ID or several. Link each one
as Related.

Do not invent work item IDs.

---

### 6. Determine Priority

Apply Priority only when the selected type has that field
(`Bug` and `User Story`). Do not set Priority on `Top Level Task`.

Use the project's Default Priority from `references/projects.md`
unless the user explicitly indicates a higher priority.

Use Priority `1` when the user explicitly says:

- P1
- critical
- blocker
- urgent
- קריטי
- דחוף

Otherwise use the project's configured default.

Do not infer Priority `1` merely because the item sounds inconvenient.

---

### 7. Determine Severity

Apply Severity **only** for `Bug`.

Do not set Severity on `User Story` or `Top Level Task`.

Use the project's Default Severity unless the user's description clearly
indicates another severity.

Mappings:

- critical / blocker / קריטי
  → `1 - Critical`

- high / חמור
  → `2 - High`

- minor / low / קל
  → `4 - Low`

Otherwise use the project's Default Severity.

Do not invent a severity outside these rules.

---

### 8. Preserve project language

If the project's configured language is Hebrew:

Keep Title and body fields in Hebrew.

Do not translate them into English unless the user explicitly asks.

Azure field names and technical values may remain in their required
Azure DevOps format.

---

### 9. Build HTML fields

If the project language is Hebrew, wrap HTML body fields in
`<div dir="rtl">` so they display right-to-left in Azure DevOps.

Store text in the fields named in the selected type section of
`item-types.md`.

Pass Azure `workItemType` exactly:

- `Bug`
- `User Story`
- `Top Level Task`

Do not put images in HTML at create time. Images are added later
by `scripts/attach-images.ps1`.

---

### 10. Attach images if the user sent any

Use only images the user attached in **this** request: screenshots
pasted or dragged into the chat, or image file paths the user wrote
in the request.

Images pasted into the Claude Code chat are not files on disk.
Before attaching, turn them into files:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .claude/skills/add-item/scripts/extract-chat-images.ps1
```

- Run it from the project root, after the work item was created.
- It reads the latest user message in the current session transcript
  and prints one `IMAGE_PATH=<path>` line per pasted image, in order.
- `NO_IMAGES` means nothing was pasted in this request: skip this step,
  unless the user wrote image file paths in the request.
- If the user wrote image file paths, use those paths. If they also
  pasted images, attach the pasted images first, then the paths.
- If the script fails, or prints `NO_IMAGES` although you can see
  images in this request, say that image attach failed and ask the
  user to save the screenshots to files and send the paths.
  Do not create the work item again.

- Do not search the repo for images.
- Do not ask if none were sent.
- Zero images: skip this step.
- One or more: keep the user's order and attach all of them.
- Do not put screenshot analysis into Title or body fields.
  The images are the evidence.
- Place images **after all text**.

Create-then-attach order:

1. Create the work item with MCP (full text, no images).
2. If there are images, get their paths (see above), then run:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .claude/skills/add-item/scripts/attach-images.ps1 -Project "<project>" -WorkItemId <id> -ImagePaths "<path1>","<path2>"
```

The script authenticates with the `AZURE_DEVOPS_EXT_PAT` environment
variable (a PAT with Work Items Read & Write). Never ask the user to
paste a token into the chat, and never print it. If the script reports
missing credentials, tell the user to set `AZURE_DEVOPS_EXT_PAT` as a
Windows user environment variable and restart Claude.

The script writes images into ReproSteps for a Bug, and into
Description for a User Story or Top Level Task.

3. If image attach failed, say that explicitly. Continue to the
   Related-link step if one was requested. Otherwise return the
   type, title, ID, URL, Assigned To, and Iteration Path, then stop.

If the script exits with code `2`, it uploaded the files but could not
update the work item. Read the `ATTACHMENT_URL=` lines from stdout and
update the HTML field through Azure DevOps MCP: keep the existing HTML
and append `<img src="URL" />` tags after all text.

- Bug: `Microsoft.VSTS.TCM.ReproSteps`
- User Story / Top Level Task: `System.Description`

Do not create a second work item if attach fails. Keep the item that
was created.

---

### 11. Link Related work items if requested

If the user did not ask to link and did not give a work item ID
for linking, skip this step.

After the work item exists (and after image attach if any):

1. Read each target work item through Azure DevOps MCP to confirm
   it exists.
2. If a target does not exist, keep the work item that was created.
   Do not create a second work item. Report that the link failed.
3. For each existing target, create a Related link with
   `wit_work_item_link_write`:

```
action: link
project: <same project as the new work item>
updates:
  - id: <new work item ID>
    linkToId: <user-provided ID>
    type: related
```

If linking fails:

- Do not delete or recreate the work item.
- Do not change fields on the target work item.
- Report the failed work item IDs.

---

### 12. Reply

Return:

- work item type
- title
- ID
- URL
- Assigned To
- Iteration Path
- linked work item IDs, if any Related links were created
- any image-attach or link failures

Then stop.
