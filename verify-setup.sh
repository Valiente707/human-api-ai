#!/usr/bin/env bash
# verify-setup.sh — confirm the local environment can run /last30days and
# /valor-intel productively before you start Week 1.
#
# Usage: ./verify-setup.sh
# Exit 0 = green, exit 1 = at least one critical check failed.

set -uo pipefail  # NOT -e: keep going through all checks

# Source the user's env file if present, so we see the same env vars
# /last30days will see when invoked from a freshly opened shell.
ENV_FILE="${HOME}/.config/valor-intel/env"
if [[ -r "$ENV_FILE" ]]; then
    # shellcheck disable=SC1090
    source "$ENV_FILE"
fi

GREEN="$(tput setaf 2 2>/dev/null || true)"
YELLOW="$(tput setaf 3 2>/dev/null || true)"
RED="$(tput setaf 1 2>/dev/null || true)"
RESET="$(tput sgr0 2>/dev/null || true)"
BOLD="$(tput bold 2>/dev/null || true)"

PASS=0
WARN=0
FAIL=0

pass() { echo "  ${GREEN}ok${RESET}   $*"; PASS=$((PASS+1)); }
warn() { echo "  ${YELLOW}warn${RESET} $*"; WARN=$((WARN+1)); }
fail() { echo "  ${RED}FAIL${RESET} $*"; FAIL=$((FAIL+1)); }
section() { echo ""; echo "${BOLD}$*${RESET}"; }

# ---------- Env file ----------
section "Env file"
if [[ -r "$ENV_FILE" ]]; then
    pass "$ENV_FILE present (perms: $(stat -c '%a' "$ENV_FILE" 2>/dev/null || stat -f '%A' "$ENV_FILE" 2>/dev/null || echo '?'))"
else
    warn "$ENV_FILE missing — run ./install-skills.sh to provision it, or set env vars another way"
fi

# ---------- Python ----------
section "Python"
if command -v python3 >/dev/null; then
    py=$(python3 --version 2>&1 | awk '{print $2}')
    minor=$(echo "$py" | awk -F. '{print $1*100 + $2}')
    if (( minor >= 312 )); then
        pass "python3 = $py"
    else
        fail "python3 = $py (last30days requires 3.12+) — macOS: brew install python@3.12"
    fi
else
    fail "python3 not found — install Python 3.12+ before running /last30days"
fi

# ---------- Skills installed ----------
section "Skills installed at ~/.claude/skills"
if [[ -f "$HOME/.claude/skills/last30days/SKILL.md" || \
      -f "$HOME/.claude/skills/last30days/README.md" ]]; then
    pass "last30days/ present"
else
    fail "last30days/ missing — run ./install-skills.sh"
fi
if [[ -f "$HOME/.claude/skills/valor-intel/SKILL.md" ]]; then
    pass "valor-intel/ present"
else
    fail "valor-intel/ missing — run ./install-skills.sh"
fi

# ---------- Reddit reachability (the real cloud-IP test) ----------
section "Reddit reachability — this is the test that matters"
if ! command -v curl >/dev/null; then
    warn "curl not found, skipping Reddit check"
else
    code=$(curl -sS -o /dev/null -w '%{http_code}' \
        -A "Mozilla/5.0 valor-intel-verify" \
        --max-time 10 \
        "https://www.reddit.com/r/Dentistry/top.json?limit=1" || echo "000")
    case "$code" in
        200) pass "Reddit returned 200 — residential IP confirmed. /last30days will work." ;;
        403) fail "Reddit returned 403 — you're on a datacenter/cloud IP. /last30days will produce empty briefs. Switch to your home network." ;;
        429) warn "Reddit returned 429 (rate limited). Wait a minute and re-run this script." ;;
        000) warn "Could not reach Reddit (network error). Are you online?" ;;
        *)   warn "Reddit returned HTTP $code — unexpected. Check connectivity." ;;
    esac
fi

# ---------- Tier 2: free, one-step setup ----------
section "Tier 2 sources (free, one-step)"
if command -v yt-dlp >/dev/null; then
    pass "yt-dlp on PATH ($(yt-dlp --version 2>&1 | head -1)) — YouTube enabled"
else
    warn "yt-dlp not installed — YouTube disabled. brew install yt-dlp"
fi

# X/Twitter cookie sniffing is cross-browser/OS pain. Just remind.
warn "X/Twitter: open https://x.com in any browser and confirm you're logged in (skill picks up the browser session)"

if [[ -n "${BLUESKY_HANDLE:-}" && -n "${BLUESKY_APP_PASSWORD:-}" ]]; then
    pass "Bluesky configured ($BLUESKY_HANDLE)"
else
    warn "Bluesky disabled — export BLUESKY_HANDLE and BLUESKY_APP_PASSWORD"
fi

# ---------- Tier 3: free-tier sign-up + Perplexity (paid) ----------
section "Tier 3 sources (sign-up / Perplexity paid)"
if [[ -n "${SCRAPECREATORS_API_KEY:-}" ]]; then
    pass "ScrapeCreators key set — TikTok, Instagram, Threads, Pinterest enabled"
else
    warn "SCRAPECREATORS_API_KEY unset — TikTok/Instagram/Threads/Pinterest disabled. Free 10K calls/mo at https://scrapecreators.com"
fi

if [[ -n "${OPENROUTER_API_KEY:-}" ]]; then
    pass "OpenRouter key set — Perplexity Sonar Pro enabled"
else
    warn "OPENROUTER_API_KEY unset — Perplexity disabled. Sign up at https://openrouter.ai"
fi

if [[ -n "${BRAVE_API_KEY:-}" ]]; then
    pass "Brave Search key set — Web source enabled"
else
    warn "BRAVE_API_KEY unset — Web (Brave) disabled. Free 2K queries/mo at https://brave.com/search/api"
fi

# ---------- Runtime config ----------
section "Runtime config"
if [[ -n "${INCLUDE_SOURCES:-}" ]]; then
    pass "INCLUDE_SOURCES=$INCLUDE_SOURCES"
    # Warn if not full coverage
    full="x,youtube,bluesky,tiktok,instagram,threads,pinterest,perplexity,web"
    missing=()
    for src in ${full//,/ }; do
        case ",${INCLUDE_SOURCES}," in
            *,${src},*) ;;
            *) missing+=("$src") ;;
        esac
    done
    if (( ${#missing[@]} > 0 )); then
        warn "Not at full coverage. Missing: ${missing[*]}. For all 13 sources: export INCLUDE_SOURCES=$full"
    fi
else
    warn "INCLUDE_SOURCES unset — only Reddit/HN/Polymarket/GitHub will be queried. For full coverage: export INCLUDE_SOURCES=x,youtube,bluesky,tiktok,instagram,threads,pinterest,perplexity,web"
fi

# ---------- Summary ----------
echo ""
echo "${BOLD}Summary:${RESET} ${GREEN}${PASS} pass${RESET}  ${YELLOW}${WARN} warn${RESET}  ${RED}${FAIL} fail${RESET}"
if (( FAIL > 0 )); then
    echo ""
    echo "${RED}One or more critical checks failed.${RESET} Fix the FAIL items above before running /last30days for Week 1."
    exit 1
fi
echo ""
echo "${GREEN}You're set.${RESET} In Claude Code, try:"
echo "  /last30days \"AI marketing platforms for medical and dental practices\""
exit 0
