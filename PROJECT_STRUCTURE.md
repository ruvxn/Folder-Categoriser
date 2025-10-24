# Project Structure

## Directory Layout

```
FolderCategoriser/
├── FolderCategoriser.xcodeproj/
│   └── project.pbxproj              # Xcode project file
├── FolderCategoriser/
│   ├── AppDelegate.swift            # Main app controller
│   ├── OverlayWindow.swift          # Transparent overlay window
│   ├── OverlayView.swift            # Drawing & interaction view
│   ├── Rectangle.swift              # Rectangle model
│   ├── MenuBarController.swift      # Menu bar management
│   ├── ColorPresets.swift           # Color utilities
│   ├── Info.plist                   # App configuration
│   └── Assets.xcassets/             # App icons
│       └── AppIcon.appiconset/
├── README.md                        # Full documentation
├── QUICKSTART.md                    # Quick start guide
├── PROJECT_STRUCTURE.md             # This file
└── LICENSE                          # License file
```

## File Descriptions

### AppDelegate.swift
- **Purpose**: Application lifecycle management
- **Key Functions**:
  - Creates and displays overlay window
  - Initializes menu bar controller
  - Sets initial mode (Lock)

### OverlayWindow.swift
- **Purpose**: Custom transparent window
- **Key Features**:
  - Borderless, transparent window
  - Positioned at desktop level + 1
  - Manages mouse event capture based on mode
  - Prevents focus stealing
  - Spans across all desktop spaces

### OverlayView.swift
- **Purpose**: Main view for drawing and interactions
- **Key Features**:
  - Draws all rectangles with borders and fills
  - Handles all mouse events (click, drag, double-click, right-click)
  - Manages rectangle creation, selection, editing
  - Implements resize handles (8 points)
  - Shows edit dialog and delete menu
  - Displays mode indicator

### Rectangle.swift (CategoryRectangle class)
- **Purpose**: Model representing a categorization rectangle
- **Properties**:
  - `id`: Unique identifier
  - `frame`: Position and size
  - `color`: Border and fill color
  - `borderWidth`: Border thickness
  - `fillOpacity`: Transparency of fill
  - `label`: Text label
  - `fontSize`: Label font size
- **Methods**:
  - `draw(showFill:)`: Renders rectangle
  - `contains(_:)`: Hit testing
  - `hitTestResizeHandle(at:)`: Resize handle detection
  - `drawResizeHandles()`: Draws handles

### MenuBarController.swift
- **Purpose**: Menu bar icon and menu management
- **Features**:
  - Status bar icon with dynamic symbol (□/■)
  - Mode toggle
  - Fill toggle
  - Opacity slider
  - Border width submenu
  - Clear all confirmation
  - Quit option
- **Updates**: Icon and menu items based on current state

### ColorPresets.swift
- **Purpose**: Provides preset colors
- **Contains**:
  - 8 preset colors (Blue, Green, Orange, Red, Purple, Yellow, Teal, Pink)
  - Color comparison utilities
  - Default color selection
  - Human-readable color names

### Info.plist
- **Purpose**: App configuration
- **Key Settings**:
  - `LSUIElement = true`: Hides from Dock
  - Bundle identifier
  - Minimum macOS version (13.0)
  - App name and version

### Assets.xcassets
- **Purpose**: App icons and images
- **Contents**: AppIcon set (various sizes for menu bar and notifications)

## Data Flow

```
User Action
    ↓
MenuBarController (mode toggle, settings)
    ↓
OverlayWindow (window level, mouse event routing)
    ↓
OverlayView (mouse event processing)
    ↓
CategoryRectangle (data model)
    ↓
OverlayView (drawing)
    ↓
Screen Display
```

## Key Interactions

### Creating a Rectangle
1. User enters Edit Mode via MenuBarController
2. User clicks and drags in OverlayView
3. OverlayView creates temporary CategoryRectangle
4. On mouse up, rectangle is added to rectangles array
5. View redraws to show new rectangle

### Editing a Rectangle
1. User double-clicks rectangle in OverlayView
2. OverlayView shows NSAlert with color picker and text field
3. User selects color and enters label
4. On OK, CategoryRectangle properties are updated
5. View redraws to show changes

### Resizing a Rectangle
1. User clicks on resize handle of selected rectangle
2. OverlayView captures handle and start frame
3. During drag, frame is adjusted based on handle position
4. On mouse up, new frame is finalized
5. View redraws with new size

### Switching to Lock Mode
1. User selects "Enter Lock Mode" from menu
2. MenuBarController calls overlayWindow.enterLockMode()
3. OverlayWindow sets ignoresMouseEvents = true
4. All mouse events now pass through to desktop

## Extension Points

### Adding Persistence
- Add save/load methods to CategoryRectangle
- Implement JSON encoding/decoding
- Save to user defaults or file on disk
- Load rectangles in AppDelegate on launch

### Adding Multi-Monitor Support
- Create one OverlayWindow per screen
- Store reference to screen in window
- Update frames when screens change
- Synchronize rectangles across displays

### Adding Undo/Redo
- Implement command pattern for rectangle operations
- Maintain undo/redo stacks in OverlayView
- Add menu items for undo/redo
- Bind to `⌘Z` and `⌘⇧Z`

### Adding Snap-to-Grid
- Add grid size property to OverlayView
- Round rectangle frames to grid in mouseDragged
- Optionally draw grid in Edit Mode
- Add toggle in menu bar

## Build Configuration

The Xcode project includes:
- Deployment target: macOS 13.0
- Swift version: 5.0
- Build configurations: Debug and Release
- No external dependencies
- Automatic code signing (configurable)
