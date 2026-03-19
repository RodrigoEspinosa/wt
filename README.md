# wt

Git worktree manager powered by [fzf](https://github.com/junegunn/fzf).

Quickly list, switch to, create, or remove git worktrees with fuzzy search.

## Install

### Homebrew

```sh
brew install <user>/tap/wt
```

### From source

```sh
git clone https://github.com/<user>/wt.git
cd wt
make install
```

## Dependencies

- `git`
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

### Shell integration

`wt` needs a shell function to `cd` into worktrees (a subprocess can't change the parent shell's directory). Add to your `~/.zshrc`, `~/.bashrc`, or `~/.config/fish/config.fish`:

```sh
# zsh / bash
eval "$(wt init zsh)"   # or bash

# fish
wt init fish | source
```

### Keyboard shortcuts in fzf

| Key | Action |
|-----|--------|
| `Enter` | Select worktree (prints path) |
| `Ctrl-D` | Delete the highlighted worktree |

## Environment variables

| Variable | Description | Default |
|----------|-------------|---------|
| `WT_BASE_DIR` | Parent directory for new worktrees | Sibling of the repo root |

## License

MIT
