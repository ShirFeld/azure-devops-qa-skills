# Recurring item templates

This file is the template config for `recurring-items`.
Keep one `SKILL.md` for the workflow. Put the template list here.

Replace every sample value with your Azure DevOps organization, project,
team, assignee, template work item IDs, and the text those templates
actually contain. The names, IDs, and dates below are fictional.
When you rename a button, put that label in the `description` of
`SKILL.md` so the skill still triggers on it.

Each template is an existing Top Level Task in Azure DevOps.
The skill reads the template and its Child items live, so a change to
the template's fields or Child items is picked up on the next run.

Organization:
`https://dev.azure.com/<your-org>`

The organization slug also belongs in the `ADO_ORG` environment variable.
Do not put a PAT in this file.

## Buttons

Show the buttons in this order. Keep the order and the labels exactly.

| # | Button label | Template ID | Frequency |
| --- | --- | --- | --- |
| 1 | סקירה חודשית | 10001 | Twice a month |
| 2 | עדכון אמצע חודש | 10002 | Once a month |
| 3 | דיווח תחילת חודש | 10003 | On the 1st of every month |
| 4 | דיווח קצר | 10003 | When only the short report is needed |

Frequency is informational. A manual run never refuses because of
frequency. The duplicate check in `SKILL.md` is the only guard.

## Auto schedule

Auto mode (`/recurring-items auto`) creates only these buttons, once per
calendar month, on or after the given day of the month. Buttons 1 and
4 are manual only.

| # | Button label | Create from day | Already-created check (Title contains) |
| --- | --- | --- | --- |
| 3 | דיווח תחילת חודש | 1 | `דיווח חודשי מלא` |
| 2 | עדכון אמצע חודש | 12 | `עדכון 15 לחודש <current month name>` |

Run the due buttons in this table's order.

## Values for every new item

Use these for the new Top Level Task and every new Child item.

| Field | Value |
| --- | --- |
| Project | `Operations` |
| Team | `Operations Team` |
| `System.AreaPath` | `Operations` |
| `System.AssignedTo` | `alex.rivera@example.com` |
| `System.IterationPath` | The current sprint (see `SKILL.md`) |
| `System.Tags` | `recurring-auto`, in auto mode only |

Do not copy State, Reason, dates, Iteration Path, Assigned To, or Tags
from the template.

## Text replacements

Some templates contain a date or a month name in their text.
Replace it in the new items only. Never edit the template.

Apply each replacement to Title and Description of the new Top Level
Task and of every new Child item, wherever the template text appears.

The strings below are samples. Replace each "Template text" cell with
the exact month name or date written in your template work item.

Month names in Hebrew, by month number:

| 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9 | 10 | 11 | 12 |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| ינואר | פברואר | מרץ | אפריל | מאי | יוני | יולי | אוגוסט | ספטמבר | אוקטובר | נובמבר | דצמבר |

### 1. סקירה חודשית (10001)

No replacements. Copy the text exactly.

### 2. עדכון אמצע חודש (10002)

| Template text | Replace with |
| --- | --- |
| `ספטמבר` | Hebrew name of the current month (today's month) |

Example: a run on 2026-11-12 turns `עדכון 15 לחודש ספטמבר` into
`עדכון 15 לחודש נובמבר`, and `ל-15 בספטמבר` into `ל-15 בנובמבר`.

### 3. דיווח תחילת חודש (10003)

| Template text | Replace with |
| --- | --- |
| `01.09.2026` | The 1st of the current month as `01.MM.YYYY` |

Always use `01`, even when the run happens later in the month.

Example: a run on 2026-11-03 turns `דיווח חודשי מלא נכון ל01.09.2026`
into `דיווח חודשי מלא נכון ל01.11.2026`.

The already-created check for this button is the longer phrase
`דיווח חודשי מלא`, so a short report from button 4 does not count
as this button already created.

### 4. דיווח קצר (10003)

Same template as button 3, without the נספח items. Manual only.

Child filter: skip every template Child item whose Title contains
`נספח`. Copy only the remaining Child items.

| Template text | Replace with |
| --- | --- |
| `01.09.2026` | The 1st of the current month as `01.MM.YYYY` |
| `דיווח חודשי מלא` | `דיווח חודשי` |

Always use `01`, even when the run happens later in the month.

Example: a run on 2026-11-09 turns
`דיווח חודשי מלא נכון ל01.09.2026` into
`דיווח חודשי נכון ל01.11.2026`, and creates only the Child items
whose titles do not contain `נספח` (sample: `דיווח חודשי באתר` and
`דיווח חודשי באפליקציה`).

### When the template text is missing

If a template text listed above does not appear in the template's
Title, the template was probably edited. In manual mode, stop and ask
the user what to replace. In auto mode, do not create that button's
items and report it as a failure. Do not create anything for it yet.
