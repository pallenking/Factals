#!/bin/bash

# Simple test script to extract and examine one commit
set -e

COMMIT=${1:-"44dca877"}  # Default to latest commit from dry-run
DIAGRAM_FILE="../Docs/ApplicationViewControllerH.pages"
TEMP_DIR="./temp_test"

echo "Testing extraction of commit $COMMIT"

# Create temp directory
mkdir -p "$TEMP_DIR"
rm -rf "$TEMP_DIR"/*

# Extract the file
echo "Extracting file from commit $COMMIT..."
git show "$COMMIT:$DIAGRAM_FILE" > "$TEMP_DIR/diagram_$COMMIT.pages"

# Check file size
FILE_SIZE=$(wc -c < "$TEMP_DIR/diagram_$COMMIT.pages")
echo "Extracted file size: $FILE_SIZE bytes"

# Try to examine the file structure
echo ""
echo "File type information:"
file "$TEMP_DIR/diagram_$COMMIT.pages"

echo ""
echo "Trying to extract as zip archive (.pages files are actually zip files):"
if unzip -l "$TEMP_DIR/diagram_$COMMIT.pages" 2>/dev/null | head -20; then
    echo "Successfully listed contents as zip!"
    
    # Extract the zip
    mkdir -p "$TEMP_DIR/extracted"
    unzip -q "$TEMP_DIR/diagram_$COMMIT.pages" -d "$TEMP_DIR/extracted"
    
    echo ""
    echo "Contents after extraction:"
    find "$TEMP_DIR/extracted" -type f | head -20
    
    echo ""
    echo "Looking for image files:"
    find "$TEMP_DIR/extracted" \( -name "*.png" -o -name "*.jpg" -o -name "*.jpeg" \) | head -10
else
    echo "Not a valid zip file or extraction failed"
fi

# Check if macOS has Pages app available
if [ -d "/Applications/Pages.app" ]; then
    echo ""
    echo "Pages app is available - we could potentially use AppleScript to convert"
fi

# If sips is available, try it
if command -v sips >/dev/null 2>&1; then
    echo ""
    echo "Trying sips conversion (macOS built-in)..."
    if sips -s format png "$TEMP_DIR/diagram_$COMMIT.pages" --out "$TEMP_DIR/converted_with_sips.png" 2>/dev/null; then
        echo "sips conversion successful!"
        ls -la "$TEMP_DIR/converted_with_sips.png"
    else
        echo "sips conversion failed (expected for .pages files)"
    fi
fi

echo ""
echo "Test complete. Check $TEMP_DIR for results."