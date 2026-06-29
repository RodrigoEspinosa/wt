#!/usr/bin/env bats

setup() {
  source "${BATS_TEST_DIRNAME}/../bin/wt"

  TEST_TMP_DIR="$(mktemp -d)"
  mkdir -p "$TEST_TMP_DIR/main_repo"
  cd "$TEST_TMP_DIR/main_repo"
  # Canonicalize so it matches `git rev-parse --show-toplevel`, which resolves
  # symlinks (e.g. macOS /var -> /private/var under $TMPDIR).
  MAIN_REPO="$(pwd -P)"

  git init -q -b main
  git config user.name "Test User"
  git config user.email "test@example.com"
  git commit -q --allow-empty -m "initial"

  unset WT_BASE_DIR
}

teardown() {
  rm -rf "$TEST_TMP_DIR"
}

@test "worktree_base reads a relative baseDir from .wtconfig (resolved against repo root)" {
  printf 'baseDir = .trees\n' > .wtconfig
  run worktree_base
  [ "$status" -eq 0 ]
  [ "$output" = "$MAIN_REPO/.trees" ]
}

@test "worktree_base reads an absolute baseDir from .wtconfig" {
  printf 'baseDir = %s/abs-trees\n' "$TEST_TMP_DIR" > .wtconfig
  run worktree_base
  [ "$status" -eq 0 ]
  [ "$output" = "$TEST_TMP_DIR/abs-trees" ]
}

@test "worktree_base expands a leading ~ in baseDir" {
  printf 'baseDir = ~/my-trees\n' > .wtconfig
  run worktree_base
  [ "$status" -eq 0 ]
  [ "$output" = "$HOME/my-trees" ]
}

@test "WT_BASE_DIR overrides the .wtconfig baseDir" {
  printf 'baseDir = .trees\n' > .wtconfig
  WT_BASE_DIR="$TEST_TMP_DIR/env-wins" run worktree_base
  [ "$status" -eq 0 ]
  [ "$output" = "$TEST_TMP_DIR/env-wins" ]
}

@test "worktree_base falls back to <repo>/_worktrees with no config" {
  run worktree_base
  [ "$status" -eq 0 ]
  [ "$output" = "$MAIN_REPO/_worktrees" ]
}
