#!/bin/bash
set -e

DIAGRAM_FILE="../Docs/ApplicationViewControllerH.pages"
OUTPUT_DIR="./frames_recent_debug"
TEMP_DIR="./temp_recent_debug"

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
PURPLE='\033[0;35m'
NC='\033[0m'

log() { echo -e "${GREEN}[$(date +'%H:%M:%S')] $1${NC}"; }
info() { echo -e "${BLUE}[INFO] $1${NC}"; }
warn() { echo -e "${YELLOW}[WARN] $1${NC}"; }
highlight() { echo -e "${PURPLE}[RECENT] $1${NC}"; }

highlight "Setting up RECENT DEBUGGING EVOLUTION extraction (post-Sep 9 commits)..."

# Clean up any existing frame files
rm -f ./frame_*.png 2>/dev/null || true
rm -f ./frames_recent_debug/*.png 2>/dev/null || true

# Setup directories
mkdir -p "$OUTPUT_DIR" "$TEMP_DIR"
rm -f "$OUTPUT_DIR"/* "$TEMP_DIR"/* 2>/dev/null || true

# Get commits since last movie creation (Sep 9, 2025) in chronological order (oldest first)
log "Getting recent commits since Sep 9, 2025 in chronological order..."
commits=($(git log --oneline --since="2025-09-09" --follow --reverse "$DIAGRAM_FILE" | awk '{print $1}'))

total_commits=${#commits[@]}
highlight "Processing $total_commits recent debugging commits chronologically..."
info "These commits represent the latest system architecture changes"

if [ $total_commits -eq 0 ]; then
    warn "No recent commits found since Sep 9, 2025"
    exit 1
fi

# Process each commit
successful_extractions=0
for i in "${!commits[@]}"; do
    commit=${commits[$i]}
    frame_name="frame_$(printf "%04d" $i)"

    info "Processing recent commit $commit ($((i+1))/$total_commits)..."

    # Extract file from commit
    temp_file="$TEMP_DIR/diagram_$commit.pages"
    if ! git show "$commit:$DIAGRAM_FILE" > "$temp_file" 2>/dev/null; then
        warn "Could not extract file from commit $commit"
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
        commit_datetime=$(git log --format="%ai" -n 1 "$commit" | cut -d'+' -f1 | sed 's/ /T/')
        commit_msg=$(git log --format="%s" -n 1 "$commit" | cut -c1-40)

        # Add commit info with debugging focus - bright purple text for recent changes
        text_overlay="RECENT: $((i+1))/$total_commits $commit_datetime"
        msg_overlay="Debug: $commit_msg"

        if command -v magick >/dev/null 2>&1; then
            magick "$output_file" \
                    -pointsize 14 -fill purple -stroke white -strokewidth 0.7 \
                    -gravity NorthWest -annotate +10+10 "$text_overlay" \
                    -pointsize 12 -fill darkviolet -stroke white -strokewidth 0.5 \
                    -gravity NorthWest -annotate +10+30 "$msg_overlay" \
                    "$output_file"
        elif command -v convert >/dev/null 2>&1; then
            convert "$output_file" \
                    -pointsize 14 -fill purple -stroke white -strokewidth 0.7 \
                    -gravity NorthWest -annotate +10+10 "$text_overlay" \
                    -pointsize 12 -fill darkviolet -stroke white -strokewidth 0.5 \
                    -gravity NorthWest -annotate +10+30 "$msg_overlay" \
                    "$output_file"
        fi

        ((successful_extractions++))

        # Clean up extraction directory to save space
        rm -rf "$extract_dir"
    else
        warn "Could not extract preview from commit $commit"
    fi

    # Clean up temp file to save space
    rm -f "$temp_file"
done

log "Successfully extracted $successful_extractions out of $total_commits recent commits"

if [ $successful_extractions -eq 0 ]; then
    log "No frames created - cannot make movie"
    exit 1
fi

# Create movie from recent debugging frames at 2 fps (slower for detailed viewing)
log "Creating RECENT DEBUGGING EVOLUTION movie from $successful_extractions frames at 2 fps..."
if ffmpeg -y -framerate 2 -pattern_type glob -i "$OUTPUT_DIR/*.png" \
           -c:v libx264 -pix_fmt yuv420p \
           -vf "scale=1920:1080:force_original_aspect_ratio=decrease,pad=1920:1080:(ow-iw)/2:(oh-ih)/2" \
           "system_evolution_recent_debugging.mp4"; then

    highlight "RECENT DEBUGGING movie created successfully: system_evolution_recent_debugging.mp4"
    info "Total frames: $successful_extractions"
    info "Duration: ~$((successful_extractions/2)) seconds at 2fps"
    info "Shows latest debugging evolution since Sep 9, 2025"

    # Show first and last commit info
    first_commit=${commits[0]}
    last_commit=${commits[$((total_commits-1))]}

    first_date=$(git log --format="%ai" -n 1 "$first_commit" | cut -d' ' -f1)
    last_date=$(git log --format="%ai" -n 1 "$last_commit" | cut -d' ' -f1)

    info "Recent debugging span: $first_date to $last_date"
    info "First recent commit: $first_commit"
    info "Latest commit: $last_commit"

    # File size info
    movie_size=$(ls -lh "system_evolution_recent_debugging.mp4" | awk '{print $5}')
    info "Movie file size: $movie_size"
else
    log "Failed to create movie"
    exit 1
fi

# Cleanup temp files
rm -rf "$TEMP_DIR"

highlight "Recent debugging evolution extraction completed!"
echo ""
echo "🎬 RECENT DEBUGGING EVOLUTION MOVIE CREATED!"
echo "=============================================="
echo ""
echo "📁 Files created:"
echo "   Frames: $OUTPUT_DIR/ ($successful_extractions frames)"
echo "   Movie:  system_evolution_recent_debugging.mp4"
echo ""
echo "🎯 Movie specifications:"
echo "   • Recent $successful_extractions commits since Sep 9, 2025"
echo "   • 2 frames per second (detailed viewing)"
echo "   • 1920x1080 HD resolution"
echo "   • Purple text: 'RECENT: N/Total YYYY-MM-DDTHH:MM:SS'"
echo "   • Violet text: commit messages (debugging focus)"
echo "   • Chronological order: oldest → newest recent changes"
echo ""
echo "⏱  This represents your latest debugging session evolution!"
echo "🔍 Focus: debugging, morning work, version updates, vewBase fixes"