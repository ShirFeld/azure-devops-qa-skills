# Work item type writing rules

This file is the type config for `add-item`.
Keep one `SKILL.md` for the workflow. Put type differences here.
Read only the matching type section after the type is known.

---

## Bug

Azure `workItemType`:
`Bug`

Title format:
`[אזור/מסך]: [התקלה]`

HTML field:
`Microsoft.VSTS.TCM.ReproSteps`

Also set:

- `Microsoft.VSTS.Common.Priority`
- `Microsoft.VSTS.Common.Severity`

### Template

Number the steps with `1.` `2.` `3.` and `<br />`.
Do not use `<ul>`, `<li>`, or bullet points.

After `<b>באג:</b>`, insert `<br />`, then write one short
professional QA sentence on the next line. After that sentence,
insert another `<br />` so there is a blank line before תוצאה רצויה.

```html
<div dir="rtl">
  <b>שחזור:</b><br />
  1. ...<br />
  2. ...<br />
  <br />
  <b>באג:</b><br />
  ...<br />
  <br />
  <b>תוצאה רצויה:</b> ...
</div>
```

If System Info is included, place it after תוצאה רצויה,
still inside the same `div`.

#### שחזור

Always start from the beginning: open the environment, then log in,
then the user's steps.

Read [login.md](login.md) and put its mandatory first steps at the
start of שחזור. Pick the mobile or web URL from that file.

Rewrite the rest into numbered steps. One action per step.

If the user mentioned a starting state after login, write it after
the mandatory login steps. Do not replace those login steps with a
short precondition.

If the bug is on the login screen, keep only the Navigate step from
`login.md`. Do not add the log-in step.

If the user said the defect happens for any values, state that
explicitly in the relevant step.

If the user did not provide enough information for detailed steps,
use only the steps that are known after the mandatory login steps.
Still write those steps in professional QA language.

#### באג

One short professional QA sentence stating what is broken.

Example: `לחיצה על כפתור חישוב אינה מפיקה תוצאה.`

Do not write a long description.
Do not invent product behavior the user did not state.

#### תוצאה רצויה

Describe the desired working behavior implied by the report,
in a complete QA sentence.

Do not invent additional expected behavior.

#### Writing example

User input:

> יוזר מתחבר, מכניס נתונים במחשבון ימי חופשה, לוחץ חישוב ולא קורה חישוב

Bug fields:

- Title: `מחשבון ימי חופשה: לחיצה על חישוב אינה מפיקה תוצאה לאחר התחברות`
- שחזור:
  1. נווט אל https://app.example.com/
  2. הזן פרטי משתמש תקינים והתחבר.
  3. נווט למחשבון ימי חופשה.
  4. הזן נתונים במחשבון (התקלה מתרחשת לכל ערך שמוזן).
  5. לחץ על כפתור חישוב.
- באג:
  לחיצה על כפתור חישוב אינה מפיקה תוצאה.

- תוצאה רצויה: לאחר הזנת הנתונים ולחיצה על כפתור החישוב, המערכת מבצעת את החישוב ומציגה את התוצאה.

### Skip template

If the user asked not to use the template, put their text in
`Microsoft.VSTS.TCM.ReproSteps` inside `<div dir="rtl">`.
Do not add שחזור / באג / תוצאה רצויה headings.
Do not add the mandatory login steps from `login.md`.

After a successful image attach, append `<img src="URL" />` after all
text in ReproSteps.

---

## Top Level Task

Azure `workItemType`:
`Top Level Task`

Title format:
`[אזור/מסך]: [המשימה]`

HTML field:
`System.Description`

Do not set Priority or Severity. Those fields are not on this type.

Do not use the Bug שחזור template.

Write the requested work as professional QA Hebrew in Description.

```html
<div dir="rtl">
  ...
</div>
```

If System Info is included, place it after the description text,
still inside the same `div`.

### Skip template

If the user asked not to use the template, put their text in
`System.Description` inside `<div dir="rtl">`.

After a successful image attach, append `<img src="URL" />` after all
text in Description.

---

## User Story

Azure `workItemType`:
`User Story`

Title format:
`[אזור/מסך]: [היכולת]`

HTML fields:

- `System.Description`
- `Microsoft.VSTS.Common.AcceptanceCriteria`

Also set:

- `Microsoft.VSTS.Common.Priority`

Do not set Severity.

Do not set `Custom.Version` or `Microsoft.VSTS.Scheduling.StoryPoints`
unless the user explicitly provided those values.

### Description

Describe the capability the user will have, in professional QA Hebrew.

```html
<div dir="rtl">
  ...
</div>
```

If System Info is included, place it after the description text,
still inside the same `div`.

### Acceptance Criteria

Write testable criteria implied by the request.
Use numbered items with `1.` `2.` `3.` and `<br />`.
Do not use `<ul>`, `<li>`, or bullet points.

```html
<div dir="rtl">
  1. ...<br />
  2. ...
</div>
```

Do not leave Acceptance Criteria empty.
`create-test-cases` reads Description and Acceptance Criteria.

Do not invent criteria the user did not state or directly imply.

### Skip template

If the user asked not to use the template, put their text in
`System.Description` inside `<div dir="rtl">`.
Still write at least one short Acceptance Criterion from what they
asked for. Do not leave Acceptance Criteria empty.

After a successful image attach, append `<img src="URL" />` after all
text in Description. Do not put images in Acceptance Criteria.
