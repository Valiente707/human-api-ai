#!/usr/bin/env bash
# Install the local pieces of the Valor Intel setup:
#   1. Symlink valor-intel/ to ~/.claude/skills/valor-intel/ so /valor-intel
#      is picked up by Claude Code.
#   2. Provision the API-key env file at ~/.config/valor-intel/env (chmod 600).
#   3. Print the Claude Code commands you run yourself to install the
#      upstream last30days plugin (which uses the marketplace path,
#      not a manual git clone).
#
# Usage:        ./install-skills.sh
# Idempotent:   re-running refreshes the symlink and leaves an existing env
#               file alone.
# Uninstall:    rm ~/.claude/skills/valor-intel
#               rm ~/.config/valor-intel/env   # only if you want to wipe keys
#               In Claude Code: /plugin marketplace remove mvanhorn/last30days-skill

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")" && pwd)"
SKILLS_DIR="${HOME}/.claude/skills"
VALOR_SRC="${REPO_ROOT}/valor-intel"
VALOR_LINK="${SKILLS_DIR}/valor-intel"

mkdir -p "$SKILLS_DIR"

# 1. Link valor-intel/ from this repo so edits here flow through immediately
if [[ ! -d "$VALOR_SRC" ]]; then
    echo "error: $VALOR_SRC not found. Run this script from the repo root." >&2
    exit 1
fi
if [[ -e "$VALOR_LINK" || -L "$VALOR_LINK" ]]; then
    rm -rf "$VALOR_LINK"
fi
ln -s "$VALOR_SRC" "$VALOR_LINK"
echo "Linked $VALOR_LINK -> $VALOR_SRC"

# 2. Provision env file at ~/.config/valor-intel/env (don't overwrite an existing one)
ENV_DIR="${HOME}/.config/valor-intel"
ENV_FILE="${ENV_DIR}/env"
ENV_TEMPLATE="${VALOR_SRC}/env.template"
mkdir -p "$ENV_DIR"
if [[ -f "$ENV_FILE" ]]; then
    echo "Env file already exists at $ENV_FILE (leaving it alone)."
else
    cp "$ENV_TEMPLATE" "$ENV_FILE"
    chmod 600 "$ENV_FILE"
    echo "Created $ENV_FILE (perms 600)."
    echo "  -> Fill in your API keys before running /last30days."
fi
echo ""
echo "To make your shell load the env file automatically, add this line"
echo "to ~/.bashrc (Git Bash on Windows) or ~/.zshrc (macOS) once:"
echo "    [ -r ~/.config/valor-intel/env ] && source ~/.config/valor-intel/env"
echo "Then open a new terminal (or 'source' the rc file)."

# 3. Python version check (last30days requires 3.12+)
if command -v python3 >/dev/null; then
    py_version=$(python3 --version 2>&1 | awk '{print $2}')
    py_minor=$(echo "$py_version" | awk -F. '{print $1*100 + $2}')
    if (( py_minor < 312 )); then
        echo "WARNING: last30days requires Python 3.12+ (you have $py_version)."
        echo "         macOS:  brew install python@3.12"
        echo "         Windows: install from https://python.org/downloads/"
        echo "         pyenv:  pyenv install 3.12 && pyenv global 3.12"
    else
        echo "Python: $py_version (ok)"
    fi
else
    echo "WARNING: python3 not found. Install Python 3.12+ before running /last30days."
fi

# 4. Final instructions — manual steps the user runs in Claude Code itself
cat <<'EOF'

Now finish the install in Claude Code. These are slash commands you
type INTO Claude Code, not into a shell:

  /plugin marketplace add mvanhorn/last30days-skill

Claude Code will fetch the marketplace manifest and prompt you to install
the last30days plugin. After that, /last30days is available as a slash
command alongside /valor-intel.

Optional source setup (skip if Reddit + HN are enough — see playbook §1a):
  YouTube:    brew install yt-dlp        (macOS)  |  pipx install yt-dlp
  X/Twitter:  stay logged in to x.com in any browser
  TikTok/IG:  set SCRAPECREATORS_API_KEY in ~/.config/valor-intel/env
  Perplexity: set OPENROUTER_API_KEY  in ~/.config/valor-intel/env
  Brave Web:  set BRAVE_API_KEY       in ~/.config/valor-intel/env
  Bluesky:    set BLUESKY_HANDLE + BLUESKY_APP_PASSWORD

Reddit, Hacker News, Polymarket, and GitHub work with zero config from
a residential IP. (Cloud/datacenter IPs hit a Reddit 403 — that's just
Reddit's policy, not a bug.)

Done with the script. In Claude Code, try:
  /last30days "AI marketing platforms for medical and dental practices"
  /valor-intel              # runs the full weekly routine
EOF
