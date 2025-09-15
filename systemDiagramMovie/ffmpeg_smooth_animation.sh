#!/bin/bash
# Simple smooth animation using FFmpeg's built-in motion interpolation
# This is a fallback method that doesn't require OpenCV
set -e

FRAMES_DIR="${1:-./frames_all_chrono}"
ORIGINAL_MOVIE="system_evolution_complete_chronological.mp4"
OUTPUT_MOVIE="system_evolution_smooth_ffmpeg.mp4"
INTERPOLATION_FACTOR=2  # Double the frame rate for smoother motion

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

log() { echo -e "${GREEN}[$(date +'%H:%M:%S')] $1${NC}"; }
info() { echo -e "${BLUE}[INFO] $1${NC}"; }
warn() { echo -e "${YELLOW}[WARN] $1${NC}"; }
error() { echo -e "${RED}[ERROR] $1${NC}"; }

# Check if original movie exists
if [ ! -f "$ORIGINAL_MOVIE" ]; then
    error "Original movie not found: $ORIGINAL_MOVIE"
    echo "Run the complete_chronological.sh script first to create the base movie"
    exit 1
fi

log "Creating smooth animation using FFmpeg motion interpolation..."

# Method 1: Using minterpolate filter with motion estimation
create_smooth_with_minterpolate() {
    log "Using FFmpeg minterpolate filter for motion compensation..."
    
    ffmpeg -y -i "$ORIGINAL_MOVIE" \
           -filter:v "minterpolate=fps=6:mi_mode=mci:mc_mode=aobmc:me_mode=bidir:vsbmc=1" \
           -c:v libx264 -pix_fmt yuv420p \
           "$OUTPUT_MOVIE"
}

# Method 2: Using framerate filter (simpler, faster)
create_smooth_with_framerate() {
    log "Using FFmpeg framerate filter for frame interpolation..."
    
    ffmpeg -y -i "$ORIGINAL_MOVIE" \
           -filter:v "framerate=fps=6" \
           -c:v libx264 -pix_fmt yuv420p \
           "system_evolution_smooth_simple.mp4"
}

# Method 3: Create from frames with blending
create_smooth_from_frames() {
    if [ ! -d "$FRAMES_DIR" ]; then
        warn "Frames directory not found: $FRAMES_DIR"
        return 1
    fi
    
    local frames=($(ls "$FRAMES_DIR"/*.png 2>/dev/null | sort -V))
    local total_frames=${#frames[@]}
    
    if [ $total_frames -eq 0 ]; then
        warn "No frames found in $FRAMES_DIR"
        return 1
    fi
    
    log "Creating smooth animation from $total_frames individual frames..."
    
    # Create a temporary movie at higher frame rate, then apply motion interpolation
    local temp_movie="temp_high_fps.mp4"
    
    # First, create movie at double frame rate by duplicating frames
    ffmpeg -y -framerate 6 -pattern_type glob -i "$FRAMES_DIR/*.png" \
           -c:v libx264 -pix_fmt yuv420p \
           -vf "scale=1920:1080:force_original_aspect_ratio=decrease,pad=1920:1080:(ow-iw)/2:(oh-ih)/2" \
           "$temp_movie"
    
    # Then apply motion interpolation to smooth transitions
    ffmpeg -y -i "$temp_movie" \
           -filter:v "minterpolate=fps=12:mi_mode=mci:mc_mode=aobmc" \
           -c:v libx264 -pix_fmt yuv420p \
           "system_evolution_smooth_frames.mp4"
    
    rm -f "$temp_movie"
    info "Created smooth animation from frames: system_evolution_smooth_frames.mp4"
}

# Get movie info
get_movie_info() {
    log "Original movie information:"
    ffprobe -v quiet -print_format json -show_format -show_streams "$ORIGINAL_MOVIE" | \
        grep -E '"duration"|"avg_frame_rate"|"width"|"height"' | head -4
}

main() {
    log "Starting FFmpeg-based smooth animation creation..."
    
    get_movie_info
    
    # Try the motion interpolation method first (highest quality)
    log "Attempting motion interpolation method..."
    if create_smooth_with_minterpolate; then
        log "Successfully created: $OUTPUT_MOVIE"
    else
        warn "Motion interpolation failed, trying simpler method..."
        if create_smooth_with_framerate; then
            log "Successfully created: system_evolution_smooth_simple.mp4"
        else
            error "Both FFmpeg interpolation methods failed"
            exit 1
        fi
    fi
    
    # Also try frame-based method if frames exist
    create_smooth_from_frames || warn "Frame-based smoothing skipped"
    
    log "Smooth animation creation complete!"
    
    # Show results
    echo ""
    info "Generated movies:"
    for movie in system_evolution_smooth_*.mp4; do
        if [ -f "$movie" ]; then
            echo "  - $movie ($(du -h "$movie" | cut -f1))"
        fi
    done
    
    echo ""
    info "Comparison:"
    echo "  - Original: $ORIGINAL_MOVIE ($(du -h "$ORIGINAL_MOVIE" | cut -f1)) at 3fps"
    for movie in system_evolution_smooth_*.mp4; do
        if [ -f "$movie" ]; then
            local fps_info=$(ffprobe -v quiet -select_streams v:0 -show_entries stream=avg_frame_rate -of csv=p=0 "$movie")
            echo "  - $movie ($(du -h "$movie" | cut -f1)) at ~6-12fps (interpolated)"
        fi
    done
}

# Help message
if [ "$1" = "--help" ] || [ "$1" = "-h" ]; then
    echo "Usage: $0 [FRAMES_DIR]"
    echo ""
    echo "Create smooth animations using FFmpeg's built-in motion interpolation"
    echo "This method doesn't require OpenCV and works with existing movies or frames"
    echo ""
    echo "Options:"
    echo "  FRAMES_DIR    Directory containing PNG frames (default: ./frames_all_chrono)"
    echo "  --help, -h    Show this help message"
    echo ""
    echo "Dependencies:"
    echo "  - ffmpeg (with minterpolate filter support)"
    echo ""
    echo "Input:"
    echo "  - $ORIGINAL_MOVIE (base movie to interpolate)"
    echo "  - $FRAMES_DIR (optional: individual frames)"
    echo ""
    echo "Output:"
    echo "  - system_evolution_smooth_ffmpeg.mp4 (primary output)"
    echo "  - system_evolution_smooth_simple.mp4 (fallback method)"
    echo "  - system_evolution_smooth_frames.mp4 (from frames if available)"
    exit 0
fi

main "$@"