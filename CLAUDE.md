# azure-devops-qa-skills

QA automations for Azure DevOps, used from both Claude Code and Cursor.

This repository is a **template**. Sample organization, project, people, and URL values in `references/` are fictional. Replace them with your Azure DevOps values before use. Never commit a PAT, token, or real identity data you do not want public.

## Layout rules

- Skills live only in `.claude/skills/`. Cursor loads them from there too. Never create a copy under `.cursor/skills/`.
- One skill per action. Do not copy a skill per Azure project. Per-project data (Area Path, Iteration, Assigned To, Test Plan) goes in the skill's `references/` files.
- MCP servers are defined twice: `.mcp.json` (Claude Code) and `.cursor/mcp.json` (Cursor). Change both together.
- `scripts/start-ado-mcp.ps1` starts the Azure DevOps MCP. It reads the organization from `ADO_ORG` and the PAT from `AZURE_DEVOPS_EXT_PAT`. Never write a PAT to a file.

## Shared files between skills

Editing these changes more than one skill:

- `create-test-cases/references/projects.md`, `test-case-rules.md`, `qa-analysis.md` — also read by `update-test-cases`.
- `validate-work-item-content/SKILL.md`, `references/azure.md`, `references/report-template.md` — `create-test-cases` runs this skill first and reuses its report.

Keep report templates and examples in each skill's `references/`, not in `SKILL.md`. Keep `SKILL.md` around 500 lines or less.

## Git

- Use a separate `feature/...` branch for each change and open a PR to `main`.
- Do not merge, enable auto-merge, or push directly to `main` unless explicitly asked.
