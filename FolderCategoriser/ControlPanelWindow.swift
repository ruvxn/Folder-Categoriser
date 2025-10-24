//
//  ControlPanelWindow.swift
//  FolderCategoriser
//
//  Control panel window for managing the overlay settings.
//

import Cocoa

/// Control panel window with UI controls for the application
class ControlPanelWindow: NSWindow {

    // MARK: - Properties

    private weak var overlayWindow: OverlayWindow?
    private var controlPanelView: ControlPanelView!

    // MARK: - Initialization

    init(overlayWindow: OverlayWindow) {
        self.overlayWindow = overlayWindow

        // Create a modern, taller window for more controls
        let windowRect = NSRect(x: 100, y: 100, width: 450, height: 780)

        super.init(
            contentRect: windowRect,
            styleMask: [.titled, .closable, .miniaturizable, .resizable],
            backing: .buffered,
            defer: false
        )

        setupWindow()
        setupControlPanel()
    }

    // MARK: - Setup

    private func setupWindow() {
        title = "Folder Categoriser"

        // Center the window on screen
        center()

        // Use normal window level
        level = .normal

        // Set minimum and maximum sizes
        minSize = NSSize(width: 450, height: 400)
        maxSize = NSSize(width: 450, height: 1000)

        // Ensure window is visible
        isReleasedWhenClosed = false
        collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
    }

    private func setupControlPanel() {
        // Create scroll view
        let scrollView = NSScrollView(frame: contentView!.bounds)
        scrollView.hasVerticalScroller = true
        scrollView.hasHorizontalScroller = false
        scrollView.autohidesScrollers = true
        scrollView.backgroundColor = .clear
        scrollView.drawsBackground = false

        // Create content view with full height for all controls
        let contentHeight: CGFloat = 800 // Optimized height for all controls
        let contentFrame = NSRect(x: 0, y: 0, width: contentView!.bounds.width, height: contentHeight)
        controlPanelView = ControlPanelView(frame: contentFrame, overlayWindow: overlayWindow)

        // Set up the document view
        scrollView.documentView = controlPanelView

        // Set the scroll view as the content view
        contentView = scrollView
    }
}

// MARK: - Control Panel View

class ControlPanelView: NSView {

    // MARK: - Properties

    private weak var overlayWindow: OverlayWindow?
    private var isEditMode: Bool = false

    // UI Elements
    private var modeToggleButton: NSButton!
    private var modeStatusLabel: NSTextField!
    private var fillToggle: NSButton!
    private var opacitySlider: NSSlider!
    private var opacityLabel: NSTextField!
    private var borderWidthSlider: NSSlider!
    private var borderWidthLabel: NSTextField!
    private var colorButtons: [NSButton] = []
    private var selectedColorIndex: Int = 0
    private var clearButton: NSButton!

    // MARK: - Initialization

    init(frame frameRect: NSRect, overlayWindow: OverlayWindow?) {
        self.overlayWindow = overlayWindow
        super.init(frame: frameRect)
        setupUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }

    // MARK: - UI Setup

    private func setupUI() {
        wantsLayer = true
        layer?.backgroundColor = NSColor.windowBackgroundColor.cgColor

        let margin: CGFloat = 25
        let cardPadding: CGFloat = 20
        var currentY: CGFloat = bounds.height - 30

        // MARK: - HEADER
        let titleLabel = NSTextField(labelWithString: "Folder Categoriser")
        titleLabel.font = NSFont.systemFont(ofSize: 24, weight: .bold)
        titleLabel.frame = NSRect(x: margin, y: currentY, width: bounds.width - margin * 2, height: 30)
        titleLabel.alignment = .center
        titleLabel.isBezeled = false
        titleLabel.isEditable = false
        titleLabel.drawsBackground = false
        addSubview(titleLabel)
        currentY -= 40

        let subtitleLabel = NSTextField(labelWithString: "Organize your desktop visually")
        subtitleLabel.font = NSFont.systemFont(ofSize: 12, weight: .regular)
        subtitleLabel.textColor = .secondaryLabelColor
        subtitleLabel.frame = NSRect(x: margin, y: currentY, width: bounds.width - margin * 2, height: 16)
        subtitleLabel.alignment = .center
        subtitleLabel.isBezeled = false
        subtitleLabel.isEditable = false
        subtitleLabel.drawsBackground = false
        addSubview(subtitleLabel)
        currentY -= 40

        // MARK: - MODE CARD
        let modeCardHeight: CGFloat = 120
        let modeCard = createCard(at: currentY - modeCardHeight, height: modeCardHeight)
        addSubview(modeCard)
        currentY -= cardPadding

        modeStatusLabel = NSTextField(labelWithString: "🔒 Lock Mode")
        modeStatusLabel.font = NSFont.systemFont(ofSize: 14, weight: .semibold)
        modeStatusLabel.frame = NSRect(x: margin + 40, y: currentY, width: bounds.width - margin * 2 - 80, height: 36)
        modeStatusLabel.alignment = .center
        modeStatusLabel.textColor = .white
        modeStatusLabel.drawsBackground = true
        modeStatusLabel.backgroundColor = .systemBlue
        modeStatusLabel.isBordered = false
        modeStatusLabel.isEditable = false
        modeStatusLabel.wantsLayer = true
        modeStatusLabel.layer?.cornerRadius = 18
        addSubview(modeStatusLabel)
        currentY -= 50

        modeToggleButton = NSButton(frame: NSRect(x: margin + 40, y: currentY, width: bounds.width - margin * 2 - 80, height: 36))
        modeToggleButton.title = "Enter Edit Mode"
        modeToggleButton.bezelStyle = .rounded
        modeToggleButton.font = NSFont.systemFont(ofSize: 13, weight: .medium)
        modeToggleButton.target = self
        modeToggleButton.action = #selector(toggleMode)
        modeToggleButton.keyEquivalent = "e"
        addSubview(modeToggleButton)
        currentY -= (modeCardHeight - 70) + 20

        // MARK: - COLOR CARD
        let colorCardHeight: CGFloat = 250
        let colorCardY = currentY - colorCardHeight
        let colorCard = createCard(at: colorCardY, height: colorCardHeight)
        addSubview(colorCard)
        currentY -= 25

        let colorSectionLabel = NSTextField(labelWithString: "Rectangle Color")
        colorSectionLabel.font = NSFont.systemFont(ofSize: 13, weight: .semibold)
        colorSectionLabel.frame = NSRect(x: margin + cardPadding, y: currentY, width: 200, height: 18)
        colorSectionLabel.isBezeled = false
        colorSectionLabel.isEditable = false
        colorSectionLabel.drawsBackground = false
        addSubview(colorSectionLabel)
        currentY -= 30

        // Add separator line
        let colorSeparator = NSBox(frame: NSRect(x: margin + cardPadding, y: currentY, width: bounds.width - margin * 2 - cardPadding * 2, height: 1))
        colorSeparator.boxType = .separator
        addSubview(colorSeparator)
        currentY -= 25

        let colors: [NSColor] = [
            .systemBlue, .systemPurple, .systemPink,
            .systemRed, .systemOrange, .systemYellow,
            .systemGreen, .systemTeal, .systemGray
        ]

        let colorButtonSize: CGFloat = 50
        let colorSpacing: CGFloat = 18
        let colorGridWidth = colorButtonSize * 3 + colorSpacing * 2
        let colorStartX = (bounds.width - colorGridWidth) / 2

        for (index, color) in colors.enumerated() {
            let row = index / 3
            let col = index % 3
            let x = colorStartX + CGFloat(col) * (colorButtonSize + colorSpacing)
            let y = currentY - CGFloat(row) * (colorButtonSize + colorSpacing)

            let button = NSButton(frame: NSRect(x: x, y: y, width: colorButtonSize, height: colorButtonSize))
            button.title = "" // Remove button text
            button.isBordered = false
            button.wantsLayer = true
            button.layer?.backgroundColor = color.cgColor
            button.layer?.cornerRadius = 11
            button.layer?.borderWidth = index == 0 ? 3 : 0
            button.layer?.borderColor = NSColor.white.cgColor
            button.target = self
            button.action = #selector(colorSelected(_:))
            button.tag = index
            button.layer?.shadowColor = NSColor.black.cgColor
            button.layer?.shadowOpacity = 0.25
            button.layer?.shadowOffset = NSSize(width: 0, height: -1)
            button.layer?.shadowRadius = 4

            colorButtons.append(button)
            addSubview(button)
        }
        currentY -= (colorButtonSize * 3 + colorSpacing * 2) + 25

        // MARK: - APPEARANCE CARD
        let appearanceCardHeight: CGFloat = 215
        let appearanceCard = createCard(at: currentY - appearanceCardHeight, height: appearanceCardHeight)
        addSubview(appearanceCard)
        currentY -= cardPadding

        let appearanceLabel = NSTextField(labelWithString: "Appearance")
        appearanceLabel.font = NSFont.systemFont(ofSize: 13, weight: .semibold)
        appearanceLabel.frame = NSRect(x: margin + cardPadding, y: currentY, width: 150, height: 18)
        appearanceLabel.isBezeled = false
        appearanceLabel.isEditable = false
        appearanceLabel.drawsBackground = false
        addSubview(appearanceLabel)
        currentY -= 35

        fillToggle = NSButton(checkboxWithTitle: "Show Fill", target: self, action: #selector(toggleFill))
        fillToggle.frame = NSRect(x: margin + cardPadding, y: currentY, width: 200, height: 20)
        fillToggle.state = .on
        fillToggle.font = NSFont.systemFont(ofSize: 12, weight: .medium)
        addSubview(fillToggle)
        currentY -= 38

        opacityLabel = NSTextField(labelWithString: "Fill Opacity: 25%")
        opacityLabel.font = NSFont.systemFont(ofSize: 12, weight: .medium)
        opacityLabel.textColor = .secondaryLabelColor
        opacityLabel.frame = NSRect(x: margin + cardPadding, y: currentY, width: 150, height: 16)
        opacityLabel.isBezeled = false
        opacityLabel.isEditable = false
        opacityLabel.drawsBackground = false
        addSubview(opacityLabel)
        currentY -= 28

        opacitySlider = NSSlider(frame: NSRect(x: margin + cardPadding, y: currentY, width: bounds.width - margin * 2 - cardPadding * 2, height: 20))
        opacitySlider.minValue = 0.0
        opacitySlider.maxValue = 1.0
        opacitySlider.doubleValue = 0.25
        opacitySlider.isContinuous = true
        opacitySlider.target = self
        opacitySlider.action = #selector(opacityChanged)
        addSubview(opacitySlider)
        currentY -= 38

        borderWidthLabel = NSTextField(labelWithString: "Border Width: 2px")
        borderWidthLabel.font = NSFont.systemFont(ofSize: 12, weight: .medium)
        borderWidthLabel.textColor = .secondaryLabelColor
        borderWidthLabel.frame = NSRect(x: margin + cardPadding, y: currentY, width: 150, height: 16)
        borderWidthLabel.isBezeled = false
        borderWidthLabel.isEditable = false
        borderWidthLabel.drawsBackground = false
        addSubview(borderWidthLabel)
        currentY -= 28

        borderWidthSlider = NSSlider(frame: NSRect(x: margin + cardPadding, y: currentY, width: bounds.width - margin * 2 - cardPadding * 2, height: 20))
        borderWidthSlider.minValue = 1.0
        borderWidthSlider.maxValue = 8.0
        borderWidthSlider.doubleValue = 2.0
        borderWidthSlider.isContinuous = true
        borderWidthSlider.target = self
        borderWidthSlider.action = #selector(borderWidthChanged)
        addSubview(borderWidthSlider)
        currentY -= 45

        // MARK: - ACTIONS
        clearButton = NSButton(frame: NSRect(x: margin + 30, y: currentY, width: bounds.width - margin * 2 - 60, height: 36))
        clearButton.title = "Clear All Rectangles"
        clearButton.bezelStyle = .rounded
        clearButton.font = NSFont.systemFont(ofSize: 12, weight: .medium)
        clearButton.target = self
        clearButton.action = #selector(clearAll)
        clearButton.keyEquivalent = "k"
        addSubview(clearButton)
        currentY -= 50

        // MARK: - HELP TEXT
        let helpText = NSTextField(wrappingLabelWithString: "💡 Edit Mode: Drag to create • Lock Mode: Click through")
        helpText.font = NSFont.systemFont(ofSize: 10, weight: .regular)
        helpText.textColor = .tertiaryLabelColor
        helpText.frame = NSRect(x: margin + 15, y: currentY - 30, width: bounds.width - margin * 2 - 30, height: 30)
        helpText.alignment = .center
        helpText.isBezeled = false
        helpText.isEditable = false
        helpText.drawsBackground = false
        addSubview(helpText)
    }

    // Creates a modern card-style container
    private func createCard(at yPosition: CGFloat, height: CGFloat) -> NSView {
        let card = NSView(frame: NSRect(x: 20, y: yPosition, width: bounds.width - 40, height: height))
        card.wantsLayer = true
        card.layer?.backgroundColor = NSColor.controlBackgroundColor.cgColor
        card.layer?.cornerRadius = 14
        card.layer?.borderWidth = 1
        card.layer?.borderColor = NSColor.separatorColor.withAlphaComponent(0.5).cgColor
        card.layer?.shadowColor = NSColor.black.cgColor
        card.layer?.shadowOpacity = 0.1
        card.layer?.shadowOffset = NSSize(width: 0, height: 1)
        card.layer?.shadowRadius = 10
        return card
    }

    private func addSeparator(at yPosition: CGFloat) {
        let separator = NSBox(frame: NSRect(x: 40, y: yPosition, width: bounds.width - 80, height: 1))
        separator.boxType = .separator
        addSubview(separator)
    }

    // MARK: - Actions

    @objc private func toggleMode() {
        isEditMode.toggle()

        if isEditMode {
            overlayWindow?.enterEditMode()
            modeToggleButton.title = "Enter Lock Mode"
            modeStatusLabel.stringValue = "✏️ Edit Mode"
            modeStatusLabel.textColor = .white
            modeStatusLabel.backgroundColor = .systemGreen
        } else {
            overlayWindow?.enterLockMode()
            modeToggleButton.title = "Enter Edit Mode"
            modeStatusLabel.stringValue = "🔒 Lock Mode"
            modeStatusLabel.textColor = .white
            modeStatusLabel.backgroundColor = .systemBlue
        }
    }

    @objc private func toggleFill() {
        guard let overlayView = overlayWindow?.overlayView else { return }
        overlayView.showFills = (fillToggle.state == .on)
    }

    @objc private func opacityChanged() {
        let opacity = CGFloat(opacitySlider.doubleValue)
        opacityLabel.stringValue = String(format: "Fill Opacity: %.0f%%", opacity * 100)

        guard let overlayView = overlayWindow?.overlayView else { return }
        for rectangle in overlayView.rectangles {
            rectangle.fillOpacity = opacity
        }
        overlayView.needsDisplay = true
    }

    @objc private func borderWidthChanged() {
        let width = CGFloat(borderWidthSlider.doubleValue)
        borderWidthLabel.stringValue = String(format: "Border Width: %.0fpx", width)

        guard let overlayView = overlayWindow?.overlayView else { return }
        for rectangle in overlayView.rectangles {
            rectangle.borderWidth = width
        }
        overlayView.needsDisplay = true
    }

    @objc private func colorSelected(_ sender: NSButton) {
        // Update selection indicator
        for (index, button) in colorButtons.enumerated() {
            button.layer?.borderWidth = (index == sender.tag) ? 3 : 0
        }
        selectedColorIndex = sender.tag

        // Get the selected color
        let colors: [NSColor] = [
            .systemBlue, .systemPurple, .systemPink,
            .systemRed, .systemOrange, .systemYellow,
            .systemGreen, .systemTeal, .systemGray
        ]

        guard sender.tag < colors.count else { return }
        let selectedColor = colors[sender.tag]

        // Update default color for new rectangles
        overlayWindow?.overlayView.defaultColor = selectedColor

        // Update ALL existing rectangles to the new color
        guard let overlayView = overlayWindow?.overlayView else { return }
        for rectangle in overlayView.rectangles {
            rectangle.color = selectedColor
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
}
