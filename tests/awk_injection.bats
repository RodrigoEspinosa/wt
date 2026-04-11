#!/usr/bin/env bats

setup() {
  source "${BATS_TEST_DIRNAME}/../bin/wt"
  git() {
    if [ "$1" = "worktree" ] && [ "$2" = "list" ]; then
      printf 'worktree /path/to/wt\nHEAD abc123\nbranch refs/heads/branch\\name\n\n'
      return 0
    fi
    command git "$@"
  }
  export -f git
}

@test "get_worktree_path with backslashes in branch name" {
  run get_worktree_path 'branch\name'
  [ "$status" -eq 0 ]
  [ "$output" = "/path/to/wt" ]
}
