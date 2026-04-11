#!/usr/bin/env bats

setup() {
  source "${BATS_TEST_DIRNAME}/../bin/wt"

  TEST_TMP_DIR="$(mktemp -d)"
  export WT_BASE_DIR="$TEST_TMP_DIR/worktrees"
  mkdir -p "$WT_BASE_DIR"

  MAIN_REPO="$TEST_TMP_DIR/main_repo"
  mkdir -p "$MAIN_REPO"
  cd "$MAIN_REPO"

  # Configure git for tests to avoid warnings
  git init -q -b main
  git config user.name "Test User"
  git config user.email "test@example.com"
  git commit -q --allow-empty -m "initial"
}

teardown() {
  rm -rf "$TEST_TMP_DIR"
}

@test "create_worktree simply echoes the path if directory already exists" {
  mkdir -p "$WT_BASE_DIR/existing-dir"

  run create_worktree "existing-dir"
  [ "$status" -eq 0 ]
  [ "${lines[-1]}" = "$WT_BASE_DIR/existing-dir" ]
}

@test "create_worktree creates a new branch and worktree if branch does not exist" {
  run create_worktree "new-feature"
  [ "$status" -eq 0 ]
  [ "${lines[-1]}" = "$WT_BASE_DIR/new-feature" ]

  # Verify side effects
  [ -d "$WT_BASE_DIR/new-feature" ]

  # Verify the new branch exists in the main repo
  git show-ref --verify --quiet "refs/heads/new-feature"

  # Verify it's a git repository (worktree)
  cd "$WT_BASE_DIR/new-feature"
  [ "$(git rev-parse --is-inside-work-tree)" = "true" ]
}

@test "create_worktree checks out an existing branch if it already exists" {
  # Create a branch first
  git branch "existing-branch"

  run create_worktree "existing-branch"
  [ "$status" -eq 0 ]
  [ "${lines[-1]}" = "$WT_BASE_DIR/existing-branch" ]

  # Verify side effects
  [ -d "$WT_BASE_DIR/existing-branch" ]

  cd "$WT_BASE_DIR/existing-branch"
  [ "$(git branch --show-current)" = "existing-branch" ]
}

@test "create_worktree creates a new branch from a start_point if provided" {
  # Create a commit to start from
  git checkout -q -b base-branch
  git commit -q --allow-empty -m "base commit"
  local start_commit="$(git rev-parse HEAD)"

  # Go back to main
  git checkout -q main

  run create_worktree "feature-from-base" "base-branch"
  [ "$status" -eq 0 ]
  [ "${lines[-1]}" = "$WT_BASE_DIR/feature-from-base" ]

  # Verify side effects
  [ -d "$WT_BASE_DIR/feature-from-base" ]

  cd "$WT_BASE_DIR/feature-from-base"
  [ "$(git branch --show-current)" = "feature-from-base" ]
  [ "$(git rev-parse HEAD)" = "$start_commit" ]
}
