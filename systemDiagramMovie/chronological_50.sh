#!/bin/bash
set -e

DIAGRAM_FILE="../Docs/ApplicationViewControllerH.pages"
OUTPUT_DIR="./frames_50_chrono"
TEMP_DIR="./temp_50_chrono"

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

log() { echo -e "${GREEN}[$(date +'%H:%M:%S')] $1${NC}"; }
info() { echo -e "${BLUE}[INFO] $1${NC}"; }

log "Setting up chronological extraction (oldest to newest)..."

# Clean up any existing frame files
rm -f ./frame_*.png 2>/dev/null || true
rm -f ./frames_*/*.png 2>/dev/null || true

# Setup directories
mkdir -p "$OUTPUT_DIR" "$TEMP_DIR"
rm -f "$OUTPUT_DIR"/* "$TEMP_DIR"/* 2>/dev/null || true

# Get commits in REVERSE chronological order (oldest first) - last 50
log "Getting last 50 commits in chronological order (oldest first)..."
commits=($(git log --oneline --follow --reverse "$DIAGRAM_FILE" | tail -50 | awk '{print $1}'))

total_commits=${#commits[@]}
log "Processing $total_commits commits chronologically..."

# Process each commit
successful_extractions=0
for i in "${!commits[@]}"; do
    commit=${commits[$i]}
    frame_name="frame_$(printf "%03d" $i)"
    
    log "Processing commit $commit ($((i+1))/$total_commits) - chronological order..."
    
    # Extract file from commit
    temp_file="$TEMP_DIR/diagram_$commit.pages"
    if ! git show "$commit:$DIAGRAM_FILE" > "$temp_file" 2>/dev/null; then
        info "Could not extract file from commit $commit"
        continue
    fi
    
    # Extract preview image
    extract_dir="$TEMP_DIR/extract_$commit"
    mkdir -p "$extract_dir"
    
    if unzip -q "$temp_file" -d "$extract_dir" 2>/dev/null && [ -f "$extract_dir/preview.jpg" ]; then
        output_file="$OUTPUT_DIR/$frame_name.png"
        
        # Convert to PNG
        if command -v magick >/dev/null 2>&1; then
            magick "$extract_dir/preview.jpg" "$output_file"
        elif command -v convert >/dev/null 2>&1; then
            convert "$extract_dir/preview.jpg" "$output_file"
        else
            cp "$extract_dir/preview.jpg" "$output_file"
        fi
        
        # Get commit info
        commit_msg=$(git log --format="%s" -n 1 "$commit")
        commit_date=$(git log --format="%ai" -n 1 "$commit" | cut -d' ' -f1)
        
        # Add commit info in upper left corner - purple text, half size (12pt instead of 24pt)
        if command -v magick >/dev/null 2>&1; then
            magick "$output_file" \
                    -pointsize 12 -fill purple -stroke white -strokewidth 0.5 \
                    -gravity NorthWest -annotate +10+10 "Commit $commit $commit_msg $commit_date" \
                    "$output_file"
        elif command -v convert >/dev/null 2>&1; then
            convert "$output_file" \
                    -pointsize 12 -fill purple -stroke white -strokewidth 0.5 \
                    -gravity NorthWest -annotate +10+10 "Commit $commit $commit_msg $commit_date" \
                    "$output_file"
        fi
        
        info "Created $frame_name.png (chronological #$((i+1)))"
        ((successful_extractions++))
    else
        info "Could not extract preview from commit $commit"
    fi
done

log "Successfully extracted $successful_extractions out of $total_commits commits"

if [ $successful_extractions -eq 0 ]; then
    log "No frames created - cannot make movie"
    exit 1
fi

# Create movie from chronological frames
log "Creating chronological movie from $successful_extractions frames..."
if ffmpeg -y -framerate 2 -pattern_type glob -i "$OUTPUT_DIR/*.png" \
           -c:v libx264 -pix_fmt yuv420p \
           -vf "scale=1920:1080:force_original_aspect_ratio=decrease,pad=1920:1080:(ow-iw)/2:(oh-ih)/2" \
           "system_evolution_chronological_50.mp4"; then
    
    log "Movie created successfully: system_evolution_chronological_50.mp4"
    info "Frames: $successful_extractions"
    info "Duration: ~$((successful_extractions/2)) seconds at 2fps"
    info "Shows evolution from oldest to newest commits"
    
    # Show first and last commit info
    first_commit=${commits[0]}
    last_commit=${commits[$((total_commits-1))]}
    
    first_date=$(git log --format="%ai" -n 1 "$first_commit" | cut -d' ' -f1)
    last_date=$(git log --format="%ai" -n 1 "$last_commit" | cut -d' ' -f1)
    
    info "Time span: $first_date to $last_date"
    info "First commit: $first_commit"
    info "Last commit: $last_commit"
else
    log "Failed to create movie"
    exit 1
fi

# Cleanup temp files
rm -rf "$TEMP_DIR"

log "Process completed!"
echo ""
echo "📁 Files created:"
echo "   Frames: $OUTPUT_DIR/"
echo "   Movie:  system_evolution_chronological_50.mp4"
echo ""
echo "🎬 Movie shows your system diagram evolution chronologically"
echo "   from oldest commit to newest commit over time"