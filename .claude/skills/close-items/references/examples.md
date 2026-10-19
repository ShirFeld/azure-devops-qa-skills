# Examples — close-items

### Version mode

User:

`סגור את האייטמים של גרסה 1.31.0`

Expected workflow:

1. Version = `1.31.0`
2. Find Bugs / User Stories in every configured source project
   where `Custom.Version = 1.31.0`
3. Find their related Support items
4. Keep only items that match `references/azure.md`:
   - `Customer Complaint`
   - or items whose title contains `[Feedback]`
5. For every candidate, inspect all linked source-project Bugs / User Stories
6. Skip if any linked source item has another Version or missing Version
7. Skip if already `Closed`, `Completed`, or `Rejected`
8. `Customer Complaint` → `Closed`
9. `[Feedback]` items → `Completed`
10. Update eligible Support items using Azure DevOps MCP
11. Return Hebrew summary with per-project source counts, IDs, and URLs
12. Stop

### Item ID mode

User:

`סגור את האייטמים של 12345`

Expected workflow:

1. Source Work Item ID = `12345`
2. Read that work item. Do not require Version. Do not update it.
3. Find its related Support items
4. Keep only items that match `references/azure.md`:
   - `Customer Complaint`
   - or items whose title contains `[Feedback]`
5. For every candidate, inspect all linked source-project Bugs / User Stories
6. Skip if linked to any source-project Bug / User Story other than `12345`
7. Skip if already `Closed`, `Completed`, or `Rejected`
8. `Customer Complaint` → `Closed`
9. `[Feedback]` items → `Completed`
10. Update eligible Support items using Azure DevOps MCP
11. Return Hebrew summary with source ID, IDs, and URLs
12. Stop
