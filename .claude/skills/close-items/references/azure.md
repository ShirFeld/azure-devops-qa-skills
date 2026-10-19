# Azure DevOps — close-items

This file is the project config for `close-items`.
Keep one `SKILL.md` for the workflow.
Configured product projects are the source. The support project is
the close target.
Do not copy this skill per Azure product project.

Replace the sample organization, projects, types, and field names
with your Azure DevOps values. The names below are fictional.

Organization:
`https://dev.azure.com/<your-org>`

Do not change configured names at runtime. They must match Azure DevOps.

## Source projects

These projects are the source. Never update their work items.
This skill only reads them to find linked support items.

- Web App
- Mobile App

Work item types:
Bug, User Story

Version field display name:
Version

Version field reference name:
`Custom.Version`

Example value:
`1.31.0`

The source may be:

1. Version mode: every Bug / User Story in **all** source projects
   whose `Custom.Version` equals the requested version.
2. One work item ID. Do not require `Custom.Version` on that item.

## Support (targets to close)

Project:
Support

Close only:

1. Work item type `Customer Complaint` (Azure name, not `CUSTOMER COMPLAINT`).
2. Items whose title contains `[Feedback]` (this marker is not a work item type). Those are usually `BugReported`, `Feedback`, or `FeatureRequest`.

Change the title marker if your support intake uses a different label.

Link type from a source project to Support:
`System.LinkTypes.Related`

Version mode: do not close a Support item when it is linked to a source
project Bug or User Story whose `Custom.Version` is missing or different
from the requested version, even if another linked source item matches.

Item ID mode: do not close a Support item when it is also linked to a
source project Bug or User Story other than the given source item, even
if the source item has no Version.

## Close states

Prefer `Closed` when that state exists on the type. Otherwise `Completed`.

| Type               | Close state |
| ------------------ | ----------- |
| Customer Complaint | Closed      |
| BugReported        | Completed   |
| Feedback           | Completed   |
| FeatureRequest     | Completed   |

Skip items already in `Closed`, `Completed`, or `Rejected`.

In both modes: never update source project work items, never create or
delete work items, update only eligible Support items, and update each
Support item at most once.
