# QA Analysis Rules

Perform this analysis only after creating coverage for the explicit
User Story requirements.

Never present inferred QA behavior as a confirmed product requirement.

When several related User Stories are on the same topic,
read all of them before preparing QA questions.

Do not add a question that another תקין User Story in the same
topic already answers.

Do not prepare or post questions for a User Story whose State
is `Removed`.

Do not prepare or post questions for a User Story that is not
תקין.

Do not prepare or post questions on items in the skip-project
from `validate-work-item-content/references/azure.md`
(sample: `Support`).

Never create a Test Case titled `QA - שאלות פתוחות`.

Never create a Test Case titled `QA - לשים לב`.

## Open questions — Discussion on the User Story

Use a Discussion comment on the source User Story for behavior
that is unclear or missing from that User Story.

Prepare candidate questions only when they are genuine.

Do not post them on the User Story until the user approves
each question.

Examples include:

- unclear expected behavior
- ambiguous Acceptance Criteria
- missing behavior for an edge case
- conflicting requirements
- missing information required to test the feature

Each candidate question is a numbered line.

Number the questions starting from `1`.
Put a line break after each question.

Format:

```
1. <first question>
2. <second question>
```

A single question is still numbered as `1.`

Write every question clearly in English.

Never invent the answer.

If there are no meaningful questions, do not prepare a comment
and do not ask the user.

If several related User Stories are on the same topic, keep each
question on the User Story it belongs to.

Do not duplicate the same question on more than one User Story.

### Ask the user before posting

Candidate questions must not be written on the User Story
until the user answers `כן` or `לא` for each one.

After Test Cases are created, present every candidate question
in chat as a numbered list, grouped by User Story.

Do not post yet.
Stop and wait.

Keep only questions the user answered `כן`.
Drop every question the user answered `לא`.
`כולן כן` or `כולן לא` is a valid answer for that User Story.

If a question has no yes/no answer, ask again only about
that question. Do not guess.

After approval, renumber the kept questions from `1.` before
posting.

If a User Story has no approved questions, do not post a
comment on that User Story.

In Dry Run, do not ask and do not post. Include the proposed
candidate comment text in the report, and note that these
questions would have been asked for approval.

### How to post

Post only after the user has answered, and only the approved
questions.

Use Azure DevOps MCP `wit_work_item_comment_write`:

- `action`: `add`
- `project`: the User Story's `System.TeamProject`
- `workItemId`: the User Story ID
- `format`: `Html`
- `text`: the mention HTML, then only the approved,
  renumbered questions

Do not update Title, Description, Acceptance Criteria, or State.

### Mentions

Replace the sample names and identity IDs below with people from
your Azure DevOps organization. The IDs here are fake placeholders
and will not notify anyone until you replace them.

Always start with these mentions, in this order, with two spaces
between them:

`@<Alex Rivera>  @<Jordan Lee>`

Use HTML mention tags so Azure DevOps notifies these people.
Use these identity IDs exactly:

| Display name | Identity ID |
| --- | --- |
| Alex Rivera | `123e4567-e89b-12d3-a456-426614174001` |
| Jordan Lee | `123e4567-e89b-12d3-a456-426614174002` |

Do not mention anyone else.
Do not look up different identities.
Do not replace a name if lookup fails. Use the IDs above.

Mention HTML prefix:

```html
<a href="#" data-vss-mention="version:2.0,123e4567-e89b-12d3-a456-426614174001">@Alex Rivera</a>  <a href="#" data-vss-mention="version:2.0,123e4567-e89b-12d3-a456-426614174002">@Jordan Lee</a>
```

Then add the approved, renumbered questions, one per line,
separated by `<br>`.

Full HTML example:

```html
<a href="#" data-vss-mention="version:2.0,123e4567-e89b-12d3-a456-426614174001">@Alex Rivera</a>  <a href="#" data-vss-mention="version:2.0,123e4567-e89b-12d3-a456-426614174002">@Jordan Lee</a><br>1. What happens when day 31 is selected and the next month does not have a day 31?
```

If there are several questions, keep the same mention prefix and
put each numbered question on its own line:

```html
<a href="#" data-vss-mention="version:2.0,123e4567-e89b-12d3-a456-426614174001">@Alex Rivera</a>  <a href="#" data-vss-mention="version:2.0,123e4567-e89b-12d3-a456-426614174002">@Jordan Lee</a><br>1. What happens when day 31 is selected and the next month does not have a day 31?<br>2. What is displayed when there is no data?
```

Do not add any other sentence before the questions.
Do not add the work item ID.
Do not change the display names.

If a comment add fails:

- record the failure
- record the Azure DevOps MCP error
- continue with the remaining work

Do not retry blindly if it is uncertain whether Azure already
added the comment.

## Additional QA thinking for regular Test Cases

Think like a QA engineer when generating regular Test Cases.

Consider when relevant:

- Edge cases
- Boundary values
- Regression risks
- Unusual user flows
- Data consistency
- Persistence
- Duplicate actions
- Repeated operations
- State changes
- Error handling
- Different relevant data conditions

If an extra check is testable without inventing product behavior,
include it as a regular Test Case or Step.

Do not present inferred checks as confirmed product requirements
unless they are supported by the User Story.

If the expected behavior is not defined, treat it as a
candidate open question. Ask the user whether to write it
on the User Story before posting. Do not invent an answer.

Never create a separate Test Case for these considerations.

Never use the titles `QA - שאלות פתוחות` or `QA - לשים לב`.

## Important distinction

Regular Test Cases:
→ What the User Story says must work.

Open questions Discussion:
→ What the User Story does not explain and requires
clarification. Candidate questions are shown to the user
first. Only approved questions are posted.

Additional QA thinking:
→ Extra risks that may become regular Test Cases when they do
not invent product behavior. Not a separate Test Case category.
