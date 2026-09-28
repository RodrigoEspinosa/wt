# Contributing to wt

Thanks for helping out! `wt` is a single Bash script (`bin/wt`), so getting
started takes a minute.

## Setup

You need `git`, [fzf](https://github.com/junegunn/fzf),
[bats-core](https://github.com/bats-core/bats-core), and
[shellcheck](https://www.shellcheck.net/).

```sh
brew install fzf bats-core shellcheck   # macOS
sudo apt-get install fzf bats shellcheck # Debian/Ubuntu
```

Run your local copy directly with `./bin/wt`.

## Before opening a PR

```sh
make test   # BATS tests in tests/
make lint   # shellcheck bin/wt
```

Both run in CI on Linux and macOS.

- Add or update a test in `tests/` for any behavior change.
- Update `README.md` and the man page (`doc/wt.1`) when you change user-facing
  flags, commands, or environment variables.
- Add an entry under `## [Unreleased]` in `CHANGELOG.md`.
- Use [Conventional Commits](https://www.conventionalcommits.org/) for commit
  messages and PR titles (`feat:`, `fix:`, `docs:`, `test:`, `refactor:`, ...).

## Looking for something to work on?

Check the issues labeled
[`good first issue`](https://github.com/RodrigoEspinosa/wt/labels/good%20first%20issue)
or [`help wanted`](https://github.com/RodrigoEspinosa/wt/labels/help%20wanted).
