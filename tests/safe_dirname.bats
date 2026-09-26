#!/usr/bin/env bats

setup() {
  source "${BATS_TEST_DIRNAME}/../bin/wt"
}

@test "safe_dirname keeps branch name without slashes unchanged" {
  run safe_dirname "feature-branch"
  [ "$status" -eq 0 ]
  [ "$output" = "feature-branch" ]
}

@test "safe_dirname converts single slash to dash" {
  run safe_dirname "feat/branch"
  [ "$status" -eq 0 ]
  [ "$output" = "feat-branch" ]
}

@test "safe_dirname converts multiple slashes to dashes" {
  run safe_dirname "bugfix/jira-123/subtask/fix"
  [ "$status" -eq 0 ]
  [ "$output" = "bugfix-jira-123-subtask-fix" ]
}

@test "safe_dirname handles branch names starting with slash" {
  run safe_dirname "/test-branch"
  [ "$status" -eq 0 ]
  [ "$output" = "-test-branch" ]
}

@test "safe_dirname handles branch names ending with slash" {
  run safe_dirname "test-branch/"
  [ "$status" -eq 0 ]
  [ "$output" = "test-branch-" ]
}

@test "safe_dirname correctly handles branch names that contain single quotes" {
  run safe_dirname "feature/'cool'-branch"
  [ "$status" -eq 0 ]
  [ "$output" = "feature-'cool'-branch" ]
}
