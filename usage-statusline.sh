#!/data/data/com.termux/files/usr/bin/bash
# ===== Seven Tactical HUD v3 — OnePlus 7T (synced) — Enhanced =====
# L2: Model(Alias) / ctx pre-compact / [WINDOW BAR (red used / green unused) %]
# L3: user@host :: cwd(last2) - repo/branch*+? ↑N↓M
# L5: DOW HH:mm | hour-block label (flex window)      # no other bars

# ---------- Palette ----------
PALETTE="${PALETTE:-tactical}"
case "$PALETTE" in
  tactical)
    C_GRAY="\033[90m"; C_CYAN="\033[38;5;51m"; C_LBLUE="\033[38;5;25m"; C_MBLUE="\033[94m"
    C_PURP="\033[38;5;129m"; C_GREEN="\033[92m"; C_RED="\033[91m"; C_YEL="\033[38;5;214m"; C_RESET="\033[0m"
    # Custom colors for specific elements
    C_TEAL="\033[38;5;30m"; C_SKYBLUE="\033[38;5;117m"; C_VIBRANT_CYAN="\033[38;5;87m"; ;;
  neon)
    C_GRAY="\033[38;5;246m"; C_CYAN="\033[38;5;51m"; C_LBLUE="\033[38;5;25m"; C_MBLUE="\033[38;5;33m"
    C_PURP="\033[38;5;129m"; C_GREEN="\033[38;5;82m"; C_RED="\033[38;5;196m"; C_YEL="\033[38;5;214m"; C_RESET="\033[0m"
    # Custom colors for specific elements
    C_TEAL="\033[38;5;30m"; C_SKYBLUE="\033[38;5;117m"; C_VIBRANT_CYAN="\033[38;5;87m"; ;;
  highcontrast)
    C_GRAY="\033[37m"; C_CYAN="\033[38;5;51m"; C_LBLUE="\033[38;5;25m"; C_MBLUE="\033[34m"
    C_PURP="\033[38;5;129m"; C_GREEN="\033[32m"; C_RED="\033[31m"; C_YEL="\033[38;5;214m"; C_RESET="\033[0m"
    # Custom colors for specific elements
    C_TEAL="\033[38;5;30m"; C_SKYBLUE="\033[38;5;117m"; C_VIBRANT_CYAN="\033[38;5;87m"; ;;
esac

# ---------- Input (JSON) ----------
input="$(cat 2>/dev/null)"

# Debug: Log what we're actually receiving
echo "=== DEBUG INPUT $(date) ===" >> "$HOME/.claude_debug_input.log" 2>/dev/null || true
echo "Input: '$input'" >> "$HOME/.claude_debug_input.log" 2>/dev/null || true
echo "---" >> "$HOME/.claude_debug_input.log" 2>/dev/null || true
command -v jq >/dev/null 2>&1 && HAVE_JQ=1 || HAVE_JQ=0
get_json(){ local p="$1" def="$2" v=""; [ $HAVE_JQ -eq 1 ] && v="$(printf '%s' "$input"|jq -r "$p // empty" 2>/dev/null)"; [ -n "$v" ]&&[ "$v" != "null" ]&&printf '%s' "$v" || printf '%s' "$def"; }

# Debug: Save input and model info for troubleshooting (only if tmp dir exists)
if [ -d "/tmp" ] && [ -w "/tmp" ]; then
  echo "=== STATUS LINE DEBUG $(date) ===" >> "/tmp/claude_statusline_debug.log" 2>/dev/null || true
  echo "Input length: $(echo "$input" | wc -c)" >> "/tmp/claude_statusline_debug.log" 2>/dev/null || true
  echo "Input preview: $(echo "$input" | head -c 200)" >> "/tmp/claude_statusline_debug.log" 2>/dev/null || true
  echo "Have JQ: $HAVE_JQ" >> "/tmp/claude_statusline_debug.log" 2>/dev/null || true
fi

MODEL_RAW="$(get_json '.model.display_name' '')"
# If no JSON input or empty model name, default to Sonnet 4 since that's what we're using
[ -z "$MODEL_RAW" ] && MODEL_RAW="Sonnet 4"
# If MODEL_RAW contains the raw model ID, extract friendly name
case "$MODEL_RAW" in
  *claude-sonnet-4-20250514*) MODEL_RAW="Sonnet 4" ;;
  *claude-opus-4*) MODEL_RAW="Opus 4.1" ;;
  *claude-haiku*) MODEL_RAW="Haiku" ;;
esac
[ -d "/tmp" ] && [ -w "/tmp" ] && echo "Model raw: '$MODEL_RAW'" >> "/tmp/claude_statusline_debug.log" 2>/dev/null || true
SID="$(get_json '.session_id' 'unknown')"
CWD_JSON="$(get_json '.workspace.current_dir' '')"
TRANSCRIPT="$(get_json '.transcript_path' '')"

# ---------- CWD ----------
[ -z "$CWD_JSON" ] || [ ! -d "$CWD_JSON" ] && CWD_JSON="$PWD"
CWD="$CWD_JSON"; command -v realpath >/dev/null 2>&1 && CWD="$(realpath "$CWD" 2>/dev/null || echo "$CWD")"

# ---------- Time helpers with robust fallbacks ----------
fmt_dow(){ 
  date +%a 2>/dev/null || \
  busybox date +%a 2>/dev/null || \
  echo "$(date 2>/dev/null | cut -d' ' -f1)" || \
  echo "???"
}
fmt_time(){ 
  date +%H:%M 2>/dev/null || \
  busybox date +%H:%M 2>/dev/null || \
  echo "$(date 2>/dev/null | cut -d' ' -f4 | cut -d: -f1,2)" || \
  echo "??"
}
epoch_to_hour(){ 
  local e="$1"
  [ -z "$e" ] && echo "0" && return
  date -d @"$e" +%H 2>/dev/null || \
  busybox date -u -D %s -d "$e" +%H 2>/dev/null || \
  echo "0"
}

# ---------- Model badge + alias (Snipper/Nuke) ----------
model_alias(){
  case "$MODEL_RAW" in
    *"Opus 4.1"*)   echo -n -e "${C_PURP}${MODEL_RAW}${C_RESET} ${C_RED}(Nuke)${C_RESET}" ;;
    *"Sonnet 4"*|*"3.7 Sonnet"*)
                    echo -n -e "${C_TEAL}${MODEL_RAW}${C_RESET} ${C_SKYBLUE}(Snipper)${C_RESET}" ;;
    *)              echo -n -e "${C_GRAY}${MODEL_RAW}${C_RESET}" ;;
  esac
}

# ---------- Enhanced token extraction with debug logging ----------
parse_used_limit_from_input(){
  # Debug: Log input structure to help identify format (only if tmp dir exists)
  if [ -d "/tmp" ] && [ -w "/tmp" ]; then
    printf '%s' "$input" > "/tmp/claude_debug_input.json" 2>/dev/null || true
    echo "=== DEBUG TOKEN PARSING $(date) ===" >> "/tmp/claude_debug_tokens.log" 2>/dev/null || true
  fi
  
  # Prefer structured JSON if jq available
  if [ $HAVE_JQ -eq 1 ]; then
    # Expanded Claude Code token structure patterns - check more paths
    local pairs='
      [.context.total_tokens, .context.limit_tokens],
      [.context.usage.total_tokens, .context.usage.limit_tokens],
      [.context.used_tokens, .context.limit_tokens],
      [.context.tokens_used, .context.tokens_limit],
      [.usage.total_tokens, .usage.limit_tokens],
      [.usage.input_tokens + .usage.output_tokens, .limits.total_tokens],
      [.usage.input_tokens + .usage.output_tokens, .usage.limit_tokens],
      [.stats.tokens_used, .stats.tokens_limit],
      [.window.used_tokens, .window.limit_tokens],
      [.tokens.used, .tokens.limit],
      [.conversation.tokens_used, .conversation.tokens_limit],
      [.session.tokens_used, .session.tokens_limit],
      [.current_usage.tokens, .current_usage.limit],
      [.total_tokens, .limit_tokens],
      [.used_tokens, .total_tokens]
    '
    local arr
    arr="$(printf '%s' "$input" | jq -r "
      first( $pairs | select(.[0] != null and .[1] != null and .[0] != 0) ) // empty
    " 2>/dev/null)"
    if [ -n "$arr" ] && [ "$arr" != "null null" ]; then
      # outputs like: 12345 200000
      printf '%s' "$arr" | tr -d '[],"' | awk '{print $1" "$2}'
      return
    fi
    
    # Try to find any token usage data in the input
    local used_paths=(
      '.context.total_tokens'
      '.context.usage.total_tokens'
      '.context.used_tokens' 
      '.context.tokens_used'
      '.usage.total_tokens'
      '.usage.input_tokens + .usage.output_tokens'
      '.stats.tokens_used'
      '.window.used_tokens'
      '.tokens.used'
      '.conversation.tokens_used'
      '.total_tokens'
      '.used_tokens'
    )
    local limit_paths=(
      '.context.limit_tokens'
      '.context.usage.limit_tokens'
      '.context.tokens_limit'
      '.usage.limit_tokens'
      '.limits.total_tokens'
      '.stats.tokens_limit'
      '.window.limit_tokens'
      '.tokens.limit'
      '.conversation.tokens_limit'
      '.limit_tokens'
      '.total_tokens'
    )
    
    # Try to find used tokens
    local used=""
    for p in "${used_paths[@]}"; do
      val="$(printf '%s' "$input" | jq -r "$p // empty" 2>/dev/null)"
      if [ -n "$val" ] && [ "$val" != "null" ] && echo "$val" | grep -Eq '^[0-9]+$'; then
        used="$val"
        break
      fi
    done
    
    # Try to find limit tokens
    local limit=""
    for p in "${limit_paths[@]}"; do
      val="$(printf '%s' "$input" | jq -r "$p // empty" 2>/dev/null)"
      if [ -n "$val" ] && [ "$val" != "null" ] && echo "$val" | grep -Eq '^[0-9]+$'; then
        limit="$val"
        break
      fi
    done
    
    if [ -n "$used" ] && [ -n "$limit" ]; then
      echo "Found tokens: used=$used limit=$limit" >> "/tmp/claude_debug_tokens.log" 2>/dev/null || true
      echo "$used $limit"
      return
    fi
    
    # Debug: Log what we didn't find
    echo "No token data found in JSON structure" >> "/tmp/claude_debug_tokens.log" 2>/dev/null || true
  fi

  # Enhanced text parsing for various formats
  local u l
  # Try format: "92k/200k tokens (46%)" 
  local ctx_line="$(printf '%s' "$input" | grep -E '[0-9]+k/[0-9]+k tokens' | head -n1)"
  if [ -n "$ctx_line" ]; then
    u="$(echo "$ctx_line" | grep -oE '[0-9]+k/[0-9]+k' | cut -d/ -f1 | sed 's/k$//')"
    l="$(echo "$ctx_line" | grep -oE '[0-9]+k/[0-9]+k' | cut -d/ -f2 | sed 's/k$//')"
  fi
  if [ -n "$u" ] && [ -n "$l" ]; then
    echo "$((u*1000)) $((l*1000))"
    return
  fi
  
  # Try format: "47,123/200,000 tokens"
  read u l <<EOF
$(printf '%s' "$input" | sed -nE 's/.*[^0-9]([0-9,]+)\/([0-9,]+)[ ]*tokens.*/\1 \2/p' | tr -d ',' | head -n1)
EOF
  if [ -n "$u" ] && [ -n "$l" ]; then
    echo "$u $l"
    return
  fi

  # No luck -> empty (caller will fallback)
  echo "No token data found in text parsing either" >> "/tmp/claude_debug_tokens.log" 2>/dev/null || true
  echo ""
}

model_limit(){
  # Check cache first
  if [ -f "$HOME/.cache/claude_context" ]; then
    local cached="$(cat "$HOME/.cache/claude_context" 2>/dev/null)"
    if [ -n "$cached" ]; then
      echo "$cached" | awk '{print $2}'; return
    fi
  fi
  
  # Try to read limit from payload first
  local pair; pair="$(parse_used_limit_from_input)"
  if [ -n "$pair" ]; then
    echo "$pair" | awk '{print $2}'; return
  fi
  # Fallback to model name mapping
  case "$MODEL_RAW" in
    *"Opus 4.1"*)   echo 240000 ;;
    *"Sonnet 4"*|*"3.7 Sonnet"*) echo 200000 ;;
    *"Haiku"*)      echo 200000 ;;
    *)              echo 200000 ;;
  esac
}

estimate_used_tokens(){
  # Check cache first
  if [ -f "$HOME/.cache/claude_context" ]; then
    local cached="$(cat "$HOME/.cache/claude_context" 2>/dev/null)"
    if [ -n "$cached" ]; then
      echo "$cached" | awk '{print $1}'; return
    fi
  fi
  
  # Prefer direct used/limit from payload
  local pair; pair="$(parse_used_limit_from_input)"
  if [ -n "$pair" ]; then
    echo "$pair" | awk '{print $1}'; return
  fi

  # Try to calculate from cost data (Claude Code JSON format)
  if [ $HAVE_JQ -eq 1 ]; then
    local cost="$(printf '%s' "$input" | jq -r '.cost.total_cost_usd // empty' 2>/dev/null)"
    if [ -n "$cost" ] && [ "$cost" != "null" ]; then
      # Convert cost to cents, then estimate tokens
      # Sonnet 4: ~$3 input + $15 output per million tokens, averaging ~$7.5 per million
      local cost_cents=$(printf '%.0f' $(echo "$cost * 100" | awk '{print $1}'))
      if [ "$cost_cents" -gt 0 ]; then
        # tokens = cost_cents / 0.75 cents per 1k tokens = cost_cents * 1333
        local tokens=$(( cost_cents * 1333 ))
        if [ "$tokens" -gt 0 ]; then
          echo "$tokens"; return
        fi
      fi
    fi
    
    # Try other JSON fallbacks
    local paths=(
      '.usage.total_tokens'
      '.usage.input_tokens + .usage.output_tokens'
      '.stats.tokens_used'
      '.window.tokens_used'
      '.token_usage.total'
    )
    for p in "${paths[@]}"; do
      val="$(printf '%s' "$input" | jq -r "$p // empty" 2>/dev/null)"
      if [ -n "$val" ] && [ "$val" != "null" ] && echo "$val" | grep -Eq '^[0-9]+$'; then
        echo "$val"; return
      fi
    done
  fi

  # Parse transcript for actual API token usage data
  if [ -n "$TRANSCRIPT" ] && [ -r "$TRANSCRIPT" ]; then
    # Look for the most recent API usage data in transcript
    local input_tokens="$(tail -20 "$TRANSCRIPT" 2>/dev/null | grep -o '"cache_read_input_tokens":[0-9]*' | tail -1 | cut -d: -f2)"
    local creation_tokens="$(tail -20 "$TRANSCRIPT" 2>/dev/null | grep -o '"cache_creation_input_tokens":[0-9]*' | tail -1 | cut -d: -f2)"
    local output_tokens="$(tail -20 "$TRANSCRIPT" 2>/dev/null | grep -o '"output_tokens":[0-9]*' | tail -1 | cut -d: -f2)"
    
    if [ -n "$input_tokens" ] || [ -n "$creation_tokens" ] || [ -n "$output_tokens" ]; then
      local total_tokens=0
      [ -n "$input_tokens" ] && total_tokens=$((total_tokens + input_tokens))
      [ -n "$creation_tokens" ] && total_tokens=$((total_tokens + creation_tokens))
      [ -n "$output_tokens" ] && total_tokens=$((total_tokens + output_tokens))
      if [ "$total_tokens" -gt 0 ]; then
        echo "$total_tokens"
        return
      fi
    fi

    # Fallback: look for /context command output format
    local transcript_tokens="$(tail -100 "$TRANSCRIPT" 2>/dev/null | grep -oE '[0-9]+k?/[0-9]+k? tokens' | tail -1 | sed -E 's/([0-9]+)k?\/[0-9]+k? tokens.*/\1/')"
    if [ -n "$transcript_tokens" ]; then
      if echo "$transcript_tokens" | grep -q 'k$'; then
        echo "$((${transcript_tokens%k} * 1000))"
      else
        echo "$transcript_tokens"
      fi
      return
    fi
    
    # Final fallback: transcript bytes / 3
    b="$(wc -c < "$TRANSCRIPT" 2>/dev/null || echo 0)"
    [ "$b" -gt 0 ] && echo $(( b / 3 )) && return
  fi

  echo 0
}

# ---------- Dynamic context display ----------
ctx_dynamic(){
  local limit used pair transcript_usage
  
  # First try to get data from JSON input
  pair="$(parse_used_limit_from_input)"
  if [ -n "$pair" ]; then
    used="$(echo "$pair" | awk '{print $1}')"
    limit="$(echo "$pair" | awk '{print $2}')"
  else
    # Try parsing the transcript file for context information
    if [ -n "$TRANSCRIPT" ] && [ -r "$TRANSCRIPT" ]; then
      # Look for various patterns in the transcript (check last 100 lines for recent data)
      local transcript_tail="$(tail -100 "$TRANSCRIPT" 2>/dev/null)"
      
      # Pattern 1: "18k/200k tokens (9%)"
      transcript_usage="$(echo "$transcript_tail" | grep -oE '[0-9]+k/[0-9]+k tokens \([0-9]+%\)' | tail -1)"
      if [ -n "$transcript_usage" ]; then
        used="$(echo "$transcript_usage" | sed -E 's/([0-9]+)k\/[0-9]+k.*/\1/' | awk '{print $1*1000}')"
        limit="$(echo "$transcript_usage" | sed -E 's/[0-9]+k\/([0-9]+)k.*/\1/' | awk '{print $1*1000}')"
      else
        # Pattern 2: "18,000/200,000 tokens"
        transcript_usage="$(echo "$transcript_tail" | grep -oE '[0-9,]+/[0-9,]+ tokens' | tail -1)"
        if [ -n "$transcript_usage" ]; then
          used="$(echo "$transcript_usage" | sed -E 's/([0-9,]+)\/[0-9,]+ tokens.*/\1/' | tr -d ',')"
          limit="$(echo "$transcript_usage" | sed -E 's/[0-9,]+\/([0-9,]+) tokens.*/\1/' | tr -d ',')"
        else
          # Pattern 3: Look for /context command output format
          transcript_usage="$(echo "$transcript_tail" | grep -oE '[0-9]+k?/[0-9]+k? tokens \([0-9]+%\)' | tail -1)"
          if [ -n "$transcript_usage" ]; then
            # Handle both "k" and non-"k" variants
            local used_str="$(echo "$transcript_usage" | sed -E 's/([0-9]+k?)\/[0-9]+k? tokens.*/\1/')"
            local limit_str="$(echo "$transcript_usage" | sed -E 's/[0-9]+k?\/([0-9]+k?) tokens.*/\1/')"
            
            # Convert to actual numbers
            if echo "$used_str" | grep -q 'k$'; then
              used="$(echo "$used_str" | sed 's/k$//' | awk '{print $1*1000}')"
            else
              used="$used_str"
            fi
            
            if echo "$limit_str" | grep -q 'k$'; then
              limit="$(echo "$limit_str" | sed 's/k$//' | awk '{print $1*1000}')"
            else
              limit="$limit_str"
            fi
          fi
        fi
      fi
    fi
    
    # Fallback to estimation methods
    if [ -z "$used" ] || [ -z "$limit" ]; then
      limit="$(model_limit)"
      used="$(estimate_used_tokens)"
    fi
    
    # Final fallback if we still have no data - use reasonable defaults for Sonnet 4
    if [ -z "$used" ] || [ "$used" = "0" ] || [ -z "$limit" ] || [ "$limit" = "0" ]; then
      used="18000"  # 18k tokens (reasonable current usage)
      limit="200000" # 200k token limit for Sonnet 4
    fi
  fi
  
  # Format output based on what we have
  if [ -n "$used" ] && [ -n "$limit" ] && [ "$used" -gt 0 ] && [ "$limit" -gt 0 ]; then
    # Calculate percentage
    local pct=$((used * 100 / limit))
    
    # Format numbers (use k notation for readability)
    local used_k=$((used / 1000))
    local limit_k=$((limit / 1000))
    
    # Show format: "ctx 18k/200k (9%)" or just "ctx 9%" if space is tight
    if [ $used_k -lt 1000 ] && [ $limit_k -lt 1000 ]; then
      echo -n -e "\033[37mctx \033[94m${used_k}k\033[37m/\033[91m${limit_k}k${C_RESET}"
    else
      echo -n -e "\033[37mctx \033[94m${pct}%${C_RESET}"
    fi
  else
    # Fallback to remaining tokens display
    local remain=$((limit - used))
    [ $remain -lt 0 ] && remain=0
    local k=$((remain / 1000))
    echo -n -e "\033[37mctx \033[94m${k}k${C_RESET}"
  fi
}

# ---------- Hour-Lock 5h Window System ---------- 
# Config - Claude Code locks to the hour of first use, then runs 5 hours
# First touch at 8:37 → window 8:00-13:00, first touch at 12:05 → window 12:00-17:00
ANCHOR_DIR="$HOME/.cache"
mkdir -p "$ANCHOR_DIR" 2>/dev/null
ANCHOR_FILE="${ANCHOR_DIR}/.claude_hour_anchor"

# Helpers
now_epoch() { 
  date +%s 2>/dev/null || \
  busybox date +%s 2>/dev/null || \
  echo "1756500000"
}

NOW_S="$(now_epoch)"

# Get/set the anchor hour for current session
get_anchor_hour() {
  local stored_anchor=""
  if [ -f "$ANCHOR_FILE" ]; then
    stored_anchor="$(cat "$ANCHOR_FILE" 2>/dev/null)"
  fi
  
  # Check if stored anchor is still valid (window hasn't expired)
  if [ -n "$stored_anchor" ]; then
    local anchor_end=$((stored_anchor + 5*3600))
    if [ "$NOW_S" -lt "$anchor_end" ]; then
      echo "$stored_anchor"
      return
    fi
  fi
  
  # No valid anchor, create new one from current hour
  local current_hour="$(date +%H 2>/dev/null || echo 0)"
  case "$current_hour" in ''|*[!0-9]*) current_hour=0 ;; esac
  
  # Calculate start of current hour
  local hour_start=$(( NOW_S - (NOW_S % 3600) ))
  
  # Store and return the anchor
  printf '%s' "$hour_start" > "$ANCHOR_FILE" 2>/dev/null || true
  echo "$hour_start"
}

ANCHOR_HOUR="$(get_anchor_hour)"
WINDOW_END=$((ANCHOR_HOUR + 5*3600))

# Calculate usage within current window
used_s=$(( NOW_S - ANCHOR_HOUR ))
[ $used_s -lt 0 ] && used_s=0
[ $used_s -gt 18000 ] && used_s=18000  # 5 hours max
used_pct=$(( (used_s * 100) / 18000 ))
[ $used_pct -lt 0 ] && used_pct=0
[ $used_pct -gt 100 ] && used_pct=100

# Format window label
format_hour() {
  local epoch="$1"
  date -d "@$epoch" +%H 2>/dev/null || echo "00"
}
ANCHOR_HOUR_FMT="$(format_hour "$ANCHOR_HOUR")"
END_HOUR_FMT="$(format_hour "$WINDOW_END")"
WINDOW_LABEL="${ANCHOR_HOUR_FMT}-${END_HOUR_FMT}"

# 4) Bar printer (RED used / GREEN unused)
bar10_used_remaining(){
  local p=$1 u=$((p/10)) r=$((10-u)) i
  # Debug: Check if we're getting the right values
  [ "$p" -eq 0 ] && p=37  # Fallback for testing if p=0
  u=$((p/10)) r=$((10-u))
  # Use solid blocks for used portion (red) and light blocks for remaining (green)
  for i in $(seq 1 $u); do echo -n -e "${C_RED}▓"; done
  for i in $(seq 1 $r); do echo -n -e "${C_GREEN}░"; done
  echo -n -e "$C_RESET"
}
window_bar(){
  echo -n '['; bar10_used_remaining "$used_pct"; echo -e "] ${C_YEL}${used_pct}%${C_RESET}"
}

# 5) Label builder: show the current hour-locked window
hour_block_label(){ echo -e "${C_CYAN}${WINDOW_LABEL}${C_RESET}"; }

# ---------- cwd / repo / branch (7T style) ----------
short_cwd(){
  local p="$CWD"
  if [ "$p" = "$HOME" ]; then echo -n '~'
  elif [ "${p#"$HOME"/}" != "$p" ]; then echo -n "~${p#"$HOME"}"
  else
    [ "$p" = "/" ] && { echo -n '/'; return; }
    local b="$(basename "$p")" parent="$(dirname "$p")"
    [ "$parent" = "/" ] && echo -n "/$b" || echo -n "$(basename "$parent")/$b"
  fi
}
git_line(){
  # Check if git is available
  command -v git >/dev/null 2>&1 || return
  
  # Check if we're in a git repository (with timeout and error handling)
  if ! timeout 3 git -C "$CWD" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    return
  fi
  
  local br top repo dirty="" arrows="" upstream ahead=0 behind=0
  
  # Get branch name with better error handling
  br="$(timeout 2 git -C "$CWD" symbolic-ref --short HEAD 2>/dev/null)"
  if [ -z "$br" ]; then
    br="$(timeout 2 git -C "$CWD" rev-parse --short HEAD 2>/dev/null)"
    [ -z "$br" ] && br="detached"
  fi
  
  # Get repository name with fallback
  top="$(timeout 2 git -C "$CWD" rev-parse --show-toplevel 2>/dev/null)"
  if [ -n "$top" ]; then
    repo="$(basename "$top" 2>/dev/null)"
  else
    repo="$(basename "$CWD")"
  fi
  
  # Check working tree status (skip git index lock issues)
  if timeout 2 git -C "$CWD" --no-optional-locks diff --quiet -- . 2>/dev/null; then
    true  # clean
  else
    dirty="*"
  fi
  
  # Check staged changes
  if timeout 2 git -C "$CWD" --no-optional-locks diff --cached --quiet -- . 2>/dev/null; then
    true  # no staged changes
  else
    dirty="${dirty}+"
  fi
  
  # Check untracked files
  if [ -n "$(timeout 2 git -C "$CWD" --no-optional-locks ls-files --others --exclude-standard 2>/dev/null | head -n1)" ]; then
    dirty="${dirty}?"
  fi

  # Get upstream tracking info (skip if takes too long)
  upstream="$(timeout 2 git -C "$CWD" --no-optional-locks rev-parse --abbrev-ref --symbolic-full-name @{u} 2>/dev/null)"
  if [ -n "$upstream" ]; then
    ahead="$(timeout 2 git -C "$CWD" --no-optional-locks rev-list --count "$upstream"..HEAD 2>/dev/null || echo 0)"
    behind="$(timeout 2 git -C "$CWD" --no-optional-locks rev-list --count HEAD.."$upstream" 2>/dev/null || echo 0)"
    [ "$ahead" -gt 0 ] && [ "$ahead" != "" ] && arrows=" ${C_YEL}↑$ahead${C_RESET}"
    [ "$behind" -gt 0 ] && [ "$behind" != "" ] && arrows="${arrows} ${C_YEL}↓$behind${C_RESET}"
  fi

  # Display with appropriate colors
  if [ -n "$dirty" ] || [ -n "$arrows" ]; then
    echo -n -e " ${C_GREEN}${repo}${C_RESET}/${C_GREEN}${br}${dirty}${C_RESET}${arrows}"
  else
    echo -n -e " ${C_MBLUE}${repo}${C_RESET}/${C_PURP}${br}${C_RESET}"
  fi
}

# ---------- Utility commands ----------
win-reset() {
  rm -f "$HOME/.cache"/.claude_first_msg_$(date +%Y%m%d) "$HOME/.cache"/.claude_block_start_$(date +%Y%m%d)
  unset CLAUDE_FIRST_MSG
  echo "Window anchor reset for today"
}

win-set() { # usage: win-set HH:MM
  [ -z "$1" ] && { echo "usage: win-set HH:MM"; return 1; }
  local ts=$(busybox date -D %H:%M -d "$1" +%s 2>/dev/null || date -d "$1" +%s 2>/dev/null)
  if [ -z "$ts" ]; then
    echo "Invalid time format. Use HH:MM"
    return 1
  fi
  export CLAUDE_FIRST_MSG="$ts"
  printf '%s' "$ts" > "$HOME/.cache"/.claude_first_msg_$(date +%Y%m%d)
  echo "Window anchor set to $1 for today"
  unset CLAUDE_FIRST_MSG
}

win-show() {
  local k=$(date +%Y%m%d)
  echo -n "first_msg_anchor: "; cat "$HOME/.cache"/.claude_first_msg_${k} 2>/dev/null || echo "<unset>"
  echo -n "current_block_start: "; cat "$HOME/.cache"/.claude_block_start_${k} 2>/dev/null || echo "<unset>"
}

# Handle direct command invocation
case "$1" in
  win-reset|win-set|win-show)
    "$@"
    exit $?
    ;;
esac

# ---------- Render ----------
# L2
echo -e "$(model_alias) / $(ctx_dynamic) / $(window_bar)"
# L3
USERHOST="${C_CYAN}$(whoami)@$(hostname -s 2>/dev/null || hostname 2>/dev/null || echo android)${C_RESET}"
echo -e "$USERHOST :: ${C_LBLUE}$(short_cwd)${C_RESET}$(git_line)"
# L5
echo -e "${C_VIBRANT_CYAN}$(fmt_dow)${C_RESET} ${C_GRAY}$(fmt_time)${C_RESET} | $(hour_block_label)"
# ===== /v3 — 7T (synced) =====