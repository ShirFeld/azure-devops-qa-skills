# Report template — update-test-cases

```
# דוח עדכון תרחישי בדיקה

## סיכום
- אייטמים בבקשה: <n>
- אין שינוי: <n>
- עודכנו: <n>
- לא טופלו: <n>

## אין שינוי
### <id> — <title>
- baseline: <date>
- תרחישים קיימים: <n>
- URL: <url>

## עודכנו
### <id> — <title>
- מה השתנה ב-US: Title / Description / AC / Iteration
- נוספו: <test case id> — <title>
- עודכנו: <test case id> — <title> (כותרת / צעדים)
- הועברו ל-Removed: <test case id> — <title>
- Test Plan: <name> (<id>)
- Suite: <name> (<id>)
- שאלות פתוחות: ממתין לאישור / נכתבו ב-Discussion / אין / Dry Run — לא נכתב / נכשל
- נוסח שאלות: <visible comment text, or "אין">
- URL: <url when available>

## לא טופלו
### <id> — <title>
- סיבה: אין תרחישים קשורים / Removed / Product בלי תרחישים / תוכן דרישות הוסר מאז היצירה / Support / לא נמצא / כשל
- פירוט: <what is missing, or the skip/failure detail>
```

Rules:

- `אין שינוי` is only when related Test Cases exist and the
  compared User Story fields match the baseline.
- `עודכנו` is when this skill added, updated, or Removed at
  least one Test Case, including Dry Run proposals.
- `לא טופלו` is every remaining requested ID.
- If a User Story Title changed, note that the Suite name is
  still the old Title.
- In Dry Run, list proposed Test Case titles and set new IDs to
  `Dry Run — לא נוצר`. Mark updates as `Dry Run — לא עודכן`.
- In the first turn, if there are candidate questions, set
  `שאלות פתוחות` to `ממתין לאישור`.
- After the user answers, set `שאלות פתוחות` to
  `נכתבו ב-Discussion`, or `אין` if every candidate for that
  User Story was rejected.
