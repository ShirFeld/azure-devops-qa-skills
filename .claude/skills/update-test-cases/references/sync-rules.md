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

Include already-`Removed` Test Cases when computing `baselineDate`.
Exclude them when matching coverage or updating steps.

If a Related item cannot be read, record the failure and continue
with the items that can be read.

---

## Baseline date

`baselineDate` is the latest `System.ChangedDate` among all related
Test Cases, including `Removed`.

Use that timestamp as `asOf` when reading the User Story baseline.

If Azure returns the date without a timezone, keep it as returned
and pass it to `asOf`. Do not invent a timezone.

There is no local snapshot file.
Do not hash User Story text into the repo.
Do not treat Assigned To, tags, or Discussion as the baseline.

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

If baseline Description or Acceptance Criteria had text, and the
current field is empty after normalization:

- Do not invent requirements from the Title.
- Do not set every related Test Case to `Removed`.
- Do not post a missing-content Discussion comment.
- Put the User Story under `לא טופלו` with reason
  `תוכן דרישות הוסר מאז היצירה`.

---

## No related Test Cases

Do not create the first Test Cases from scratch.

| Current Iteration | Suite found | Action |
| --- | --- | --- |
| `PRODUCT` | any | `לא טופלו` — `Product בלי תרחישים` |
| `SPRINT` | yes | Product → Sprint. Create missing Test Cases in that Suite from the current User Story. |
| `SPRINT` | no | `לא טופלו` — `אין תרחישים קשורים`. Tell the user to run `create-test-cases`. |
| neither | any | Stop and ask the user. |

When Product → Sprint creates the first Test Cases, there is no
content baseline. Generate from the current User Story using
`test-case-rules.md`. Do not asOf-compare content.

---

## Find the Suite

Azure DevOps MCP cannot rename a Suite.

Search in the User Story's project:

1. `testplan` `list_plans`
2. `testplan` `list_suites` on candidate plans
3. Match Suite name to the baseline (`asOf`) User Story Title
   exactly as it appeared in Azure DevOps

If not found, try the current User Story Title.

Do not nest a new Suite under an existing child Suite.

Do not create a second Suite because the Title changed.

If the Title changed and the Suite was found under the old name,
keep that Suite and report that its name is still the old Title.

If several Suites match, stop and ask the user.

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

Compare baseline requirements to current requirements.

- **Unchanged:** same meaning after normalization.
- **Added:** present now, not present at baseline.
- **Removed:** present at baseline, not present now.
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
