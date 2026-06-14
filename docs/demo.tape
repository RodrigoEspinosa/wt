# vhs tape for wt demo — render with: vhs docs/demo.tape
# https://github.com/charmbracelet/vhs
#
# Run from the repo root. The tape is self-contained: it uses the repo's
# bin/wt, loads the shell integration, and seeds/removes demo worktrees.

Output docs/demo.gif

Set Shell "zsh"
Set FontSize 16
Set Width 1000
Set Height 600
Set Theme "Dracula"
Set TypingSpeed 60ms
Set PlaybackSpeed 1.0

# Hidden setup: repo wt on PATH, shell integration, demo worktrees
Hide
Type `export PATH="$PWD/bin:$PATH"; eval "$(wt init zsh)"`
Enter
Type `command wt feat/fzf-picker >/dev/null; command wt feat/start-point >/dev/null; command wt feat/completions >/dev/null; clear`
Enter
Sleep 3s
Show

# Launch the fuzzy picker
Type "wt"
Sleep 500ms
Enter
Sleep 1500ms

# Fuzzy-filter
Type "feat"
Sleep 1200ms

# Move selection, show the preview pane updating
Down
Sleep 800ms
Down
Sleep 1000ms
Up
Sleep 800ms

# Jump into the highlighted worktree
Enter
Sleep 1000ms

# Show we actually changed directory
Type "pwd"
Enter
Sleep 1500ms

# Jump to an existing worktree by name (no fzf)
Type "wt master"
Enter
Sleep 1000ms

Type "pwd"
Enter
Sleep 1500ms

# Same command creates the worktree if it doesn't exist yet
Type "wt scratch-demo"
Enter
Sleep 1500ms

Type "pwd"
Enter
Sleep 1500ms

# Go back and clean up — the merged branch is deleted too
Type "wt master"
Enter
Sleep 1000ms

Type "wt -d scratch-demo"
Enter
Sleep 2500ms

# Hidden teardown: remove the demo worktrees
Hide
Type `command wt -d feat/fzf-picker; command wt -d feat/start-point; command wt -d feat/completions`
Enter
Sleep 3s
Show
