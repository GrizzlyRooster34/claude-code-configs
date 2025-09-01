export GOOGLE_API_KEY="AIzaSyCU4FCl7Pa1pbfuBvAOLbqi33mICORgz0U"

### CLAUDE↔GEMINI BRIDGE (Termux)
# When set, Claude Code will talk to the local bridge (Gemini backend).
export ANTHROPIC_API_URL="http://127.0.0.1:8787"

# Quick switches
cc_use_gemini() {
  export ANTHROPIC_API_URL="http://127.0.0.1:8787"
  echo "[Claude Code] → Gemini via local bridge at \$ANTHROPIC_API_URL"
}
cc_use_anthropic() {
  unset ANTHROPIC_API_URL
  echo "[Claude Code] → Direct Anthropic (default Sonnet in IDE)"
}

# Convenience: start bridge in a new Termux session (if using Termux:API sessions)
cc_bridge() { "$HOME/start-claude-gemini.sh"; }
cc_bridge_keepalive() { "$HOME/bridge-keepalive.sh"; }
### END CLAUDE↔GEMINI BRIDGE
export PATH="$HOME/bin:$PATH"
