---
name: release
description: Bump the app version (SemVer, plus a build number where the stores need one) and add its CHANGELOG.md entry on the current feature branch, so merging the PR releases it. Use when finalizing a PR.
argument-hint: "[major|minor|patch]"
---

Version bump for this branch: $ARGUMENTS (default: choose from the changes).

Every PR merged to `main` is a release: `release.yml` builds as a check and leaves nothing behind — no GitHub Release, no artifact, no Play upload, no tag. The bundle Play receives is built locally and uploaded by hand (`docs/RELEASING.md`). CI (`bash scripts/version.sh check`) fails a PR whose version isn't above the one on `main`, or that has no changelog entry.

1. Stop if on `main`. Run `git fetch origin main --quiet`; the version to beat is `main`'s, which `bash scripts/version.sh check` compares against — there are no release tags. Read the branch's version with `bash scripts/version.sh name` and `build`. If the branch is already above `main`, adjust the level if needed and update its entry rather than bumping twice.
2. Bump `main`'s version per SemVer and reset the lower parts (`1.4.2` → `1.5.0`):
   - `major`: breaks existing users, e.g. data or backups that older versions can't read, or a removed feature.
   - `minor`: new user-facing features or behavior.
   - `patch`: fixes, and changes users don't notice (dependencies, docs, CI, refactors).
   With a build number (`x.y.z+N`), set `N` to `main`'s build number + 1. Update every place the stack keeps the version (`docs/STACK_NOTES.md`).
3. In `CHANGELOG.md`, add `## [x.y.z] - YYYY-MM-DD` right below `## [Unreleased]`, and move anything listed under Unreleased into it. Write it from `git log --oneline origin/main..HEAD`: Added / Changed / Fixed, short, in words a user would use. Say what they can now do, not which class changed.
4. Commit `chore(release): x.y.z` with the message in a file (`git commit -F`), and put the version in the PR title or description.
5. Build the release artifact in the background with `flutter build apk --release`, copy it to `dist/qr-scanner-generator-X.Y.Z.<ext>` (gitignored), check the built version matches, and give the user the path. Rebuild it after any later app change on the branch.
