# Report template — validate-work-item-content

Also used by `create-test-cases` (Part A of its combined reply).

Use this structure and these headings:

```
# דוח תוכן אייטמים

## סיכום
- נבדקו: <n>
- תקינים: <n>
- חסר תוכן: <n>
- נכתב Discussion: <n>
- דולגו (Support): <n>
- לא נמצאו: <n>
- נכשלו: <n>

## תקין
### <id> — <title>
- סוג: <type>
- פרויקט: <project>
- יוצר: <Created By display name>
- URL: <url>
- Description: <full text, or "אין שדה" if the type has none>
- Acceptance Criteria: <full text, "לא נדרש ליוצר זה", or "לא נדרש לסוג זה">

## חסר תוכן
### <id> — <title>
- סוג: <type>
- פרויקט: <project>
- יוצר: <Created By display name>
- URL: <url>
- Description: <full text, or "חסר">
- Acceptance Criteria: <full text, "חסר", "לא נדרש ליוצר זה", or "לא נדרש לסוג זה">
- מה חסר: Description / Acceptance Criteria / שניהם
- Discussion: נכתב / Dry Run — לא נכתב / נכשל
- נוסח שנכתב או שהיה נכתב: <visible comment text>

## לא נבדקו
### <id>
- סיבה: Support / לא נמצא / כשל
- פרטי שגיאה אם יש
```

Rules for the report:

- Put every requested ID in exactly one section.
- For תקין, show the full Description and Acceptance Criteria
  text, not a yes/no flag.
- Strip HTML tags only for readability. Keep the visible text.
- Show the Created By display name on every checked item.
- If Acceptance Criteria has visible text, show that text even when
  the field is not required.
- If a valid item has no Acceptance Criteria field on its type,
  write `לא נדרש לסוג זה`.
- If Acceptance Criteria is not required because of the creator and
  the field is empty, write `לא נדרש ליוצר זה`.
- For חסר תוכן, still show any field that does have text.
- If a required field is empty, write `חסר`.
- In Dry Run, still build the full report. Set Discussion to
  `Dry Run — לא נכתב`.
- If a section has no items, write `אין`.
- Do not omit field content because it is long.
