#!/usr/bin/env bats

# Exercises the bash wrapper that "wt init bash" emits: it must cd into a
# result that is a directory and print any other (non-directory) result.

setup() {
  source "${BATS_TEST_DIRNAME}/../bin/wt"

  FAKE_BIN="$(mktemp -d)"
  PATH="$FAKE_BIN:$PATH"
}

teardown() {
  rm -rf "$FAKE_BIN" "${FAKE_TARGET:-}"
}

# Install a fake `wt` binary on PATH that prints $1, so the wrapper's
# `command wt ...` resolves to it instead of recursing.
fake_wt_prints() {
  cat > "$FAKE_BIN/wt" <<SH
#!/usr/bin/env bash
printf '%s\n' '$1'
SH
  chmod +x "$FAKE_BIN/wt"
}

@test "bash wrapper cd's into a directory result" {
  FAKE_TARGET="$(mktemp -d)"
  fake_wt_prints "$FAKE_TARGET"

  eval "$(shell_init bash)"
  wt some-branch

  [ "$PWD" = "$FAKE_TARGET" ]
}

@test "bash wrapper prints a non-directory result without cd" {
  local before="$PWD"
  fake_wt_prints "not-a-directory"

  eval "$(shell_init bash)"
  run wt some-branch

  [ "$status" -eq 0 ]
  [ "$output" = "not-a-directory" ]
  [ "$PWD" = "$before" ]
}

@test "shell_init rejects an unsupported shell" {
  run shell_init powershell
  [ "$status" -eq 1 ]
  [[ "$output" == *"unsupported shell: powershell"* ]]
}
