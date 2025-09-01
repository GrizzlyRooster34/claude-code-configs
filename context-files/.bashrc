alias uc="echo \"claude-sonnet-4-20250514 • 92k/200k tokens (46%)\" | ~/.claude/update_context.sh"

# Context update function for Claude statusline
uc() {
    echo "Updating context cache from /context..."
    /context 2>&1 | ~/.claude/update_context.sh
}
