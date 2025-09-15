#!/bin/bash

# Quick test with just the last 5 commits
set -e

DIAGRAM_FILE="../Docs/ApplicationViewControllerH.pages"
OUTPUT_DIR="./test_frames"
TEMP_DIR="./temp_quick"

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

log() { echo -e "${GREEN}[$(date +'%H:%M:%S')] $1${NC}"; }
info() { echo -e "${BLUE}[INFO] $1${NC}"; }

# Setup
mkdir -p "$OUTPUT_DIR" "$TEMP_DIR"
rm -f "$OUTPUT_DIR"/* "$TEMP_DIR"/* 2>/dev/null || true

# Get last 5 commits
log "Getting last 5 commits that modified $DIAGRAM_FILE..."
commits=($(git log --oneline --follow "$DIAGRAM_FILE" | head -5 | awk '{print $1}'))

log "Found ${#commits[@]} recent commits"

# Process each commit
for i in "${!commits[@]}"; do
    commit=${commits[$i]}
    frame_name="frame_$(printf "%02d" $i)"
    
    log "Processing commit $commit ($((i+1))/${#commits[@]})..."
    
    # Extract file
    temp_file="$TEMP_DIR/diagram_$commit.pages"
    git show "$commit:$DIAGRAM_FILE" > "$temp_file"
    
    # Extract preview
    extract_dir="$TEMP_DIR/extract_$commit"
    mkdir -p "$extract_dir"
    
    if unzip -q "$temp_file" -d "$extract_dir"; then
        if [ -f "$extract_dir/preview.jpg" ]; then
            output_file="$OUTPUT_DIR/$frame_name.png"
            convert "$extract_dir/preview.jpg" "$output_file"
            
            # Add commit info
            commit_msg=$(git log --format="%s" -n 1 "$commit")
            commit_date=$(git log --format="%ai" -n 1 "$commit" | cut -d' ' -f1)
            
            # Add text overlay
            convert "$output_file" \
                    -pointsize 20 -fill white -stroke black -strokewidth 1 \
                    -gravity North -annotate +0+10 "Commit: $commit" \
                    -pointsize 16 -fill white -stroke black -strokewidth 1 \
                    -gravity North -annotate +0+35 "$commit_msg" \
                    -pointsize 12 -fill white -stroke black -strokewidth 1 \
                    -gravity North -annotate +0+55 "$commit_date" \
                    "$output_file"
            
            info "Created $frame_name.png"
        fi
    fi
done

# Create a quick movie
log "Creating test movie..."
if [ $(ls -1 "$OUTPUT_DIR"/*.png 2>/dev/null | wc -l) -gt 0 ]; then
    ffmpeg -y -framerate 1 -pattern_type glob -i "$OUTPUT_DIR/*.png" \
           -c:v libx264 -pix_fmt yuv420p \
           -vf "scale=1280:720:force_original_aspect_ratio=decrease,pad=1280:720:(ow-iw)/2:(oh-ih)/2" \
           "quick_test.mp4"
    log "Test movie created: quick_test.mp4"
    log "Frames created: $(ls -1 "$OUTPUT_DIR"/*.png | wc -l)"
else
    info "No frames created - check for errors above"
fi

# Cleanup
rm -rf "$TEMP_DIR"