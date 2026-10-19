# Azure DevOps Projects

This file is the project config for `add-item`.
Keep one `SKILL.md` for the workflow. Put Azure project differences here.
Read the Allowed assignees section and only the matching project section.

Replace every sample value in this file with your Azure DevOps organization,
projects, and people before using the skill. The names and emails below are
fictional.

Organization:
`https://dev.azure.com/<your-org>`

The organization slug also belongs in the `ADO_ORG` environment variable.
Do not put a PAT in this file.

## Allowed assignees

Default Assigned To for every project is the person named in that project's
Assigned To field (sample: Alex Rivera).
Use another person from this table only when the user explicitly names them.
Use the Email value exactly. Do not look up identities at runtime.

Match case-insensitively on Display name, first name, and Aliases.

| Display name | Email | Aliases |
| --- | --- | --- |
| Alex Rivera | alex.rivera@example.com | alex, עלי, עליי, me |
| Jordan Lee | jordan.lee@example.com | jordan |
| Sam Patel | sam.patel@example.com | sam |

If the named person is not in this table, or the name is ambiguous, stop and ask.
Do not create the work item yet.

## Rules for every project

- Use the Area Path from that project's section exactly. Never change it.
- Use the Iteration Path from that project's section exactly, unless the user
  explicitly asked to put the item on the current sprint.
- Use the Assigned To from that project's section exactly, unless the user
  explicitly named someone from Allowed assignees.
- Never use Azure DevOps default Area Path or Iteration Path.
- Always pass Project explicitly when creating the work item through Azure DevOps MCP.
- Never reuse Area Path or Iteration Path from another project.
- When resolving the current sprint, use that project's Team with
  Azure DevOps MCP `work` `list_team_iterations` and `timeframe: current`.

---

## Web App

Project:
Web App

Team:
Web App Team

Area Path:
Web App\Product

Iteration Path:
Web App\Team Backlog

Assigned To:
alex.rivera@example.com

Default Priority:
2

Default Severity:
3 - Medium

Language:
Hebrew

---

## Mobile App

Project:
Mobile App

Team:
Mobile App Team

Area Path:
Mobile App\Product

Iteration Path:
Mobile App\Team Backlog

Assigned To:
alex.rivera@example.com

Default Priority:
2

Default Severity:
3 - Medium

Language:
Hebrew
