#!/usr/bin/env bats

setup() {
  # Source the script under test
  source "${BATS_TEST_DIRNAME}/../bin/wt"

  # Mock git to test both code paths
  git() {
    if [[ "$1" == "rev-parse" && "$2" == "--show-toplevel" ]]; then
      if [[ "${MOCK_GIT_SHOW_TOPLEVEL_FAIL:-}" == "1" ]]; then
        return 1
      elif [[ "${MOCK_GIT_SHOW_TOPLEVEL_EMPTY:-}" == "1" ]]; then
        return 0
      elif [[ -n "${MOCK_GIT_SHOW_TOPLEVEL_OUTPUT:-}" ]]; then
        echo "$MOCK_GIT_SHOW_TOPLEVEL_OUTPUT"
        return 0
      fi
    elif [[ "$1" == "rev-parse" && "$2" == "--git-dir" ]]; then
      echo "/mock/git/dir"
      return 0
    fi
    # Fallback to real git if not mocked
    command git "$@"
  }
}

@test "repo_root outputs toplevel when --show-toplevel succeeds" {
  export MOCK_GIT_SHOW_TOPLEVEL_OUTPUT="/mock/toplevel"
  run repo_root
  [ "$status" -eq 0 ]
  [ "$output" = "/mock/toplevel" ]
}

@test "repo_root outputs git-dir when --show-toplevel fails" {
  export MOCK_GIT_SHOW_TOPLEVEL_FAIL=1
  run repo_root
  [ "$status" -eq 0 ]
  [ "$output" = "/mock/git/dir" ]
}

@test "repo_root outputs git-dir when --show-toplevel output is empty" {
  export MOCK_GIT_SHOW_TOPLEVEL_EMPTY=1
  run repo_root
  [ "$status" -eq 0 ]
  [ "$output" = "/mock/git/dir" ]
}
