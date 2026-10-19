---
name: update-test-cases
description: >-
  Updates existing Azure DevOps Test Cases when a User Story has changed
  since they were created or last synced. Supports the Azure projects
  listed in create-test-cases/references/projects.md. Compares the current Title,
  Description, Acceptance Criteria, Iteration, and State to the User Story
  Revision stored in the Suite's sync marker. Adds, updates, or sets
  obsolete Test Cases to Removed, and advances the marker only after every
  write succeeded. For Test Cases without a marker, runs an alignment check
  and asks before setting a starting point. Does not run
  validate-work-item-content.
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
- Sync marker: `.claude/skills/create-test-cases/references/sync-marker.md`

Use Azure DevOps MCP for all Azure DevOps operations.

Do not use Azure CLI, PowerShell, Bash, REST calls, or local scripts.

Do not search unrelated workspace files, previous chats, or old scripts.

---

## Workflow

### 1. Do not validate content

Do not read or follow `validate-work-item-content`.

Do not post a missing-content Discussion comment.

If current Description or Acceptance Criteria are empty after they
were present at `storedRev`, go to `לא טופלו`.
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
- Rev (`System.Rev`)
- Relations

`targetRev` is the `System.Rev` from this read.
Every diff in this run is built against `targetRev`.

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

For coverage matching, ignore Test Cases whose State is already
`Removed`. Do not resurrect them.

Do not use the Test Cases' `System.ChangedDate` for anything.
A manual change to a Test Case (Assigned To, tags, Steps) does not
move the baseline.

---

### 4. Find the Suite and read the sync marker

Follow "Find the Suite" in `references/sync-rules.md`, then
"Read the marker" in
`.claude/skills/create-test-cases/references/sync-marker.md`.

`storedRev` is the `rev` in the marker for this User Story.

If no Suite is found, there is no `storedRev`.

---

### 5. Decide whether this skill may continue

Follow `references/sync-rules.md` for each User Story.

If the User Story State is `Removed`:

- Do not update Test Cases.
- Do not create Test Cases.
- Do not post open questions.
- Do not write the marker.
- Put it under `לא טופלו`.

If Iteration contains neither `PRODUCT` nor `SPRINT`:

- Stop and ask the user.
- Do not assume.

If several related User Stories belong to different projects:

- Stop and ask the user.
- Do not assume.

Then choose one path:

| Marker | Related Test Cases (not `Removed`) | Path |
| --- | --- | --- |
| yes | any | step 6 — compare `storedRev` to `targetRev` |
| no | yes | `ללא נקודת התחלה` — "No marker" in `references/sync-rules.md` |
| no | none | "No related Test Cases" in `references/sync-rules.md` |

Never guess a baseline when there is no marker.
Never mark existing Test Cases as synced without the user's
approval.

---

### 6. Compare the stored Revision to the current Revision

Read the User Story at `storedRev` with `list_revisions`
(see "Read the User Story at a Revision" in `sync-marker.md`).

Compare it to the User Story at `targetRev` from step 2.

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
  Do not advance the marker.

If they differ, continue.

PRODUCT → SPRINT is a material change even when Title,
Description, and Acceptance Criteria are unchanged.

---

### 7. Load the project configuration

Read the matching project section from:

`.claude/skills/create-test-cases/references/projects.md`

Determine the project from the User Story Area Path / Team Project.

Create or update Test Cases in that project.

Use the configured Language.

Do not guess Test Plan.

Do not use a configured Parent Suite.

---

### 8. Suite rules

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

### 9. Diff requirements and apply updates

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

Before each write, check whether it already happened.
Follow "Resume after a partial failure" in `sync-marker.md`.
A run after a partial failure must not create duplicates.

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

### 10. Verify and write the sync marker

If this is a Dry Run, skip this step. Show the marker that would be
written.

For each User Story that had a material change and finished
step 9 (also when no Test Case write was needed), and for each
User Story whose starting point the user approved in step 13:

1. Follow "Verify before marking" in `sync-marker.md`.
2. If any write failed or any check failed: do not write the
   marker. Report `סימון סנכרון: לא עודכן — נותר כשל חלקי`.
3. Follow "User Story changed during the sync" in `sync-marker.md`.
4. Write `rev = targetRev` with "Write the marker".
5. If the write fails, follow "Write failure". Do not switch to
   another storage place.

Do not write the marker for `אין שינוי` or `לא טופלו` items, or for
`ללא נקודת התחלה` items the user did not approve.

If the material change needed no Test Case write (for example, the
Iteration contains `PRODUCT` and there are no Test Cases), still
advance the marker to `targetRev`. The change was reviewed.

---

### 11. Perform additional QA analysis

Read and follow:

`.claude/skills/create-test-cases/references/qa-analysis.md`

Do this only for User Stories that had a material change and
are not `Removed`.

Do not prepare questions for `אין שינוי` User Stories.

Do not prepare questions for `לא טופלו` User Stories.

Do not prepare questions for `ללא נקודת התחלה` User Stories.

If there are genuine questions:

- Prepare a candidate question list for that User Story.
- List the English questions, numbered, one per line.
- Do not post yet.
- Do not ask the user yet. Ask after the report.

If there are no meaningful questions, do not prepare a comment
and do not ask.

---

### 12. Dry Run

If the user requests Dry Run / Preview:

- Perform Azure DevOps reads only.
- Do not create or update anything.
- Do not set Test Cases to `Removed`.
- Do not add Discussion comments.
- Do not write or change the sync marker.

Build the report using proposed values.

Mark writes as `Dry Run — לא נוצר` or `Dry Run — לא עודכן`.

For open questions, set `שאלות פתוחות` to
`Dry Run — לא נכתב` and still show the proposed
candidate comment text.

Do not ask the user in Dry Run.
Do not wait for approval.

Then go to the report and stop.

---

### 13. Approvals after the report

If this is a Dry Run, skip this ask.

#### Starting point for `ללא נקודת התחלה`

If this is not a Dry Run and a User Story is under
`ללא נקודת התחלה`, ask after the report.
Use the prompt in "No marker" in `references/sync-rules.md`.

Write nothing for that User Story before the user answers `כן`.

After `כן`: read the User Story again. If its `System.Rev` is no
longer `targetRev`, rebuild the alignment check, report it, and ask
again. Do not write the old proposal. Otherwise run step 9 for the
proposed actions, then step 10 with `rev = targetRev`.

After `לא`: write nothing for that User Story.

#### Open questions

If this is not a Dry Run, and there are candidate questions
from step 11:

1. Finish creating, updating, and Removed writes, and step 10.
2. Return the report with `שאלות פתוחות: ממתין לאישור`
   and the candidate comment text.
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
End with the final status line for each User Story from
"Final status line" in
[references/report-template.md](references/report-template.md).

---

### 14. Combined reply

Always return one Hebrew report.
This report is required, including Dry Run, and including when
nothing was updated.

Put every requested ID in the report exactly once.

The section names in this file (`אין שינוי`, `עודכנו`,
`ללא נקודת התחלה`, `לא טופלו`) are internal categories.
Do not print them as report headings. Start with the verdict line
from the template, and do not print empty sections or `אין` lines.

After this report, if this is not a Dry Run and there are
`ללא נקודת התחלה` items or candidate open questions from step 11,
present them for approval as specified in step 13, then stop
and wait.

If there is nothing to approve, or this is a Dry Run:
then stop.

Use the structure, headings, and rules in
[references/report-template.md](references/report-template.md).
