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

@test "remove_worktree dies when no worktree exists for branch" {
  run remove_worktree "no-such-branch"
  [ "$status" -eq 1 ]
  [[ "$output" == *"no worktree found for branch: no-such-branch"* ]]
}

@test "remove_worktree removes the worktree and deletes a merged branch" {
  create_worktree "merged-feature" > /dev/null

  run remove_worktree "merged-feature"
  [ "$status" -eq 0 ]
  [[ "$output" == *"Removed worktree: merged-feature"* ]]
  [[ "$output" == *"Deleted branch: merged-feature"* ]]

  [ ! -d "$WT_BASE_DIR/merged-feature" ]
  ! git show-ref --verify --quiet "refs/heads/merged-feature"
}

@test "remove_worktree force-removes a worktree that only has untracked files" {
  create_worktree "with-artifacts" > /dev/null
  # Simulate build artifacts a postCreate hook would leave behind
  printf 'API_KEY=1\n' > "$WT_BASE_DIR/with-artifacts/.env"
  mkdir -p "$WT_BASE_DIR/with-artifacts/node_modules"

  run remove_worktree "with-artifacts"
  [ "$status" -eq 0 ]
  [[ "$output" == *"Removed worktree: with-artifacts"* ]]
  [ ! -d "$WT_BASE_DIR/with-artifacts" ]
}

@test "remove_worktree refuses when tracked files have uncommitted changes" {
  create_worktree "dirty-feature" > /dev/null
  # Modify a tracked file without committing
  git -C "$WT_BASE_DIR/dirty-feature" commit -q --allow-empty -m "base"
  printf 'changed\n' >> "$WT_BASE_DIR/dirty-feature/tracked.txt"
  git -C "$WT_BASE_DIR/dirty-feature" add tracked.txt

  run remove_worktree "dirty-feature"
  [ "$status" -eq 1 ]
  [[ "$output" == *"uncommitted changes"* ]]
  [ -d "$WT_BASE_DIR/dirty-feature" ]
}

@test "remove_worktree keeps an unmerged branch and says how to force-delete" {
  create_worktree "unmerged-feature" > /dev/null
  git -C "$WT_BASE_DIR/unmerged-feature" commit -q --allow-empty -m "unmerged work"

  run remove_worktree "unmerged-feature"
  [ "$status" -eq 0 ]
  [[ "$output" == *"Removed worktree: unmerged-feature"* ]]
  [[ "$output" == *"Kept branch unmerged-feature"* ]]

  [ ! -d "$WT_BASE_DIR/unmerged-feature" ]
  git show-ref --verify --quiet "refs/heads/unmerged-feature"
}
