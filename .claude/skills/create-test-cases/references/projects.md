# Azure DevOps Test Plan Projects

This file is the project config for `create-test-cases` and
`update-test-cases`.
Keep one `SKILL.md` for each workflow. Put Azure project differences here.
Read only the matching project section.

Replace the sample project names with your Azure DevOps projects.
The names below are fictional.

## Rules

- Use the configuration for the requested project exactly.
- Never reuse a Test Plan from another project.
- Never guess missing configuration.
- If anything is unclear, stop and ask the user.
- Determine the project from the User Story Area Path /
  Team Project.
- Create Test Cases in the same project as the User Story.
- If Test Plan is not configured, stop before creating
  anything and ask the user.

---

## Suite creation

Applies to all projects in this file.

- Do not place the new Suite under an existing child Suite.
- There is no configured Parent Suite.
- Create a new Suite for every User Story whose State is
  not `Removed`.
- Do not create a Suite for a User Story whose State is
  `Removed`.
- Name the Suite using the User Story Title exactly as it
  appears in Azure DevOps.
- Create the new Suite directly under the Test Plan root.
- Do not nest the Suite under an existing feature or screen Suite.
- If the user explicitly names a Parent Suite, use that instead.

---

## Test Plan creation

- One User Story: create one Test Plan and one Suite,
  unless State is `Removed`. Then create nothing.
- Several related User Stories on the same topic:
  create one Test Plan and one Suite per User Story
  that is not `Removed`.
- Name the Test Plan with a short general Hebrew name
  based on the first User Story.

---

## Web App

Project:
Web App

Test Plan:
None. Create a new Test plan for the User Story.

Parent Suite:
None. Create a new Suite for the User Story.

Language:
Hebrew

---

## Mobile App

Project:
Mobile App

Test Plan:
None. Create a new Test plan for the User Story.

Parent Suite:
None. Create a new Suite for the User Story.

Language:
Hebrew
