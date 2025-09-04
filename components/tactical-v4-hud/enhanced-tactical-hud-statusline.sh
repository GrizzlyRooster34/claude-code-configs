#!/data/data/com.termux/files/usr/bin/bash
# Seven Tactical HUD v3.1 - Fixed ANSI rendering and formatting
# Advanced statusline with model aliases, context tracking, and tactical display

# Configuration
PALETTE_MODE=${SEVEN_PALETTE:-"tactical"}  # tactical, neon, highcontrast
WINDOW_WIDTH=20  # 5-hour flex window bar width

# Check for jq availability once at startup
HAVE_JQ=0
command -v jq >/dev/null 2>&1 && HAVE_JQ=1

# Color palettes - using printf to ensure proper ANSI rendering
setup_colors() {
  case "$PALETTE_MODE" in
    "neon")
      # Neon palette - bright cyberpunk colors
      C_MODEL=$(printf '\033[95m')     # Bright magenta
      C_CONTEXT=$(printf '\033[96m')   # Bright cyan
      C_USER=$(printf '\033[92m')      # Bright green
      C_HOST=$(printf '\033[93m')      # Bright yellow
      C_CWD=$(printf '\033[94m')       # Bright blue
      C_GIT=$(printf '\033[91m')       # Bright red
      C_TIME=$(printf '\033[97m')      # Bright white
      C_BAR_USED=$(printf '\033[91m')  # Bright red
      C_BAR_FREE=$(printf '\033[92m')  # Bright green
      ;;
    "highcontrast")
      # High contrast for accessibility
      C_MODEL=$(printf '\033[97m')     # Bright white
      C_CONTEXT=$(printf '\033[93m')   # Bright yellow
      C_USER=$(printf '\033[92m')      # Bright green
      C_HOST=$(printf '\033[94m')      # Bright blue
      C_CWD=$(printf '\033[96m')       # Bright cyan
      C_GIT=$(printf '\033[91m')       # Bright red
      C_TIME=$(printf '\033[97m')      # Bright white
      C_BAR_USED=$(printf '\033[91m')  # Bright red
      C_BAR_FREE=$(printf '\033[92m')  # Bright green
      ;;
    *)
      # Tactical palette (default) - military/subdued colors
      C_MODEL=$(printf '\033[32m')     # Green
      C_CONTEXT=$(printf '\033[33m')   # Yellow
      C_USER=$(printf '\033[36m')      # Cyan
      C_HOST=$(printf '\033[90m')      # Dark gray
      C_CWD=$(printf '\033[34m')       # Blue
      C_GIT=$(printf '\033[31m')       # Red
      C_TIME=$(printf '\033[37m')      # Light gray
      C_BAR_USED=$(printf '\033[31m')  # Red
      C_BAR_FREE=$(printf '\033[32m')  # Green
      ;;
  esac
  C_RESET=$(printf '\033[0m')
  C_DIM=$(printf '\033[90m')
  C_PURP=$(printf '\033[35m')   # Purple for Opus 4.1
  C_CYAN=$(printf '\033[36m')   # Cyan for Sonnet 4
  C_GREEN=$(printf '\033[32m')  # Green for aliases
  C_RED=$(printf '\033[31m')    # Red for aliases
  C_GRAY=$(printf '\033[37m')   # Gray for other models
  C_YEL=$(printf '\033[33m')    # Yellow for percentage
  C_MBLUE=$(printf '\033[94m')  # Medium blue for git repos
}

# Robust token usage extraction from input payload (JSON or text)
parse_used_limit_from_input() {
  local input="$1"
  [ -z "$input" ] && return 1
  
  # Early exit if input is clearly not useful
  case "$input" in
    ""|"{}"|\[\]|null) return 1 ;;
  esac
  
  # Method 1: JSON parsing with jq (most reliable)
  if [ $HAVE_JQ -eq 1 ]; then
    # Define multiple JSON path attempts for different Claude Code schemas
    local json_paths='
      [.context.usage.total_tokens, .context.usage.limit_tokens],
      [.usage.total_tokens, .usage.limit_tokens],
      [(.usage.input_tokens // 0) + (.usage.output_tokens // 0), .limits.total_tokens],
      [.stats.tokens_used, .stats.tokens_limit],
      [.tokens.used, .tokens.total],
      [.session.tokens_used, .session.tokens_limit]
    '
    
    # Attempt JSON parsing with error suppression
    local result
    result="$(printf '%s' "$input" | jq -r "
      first( $json_paths | select(.[0] != null and .[1] != null and .[0] > 0 and .[1] > 0) ) // empty
    " 2>/dev/null | tr -d '[],"' | awk 'NF==2 && $1>0 && $2>0 {print $1" "$2}' | head -1)"
    
    if [ -n "$result" ]; then
      printf '%s' "$result"
      return 0
    fi
  fi
  
  # Method 2: Text pattern matching with multiple format support
  local patterns=(
    # Pattern 1: "47k/200k tokens (23%)" - k suffix
    's/.*[^0-9]([0-9]+)k\/([0-9]+)k[[:space:]]*tokens.*/\1 \2/p'
    # Pattern 2: "47,000/200,000 tokens" - comma separators
    's/.*[^0-9]([0-9,]+)\/([0-9,]+)[[:space:]]*tokens.*/\1 \2/p'
    # Pattern 3: "47000/200000 tokens" - plain numbers
    's/.*[^0-9]([0-9]+)\/([0-9]+)[[:space:]]*tokens.*/\1 \2/p'
    # Pattern 4: "Used: 47k, Limit: 200k" - separate labels
    's/.*[Uu]sed:[[:space:]]*([0-9]+)k.*[Ll]imit:[[:space:]]*([0-9]+)k.*/\1 \2/p'
    # Pattern 5: "47M/200M tokens" - M suffix (millions)
    's/.*[^0-9]([0-9]+)[Mm]\/([0-9]+)[Mm][[:space:]]*tokens.*/\1 \2/p'
  )
  
  local pattern result used_raw limit_raw used limit
  for pattern in "${patterns[@]}"; do
    result="$(printf '%s' "$input" | sed -nE "$pattern" | head -1)"
    [ -z "$result" ] && continue
    
    # Parse the two numbers
    used_raw="$(printf '%s' "$result" | awk '{print $1}')"
    limit_raw="$(printf '%s' "$result" | awk '{print $2}')"
    
    # Validate we have numeric values
    case "$used_raw$limit_raw" in
      *[!0-9,]*) continue ;;  # Skip if contains non-numeric chars (except commas)
    esac
    
    # Remove commas and convert based on suffix detection in original pattern
    used="$(printf '%s' "$used_raw" | tr -d ',')"
    limit="$(printf '%s' "$limit_raw" | tr -d ',')"
    
    # Apply multipliers based on which pattern matched
    case "$pattern" in
      *k*) 
        # k suffix patterns - multiply by 1000
        used=$((used * 1000))
        limit=$((limit * 1000))
        ;;
      *[Mm]*)
        # M suffix patterns - multiply by 1000000
        used=$((used * 1000000))
        limit=$((limit * 1000000))
        ;;
    esac
    
    # Validate reasonable ranges (basic sanity check)
    if [ "$used" -gt 0 ] && [ "$limit" -gt 0 ] && [ "$used" -le "$limit" ] && [ "$limit" -le 10000000 ]; then
      printf '%s %s' "$used" "$limit"
      return 0
    fi
  done
  
  # Method 3: Fallback percentage-based estimation
  local pct_match
  pct_match="$(printf '%s' "$input" | sed -nE 's/.*[^0-9]([0-9]+)%[[:space:]]*\(?([0-9,]+)k?\)?[[:space:]]*tokens.*/\1 \2/p' | head -1)"
  if [ -n "$pct_match" ]; then
    local percentage total_raw total
    percentage="$(printf '%s' "$pct_match" | awk '{print $1}')"
    total_raw="$(printf '%s' "$pct_match" | awk '{print $2}')"
    total="$(printf '%s' "$total_raw" | tr -d ',')"
    
    # If ends with 'k' in original, multiply by 1000
    case "$total_raw" in
      *k) total=$((total * 1000)) ;;
    esac
    
    if [ "$percentage" -gt 0 ] && [ "$percentage" -le 100 ] && [ "$total" -gt 0 ]; then
      local estimated_used=$((total * percentage / 100))
      printf '%s %s' "$estimated_used" "$total"
      return 0
    fi
  fi
  
  # No patterns matched
  return 1
}

# Model limit determination
model_limit(){
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

# Token usage estimation
estimate_used_tokens(){
  # Prefer direct used/limit from payload
  local pair; pair="$(parse_used_limit_from_input)"
  if [ -n "$pair" ]; then
    echo "$pair" | awk '{print $1}'; return
  fi

  # Try JSON fallbacks
  if [ $HAVE_JQ -eq 1 ]; then
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

  # Final fallback: transcript bytes / 3
  if [ -n "$TRANSCRIPT" ] && [ -r "$TRANSCRIPT" ]; then
    b="$(wc -c < "$TRANSCRIPT" 2>/dev/null || echo 0)"
    [ "$b" -gt 0 ] && echo $(( b / 3 )) && return
  fi

  echo 0
}

# Model aliases
model_alias(){
  case "$MODEL_RAW" in
    *"Opus 4.1"*)   printf '%s%s%s %s(Nuke)%s' "$C_PURP" "$MODEL_RAW" "$C_RESET" "$C_RED" "$C_RESET" ;;
    *"Sonnet 4"*|*"3.7 Sonnet"*)
                    printf '%s%s%s %s(Snipper)%s' "$C_CYAN" "$MODEL_RAW" "$C_RESET" "$C_GREEN" "$C_RESET" ;;
    *)              printf '%s%s%s' "$C_GRAY" "$MODEL_RAW" "$C_RESET" ;;
  esac
}

# --- ctx displays (keep as-is if already present with same logic) ---
ctx_used_of_limit(){
  local limit="$(model_limit)"
  local used="$(estimate_used_tokens)"
  [ "$used" -lt 0 ] && used=0
  [ "$used" -gt "$limit" ] && used="$limit"
  printf '%s%dk/%dk%s' "$C_GRAY" $((used/1000)) $((limit/1000)) "$C_RESET"
}
ctx_pre_compact(){
  local limit="$(model_limit)"
  local used="$(estimate_used_tokens)"
  local remain=$(( limit - used )); [ $remain -lt 0 ] && remain=0
  printf '%sctx pre-compact %dk%s' "$C_GRAY" $((remain/1000)) "$C_RESET"
}


# ---------- 5h Window: first message of day anchor -> contiguous blocks ----------

# Config
WINDOW_SECONDS=18000                                 # 5 hours
FIRST_ANCHOR_ENV="${CLAUDE_FIRST_MSG:-}"            # optional override (epoch)
# Use Termux-friendly directory instead of /tmp (which is read-only)
ANCHOR_DIR="/data/data/com.termux/files/home/.claude"                                   
TODAY_KEY="$(date +%Y%m%d 2>/dev/null || busybox date +%Y%m%d)"
FIRST_ANCHOR_FILE="${ANCHOR_DIR}/.claude_first_msg_${TODAY_KEY}"
BLOCK_FILE="${ANCHOR_DIR}/.claude_block_start_${TODAY_KEY}"  # for inspection, not required

# Create anchor directory if it doesn't exist
mkdir -p "$ANCHOR_DIR" 2>/dev/null

# Helpers
now_epoch() { date +%s 2>/dev/null || busybox date +%s; }
hh_local()  { date -d @"$1" +%H 2>/dev/null || busybox date -u -D %s -d "$1" +%H; }
hm_label()  { date -d @"$1" +%H:%M 2>/dev/null || busybox date -u -D %s -d "$1" +%H:%M; }

NOW_S="$(now_epoch)"

# 1) Establish "first message of day" anchor
#    Priority: env > existing file > create now (only if we're in morning band 06–12)
establish_first_anchor() {
  local anchor="$FIRST_ANCHOR_ENV"
  if [ -z "$anchor" ] && [ -f "$FIRST_ANCHOR_FILE" ]; then
    anchor="$(cat "$FIRST_ANCHOR_FILE" 2>/dev/null)"
  fi
  if [ -z "$anchor" ]; then
    # only lock automatically if first render happens in morning band (06–12)
    local hour_now="$(date +%H 2>/dev/null || busybox date +%H)"
    if [ "$hour_now" -ge 6 ] && [ "$hour_now" -le 12 ]; then
      anchor="$NOW_S"
      printf '%s' "$anchor" > "$FIRST_ANCHOR_FILE"
    else
      # If we render outside 06–12 with no anchor yet, assume "now"
      # (You can still override via env or helper function.)
      anchor="$NOW_S"
      printf '%s' "$anchor" > "$FIRST_ANCHOR_FILE"
    fi
  fi
  echo "$anchor"
}

FIRST_MSG_ANCHOR="$(establish_first_anchor)"

# 2) Compute the current 5h block index and its bounds (contiguous blocks from the anchor)
delta=$(( NOW_S - FIRST_MSG_ANCHOR ))
[ $delta -lt 0 ] && delta=0
BLOCK_INDEX=$(( delta / WINDOW_SECONDS ))                    # 0-based
BLOCK_START=$(( FIRST_MSG_ANCHOR + BLOCK_INDEX * WINDOW_SECONDS ))
BLOCK_END=$(( BLOCK_START + WINDOW_SECONDS ))
printf '%s' "$BLOCK_START" > "$BLOCK_FILE"

# 3) Within-block usage
used_s=$(( NOW_S - BLOCK_START ))
[ $used_s -lt 0 ] && used_s=0
[ $used_s -gt $WINDOW_SECONDS ] && used_s=$WINDOW_SECONDS
used_pct=$(( (used_s * 100) / WINDOW_SECONDS ))
[ $used_pct -lt 0 ] && used_pct=0
[ $used_pct -gt 100 ] && used_pct=100

# 4) Bar printer (RED used / GREEN unused)
bar10_used_remaining(){
  local p=$1 u=$((p/10)) r=$((10-u)) i
  for i in $(seq 1 $u); do printf '%s█' "$C_RED"; done
  for i in $(seq 1 $r); do printf '%s░' "$C_GREEN"; done
  printf '%s' "$C_RESET"
}
window_bar(){
  printf '['; bar10_used_remaining "$used_pct"; printf '] %s%d%%%s' "$C_YEL" "$used_pct" "$C_RESET"
}

# 5) Label builder: show the current block window HH–HH
LBL_START_H="$(hh_local "$BLOCK_START")"
LBL_END_H="$(hh_local "$BLOCK_END")"
hour_block_label(){ printf '%sB%s%s %s–%s%s' "$C_CYAN" "$((BLOCK_INDEX+1))" "$C_RESET" "$LBL_START_H" "$LBL_END_H" "$C_RESET"; }

# Git status with upstream tracking
git_line(){
  command -v git >/dev/null 2>&1 || return
  git -C "$CWD" rev-parse --is-inside-work-tree >/dev/null 2>&1 || return
  local br top repo dirty="" arrows="" upstream ahead=0 behind=0
  br="$(git -C "$CWD" symbolic-ref --short HEAD 2>/dev/null || git -C "$CWD" rev-parse --short HEAD 2>/dev/null || echo 'detached')"
  top="$(git -C "$CWD" rev-parse --show-toplevel 2>/dev/null)"; repo="$(basename "$top" 2>/dev/null)"

  # flags: * (dirty unstaged), + (staged), ? (untracked)
  git -C "$CWD" diff --quiet -- . 2>/dev/null || dirty="*"
  git -C "$CWD" diff --cached --quiet -- . 2>/dev/null || dirty="${dirty}+"
  [ -n "$(git -C "$CWD" ls-files --others --exclude-standard 2>/dev/null)" ] && dirty="${dirty}?"

  upstream="$(git -C "$CWD" rev-parse --abbrev-ref --symbolic-full-name @{u} 2>/dev/null)"
  if [ -n "$upstream" ]; then
    ahead="$(git -C "$CWD" rev-list --count "$upstream"..HEAD 2>/dev/null || echo 0)"
    behind="$(git -C "$CWD" rev-list --count HEAD.."$upstream" 2>/dev/null || echo 0)"
    [ "$ahead" -gt 0 ]  && arrows=" ${C_YEL}↑$ahead${C_RESET}"
    [ "$behind" -gt 0 ] && arrows="${arrows} ${C_YEL}↓$behind${C_RESET}"
  fi

  # clean: repo (medium blue) / branch (purple)
  # pending: both segments green
  if [ -n "$dirty" ] || [ -n "$arrows" ]; then
    printf ' %s%s%s/%s%s%s%s' "$C_GREEN" "$repo" "$C_RESET" "$C_GREEN" "$br$dirty" "$C_RESET" "$arrows"
  else
    printf ' %s%s%s/%s%s%s' "$C_MBLUE" "$repo" "$C_RESET" "$C_PURP" "$br" "$C_RESET"
  fi
}


# Main execution
setup_colors

# Read JSON input from stdin
input=$(cat 2>/dev/null)

# Extract info using jq if available, otherwise use defaults
if command -v jq >/dev/null 2>&1 && [ -n "$input" ]; then
  model_name=$(printf '%s' "$input" | jq -r '.model.display_name // "Claude"' 2>/dev/null)
  cwd=$(printf '%s' "$input" | jq -r '.workspace.current_dir // ""' 2>/dev/null)
  session_id=$(printf '%s' "$input" | jq -r '.session_id // "unknown"' 2>/dev/null)
  TRANSCRIPT=$(printf '%s' "$input" | jq -r '.transcript_path // ""' 2>/dev/null)
else
  model_name="Claude"
  cwd="$PWD"
  session_id="unknown"
  TRANSCRIPT=""
fi

# Use current directory if not provided
[ -z "$cwd" ] || [ ! -d "$cwd" ] && cwd="$PWD"

# Basic system info
hour=$(date +%H | sed 's/^0//')  # Remove leading zero
minute=$(date +%M)
dow=$(date +%a)
user=$(whoami)
host=$(hostname -s 2>/dev/null || hostname 2>/dev/null || echo "localhost")

# Get model alias and context info
MODEL_RAW="$model_name"
model_display=$(model_alias)
context_tokens=$(ctx_pre_compact)

# Directory display (last 2 components)
if [ "$cwd" = "$HOME" ]; then
  dir_display="~"
else
  # Get last 2 path components
  dir_display=$(printf "%s" "$cwd" | awk -F/ '{if(NF>2) print $(NF-1)"/"$NF; else if(NF==2) print $NF; else print $0}')
  # Replace home prefix with ~
  if [ "${cwd#$HOME/}" != "$cwd" ]; then
    dir_display="~/${dir_display}"
  fi
fi

# Git information
CWD="$cwd"
git_info=$(git_line)

# Window bar is now calculated above with new logic

# Force terminal to recognize ANSI codes
export TERM=${TERM:-xterm-256color}

# Output Seven Tactical HUD v3.1 - Clean 3-line format with proper ANSI handling
printf "\n"

# Line 1: ModelBadge(Alias) / ctx pre-compact / [WINDOW BAR %]
printf "%s / ${C_CONTEXT}%s${C_RESET} / " "$model_display" "$context_tokens"
window_bar
printf "\n"

# Line 2: user@host :: cwd(last2) - repo/branch*+? ↑N↓M  
printf "${C_USER}%s${C_RESET}@${C_HOST}%s${C_RESET} :: ${C_CWD}%s${C_RESET}" "$user" "$host" "$dir_display"
if [ -n "$git_info" ]; then
  printf "%s" "$git_info"
fi
printf "\n"

# Line 3: DOW HH:mm | Flex HH–HH (5-hour window)
printf "${C_TIME}%s %02d:%s${C_RESET} ${C_DIM}|${C_RESET} " "$dow" "$hour" "$minute"
hour_block_label
printf " ${C_DIM}(5-hour window)${C_RESET}\n"