#!/bin/bash

# Professional DMG Creator for Folder Categoriser
# This script creates a beautiful, distributable DMG file

set -e

# Configuration
APP_NAME="Folder Categoriser"
APP_FILE="FolderCategoriser.app"
DMG_NAME="FolderCategoriser-1.0.dmg"
DMG_TEMP="FolderCategoriser-temp.dmg"
VOLUME_NAME="Folder Categoriser"
DMG_BACKGROUND="dmg-background.png"
WINDOW_WIDTH=600
WINDOW_HEIGHT=400
ICON_SIZE=96
APP_ICON_X=150
APP_ICON_Y=180
APPS_LINK_X=450
APPS_LINK_Y=180

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}   Folder Categoriser DMG Builder${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Check if app exists (try both locations)
if [ -d "FolderCategoriser/build/Release/$APP_FILE" ]; then
    APP_PATH="FolderCategoriser/build/Release/$APP_FILE"
elif [ -d "build/Release/$APP_FILE" ]; then
    APP_PATH="build/Release/$APP_FILE"
else
    echo -e "${YELLOW}⚠️  Release build not found!${NC}"
    echo ""
    echo "Please build the Release version first:"
    echo "1. Open Xcode"
    echo "2. Product → Scheme → Edit Scheme"
    echo "3. Set Run configuration to 'Release'"
    echo "4. Product → Build (⌘B)"
    echo ""
    echo "Or run: xcodebuild -configuration Release -scheme FolderCategoriser"
    exit 1
fi

echo -e "${GREEN}✓${NC} Found Release build"

# Create temporary directory
TEMP_DIR=$(mktemp -d)
echo -e "${GREEN}✓${NC} Created temporary directory"

# Copy app to temp directory
cp -R "build/Release/$APP_FILE" "$TEMP_DIR/"
echo -e "${GREEN}✓${NC} Copied app bundle"

# Create Applications symlink
ln -s /Applications "$TEMP_DIR/Applications"
echo -e "${GREEN}✓${NC} Created Applications symlink"

# Create temporary DMG
echo ""
echo -e "${BLUE}Creating temporary DMG...${NC}"
hdiutil create -srcfolder "$TEMP_DIR" -volname "$VOLUME_NAME" -fs HFS+ \
    -fsargs "-c c=64,a=16,e=16" -format UDRW -size 200m "$DMG_TEMP"
echo -e "${GREEN}✓${NC} Temporary DMG created"

# Mount the DMG
echo -e "${BLUE}Mounting DMG...${NC}"
MOUNT_DIR=$(hdiutil attach -readwrite -noverify -noautoopen "$DMG_TEMP" | \
    egrep '^/dev/' | sed 1q | awk '{print $3}')
echo -e "${GREEN}✓${NC} DMG mounted at: $MOUNT_DIR"

# Wait for mount to complete
sleep 2

# Copy background image if it exists
if [ -f "$DMG_BACKGROUND" ]; then
    mkdir -p "$MOUNT_DIR/.background"
    cp "$DMG_BACKGROUND" "$MOUNT_DIR/.background/"
    echo -e "${GREEN}✓${NC} Background image copied"
    HAS_BACKGROUND=true
else
    echo -e "${YELLOW}⚠️  Background image not found (optional)${NC}"
    HAS_BACKGROUND=false
fi

# Set custom icon if available
if [ -f "FolderCategoriser/Assets.xcassets/AppIcon.appiconset/icon_512x512@2x.png" ]; then
    cp "FolderCategoriser/Assets.xcassets/AppIcon.appiconset/icon_512x512@2x.png" "$MOUNT_DIR/.VolumeIcon.icns"
    SetFile -c icnC "$MOUNT_DIR/.VolumeIcon.icns"
    echo -e "${GREEN}✓${NC} Custom volume icon set"
fi

# Configure DMG appearance with AppleScript
echo -e "${BLUE}Configuring DMG appearance...${NC}"

if [ "$HAS_BACKGROUND" = true ]; then
    APPLESCRIPT="
    tell application \"Finder\"
        tell disk \"$VOLUME_NAME\"
            open
            set current view of container window to icon view
            set toolbar visible of container window to false
            set statusbar visible of container window to false
            set the bounds of container window to {100, 100, $(expr 100 + $WINDOW_WIDTH), $(expr 100 + $WINDOW_HEIGHT)}
            set viewOptions to the icon view options of container window
            set arrangement of viewOptions to not arranged
            set icon size of viewOptions to $ICON_SIZE
            set background picture of viewOptions to file \".background:$DMG_BACKGROUND\"
            set position of item \"$APP_FILE\" of container window to {$APP_ICON_X, $APP_ICON_Y}
            set position of item \"Applications\" of container window to {$APPS_LINK_X, $APPS_LINK_Y}
            close
            open
            update without registering applications
            delay 2
        end tell
    end tell
    "
else
    APPLESCRIPT="
    tell application \"Finder\"
        tell disk \"$VOLUME_NAME\"
            open
            set current view of container window to icon view
            set toolbar visible of container window to false
            set statusbar visible of container window to false
            set the bounds of container window to {100, 100, $(expr 100 + $WINDOW_WIDTH), $(expr 100 + $WINDOW_HEIGHT)}
            set viewOptions to the icon view options of container window
            set arrangement of viewOptions to not arranged
            set icon size of viewOptions to $ICON_SIZE
            set position of item \"$APP_FILE\" of container window to {$APP_ICON_X, $APP_ICON_Y}
            set position of item \"Applications\" of container window to {$APPS_LINK_X, $APPS_LINK_Y}
            close
            open
            update without registering applications
            delay 2
        end tell
    end tell
    "
fi

echo "$APPLESCRIPT" | osascript
echo -e "${GREEN}✓${NC} DMG appearance configured"

# Wait for changes to settle
sleep 3

# Make sure everything is written
sync

# Unmount
echo -e "${BLUE}Finalizing DMG...${NC}"
hdiutil detach "$MOUNT_DIR"
echo -e "${GREEN}✓${NC} DMG unmounted"

# Convert to compressed, read-only final DMG
hdiutil convert "$DMG_TEMP" -format UDZO -imagekey zlib-level=9 -o "$DMG_NAME"
echo -e "${GREEN}✓${NC} DMG compressed"

# Clean up
rm -f "$DMG_TEMP"
rm -rf "$TEMP_DIR"
echo -e "${GREEN}✓${NC} Cleaned up temporary files"

# Get DMG info
DMG_SIZE=$(du -h "$DMG_NAME" | cut -f1)

echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}   ✓ DMG Created Successfully!${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo -e "📦 File: ${BLUE}$DMG_NAME${NC}"
echo -e "📊 Size: ${BLUE}$DMG_SIZE${NC}"
echo -e "📍 Location: ${BLUE}$(pwd)/$DMG_NAME${NC}"
echo ""
echo -e "${YELLOW}Next steps:${NC}"
echo "1. Test the DMG by mounting it"
echo "2. Drag the app to Applications"
echo "3. Launch and verify it works"
echo "4. If distributing, consider code signing"
echo ""
echo -e "${GREEN}Done!${NC}"
