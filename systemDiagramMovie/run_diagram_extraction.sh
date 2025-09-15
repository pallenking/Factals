#!/bin/bash

# Master script for running system diagram extractions
# This gives you several options for generating your time-lapse movie

set -e

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

log() { echo -e "${GREEN}[INFO] $1${NC}"; }
warn() { echo -e "${YELLOW}[WARN] $1${NC}"; }
error() { echo -e "${RED}[ERROR] $1${NC}"; }

echo "🎬 System Diagram Movie Generator"
echo "=================================="
echo ""

# Check what we have
TOTAL_COMMITS=$(./extract_system_diagrams.sh --dry-run 2>/dev/null | tail -n +4 | wc -l)
log "Found $TOTAL_COMMITS commits that modified your system diagram"

echo ""
echo "Choose your extraction option:"
echo ""
echo "1. 🚀 Quick Test (Last 10 commits) - ~30 seconds"
echo "2. 📊 Medium Sample (Last 50 commits) - ~2 minutes" 
echo "3. 🎭 Full History (All $TOTAL_COMMITS commits) - ~15 minutes"
echo "4. 🔍 Custom Range (Specify number of commits)"
echo "5. 📅 Date Range (Specify date range)"
echo "6. ❓ Help/Information"
echo ""

read -p "Enter your choice (1-6): " choice

case $choice in
    1)
        log "Running quick test with last 10 commits..."
        # Modify our quick test script
        cat > quick_test_10.sh << 'EOF'
#!/bin/bash
set -e
DIAGRAM_FILE="Docs/ApplicationViewControllerH.pages"
OUTPUT_DIR="./frames_10"
TEMP_DIR="./temp_10"
GREEN='\033[0;32m'
NC='\033[0m'
log() { echo -e "${GREEN}[$(date +'%H:%M:%S')] $1${NC}"; }

mkdir -p "$OUTPUT_DIR" "$TEMP_DIR"
rm -f "$OUTPUT_DIR"/* "$TEMP_DIR"/* 2>/dev/null || true

commits=($(git log --oneline --follow "$DIAGRAM_FILE" | head -10 | awk '{print $1}'))
log "Processing ${#commits[@]} commits..."

for i in "${!commits[@]}"; do
    commit=${commits[$i]}
    frame_name="frame_$(printf "%03d" $i)"
    log "Processing $commit ($((i+1))/${#commits[@]})..."
    
    temp_file="$TEMP_DIR/diagram_$commit.pages"
    git show "$commit:$DIAGRAM_FILE" > "$temp_file"
    
    extract_dir="$TEMP_DIR/extract_$commit"
    mkdir -p "$extract_dir"
    
    if unzip -q "$temp_file" -d "$extract_dir" && [ -f "$extract_dir/preview.jpg" ]; then
        output_file="$OUTPUT_DIR/$frame_name.png"
        magick "$extract_dir/preview.jpg" "$output_file"
        
        commit_msg=$(git log --format="%s" -n 1 "$commit")
        commit_date=$(git log --format="%ai" -n 1 "$commit" | cut -d' ' -f1)
        
        magick "$output_file" \
                -pointsize 18 -fill white -stroke black -strokewidth 1 \
                -gravity North -annotate +0+10 "Commit $((i+1))/$TOTAL_COMMITS: $commit" \
                -pointsize 14 -fill white -stroke black -strokewidth 1 \
                -gravity North -annotate +0+32 "$commit_msg" \
                -pointsize 12 -fill white -stroke black -strokewidth 1 \
                -gravity North -annotate +0+50 "$commit_date" \
                "$output_file"
    fi
done

log "Creating movie..."
ffmpeg -y -framerate 1.5 -pattern_type glob -i "$OUTPUT_DIR/*.png" \
       -c:v libx264 -pix_fmt yuv420p \
       -vf "scale=1920:1080:force_original_aspect_ratio=decrease,pad=1920:1080:(ow-iw)/2:(oh-ih)/2" \
       "system_evolution_10.mp4"

log "Movie created: system_evolution_10.mp4 ($(ls -1 "$OUTPUT_DIR"/*.png | wc -l) frames)"
rm -rf "$TEMP_DIR"
EOF
        chmod +x quick_test_10.sh
        ./quick_test_10.sh
        ;;
    
    2)
        log "Running medium sample with last 50 commits..."
        # Create a modified version for 50 commits
        sed 's/head -10/head -50/g; s/frames_10/frames_50/g; s/temp_10/temp_50/g; s/system_evolution_10/system_evolution_50/g' quick_test_10.sh > medium_test_50.sh
        chmod +x medium_test_50.sh
        ./medium_test_50.sh
        ;;
    
    3)
        log "Running full history extraction - this will take a while..."
        warn "This will process all $TOTAL_COMMITS commits"
        read -p "Are you sure? (y/N): " confirm
        if [[ $confirm =~ ^[Yy]$ ]]; then
            ./extract_system_diagrams.sh
        else
            log "Cancelled full extraction"
        fi
        ;;
    
    4)
        read -p "Enter number of recent commits to process: " num_commits
        if [[ $num_commits =~ ^[0-9]+$ ]] && [ $num_commits -gt 0 ] && [ $num_commits -le $TOTAL_COMMITS ]; then
            log "Processing last $num_commits commits..."
            sed "s/head -10/head -$num_commits/g; s/frames_10/frames_$num_commits/g; s/temp_10/temp_$num_commits/g; s/system_evolution_10/system_evolution_$num_commits/g" quick_test_10.sh > "custom_test_$num_commits.sh"
            chmod +x "custom_test_$num_commits.sh"
            "./"custom_test_$num_commits.sh""
        else
            error "Invalid number. Must be between 1 and $TOTAL_COMMITS"
        fi
        ;;
    
    5)
        echo "Date range extraction not implemented yet"
        warn "Use git log with --since and --until to find specific commits first"
        ;;
    
    6)
        echo ""
        echo "📖 Help Information"
        echo "==================="
        echo ""
        echo "This tool extracts your system diagrams from git history and creates a time-lapse movie."
        echo ""
        echo "📁 Files involved:"
        echo "  - Source: Docs/ApplicationViewControllerH.pages"
        echo "  - Frames: ./frames_N/ (extracted images)"
        echo "  - Movie: system_evolution_N.mp4"
        echo ""
        echo "🛠  Requirements:"
        echo "  - ffmpeg (for video creation)"
        echo "  - ImageMagick (for image processing)"
        echo "  - macOS (for .pages file handling)"
        echo ""
        echo "⏱  Processing times (approximate):"
        echo "  - 10 commits: ~30 seconds"
        echo "  - 50 commits: ~2 minutes"
        echo "  - All commits ($TOTAL_COMMITS): ~15 minutes"
        echo ""
        echo "🎬 Output format:"
        echo "  - 1920x1080 MP4 video"
        echo "  - Each frame shows commit info"
        echo "  - 1-1.5 frames per second"
        echo ""
        ;;
    
    *)
        error "Invalid choice. Please run the script again and choose 1-6."
        ;;
esac