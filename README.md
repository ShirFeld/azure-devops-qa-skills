# Azure DevOps Skills

Agent skills for Claude Code and Cursor that create Azure DevOps work items, generate and sync test cases, validate required fields, and close linked support items — without opening Azure DevOps by hand.

This repository is a **template**. Sample projects, people, URLs, and identity IDs below are fictional. Replace them with your organization before you use the skills.

**Never commit a PAT, password, or real employee directory.**

---

## What is here

| Skill | What it does | When to use |
| --- | --- | --- |
| **add-item** | Creates a Bug, User Story, or Top Level Task | `add bug` / `תפתחי באג` / `תפתחי user story` |
| **create-test-cases** | Creates a Test Plan, Suite, and Hebrew QA scenarios from a User Story | `write test cases` / `תכתבי תרחישי בדיקה` |
| **update-test-cases** | Syncs existing test cases when the User Story changed | `update test cases` / `עדכני תרחישים` |
| **validate-work-item-content** | Checks Description (and Acceptance Criteria when configured) and comments when missing | `validate work item` / `בדקי אייטם` |
| **close-items** | Closes linked support items for a release version or a source work item ID | `close items` / `סגרי אייטמים לגרסה 1.31.0` |

---

## Prerequisites

- [Claude Code](https://claude.com/claude-code) and/or [Cursor](https://cursor.com)
- [Node.js](https://nodejs.org) (for `npx`, which runs the MCP servers)
- Access to an Azure DevOps organization
- A Personal Access Token (PAT) with Work Items Read & Write (and Test Management if you use the test-case skills)

---

## Setup

1. Clone this repository:

```bash
git clone https://github.com/ShirFeld/azure-devops-qa-skills.git
cd azure-devops-qa-skills
```

2. Set two **user** environment variables on Windows (once), then restart Claude Code / Cursor:

```powershell
[Environment]::SetEnvironmentVariable("ADO_ORG", "<your-org-slug>", "User")
[Environment]::SetEnvironmentVariable("AZURE_DEVOPS_EXT_PAT", "<PAT>", "User")
```

`ADO_ORG` is only the organization name from `https://dev.azure.com/<org>`. The PAT is never stored in this repo. `scripts/start-ado-mcp.ps1` reads both variables and starts the Azure DevOps MCP.

3. Replace the **sample** values in every skill `references/` file with your Azure DevOps projects, teams, area paths, people, and login URLs. Search for `example.com` and `your-org` to find them.

4. MCP servers (`ado`, `playwright`) are defined twice, once per tool:
   - Claude Code — `.mcp.json`
   - Cursor — `.cursor/mcp.json`

   If you change a server in one file, update the other too.

5. Confirm the servers are connected: Claude Code via `/mcp`, Cursor via Settings → MCP.

---

## Usage

After this project is open in Claude Code or Cursor, write in Hebrew or English. The skills load automatically.

### Create a work item

The type is chosen only from explicit wording. If the type is unclear, the agent asks before creating anything.

```
תפתחי באג ב-Web App: אחרי שמירה הדף נתקע על spinner
```

```
תפתחי user story ב-Mobile App: משתמש יכול לאשר דוח לפני שליחה
```

Supported Azure projects are whatever you listed in `add-item/references/projects.md`. If the project is unclear, the agent asks before creating the item.

### Test cases from a User Story

```
תכתבי תרחישי בדיקה ל-US 12345 ב-Mobile App
```

Required: a User Story ID. The project is taken from the User Story Area Path / Team Project.

On a successful create, the skill appends a marker to the Suite Description, for example `[qa-sync] us=12345 rev=14`. That line stores the User Story Revision the Test Cases were generated from. Other Description content is left as is. If a write failed partway, the marker is not written.

### Update test cases when a User Story changed

```
עדכני תרחישים ל-US 12345
```

- **The comparison point is the Revision in the Suite marker**, not the date Test Cases were last changed. A manual Test Case edit, such as Assigned To, does not move the baseline.
- **Compared fields:** Title, Description, Acceptance Criteria, Iteration, and State. A change only to assignee, tags, or Discussion does not update Test Cases.
- **When the marker advances:** only after every write succeeded and was verified. After a partial failure, a later run detects what already exists and finishes only what is missing, without duplicates.
- **Older Test Cases with no marker:** the agent shows an alignment check against the current User Story and asks before setting a starting point.
- **Marker write failure:** if the Suite Description cannot be updated, the report says the sync was not marked complete. The agent does not store the marker somewhere else.
- **Dry Run:** reads only. The marker is not written either.
- **PAT permissions:** finding the Suite and updating its Description needs Test Management and Work Items, read and write.

### Close support items after a release

```
סגרי אייטמים לגרסה 1.31.0
```

Closes only configured support work items that are linked to Bugs or User Stories in the configured source projects for that version. It does not change the source items.

Preview first:

```
dry run לסגירת אייטמים לגרסה 1.31.0
```

---

## Project layout

One skill per action. Azure project differences live in config, not in a copied `SKILL.md`.

```
azure-devops-qa-skills/
├── .claude/
│   └── skills/                           # single source for skills (Claude Code + Cursor)
│       ├── add-item/
│       │   ├── SKILL.md
│       │   ├── references/               # projects, writing rules, login URLs
│       │   └── scripts/                  # attach images after the work item exists
│       ├── create-test-cases/
│       ├── update-test-cases/
│       ├── validate-work-item-content/
│       └── close-items/
├── .cursor/
│   └── mcp.json
├── scripts/
│   └── start-ado-mcp.ps1
├── .mcp.json
├── CLAUDE.md
└── README.md
```

- Skills live only in `.claude/skills/`. Cursor loads them from there. Do not copy them to `.cursor/skills/`.
- **Skill** = what to do (`add-item`, `create-test-cases`, …).
- **Azure project** = where / which fields (your names in `references/`).
- Change Area Path, Iteration, Assigned To, or Test Plan in that project's config section, not by duplicating the skill.

---

## What you must replace

| File | Sample values to replace |
| --- | --- |
| Environment `ADO_ORG` | `your-org` |
| `add-item/references/projects.md` | organization URL, assignee table, project / team / area / iteration |
| `add-item/references/login.md` | app login URLs |
| `create-test-cases/references/projects.md` | project names and test-plan settings |
| `create-test-cases/references/qa-analysis.md` | mention names and Azure identity IDs |
| `validate-work-item-content/references/azure.md` | skip-project, required creators, mention IDs |
| `close-items/references/azure.md` | source projects, support project, types, version field |

Identity IDs in the sample files are **fake placeholders**. Copy real IDs from Azure DevOps only into your private clone, not into a public fork unless you intend them to be public.

---

## Notes

- Do not share PATs, passwords, or tokens.
- Skills talk to Azure DevOps through MCP, not Azure CLI. Exception: the `add-item` scripts that attach images.
- Business rules (projects, assignees, Test Plans) belong in the skill `references/` files.
