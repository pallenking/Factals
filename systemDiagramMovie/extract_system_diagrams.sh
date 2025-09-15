#!/bin/bash

# Script to extract system diagrams from git history and build a movie
# Usage: ./extract_system_diagrams.sh

set -e

# Configuration
DIAGRAM_FILE="../Docs/ApplicationViewControllerH.pages"
OUTPUT_DIR="./diagram_frames"
MOVIE_OUTPUT="system_evolution.mp4"
TEMP_DIR="./temp_extraction"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

log() {
    echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')] $1${NC}"
}

error() {
    echo -e "${RED}[ERROR] $1${NC}" >&2
}

warning() {
    echo -e "${YELLOW}[WARNING] $1${NC}"
}

info() {
    echo -e "${BLUE}[INFO] $1${NC}"
}

# Check if we're in a git repository
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    error "Not in a git repository!"
    exit 1
fi

# Check if the diagram file exists in the repository
if ! git ls-files --error-unmatch "$DIAGRAM_FILE" > /dev/null 2>&1; then
    error "File $DIAGRAM_FILE not found in git repository!"
    exit 1
fi

# Check dependencies
check_dependencies() {
    log "Checking dependencies..."
    
    local missing_deps=()
    
    # Check for ffmpeg (for movie creation)
    if ! command -v ffmpeg >/dev/null 2>&1; then
        missing_deps+=("ffmpeg")
    fi
    
    # Check for ImageMagick (prefer magick over convert)
    if ! command -v magick >/dev/null 2>&1 && ! command -v convert >/dev/null 2>&1; then
        missing_deps+=("imagemagick")
    fi
    
    if [ ${#missing_deps[@]} -ne 0 ]; then
        error "Missing dependencies: ${missing_deps[*]}"
        info "Install with: brew install ${missing_deps[*]}"
        exit 1
    fi
    
    log "All dependencies found!"
}

# Create necessary directories
setup_directories() {
    log "Setting up directories..."
    mkdir -p "$OUTPUT_DIR"
    mkdir -p "$TEMP_DIR"
    rm -f "$OUTPUT_DIR"/*.png 2>/dev/null || true
    rm -rf "$TEMP_DIR"/* 2>/dev/null || true
}

# Get list of commits that modified the diagram file
get_commits() {
    log "Getting commits that modified $DIAGRAM_FILE..."
    git log --oneline --follow --reverse "$DIAGRAM_FILE" | awk '{print $1}'
}

# Extract .pages file from a specific commit and convert to image
extract_and_convert() {
    local commit=$1
    local output_name=$2
    
    info "Processing commit $commit..."
    
    # Extract the file from the specific commit
    local temp_file="$TEMP_DIR/diagram_$commit.pages"
    
    if ! git show "$commit:$DIAGRAM_FILE" > "$temp_file" 2>/dev/null; then
        warning "Could not extract $DIAGRAM_FILE from commit $commit"
        return 1
    fi
    
    # .pages files are zip archives containing preview images
    local extract_dir="$TEMP_DIR/pages_extract_$commit"
    mkdir -p "$extract_dir"
    
    if unzip -q "$temp_file" -d "$extract_dir" 2>/dev/null; then
        # Look for the main preview image first (highest quality)
        local preview_image="$extract_dir/preview.jpg"
        if [ -f "$preview_image" ]; then
            # Convert to PNG and save
            local output_image="$OUTPUT_DIR/$output_name.png"
            if command -v magick >/dev/null 2>&1; then
                magick "$preview_image" "$output_image"
                info "Extracted and converted preview image from $commit to $output_name.png"
                return 0
            elif command -v convert >/dev/null 2>&1; then
                convert "$preview_image" "$output_image"
                info "Extracted and converted preview image from $commit to $output_name.png"
                return 0
            else
                # Just copy as JPG if ImageMagick not available
                cp "$preview_image" "$OUTPUT_DIR/$output_name.jpg"
                info "Extracted preview image from $commit to $output_name.jpg"
                return 0
            fi
        fi
        
        # Fallback: look for any preview image
        local any_preview=$(find "$extract_dir" -name "preview*.jpg" -o -name "preview*.png" | head -n 1)
        if [ -n "$any_preview" ] && [ -f "$any_preview" ]; then
            local output_image="$OUTPUT_DIR/$output_name.png"
            if command -v magick >/dev/null 2>&1; then
                magick "$any_preview" "$output_image"
                info "Extracted and converted fallback preview from $commit to $output_name.png"
                return 0
            elif command -v convert >/dev/null 2>&1; then
                convert "$any_preview" "$output_image"
                info "Extracted and converted fallback preview from $commit to $output_name.png"
                return 0
            else
                # Determine extension and copy
                local ext="${any_preview##*.}"
                cp "$any_preview" "$OUTPUT_DIR/$output_name.$ext"
                info "Extracted fallback preview from $commit to $output_name.$ext"
                return 0
            fi
        fi
    fi
    
    warning "Could not extract preview image from $commit - .pages file may be corrupted or in old format"
    return 1
}

# Create a movie from the extracted frames
create_movie() {
    log "Creating movie from frames..."
    
    local frame_count=$(ls -1 "$OUTPUT_DIR"/*.png 2>/dev/null | wc -l)
    if [ "$frame_count" -eq 0 ]; then
        error "No frames found in $OUTPUT_DIR"
        return 1
    fi
    
    info "Found $frame_count frames"
    
    # Create movie with ffmpeg
    # -r 0.5 means 0.5 frames per second (2 seconds per frame)
    # -pattern_type glob allows us to use wildcards
    ffmpeg -y -framerate 0.5 -pattern_type glob -i "$OUTPUT_DIR/*.png" \
           -c:v libx264 -pix_fmt yuv420p -vf "scale=1920:1080:force_original_aspect_ratio=decrease,pad=1920:1080:(ow-iw)/2:(oh-ih)/2" \
           "$MOVIE_OUTPUT"
    
    if [ $? -eq 0 ]; then
        log "Movie created successfully: $MOVIE_OUTPUT"
        info "Duration: $(ffprobe -i "$MOVIE_OUTPUT" -show_entries format=duration -v quiet -of csv="p=0" | cut -d'.' -f1) seconds"
    else
        error "Failed to create movie"
        return 1
    fi
}

# Add commit information to frames
add_commit_info() {
    local commits=("$@")
    
    log "Adding commit information to frames..."
    
    for i in "${!commits[@]}"; do
        local commit=${commits[$i]}
        local frame_file="$OUTPUT_DIR/frame_$(printf "%04d" $i).png"
        
        if [ -f "$frame_file" ]; then
            local commit_msg=$(git log --format="%s" -n 1 "$commit")
            local commit_date=$(git log --format="%ai" -n 1 "$commit")
            
            # Add text overlay using ImageMagick
            convert "$frame_file" \
                    -pointsize 24 -fill white -stroke black -strokewidth 1 \
                    -gravity North -annotate +0+20 "Commit: $commit" \
                    -pointsize 18 -fill white -stroke black -strokewidth 1 \
                    -gravity North -annotate +0+50 "$commit_msg" \
                    -pointsize 14 -fill white -stroke black -strokewidth 1 \
                    -gravity North -annotate +0+75 "$commit_date" \
                    "$frame_file"
        fi
    done
}

# Main execution
main() {
    log "Starting system diagram extraction..."
    
    check_dependencies
    setup_directories
    
    # Get all commits that modified the diagram
    local commits=($(get_commits))
    local total_commits=${#commits[@]}
    
    log "Found $total_commits commits that modified $DIAGRAM_FILE"
    
    if [ $total_commits -eq 0 ]; then
        error "No commits found that modified $DIAGRAM_FILE"
        exit 1
    fi
    
    # Extract and convert each commit
    local successful_extractions=0
    for i in "${!commits[@]}"; do
        local commit=${commits[$i]}
        local frame_name="frame_$(printf "%04d" $i)"
        
        if extract_and_convert "$commit" "$frame_name"; then
            ((successful_extractions++))
        fi
    done
    
    log "Successfully extracted $successful_extractions out of $total_commits commits"
    
    if [ $successful_extractions -eq 0 ]; then
        error "No successful extractions - cannot create movie"
        exit 1
    fi
    
    # Add commit information to frames
    add_commit_info "${commits[@]}"
    
    # Create the movie
    create_movie
    
    # Cleanup
    rm -rf "$TEMP_DIR"
    
    log "Process completed!"
    info "Frames directory: $OUTPUT_DIR"
    info "Movie file: $MOVIE_OUTPUT"
    info "Total commits processed: $total_commits"
    info "Successful extractions: $successful_extractions"
}

# Show usage if help requested
if [ "$1" = "--help" ] || [ "$1" = "-h" ]; then
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Extract system diagrams from git history and create a movie"
    echo ""
    echo "Options:"
    echo "  -h, --help     Show this help message"
    echo "  --dry-run      Show what would be done without executing"
    echo ""
    echo "Configuration (edit script to modify):"
    echo "  DIAGRAM_FILE: $DIAGRAM_FILE"
    echo "  OUTPUT_DIR: $OUTPUT_DIR"
    echo "  MOVIE_OUTPUT: $MOVIE_OUTPUT"
    exit 0
fi

# Dry run mode
if [ "$1" = "--dry-run" ]; then
    log "DRY RUN MODE - showing what would be done:"
    echo "Would extract from file: $DIAGRAM_FILE"
    echo "Would save frames to: $OUTPUT_DIR"
    echo "Would create movie: $MOVIE_OUTPUT"
    echo ""
    echo "Commits that would be processed:"
    get_commits | nl -v0 -w3 -s': '
    exit 0
fi

# Run main function
main "$@"