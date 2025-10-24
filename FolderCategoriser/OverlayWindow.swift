//
//  OverlayWindow.swift
//  FolderCategoriser
//
//  A transparent overlay window that sits above the desktop wallpaper
//  but below desktop icons.
//

import Cocoa

/// Transparent overlay window for drawing categorization rectangles
class OverlayWindow: NSWindow {

    // MARK: - Properties

    /// The custom overlay view that handles drawing and interactions
    var overlayView: OverlayView!

    // MARK: - Initialization

    init() {
        // Get the screen frame (main screen)
        let screenFrame = NSScreen.main?.frame ?? NSRect.zero

        // Initialize the window with full screen frame
        super.init(
            contentRect: screenFrame,
            styleMask: [.borderless],
            backing: .buffered,
            defer: false
        )

        // Configure window properties
        setupWindow()

        // Create and set the overlay view
        setupOverlayView()
    }

    // MARK: - Setup

    private func setupWindow() {
        // Make the window transparent
        isOpaque = false
        backgroundColor = .clear
        hasShadow = false

        // Set window level to be above desktop icons but below normal windows
        // Using a level between desktop and normal windows
        level = NSWindow.Level(rawValue: Int(CGWindowLevelForKey(.desktopIconWindow)) + 1)

        // Initially ignore mouse events (Lock mode)
        ignoresMouseEvents = true

        // Prevent the window from being hidden when app is inactive
        collectionBehavior = [.canJoinAllSpaces, .stationary]

        // Don't show in mission control or app switcher
        isExcludedFromWindowsMenu = true
    }

    private func setupOverlayView() {
        overlayView = OverlayView(frame: contentView!.bounds)
        contentView = overlayView
    }

    // MARK: - Mode Management

    /// Switches to Edit mode (captures mouse events)
    func enterEditMode() {
        ignoresMouseEvents = false
        overlayView.isEditMode = true
        overlayView.needsDisplay = true
    }

    /// Switches to Lock mode (ignores mouse events, click-through)
    func enterLockMode() {
        ignoresMouseEvents = true
        overlayView.isEditMode = false
        overlayView.needsDisplay = true
    }

    // MARK: - NSWindow Overrides

    /// Prevents the window from becoming key (so it doesn't steal focus)
    override var canBecomeKey: Bool {
        return overlayView.isEditMode
    }

    /// Prevents the window from becoming main
    override var canBecomeMain: Bool {
        return false
    }
}
