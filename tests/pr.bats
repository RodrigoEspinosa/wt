#!/usr/bin/env bats

setup() {
  source "${BATS_TEST_DIRNAME}/../bin/wt"

  TEST_TMP_DIR="$(mktemp -d)"
  export WT_BASE_DIR="$TEST_TMP_DIR/worktrees"
  mkdir -p "$WT_BASE_DIR"

  # Don't let a real gh on the host reach the network during tests.
  export PATH="$TEST_TMP_DIR/bin:$PATH"
  mkdir -p "$TEST_TMP_DIR/bin"
  printf '#!/bin/sh\nexit 1\n' > "$TEST_TMP_DIR/bin/gh"
  chmod +x "$TEST_TMP_DIR/bin/gh"

  ORIGIN="$TEST_TMP_DIR/origin.git"
  git init -q --bare "$ORIGIN"

  MAIN_REPO="$TEST_TMP_DIR/main_repo"
  mkdir -p "$MAIN_REPO"
  cd "$MAIN_REPO"

  git init -q -b main
  git config user.name "Test User"
  git config user.email "test@example.com"
  git commit -q --allow-empty -m "initial"
  git remote add origin "$ORIGIN"
  git push -q origin main

  # Build a commit and expose it as a GitHub-style pull ref on the remote.
  git checkout -q -b pr-source
  git commit -q --allow-empty -m "pr work"
  PR_SHA="$(git rev-parse HEAD)"
  git push -q origin pr-source           # push the object to the remote first
  git -C "$ORIGIN" update-ref refs/pull/7/head "$PR_SHA"
  git push -q origin --delete pr-source  # leave only the pull ref behind
  git checkout -q main
  git branch -q -D pr-source
}

teardown() {
  rm -rf "$TEST_TMP_DIR"
}

@test "pr_worktree rejects a non-numeric argument" {
  run pr_worktree "abc"
  [ "$status" -eq 1 ]
  [[ "$output" == *"invalid PR number"* ]]
}

@test "pr_worktree rejects a missing argument" {
  run pr_worktree ""
  [ "$status" -eq 1 ]
  [[ "$output" == *"pr <number>"* ]]
}

@test "pr_worktree fetches the pull ref into a new worktree" {
  run pr_worktree "7"
  [ "$status" -eq 0 ]
  [ "${lines[${#lines[@]}-1]}" = "$WT_BASE_DIR/pr-7" ]

  [ -d "$WT_BASE_DIR/pr-7" ]
  [ "$(git rev-parse HEAD)" != "$(git -C "$WT_BASE_DIR/pr-7" rev-parse HEAD)" ]
  [ "$(git -C "$WT_BASE_DIR/pr-7" log -1 --pretty=%s)" = "pr work" ]
  git show-ref --verify --quiet "refs/heads/pr-7"
}

@test "pr_worktree returns the existing worktree path without refetching" {
  create_worktree "pr-7" > /dev/null

  run pr_worktree "7"
  [ "$status" -eq 0 ]
  # Existing worktree is returned directly — no fetch, path ends in /pr-7
  [[ "$output" != *"fetching"* ]]
  [[ "${lines[${#lines[@]}-1]}" == */pr-7 ]]
  [ -d "${lines[${#lines[@]}-1]}" ]
}
