---
name: validate-work-item-content
description: >-
  Validates Azure DevOps work items of any type for required Description,
  and for Acceptance Criteria when the item was created by a person listed
  in references/azure.md. Posts a Discussion comment when required data is
  missing, and returns a Hebrew report of valid items with full field
  text versus missing content. Accepts one or many work item IDs.
  Skips the project named in that config (sample: Support). Use when the user
  says validate work item, validate content, check description,
  check acceptance criteria, בדוק תוכן, בדוק אייטם, בדוק אייטמים,
  חסר description, or חסר acceptance criteria.
argument-hint: <work item ID or several work item IDs>
---

# /validate-work-item-content

Validate existing Azure DevOps work items for required content.

Use this skill for the workflow and business rules.

This is one skill for every allowed Azure project.
Do not look for a per-project copy of this `SKILL.md`.
Project, field, and mention details live only in
[references/azure.md](references/azure.md).

Use the connected Azure DevOps MCP server for all Azure DevOps reads
and comments.

Do not use Azure CLI, PowerShell, Bash, REST calls, or local scripts.

---

## Prerequisites

- Azure DevOps MCP is connected and authenticated.
- Organization: the URL in [references/azure.md](references/azure.md)
- Azure configuration: [references/azure.md](references/azure.md)

---

## Execution Rules

- Read this skill and `references/azure.md`.
- Do not search unrelated workspace files, previous chats, or old scripts.
- Use Azure DevOps MCP for all Azure DevOps operations.
- Accept every work item type.
- Accept one work item ID or several IDs in the same request.
- Never guess work item IDs.
- Never create, update, or delete work item fields.
- Never change State, Title, Description, or Acceptance Criteria.
- The only allowed write is adding a Discussion comment on an item
  whose required data is missing.
- Always post that comment when required data is missing, even if
  the same comment already exists.
- Do not comment on items in the skip-project from `references/azure.md`.
- Do not comment on items that already have the required content.
- If the user requests a dry run / preview, perform reads only.
  Do not add comments.

---

## Input

Required:

- At least one work item ID

The user may give one ID or several IDs.

If no work item ID is provided, ask:

`מה מספר האייטם או מספרי האייטמים?`

Do not continue until at least one ID is known.

---

## Workflow

### 1. Parse the work item IDs

Collect every whole-number work item ID from the request.

Keep the user's order.
Remove duplicate IDs.
Do not invent IDs.

---

### 2. Load Azure configuration

Read:

[references/azure.md](references/azure.md)

Use the configured values exactly for:

- Organization
- Support skip rule
- Description field
- Acceptance Criteria field
- Acceptance Criteria required creators
- mention identities
- creator mention rule
- comment HTML

---

### 3. Read the work items

Use Azure DevOps MCP.

- One ID: `wit_work_item` action `get`
- Several IDs: `wit_work_item` action `get_batch`

Read at least:

- ID
- Title
- Work Item Type
- Team Project (`System.TeamProject`)
- Created By (`System.CreatedBy`)
- Description (`System.Description`)
- Acceptance Criteria (`Microsoft.VSTS.Common.AcceptanceCriteria`)
- URL when available

Keep Title, Description, Acceptance Criteria, and Created By text
for the final report, including empty values.

If an ID is not found:

- record it as not found
- do not comment
- continue with the remaining IDs

---

### 4. Skip the configured support project

If `System.TeamProject` is the skip-project from `references/azure.md`
(sample: `Support`):

- do not validate content
- do not add a comment
- record skip reason `support-project`
- continue with the remaining IDs

Every other project is allowed.

---

### 5. Decide which fields are required

Description is always required.

Check `System.CreatedBy` first.

Match the creator against the Acceptance Criteria required creators
in `references/azure.md` by `displayName` (case-insensitive) or by
identity `id`.

If `System.CreatedBy` is absent or unreadable:

- do not comment
- record the item as failed
- continue with the remaining IDs

If the creator is not in the Acceptance Criteria required creators list:

- do not require Acceptance Criteria
- do not treat empty Acceptance Criteria as missing data
- do not call `get_type` for this item
- still require Description

If the creator is in the Acceptance Criteria required creators list:

Acceptance Criteria is required only if that field exists on the
work item type.

For each unique pair of Team Project + Work Item Type among these
items in this request, use Azure DevOps MCP `wit_work_item`
action `get_type`.

The type has Acceptance Criteria only when type metadata includes:

- `Microsoft.VSTS.Common.AcceptanceCriteria`

or a field whose display name is `Acceptance Criteria`.

If the type does not have that field:

- do not require Acceptance Criteria
- do not treat the missing field as missing data
- still require Description

Cache the type result. Do not call `get_type` again for the same
project and type in this request.

If `get_type` fails:

- do not comment
- record the item as failed
- continue with the remaining IDs

---

### 6. Decide whether content is missing

A field is missing when it is absent, null, empty, whitespace-only,
or HTML with no visible text.

Treat HTML as empty after stripping tags, decoding entities such as
`&nbsp;`, and trimming whitespace.

Images without visible text still count as empty.

Do not treat placeholder guesses such as `TBD` as empty.
Only empty / no visible text is missing.

For each remaining work item:

- Description missing → required data is missing
- Creator requires Acceptance Criteria, the type has that field,
  and that field is missing → required data is missing
- Creator does not require Acceptance Criteria and Description has
  visible text → required data is present
- Type has no Acceptance Criteria field and Description has
  visible text → required data is present

---

### 7. Dry Run behavior

If the user says anything equivalent to:

- dry run
- preview
- show me first
- don't comment
- רק תראה לי
- אל תכתוב עדיין

perform all reads and validation.

Do not call any MCP tool that writes to Azure DevOps.

Return the Hebrew report from step 10, including full field
text. For items that would receive a comment, set Discussion to
`Dry Run — לא נכתב`.

Then stop.

---

### 8. Add Discussion comments

For every work item whose required data is missing:

Add one Discussion comment with Azure DevOps MCP
`wit_work_item_comment_write`:

- `action`: `add`
- `project`: the item's `System.TeamProject`
- `workItemId`: the item ID
- `format`: `Html`
- `text`: the mention HTML plus only the matching missing-field
  lines from `references/azure.md`

Choose the mention prefix from `System.CreatedBy`:

- Creator is in the Acceptance Criteria required creators list → use the
  default mentions from `references/azure.md`
- Creator is anyone else and Description is missing → mention only
  that creator, using `System.CreatedBy` `id` and `displayName`.
  Do not use the default mention list in this comment.
  If `CreatedBy.id` is missing, look up the identity with
  `core_get_identity_ids`. If the identity cannot be resolved,
  do not comment, record the item as failed, and continue.

Build the comment from the missing required fields:

- Description missing → add `Description is missing`
- Required Acceptance Criteria missing → add `Acceptance Criteria is missing`
- Both required fields missing → add both lines, Description first

Do not add `Acceptance Criteria is missing` when Acceptance Criteria
is not required for this creator or this type.

Do not add any other sentence.
Do not change the names.
Do not skip posting because a similar comment already exists.

If a comment add fails:

- record the item as failed
- record the Azure DevOps MCP error
- continue with the remaining items

Do not retry blindly if it is uncertain whether Azure already
added the comment.

---

### 9. Handle items that are valid

If required data is present:

- do not add a comment
- record the item as valid
- keep Title, Description, Acceptance Criteria, and Created By text
  for the final report

---

### 10. Reply with a report

Always return a Hebrew report. This report is required,
including Dry Run.

Use the structure, headings, and rules in
[references/report-template.md](references/report-template.md).

Then stop.

Do not perform additional writes after the report unless the user
explicitly asks.

---

## Safety Rules

- Never update work item fields.
- Never create work items.
- Never delete work items.
- Never comment on skip-project work items.
- Never comment on an item that has the required content.
- Always post a new comment when required data is missing.
- One missing item receives at most one new comment per request.
- Do not expose credentials, PATs, tokens, or MCP authentication data.
- Do not perform write operations during Dry Run.

---

## Examples

See [references/examples.md](references/examples.md).
