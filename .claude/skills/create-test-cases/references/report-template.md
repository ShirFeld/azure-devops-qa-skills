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
- שאלות פתוחות: ממתין לאישור / נכתבו ב-Discussion / אין / Dry Run — לא נכתב / נכשל
- נוסח שאלות: <visible comment text, or "אין">
- URL: <url when available>

## Suite בלבד
### <id> — <title>
- סיבה: Product
- Test Plan: <name> (<id>)
- Suite: <name> (<id>)
- תרחישים: לא נוצרו
- שאלות פתוחות: ממתין לאישור / נכתבו ב-Discussion / אין / Dry Run — לא נכתב / נכשל
- נוסח שאלות: <visible comment text, or "אין">

## לא נפתחו
### <id> — <title>
- סיבה: חסר תוכן / Removed / Support / לא נמצא / כשל
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
  missing content, Removed, Support, not found, or failed.
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
