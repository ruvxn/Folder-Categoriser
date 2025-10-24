#!/bin/bash
set -e

APP_NAME="Folder Categoriser"
APP_FILE="FolderCategoriser.app"
DMG_NAME="FolderCategoriser-1.0.dmg"
DMG_TEMP="FolderCategoriser-temp.dmg"
VOLUME_NAME="Folder Categoriser"

GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}Creating professional DMG for Folder Categoriser...${NC}"

# Find the app
if [ -d "FolderCategoriser/build/Release/$APP_FILE" ]; then
    APP_PATH="FolderCategoriser/build/Release/$APP_FILE"
elif [ -d "build/Release/$APP_FILE" ]; then
    APP_PATH="build/Release/$APP_FILE"
else
    echo "Error: Release build not found!"
    exit 1
fi

echo -e "${GREEN}✓${NC} Found app at: $APP_PATH"

# Create temp directory
TEMP_DIR=$(mktemp -d)
cp -R "$APP_PATH" "$TEMP_DIR/"
ln -s /Applications "$TEMP_DIR/Applications"
echo -e "${GREEN}✓${NC} Prepared DMG contents"

# Create DMG
hdiutil create -srcfolder "$TEMP_DIR" -volname "$VOLUME_NAME" -fs HFS+ \
    -fsargs "-c c=64,a=16,e=16" -format UDRW -size 200m "$DMG_TEMP"

# Mount and configure
MOUNT_DIR=$(hdiutil attach -readwrite -noverify -noautoopen "$DMG_TEMP" | \
    egrep '^/dev/' | sed 1q | awk '{print $3}')

sleep 2

# Configure appearance
osascript << APPLESCRIPT
tell application "Finder"
    tell disk "$VOLUME_NAME"
        open
        set current view of container window to icon view
        set toolbar visible of container window to false
        set statusbar visible of container window to false
        set the bounds of container window to {100, 100, 700, 500}
        set viewOptions to the icon view options of container window
        set arrangement of viewOptions to not arranged
        set icon size of viewOptions to 96
        set position of item "$APP_FILE" of container window to {150, 180}
        set position of item "Applications" of container window to {450, 180}
        close
        open
        update without registering applications
        delay 2
    end tell
end tell
APPLESCRIPT

echo -e "${GREEN}✓${NC} Configured DMG appearance"

sleep 2
sync
hdiutil detach "$MOUNT_DIR"

# Convert to compressed DMG
hdiutil convert "$DMG_TEMP" -format UDZO -imagekey zlib-level=9 -o "$DMG_NAME"

# Clean up
rm -f "$DMG_TEMP"
rm -rf "$TEMP_DIR"

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}✓ DMG created successfully!${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo "File: $DMG_NAME"
echo "Size: $(du -h "$DMG_NAME" | cut -f1)"
echo ""
echo "Done!"
