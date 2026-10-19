#!/usr/bin/env bats

setup() {
  source "${BATS_TEST_DIRNAME}/../bin/wt"

  TEST_TMP_DIR="$(mktemp -d)"
  export WT_BASE_DIR="$TEST_TMP_DIR/worktrees" WT_NO_HOOKS=1
  export WT_PREVIEW_STATE="$TEST_TMP_DIR/mode"

  MAIN_REPO="$TEST_TMP_DIR/main_repo"
  mkdir -p "$MAIN_REPO"
  cd "$MAIN_REPO"

  git init -q -b main
  git config user.name "Test User"
  git config user.email "test@example.com"
  echo a > a
  git add a
  git commit -q -m "initial"
}

teardown() {
  rm -rf "$TEST_TMP_DIR"
}

# Strip ANSI colors so assertions read plainly.
plain() { sed $'s/\033\\[[0-9;]*m//g'; }

@test "preview_mode defaults to overview" {
  run preview_mode
  [ "$output" = "overview" ]
}

@test "preview_cycle steps through every mode and wraps around" {
  preview_cycle
  [ "$(preview_mode)" = "diff" ]
  preview_cycle
  [ "$(preview_mode)" = "overview" ]
}

@test "preview_cycle does nothing without a state file" {
  WT_PREVIEW_STATE="" run preview_cycle
  [ "$status" -eq 0 ]
  [ ! -e "$TEST_TMP_DIR/mode" ]
}

@test "overview preview shows status and recent commits" {
  echo b >> a
  run preview_worktree "$MAIN_REPO"
  output="$(printf '%s' "$output" | plain)"
  [ "$status" -eq 0 ]
  [[ "$output" == *"$MAIN_REPO"* ]]
  [[ "$output" == *" M a"* ]]
  [[ "$output" == *"initial"* ]]
}

@test "diff preview lists the branch's own commits and changes" {
  local wt_path
  wt_path="$(create_worktree feat)"
  ( cd "$wt_path" && echo b > b && git add b && git commit -q -m "add b" && echo c >> a )
  echo diff > "$WT_PREVIEW_STATE"

  run preview_worktree "$wt_path"
  output="$(printf '%s' "$output" | plain)"
  [ "$status" -eq 0 ]
  [[ "$output" == *"1 commit(s) not on main:"* ]]
  [[ "$output" == *"add b"* ]]
  [[ "$output" == *" b | 1 +"* ]]
  [[ "$output" == *"uncommitted:"* ]]
  [[ "$output" == *" a | 1 +"* ]]
}

@test "diff preview says so when nothing is beyond the default branch" {
  echo diff > "$WT_PREVIEW_STATE"
  run preview_worktree "$MAIN_REPO"
  [ "$status" -eq 0 ]
  [[ "$output" == *"no commits beyond main"* ]]
  [[ "$output" != *"uncommitted:"* ]]
}

@test "diff preview compares against origin's default branch when present" {
  git update-ref refs/remotes/origin/main HEAD
  git commit -q --allow-empty -m "local only"
  echo diff > "$WT_PREVIEW_STATE"

  run preview_worktree "$MAIN_REPO"
  output="$(printf '%s' "$output" | plain)"
  [[ "$output" == *"1 commit(s) not on origin/main:"* ]]
  [[ "$output" == *"local only"* ]]
}

@test "main _preview renders the preview for a path" {
  run main _preview "$MAIN_REPO"
  [ "$status" -eq 0 ]
  [[ "$output" == *"overview"*"diff"* ]]
  [[ "$output" == *"initial"* ]]
}
