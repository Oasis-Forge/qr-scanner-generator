#!/usr/bin/env bash
# One version tool for CI, the release workflow, and /release.
#
#   scripts/version.sh name    print x.y.z
#   scripts/version.sh build   print the build number N (0 when there is none)
#   scripts/version.sh check   pass when the version stands still; when it is
#                              raised, fail unless it is above the base
#                              branch's and CHANGELOG.md has a
#                              "## [x.y.z] - YYYY-MM-DD" entry for it
#   scripts/version.sh changed print true when the version differs from the
#                              base branch's, false when it stands still
#   scripts/version.sh notes   print the CHANGELOG.md entry for the current version
#
# The version lives in the first file found of pubspec.yaml (x.y.z+N),
# package.json ("version": "x.y.z"), or VERSION (x.y.z or x.y.z+N).
# Set VERSION_FILE to choose one explicitly.
set -euo pipefail

fail() { echo "::error::$1" >&2; exit 1; }

version_file() {
  if [ -n "${VERSION_FILE:-}" ]; then echo "$VERSION_FILE"; return; fi
  for f in pubspec.yaml package.json VERSION; do
    if [ -f "$f" ]; then echo "$f"; return; fi
  done
  fail "no pubspec.yaml, package.json, or VERSION file found"
}

# Reads a version file's content on stdin and prints "x.y.z N".
parse() {
  case "$(basename "$1")" in
    pubspec.yaml) sed -nE 's/^version: *([0-9]+\.[0-9]+\.[0-9]+)\+([0-9]+)[[:space:]]*$/\1 \2/p' ;;
    package.json) sed -nE 's/^[[:space:]]*"version": *"([0-9]+\.[0-9]+\.[0-9]+)".*$/\1 0/p' | head -n 1 ;;
    *) sed -nE 's/^([0-9]+\.[0-9]+\.[0-9]+)(\+([0-9]+))?[[:space:]]*$/\1 \3/p' | head -n 1 ;;
  esac
}

changelog_entry() {
  awk -v heading="## [$1] - " '
    index($0, heading) == 1 { found = 1; next }
    found && /^## \[/ { exit }
    found { print }
    END { exit !found }
  ' CHANGELOG.md
}

# The version already on the trunk, which is what a PR has to rise above, or
# empty when there is no baseline yet. Release tags are not used: this repo
# publishes nothing from CI and carries none (decided 2026-09-21,
# docs/RELEASING.md). VERSION_BASE_BRANCH names another trunk.
#
# An origin that is configured but unreachable is an error worth naming: a
# silent pass would skip the gate exactly when the network is the problem.
base_branch_version() {
  local branch=${VERSION_BASE_BRANCH:-main}
  local ref="refs/remotes/origin/$branch"
  local heads status
  if ! git remote get-url origin > /dev/null 2>&1; then
    echo "No origin remote yet, so there is nothing to compare against." >&2
    return 0
  fi

  # Reachable and the branch exists? 0. Reachable and it doesn't? 2, and there
  # is simply no baseline. Anything else is the network, and has to be said.
  status=0
  heads=$(git ls-remote --exit-code --heads origin "$branch" 2>&1) || status=$?
  case "$status" in
    0) ;;
    2) echo "origin has no $branch yet, so there is nothing to compare against." >&2
       return 0 ;;
    *) fail "can't reach origin to read $branch's version: $(printf '%s' "$heads" | head -n 1)" ;;
  esac

  if ! git rev-parse --verify --quiet "$ref" > /dev/null; then
    # --depth=1 is a property of the fetch, not of the refspec: against a full
    # local clone it writes .git/shallow and truncates the repository silently.
    # CI is already shallow, which is the only case that wants it.
    if [ "$(git rev-parse --is-shallow-repository)" = "true" ]; then
      git fetch --quiet --depth=1 origin "+refs/heads/$branch:$ref"
    else
      git fetch --quiet origin "+refs/heads/$branch:$ref"
    fi
  fi

  if [ "$(git rev-parse HEAD)" = "$(git rev-parse "$ref")" ]; then
    # On the trunk itself — the merge build — compare against the commit
    # before the merge. Two PRs opened together both pass the gate against the
    # same main; the first merge moves it, and without this the second would
    # ship as part of no release, leaving main's code unreleased and the
    # bundle older than its own changelog. Needs fetch-depth 2 in CI; with a
    # depth-1 checkout there is no previous commit and the check is skipped
    # rather than guessed at.
    git rev-parse --verify --quiet HEAD~1 > /dev/null || return 0
    git show "HEAD~1:$file" 2>/dev/null | parse "$file"
    return 0
  fi
  git show "$ref:$file" 2>/dev/null | parse "$file"
}

file=$(version_file)
read -r name build < <(parse "$file" < "$file") || true
[ -n "${name:-}" ] || fail "$file: the version must look like x.y.z (x.y.z+N in pubspec.yaml)"
build=${build:-0}

case "${1:-}" in
  name) echo "$name" ;;
  build) echo "$build" ;;
  notes) changelog_entry "$name" || fail "CHANGELOG.md has no '## [$name] - ' entry" ;;
  check)
    base_branch=${VERSION_BASE_BRANCH:-main}
    last_name=
    last_build=0
    # Command substitution, not `< <(…)`: a process substitution runs in a
    # subshell whose exit status the script never sees, so `fail` inside the
    # helper would print its annotation and then be ignored. Assigning lets
    # set -e stop the script, which is the whole point of naming the error.
    baseline=$(base_branch_version)
    read -r last_name last_build <<< "$baseline" || true
    last_build=${last_build:-0}

    if [ -n "$last_name" ]; then
      highest=$(printf '%s\n%s\n' "$last_name" "$name" | sort -V | tail -n 1)
      if [ "$highest" != "$name" ]; then
        fail "$base_branch is on $last_name: this branch went back to $name"
      fi
      # Not every branch is a release (decided 2026-09-21). The user decides
      # when to cut one; until then the version stands still, and standing
      # still is not an error. A version that moves is still checked in full,
      # including a build number raised on its own — Play refuses an upload
      # whose build number it has already seen, even under the same x.y.z.
      if [ "$name" = "$last_name" ] && [ "$build" = "$last_build" ]; then
        echo "No release here: still $name+$build, the same as $base_branch."
        exit 0
      fi
      if [ "$build" != 0 ] && [ "$build" -le "$last_build" ]; then
        fail "$base_branch was already on build $last_build: raise the build number above it"
      fi
    fi
    changelog_entry "$name" > /dev/null || fail "CHANGELOG.md needs a '## [$name] - YYYY-MM-DD' entry"
    echo "Releasing $name+$build (was ${last_name:-nothing yet})."
    ;;
  changed)
    read -r changed_name changed_build <<< "$(base_branch_version)" || true
    if [ -z "${changed_name:-}" ] ||
       [ "$name" != "$changed_name" ] ||
       [ "$build" != "${changed_build:-0}" ]; then
      echo true
    else
      echo false
    fi
    ;;
  *) sed -n '4,11p' "$0" >&2; exit 2 ;;
esac
