# Folder Categoriser

A macOS desktop overlay application for visually organizing folders using colored rectangles and labels.

## Overview

Folder Categoriser creates a transparent overlay on your macOS desktop that allows you to draw colored rectangles to visually categorize your folders. The overlay sits above your wallpaper but below your desktop icons, so you can still interact with your files normally while having visual organization.

## Features

### Two Modes
- **Edit Mode**: Create, modify, resize, move, and delete rectangles
- **Lock Mode**: Rectangles are visible but frozen; all clicks pass through to the desktop

### Rectangle Management
- **Create**: Click and drag to create new rectangles
- **Resize**: Drag any of the 8 resize handles (corners and edges)
- **Move**: Click and drag rectangles to reposition them
- **Edit**: Double-click to change color and label
- **Delete**: Right-click for delete menu, or select and press Delete/Backspace

### Customization
- **Colors**: Choose from 8 preset colors or use custom colors via color picker
- **Labels**: Add text labels to identify categories
- **Border Width**: Adjustable from 1-5 pixels
- **Fill Opacity**: Adjustable transparency (0-100%) for fills
- **Fill Toggle**: Show or hide filled backgrounds

### User Interface
- **Menu Bar Icon**: Quick access to all features
  - □ (empty square) = Lock Mode
  - ■ (filled square) = Edit Mode
- **Visual Indicator**: "EDIT MODE" overlay when in edit mode
- **Keyboard Shortcuts**:
  - `⌘E` - Toggle Edit/Lock mode
  - `⌘F` - Toggle fill on/off
  - `⌘K` - Clear all rectangles
  - `⌘Q` - Quit application
  - `Delete/Backspace` - Delete selected rectangle

## Building the Application

### Requirements
- macOS 13.0 or later
- Xcode 15.0 or later
- Swift 5.0 or later

### Build Instructions

1. **Open the Project**
   ```bash
   cd FolderCategoriser
   open FolderCategoriser.xcodeproj
   ```

2. **Build in Xcode**
   - Select the "FolderCategoriser" scheme
   - Choose "My Mac" as the destination
   - Press `⌘B` to build or `⌘R` to build and run

3. **Alternative: Build from Command Line**
   ```bash
   cd FolderCategoriser
   xcodebuild -project FolderCategoriser.xcodeproj -scheme FolderCategoriser -configuration Release
   ```

   The built app will be located at:
   ```
   build/Release/FolderCategoriser.app
   ```

## Usage

### Getting Started

1. **Launch the Application**
   - Run FolderCategoriser.app
   - The app runs in the background (no dock icon)
   - Look for the menu bar icon (□) in the top-right of your screen

2. **Enter Edit Mode**
   - Click the menu bar icon
   - Select "Enter Edit Mode" (or press `⌘E`)
   - The icon changes to ■ and "EDIT MODE" appears on screen

3. **Create Rectangles**
   - Click and drag on the desktop to create a rectangle
   - Release to finish creating
   - The rectangle appears with the default blue color

4. **Customize Rectangles**
   - **Double-click** a rectangle to edit:
     - Enter a label name
     - Choose from preset colors or use the color picker
     - Click OK to apply changes
   - **Drag edges/corners** to resize
   - **Click and drag** the rectangle to move it

5. **Delete Rectangles**
   - **Right-click** a rectangle and select "Delete Rectangle"
   - Or select a rectangle and press **Delete** or **Backspace**

6. **Lock Your Layout**
   - Click the menu bar icon
   - Select "Enter Lock Mode" (or press `⌘E`)
   - Rectangles are now frozen and clicks pass through to desktop

### Menu Bar Options

- **Enter Edit/Lock Mode**: Toggle between modes
- **Show Fill**: Toggle filled backgrounds on/off (checked = on)
- **Fill Opacity**: Slider to adjust transparency of fills (0-100%)
- **Border Width**: Choose border thickness (1-5 pixels)
- **Clear All Rectangles**: Remove all rectangles (with confirmation)
- **Quit**: Exit the application

### Tips

- Use different colors for different categories (e.g., Work, Personal, Projects)
- Add descriptive labels to remember what each area is for
- Adjust opacity if fills are too prominent
- Use Lock mode during normal work to prevent accidental changes
- The overlay works across all desktop spaces

## Technical Details

### Architecture

The application is built using AppKit and consists of:

- **AppDelegate.swift**: Main application controller
- **OverlayWindow.swift**: Transparent window that sits above the desktop
- **OverlayView.swift**: Custom view handling drawing and mouse interactions
- **Rectangle.swift**: Model representing categorization rectangles
- **MenuBarController.swift**: Menu bar icon and menu management
- **ColorPresets.swift**: Preset colors and utilities

### Window Levels

The overlay window uses `CGWindowLevelForKey(.desktopWindow) + 1` to position itself:
- Above: Desktop wallpaper
- Below: Desktop icons, Finder windows, and all other applications

### Mouse Event Handling

- **Edit Mode**: Window captures mouse events (`ignoresMouseEvents = false`)
- **Lock Mode**: Window ignores events, clicks pass through (`ignoresMouseEvents = true`)

## Limitations

- Rectangles are not persisted between app launches (by design)
- No undo/redo functionality
- Cannot import/export rectangle layouts
- Limited to one monitor (displays on main screen)

## Troubleshooting

**Problem**: Desktop icons are not clickable
- **Solution**: Make sure you're in Lock Mode (menu bar icon should show □)

**Problem**: Can't create rectangles
- **Solution**: Enter Edit Mode via menu bar icon or press `⌘E`

**Problem**: Rectangles don't appear
- **Solution**: Check that "Show Fill" is enabled or increase border width

**Problem**: App doesn't appear in Dock
- **Solution**: This is intentional - the app runs as a menu bar utility (LSUIElement)

## License

See LICENSE file for details.

## Contributing

This is a personal project, but suggestions and improvements are welcome!