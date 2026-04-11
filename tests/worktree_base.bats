#!/usr/bin/env bats

setup() {
  # Source the script under test
  # We use the absolute path to ensure it's found
  source "${BATS_TEST_DIRNAME}/../bin/wt"

  # Mock repo_root
  repo_root() {
    echo "/mock/repo/root"
  }
}

@test "worktree_base uses WT_BASE_DIR if set" {
  export WT_BASE_DIR="/custom/path"
  run worktree_base
  [ "$status" -eq 0 ]
  [ "$output" = "/custom/path" ]
}

@test "worktree_base uses parent of repo_root if WT_BASE_DIR is unset" {
  unset WT_BASE_DIR
  run worktree_base
  [ "$status" -eq 0 ]
  [ "$output" = "/mock/repo" ]
}

@test "worktree_base uses parent of repo_root if WT_BASE_DIR is empty string" {
  export WT_BASE_DIR=""
  run worktree_base
  [ "$status" -eq 0 ]
  [ "$output" = "/mock/repo" ]
}

@test "worktree_base uses WT_BASE_DIR correctly if it contains spaces" {
  export WT_BASE_DIR="/custom path/with spaces"
  run worktree_base
  [ "$status" -eq 0 ]
  [ "$output" = "/custom path/with spaces" ]
}
