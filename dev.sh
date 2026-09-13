#!/bin/sh
set -eu

SLIDES_DIR="slides"

usage() {
    echo "Usage: $0 --week N [--port PORT]"
    exit 1
}

WEEK=""
PORT=8888

while [ "$#" -gt 0 ]; do
    case "$1" in
        --week) WEEK="$2"; shift; shift ;;
        --port) PORT="$2"; shift; shift ;;
        *)      usage ;;
    esac
done

[ -z "$WEEK" ] && usage

padded=$(printf "%02d" "$WEEK")
src="${SLIDES_DIR}/week-${padded}.qmd"

if [ ! -f "$src" ]; then
    echo "File not found: $src"
    exit 1
fi

# Symlink so Pandoc can resolve assets/images/... relative to slides/
ln -sf ../assets "${SLIDES_DIR}/assets"
trap 'rm -f "${SLIDES_DIR}/assets"' EXIT INT TERM

echo "Dev preview: week ${padded} on port ${PORT}"
echo "Open: http://localhost:${PORT}/slides/week-${padded}.html"

quarto preview "$src" --profile dev --no-browser --port "$PORT"
