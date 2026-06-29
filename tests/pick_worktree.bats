#!/usr/bin/env bats

setup() {
  source "${BATS_TEST_DIRNAME}/../bin/wt"

  # The picker feeds annotate_worktrees into fzf; stub it so no real git runs.
  # fzf is stubbed per-test to emulate the user's interaction.
  annotate_worktrees() {
    printf '  \tfeature\t/tmp/feature\t\n'
  }
  export -f annotate_worktrees
}

@test "pick_worktree returns 0 and prints nothing when fzf is cancelled" {
  fzf() {
    cat > /dev/null
    return 130 # Simulate user pressing Esc
  }
  export -f fzf

  run pick_worktree
  [ "$status" -eq 0 ]
  [ "$output" = "" ]
}

@test "pick_worktree returns path when fzf outputs selection" {
  fzf() {
    # --print-query then --expect: query line, key line (empty for enter),
    # then the full selected row (flags, branch, path, ahead/behind).
    cat > /dev/null
    printf '\n\n  \tfeature\t/tmp/feature\t\n'
  }
  export -f fzf

  mkdir -p /tmp/feature
  run pick_worktree
  rm -rf /tmp/feature

  [ "$status" -eq 0 ]
  [ "$output" = "/tmp/feature" ]
}

@test "pick_worktree handles worktree paths containing spaces" {
  fzf() {
    cat > /dev/null
    printf '\n\n  \tfeature\t/tmp/wt path with spaces\t\n'
  }
  export -f fzf

  mkdir -p "/tmp/wt path with spaces"
  run pick_worktree
  rm -rf "/tmp/wt path with spaces"

  [ "$status" -eq 0 ]
  [ "$output" = "/tmp/wt path with spaces" ]
}

@test "pick_worktree dies when selected path does not exist" {
  fzf() {
    cat > /dev/null
    printf '\n\n  \tfeature\t/tmp/feature_not_exist\t\n'
  }
  export -f fzf

  run pick_worktree

  [ "$status" -eq 1 ]
  [[ "$output" == *"worktree path not found: /tmp/feature_not_exist"* ]]
}

@test "pick_worktree calls remove_worktree when ctrl-d is pressed" {
  fzf() {
    cat > /dev/null
    printf '\nctrl-d\n  \tfeature\t/tmp/feature\t\n'
  }
  remove_worktree() {
    echo "Called remove_worktree with $1"
  }
  export -f fzf remove_worktree

  run pick_worktree

  [ "$status" -eq 0 ]
  [[ "$output" == *"Called remove_worktree with feature"* ]]
}

@test "pick_worktree creates a worktree from the query when ctrl-n is pressed" {
  fzf() {
    # ctrl-n with no row selected: act on the typed query instead.
    cat > /dev/null
    printf 'brand-new\nctrl-n\n\n'
  }
  goto_worktree() {
    echo "Called goto_worktree with $1"
  }
  export -f fzf goto_worktree

  run pick_worktree

  [ "$status" -eq 0 ]
  [[ "$output" == *"Called goto_worktree with brand-new"* ]]
}
