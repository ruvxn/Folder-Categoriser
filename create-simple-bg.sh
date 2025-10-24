#!/bin/bash
# Create a professional looking DMG background

# Use Quartz to create a nice background
cat > /tmp/dmg-bg.html << 'HTML'
<html>
<body style="margin:0; width:600px; height:400px; background: linear-gradient(180deg, #f8f9fa 0%, #e9ecef 100%); display:flex; align-items:center; justify-content:center; font-family: -apple-system;">
<div style="text-align:center; color:#6c757d; font-size:14px; position:absolute; bottom:30px; width:100%;">
Drag to Applications folder to install
</div>
</body>
</html>
HTML

# Convert HTML to PNG using built-in webkit2png or screencapture
if command -v webkit2png &> /dev/null; then
    webkit2png -F -o dmg-bg /tmp/dmg-bg.html
    mv dmg-bg-full.png dmg-background.png 2>/dev/null || mv dmg-bg.png dmg-background.png
elif [ -f /usr/sbin/screencapture ]; then
    # Alternative: create with Apple Script
    osascript -e 'use framework "AppKit"
    set img to current application'"'"'s NSImage'"'"'s alloc()'"'"'s initWithSize:{600, 400}
    img'"'"'s lockFocus()
    set grad to current application'"'"'s NSGradient'"'"'s alloc()'"'"'s initWithColors:{current application'"'"'s NSColor'"'"'s colorWithRed:0.97 green:0.98 blue:0.98 alpha:1, current application'"'"'s NSColor'"'"'s colorWithRed:0.91 green:0.93 blue:0.93 alpha:1}
    grad'"'"'s drawInRect:(current application'"'"'s NSMakeRect(0, 0, 600, 400)) angle:90
    img'"'"'s unlockFocus()
    set tiffData to img'"'"'s TIFFRepresentation()
    set bitmapRep to current application'"'"'s NSBitmapImageRep'"'"'s imageRepWithData:tiffData
    set pngData to bitmapRep'"'"'s representationUsingType:(current application'"'"'s NSPNGFileType) |properties|:(missing value)
    pngData'"'"'s writeToFile:"dmg-background.png" atomically:true'
fi
