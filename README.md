# wt

Git worktree manager powered by [fzf](https://github.com/junegunn/fzf).

Quickly list, switch to, create, or remove git worktrees with fuzzy search.

![wt demo](docs/demo.gif)

## Install

### Homebrew

```sh
brew install RodrigoEspinosa/tap/wt
```

### From source

```sh
git clone https://github.com/RodrigoEspinosa/wt.git
cd wt
make install
```

This installs `wt` to `/usr/local/bin` by default. Override with `PREFIX`:

```sh
make install PREFIX=$HOME/.local
```

### Uninstall

```sh
brew uninstall wt            # Homebrew
make uninstall               # from source
```

## Requirements

- `git` 2.5 or newer (for worktree support)
- [fzf](https://github.com/junegunn/fzf)

## Quick start

1. Install `wt` (see above).
2. Add shell integration to your rc file:

```sh
# zsh
eval "$(wt init zsh)"

# bash
eval "$(wt init bash)"

# fish
wt init fish | source
```

3. Run `wt` inside any git repository.

## Usage

```sh
wt                    # Interactive fuzzy picker
wt my-feature         # Switch to branch worktree (creates if needed)
wt my-feature main    # Create the branch from main if it doesn't exist
wt pr 123             # Check out GitHub PR #123 in a worktree
wt clean              # Pick and remove merged/stale worktrees
wt -d my-feature      # Remove a worktree
wt -l                 # List all worktrees
```

### Commands

| Command           | Description                                        |
| ----------------- | -------------------------------------------------- |
| `wt`              | Launch fzf to fuzzy-pick a worktree                |
| `wt <branch> [<start-point>]` | Switch to the worktree for `<branch>`, creating it if it doesn't exist. A new branch starts at `<start-point>` (commit, branch, or tag) if given |
| `wt pr <number>`  | Fetch a GitHub pull request and check it out in a worktree |
| `wt clean`        | Multi-select and remove worktrees whose branch is merged or whose upstream is gone |
| `wt -d <branch>`  | Remove the worktree for `<branch>`, deleting the local branch too if it is fully merged |
| `wt -l`           | List all worktrees with their paths                |
| `wt init <shell>` | Print shell integration for bash, zsh, or fish     |
| `wt -h`           | Show help                                          |
| `wt -v`           | Show version                                       |

### Worktree hooks (`.wtconfig`)

A fresh worktree is a clean checkout — it's missing the untracked files that make a repo usable (`.env`, `node_modules`, build caches). Drop a `.wtconfig` at the repo root and `wt` will prepare each **newly created** worktree for you:

```ini
# .wtconfig
copy = .env                # copy a file/dir from the primary worktree
copy = .env.local
link = node_modules        # symlink instead of copy (good for big dirs)
postCreate = pnpm install  # shell command run inside the new worktree
```

- `copy` / `link` / `postCreate` may each appear multiple times; they run in that order.
- `copy` and `link` sources are resolved against the **primary** worktree; missing sources are skipped with a notice.
- `postCreate` runs with the new worktree as the working directory and can read `$WT_BRANCH`, `$WT_PATH`, and `$WT_SOURCE`.
- All hook output goes to stderr, so the shell wrapper still `cd`s you in cleanly. Set `WT_NO_HOOKS=1` to skip hooks for one run.

Because hooks leave untracked files behind, `wt -d` and `wt clean` force past **untracked** files when removing a worktree but still refuse to delete one with uncommitted changes to **tracked** files.

### `wt pr`

`wt pr <number>` fetches `refs/pull/<number>/head` from `origin` (or your first remote) into a local branch and checks it out in a worktree — perfect for reviewing a PR without disturbing your current work. If [`gh`](https://cli.github.com) is installed, the worktree is named after the PR's head branch; otherwise it falls back to `pr-<number>`.

### `wt clean`

`wt clean` finds worktrees whose branch is fully merged into the default branch or whose upstream has been deleted (`[gone]`), and offers them in an fzf multi-select list (`Tab` to mark, `Enter` to remove). Without fzf it prints the candidates so you can remove them with `wt -d`.

### Shell integration

`wt` prints the selected worktree path to stdout. A subprocess can't change the parent shell's working directory, so `wt init <shell>` outputs a thin wrapper function that captures the path and `cd`s into it. It also provides tab completions for branches, worktrees, and options.

### Keyboard shortcuts (fzf picker)

| Key      | Action                          |
| -------- | ------------------------------- |
| `Enter`  | Select worktree (prints path)   |
| `Ctrl-D` | Delete the highlighted worktree |

The preview pane on the right shows the last 10 commits for the highlighted worktree.

## Environment variables

| Variable      | Description                        | Default                  |
| ------------- | ---------------------------------- | ------------------------ |
| `WT_BASE_DIR` | Parent directory for new worktrees | `<repo>/_worktrees` |
| `WT_NO_HOOKS` | When set, skip `.wtconfig` copy/link/postCreate hooks | _(unset)_ |

When `WT_BASE_DIR` is not set, new worktrees are created in a `_worktrees/` directory at the root of the repository. Branch names with slashes (e.g. `rec/my-branch`) are flattened to a single directory (`_worktrees/rec-my-branch`); the branch itself keeps its original name.

## Man page

A man page is included at `doc/wt.1`. To install it:

```sh
# With make
make install-man

# Or manually
cp doc/wt.1 /usr/local/share/man/man1/
```

After installing, view it with `man wt`.

## License

[MIT](LICENSE)
