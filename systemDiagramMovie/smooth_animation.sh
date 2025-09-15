#!/bin/bash
# Frame interpolation script for smooth diagram evolution animation
# Uses optical flow and morphing to create smooth transitions between frames
set -e

FRAMES_DIR="${1:-./frames_all_chrono}"
OUTPUT_DIR="./frames_smoothed"
TEMP_DIR="./temp_smooth"
INTERP_FRAMES=2  # Number of interpolated frames between each original frame

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

# Check dependencies
check_dependencies() {
    local missing_deps=()
    
    if ! command -v ffmpeg >/dev/null 2>&1; then
        missing_deps+=("ffmpeg")
    fi
    
    if ! command -v convert >/dev/null 2>&1 && ! command -v magick >/dev/null 2>&1; then
        missing_deps+=("imagemagick")
    fi
    
    # Check for Python and OpenCV
    if ! command -v python3 >/dev/null 2>&1; then
        missing_deps+=("python3")
    elif ! python3 -c "import cv2" 2>/dev/null; then
        missing_deps+=("opencv-python")
    fi
    
    if [ ${#missing_deps[@]} -gt 0 ]; then
        error "Missing dependencies: ${missing_deps[*]}"
        echo "Install with:"
        for dep in "${missing_deps[@]}"; do
            case $dep in
                "ffmpeg"|"imagemagick") echo "  brew install $dep" ;;
                "python3") echo "  brew install python3" ;;
                "opencv-python") echo "  pip3 install opencv-python numpy" ;;
            esac
        done
        exit 1
    fi
}

# Create Python script for optical flow interpolation
create_interpolation_script() {
    cat > "$TEMP_DIR/interpolate.py" << 'EOF'
import cv2
import numpy as np
import sys
import os

def create_interpolated_frames(frame1_path, frame2_path, output_dir, num_interp):
    """Create interpolated frames between two input frames using optical flow"""
    
    # Read frames
    frame1 = cv2.imread(frame1_path)
    frame2 = cv2.imread(frame2_path)
    
    if frame1 is None or frame2 is None:
        print(f"Error: Could not read frames {frame1_path} or {frame2_path}")
        return False
    
    # Convert to grayscale for optical flow
    gray1 = cv2.cvtColor(frame1, cv2.COLOR_BGR2GRAY)
    gray2 = cv2.cvtColor(frame2, cv2.COLOR_BGR2GRAY)
    
    # Calculate optical flow using Farneback method
    flow = cv2.calcOpticalFlowPyrLK_dense(gray1, gray2)
    
    # Alternative: Use dense optical flow
    flow = cv2.calcOpticalFlowPyrLK_dense(gray1, gray2, None, 
                                         winSize=(15,15), 
                                         maxLevel=2,
                                         criteria=(cv2.TERM_CRITERIA_EPS | cv2.TERM_CRITERIA_COUNT, 10, 0.03))
    
    # If that fails, use simple morphing
    if flow is None:
        return morph_frames(frame1, frame2, output_dir, num_interp)
    
    h, w = frame1.shape[:2]
    
    # Create interpolated frames
    for i in range(1, num_interp + 1):
        alpha = i / (num_interp + 1)  # Interpolation factor
        
        # Create coordinate matrices
        coords = np.indices((h, w), dtype=np.float32).transpose(1,2,0)
        
        # Apply interpolated flow
        new_coords = coords + flow * alpha
        
        # Remap frame1 using interpolated flow
        warped_frame1 = cv2.remap(frame1, new_coords[:,:,1], new_coords[:,:,0], cv2.INTER_LINEAR)
        
        # Reverse flow for frame2
        reverse_flow = -flow * (1 - alpha)
        reverse_coords = coords + reverse_flow
        warped_frame2 = cv2.remap(frame2, reverse_coords[:,:,1], reverse_coords[:,:,0], cv2.INTER_LINEAR)
        
        # Blend the warped frames
        interpolated = cv2.addWeighted(warped_frame1, 1-alpha, warped_frame2, alpha, 0)
        
        # Save interpolated frame
        output_path = os.path.join(output_dir, f"interp_{i:02d}.png")
        cv2.imwrite(output_path, interpolated)
        print(f"Created interpolated frame: {output_path}")
    
    return True

def morph_frames(frame1, frame2, output_dir, num_interp):
    """Simple morphing fallback if optical flow fails"""
    print("Using simple morphing fallback...")
    
    for i in range(1, num_interp + 1):
        alpha = i / (num_interp + 1)
        
        # Simple alpha blending
        morphed = cv2.addWeighted(frame1, 1-alpha, frame2, alpha, 0)
        
        output_path = os.path.join(output_dir, f"interp_{i:02d}.png")
        cv2.imwrite(output_path, morphed)
        print(f"Created morphed frame: {output_path}")
    
    return True

def dense_optical_flow(gray1, gray2):
    """Calculate dense optical flow using Farneback method"""
    try:
        flow = cv2.calcOpticalFlowPyrLK_Farneback(gray1, gray2, None, 0.5, 3, 15, 3, 5, 1.2, 0)
        return flow
    except:
        # Fallback to simpler method
        return None

if __name__ == "__main__":
    if len(sys.argv) != 5:
        print("Usage: python3 interpolate.py <frame1> <frame2> <output_dir> <num_interp>")
        sys.exit(1)
    
    frame1_path = sys.argv[1]
    frame2_path = sys.argv[2]
    output_dir = sys.argv[3]
    num_interp = int(sys.argv[4])
    
    os.makedirs(output_dir, exist_ok=True)
    
    success = create_interpolated_frames(frame1_path, frame2_path, output_dir, num_interp)
    if not success:
        sys.exit(1)
EOF
}

# Main processing function
process_frames() {
    local frames=($(ls "$FRAMES_DIR"/*.png 2>/dev/null | sort -V))
    local total_frames=${#frames[@]}
    
    if [ $total_frames -eq 0 ]; then
        error "No PNG frames found in $FRAMES_DIR"
        exit 1
    fi
    
    log "Found $total_frames frames to process"
    log "Will create $INTERP_FRAMES interpolated frames between each pair"
    
    # Copy first frame
    local frame_counter=0
    local output_name=$(printf "smooth_%04d.png" $frame_counter)
    cp "${frames[0]}" "$OUTPUT_DIR/$output_name"
    info "Copied original frame: $output_name"
    ((frame_counter++))
    
    # Process pairs of consecutive frames
    for (( i=0; i<$((total_frames-1)); i++ )); do
        local current_frame="${frames[$i]}"
        local next_frame="${frames[$((i+1))]}"
        local pair_dir="$TEMP_DIR/pair_$i"
        
        log "Processing frame pair $((i+1))/$((total_frames-1)): $(basename "$current_frame") -> $(basename "$next_frame")"
        
        mkdir -p "$pair_dir"
        
        # Create interpolated frames using Python script
        if python3 "$TEMP_DIR/interpolate.py" "$current_frame" "$next_frame" "$pair_dir" "$INTERP_FRAMES"; then
            # Copy interpolated frames to output
            for interp_file in $(ls "$pair_dir"/interp_*.png 2>/dev/null | sort -V); do
                output_name=$(printf "smooth_%04d.png" $frame_counter)
                cp "$interp_file" "$OUTPUT_DIR/$output_name"
                info "Added interpolated frame: $output_name"
                ((frame_counter++))
            done
        else
            warn "Interpolation failed for pair $i, skipping interpolated frames"
        fi
        
        # Copy the next original frame
        output_name=$(printf "smooth_%04d.png" $frame_counter)
        cp "$next_frame" "$OUTPUT_DIR/$output_name"
        info "Copied original frame: $output_name"
        ((frame_counter++))
        
        # Clean up pair directory
        rm -rf "$pair_dir"
    done
    
    log "Created $frame_counter total frames ($(ls "$OUTPUT_DIR"/*.png 2>/dev/null | wc -l) files)"
}

# Create final movie
create_smooth_movie() {
    local smooth_frames=($(ls "$OUTPUT_DIR"/*.png 2>/dev/null | wc -l))
    
    if [ $smooth_frames -eq 0 ]; then
        error "No smoothed frames found"
        exit 1
    fi
    
    log "Creating smooth animation movie from $smooth_frames frames..."
    
    # Calculate new framerate (original was 3fps, now we have more frames)
    local original_fps=3
    local frames_multiplier=$((INTERP_FRAMES + 1))
    local new_fps=$((original_fps * frames_multiplier))
    
    # Create movie with higher framerate to maintain same timing
    ffmpeg -y -framerate $new_fps -pattern_type glob -i "$OUTPUT_DIR/*.png" \
           -c:v libx264 -pix_fmt yuv420p \
           -vf "scale=1920:1080:force_original_aspect_ratio=decrease,pad=1920:1080:(ow-iw)/2:(oh-ih)/2" \
           "system_evolution_smooth_animation.mp4"
    
    log "Smooth animation movie created: system_evolution_smooth_animation.mp4"
    info "Original frames: $(ls "$FRAMES_DIR"/*.png 2>/dev/null | wc -l)"
    info "Smoothed frames: $smooth_frames"
    info "Framerate: ${new_fps}fps (maintains same duration as original 3fps)"
}

# Main execution
main() {
    log "Starting frame interpolation for smooth animation..."
    
    # Setup
    mkdir -p "$OUTPUT_DIR" "$TEMP_DIR"
    rm -f "$OUTPUT_DIR"/* "$TEMP_DIR"/* 2>/dev/null || true
    
    # Check dependencies
    check_dependencies
    
    # Create interpolation script
    create_interpolation_script
    
    # Process frames
    process_frames
    
    # Create final movie
    create_smooth_movie
    
    # Cleanup
    rm -rf "$TEMP_DIR"
    
    log "Frame interpolation complete!"
    log "Original movie: system_evolution_complete_chronological.mp4"
    log "Smooth movie: system_evolution_smooth_animation.mp4"
    
    # Show file sizes for comparison
    if [ -f "system_evolution_complete_chronological.mp4" ] && [ -f "system_evolution_smooth_animation.mp4" ]; then
        info "File size comparison:"
        ls -lh system_evolution_complete_chronological.mp4 system_evolution_smooth_animation.mp4
    fi
}

# Help message
if [ "$1" = "--help" ] || [ "$1" = "-h" ]; then
    echo "Usage: $0 [FRAMES_DIR]"
    echo ""
    echo "Create smooth animations by interpolating between successive frames"
    echo "Uses optical flow to detect movement and generate intermediate frames"
    echo ""
    echo "Options:"
    echo "  FRAMES_DIR    Directory containing PNG frames (default: ./frames_all_chrono)"
    echo "  --help, -h    Show this help message"
    echo ""
    echo "Dependencies:"
    echo "  - ffmpeg"
    echo "  - ImageMagick (convert/magick)"
    echo "  - python3 with opencv-python and numpy"
    echo ""
    echo "Output:"
    echo "  - frames_smoothed/    Directory with interpolated frames"
    echo "  - system_evolution_smooth_animation.mp4    Final smooth movie"
    exit 0
fi

# Run main function
main "$@"