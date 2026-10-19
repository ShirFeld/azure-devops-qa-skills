# Report template — create-test-cases (Part B)

```
# דוח תרחישי בדיקה

## סיכום
- אייטמים בבקשה: <n>
- נפתחו תרחישים: <n>
- Suite בלבד (Product): <n>
- לא נפתחו: <n>
- נכתבו שאלות פתוחות ב-Discussion: <n>

## נפתחו
### <id> — <title>
- Test Plan: <name> (<id>)
- Suite: <name> (<id>)
- תרחישים שנוצרו:
  - <test case id> — <title>
- סימון סנכרון: [qa-sync] us=<id> rev=<startRev> — נשמר / לא נשמר — נותר כשל חלקי / לא נשמר — הסנכרון לא סומן כהושלם / Dry Run — לא נכתב
- שאלות פתוחות: ממתין לאישור / נכתבו ב-Discussion / אין / Dry Run — לא נכתב / נכשל
- נוסח שאלות: <visible comment text, or "אין">
- URL: <url when available>

## Suite בלבד
### <id> — <title>
- סיבה: Product
- Test Plan: <name> (<id>)
- Suite: <name> (<id>)
- תרחישים: לא נוצרו
- סימון סנכרון: [qa-sync] us=<id> rev=<startRev> — נשמר / לא נשמר — נותר כשל חלקי / לא נשמר — הסנכרון לא סומן כהושלם / Dry Run — לא נכתב
- שאלות פתוחות: ממתין לאישור / נכתבו ב-Discussion / אין / Dry Run — לא נכתב / נכשל
- נוסח שאלות: <visible comment text, or "אין">

## לא נפתחו
### <id> — <title>
- סיבה: חסר תוכן / Removed / קיימים Suite / תרחישים — להריץ update-test-cases / skip-project / לא נמצא / כשל
- פירוט: <what is missing, or the skip/failure detail>
```

Rules for Part B:

- `נפתחו` is only for תקין User Stories whose Iteration contains
  `SPRINT` and that received Test Cases.
- List every created Test Case ID and title under that User Story.
  In Dry Run, list proposed titles and set IDs to
  `Dry Run — לא נוצר`.
- `Suite בלבד` is only for תקין User Stories whose Iteration
  contains `PRODUCT` and that received a Suite without Test Cases.
  Do not list them under `נפתחו`.
- `לא נפתחו` is for every remaining requested ID:
  missing content, Removed, skip-project, not found, or failed.
- A User Story with missing content must appear under `לא נפתחו`
  even if Discussion was written.
- Include Test Plan name and ID, Suite names and IDs, URLs when
  available, and any partial failures from step 12.
- For every item under `נפתחו` or `Suite בלבד`, report
  `שאלות פתוחות` and `נוסח שאלות`.
- In the first turn, if there are candidate questions, set
  `שאלות פתוחות` to `ממתין לאישור` and show the candidate text.
- After the user answers and comments are posted, the written
  text is only the approved, renumbered questions.
  Set `שאלות פתוחות` to `נכתבו ב-Discussion`, or `אין` if
  every candidate for that User Story was rejected.
- In Dry Run, still show the proposed candidate comment text
  and set `שאלות פתוחות` to `Dry Run — לא נכתב`.
  Note that these questions would have been asked for approval.
- If nothing was created, still show Part B with those IDs under
  `לא נפתחו` or `Suite בלבד` as appropriate.
- For every item under `נפתחו` or `Suite בלבד`, report
  `סימון סנכרון`. Show `נשמר` only after the marker was written
  and confirmed. When the User Story changed during the run, add
  `ה-US השתנה במהלך היצירה (rev <a> → <b>) — יש להריץ update-test-cases`.

## Final status line

After the user answers the open-questions ask and the approved
comments are posted (or none are), end the short confirmation
with one line per User Story that received a Suite:

```
<✅ / ⚠️> <id> — <נוצרו <n> תרחישים / Suite בלבד (Product)>. סימון סנכרון: rev <startRev> (<נשמר / לא נשמר>). שאלות פתוחות: <נכתבו <n> ב-Discussion / לא נכתבו (כולן נדחו)>.
```

Use `⚠️` when a write or the marker failed, and say what failed.
