# Test Case Rules

## User Story Analysis

Before generating Test Cases, use:

- Title
- Description
- Acceptance Criteria

Treat all three as sources of requirements.

When several related User Stories are on the same topic,
read all of them before generating Test Cases.

Do not duplicate coverage that another User Story in the
same topic already covers.

Do not create Test Cases or a Suite for a User Story
whose State is `Removed`.

Generate Test Cases only for User Stories whose State is
not `Removed` and whose Iteration contains SPRINT.

Acceptance Criteria must be reviewed individually.

Every testable requirement in the Acceptance Criteria must be covered
by at least one Test Case or Test Step.

Requirements from the Description must also receive coverage when applicable.

Do not create duplicate tests when the same requirement appears in both
Description and Acceptance Criteria.

Do not invent product behavior.

## Language

Write Test Cases in Hebrew.

Use clear product and QA terminology.

Do not translate technical terms when keeping the original term makes
the Test Case clearer.

## Test Case Titles

Every Test Case must have a clear Hebrew title.

The title should describe what is being tested.

Prefer concise titles such as:

`טופס הזמנה - יצירת הזמנה`

`טופס הזמנה - תצוגה`

These are naming examples only.
Do not create them unless supported by the User Story.

Do not use generic names such as:

- Test 1
- Scenario 1
- בדיקה
- תרחיש 1

## Test Case Granularity

Group related checks into the same Test Case when they belong to:

- the same screen
- the same logical flow
- the same functionality

For example, several UI elements on the same screen may be checked
as separate Steps inside one Test Case.

Create a separate Test Case when there is:

- a different functional flow
- a different behavior
- a different meaningful outcome

Avoid creating many tiny Test Cases.

Avoid creating one very large Test Case containing unrelated functionality.

## Test Steps

Each Test Case must contain one or more Steps.

Each Step contains:

- Action
- Expected Result

### Action

Write the Action in Hebrew.

The Action should clearly describe:

- what the tester performs
- or what the tester is checking

Keep Actions concise and specific.

Do not invent screens, buttons, fields, or actions that are not supported
by the User Story.

### Expected Result

Write the Expected Result in Hebrew.

The Expected Result must:

- correspond directly to the Action
- be specific and testable
- be supported by the User Story

Do not invent expected product behavior.

If the expected behavior is unclear, add it as a candidate
open question. It requires user approval before it is
written on the User Story Discussion.
Do not invent an Expected Result.
Do not create a Test Case titled `QA - שאלות פתוחות`.

## Preconditions

Add Preconditions only when a prerequisite is clearly required by
the User Story or test flow.

Do not invent:

- user roles
- permissions
- existing data
- configuration
- previous system state

If no meaningful prerequisite is known, leave Preconditions empty.

## Coverage

Before finalizing the Test Cases, verify:

- every testable Acceptance Criterion is covered
- relevant Description requirements are covered
- duplicate coverage has been avoided

A requirement may be covered by:

- an entire Test Case
- or a specific Step inside a Test Case
