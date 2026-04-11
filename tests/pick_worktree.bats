#!/usr/bin/env bats

setup() {
  source "${BATS_TEST_DIRNAME}/../bin/wt"
}

@test "pick_worktree returns 0 and prints nothing when fzf is cancelled" {
  list_worktrees() {
    echo -e "feature\t/tmp/feature"
  }
  fzf() {
    return 1 # Simulate user pressing Esc
  }
  export -f list_worktrees fzf

  run pick_worktree
  [ "$status" -eq 0 ]
  [ "$output" = "" ]
}

@test "pick_worktree returns path when fzf outputs selection" {
  list_worktrees() {
    echo -e "feature\t/tmp/feature"
  }
  fzf() {
    # Consume stdin so no broken pipe
    cat > /dev/null
    echo "feature                        /tmp/feature"
  }
  export -f list_worktrees fzf

  mkdir -p /tmp/feature
  run pick_worktree
  rm -rf /tmp/feature

  [ "$status" -eq 0 ]
  [ "$output" = "/tmp/feature" ]
}

@test "pick_worktree dies when selected path does not exist" {
  list_worktrees() {
    echo -e "feature\t/tmp/feature_not_exist"
  }
  fzf() {
    cat > /dev/null
    echo "feature                        /tmp/feature_not_exist"
  }
  export -f list_worktrees fzf

  run pick_worktree

  [ "$status" -eq 1 ]
  [[ "$output" == *"worktree path not found: /tmp/feature_not_exist"* ]]
}

@test "pick_worktree calls remove_worktree when fzf outputs DELETE prefix" {
  list_worktrees() {
    echo -e "feature\t/tmp/feature"
  }
  fzf() {
    cat > /dev/null
    echo "DELETE:feature"
  }
  remove_worktree() {
    echo "Called remove_worktree with $1"
  }
  export -f list_worktrees fzf remove_worktree

  run pick_worktree

  [ "$status" -eq 0 ]
  [[ "$output" == *"Called remove_worktree with feature"* ]]
}
