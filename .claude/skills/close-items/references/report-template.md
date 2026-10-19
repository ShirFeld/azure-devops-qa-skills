# Summary template — close-items

## Final summary

Summarize in Hebrew.

Include according to mode:

#### Version mode

- `גרסה: <version>`
- `sourceMatched` total
- number of matching Bugs / User Stories per configured source project,
  including `0`

#### Item ID mode

- `אייטם מקור: <id>`
- title, type, project, and URL of the source work item

Then in both modes:

- number of unique Support candidates
- number closed/completed successfully
- number skipped because already closed
- Version mode: number skipped because linked to another Version or missing Version
- Item ID mode: number skipped because linked to another source-project Bug / User Story
- number failed

For successfully updated items include:

- ID
- type
- resulting State
- URL

For `other-source-version` or `other-source-links` skips include:

- Support Work Item ID
- current State
- related source IDs that caused the skip
- URL

For failed items include:

- Support Work Item ID
- error/reason
- URL when available

## Empty Result Behavior

If:

`supportClosed = 0`

and no updates failed:

#### Version mode

`לא נמצאו אייטמי תמיכה פתוחים שניתן לסגור עבור גרסה <version>.`

Also explain whether:

- no Support items were linked
- all candidates were already closed
- or all candidates were skipped because of another/missing source Version

Include the per-project source counts.

#### Item ID mode

`לא נמצאו אייטמי תמיכה פתוחים שניתן לסגור עבור אייטם <id>.`

Also explain whether:

- no Support items were linked
- all candidates were already closed
- or all candidates were skipped because they were also linked to another
  source-project Bug / User Story
