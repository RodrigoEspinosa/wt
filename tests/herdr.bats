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

  # Stub herdr: log every call, answer from STUB_* variables.
  STUB_BIN="$TEST_TMP_DIR/bin"
  mkdir -p "$STUB_BIN"
  export HERDR_LOG="$TEST_TMP_DIR/herdr.log"
  : > "$HERDR_LOG"
  cat > "$STUB_BIN/herdr" <<'STUB'
#!/usr/bin/env bash
printf '%s\n' "$*" >> "$HERDR_LOG"
case "$1 $2" in
  "worktree open")  exit "${STUB_OPEN_RC:-0}" ;;
  "worktree list")
    printf '{"result":{"source":{"repo_root":"x"},"worktrees":[{"branch":"b","open_workspace_id":"%s","path":"%s"}]}}\n' \
      "${STUB_WS:-}" "${STUB_PATH:-}"
    ;;
  "workspace get")
    printf '{"result":{"workspace":{"agent_status":"%s","workspace_id":"%s"}}}\n' "${STUB_STATUS:-idle}" "$3"
    ;;
  "workspace close") ;;
esac
STUB
  chmod +x "$STUB_BIN/herdr"
  export PATH="$STUB_BIN:$PATH"

  export WT_HERDR=workspace HERDR_ENV=1 HERDR_WORKSPACE_ID=w1
}

teardown() {
  rm -rf "$TEST_TMP_DIR"
}

@test "herdr_enabled requires WT_HERDR=workspace and HERDR_ENV=1" {
  herdr_enabled
  WT_HERDR="" run herdr_enabled
  [ "$status" -ne 0 ]
  HERDR_ENV="" run herdr_enabled
  [ "$status" -ne 0 ]
}

@test "switch_to prints the path when herdr is not enabled" {
  WT_HERDR="" run switch_to "/some/path"
  [ "$status" -eq 0 ]
  [ "$output" = "/some/path" ]
  [ ! -s "$HERDR_LOG" ]
}

@test "switch_to opens a herdr workspace and prints nothing" {
  local wt_path
  wt_path="$(create_worktree feat)"

  run switch_to "$wt_path"
  [ "$status" -eq 0 ]
  [ -z "$output" ]
  grep -q -- "^worktree open --cwd .* --path $wt_path --label feat --focus$" "$HERDR_LOG"
}

@test "switch_to falls back to printing the path when herdr fails" {
  STUB_OPEN_RC=1 run switch_to "$MAIN_REPO"
  [ "$status" -eq 0 ]
  [[ "$output" == *"switching with cd instead"* ]]
  [[ "$output" == *"$MAIN_REPO" ]]
}

@test "main goto opens herdr instead of printing the path" {
  run main feat
  [ "$status" -eq 0 ]
  [[ "$output" != *"$WT_BASE_DIR/feat"* ]]
  grep -q -- "worktree open" "$HERDR_LOG"
}

@test "main goto still fails when the worktree can't be created" {
  mkdir -p "$WT_BASE_DIR/a-b"
  git worktree add -q -b a/b "$WT_BASE_DIR/a-b"
  run main a-b
  [ "$status" -eq 1 ]
  ! grep -q -- "worktree open" "$HERDR_LOG"
}

@test "herdr_workspace_for finds the workspace open on a path" {
  export STUB_PATH="/tmp/wt/feat" STUB_WS="w7"
  run herdr_workspace_for "/tmp/wt/feat"
  [ "$output" = "w7" ]
  run herdr_workspace_for "/tmp/wt/fe"
  [ -z "$output" ]
}

@test "remove_worktree closes the herdr workspace for the removed worktree" {
  local wt_path
  wt_path="$(create_worktree feat)"
  export STUB_PATH="$(get_worktree_path feat)" STUB_WS="w7"

  run remove_worktree feat
  [ "$status" -eq 0 ]
  [[ "$output" == *"Closed herdr workspace: w7"* ]]
  grep -qx "workspace close w7" "$HERDR_LOG"
  [ ! -d "$wt_path" ]
}

@test "remove_worktree leaves the current herdr workspace open" {
  create_worktree feat > /dev/null
  export STUB_PATH="$(get_worktree_path feat)" STUB_WS="w1"

  run remove_worktree feat
  [ "$status" -eq 0 ]
  [[ "$output" == *"Left herdr workspace w1 open"* ]]
  ! grep -q "workspace close" "$HERDR_LOG"
}

@test "remove_worktree refuses while an agent is working in the workspace" {
  local wt_path
  wt_path="$(create_worktree feat)"
  export STUB_PATH="$(get_worktree_path feat)" STUB_WS="w7" STUB_STATUS="working"

  run remove_worktree feat
  [ "$status" -eq 1 ]
  [[ "$output" == *"an agent is still working in herdr workspace w7"* ]]
  [ -d "$wt_path" ]
}

@test "remove_worktree doesn't call herdr when integration is off" {
  create_worktree feat > /dev/null
  WT_HERDR="" run remove_worktree feat
  [ "$status" -eq 0 ]
  [ ! -s "$HERDR_LOG" ]
}
