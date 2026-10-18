#!/usr/bin/env bats

setup() {
  source "${BATS_TEST_DIRNAME}/../bin/wt"

  TEST_TMP_DIR="$(mktemp -d)"
  export WT_BASE_DIR="$TEST_TMP_DIR/worktrees" WT_NO_HOOKS=1
  mkdir -p "$WT_BASE_DIR"

  MAIN_REPO="$TEST_TMP_DIR/main_repo"
  mkdir -p "$MAIN_REPO"
  cd "$MAIN_REPO"

  git init -q -b main
  git config user.name "Test User"
  git config user.email "test@example.com"
  printf 'build/\n' > .gitignore
  git add .gitignore
  git commit -q -m "initial"
}

teardown() {
  rm -rf "$TEST_TMP_DIR"
}

# Print the verdict clean_report gives the worktree on <branch>.
verdict_of() {
  clean_report | B="$1" awk -F'\t' '$6 == ENVIRON["B"] { print $3 }'
}

# A worktree on <branch> with one commit that main doesn't have.
unmerged_worktree() {
  create_worktree "$1" > /dev/null
  git -C "$WT_BASE_DIR/$1" commit -q --allow-empty -m "wip on $1"
}

@test "default_branch falls back to main" {
  run default_branch
  [ "$status" -eq 0 ]
  [ "$output" = "main" ]
}

@test "a merged worktree with nothing uncommitted is safe" {
  create_worktree merged > /dev/null
  [ "$(verdict_of merged)" = "safe" ]
}

@test "an unmerged worktree with nothing uncommitted is idle" {
  unmerged_worktree feat
  [ "$(verdict_of feat)" = "idle" ]
}

@test "uncommitted tracked changes make a worktree dirty" {
  create_worktree merged > /dev/null
  echo change >> "$WT_BASE_DIR/merged/.gitignore"
  [ "$(verdict_of merged)" = "dirty" ]
}

@test "untracked files are flagged, but gitignored ones are not" {
  create_worktree merged > /dev/null
  mkdir -p "$WT_BASE_DIR/merged/build"
  touch "$WT_BASE_DIR/merged/build/out.o"
  [ "$(verdict_of merged)" = "safe" ]

  touch "$WT_BASE_DIR/merged/notes.txt"
  [ "$(verdict_of merged)" = "untracked" ]
}

@test "a worktree whose directory was deleted is safe, even if unmerged" {
  unmerged_worktree feat
  rm -rf "$WT_BASE_DIR/feat"
  [ "$(verdict_of feat)" = "safe" ]
}

@test "a locked worktree is locked" {
  create_worktree merged > /dev/null
  git worktree lock "$WT_BASE_DIR/merged"
  [ "$(verdict_of merged)" = "locked" ]
}

@test "the worktree you are in is current" {
  create_worktree merged > /dev/null
  cd "$WT_BASE_DIR/merged"
  [ "$(verdict_of merged)" = "current" ]
}

@test "a worktree with a busy herdr agent is busy" {
  create_worktree merged > /dev/null
  local wt_path
  wt_path="$(get_worktree_path merged)"
  herdr_agent_statuses() { printf '%s\tworking\n' "$wt_path"; }

  [ "$(verdict_of merged)" = "busy" ]
}

@test "a detached worktree is idle if a branch holds its commits, else orphan" {
  git worktree add -q --detach "$WT_BASE_DIR/det" 2>/dev/null
  [ "$(verdict_of '(detached)')" = "idle" ]

  git -C "$WT_BASE_DIR/det" commit -q --allow-empty -m "only here"
  [ "$(verdict_of '(detached)')" = "orphan" ]
}

@test "clean_report leaves out the primary worktree" {
  create_worktree merged > /dev/null
  run clean_report
  [ "$status" -eq 0 ]
  [ "$(printf '%s\n' "$output" | wc -l | tr -d ' ')" = 1 ]
  [[ "$output" != *$'\tmain\t'* ]]
}

@test "clean_report sorts safe worktrees before riskier ones" {
  unmerged_worktree aaa-idle
  create_worktree zzz-safe > /dev/null
  run clean_report
  [ "$(printf '%s\n' "$output" | head -n1 | cut -f6)" = "zzz-safe" ]
}

@test "clean_summary totals worktrees and what the safe ones free" {
  run clean_summary <<< $'0\t2048\tsafe\n1\t1024\tidle\n0\t0\tsafe'
  [ "$output" = "3 worktree(s) · 3M on disk · 2 safe to remove (2M)" ]
}

@test "human_size and human_age pick a readable unit" {
  [ "$(human_size 512)" = "512K" ]
  [ "$(human_size 35000)" = "34M" ]
  [ "$(human_size 1258291)" = "1.2G" ]
  [ "$(human_age 120)" = "2m" ]
  [ "$(human_age 7200)" = "2h" ]
  [ "$(human_age 259200)" = "3d" ]
}

@test "clean_worktrees reports nothing to clean with only the primary worktree" {
  run clean_worktrees
  [ "$status" -eq 0 ]
  [[ "$output" == *"nothing to clean"* ]]
}

@test "clean_worktrees --list prints the report and removes nothing" {
  create_worktree merged > /dev/null
  unmerged_worktree feat

  run clean_worktrees --list
  [ "$status" -eq 0 ]
  [[ "$output" == *"2 worktree(s)"*"1 safe to remove"* ]]
  [[ "$output" == *"safe "*"merged"*"merged into main"* ]]
  [[ "$output" == *"idle "*"feat"*"not merged (branch kept)"* ]]
  [ -d "$WT_BASE_DIR/merged" ]
  [ -d "$WT_BASE_DIR/feat" ]
}

@test "clean_worktrees --yes removes only safe worktrees" {
  create_worktree merged > /dev/null
  unmerged_worktree feat
  unmerged_worktree gone
  rm -rf "$WT_BASE_DIR/gone"
  create_worktree scratch > /dev/null
  touch "$WT_BASE_DIR/scratch/notes.txt"

  run clean_worktrees --yes
  [ "$status" -eq 0 ]
  [[ "$output" == *"Removed worktree: merged"* ]]
  [[ "$output" == *"Deleted branch: merged"* ]]
  [[ "$output" == *"Removed worktree: gone"* ]]
  [ ! -d "$WT_BASE_DIR/merged" ]
  [ -d "$WT_BASE_DIR/feat" ]
  [ -d "$WT_BASE_DIR/scratch" ]
  [ -z "$(git worktree list --porcelain | grep -F "$WT_BASE_DIR/gone" || true)" ]
}

@test "clean_worktrees removes what you pick and skips refused verdicts" {
  unmerged_worktree feat
  create_worktree messy > /dev/null
  echo change >> "$WT_BASE_DIR/messy/.gitignore"
  fzf() { grep -E $'\t(feat|messy)\t'; }

  run clean_worktrees
  [ "$status" -eq 0 ]
  [[ "$output" == *"Removed worktree: feat"* ]]
  [[ "$output" == *"Kept branch feat"* ]]
  [[ "$output" == *"skipped messy (dirty)"* ]]
  [ ! -d "$WT_BASE_DIR/feat" ]
  [ -d "$WT_BASE_DIR/messy" ]
}

@test "clean_worktrees does nothing when the picker is cancelled" {
  create_worktree merged > /dev/null
  fzf() { cat > /dev/null; return 130; }

  run clean_worktrees
  [ "$status" -eq 0 ]
  [ -d "$WT_BASE_DIR/merged" ]
}

@test "clean_worktrees rejects an unknown option" {
  run clean_worktrees --bogus
  [ "$status" -eq 1 ]
  [[ "$output" == *"unknown clean option: --bogus"* ]]
}

@test "remove_worktree never deletes the default branch" {
  git checkout -q -b dev
  create_worktree main > /dev/null

  run remove_worktree main
  [ "$status" -eq 0 ]
  [ ! -d "$WT_BASE_DIR/main" ]
  git show-ref --verify --quiet refs/heads/main
}
