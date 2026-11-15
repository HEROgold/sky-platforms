# Docs

Work moves through four item types. Each one is a GitHub issue, opened from the matching form in `.github/ISSUE_TEMPLATE/`.

1. Idea. A player problem or value worth solving.
2. Design. How the feature plays and what it changes from vanilla.
3. Spec. Testable behaviour, data and runtime changes, and migrations.
4. Slice. One player-visible change that ships on its own.

Each item links its parent as a GitHub sub-issue. The Parent field in the form repeats the link, so it reads without the sub-issue view.

Every item answers why. The Why section names the player problem or value and links the evidence.

Every spec and slice answers how it reaches prod. The Path to prod section names the target release, whether a save migration is needed, the in-game test steps, and the changelog line for the mod portal.

A slice is small. If it cannot ship on its own, split it.

Where docs live:

- `docs/design/`: one file per design, copied from `_template.md`.
- `docs/spec/`: one file per spec, copied from `_template.md`.
- Ideas and slices live only as issues.
