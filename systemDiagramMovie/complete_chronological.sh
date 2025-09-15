#!/bin/bash
set -e

DIAGRAM_FILE="../Docs/ApplicationViewControllerH.pages"
OUTPUT_DIR="./frames_all_chrono"
TEMP_DIR="./temp_all_chrono"

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

log() { echo -e "${GREEN}[$(date +'%H:%M:%S')] $1${NC}"; }
info() { echo -e "${BLUE}[INFO] $1${NC}"; }
warn() { echo -e "${YELLOW}[WARN] $1${NC}"; }

log "Setting up COMPLETE chronological extraction (ALL commits, oldest to newest)..."

# Clean up any existing frame files
rm -f ./frame_*.png 2>/dev/null || true
rm -f ./frames_*/*.png 2>/dev/null || true

# Setup directories
mkdir -p "$OUTPUT_DIR" "$TEMP_DIR"
rm -f "$OUTPUT_DIR"/* "$TEMP_DIR"/* 2>/dev/null || true

# Get ALL commits in chronological order (oldest first)
log "Getting ALL commits in chronological order (oldest first)..."
commits=($(git log --oneline --follow --reverse "$DIAGRAM_FILE" | awk '{print $1}'))

total_commits=${#commits[@]}
log "Processing ALL $total_commits commits chronologically..."
warn "This will take approximately $((total_commits/4)) minutes"

# Process each commit
successful_extractions=0
for i in "${!commits[@]}"; do
    commit=${commits[$i]}
    frame_name="frame_$(printf "%04d" $i)"
    
    # Progress indicator every 25 commits
    if (( (i + 1) % 25 == 0 )); then
        log "Progress: $((i+1))/$total_commits commits processed ($((100*(i+1)/total_commits))%)"
    fi
    
    info "Processing commit $commit ($((i+1))/$total_commits)..."
    
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
        
        # Get commit date/time (simplified format)
        commit_datetime=$(git log --format="%ai" -n 1 "$commit" | cut -d'+' -f1 | sed 's/ /T/')
        
        # Add ONLY commit number and date/time in upper left corner - purple text
        text_overlay="Commit $((i+1))/$total_commits $commit_datetime"
        
        if command -v magick >/dev/null 2>&1; then
            magick "$output_file" \
                    -pointsize 12 -fill purple -stroke white -strokewidth 0.5 \
                    -gravity NorthWest -annotate +10+10 "$text_overlay" \
                    "$output_file"
        elif command -v convert >/dev/null 2>&1; then
            convert "$output_file" \
                    -pointsize 12 -fill purple -stroke white -strokewidth 0.5 \
                    -gravity NorthWest -annotate +10+10 "$text_overlay" \
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

log "Successfully extracted $successful_extractions out of $total_commits commits"

if [ $successful_extractions -eq 0 ]; then
    log "No frames created - cannot make movie"
    exit 1
fi

# Create movie from chronological frames at 3 fps
log "Creating complete chronological movie from $successful_extractions frames at 3 fps..."
if ffmpeg -y -framerate 3 -pattern_type glob -i "$OUTPUT_DIR/*.png" \
           -c:v libx264 -pix_fmt yuv420p \
           -vf "scale=1920:1080:force_original_aspect_ratio=decrease,pad=1920:1080:(ow-iw)/2:(oh-ih)/2" \
           "system_evolution_complete_chronological.mp4"; then
    
    log "Movie created successfully: system_evolution_complete_chronological.mp4"
    info "Total frames: $successful_extractions"
    info "Duration: ~$((successful_extractions/3)) seconds at 3fps"
    info "Shows complete evolution from oldest to newest commits"
    
    # Show first and last commit info
    first_commit=${commits[0]}
    last_commit=${commits[$((total_commits-1))]}
    
    first_date=$(git log --format="%ai" -n 1 "$first_commit" | cut -d' ' -f1)
    last_date=$(git log --format="%ai" -n 1 "$last_commit" | cut -d' ' -f1)
    
    info "Complete time span: $first_date to $last_date"
    info "First commit: $first_commit"
    info "Last commit: $last_commit"
    
    # File size info
    movie_size=$(ls -lh "system_evolution_complete_chronological.mp4" | awk '{print $5}')
    info "Movie file size: $movie_size"
else
    log "Failed to create movie"
    exit 1
fi

# Cleanup temp files
rm -rf "$TEMP_DIR"

log "Complete chronological extraction completed!"
echo ""
echo "🎬 COMPLETE SYSTEM EVOLUTION MOVIE CREATED!"
echo "==========================================="
echo ""
echo "📁 Files created:"
echo "   Frames: $OUTPUT_DIR/ ($successful_extractions frames)"
echo "   Movie:  system_evolution_complete_chronological.mp4"
echo ""
echo "🎯 Movie specifications:"
echo "   • All $successful_extractions/$total_commits commits processed"
echo "   • 3 frames per second"
echo "   • 1920x1080 HD resolution"
echo "   • Purple text: 'Commit N/Total YYYY-MM-DDTHH:MM:SS'"
echo "   • Chronological order: oldest → newest"
echo ""
echo "⏱  This represents your complete system evolution timeline!"