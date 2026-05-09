#!/usr/bin/env bash
# Bundle the Valor Intel skill into a .skill file for upload to claude.ai.
#
# Usage:    ./make-skill-bundle.sh
# Output:   valor-intel.skill (in the repo root)
# Upload:   claude.ai project -> Skills -> Upload -> select valor-intel.skill
#
# Pair this with the upstream last30days-skill in the same project:
# https://github.com/mvanhorn/last30days-skill

set -euo pipefail

cd "$(dirname "$0")"

SKILL_DIR="valor-intel"
OUTPUT="valor-intel.skill"

[[ -f "$SKILL_DIR/SKILL.md" ]] || {
    echo "error: $SKILL_DIR/SKILL.md not found in $(pwd)" >&2
    exit 1
}

command -v zip >/dev/null || {
    echo "error: 'zip' not installed (apt-get install zip / brew install zip)" >&2
    exit 1
}

rm -f "$OUTPUT"
# Zip the *contents* of valor-intel/ so SKILL.md sits at the archive root.
( cd "$SKILL_DIR" && zip -rq "../$OUTPUT" . -x '*.DS_Store' '__MACOSX/*' )

echo "Built $OUTPUT"
ls -lh "$OUTPUT"
