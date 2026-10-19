# Sync marker — shared by create-test-cases and update-test-cases

The sync marker records which User Story Revision the Test Cases
were created or synced from.

It lives in the `System.Description` of that User Story's
Test Suite work item. It is the only baseline for
`update-test-cases`.

Do not use `System.ChangedDate` of Test Cases as a baseline.
Do not use any custom field. Do not create a field.
Do not store the marker in tags, links, Discussion, the Test Plan,
or the User Story.
If the Suite Description cannot be read or written, do not switch
to another storage place. Report it. See "Write failure".

---

## Format

One line per User Story:

```
[qa-sync] us=<User Story ID> rev=<User Story System.Rev>
```

Example: `[qa-sync] us=12345 rev=14`

- `us` is the source User Story ID.
- `rev` is the User Story `System.Rev` whose Title, Description,
  Acceptance Criteria, Iteration, and State the Test Cases now
  fully match.

In HTML, write the marker as its own block at the end of the
Description:

```html
<div>[qa-sync] us=12345 rev=14</div>
```

---

## Read the marker

1. The Suite ID from `testplan` `list_suites` is also its
   work item ID.
2. Read it with `wit_work_item` `get`, fields
   `System.WorkItemType`, `System.Description`, `System.Rev`.
3. If `System.WorkItemType` is not `Test Suite`, or the read
   fails, the marker is unreadable. Report it and stop for
   that User Story. Do not guess.
4. Strip HTML and decode entities. Search for
   `[qa-sync] us=<id> rev=<number>`.

Results:

| Found | Meaning |
| --- | --- |
| exactly one marker with this `us` | `storedRev` = its `rev` |
| no marker with this `us` | no stored baseline. See `update-test-cases` "No marker" |
| two or more markers with this `us` | stop and ask the user |
| `rev` is not a whole number, or is greater than the current User Story `System.Rev` | stop and ask the user |
| only markers for a different `us` | this Suite belongs to another User Story. Do not use it |

---

## Read the User Story at a Revision

Use `wit_work_item` `list_revisions`:

- `workItemId`: the User Story ID
- `skip`: `rev - 1`
- `top`: `1`

Check that the returned `rev` equals the requested `rev`.
If not, stop and report. Do not use `asOf` by date.

---

## Write the marker

Write only when all are true:

- this is not a Dry Run
- every planned write for this User Story succeeded and was
  verified (see "Verify before marking")
- the user approved a starting point when one was required
  (`update-test-cases` "No marker")

Steps:

1. Read the Suite work item again: `System.Description`,
   `System.Rev`.
2. Build the new Description:
   - If a marker for this `us` exists, replace only that marker
     text. Keep every other character as is.
   - If no marker exists, append
     `<div>[qa-sync] us=<id> rev=<rev></div>` at the end.
     Keep all existing content as is.
   - Never remove or rewrite other text, other markers, or
     formatting.
3. Write with `wit_work_item_write` `update` on the Suite ID:
   - `{ op: "test", path: "/rev", value: <Suite System.Rev from step 1> }`
   - `{ op: "replace", path: "/fields/System.Description", value: <new Description> }`
     (use `op: "add"` when the Description was empty)
4. If the `test /rev` fails, someone changed the Suite meanwhile.
   Repeat steps 1–3 once. If it fails again, treat it as a
   write failure.
5. Read the Suite again and confirm the marker shows the new
   `rev`. If not, treat it as a write failure.

`rev` to write:

- `create-test-cases`: `startRev`, the User Story `System.Rev`
  read before generating Test Cases.
- `update-test-cases`: `targetRev`, the User Story `System.Rev`
  the diff was built against.

Never write the latest Revision when the sync was built on an
earlier one.

---

## Write failure

If the update is refused (no permission, the Suite type does not
allow the field, the tool does not support it) or the marker
cannot be confirmed:

- Do not retry with another storage place.
- Do not write a Discussion comment, tag, or link instead.
- Report: `סימון סנכרון: לא נשמר — הסנכרון לא סומן כהושלם`
  with the Azure error text.
- Test Case writes that already succeeded stay as they are.
  The next run detects them and does not duplicate them.

---

## Verify before marking

Before writing the marker, read Azure again and confirm:

- every Test Case that should exist exists, is in the Suite
  (`testplan` `list_cases`), and has a `Related` link to the
  User Story (User Story `expand: Relations`)
- every planned Steps or Title update shows the new value
- every planned `Removed` Test Case is `Removed`

If any check fails, do not write the marker. Report what is
missing.

---

## Resume after a partial failure

The marker is not advanced after a partial failure, so the next
run compares from the same `storedRev` and plans the same work.

Before each write, check whether it already happened.
Azure is the source of truth. There is no local state file.

| Planned write | Already done when | Then |
| --- | --- | --- |
| Create Test Case | a matching Test Case exists (see below) | do not create. Complete only the missing Suite add or Related link |
| Add to Suite | the Test Case is in `list_cases` of that Suite | skip |
| Related link | the User Story Relations include it | skip |
| Update Steps | current Steps equal the planned Steps after normalization | skip |
| Update Title | current Title equals the planned Title | skip |
| Set `Removed` | State is already `Removed` | skip |
| Marker | marker already shows the planned `rev` | skip |

### Find a Test Case created by an earlier failed run

Search in this order. Stop at the first source that has a match.

1. Related Test Cases of the User Story (State not `Removed`).
2. Test Cases in the Suite (`testplan` `list_cases`).
3. Test Cases that were created but neither linked nor added to
   the Suite. Use `wit_query` `wiql`, once per run, without a
   Title filter, because a rerun may word the Title differently:

```
SELECT [System.Id], [System.Title], [System.CreatedDate]
FROM WorkItems
WHERE [System.TeamProject] = '<project>'
  AND [System.WorkItemType] = 'Test Case'
  AND [System.CreatedBy] = @Me
  AND [System.State] <> 'Removed'
  AND [System.CreatedDate] >= '<ChangedDate of the User Story at storedRev, or at startRev for create>'
```

   Keep only results that have no `Related` link to any
   User Story and are not in this Suite. Read their Title and Steps.

A match is the same normalized Title, or Steps that cover the same
requirement.

- One match: reuse it. Complete the Suite add and the Related link.
- Several matches: stop and ask. Do not reuse any of them, and do
  not create another one.
- No match: create the Test Case.

Report every reused Test Case as `הושלם מהרצה קודמת`.

---

## User Story changed during the sync

At the end, before writing the marker, read the User Story again.

- Current `System.Rev` equals the Revision the work was based on:
  write that Revision.
- Current `System.Rev` is higher: compare the compared fields
  (`update-test-cases` `references/sync-rules.md`) between the
  Revision the work was based on and the current one.
  - Same: write the Revision the work was based on.
  - Different: still write the Revision the work was based on.
    Report `ה-US השתנה במהלך הסנכרון (rev <base> → <current>) —
    יש להריץ update-test-cases שוב`. The next run picks it up.

---

## Dry Run

Read only. Do not write the marker and do not write anything else.

In the report, show:

- `סימון שמור`: the current marker, or `אין`
- `סימון שהיה נכתב`: the marker line, with
  `Dry Run — לא נכתב`
