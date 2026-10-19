---
name: update-test-cases
description: >-
  Updates existing Azure DevOps Test Cases when a User Story has changed
  since they were created or last synced. Supports the Azure projects
  listed in create-test-cases/references/projects.md. Compares the current Title,
  Description, Acceptance Criteria, and Iteration to the User Story as of
  the related Test Cases' last change. Adds, updates, or sets obsolete
  Test Cases to Removed. Does not run validate-work-item-content.
  Does not create Test Cases from scratch when none exist.
  Use when the user asks to update test cases, refresh test cases,
  sync test cases, check if a User Story changed before testing,
  עדכון תרחישים, סנכרן תרחישים, בדוק שינוי ב-US, or לפני בדיקות
  for User Stories that already have Test Cases.
argument-hint: <User Story ID or several related User Story IDs>
---

# /update-test-cases

Sync existing Test Cases to the current User Story using Azure DevOps MCP.

This is one skill for every supported Azure project.
Do not look for a per-project copy of this `SKILL.md`.

This skill does not create the first Test Cases for a User Story.
That is `create-test-cases`.

Do not run `validate-work-item-content`.
If related Test Cases exist, that User Story was already validated
when those Test Cases were created.

Supported projects are the project sections in
`.claude/skills/create-test-cases/references/projects.md`.
Do not hardcode a project list in this file.

---

## Never guess

If anything is unclear, stop and ask the user.

Do not invent an answer.
Do not choose a default.
Do not continue writing until the user answers.

This includes unclear Iteration, unclear Project, mixed projects
in the same topic, missing IDs, unclear expected product behavior,
or an unclear match between an existing Test Case and a requirement.

Do not invent Description or Acceptance Criteria.
Do not invent product behavior.

---

## Input

Required:

- At least one User Story ID

The user may give one User Story or several related User Stories
on the same topic.

If User Story ID is missing, ask:
`מה ה-ID של ה-US?`

Do not write anything until the User Story ID is known.

Do not treat User Stories as the same topic unless the user
says they are related and lists the IDs.

---

## Prerequisites

- Azure DevOps MCP is connected and authenticated.
- Organization: the `ADO_ORG` environment variable. Do not hardcode an organization name.
- Project config: `.claude/skills/create-test-cases/references/projects.md`
- Test Case writing rules: `.claude/skills/create-test-cases/references/test-case-rules.md`
- Open questions: `.claude/skills/create-test-cases/references/qa-analysis.md`
- Sync rules: `references/sync-rules.md`

Use Azure DevOps MCP for all Azure DevOps operations.

Do not use Azure CLI, PowerShell, Bash, REST calls, or local scripts.

Do not search unrelated workspace files, previous chats, or old scripts.

---

## Workflow

### 1. Do not validate content

Do not read or follow `validate-work-item-content`.

Do not post a missing-content Discussion comment.

If current Description or Acceptance Criteria are empty after they
were present at the baseline, go to `לא טופלו`.
Do not invent requirements from the Title.
Do not set every related Test Case to `Removed` only because
those fields were cleared.

---

### 2. Read the User Story or Stories

Use Azure DevOps MCP `wit_work_item` with `expand: Relations`.

Read:

- Title
- Description
- Acceptance Criteria
- State
- Area Path
- Iteration Path
- Team Project
- Relations

Read every requested User Story in the user's order.

When several User Stories are on the same topic, read all of them
before generating or updating tests.

---

### 3. Find existing Test Cases

Follow `references/sync-rules.md`.

Keep only Related work items whose type is `Test Case`.

Read each related Test Case:

- Title
- Steps
- State
- Created Date
- Changed Date

`baselineDate` is the latest `System.ChangedDate` among those
related Test Cases, including Test Cases already in `Removed`.

For coverage matching, ignore Test Cases whose State is already
`Removed`. Do not resurrect them.

---

### 4. Decide whether this skill may continue

Follow `references/sync-rules.md` for each User Story.

If the User Story State is `Removed`:

- Do not update Test Cases.
- Do not create Test Cases.
- Do not post open questions.
- Put it under `לא טופלו`.

If there are no related Test Cases:

- Do not create the first Test Cases from scratch.
- If Iteration contains `PRODUCT`: put it under `לא טופלו`
  with reason `Product בלי תרחישים`.
- If Iteration contains `SPRINT` and an existing Suite is found
  for this User Story: treat this as Product → Sprint and create
  the missing Test Cases in that Suite.
- Otherwise put it under `לא טופלו` with reason
  `אין תרחישים קשורים` and tell the user to run `create-test-cases`.

If Iteration contains neither `PRODUCT` nor `SPRINT`:

- Stop and ask the user.
- Do not assume.

If several related User Stories belong to different projects:

- Stop and ask the user.
- Do not assume.

---

### 5. Compare the User Story to the baseline

When related Test Cases exist, read the User Story again with
`wit_work_item` `get` and `asOf: baselineDate`.

Compare only:

- Title
- Description
- Acceptance Criteria
- Iteration Path
- State

Normalize HTML before comparing. Follow `references/sync-rules.md`.

A change to Assigned To, tags, Discussion, or other fields is
not a User Story change for this skill.

If those compared fields are the same:

- Put the User Story under `אין שינוי`.
- Do not write to Azure for that User Story.

If they differ, continue.

PRODUCT → SPRINT is a material change even when Title,
Description, and Acceptance Criteria are unchanged.

---

### 6. Load the project configuration

Read the matching project section from:

`.claude/skills/create-test-cases/references/projects.md`

Determine the project from the User Story Area Path / Team Project.

Create or update Test Cases in that project.

Use the configured Language.

Do not guess Test Plan.

Do not use a configured Parent Suite.

---

### 7. Find the existing Suite

Follow `references/sync-rules.md`.

Look up the Suite by the baseline (`asOf`) User Story Title.

Azure DevOps MCP cannot rename a Suite.

If the User Story Title changed, keep using the existing Suite.
Report that the Suite name is still the old Title.
Do not create a second Suite for the new Title.

If no Suite is found and this skill must add Test Cases:

- Stop and ask the user unless Product → Sprint requires creating
  structure. Then follow the Test Plan and Suite rules in
  `create-test-cases` and `references/projects.md`.

Place new Test Cases only in that User Story's Suite.

---

### 8. Diff requirements and apply updates

Read and follow:

`.claude/skills/create-test-cases/references/test-case-rules.md`

and:

`references/sync-rules.md`

Do not regenerate every Test Case.

Leave a Test Case untouched when it still covers unchanged
requirements.

Create Test Cases only when Iteration contains `SPRINT`.

Do not create Test Cases titled `QA - שאלות פתוחות`
or `QA - לשים לב`.

If this is not a Dry Run:

- New requirement → create a Test Case, add it to the Suite,
  and link it to the User Story with `Related`.
- Changed requirement → update the matching Test Case steps
  with `testplan_test_case_write` `update_steps`. Update the
  Title with `wit_work_item_write` when the Title must change.
- Removed requirement, or a Test Case that no longer covers
  anything in the current User Story → set that Test Case
  `System.State` to `Removed` with `wit_work_item_write`.
  If the Test Case type has no `Removed` state, stop and ask.
  Do not guess `Closed`.

If Test Case creation succeeds but adding it to the Suite or
creating the Related link fails:

- Do not create the Test Case again.
- Report the partial failure.

Never create a replacement Test Case to fix a failed relationship.

Never update the source User Story Title, Description,
Acceptance Criteria, or State.

---

### 9. Perform additional QA analysis

Read and follow:

`.claude/skills/create-test-cases/references/qa-analysis.md`

Do this only for User Stories that had a material change and
are not `Removed`.

Do not prepare questions for `אין שינוי` User Stories.

Do not prepare questions for `לא טופלו` User Stories.

If there are genuine questions:

- Prepare a candidate question list for that User Story.
- List the English questions, numbered, one per line.
- Do not post yet.
- Do not ask the user yet. Ask after the report.

If there are no meaningful questions, do not prepare a comment
and do not ask.

---

### 10. Dry Run

If the user requests Dry Run / Preview:

- Perform Azure DevOps reads only.
- Do not create or update anything.
- Do not set Test Cases to `Removed`.
- Do not add Discussion comments.

Build the report using proposed values.

Mark writes as `Dry Run — לא נוצר` or `Dry Run — לא עודכן`.

For open questions, set `שאלות פתוחות` to
`Dry Run — לא נכתב` and still show the proposed
candidate comment text.

Do not ask the user in Dry Run.
Do not wait for approval.

Then go to the report and stop.

---

### 11. Open-question approval

If this is a Dry Run, skip this ask.

If this is not a Dry Run, and there are candidate questions
from step 9:

1. Finish creating, updating, and Removed writes.
2. Return the report with `שאלות פתוחות: ממתין לאישור`
   and the candidate question text.
3. Then present the candidate questions in chat, grouped by
   User Story, using this Hebrew prompt:

```
לפני כתיבה ב-Discussion, האם לכתוב כל שאלה הבאה?

### <US id> — <title>
1. <question>
2. <question>

עני כן/לא לכל מספר.
```

4. Stop and wait for the user.
5. Do not post yet.

The questions themselves stay in English.

Accept `כן` / `לא` per number.
`כולן כן` or `כולן לא` is a valid answer for that User Story.

Do not guess.
Do not choose a default.
If a question has no yes/no answer, ask again only about
that question. Do not post until every candidate has an answer.

If there are no candidate questions, skip this ask.
In the report, set `שאלות פתוחות` to `אין`.

#### Post only approved questions

This runs after the user answers, not in the first turn.

Keep only questions the user answered `כן`.
Drop every question the user answered `לא`.
Renumber the kept questions from `1.`

If that User Story has at least one approved question,
add one Discussion comment with `wit_work_item_comment_write`:

- `action`: `add`
- `project`: the User Story's `System.TeamProject`
- `workItemId`: the User Story ID
- `format`: `Html`
- `text`: the mention HTML plus only the approved,
  renumbered questions from
  `.claude/skills/create-test-cases/references/qa-analysis.md`

If every question for a User Story was rejected, do not
post a comment on that User Story.

Do not post on `Removed` or skip-project items.

If a comment add fails:

- record the partial failure
- continue with the remaining work
- do not retry blindly if it is uncertain whether Azure
  already added the comment.

After posting, give a short Hebrew confirmation of what
was written on each User Story, or that nothing was written
because every question was rejected.
Do not repeat the full report.

---

### 12. Combined reply

Always return one Hebrew report.
This report is required, including Dry Run, and including when
nothing was updated.

Put every requested ID in exactly one section.

If a section has no items, write `אין`.

After this report, if this is not a Dry Run and there are
candidate open questions from step 9, present them for
approval as specified in step 11, then stop and wait.

If there are no candidate questions, or this is a Dry Run:
then stop.

Use the structure, headings, and rules in
[references/report-template.md](references/report-template.md).
