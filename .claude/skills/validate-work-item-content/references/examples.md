# Examples — validate-work-item-content

### One work item, data missing

User:

`בדוק תוכן 12345`

Expected workflow:

1. Read work item `12345`, including Created By
2. Skip if project is the skip-project from `azure.md` (sample: `Support`)
3. Check whether Created By is in the Acceptance Criteria required creators list
4. If yes, check whether the type has Acceptance Criteria
5. If Description or required Acceptance Criteria is empty,
   add the Discussion comment
6. If the creator is anyone else and Description is empty,
   mention that creator and add `Description is missing`
7. Return the Hebrew report with creator, full Description, and
   Acceptance Criteria text
8. Stop

### Other creator, Description missing

User:

`בדוק תוכן 12345`

Created By is not in the Acceptance Criteria required creators list.
Description is empty.

Expected workflow:

1. Read work item `12345`, including Created By
2. Do not require Acceptance Criteria
3. Add a Discussion comment that mentions only the creator
   and `Description is missing`
4. Return the Hebrew report
5. Stop

### Several work items

User:

`בדוק תוכן 12345 12346 12347`

Expected workflow:

1. Read all three work items
2. Validate each one independently
3. Comment only on items with missing required data
4. Always post a new comment on those items
5. Return the Hebrew report with תקין, חסר תוכן, and לא נבדקו
6. Stop
