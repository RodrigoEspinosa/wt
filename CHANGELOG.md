# Changelog

All notable changes to this project are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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

[0.4.2]: https://github.com/RodrigoEspinosa/wt/compare/v0.4.1...v0.4.2
[0.4.1]: https://github.com/RodrigoEspinosa/wt/compare/v0.4.0...v0.4.1
[0.4.0]: https://github.com/RodrigoEspinosa/wt/compare/v0.3.0...v0.4.0
[0.3.0]: https://github.com/RodrigoEspinosa/wt/compare/v0.2.0...v0.3.0
[0.2.0]: https://github.com/RodrigoEspinosa/wt/compare/v0.1.2...v0.2.0
[0.1.2]: https://github.com/RodrigoEspinosa/wt/compare/v0.1.1...v0.1.2
[0.1.1]: https://github.com/RodrigoEspinosa/wt/compare/v0.1.0...v0.1.1
