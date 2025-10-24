//
//  ColorPresets.swift
//  FolderCategoriser
//
//  Provides preset colors and color utilities for the application.
//

import Cocoa

/// Provides preset colors for quick rectangle categorization
struct ColorPresets {

    // MARK: - Preset Colors

    /// Array of preset colors for quick selection
    static let presets: [NSColor] = [
        NSColor(red: 0.2, green: 0.6, blue: 1.0, alpha: 1.0),   // Blue
        NSColor(red: 0.3, green: 0.8, blue: 0.4, alpha: 1.0),   // Green
        NSColor(red: 1.0, green: 0.6, blue: 0.2, alpha: 1.0),   // Orange
        NSColor(red: 0.9, green: 0.3, blue: 0.3, alpha: 1.0),   // Red
        NSColor(red: 0.7, green: 0.4, blue: 0.9, alpha: 1.0),   // Purple
        NSColor(red: 1.0, green: 0.8, blue: 0.2, alpha: 1.0),   // Yellow
        NSColor(red: 0.3, green: 0.7, blue: 0.7, alpha: 1.0),   // Teal
        NSColor(red: 1.0, green: 0.5, blue: 0.7, alpha: 1.0),   // Pink
    ]

    /// Returns the default color (first preset)
    static var defaultColor: NSColor {
        return presets[0]
    }

    // MARK: - Color Names

    /// Returns a human-readable name for a preset color
    static func name(for color: NSColor) -> String {
        // Compare colors with a small tolerance for floating-point differences
        let tolerance: CGFloat = 0.05

        for (index, preset) in presets.enumerated() {
            if colorsAreEqual(color, preset, tolerance: tolerance) {
                return presetNames[index]
            }
        }

        return "Custom"
    }

    /// Names corresponding to the preset colors
    private static let presetNames = [
        "Blue",
        "Green",
        "Orange",
        "Red",
        "Purple",
        "Yellow",
        "Teal",
        "Pink"
    ]

    // MARK: - Color Comparison

    /// Compares two colors for approximate equality
    private static func colorsAreEqual(_ color1: NSColor, _ color2: NSColor, tolerance: CGFloat) -> Bool {
        // Convert to RGB color space for comparison
        guard let rgb1 = color1.usingColorSpace(.deviceRGB),
              let rgb2 = color2.usingColorSpace(.deviceRGB) else {
            return false
        }

        return abs(rgb1.redComponent - rgb2.redComponent) < tolerance &&
               abs(rgb1.greenComponent - rgb2.greenComponent) < tolerance &&
               abs(rgb1.blueComponent - rgb2.blueComponent) < tolerance
    }
}
