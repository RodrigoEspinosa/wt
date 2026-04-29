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
wt -d my-feature      # Remove a worktree
wt -l                 # List all worktrees
```

### Commands

| Command           | Description                                        |
| ----------------- | -------------------------------------------------- |
| `wt`              | Launch fzf to fuzzy-pick a worktree                |
| `wt <branch>`     | Switch to the worktree for `<branch>`, creating it if it doesn't exist |
| `wt -d <branch>`  | Remove the worktree (and local branch) for `<branch>` |
| `wt -l`           | List all worktrees with their paths                |
| `wt init <shell>` | Print shell integration for bash, zsh, or fish     |
| `wt -h`           | Show help                                          |
| `wt -v`           | Show version                                       |

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
