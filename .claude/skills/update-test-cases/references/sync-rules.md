# Sync rules for update-test-cases

Use these rules only from `update-test-cases`.
Do not invent product behavior.
If a match is unclear, stop and ask the user.

---

## Find related Test Cases

Read the User Story with `expand: Relations`.

Keep a related work item only when:

- the link type is Related
- the work item type is `Test Case`

Do not use Bugs, Tasks, or other User Stories as Test Cases.

Read those Test Case IDs with `wit_work_item` `get` or `get_batch`.

Exclude already-`Removed` Test Cases when matching coverage or
updating steps.

If a Related item cannot be read, record the failure and continue
with the items that can be read.

---

## Baseline Revision

The baseline is `storedRev`, the User Story Revision in the Suite's
sync marker. Follow
`.claude/skills/create-test-cases/references/sync-marker.md`.

`targetRev` is the User Story `System.Rev` read at the start of
this run.

Compare the User Story at `storedRev` to the User Story at
`targetRev`. Read `storedRev` with `list_revisions`, not `asOf`.

Never use a Test Case `System.ChangedDate` or a date as baseline.
There is no local snapshot file.
Do not hash User Story text into the repo.

Only these fields count as a User Story change:
Title, Description, Acceptance Criteria, Iteration Path, State.
A Revision that changed only Assigned To, tags, Discussion, or
other fields is not a change. The marker is not advanced for it.

---

## Normalize before compare

Before comparing Title, Description, or Acceptance Criteria:

1. Decode HTML entities.
2. Strip HTML tags.
3. Collapse whitespace, including newlines, to single spaces.
4. Trim leading and trailing spaces.

If the normalized text is the same, it is not a content change.

Iteration Path compare is case-insensitive.
Treat a path as `PRODUCT` when it contains `PRODUCT`.
Treat a path as `SPRINT` when it contains `SPRINT`.

State compare is exact against Azure's State value.

---

## Empty content after it existed

If Description or Acceptance Criteria at `storedRev` had text, and the
current field is empty after normalization:

- Do not invent requirements from the Title.
- Do not set every related Test Case to `Removed`.
- Do not post a missing-content Discussion comment.
- Put the User Story under `לא טופלו` with reason
  `תוכן דרישות הוסר מאז היצירה`.

---

## No marker

Applies when related Test Cases (not `Removed`) exist and the Suite
has no marker for this User Story. This covers Test Cases created
before the marker existed, and a `create-test-cases` run that
failed before it wrote the marker.

Do not guess a baseline.
Do not use dates.
Do not mark the Test Cases as synced on your own.

Put the User Story under `ללא נקודת התחלה` and run an alignment
check against the User Story at `targetRev`:

- Extract current requirements (see "Extract requirements").
- Match the existing Test Cases (see "Match existing Test Cases").
- List each requirement as `מכוסה` or `חסר`.
- List each Test Case that contradicts the current User Story or
  covers nothing in it as `לא תואם`.
- List each unclear match as `לא ברור`.

Propose actions for the gaps: create, update, or `Removed`.
Follow the same Iteration rules: create only when Iteration
contains `SPRINT`.

If any item is `לא ברור`, ask about it first. Do not propose a
starting point until it is resolved.

Write nothing in the first turn. After the report, ask:

```
ל-US <id> — <title> אין סימון סנכרון.
בדיקת התאמה מול rev <targetRev>: <n> מכוסות, <n> חסרות, <n> לא תואמים.
<the proposed actions, one per line, or "אין פערים">

האם לבצע את הפעולות המוצעות ולקבוע נקודת התחלה ב-rev <targetRev>?
עני כן/לא.
```

If there are no gaps, ask only:
`האם לקבוע נקודת התחלה ב-rev <targetRev>?`

- `כן`: run the proposed writes, then verify and write the marker
  with `rev = targetRev`.
- `לא`: write nothing. The User Story stays without a marker.

In Dry Run, show the alignment check and the proposed marker, and
do not ask.

---

## No related Test Cases

Do not create the first Test Cases from scratch.

| Current Iteration | Suite found | Action |
| --- | --- | --- |
| `PRODUCT` | any | `לא טופלו` — `Product בלי תרחישים` |
| `SPRINT` | yes | Product → Sprint. Create missing Test Cases in that Suite from the current User Story |
| `SPRINT` | no | `לא טופלו` — `אין תרחישים קשורים`. Tell the user to run `create-test-cases` |
| neither | any | Stop and ask the user |

When Product → Sprint creates the first Test Cases, there is
nothing to compare with. Generate from the User Story at
`targetRev` using `test-case-rules.md`, even when the Suite has no
marker. Then verify and write the marker with `rev = targetRev`.

This table applies only when the Suite has no marker. When it has
a marker, use the normal compare (`storedRev` → `targetRev`), even
if there are no Test Cases.

---

## Find the Suite

Azure DevOps MCP cannot rename a Suite.

Search in the User Story's project:

1. `testplan` `list_plans`
2. `testplan` `list_suites` on candidate plans
3. Candidate Suites: Suite name equals the current User Story
   Title, or any earlier Title. Get earlier Titles from
   `wit_work_item` `list_revisions` on the User Story.
4. Read each candidate Suite work item and its marker
   (`sync-marker.md` "Read the marker").

Pick the Suite:

- Exactly one candidate has a marker with this `us`: use it.
- Several candidates have a marker with this `us`: stop and ask.
- No candidate has a marker with this `us`, and exactly one
  candidate has no marker for any User Story: use it, without a
  baseline.
- Otherwise: stop and ask.

If `list_plans` or `list_suites` fails (for example 401 because the
PAT has no Test Management permission), report it under
`לא טופלו` with reason `כשל`. Do not continue without a Suite.

Do not nest a new Suite under an existing child Suite.

Do not create a second Suite because the Title changed.

If the Title changed and the Suite was found under the old name,
keep that Suite and report that its name is still the old Title.

If no Suite is found and Test Cases must be added:

- Product → Sprint with no Suite: create a Test Plan and Suite
  using `create-test-cases` structure rules and `projects.md`.
- Any other case: stop and ask the user.

---

## Extract requirements

Use Title, Description, and Acceptance Criteria.

Treat Description and Acceptance Criteria as requirements.

Split Acceptance Criteria into individual testable criteria.

Do not duplicate coverage when the same requirement appears in
both Description and Acceptance Criteria.

When several related User Stories are on the same topic, read all
of them before matching. Do not duplicate coverage that another
User Story in the same topic already covers.

Do not invent product behavior.

---

## Classify the User Story diff

Compare requirements at `storedRev` to requirements at `targetRev`.

- **Unchanged:** same meaning after normalization.
- **Added:** present at `targetRev`, not at `storedRev`.
- **Removed:** present at `storedRev`, not at `targetRev`.
- **Changed:** same topic, different expected behavior.

PRODUCT → SPRINT is a material Iteration change even when
requirements are unchanged.

---

## Match existing Test Cases

Use only related Test Cases whose State is not `Removed`.

Match by Title and Steps intent, not by ID order.

- A Test Case that covers only unchanged requirements:
  leave it untouched.
- A Test Case that covers a changed requirement:
  update its Steps, and its Title when the Title no longer fits.
- A Test Case that covers only removed requirements:
  set `System.State` to `Removed`.
- A Test Case that covers a mix of removed and remaining
  requirements: update it so obsolete Steps are dropped and the
  remaining coverage stays. Do not Removed it.
- An added requirement with no matching Test Case:
  create a new Test Case.
- An unmatched Test Case that still fits the current User Story:
  leave it untouched. It may be extra QA coverage.
- An unmatched Test Case that contradicts the current User Story
  or only tests removed behavior: set `Removed`.

If two Test Cases could match the same changed requirement, or
no Test Case is a clear match, stop and ask.
Do not guess.
Do not update both.
Do not Removed both.

Do not regenerate Test Cases that still match.

A Test Case created by an earlier run that failed partway counts
as an existing match. Follow "Resume after a partial failure" in
`sync-marker.md` before creating anything.

---

## Writes

Create:

- `testplan_test_case_write` `create` with Steps
- `testplan_test_suite_write` `add_test_cases`
- `wit_work_item_link_write` `related` to the source User Story

Update Steps:

- `testplan_test_case_write` `update_steps`

Update Title:

- `wit_work_item_write` `update` on `System.Title`

Obsolete Test Case:

- `wit_work_item_write` `update` on `System.State` = `Removed`

Sync marker, last and only after every write above succeeded:

- `wit_work_item_write` `update` on the Suite's `System.Description`
  (`sync-marker.md` "Write the marker")

If `Removed` is not a valid state for Test Case in that project,
stop and ask. Do not guess `Closed`. Do not delete the work item.

Do not update the User Story Title, Description, Acceptance
Criteria, or State.

---

## Iteration and State

User Story State `Removed`:
do not update, create, or post questions.

User Story Iteration contains `PRODUCT`:
do not create new Test Cases.
If Test Cases already exist from a previous Sprint, update or
Removed them only when User Story content changed.
Do not Removed them only because Iteration is Product.

User Story Iteration contains `SPRINT`:
create missing Test Cases for added requirements, including the
Product → Sprint case when a Suite already exists.

Iteration changed from `PRODUCT` at `storedRev` to `SPRINT` at
`targetRev`: every current requirement without a matching Test
Case gets a new Test Case, also when the requirement is unchanged.
