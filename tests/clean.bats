#!/usr/bin/env bats

setup() {
  source "${BATS_TEST_DIRNAME}/../bin/wt"

  TEST_TMP_DIR="$(mktemp -d)"
  export WT_BASE_DIR="$TEST_TMP_DIR/worktrees"
  mkdir -p "$WT_BASE_DIR"

  MAIN_REPO="$TEST_TMP_DIR/main_repo"
  mkdir -p "$MAIN_REPO"
  cd "$MAIN_REPO"

  git init -q -b main
  git config user.name "Test User"
  git config user.email "test@example.com"
  git commit -q --allow-empty -m "initial"
}

teardown() {
  rm -rf "$TEST_TMP_DIR"
}

@test "default_branch falls back to main" {
  run default_branch
  [ "$status" -eq 0 ]
  [ "$output" = "main" ]
}

@test "clean_candidates lists a merged worktree branch" {
  # A branch with no new commits is merged into main
  create_worktree "merged-feature" > /dev/null

  run clean_candidates
  [ "$status" -eq 0 ]
  [[ "$output" == *"merged-feature"* ]]
  [[ "$output" == *"merged into main"* ]]
}

@test "clean_candidates excludes the default branch itself" {
  create_worktree "merged-feature" > /dev/null

  run clean_candidates
  # main is the current/default branch and must never be a candidate
  [[ "$output" != *$'main\t'* ]]
}

@test "clean_candidates excludes an unmerged branch with no upstream" {
  create_worktree "active-feature" > /dev/null
  git -C "$WT_BASE_DIR/active-feature" commit -q --allow-empty -m "wip"

  run clean_candidates
  [ "$status" -eq 0 ]
  [[ "$output" != *"active-feature"* ]]
}

@test "clean_worktrees reports nothing to clean when there are no candidates" {
  create_worktree "active-feature" > /dev/null
  git -C "$WT_BASE_DIR/active-feature" commit -q --allow-empty -m "wip"

  run clean_worktrees
  [ "$status" -eq 0 ]
  [[ "$output" == *"nothing to clean"* ]]
}

@test "clean_worktrees --yes removes merged candidates without fzf" {
  create_worktree "merged-feature" > /dev/null

  run clean_worktrees --yes
  [ "$status" -eq 0 ]
  [[ "$output" == *"Removed worktree: merged-feature"* ]]
  [ ! -d "$WT_BASE_DIR/merged-feature" ]
}

@test "clean_worktrees rejects an unknown option" {
  run clean_worktrees --bogus
  [ "$status" -eq 1 ]
  [[ "$output" == *"unknown clean option: --bogus"* ]]
}
