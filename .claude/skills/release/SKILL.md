---
name: release
description: Cut a release on the current feature branch: bump the app version (SemVer, plus a build number where the stores need one), move the Unreleased changelog entries under it, build the bundle, and write the release notes in every language. Use only when the user has asked for a release, not on every PR.
argument-hint: "[major|minor|patch]"
---

Version bump for this branch: $ARGUMENTS (default: choose from the changes).

A release is cut when the user asks for one — **not on every merge** (decided 2026-09-21). Run this skill only when they have asked. Otherwise the change goes under `## [Unreleased]` in `CHANGELOG.md`, the version is left alone, and CI is happy: `bash scripts/version.sh check` passes a branch whose version stands still, and checks it in full only once it moves — above `main`'s, with its changelog entry. `release.yml` builds as a check and leaves nothing behind: no GitHub Release, no artifact, no Play upload, no tag. The bundle Play receives is built locally and uploaded by hand (`docs/RELEASING.md`).

1. Stop if on `main`. Run `git fetch origin main --quiet`; the version to beat is `main`'s, which `bash scripts/version.sh check` compares against — there are no release tags. Read the branch's version with `bash scripts/version.sh name` and `build`. If the branch is already above `main`, adjust the level if needed and update its entry rather than bumping twice.
2. Bump `main`'s version per SemVer and reset the lower parts (`1.4.2` → `1.5.0`):
   - `major`: breaks existing users, e.g. data or backups that older versions can't read, or a removed feature.
   - `minor`: new user-facing features or behavior.
   - `patch`: fixes, and changes users don't notice (dependencies, docs, CI, refactors).
   With a build number (`x.y.z+N`), set `N` to `main`'s build number + 1. Update every place the stack keeps the version (`docs/STACK_NOTES.md`).
3. In `CHANGELOG.md`, add `## [x.y.z] - YYYY-MM-DD` right below `## [Unreleased]`, and move anything listed under Unreleased into it. Write it from `git log --oneline origin/main..HEAD`: Added / Changed / Fixed, short, in words a user would use. Say what they can now do, not which class changed.
4. Commit `chore(release): x.y.z` with the message in a file (`git commit -F`), and put the version in the PR title or description.
5. Build the bundle in the background with `flutter build appbundle --release`, copy it to `dist/qr-scanner-generator-X.Y.Z.aab` (gitignored), and give the user the path. Check the built version matches and that `keytool -printcert -jarfile` names the upload key, not `CN=Android Debug`, which Play refuses. Rebuild it after any later app change on the branch.
6. Write the release's notes in all twenty listing languages, so they are ready with the bundle (`docs/RELEASING.md` → Store listing → Release notes). Draft the English from the changelog entry — under 380 characters, or the longer languages pass Play's 500-character limit — translate the other nineteen, save them as `store/play/source/release-notes/x.y.z.txt`, and run `dart tool/build_release_notes.dart store/play/source/release-notes/x.y.z.txt store/play`. It writes the single tagged block Play's Release notes field takes. A release with nothing a user can see still gets notes about what the build is for, never an invented feature.
