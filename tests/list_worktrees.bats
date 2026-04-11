#!/usr/bin/env bats

setup() {
  source "${BATS_TEST_DIRNAME}/../bin/wt"

  git() {
    if [ "$1" = "worktree" ] && [ "$2" = "list" ]; then
      cat <<EOF
worktree /path/to/main
HEAD abcdef0
branch refs/heads/main

worktree /path/to/feature
HEAD 1234567
branch refs/heads/feature

worktree /path/to/detached
HEAD 89abcdef
detached
EOF
      return 0
    fi
    command git "$@"
  }
  export -f git
}

@test "list_worktrees lists all worktrees when no target is specified" {
  run list_worktrees
  [ "$status" -eq 0 ]
  [ "${lines[0]}" = "main	/path/to/main" ]
  [ "${lines[1]}" = "feature	/path/to/feature" ]
  [ "${lines[2]}" = "(detached)	/path/to/detached" ]
}

@test "list_worktrees <branch> outputs only the path to the specified worktree" {
  run list_worktrees "feature"
  [ "$status" -eq 0 ]
  [ "$output" = "/path/to/feature" ]
}

@test "list_worktrees \"(detached)\" outputs the path to the detached worktree" {
  run list_worktrees "(detached)"
  [ "$status" -eq 0 ]
  [ "$output" = "/path/to/detached" ]
}

@test "list_worktrees <non-existent-branch> outputs nothing" {
  run list_worktrees "non-existent"
  [ "$status" -eq 0 ]
  [ "$output" = "" ]
}
