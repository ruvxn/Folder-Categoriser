//
//  AppDelegate.swift
//  FolderCategoriser
//
//  Main application delegate that sets up the overlay window and control panel.
//

import Cocoa

@main
class AppDelegate: NSObject, NSApplicationDelegate {

    // MARK: - Properties

    /// The transparent overlay window
    private var overlayWindow: OverlayWindow!

    /// The control panel window
    private var controlPanelWindow: ControlPanelWindow!

    // MARK: - Main Entry Point

    static func main() {
        let app = NSApplication.shared
        let delegate = AppDelegate()
        app.delegate = delegate
        app.run()
    }

    // MARK: - Application Lifecycle

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Ensure the app activates properly
        NSApp.setActivationPolicy(.regular)

        // Create the overlay window first (don't show it as key)
        setupOverlayWindow()

        // Setup control panel window with overlay reference
        setupControlPanel()

        // Start in Lock mode
        overlayWindow.enterLockMode()

        // Show control panel FIRST and make it key, then show overlay
        controlPanelWindow.makeKeyAndOrderFront(nil)
        overlayWindow.orderBack(nil)  // Show overlay but keep it behind

        // Force app activation
        NSApp.activate(ignoringOtherApps: true)
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Cleanup if needed
    }

    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        // Don't quit when control panel is closed (overlay window remains)
        return false
    }

    // MARK: - Setup

    private func setupOverlayWindow() {
        overlayWindow = OverlayWindow()
    }

    private func setupControlPanel() {
        controlPanelWindow = ControlPanelWindow(overlayWindow: overlayWindow)
    }
}
