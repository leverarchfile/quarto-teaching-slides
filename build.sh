#!/bin/sh

set -eu

SLIDES_DIR="slides"
OUTPUT_DIR="_output"
IMAGES_DIR="assets/images"
MAX_WIDTH=1920
MAX_HEIGHT=1080

usage() {
    echo "Usage: $0 --week N | --all"
    exit 1
}

optimise_images() {
    dir="$1"
    if [ ! -d "$dir" ]; then return; fi
    echo "Optimising images in ${dir}..."
    find "$dir" -type f \( -iname "*.jpg" -o -iname "*.jpeg" \) \
        -exec mogrify -resize "${MAX_WIDTH}x${MAX_HEIGHT}>" {} \;
    find "$dir" -type f -iname "*.png" \
        -exec mogrify -resize "${MAX_WIDTH}x${MAX_HEIGHT}>" {} \;
}

render_week() {
    week="$1"
    padded=$(printf "%02d" "$week")
    src="${SLIDES_DIR}/week-${padded}.qmd"
    slides_out="${OUTPUT_DIR}/slides"

    if [ ! -f "$src" ]; then
        echo "File not found: $src"
        exit 1
    fi

    optimise_images "${IMAGES_DIR}/week-${padded}"
    echo "Rendering week ${padded}..."

    # Temp symlink: Pandoc resolves resource paths relative to the source file (slides/),
    # so slides/assets/... must exist for embed-resources to find background images
    ln -s ../assets "${SLIDES_DIR}/assets"

    # Speaker HTML (default profile)
    quarto render "$src"
    mv "${slides_out}/week-${padded}.html" "${OUTPUT_DIR}/week-${padded}-speaker.html"

    # Handout HTML
    quarto render "$src" --profile handout
    mv "${slides_out}/week-${padded}.html" "${OUTPUT_DIR}/week-${padded}.html"

    # Remove temp symlink
    rm -f "${SLIDES_DIR}/assets"

    # Move shared _files assets (same for both HTML versions; handout version is last)
    if [ -d "${slides_out}/week-${padded}_files" ]; then
        rm -rf "${OUTPUT_DIR}/week-${padded}_files"
        mv "${slides_out}/week-${padded}_files" "${OUTPUT_DIR}/"
    fi

    # Clean up empty slides temp dir
    rmdir "${slides_out}" 2>/dev/null || true

    echo "Done: week ${padded}"
}

if [ "$#" -eq 0 ]; then
    usage
fi

WEEK=""
ALL=false

while [ "$#" -gt 0 ]; do
    case "$1" in
        --week) WEEK="$2"; shift; shift ;;
        --all)  ALL=true; shift ;;
        *)      usage ;;
    esac
done

mkdir -p "$OUTPUT_DIR"

if [ -n "$WEEK" ]; then
    render_week "$WEEK"
elif [ "$ALL" = "true" ]; then
    for qmd in "${SLIDES_DIR}"/week-*.qmd; do
        num=$(basename "$qmd" .qmd | sed 's/week-//')
        num=$(printf "%d" "$num")
        render_week "$num"
    done
else
    usage
fi
