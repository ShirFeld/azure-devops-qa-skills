---
name: create-test-cases
description: >-
  Creates Azure DevOps Test Suites and Test Cases from one or more User Stories.
  Supports the Azure projects listed in references/projects.md.
  Always runs validate-work-item-content first. Creates test scenarios only
  for items whose required Description and Acceptance Criteria are present.
  Items with missing content receive a Discussion comment and are skipped.
  Reads the Title, Description, and Acceptance Criteria, generates Hebrew
  QA scenarios, creates them in Test Plans, and links every Test Case
  to the source User Story using Related. Presents genuine open
  questions for user approval, then posts only the approved
  questions as a Discussion comment on the User Story instead
  of a Test Case.
  If Test Cases already exist and the user wants to check whether
  the User Story changed before testing, use update-test-cases.
  Do not create duplicate Test Cases.
  Use when the user asks for test cases, test scenarios, תרחישי בדיקה,
  כתיבת תרחישים, יצירת תרחישים, or provides a User Story for QA testing.
argument-hint: <User Story ID or several related User Story IDs>
---

# /create-test-cases

Create Test Cases for existing User Stories using Azure DevOps MCP.

This is one skill for every supported Azure project.
Do not look for a per-project copy of this `SKILL.md`.
Project differences (Test Plan, Parent Suite, Language) live only in
`references/projects.md`.

Supported projects are the project sections in
`references/projects.md`.
Do not hardcode a project list in this file.

Before creating anything, run the content validation skill on every
User Story ID in this request. Create Test Cases only for items that
are תקין. See step 1.

---

## Never guess

If anything is unclear, stop and ask the user.

Do not invent an answer.
Do not choose a default.
Do not continue creating until the user answers.

This includes unclear Iteration, unclear Project, mixed projects
in the same topic, missing IDs, or unclear expected product behavior
that affects what to create.

Do not invent Description or Acceptance Criteria for an item
whose required content is missing.

---

## Input

Required:

- At least one User Story ID

The user may give one User Story or several related User Stories
on the same topic.

If User Story ID is missing, ask:
`מה ה-ID של ה-US?`

Do not create anything until the User Story ID is known.

Do not treat User Stories as the same topic unless the user
says they are related and lists the IDs.

The first User Story is the first ID the user listed.

---

## Workflow

### 1. Validate content first

Read and follow:

`.claude/skills/validate-work-item-content/SKILL.md`

and its Azure config:

`.claude/skills/validate-work-item-content/references/azure.md`

Run that skill on every User Story ID from this request,
in the user's order.

Follow every validation rule:

- Read the work items with Azure DevOps MCP.
- Decide whether required Description and Acceptance Criteria
  are present.
- When required data is missing, add the Discussion comment
  defined by that skill.
- Do not comment on items in the skip-project from that skill's
  `references/azure.md` (sample: `Support`).
- Do not comment on items that already have the required content.
- Do not update work item fields.

If this request is a Dry Run / Preview, run validation as Dry Run
too: reads only, no Discussion comments.

Keep the full Hebrew validation report for the combined reply.

Do not stop after the validation report.
That skill's "Then stop" applies only when it is run on its own.
This skill continues with the results.

Split every ID into one of:

- תקין — required content is present
- חסר תוכן — required content is missing; Discussion was posted
  or would be posted in Dry Run
- לא נבדקו — skip-project, not found, or failed

Continue this workflow only with תקין IDs.

For every ID that is not תקין:

- Do not create a Test Plan for that item alone.
- Do not create a Suite for that item.
- Do not create Test Cases for that item.
- Do not generate scenarios from the Title.
- Do not post an open-questions Discussion comment.

When several User Stories are in the same request:

- Create tests only for the תקין items.
- Skip the rest.
- Still include every requested ID in the combined report.

If no ID is תקין:

- Create nothing.
- Go to the combined reply.

---

### 2. Read the User Story or Stories

Use Azure DevOps MCP to read every תקין source User Story.

Do not read a User Story for test generation if it is not תקין.

Read:

- Title
- Description
- Acceptance Criteria
- State
- Area Path
- Iteration Path
- Team Project

Do not generate scenarios from the Title alone.

Treat Description and Acceptance Criteria as requirements.

Every testable Acceptance Criterion must receive test coverage.

Do not invent product behavior.

When several תקין User Stories are on the same topic:

- Read all of them together before generating tests.
- Use a later User Story to answer questions that appear
  in an earlier User Story.
- Do not leave a question open if another תקין User Story
  in the same topic already answers it.
- Do not use a User Story that is not תקין to answer questions
  or to generate tests.

---

### 3. Decide whether tests may be created

These rules apply only to תקין User Stories.

Check the State of each תקין User Story first.

If the State is `Removed`:

- Do not create a Suite for that User Story.
- Do not create Test Cases for that User Story.
- Do not post an open-questions Discussion comment.
- If every תקין User Story is Removed, create nothing
  and go to the combined reply.

Then check the Iteration Path of each remaining תקין User Story.

Treat the Iteration check as case-insensitive.

If the Iteration Path contains `PRODUCT`, including paths such as
`Mobile App\Product Backlog`:

- The User Story is still with Product.
- Create a Suite named with the User Story Title.
- Do not create Test Cases under that Suite.

If the Iteration Path contains `SPRINT`:

- Create Test Cases for that User Story.
- Create them in the same Azure DevOps project as the User Story.

If the Iteration Path contains neither `PRODUCT` nor `SPRINT`:

- Stop and ask the user.
- Do not assume.

When a topic has mixed User Stories:

- Skip every User Story that is not תקין.
- Skip every תקין User Story whose State is `Removed`.
- For every remaining User Story whose Iteration contains `SPRINT`:
  create the Suite and the Test Cases.
- For every remaining User Story whose Iteration contains `PRODUCT`:
  create only the Suite with the User Story Title.
  Do not create Test Cases there.

If no User Story remains eligible to create a Suite or Test Cases:

- Create nothing.
- Go to the combined reply.

---

### 4. Load the project configuration

Read the matching project section from:

`references/projects.md`

Determine the project from the User Story Area Path / Team Project.

Create Test Cases in that project.

If several related User Stories belong to different projects:

- Stop and ask the user where to create the Test Plan.
- Do not assume.

Use the configured Language.

If Test Plan is configured as None / create new:
create a new Test Plan according to the structure rules below.

If a specific Test Plan is configured, use that Test Plan.

Do not guess Test Plan.

Do not use a configured Parent Suite.

---

### 5. Test Plan and Suite structure

Use only תקין User Stories that are not `Removed`.

#### One User Story

If the User Story is not תקין or its State is `Removed`:
create nothing.

Otherwise create:

- one new Test Plan
- one Suite under the Test Plan root

Test Plan name:
a short general Hebrew name based on that User Story.

Suite name:
the User Story Title exactly as it appears in Azure DevOps.

#### Several related User Stories on the same topic

Create:

- one new Test Plan for the topic
- one Suite per תקין User Story that is not `Removed`

Do not create a Suite for a User Story that is not תקין.

Do not create a Suite for a User Story whose State is `Removed`.

Test Plan name:
a short general Hebrew name based on the first User Story
the user listed that is תקין and is not `Removed`.

Suite name:
the Title of that User Story exactly as it appears in Azure DevOps.

Place the Test Cases of each User Story only under that
User Story's Suite.

Do not create Test Cases titled `QA - שאלות פתוחות`
or `QA - לשים לב`.

A Test Case that belongs to more than one User Story:

- place it under the primary User Story Suite
- do not duplicate it in another Suite

Create every Suite directly under the Test Plan root.

Do not place a Suite under an existing child Suite.

If the user explicitly names a Parent Suite, use that instead.

Check that an equivalent Suite does not already exist.

Do not create duplicate Suites.

If no תקין User Story remains that is not `Removed`:
create nothing.

---

### 6. Generate names

Test Plan name rules:

- Use clear product language in Hebrew.
- Keep it general, usually 2–6 words.
- Base it on the first תקין User Story when there are several.
- Do not copy the English Title verbatim.
- Do not invent functionality.

Suite name rules:

- Use the User Story Title as it appears in Azure DevOps.
- Do not translate it.
- Do not shorten it.

---

### 7. Generate Test Cases

Read and follow:

`references/test-case-rules.md`

Generate Test Cases only for תקין User Stories whose Iteration
contains `SPRINT`.

Do not generate Test Cases for an item whose required content
is missing.

Generate enough Test Cases to cover:

- Description requirements
- Acceptance Criteria

Avoid duplicate coverage across תקין User Stories in the same topic.

---

### 8. Perform additional QA analysis

Read and follow:

`references/qa-analysis.md`

Do not create Test Cases titled `QA - שאלות פתוחות`
or `QA - לשים לב`.

If there are genuine questions for a תקין User Story that is
not `Removed`:

- Prepare a candidate question list for that User Story.
- List the English questions, numbered, one per line:
  `1. <first question>` then a line break, `2. <second question>`, and so on.
- Do not post yet.
- Do not ask the user yet. Ask in step 12 after the combined reply.

If there are no meaningful questions, do not prepare a comment
and do not ask.

Keep QA assumptions separate from confirmed User Story requirements.

When several תקין User Stories are on the same topic, do not add a
question that is already answered by another תקין User Story
in the topic.

Extra QA risks may become regular Test Cases or Steps when they
do not invent product behavior.

---

### 9. Dry Run

If the user requests Dry Run / Preview:

- Validation in step 1 must also be Dry Run.
- Perform Azure DevOps reads only.
- Do not create or update anything.
- Do not add Discussion comments.

Build the combined reply from step 13 using proposed values
for תקין items only:

- Iteration and State decision for each User Story
  (create tests / Suite only / skip Removed / skip missing content
  / ask the user)
- proposed Test Plan name
- proposed Suite names
- proposed Test Cases per Suite
- Steps and Expected Results
- proposed candidate open-questions text
- Acceptance Criteria coverage

In the test-case report, mark created fields as
`Dry Run — לא נוצר`.

For open questions, set `שאלות פתוחות` to
`Dry Run — לא נכתב` and still show the proposed
candidate comment text.

Note in the report that these candidate questions
would have been asked for approval before posting.

Do not ask the user in Dry Run.
Do not wait for approval.

Then go to the combined reply and stop.

---

### 10. Create the Test Plan and Suites

If this is not a Dry Run:

Use Azure DevOps MCP.

Create the Test Plan and Suites according to the structure rules.

Create them only for תקין User Stories.

For a Product User Story that is תקין and is not `Removed`,
still create the Suite.
Do not add Test Cases to it.

Do not create a Suite for a User Story that is not תקין.

Do not create a Suite for a User Story whose State is `Removed`.

---

### 11. Create the Test Cases

Create Test Cases only for User Stories that are תקין,
whose State is not `Removed`, and whose Iteration contains `SPRINT`.

For each Test Case:

1. Create the Test Case in the User Story's project.
2. Add its Steps and Expected Results.
3. Add it to that User Story's Suite.
4. Link it to the source User Story using `Related`.

Every created Test Case must be Related to the source User Story.

Do not create Test Cases titled `QA - שאלות פתוחות`
or `QA - לשים לב`.

Do not create duplicate Test Cases.

---

### 12. Safe writes and open-question approval

If Test Case creation succeeds but adding it to the Suite or creating
the Related link fails:

- Do not create the Test Case again.
- Report the partial failure.

Never create a replacement Test Case to fix a failed relationship.

Never update the source User Story Title, Description,
Acceptance Criteria, or State.

The only allowed write to the source User Story is an
approved open-questions Discussion comment from step 8.

Missing-content Discussion comments from
`validate-work-item-content` are not part of this approval.

#### Ask before posting

If this is a Dry Run, skip this ask.

If this is not a Dry Run, and there are candidate questions
from step 8:

1. Finish creating the Test Plan, Suites, and Test Cases.
2. Return the combined reply from step 13 with
   `שאלות פתוחות: ממתין לאישור` and the candidate question text.
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

For each תקין User Story that is not `Removed`:

- Keep only questions the user answered `כן`.
- Drop every question the user answered `לא`.
- Renumber the kept questions from `1.`

If that User Story has at least one approved question,
add one Discussion comment with Azure DevOps MCP
`wit_work_item_comment_write`:

- `action`: `add`
- `project`: the User Story's `System.TeamProject`
- `workItemId`: the User Story ID
- `format`: `Html`
- `text`: the mention HTML plus only the approved,
  renumbered questions from `references/qa-analysis.md`

Post each approved question on the User Story it belongs to.

If every question for a User Story was rejected, do not
post a comment on that User Story.

Do not post when there are no approved questions.

Do not post on `Removed`, missing-content, or skip-project items.

If a comment add fails:

- record the partial failure
- continue with the remaining work
- do not retry blindly if it is uncertain whether Azure
  already added the comment.

After posting, give a short Hebrew confirmation of what
was written on each User Story, or that nothing was written
because every question was rejected.
Do not repeat the full combined report.

---

### 13. Combined reply

Always return one Hebrew report with both parts below.
This report is required, including Dry Run, and including when
no Test Cases were created.

Put every requested ID in exactly one section of the test-case
report.

If a section has no items, write `אין`.

After this report, if this is not a Dry Run and there are
candidate open questions from step 8, present them for
approval as specified in step 12, then stop and wait.

If there are no candidate questions, or this is a Dry Run:
then stop.

Do not post open-questions Discussion comments before the
user answers the approval ask.

#### Part A — content validation

Use the structure, headings, and rules in
`.claude/skills/validate-work-item-content/references/report-template.md`.

#### Part B — test cases

Use the structure, headings, and rules in
[references/report-template.md](references/report-template.md).
