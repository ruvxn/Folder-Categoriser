//
//  MenuBarController.swift
//  FolderCategoriser
//
//  Manages the menu bar icon and menu for the application.
//

import Cocoa

/// Manages the menu bar icon and application menu
class MenuBarController: NSObject {

    // MARK: - Properties

    /// The status item in the menu bar
    private var statusItem: NSStatusItem!

    /// The overlay window being controlled
    private weak var overlayWindow: OverlayWindow?

    /// Current mode (edit or lock)
    private var isEditMode: Bool = false

    /// Menu items that need to be updated
    private var modeToggleItem: NSMenuItem!
    private var fillToggleItem: NSMenuItem!
    private var borderWidthItem: NSMenuItem!
    private var opacitySliderItem: NSMenuItem!

    /// Slider for opacity control
    private var opacitySlider: NSSlider!

    /// Current fill opacity
    private var currentOpacity: CGFloat = 0.25

    /// Current border width
    private var currentBorderWidth: CGFloat = 2.0

    // MARK: - Initialization

    init(overlayWindow: OverlayWindow) {
        self.overlayWindow = overlayWindow
        super.init()
        setupStatusItem()
    }

    // MARK: - Setup

    private func setupStatusItem() {
        // Create status item in menu bar
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        // Set icon/title
        if let button = statusItem.button {
            // Try to use the app icon, fall back to text
            if let icon = NSImage(named: "AppIcon") {
                icon.size = NSSize(width: 18, height: 18)
                icon.isTemplate = true
                button.image = icon
            } else {
                // Use text as fallback
                button.title = "📁"
                button.font = NSFont.systemFont(ofSize: 16)
            }

            // Make sure button is visible
            button.setAccessibilityLabel("Folder Categoriser")
        }

        print("✅ Menu bar icon created")

        // Create menu
        let menu = NSMenu()

        // Mode toggle
        modeToggleItem = NSMenuItem(
            title: "Enter Edit Mode",
            action: #selector(toggleMode),
            keyEquivalent: "e"
        )
        modeToggleItem.target = self
        menu.addItem(modeToggleItem)

        menu.addItem(NSMenuItem.separator())

        // Fill toggle
        fillToggleItem = NSMenuItem(
            title: "✓ Show Fill",
            action: #selector(toggleFill),
            keyEquivalent: "f"
        )
        fillToggleItem.target = self
        menu.addItem(fillToggleItem)

        // Opacity slider
        menu.addItem(NSMenuItem.separator())
        let opacityLabel = NSMenuItem(title: "Fill Opacity:", action: nil, keyEquivalent: "")
        opacityLabel.isEnabled = false
        menu.addItem(opacityLabel)

        opacitySliderItem = createOpacitySliderMenuItem()
        menu.addItem(opacitySliderItem)

        // Border width submenu
        menu.addItem(NSMenuItem.separator())
        let borderWidthMenu = NSMenu()

        let borderWidths: [CGFloat] = [1.0, 2.0, 3.0, 4.0, 5.0]
        for width in borderWidths {
            let item = NSMenuItem(
                title: "\(Int(width))px",
                action: #selector(setBorderWidth(_:)),
                keyEquivalent: ""
            )
            item.target = self
            item.representedObject = width
            if width == currentBorderWidth {
                item.state = .on
            }
            borderWidthMenu.addItem(item)
        }

        borderWidthItem = NSMenuItem(title: "Border Width", action: nil, keyEquivalent: "")
        borderWidthItem.submenu = borderWidthMenu
        menu.addItem(borderWidthItem)

        menu.addItem(NSMenuItem.separator())

        // Clear all
        let clearItem = NSMenuItem(
            title: "Clear All Rectangles",
            action: #selector(clearAll),
            keyEquivalent: "k"
        )
        clearItem.target = self
        menu.addItem(clearItem)

        menu.addItem(NSMenuItem.separator())

        // Quit
        let quitItem = NSMenuItem(
            title: "Quit",
            action: #selector(quit),
            keyEquivalent: "q"
        )
        quitItem.target = self
        menu.addItem(quitItem)

        statusItem.menu = menu
    }

    private func createOpacitySliderMenuItem() -> NSMenuItem {
        let menuItem = NSMenuItem()

        // Create a container view for the slider
        let containerView = NSView(frame: NSRect(x: 0, y: 0, width: 200, height: 30))

        // Create slider
        opacitySlider = NSSlider(frame: NSRect(x: 20, y: 5, width: 160, height: 20))
        opacitySlider.minValue = 0.0
        opacitySlider.maxValue = 1.0
        opacitySlider.doubleValue = Double(currentOpacity)
        opacitySlider.isContinuous = true
        opacitySlider.target = self
        opacitySlider.action = #selector(opacityChanged(_:))

        containerView.addSubview(opacitySlider)

        menuItem.view = containerView

        return menuItem
    }

    // MARK: - Actions

    @objc private func toggleMode() {
        isEditMode.toggle()

        if isEditMode {
            overlayWindow?.enterEditMode()
            modeToggleItem.title = "Enter Lock Mode"
            updateMenuBarIcon(editMode: true)
        } else {
            overlayWindow?.enterLockMode()
            modeToggleItem.title = "Enter Edit Mode"
            updateMenuBarIcon(editMode: false)
        }
    }

    private func updateMenuBarIcon(editMode: Bool) {
        guard let button = statusItem.button else { return }

        if button.image != nil {
            // If using image, change the tint or overlay
            button.appearsDisabled = !editMode
        } else {
            // If using text/emoji
            button.title = editMode ? "📂" : "📁"
        }
    }

    @objc private func toggleFill() {
        guard let overlayView = overlayWindow?.overlayView else { return }

        overlayView.showFills.toggle()

        if overlayView.showFills {
            fillToggleItem.title = "✓ Show Fill"
        } else {
            fillToggleItem.title = "Show Fill"
        }
    }

    @objc private func opacityChanged(_ sender: NSSlider) {
        currentOpacity = CGFloat(sender.doubleValue)

        // Update opacity for all existing rectangles
        guard let overlayView = overlayWindow?.overlayView else { return }

        for rectangle in overlayView.rectangles {
            rectangle.fillOpacity = currentOpacity
        }

        overlayView.needsDisplay = true
    }

    @objc private func setBorderWidth(_ sender: NSMenuItem) {
        guard let width = sender.representedObject as? CGFloat else { return }

        currentBorderWidth = width

        // Update all menu items
        if let submenu = borderWidthItem.submenu {
            for item in submenu.items {
                item.state = .off
            }
            sender.state = .on
        }

        // Update border width for all existing rectangles
        guard let overlayView = overlayWindow?.overlayView else { return }

        for rectangle in overlayView.rectangles {
            rectangle.borderWidth = currentBorderWidth
        }

        overlayView.needsDisplay = true
    }

    @objc private func clearAll() {
        let alert = NSAlert()
        alert.messageText = "Clear All Rectangles?"
        alert.informativeText = "This action cannot be undone."
        alert.alertStyle = .warning
        alert.addButton(withTitle: "Clear All")
        alert.addButton(withTitle: "Cancel")

        let response = alert.runModal()

        if response == .alertFirstButtonReturn {
            overlayWindow?.overlayView.clearAll()
        }
    }

    @objc private func quit() {
        NSApplication.shared.terminate(nil)
    }

    // MARK: - Public Methods

    /// Returns the current fill opacity for new rectangles
    var fillOpacity: CGFloat {
        return currentOpacity
    }

    /// Returns the current border width for new rectangles
    var borderWidth: CGFloat {
        return currentBorderWidth
    }
}
