//
//  OverlayView.swift
//  FolderCategoriser
//
//  Custom view that handles drawing rectangles and user interactions.
//

import Cocoa

/// Custom view for drawing and interacting with categorization rectangles
class OverlayView: NSView {

    // MARK: - Properties

    /// Array of all rectangles on the desktop
    var rectangles: [CategoryRectangle] = []

    /// Whether the view is in edit mode or lock mode
    var isEditMode: Bool = false {
        didSet {
            needsDisplay = true
        }
    }

    /// Whether to show fills on rectangles
    var showFills: Bool = true {
        didSet {
            needsDisplay = true
        }
    }

    /// Default color for new rectangles
    var defaultColor: NSColor = .systemBlue

    /// Currently selected rectangle
    private var selectedRectangle: CategoryRectangle?

    /// Rectangle being created
    private var creatingRectangle: CategoryRectangle?

    /// Starting point for rectangle creation
    private var creationStartPoint: NSPoint?

    /// The resize handle being dragged (if any)
    private var activeResizeHandle: ResizeHandle?

    /// Starting frame when resizing
    private var resizeStartFrame: NSRect?

    /// Starting point when dragging
    private var dragStartPoint: NSPoint?

    /// Offset from rectangle origin when dragging
    private var dragOffset: NSPoint = .zero

    /// Current mouse position for tracking
    private var currentMousePosition: NSPoint?

    /// Tracking area for cursor updates
    private var trackingArea: NSTrackingArea?

    // MARK: - Initialization

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        setupTrackingArea()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupTrackingArea()
    }

    // MARK: - Setup

    private func setupTrackingArea() {
        let options: NSTrackingArea.Options = [
            .activeAlways,
            .mouseMoved,
            .mouseEnteredAndExited,
            .cursorUpdate
        ]

        trackingArea = NSTrackingArea(
            rect: bounds,
            options: options,
            owner: self,
            userInfo: nil
        )
        addTrackingArea(trackingArea!)
    }

    override func updateTrackingAreas() {
        super.updateTrackingAreas()
        if let trackingArea = trackingArea {
            removeTrackingArea(trackingArea)
        }
        setupTrackingArea()
    }

    // MARK: - Drawing

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Clear the view
        NSColor.clear.setFill()
        dirtyRect.fill()

        // Draw all rectangles
        for rectangle in rectangles {
            rectangle.draw(showFill: showFills)

            // Draw resize handles if this rectangle is selected and in edit mode
            if isEditMode && rectangle.id == selectedRectangle?.id {
                rectangle.drawResizeHandles()
            }
        }

        // Draw the rectangle being created
        if let creating = creatingRectangle {
            creating.draw(showFill: showFills)
        }

        // Draw mode indicator in top-right corner
        if isEditMode {
            drawModeIndicator()
        }
    }

    /// Draws a mode indicator in the corner
    private func drawModeIndicator() {
        let text = "EDIT MODE"
        let attributes: [NSAttributedString.Key: Any] = [
            .font: NSFont.systemFont(ofSize: 12, weight: .bold),
            .foregroundColor: NSColor.white
        ]

        let attributedString = NSAttributedString(string: text, attributes: attributes)
        let textSize = attributedString.size()

        // Position in top-right corner with padding
        let padding: CGFloat = 10
        let backgroundRect = NSRect(
            x: bounds.width - textSize.width - padding * 2 - 10,
            y: bounds.height - textSize.height - padding * 2 - 10,
            width: textSize.width + padding * 2,
            height: textSize.height + padding * 2
        )

        // Draw semi-transparent background
        let background = NSBezierPath(roundedRect: backgroundRect, xRadius: 6, yRadius: 6)
        NSColor.black.withAlphaComponent(0.7).setFill()
        background.fill()

        // Draw text
        attributedString.draw(at: NSPoint(
            x: backgroundRect.origin.x + padding,
            y: backgroundRect.origin.y + padding
        ))
    }

    // MARK: - Mouse Events

    override func mouseDown(with event: NSEvent) {
        guard isEditMode else { return }

        let point = convert(event.locationInWindow, from: nil)
        currentMousePosition = point

        // Handle double-click to edit rectangle
        if event.clickCount == 2 {
            for rectangle in rectangles.reversed() {
                if rectangle.contains(point) {
                    showEditDialog(for: rectangle)
                    return
                }
            }
        }

        // Check if clicking on a resize handle of selected rectangle
        if let selected = selectedRectangle,
           let handle = selected.hitTestResizeHandle(at: point) {
            activeResizeHandle = handle
            resizeStartFrame = selected.frame
            dragStartPoint = point
            return
        }

        // Check if clicking inside an existing rectangle
        for rectangle in rectangles.reversed() {
            if rectangle.contains(point) {
                selectedRectangle = rectangle
                dragStartPoint = point
                dragOffset = NSPoint(
                    x: point.x - rectangle.frame.origin.x,
                    y: point.y - rectangle.frame.origin.y
                )
                needsDisplay = true
                return
            }
        }

        // Start creating a new rectangle
        selectedRectangle = nil
        creationStartPoint = point
        creatingRectangle = CategoryRectangle(
            frame: NSRect(origin: point, size: .zero),
            color: defaultColor
        )
        needsDisplay = true
    }

    override func mouseDragged(with event: NSEvent) {
        guard isEditMode else { return }

        let point = convert(event.locationInWindow, from: nil)
        currentMousePosition = point

        // Handle resizing
        if let handle = activeResizeHandle,
           let selected = selectedRectangle,
           let startFrame = resizeStartFrame,
           let startPoint = dragStartPoint {

            let deltaX = point.x - startPoint.x
            let deltaY = point.y - startPoint.y

            var newFrame = startFrame

            switch handle {
            case .topLeft:
                newFrame.origin.x = startFrame.origin.x + deltaX
                newFrame.size.width = startFrame.size.width - deltaX
                newFrame.size.height = startFrame.size.height + deltaY
            case .top:
                newFrame.size.height = startFrame.size.height + deltaY
            case .topRight:
                newFrame.size.width = startFrame.size.width + deltaX
                newFrame.size.height = startFrame.size.height + deltaY
            case .right:
                newFrame.size.width = startFrame.size.width + deltaX
            case .bottomRight:
                newFrame.origin.y = startFrame.origin.y + deltaY
                newFrame.size.width = startFrame.size.width + deltaX
                newFrame.size.height = startFrame.size.height - deltaY
            case .bottom:
                newFrame.origin.y = startFrame.origin.y + deltaY
                newFrame.size.height = startFrame.size.height - deltaY
            case .bottomLeft:
                newFrame.origin.x = startFrame.origin.x + deltaX
                newFrame.origin.y = startFrame.origin.y + deltaY
                newFrame.size.width = startFrame.size.width - deltaX
                newFrame.size.height = startFrame.size.height - deltaY
            case .left:
                newFrame.origin.x = startFrame.origin.x + deltaX
                newFrame.size.width = startFrame.size.width - deltaX
            }

            // Ensure minimum size
            let minSize: CGFloat = 20
            if newFrame.size.width < minSize || newFrame.size.height < minSize {
                return
            }

            selected.frame = newFrame
            needsDisplay = true
            return
        }

        // Handle moving
        if let selected = selectedRectangle, dragStartPoint != nil {
            let newOrigin = NSPoint(
                x: point.x - dragOffset.x,
                y: point.y - dragOffset.y
            )
            selected.frame.origin = newOrigin
            needsDisplay = true
            return
        }

        // Handle creating
        if let startPoint = creationStartPoint,
           let creating = creatingRectangle {
            let minX = min(startPoint.x, point.x)
            let minY = min(startPoint.y, point.y)
            let maxX = max(startPoint.x, point.x)
            let maxY = max(startPoint.y, point.y)

            creating.frame = NSRect(
                x: minX,
                y: minY,
                width: maxX - minX,
                height: maxY - minY
            )
            needsDisplay = true
        }
    }

    override func mouseUp(with event: NSEvent) {
        guard isEditMode else { return }

        // Finish resizing
        if activeResizeHandle != nil {
            activeResizeHandle = nil
            resizeStartFrame = nil
            dragStartPoint = nil
            needsDisplay = true
            return
        }

        // Finish moving
        if dragStartPoint != nil && selectedRectangle != nil {
            dragStartPoint = nil
            needsDisplay = true
            return
        }

        // Finish creating
        if let creating = creatingRectangle {
            // Only add if the rectangle has meaningful size
            if creating.frame.width > 10 && creating.frame.height > 10 {
                rectangles.append(creating)
                selectedRectangle = creating
            }
            creatingRectangle = nil
            creationStartPoint = nil
            needsDisplay = true
        }
    }

    // Override to handle first mouse click
    override func acceptsFirstMouse(for event: NSEvent?) -> Bool {
        return isEditMode
    }

    /// Handle right-click for delete
    override func rightMouseDown(with event: NSEvent) {
        guard isEditMode else { return }

        let point = convert(event.locationInWindow, from: nil)

        // Find which rectangle was right-clicked
        for (index, rectangle) in rectangles.enumerated().reversed() {
            if rectangle.contains(point) {
                showDeleteMenu(for: rectangle, at: index, point: event.locationInWindow)
                return
            }
        }
    }

    /// Handle cursor updates
    override func mouseMoved(with event: NSEvent) {
        guard isEditMode else { return }

        let point = convert(event.locationInWindow, from: nil)
        currentMousePosition = point

        // Update cursor based on what's under the mouse
        updateCursor(at: point)
    }

    override func cursorUpdate(with event: NSEvent) {
        guard isEditMode else {
            NSCursor.arrow.set()
            return
        }

        let point = convert(event.locationInWindow, from: nil)
        updateCursor(at: point)
    }

    private func updateCursor(at point: NSPoint) {
        // Check for resize handles first
        if let selected = selectedRectangle,
           let handle = selected.hitTestResizeHandle(at: point) {
            handle.cursor.set()
            return
        }

        // Check if over a rectangle
        for rectangle in rectangles.reversed() {
            if rectangle.contains(point) {
                NSCursor.openHand.set()
                return
            }
        }

        // Default cursor
        NSCursor.crosshair.set()
    }

    // MARK: - Keyboard Events

    override var acceptsFirstResponder: Bool {
        return isEditMode
    }

    override func keyDown(with event: NSEvent) {
        guard isEditMode else { return }

        // Delete key or backspace
        if event.keyCode == 51 || event.keyCode == 117 {
            if let selected = selectedRectangle,
               let index = rectangles.firstIndex(where: { $0.id == selected.id }) {
                rectangles.remove(at: index)
                selectedRectangle = nil
                needsDisplay = true
            }
        }
    }

    // MARK: - Edit Dialog

    private func showEditDialog(for rectangle: CategoryRectangle) {
        let alert = NSAlert()
        alert.messageText = "Edit Rectangle"
        alert.informativeText = "Choose a color and enter a label for this category."

        // Create custom view for the dialog
        let dialogView = NSView(frame: NSRect(x: 0, y: 0, width: 300, height: 150))

        // Label text field
        let labelField = NSTextField(frame: NSRect(x: 20, y: 100, width: 260, height: 24))
        labelField.placeholderString = "Label (optional)"
        labelField.stringValue = rectangle.label
        dialogView.addSubview(labelField)

        // Color well
        let colorLabel = NSTextField(labelWithString: "Color:")
        colorLabel.frame = NSRect(x: 20, y: 70, width: 60, height: 20)
        dialogView.addSubview(colorLabel)

        let colorWell = NSColorWell(frame: NSRect(x: 90, y: 70, width: 44, height: 24))
        colorWell.color = rectangle.color
        dialogView.addSubview(colorWell)

        // Preset colors
        let presetLabel = NSTextField(labelWithString: "Presets:")
        presetLabel.frame = NSRect(x: 20, y: 40, width: 260, height: 20)
        dialogView.addSubview(presetLabel)

        // Preset color buttons
        var xOffset: CGFloat = 20
        for (index, presetColor) in ColorPresets.presets.enumerated() {
            let button = NSButton(frame: NSRect(x: xOffset, y: 10, width: 30, height: 24))
            button.bezelStyle = .rounded
            button.isBordered = true
            button.wantsLayer = true
            button.layer?.backgroundColor = presetColor.cgColor
            button.layer?.cornerRadius = 4
            button.tag = index
            button.target = self
            button.action = #selector(presetColorSelected(_:))

            // Store color well as represented object for callback
            button.cell?.representedObject = colorWell

            dialogView.addSubview(button)
            xOffset += 35
        }

        alert.accessoryView = dialogView
        alert.addButton(withTitle: "OK")
        alert.addButton(withTitle: "Cancel")

        let response = alert.runModal()

        if response == .alertFirstButtonReturn {
            rectangle.label = labelField.stringValue
            rectangle.color = colorWell.color
            needsDisplay = true
        }
    }

    @objc private func presetColorSelected(_ sender: NSButton) {
        if let colorWell = sender.cell?.representedObject as? NSColorWell {
            colorWell.color = ColorPresets.presets[sender.tag]
        }
    }

    // MARK: - Delete Menu

    private func showDeleteMenu(for rectangle: CategoryRectangle, at index: Int, point: NSPoint) {
        let menu = NSMenu()

        let deleteItem = NSMenuItem(
            title: "Delete Rectangle",
            action: #selector(deleteRectangle(_:)),
            keyEquivalent: ""
        )
        deleteItem.representedObject = index
        deleteItem.target = self
        menu.addItem(deleteItem)

        // Show menu at mouse location
        menu.popUp(positioning: nil, at: convert(point, from: nil), in: self)
    }

    @objc private func deleteRectangle(_ sender: NSMenuItem) {
        if let index = sender.representedObject as? Int,
           index < rectangles.count {
            rectangles.remove(at: index)
            selectedRectangle = nil
            needsDisplay = true
        }
    }

    // MARK: - Public Methods

    /// Clears all rectangles
    func clearAll() {
        rectangles.removeAll()
        selectedRectangle = nil
        creatingRectangle = nil
        needsDisplay = true
    }
}
