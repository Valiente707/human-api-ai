#!/usr/bin/env bash
# Install last30days-skill + valor-intel into ~/.claude/skills/ so they're
# available as /last30days and /valor-intel inside Claude Code on your laptop.
#
# Usage:        ./install-skills.sh
# Idempotent:   re-running pulls the latest last30days and refreshes the
#               valor-intel symlink to this repo.
# Uninstall:    rm -rf ~/.claude/skills/last30days ~/.claude/skills/valor-intel

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")" && pwd)"
SKILLS_DIR="${HOME}/.claude/skills"
LAST30DAYS_REPO="https://github.com/mvanhorn/last30days-skill.git"
LAST30DAYS_DIR="${SKILLS_DIR}/last30days"
VALOR_SRC="${REPO_ROOT}/valor-intel"
VALOR_LINK="${SKILLS_DIR}/valor-intel"

mkdir -p "$SKILLS_DIR"

# 1. Clone or update last30days-skill
if [[ -d "$LAST30DAYS_DIR/.git" ]]; then
    echo "Updating last30days-skill in $LAST30DAYS_DIR..."
    git -C "$LAST30DAYS_DIR" pull --ff-only
else
    echo "Cloning last30days-skill to $LAST30DAYS_DIR..."
    git clone --depth 1 "$LAST30DAYS_REPO" "$LAST30DAYS_DIR"
fi

# 2. Link valor-intel/ from this repo so edits here flow through immediately
if [[ ! -d "$VALOR_SRC" ]]; then
    echo "error: $VALOR_SRC not found. Run this script from the repo root." >&2
    exit 1
fi
if [[ -e "$VALOR_LINK" || -L "$VALOR_LINK" ]]; then
    rm -rf "$VALOR_LINK"
fi
ln -s "$VALOR_SRC" "$VALOR_LINK"
echo "Linked $VALOR_LINK -> $VALOR_SRC"

# 3. Python version check (last30days requires 3.12+)
echo ""
if command -v python3 >/dev/null; then
    py_version=$(python3 --version 2>&1 | awk '{print $2}')
    py_minor=$(echo "$py_version" | awk -F. '{print $1*100 + $2}')
    if (( py_minor < 312 )); then
        echo "WARNING: last30days requires Python 3.12+ (you have $py_version)."
        echo "         macOS:  brew install python@3.12"
        echo "         pyenv:  pyenv install 3.12 && pyenv global 3.12"
    else
        echo "Python: $py_version (ok)"
    fi
else
    echo "WARNING: python3 not found. Install Python 3.12+ before running /last30days."
fi

# 4. Optional sources hint
cat <<'EOF'

Optional source setup (skip if Reddit + HN are enough):
  YouTube:    brew install yt-dlp        (macOS)  |  pipx install yt-dlp
  X/Twitter:  stay logged in to x.com in any browser
  TikTok/IG:  export SCRAPECREATORS_API_KEY=...   (10K free calls)
  Bluesky:    bsky.app app password

Reddit, Hacker News, Polymarket, and GitHub work with zero config from a
residential IP. (If you ever run from a cloud/datacenter IP, Reddit will
403 you — that's not a config issue, that's just Reddit's policy.)

Done. From any directory, open Claude Code and try:
  /last30days "AI marketing platforms for medical and dental practices"
  /valor-intel              # runs the full weekly routine
EOF
