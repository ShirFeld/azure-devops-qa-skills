# Report template — update-test-cases

The report must answer one question first: did the User Story
change, and what happened to the Test Cases?

## Rules

- Start with one verdict line per User Story. No summary counts.
- Show only User Stories and lines that have content.
  Never write an empty heading or a line whose value is `אין`.
- Never use a heading or label that reads like an answer when it is
  a category name (for example, do not write `אין שינוי: 0`).
- Write short, plain Hebrew. One fact per line.
- Put every requested ID in the report exactly once.

## Verdict lines

Use the line that matches the internal category from `SKILL.md`:

| Internal category | Verdict line |
| --- | --- |
| `אין שינוי` | `⚪ <id> — ה-US לא השתנה מאז הסנכרון האחרון. לא שונה דבר.` |
| `עודכנו`, with Test Case writes | `✅ <id> — ה-US השתנה. <n> תרחישים עודכנו / נוספו / הוסרו.` |
| `עודכנו`, no Test Case write needed | `✅ <id> — ה-US השתנה. התרחישים הקיימים עדיין מתאימים, לא נדרש עדכון.` |
| `עודכנו`, partial failure | `⚠️ <id> — ה-US השתנה. העדכון הושלם חלקית — ראו כשלים.` |
| `ללא נקודת התחלה` | `❓ <id> — אין סימון סנכרון לתרחישים הקיימים. צריך את אישורך לפני עדכון.` |
| `לא טופלו` | `⛔ <id> — לא טופל: <reason in plain words>.` |

In Dry Run, add `(Dry Run — לא נכתב דבר)` at the end of the verdict.

## Structure

```
# דוח עדכון תרחישי בדיקה

<verdict line for each User Story, in the user's order>

## <id> — <title>
- מה השתנה ב-US: <plain description of the change>
- עודכנו: <test case id> — <title> — <what changed in it>
- נוספו: <test case id> — <title>
- הוסרו (Removed): <test case id> — <title>
- הושלמו מהרצה קודמת: <test case id> — <title> (<what was completed>)
- לא נוצר: <what was not covered and why>
- ללא שינוי: <test case ids>
- Revision: <storedRev> → <targetRev> (<נשמר / לא נשמר — reason>)
- כשלים: <failed write and Azure error>
- הערה: <US changed during sync — run again, or Suite name is still the old Title>
- Test Plan: <name> (<id>) · Suite: <name> (<id>)
- URL: <url>
```

Write a `## <id> — <title>` block only for User Stories under
`עודכנו` or `ללא נקודת התחלה`. For `אין שינוי` and `לא טופלו`,
the verdict line is enough. Add one `- פירוט:` line under the
verdict only when the reason needs more detail.

Omit any line in the block that has nothing to report.

### `ללא נקודת התחלה` block

```
## <id> — <title>
- נבדק מול: rev <targetRev>
- מכוסות: <requirements>
- חסרות: <requirements>
- לא תואמים: <test case id> — <title>
- פעולות מוצעות: <one per line>
- סימון שייכתב אחרי אישור: [qa-sync] us=<id> rev=<targetRev>
```

### Open questions

Do not put open questions in the report blocks. After the report,
use the approval prompt from `SKILL.md` step 13.

If the user still has unanswered questions from an earlier run on
the same User Story, add one line at the end of the report:
`יש עדיין <n> שאלות מהרצה קודמת שממתינות לתשובה.`

### Dry Run

- New Test Cases: `נוספו: Dry Run — לא נוצר — <title>`
- Updates: `עודכנו: Dry Run — לא עודכן — <id> — <title>`
- Revision line: `Revision: <storedRev> → <targetRev> (Dry Run — לא נשמר)`

## Example

```
# דוח עדכון תרחישי בדיקה

✅ 12345 — ה-US השתנה. תרחיש אחד עודכן.

## 12345 — טופס הזמנה
- מה השתנה ב-US: נוספה אפשרות "משלוח מהיר" לרשימת האפשרויות, בלי פירוט עלות
- עודכנו: 12350 — אפשרויות משלוח — בודק עכשיו 5 אפשרויות במקום 4
- לא נוצר: תרחיש למשלוח מהיר — לא כתוב ב-US מה העלות (שאלה 1)
- ללא שינוי: 12351–12358
- Revision: 3 → 5 (נשמר)
- Test Plan: אפשרויות משלוח (12347) · Suite: טופס הזמנה (12349)
```

## Final status line

After the user answers the open-questions ask and the approved
comments are posted (or none are), end the short confirmation
with the verdict line for each User Story, extended with the
Revision and the questions result:

```
✅ <id> — ה-US השתנה. <n> תרחישים עודכנו / נוספו / הוסרו (<ids>). Revision: <storedRev> → <targetRev> (<נשמר / לא נשמר>). שאלות פתוחות: <נכתבו <n> ב-Discussion / לא נכתבו (כולן נדחו)>.
```

Use the matching verdict symbol and wording from "Verdict lines".
