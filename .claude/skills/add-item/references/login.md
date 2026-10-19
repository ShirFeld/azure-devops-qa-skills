# Login URLs and first repro steps

This file is the login config for `add-item` Bugs.
Read it when writing Bug Repro Steps.
Do not use it for User Story or Top Level Task.
Do not add these steps when the user asked to skip the template.

Replace the sample URLs with your environments. The URLs below are fictional.

`https://app.example.com/` is the shared web app.
Use it unless the request is clearly mobile.

## Saved URLs

Use only these two URLs unless the user gave a different URL.

| Environment | URL |
| --- | --- |
| Mobile | `https://mobile.example.com/auth/login` |
| Web / platform | `https://app.example.com/` |

If the user gave a different URL, use that URL. Do not replace it.

Do not invent any other URL.

## Which URL to pick

Use **mobile** when any of these is true:

- Azure project is Mobile App
- The user wrote מובייל, mobile, or mobile app

Use **web** otherwise, including:

- Web App
- The user wrote פלטפורמה, web, or app

## Mandatory first steps

Language follows the work item: Hebrew unless the user asked for English.

Do not invent username, password, browser, or device.
"Valid credentials" / "פרטי משתמש תקינים" is enough.

### Hebrew

1. נווט אל `<URL>`
2. הזן פרטי משתמש תקינים והתחבר.

### English

1. Navigate to `<URL>`
2. Enter valid user credentials and log in.

Then continue with the user's repro steps, numbered from 3.

If the user's request already mentions login, still use these two steps.
Do not add a second login step. Rewrite the rest of the flow after login.

## Login-screen exception

If the bug is on the login screen itself, keep only the Navigate step.
Do not add "log in" / "התחבר".
Then continue with the user's remaining steps, numbered from 2.
