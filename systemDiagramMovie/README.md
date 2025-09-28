# System Diagram Movie Generator

This directory contains all tools for extracting system diagrams from git history and creating evolution movies.

## Available Scripts

### Main Generation Scripts
- `complete_chronological.sh` - Generate movie from ALL 244 commits (recommended)
- `chronological_50.sh` - Generate movie from last 50 commits
- `complete_vertical_diagram.sh` - Generate movie from vertical diagram (2 commits)
- `recent_debugging_evolution.sh` - Generate movie from recent debugging commits (post-Sep 9)
- `extract_system_diagrams.sh` - Full-featured extraction script
- `run_diagram_extraction.sh` - Interactive menu for all options

### Smooth Animation Scripts  
- `ffmpeg_smooth_animation.sh` - Create smooth interpolated animation (requires existing movie)
- `smooth_animation.sh` - Advanced OpenCV-based interpolation (requires opencv-python)

### Test Scripts
- `quick_test.sh` - Quick test with 5 commits
- `test_extraction.sh` - Extract and examine single commit

## Usage

**From the main Factals directory:**
```bash
cd systemDiagramMovie
./complete_chronological.sh       # Generate complete evolution movie
./recent_debugging_evolution.sh   # Generate recent debugging changes movie
./ffmpeg_smooth_animation.sh      # Create smooth version
```

**Interactive menu:**
```bash
cd systemDiagramMovie  
./run_diagram_extraction.sh
```

## Generated Files

### Movies
- `system_evolution_complete_chronological.mp4` - Complete 244-commit evolution (3fps)
- `system_evolution_recent_debugging.mp4` - Recent debugging changes (2fps, post-Sep 9)
- `system_evolution_smooth_ffmpeg.mp4` - Smooth interpolated version (6fps)
- `system_evolution_chronological_50.mp4` - 50-commit sample
- `system_evolution_vertical_complete.mp4` - Vertical diagram evolution

### Frame Directories
- `frames_all_chrono/` - Individual frames from complete extraction
- `frames_recent_debug/` - Individual frames from recent debugging commits
- `frames_50_chrono/` - Individual frames from 50-commit extraction
- `frames_vertical_chrono/` - Vertical diagram frames

### Other Files
- `latest_diagram_preview.jpg` - Preview of latest diagram
- Various temp directories (cleaned up automatically)

## Features

- **Chronological Order**: Oldest commit → newest commit
- **High Quality**: 1920x1080 HD resolution  
- **Text Overlays**: Purple text showing commit number and timestamp
- **Motion Interpolation**: Smooth transitions between diagram changes
- **Multiple Formats**: Various frame rates and interpolation methods

## Dependencies

- `ffmpeg` - Video processing and motion interpolation
- `ImageMagick` (convert/magick) - Image processing
- `python3` with `opencv-python` and `numpy` (for advanced interpolation)

## Notes

- All scripts work from within this subdirectory
- Diagram files are referenced as `../Docs/ApplicationViewController*.pages`
- Generated movies show 3 years of system architecture evolution
- Smooth animations double the frame rate for fluid motion tracking