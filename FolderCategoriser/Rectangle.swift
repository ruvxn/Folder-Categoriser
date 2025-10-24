//
//  Rectangle.swift
//  FolderCategoriser
//
//  A model representing a categorization rectangle on the desktop.
//

import Cocoa

/// Represents a rectangle drawn on the desktop for categorizing folders
class CategoryRectangle {

    // MARK: - Properties

    /// Unique identifier for the rectangle
    let id: UUID

    /// The frame (position and size) of the rectangle
    var frame: NSRect

    /// The color used for both border and fill
    var color: NSColor

    /// The width of the border in points
    var borderWidth: CGFloat

    /// The opacity of the fill (0.0 = transparent, 1.0 = opaque)
    var fillOpacity: CGFloat

    /// Optional label text to display on the rectangle
    var label: String

    /// Font size for the label
    var fontSize: CGFloat

    // MARK: - Initialization

    init(frame: NSRect,
         color: NSColor = .systemBlue,
         borderWidth: CGFloat = 2.0,
         fillOpacity: CGFloat = 0.25,
         label: String = "",
         fontSize: CGFloat = 14.0) {
        self.id = UUID()
        self.frame = frame
        self.color = color
        self.borderWidth = borderWidth
        self.fillOpacity = fillOpacity
        self.label = label
        self.fontSize = fontSize
    }

    // MARK: - Drawing

    /// Draws the rectangle with border and optional fill
    /// - Parameters:
    ///   - showFill: Whether to draw the filled background
    func draw(showFill: Bool) {
        let path = NSBezierPath(rect: frame)

        // Draw fill if enabled
        if showFill {
            color.withAlphaComponent(fillOpacity).setFill()
            path.fill()
        }

        // Draw border (always visible)
        color.setStroke()
        path.lineWidth = borderWidth
        path.stroke()

        // Draw label if present
        if !label.isEmpty {
            drawLabel()
        }
    }

    /// Draws the label text on the rectangle
    private func drawLabel() {
        let textAttributes: [NSAttributedString.Key: Any] = [
            .font: NSFont.systemFont(ofSize: fontSize, weight: .semibold),
            .foregroundColor: NSColor.white
        ]

        let attributedString = NSAttributedString(string: label, attributes: textAttributes)
        let stringSize = attributedString.size()

        // Position label on the top border line (centered on top edge)
        let padding: CGFloat = 6.0
        let labelRect = NSRect(
            x: frame.origin.x + padding,
            y: frame.origin.y + frame.height - (stringSize.height + padding * 2) / 2,
            width: stringSize.width + padding * 2,
            height: stringSize.height + padding * 2
        )

        // Draw rounded background for label with the rectangle's color
        let labelBackground = NSBezierPath(roundedRect: labelRect, xRadius: 5, yRadius: 5)
        color.setFill()
        labelBackground.fill()

        // Draw label text in white
        attributedString.draw(at: NSPoint(
            x: labelRect.origin.x + padding,
            y: labelRect.origin.y + padding
        ))
    }

    // MARK: - Hit Testing

    /// Checks if a point is inside the rectangle
    func contains(_ point: NSPoint) -> Bool {
        return frame.contains(point)
    }

    /// Determines which resize handle (if any) contains the given point
    /// - Returns: The handle position or nil if no handle is hit
    func hitTestResizeHandle(at point: NSPoint) -> ResizeHandle? {
        let handleSize: CGFloat = 10.0

        for handle in ResizeHandle.allCases {
            let handleRect = getHandleRect(for: handle, size: handleSize)
            if handleRect.contains(point) {
                return handle
            }
        }

        return nil
    }

    /// Gets the rectangle for a specific resize handle
    private func getHandleRect(for handle: ResizeHandle, size: CGFloat) -> NSRect {
        let x = frame.origin.x
        let y = frame.origin.y
        let w = frame.width
        let h = frame.height
        let halfSize = size / 2

        switch handle {
        case .topLeft:
            return NSRect(x: x - halfSize, y: y + h - halfSize, width: size, height: size)
        case .top:
            return NSRect(x: x + w/2 - halfSize, y: y + h - halfSize, width: size, height: size)
        case .topRight:
            return NSRect(x: x + w - halfSize, y: y + h - halfSize, width: size, height: size)
        case .right:
            return NSRect(x: x + w - halfSize, y: y + h/2 - halfSize, width: size, height: size)
        case .bottomRight:
            return NSRect(x: x + w - halfSize, y: y - halfSize, width: size, height: size)
        case .bottom:
            return NSRect(x: x + w/2 - halfSize, y: y - halfSize, width: size, height: size)
        case .bottomLeft:
            return NSRect(x: x - halfSize, y: y - halfSize, width: size, height: size)
        case .left:
            return NSRect(x: x - halfSize, y: y + h/2 - halfSize, width: size, height: size)
        }
    }

    /// Draws resize handles around the rectangle
    func drawResizeHandles() {
        let handleSize: CGFloat = 8.0

        for handle in ResizeHandle.allCases {
            let handleRect = getHandleRect(for: handle, size: handleSize)
            let path = NSBezierPath(ovalIn: handleRect)

            // Fill handle
            NSColor.white.setFill()
            path.fill()

            // Stroke handle border
            color.setStroke()
            path.lineWidth = 1.5
            path.stroke()
        }
    }
}

// MARK: - Resize Handle Enum

/// Represents the eight resize handles around a rectangle
enum ResizeHandle: CaseIterable {
    case topLeft, top, topRight
    case right
    case bottomRight, bottom, bottomLeft
    case left

    /// Returns the appropriate cursor for this handle
    var cursor: NSCursor {
        switch self {
        case .topLeft, .bottomRight:
            return NSCursor.resizeNorthwestSoutheast
        case .top, .bottom:
            return NSCursor.resizeUpDown
        case .topRight, .bottomLeft:
            return NSCursor.resizeNortheastSouthwest
        case .left, .right:
            return NSCursor.resizeLeftRight
        }
    }
}

// MARK: - NSCursor Extensions

extension NSCursor {
    /// Cursor for NW-SE resize
    static var resizeNorthwestSoutheast: NSCursor {
        return NSCursor.crosshair // macOS doesn't have diagonal cursors by default
    }

    /// Cursor for NE-SW resize
    static var resizeNortheastSouthwest: NSCursor {
        return NSCursor.crosshair
    }
}
