#!/usr/bin/env bats

setup() {
  source "${BATS_TEST_DIRNAME}/../bin/wt"

  # Mock list_worktrees
  list_worktrees() {
    printf "main\t/path/to/main\n"
    printf "test\\\\branch\t/path/to/test1\n"
    printf "branch=a\t/path/to/test2\n"
    printf "test\\\\\\\\branch\t/path/to/test3\n"
    printf "normal_branch\t/path/to/normal\n"
  }
}

@test "get_worktree_path finds normal branch" {
  run get_worktree_path "normal_branch"
  [ "$status" -eq 0 ]
  [ "$output" = "/path/to/normal" ]
}

@test "get_worktree_path handles backslashes safely" {
  run get_worktree_path 'test\branch'
  [ "$status" -eq 0 ]
  [ "$output" = "/path/to/test1" ]
}

@test "get_worktree_path handles double backslashes safely" {
  run get_worktree_path 'test\\branch'
  [ "$status" -eq 0 ]
  [ "$output" = "/path/to/test3" ]
}

@test "get_worktree_path handles branch with equal sign" {
  run get_worktree_path 'branch=a'
  [ "$status" -eq 0 ]
  [ "$output" = "/path/to/test2" ]
}
