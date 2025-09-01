#!/data/data/com.termux/files/usr/bin/bash
# Context cache updater for statusline

# Create cache directory
mkdir -p "$HOME/.cache"

# Read from stdin if no args
if [ $# -eq 0 ]; then
    input="$(cat)"
else
    input="$*"
fi

# Parse and cache context data
tokens_str="$(echo "$input" | grep -oE '[0-9]+k/[0-9]+k tokens' | head -1)"
used="$(echo "$tokens_str" | cut -d/ -f1 | sed 's/k$//')"
limit="$(echo "$tokens_str" | cut -d/ -f2 | sed 's/k.*//')"

if [ -n "$used" ] && [ -n "$limit" ]; then
    # Validate they're numbers
    if echo "$used" | grep -Eq '^[0-9]+$' && echo "$limit" | grep -Eq '^[0-9]+$'; then
        echo "$((used * 1000)) $((limit * 1000))" > "$HOME/.cache/claude_context"
        echo "Context cached: ${used}k/${limit}k"
    else
        echo "Invalid context data: used='$used' limit='$limit'"
    fi
else
    echo "No context data found to cache"
fi