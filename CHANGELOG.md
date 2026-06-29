# Changelog

All notable changes to this project are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.6.1] - 2026-06-29

### Changed

- The picker and `wt -l` now compute each worktree's status (`!`, `↑N`/`↓N`) in
  parallel instead of one at a time, and stream rows into fzf as they finish, so
  the picker appears instantly on repos with many worktrees instead of blocking
  on a serial run of `git status` per worktree.

### Fixed

- Slow git operations now show a spinner instead of appearing frozen: deleting a
  worktree (`git worktree remove`, e.g. on a large `node_modules`), creating one
  (`git worktree add`), and `wt pr` (the network fetch and checkout). Falls back
  to a plain run with a one-line breadcrumb when output isn't a terminal.

## [0.6.0] - 2026-06-28

### Added

- The interactive picker can now **create** a worktree: type a name and press
  `ctrl-n` to create (or switch to) it, instead of dropping back to the command
  line.
- `wt -l` and the picker now show worktree state: `*` marks the worktree you're
  in, `!` flags uncommitted changes, and `↑N`/`↓N` show how far each branch sits
  ahead/behind its upstream. The picker preview also shows working-tree status.
- `wt clean` accepts `--prune` (run `git fetch --all --prune` first so deleted
  upstreams are detected) and `--yes`/`--all` (remove every candidate without
  the fzf prompt, for scripts and CI).
- `.wtconfig` gains a `baseDir` key to set the worktree parent directory per
  repo. Relative paths resolve against the repo root and a leading `~` expands;
  `WT_BASE_DIR` still overrides it.

### Fixed

- Creating a worktree whose flattened directory name collides with an existing
  worktree for a different branch (e.g. `rec/foo` vs `rec-foo`) now fails with a
  clear error instead of silently switching to the wrong worktree.

### Changed

- `make install` now installs the man page as well as the binary.

## [0.5.1] - 2026-06-26

### Fixed

- The worktree picker now also deletes on the `del` (forward-delete) key, not
  just `ctrl-d`. The key was never registered with fzf's `--expect`, so pressing
  it did nothing.

## [0.5.0] - 2026-06-24

### Added

- Worktree hooks via a `.wtconfig` file at the repo root. New worktrees can
  automatically `copy` files (e.g. `.env`), `link` directories (e.g.
  `node_modules`), and run a `postCreate` shell command (e.g. `pnpm install`).
  Hooks run on creation only; set `WT_NO_HOOKS=1` to skip them. The hook command
  receives `WT_BRANCH`, `WT_PATH`, and `WT_SOURCE` in its environment.
- `wt pr <number>` fetches a GitHub pull request (`refs/pull/<n>/head`) into a
  local branch and checks it out in a worktree. Uses `gh` for a friendly branch
  name when available, otherwise `pr-<number>`.
- `wt clean` finds worktrees whose branch is merged into the default branch or
  whose upstream is gone, and removes the ones you select via an fzf
  multi-select list (falls back to a printed list without fzf).

### Changed

- Removing a worktree now forces past untracked files (build artifacts left by
  `postCreate` hooks) but still refuses to delete a worktree with uncommitted
  changes to tracked files.
- Informational messages from worktree removal now go to stderr, keeping stdout
  reserved for the path the shell wrapper `cd`s into.

## [0.4.2] - 2026-06-25

### Fixed

- `ctrl-d` delete in the worktree picker now works. The binding used fzf's
  `execute()`, whose output goes to the terminal rather than the selection, and
  `+abort` exited non-zero — so the delete signal never reached
  `remove_worktree`. The picker now uses `--expect=ctrl-d` to report the pressed
  key and route to deletion correctly.

## [0.4.1] - 2026-06-14

### Changed

- Re-recorded the demo gif for the compact picker UI.

## [0.4.0] - 2026-06-12

### Added

- Compact, adaptive-height fzf layout for the worktree picker.

## [0.3.0] - 2026-06-11

### Added

- Accept a start-point when creating a worktree.
- `remove_worktree` deletes the local branch when it is fully merged.

### Fixed

- `pick_worktree` now requires fzf and handles paths with spaces.

### Changed

- Refreshed the man page header and added `test`/`lint` Make targets.

## [0.2.0] - 2026-04-29

### Added

- Tab completions for bash, zsh, and fish (#19).
- Man page and improved README (#20).

### Changed

- CI: bats test workflow for macOS and Linux (#16), shellcheck lint workflow
  (#17), and release automation (#18).

## [0.1.2] - 2026-04-11

### Fixed

- `list_worktrees`: detect detached state via the `detached` marker, not the
  HEAD line (#13).
- fish: quote `$result` in the shell wrapper (#7).

### Tests

- Added bats tests for `create_worktree` (#14), `repo_root` (#11), and
  `pick_worktree` (#10); covered empty and spaced `WT_BASE_DIR` (#8).

## [0.1.1] - 2026-04-11

### Security

- Fixed improper string trimming via xargs (#4).

### Changed

- Optimized worktree lookup by combining awk processes (#2).
- Extracted a common worktree path lookup function (#1).
- Expanded the README with a demo gif, uninstall, and requirements.

[0.6.0]: https://github.com/RodrigoEspinosa/wt/compare/v0.5.1...v0.6.0
[0.5.1]: https://github.com/RodrigoEspinosa/wt/compare/v0.5.0...v0.5.1
[0.5.0]: https://github.com/RodrigoEspinosa/wt/compare/v0.4.2...v0.5.0
[0.4.2]: https://github.com/RodrigoEspinosa/wt/compare/v0.4.1...v0.4.2
[0.4.1]: https://github.com/RodrigoEspinosa/wt/compare/v0.4.0...v0.4.1
[0.4.0]: https://github.com/RodrigoEspinosa/wt/compare/v0.3.0...v0.4.0
[0.3.0]: https://github.com/RodrigoEspinosa/wt/compare/v0.2.0...v0.3.0
[0.2.0]: https://github.com/RodrigoEspinosa/wt/compare/v0.1.2...v0.2.0
[0.1.2]: https://github.com/RodrigoEspinosa/wt/compare/v0.1.1...v0.1.2
[0.1.1]: https://github.com/RodrigoEspinosa/wt/compare/v0.1.0...v0.1.1
