---
name: close-items
description: >-
  Closes configured support work items linked to Bugs and User Stories
  in the source projects listed in references/azure.md for a given
  Version or a given work item ID using Azure DevOps MCP. Use when the
  user says close items, close support, סגור אייטמים, סגירת תלונות,
  gives a release version such as 1.31.0 after a sprint, or gives a
  work item ID whose related support items should be closed.
argument-hint: <version like 1.31.0 | work item ID>
---

# /close-items — Close linked Support items by version or work item ID

Close eligible support work items of the types and title markers in
`references/azure.md` that are related to Bugs / User Stories in the
source product projects.

Two input modes:

1. **Version** — close Support items linked to source-project Bugs / User
   Stories that have the requested Version. Search all configured source
   projects in one run. Do not ask which project.
2. **Work item ID** — close Support items linked to that one work item.
   Do not require `Custom.Version` on the source item.

Use this skill for the workflow and business rules.

This is one skill for the source-projects → Support close flow.
Do not look for a per-project copy of this `SKILL.md`.
Source project names, Support names, types, and close states live only in
[references/azure.md](references/azure.md).

Use the connected Azure DevOps MCP server for all Azure DevOps reads
and updates.

Do not use Azure CLI, PowerShell, Bash, REST calls, or local scripts.

---

## Prerequisites

- Azure DevOps MCP is connected and authenticated.
- Organization: the URL in [references/azure.md](references/azure.md)
- Field, type, link, and state configuration:
  [references/azure.md](references/azure.md)

---

## Execution Rules

- Read this skill and `references/azure.md`.
- Do not search unrelated workspace files, previous chats, or old scripts.
- Use Azure DevOps MCP for all Azure DevOps operations.
- Do not use:
  - Azure CLI
  - `az boards`
  - `az devops invoke`
  - PowerShell
  - Bash
  - direct REST API calls
- Never update source-project Bugs or User Stories.
- Never create work items.
- Never delete work items.
- Only update eligible work items in the `Support` project.
- Close only the types and title markers in `references/azure.md`.
- Never treat a title marker as a Work Item Type.
- Version mode: never close a Support item if it is linked to any
  source-project Bug or User Story whose Version is missing or different
  from the requested Version.
- Item ID mode: never close a Support item if it is linked to any
  source-project Bug or User Story other than the given source item.
- Never guess field names, work item types, states, links, or Version values.
- Update each eligible Support item at most once per request.
- If the user requests a dry run / preview, perform read operations only.

---

## Workflow

### 1. Parse the input

Take the input from the user's request. Decide the mode:

#### Version mode

Numeric dotted format.

Examples:

- `1.31.0`
- `2.4.1`
- `10.2`

Record the requested Version. Do not continue as item ID mode.
Do not ask which project. Search all configured source projects.

#### Item ID mode

A whole number work item ID.

Examples:

- `12345`
- `88721`

Record the source Work Item ID. Do not require a Version.

#### Missing or unrecognized input

If no Version and no Work Item ID is provided, or the input cannot be
classified as one of the two modes, ask:

`מה מספר הגרסה או מספר האייטם?`

Do not continue until either a Version or a Work Item ID is known.

---

### 2. Load Azure configuration

Read:

[references/azure.md](references/azure.md)

Use the configured values exactly for:

- Organization
- source projects
- source work item types
- Version field reference name
- Support project
- support close types
- support title-marker rule
- Related link type
- target close states
- states that count as already closed

Do not replace configured names with guessed values.

---

### 3. Resolve source work items

Do not modify these work items.

Source projects: every name listed under Source projects in
`references/azure.md`.

#### Version mode

Using Azure DevOps MCP, find work items in **every** source project where:

- Project is one of the configured source projects
- Work Item Type = `Bug` OR `User Story`
- `Custom.Version` = requested Version

Collect unique matching Work Item IDs across all source projects.

Record:

`sourceMatched`

as the total number of unique matching source Bugs / User Stories.

Also record a per-project count for every configured source
project, including `0`.

If no matching source items are found in any project:

- do not update anything
- tell the user no Bugs / User Stories were found for that Version
  in any source project
- include the per-project counts (all `0`)
- stop

#### Item ID mode

Using Azure DevOps MCP, read the work item by the given ID.

If the work item is not found:

- do not update anything
- tell the user the work item was not found
- stop

Do not require `Custom.Version` on the source item.

The source item is expected to be a source-project `Bug` or `User Story`.
If the type or project is different, still continue and look for related
Support items. If none are found later, report that and stop.

Never update the source work item.

Record:

- `sourceId`
- title
- type
- project
- URL

Treat this single ID as the only source work item for the rest of the
workflow. Set:

`sourceMatched = 1`

---

### 4. Find related Support items

For every source work item from step 3, inspect its related work items
through Azure DevOps MCP.

Use the configured link type:

`System.LinkTypes.Related`

Collect unique related items from the `Support` project.

A Support item is a candidate only if it matches a close type or
title marker from `references/azure.md` (sample: type
`Customer Complaint`, or title contains `[Feedback]`).

Title-marker items may have types such as:

- `BugReported`
- `Feedback`
- `FeatureRequest`

Do not assume every item of those types is eligible.
The title must contain the configured marker.

Do not update anything yet.

Record:

`supportFound`

as the number of unique Support candidates.

---

### 5. Validate all source-project links for every Support candidate

This validation is mandatory.

For each Support candidate:

1. Inspect all of its related work items.
2. Keep the related items that belong to a configured source project
   from `references/azure.md`.
3. From those, consider only:
   - `Bug`
   - `User Story`

Never close the Support item when this validation fails.

#### Version mode

Read `Custom.Version` from every relevant source-project item.

A Support item is eligible only if every relevant linked source Bug /
User Story has exactly the Version requested by the user.

Skip the Support item if any relevant source-project work item:

- has a different Version
- has no Version
- cannot be safely verified

Use skip reason:

`other-source-version`

For this skip reason, record the IDs of the related source items
that caused the item to be skipped.

#### Item ID mode

A Support item is eligible only if its only relevant source-project Bug /
User Story related link is the given source Work Item ID.

Skip the Support item if it is also linked to any other source-project Bug
or User Story.

Use skip reason:

`other-source-links`

For this skip reason, record the IDs of the other related source items
that caused the item to be skipped.

Do not use Version matching in this mode. Missing Version on the source
item is not a reason to skip.

---

### 6. Check current Support State

For every otherwise eligible Support candidate, read its current State.

Skip the item when its State is already:

- `Closed`
- `Completed`
- `Rejected`

Use skip reason:

`already-closed`

Do not send an update for an already completed item.

---

### 7. Determine the target State

Use the exact rules from `references/azure.md`.

#### Customer Complaint

Target State:

`Closed`

#### Title-marker items

For items whose title contains the configured marker (sample: `[Feedback]`):

- `BugReported` → `Completed`
- `Feedback` → `Completed`
- `FeatureRequest` → `Completed`

Do not invent a different target State.

Do not modify unrelated fields.

---

### 8. Dry Run behavior

If the user says anything equivalent to:

- dry run
- preview
- show me first
- don't close yet
- do not update anything
- רק תראה לי
- אל תסגור עדיין

perform all discovery and validation steps using read operations only.

Do not call any MCP tool that modifies Azure DevOps.

Return:

- mode: Version or Work Item ID
- requested Version, or source Work Item ID with title, type, project, and URL
- Version mode: `sourceMatched` and the per-project counts
  for every configured source project, including `0`
- number of Support candidates
- items that would be closed/completed
- target State for each
- items skipped because already closed
- Version mode: items skipped because of another/missing source Version
- Item ID mode: items skipped because of other source-project Bug / User Story links
- IDs and URLs
- related source IDs for `other-source-version` or `other-source-links` skips

Then stop.

---

### 9. Update eligible Support items using Azure DevOps MCP

When the user requested actual closure:

Use the appropriate Azure DevOps MCP work item update tool.

For every validated eligible Support item:

- update only that Support item
- change only the State required by this workflow
- do not update its linked source-project work items
- do not create another work item
- do not change unrelated fields

Apply:

- `Customer Complaint` → `Closed`
- `[Feedback]` `BugReported` → `Completed`
- `[Feedback]` `Feedback` → `Completed`
- `[Feedback]` `FeatureRequest` → `Completed`

After each successful update, record:

- Work Item ID
- Work Item Type
- previous State
- new State
- URL

Increment:

`supportClosed`

---

### 10. Handle update failures safely

If an individual Support update fails:

- record the item as failed
- record its Work Item ID
- record the Azure DevOps MCP error
- continue only with other items that have already been independently
  validated as safe to update

Do not:

- change the work item type
- modify unrelated fields
- create another work item
- update a source-project item
- close extra Support types to compensate for the failure

Do not blindly retry an update if it is uncertain whether Azure already
applied the first request.

If update status is uncertain, mark the item for manual verification.

Record:

`supportFailed`

---

### 11. Build the final summary

Summarize in Hebrew, using the structure in
[references/report-template.md](references/report-template.md).

Then stop.

Do not perform additional update or verification calls after the summary
unless the user explicitly asks.

---

## Empty Result Behavior

Use the empty-result messages in
[references/report-template.md](references/report-template.md).

---

## Safety Rules

- Never update source-project Bugs or User Stories.
- Never create work items.
- Never delete work items.
- Never update unrelated Support items.
- Never close an item only because one linked source item matches.
- Always inspect all relevant linked source-project Bugs / User Stories first.
- Version mode: missing Version is not a match.
- Version mode: different Version is not a match.
- Version mode: search all configured source projects. Do not ask which project.
- Item ID mode: do not require Version on the source item.
- Item ID mode: a Support item linked to any source-project Bug / User Story
  other than the source item is not eligible.
- One Support item may be updated at most once per request.
- Do not expose credentials, PATs, tokens, or MCP authentication data.
- Do not perform write operations during Dry Run.

---

## Examples

See [references/examples.md](references/examples.md).
