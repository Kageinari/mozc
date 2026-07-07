#!/usr/bin/env bash
# Merge mozc-ut dictionary into dictionary00.txt at CI build time.
# Do not commit the merged dictionary00.txt (exceeds GitHub 100MB limit).

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=mozc_ut.env
source "$SCRIPT_DIR/mozc_ut.env"

WORKSPACE="${GITHUB_WORKSPACE:?GITHUB_WORKSPACE is required}"
DICT_PATH="$WORKSPACE/src/data/dictionary_oss/dictionary00.txt"
BUILD_DIR="/tmp/mozcdic-build-$$"

cleanup() {
  rm -rf "$BUILD_DIR"
}
trap cleanup EXIT

python3 -m pip install --quiet jaconv

git clone --filter=blob:none --no-checkout "$MERGE_UT_REPO" "$BUILD_DIR"
git -C "$BUILD_DIR" checkout "$MERGE_UT_REF"

cd "$BUILD_DIR/src/merge"
bash make.sh

UT_FILE="mozcdic-ut.txt"
if [[ ! -f "$UT_FILE" ]]; then
  echo "ERROR: $UT_FILE not found after merge-ut-dictionaries build" >&2
  exit 1
fi

python3 "$SCRIPT_DIR/validate_mozcdic.py" "$UT_FILE" "$MIN_UT_LINES"

UT_LINES=$(wc -l < "$UT_FILE")
cat "$UT_FILE" >> "$DICT_PATH"
TOTAL_LINES=$(wc -l < "$DICT_PATH")

echo "mozc-ut merged: ${UT_LINES} UT lines from ${MERGE_UT_REF:0:8}"
echo "dictionary00.txt total lines: ${TOTAL_LINES}"
echo "NOTE: merged dictionary00.txt must not be committed to git"