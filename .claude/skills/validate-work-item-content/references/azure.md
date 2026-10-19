# Azure DevOps — validate-work-item-content

This file is the Azure config for `validate-work-item-content`.
Keep one `SKILL.md` for the workflow.

Replace the sample organization, skip-project, people, and identity IDs
with your Azure DevOps values. The names and IDs below are fictional
placeholders and will not notify anyone until you replace them.

Organization:
`https://dev.azure.com/<your-org>`

## Allowed projects

Validate work items in every Azure DevOps project in this organization
except the skip-project.

Do not validate work items whose `System.TeamProject` is `Support`.

Known non-skip projects (samples):

- Web App
- Mobile App

If a work item belongs to another non-skip project, still validate it.
Do not skip it only because the project name is not in this list.

## Required fields

Description field reference name:

`System.Description`

Acceptance Criteria field reference name:

`Microsoft.VSTS.Common.AcceptanceCriteria`

A work item type has Acceptance Criteria only when its type metadata
includes that field, or a field whose display name is
`Acceptance Criteria`.

Do not treat `Microsoft.VSTS.TCM.ReproSteps` as Description.

## Acceptance Criteria required creators

Acceptance Criteria is required only when `System.CreatedBy` matches
one of these people **and** the work item type has that field.

| Display name | Identity ID |
| --- | --- |
| Jordan Lee | `123e4567-e89b-12d3-a456-426614174002` |
| Sam Patel | `123e4567-e89b-12d3-a456-426614174003` |

Match `System.CreatedBy` by `displayName` (case-insensitive) or by
identity `id`.

If `CreatedBy` does not match either person, do not require
Acceptance Criteria. Missing Acceptance Criteria is then not
missing data.

Do not look up different identities.
Do not guess names. Use the names and IDs above.

## Discussion comment

Post this comment only when required data is missing.

Use `wit_work_item_comment_write` with `action: add` and `format: Html`.

Choose the mention prefix from `System.CreatedBy`, then add only the
English lines that match the missing required fields:

- Description missing → `Description is missing`
- Required Acceptance Criteria missing → `Acceptance Criteria is missing`
- Both required fields missing → both lines, Description first

Do not add `Acceptance Criteria is missing` when Acceptance Criteria
is not required for this creator or this type.

Do not add any other sentence.
Do not add the work item ID.
Do not translate this text.

### Default mentions

Use these mentions when `System.CreatedBy` is `Jordan Lee` or
`Sam Patel`. Always in this order:

`@<Alex Rivera> @<Jordan Lee> @<Sam Patel>`

Use HTML mention tags so Azure DevOps notifies these people.
Use these identity IDs exactly:

| Display name | Identity ID |
| --- | --- |
| Alex Rivera | `123e4567-e89b-12d3-a456-426614174001` |
| Jordan Lee | `123e4567-e89b-12d3-a456-426614174002` |
| Sam Patel | `123e4567-e89b-12d3-a456-426614174003` |

Mention HTML prefix:

```html
<a href="#" data-vss-mention="version:2.0,123e4567-e89b-12d3-a456-426614174001">@Alex Rivera</a> <a href="#" data-vss-mention="version:2.0,123e4567-e89b-12d3-a456-426614174002">@Jordan Lee</a> <a href="#" data-vss-mention="version:2.0,123e4567-e89b-12d3-a456-426614174003">@Sam Patel</a>
```

Full HTML examples:

Description only:

```html
<a href="#" data-vss-mention="version:2.0,123e4567-e89b-12d3-a456-426614174001">@Alex Rivera</a> <a href="#" data-vss-mention="version:2.0,123e4567-e89b-12d3-a456-426614174002">@Jordan Lee</a> <a href="#" data-vss-mention="version:2.0,123e4567-e89b-12d3-a456-426614174003">@Sam Patel</a> Description is missing
```

Acceptance Criteria only:

```html
<a href="#" data-vss-mention="version:2.0,123e4567-e89b-12d3-a456-426614174001">@Alex Rivera</a> <a href="#" data-vss-mention="version:2.0,123e4567-e89b-12d3-a456-426614174002">@Jordan Lee</a> <a href="#" data-vss-mention="version:2.0,123e4567-e89b-12d3-a456-426614174003">@Sam Patel</a> Acceptance Criteria is missing
```

Both missing:

```html
<a href="#" data-vss-mention="version:2.0,123e4567-e89b-12d3-a456-426614174001">@Alex Rivera</a> <a href="#" data-vss-mention="version:2.0,123e4567-e89b-12d3-a456-426614174002">@Jordan Lee</a> <a href="#" data-vss-mention="version:2.0,123e4567-e89b-12d3-a456-426614174003">@Sam Patel</a> Description is missing<br>Acceptance Criteria is missing
```

Do not look up different identities for these three people.
Do not replace a name if lookup fails. Use the IDs above.

### Creator mention

Use this prefix when `System.CreatedBy` is **not** `Jordan Lee`
and **not** `Sam Patel`, and Description is missing.

Mention only the work item creator. Then add `Description is missing`.

Do not mention `Alex Rivera`, `Jordan Lee`, or `Sam Patel`
in this comment.

Build the mention from `System.CreatedBy` on the work item:

- `id` → `data-vss-mention` identity ID
- `displayName` → visible `@Name`

Template:

```html
<a href="#" data-vss-mention="version:2.0,{CreatedBy.id}">@{CreatedBy.displayName}</a> Description is missing
```

Example when the creator is `Dana Cohen` with identity ID
`11111111-1111-1111-1111-111111111111`:

```html
<a href="#" data-vss-mention="version:2.0,11111111-1111-1111-1111-111111111111">@Dana Cohen</a> Description is missing
```

If `CreatedBy.id` is missing, look up the identity with Azure DevOps
MCP `core_get_identity_ids` using the display name or unique name
from `CreatedBy`.

If the identity still cannot be resolved:

- do not post the comment
- record the item as failed

Do not guess an identity ID.
Do not change the creator display name.
