# Building a Professional DMG for Folder Categoriser

This guide will help you create a professional, distributable DMG installer.

## Quick Start

### Step 1: Build Release Version

1. Open **FolderCategoriser.xcodeproj** in Xcode
2. Go to **Product → Scheme → Edit Scheme** (or press ⌘<)
3. Select **Run** in the left sidebar
4. Change **Build Configuration** from "Debug" to **Release**
5. Click **Close**
6. Build the project: **Product → Build** (or press ⌘B)

Alternatively, build from command line:
```bash
xcodebuild -project FolderCategoriser.xcodeproj \
           -scheme FolderCategoriser \
           -configuration Release \
           clean build \
           BUILD_DIR="./build"
```

### Step 2: Run DMG Script

Simply run the automated script:

```bash
./create-dmg.sh
```

That's it! The script will:
- ✅ Verify the Release build exists
- ✅ Create a temporary DMG
- ✅ Add Applications symlink for easy installation
- ✅ Apply custom background (if available)
- ✅ Set icon positions and window size
- ✅ Compress the final DMG

## What You Get

The script creates: **FolderCategoriser-1.0.dmg**

When users open it, they'll see:
- Your app icon on the left
- Applications folder shortcut on the right
- Professional background
- Clear "drag to install" layout

## Testing the DMG

1. Mount the DMG:
   ```bash
   open FolderCategoriser-1.0.dmg
   ```

2. Drag the app to Applications

3. Launch from Applications and verify it works

4. Check that all features work correctly

## Customization

### Change DMG Background

Edit or replace `dmg-background.png` (600x400 pixels recommended)

### Modify DMG Settings

Edit `create-dmg.sh` and change these variables:
```bash
WINDOW_WIDTH=600        # DMG window width
WINDOW_HEIGHT=400       # DMG window height
ICON_SIZE=96           # Size of icons
APP_ICON_X=150         # App icon X position
APP_ICON_Y=180         # App icon Y position
APPS_LINK_X=450        # Applications link X position
APPS_LINK_Y=180        # Applications link Y position
```

### Update Version Number

In `create-dmg.sh`, change:
```bash
DMG_NAME="FolderCategoriser-1.0.dmg"
```

## Code Signing (Optional but Recommended)

For distribution outside the Mac App Store, you should code sign your app.

### Requirements:
- Apple Developer account ($99/year)
- Developer ID Application certificate

### Steps:

1. **Get your certificate identity:**
   ```bash
   security find-identity -v -p codesigning
   ```

2. **Sign the app:**
   ```bash
   codesign --deep --force --verify --verbose \
            --sign "Developer ID Application: Your Name (TEAM_ID)" \
            --options runtime \
            build/Release/FolderCategoriser.app
   ```

3. **Verify signing:**
   ```bash
   codesign --verify --deep --strict --verbose=2 \
            build/Release/FolderCategoriser.app
   ```

4. **Sign the DMG:**
   ```bash
   codesign --sign "Developer ID Application: Your Name (TEAM_ID)" \
            FolderCategoriser-1.0.dmg
   ```

5. **Notarize (for macOS 10.14+):**
   ```bash
   xcrun notarytool submit FolderCategoriser-1.0.dmg \
                          --apple-id "your@email.com" \
                          --team-id "TEAM_ID" \
                          --password "app-specific-password"
   ```

## Troubleshooting

### "Release build not found"
- Make sure you built with Release configuration
- Check that `build/Release/FolderCategoriser.app` exists

### DMG looks wrong when opened
- Clear DMG cache: `rm -rf /Users/*/Library/Saved\ Application\ State/com.apple.finder.savedState`
- Restart Finder: `killall Finder`
- Try opening the DMG again

### Background image not showing
- Ensure `dmg-background.png` exists in the project root
- Image should be 600x400 pixels
- Image must be PNG format

### AppleScript errors
- Grant Terminal/Script Editor permissions in System Preferences → Security & Privacy → Privacy → Automation
- Make sure Finder is running

## Distribution Checklist

Before distributing your DMG:

- [ ] Test on a fresh Mac (or VM)
- [ ] Verify all app features work
- [ ] Check app launches correctly from Applications
- [ ] Test on multiple macOS versions if possible
- [ ] Code sign the app (if distributing publicly)
- [ ] Notarize the DMG (required for macOS 10.15+)
- [ ] Create release notes
- [ ] Test the download and installation process

## File Structure

```
FolderCategoriser/
├── create-dmg.sh              # Main DMG creation script
├── dmg-background.png         # DMG background image (600x400)
├── build/
│   └── Release/
│       └── FolderCategoriser.app  # Release build
└── FolderCategoriser-1.0.dmg  # Final distributable DMG
```

## Tips

1. **Keep DMG size small:** The compressed DMG should be under 10MB for this app
2. **Test thoroughly:** Always test the DMG on a clean system before distribution
3. **Version your DMGs:** Include version number in filename (e.g., FolderCategoriser-1.0.dmg)
4. **Provide checksums:** Generate SHA256 for users to verify downloads
   ```bash
   shasum -a 256 FolderCategoriser-1.0.dmg
   ```

## Need Help?

- Check build logs in Xcode if build fails
- Run script with `bash -x create-dmg.sh` for detailed output
- Ensure you have Xcode Command Line Tools: `xcode-select --install`

---

**Happy distributing! 🚀**
