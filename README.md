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

### Uninstall

```sh
brew uninstall wt            # Homebrew
make uninstall               # from source
```

## Requirements

- `git` 2.5 or newer (for worktree support)
- [fzf](https://github.com/junegunn/fzf)

## Usage

```sh
# Interactive fuzzy picker
wt

# Switch to a branch's worktree (creates it if it doesn't exist)
wt my-feature

# Remove a worktree
wt -d my-feature

# List all worktrees
wt -l
```

The fzf picker shows a preview pane with the last 10 commits of the highlighted worktree.

### Shell integration

`wt` ships a small shell function (via `wt init <shell>`) that wraps the binary and `cd`s into the selected worktree — a subprocess can't change the parent shell's directory on its own. Add to your `~/.zshrc`, `~/.bashrc`, or `~/.config/fish/config.fish`:

```sh
# zsh / bash
eval "$(wt init zsh)"   # or bash

# fish
wt init fish | source
```

### Keyboard shortcuts in fzf

| Key      | Action                          |
| -------- | ------------------------------- |
| `Enter`  | Select worktree (prints path)   |
| `Ctrl-D` | Delete the highlighted worktree |

## Environment variables

| Variable      | Description                        | Default                  |
| ------------- | ---------------------------------- | ------------------------ |
| `WT_BASE_DIR` | Parent directory for new worktrees | Sibling of the repo root |

## License

MIT
