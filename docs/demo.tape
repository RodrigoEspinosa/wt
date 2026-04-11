# vhs tape for wt demo — render with: vhs docs/demo.tape
# https://github.com/charmbracelet/vhs

Output docs/demo.gif

Set Shell "zsh"
Set FontSize 16
Set Width 1000
Set Height 600
Set Theme "Dracula"
Set TypingSpeed 60ms
Set PlaybackSpeed 1.0

# Assumes the shell integration is already loaded:
#   eval "$(wt init zsh)"

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
Sleep 1500ms

# Show we actually changed directory
Type "pwd"
Enter
Sleep 1500ms

# Jump to an existing worktree by name (no fzf)
Type "wt main"
Enter
Sleep 1500ms

Type "pwd"
Enter
Sleep 1500ms

# Same command creates the worktree if it doesn't exist yet
Type "wt scratch-demo"
Enter
Sleep 2000ms

Type "pwd"
Enter
Sleep 1500ms

# Clean up
Type "wt -d scratch-demo"
Enter
Sleep 2000ms
