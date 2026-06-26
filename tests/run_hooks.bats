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
}

teardown() {
  rm -rf "$TEST_TMP_DIR"
}

@test "config_get returns nothing when no .wtconfig exists" {
  run config_get copy
  [ "$status" -eq 0 ]
  [ -z "$output" ]
}

@test "config_get reads multiple values and trims whitespace" {
  cat > .wtconfig <<EOF
# a comment
copy = .env
copy =   .env.local
postCreate = echo hi
EOF
  run config_get copy
  [ "$status" -eq 0 ]
  [ "${lines[0]}" = ".env" ]
  [ "${lines[1]}" = ".env.local" ]
}

@test "run_hooks copies files listed under copy from the primary worktree" {
  printf 'SECRET=1\n' > .env
  printf 'copy = .env\n' > .wtconfig

  create_worktree "feature-copy" > /dev/null

  [ -f "$WT_BASE_DIR/feature-copy/.env" ]
  [ "$(cat "$WT_BASE_DIR/feature-copy/.env")" = "SECRET=1" ]
}

@test "run_hooks symlinks paths listed under link" {
  mkdir node_modules
  printf 'link = node_modules\n' > .wtconfig

  create_worktree "feature-link" > /dev/null

  [ -L "$WT_BASE_DIR/feature-link/node_modules" ]
}

@test "run_hooks runs the postCreate command inside the new worktree" {
  printf 'postCreate = pwd > .where\n' > .wtconfig

  create_worktree "feature-hook" > /dev/null

  [ -f "$WT_BASE_DIR/feature-hook/.where" ]
  [ "$(cat "$WT_BASE_DIR/feature-hook/.where")" = "$WT_BASE_DIR/feature-hook" ]
}

@test "run_hooks exposes WT_BRANCH to the postCreate command" {
  printf 'postCreate = echo "$WT_BRANCH" > .branch\n' > .wtconfig

  create_worktree "feature-env" > /dev/null

  [ "$(cat "$WT_BASE_DIR/feature-env/.branch")" = "feature-env" ]
}

@test "WT_NO_HOOKS disables hooks" {
  printf 'SECRET=1\n' > .env
  printf 'copy = .env\n' > .wtconfig

  WT_NO_HOOKS=1 create_worktree "feature-nohook" > /dev/null

  [ ! -f "$WT_BASE_DIR/feature-nohook/.env" ]
}

@test "create_worktree still prints the path as its last line with hooks active" {
  printf 'postCreate = echo running\n' > .wtconfig

  run create_worktree "feature-path"
  [ "$status" -eq 0 ]
  [ "${lines[${#lines[@]}-1]}" = "$WT_BASE_DIR/feature-path" ]
}
