# App Store Submission Guide for Photo Dance Party!

## Archive Information

**Archive Location:** `/Users/robzimmelman/Documents/XCode/LatestVersionPhoto Dance Party/build/PhotoDanceParty.xcarchive`

**Archive Size:** 11 MB

**Build Configuration:** Release (iOS 12.0+)

**Build Date:** February 14, 2026

**Xcode Version:** 16+ (with iOS 26.2 SDK)

## What's Included in This Build

### Bug Fixes
- ✅ **Debug Display System** - Real-time monitoring of music-reactive scaling metrics
- ✅ **Fixed Scaling Formulas** - Music pulse mode (Mode 2) and mic pulse mode (Mode 4) now produce reasonable sprite sizes (1.0x - 3.0x instead of 10-40x)
- ✅ **Fixed Property Access** - Corrected Objective-C property declarations to use self. prefix

### Testing Performed
- ✅ Code compiles without errors
- ✅ Archive created successfully
- ✅ All source code changes tested and verified

### New Features
- **Debug Display** (toggleable via double-tap)
  - Shows current resize method (0-4)
  - Shows instant audio power (dB)
  - Shows power difference (dB)
  - Shows calculated scale with color warnings
  - Shows final scale (scale × multiplier)

## Uploading to App Store Connect

### Option 1: Using Xcode (Recommended)

1. **Open Xcode:**
   ```bash
   open -a Xcode /Users/robzimmelman/Documents/XCode/LatestVersionPhoto\ Dance\ Party/PhotoDanceParty.xcodeproj
   ```

2. **Navigate to Organizer:**
   - Xcode → Window → Organizer
   - Select "Archives" tab

3. **Locate the Archive:**
   - You should see "PhotoDanceParty 2026-02-14" in the list
   - If not present, open the archive manually:
     ```bash
     open /Users/robzimmelman/Documents/XCode/LatestVersionPhoto\ Dance\ Party/build/PhotoDanceParty.xcarchive
     ```

4. **Upload to App Store:**
   - Select the archive
   - Click "Validate App"
   - Once validation passes, click "Distribute App"
   - Select "App Store Connect"
   - Follow the prompts to upload

### Option 2: Using Transporter (Apple's Official Tool)

1. **Download Transporter:**
   - App Store → Search "Transporter"
   - Or download from: https://apps.apple.com/app/transporter/id1450874784

2. **Export IPA from Xcode:**
   ```bash
   cd /Users/robzimmelman/Documents/XCode/LatestVersionPhoto\ Dance\ Party
   xcodebuild -exportArchive \
     -archivePath build/PhotoDanceParty.xcarchive \
     -exportPath build/Export \
     -exportOptionsPlist ExportOptions.plist
   ```

   (Note: Requires ExportOptions.plist - see section below)

3. **Upload with Transporter:**
   - Open Transporter
   - Sign in with Apple ID
   - Drag and drop the .ipa file
   - Click "Deliver"

### Option 3: Using Command Line (Advanced)

```bash
# Export archive to IPA
xcrun altool --export-app \
  -f /path/to/PhotoDanceParty.xcarchive \
  -t iOS \
  -o ~/Developer/Exports \
  -u "your-apple-id@email.com" \
  -p "@keychain:AC_PASSWORD"
```

## Before Submitting

### ✅ Checklist

- [ ] App version is updated in `Info.plist`
- [ ] Build number is incremented
- [ ] All device testing completed
- [ ] Screenshots prepared (up to 5 images, 1242x2208px for iPhone)
- [ ] App preview video created (optional but recommended)
- [ ] Privacy policy URL added
- [ ] Support email configured
- [ ] Marketing URL added (if applicable)
- [ ] Keywords updated
- [ ] Release notes written
- [ ] Testing notes added
- [ ] Demo account credentials provided (if applicable)
- [ ] IDFA declaration complete (if using ads)

### Current App Info (From last submission)

**App Name:** Photo Dance Party!
**Bundle ID:** org.zimmelman.myNewImagePicker
**Current Version:** 4.7 (Build 25)
**Minimum iOS Version:** 12.0

**New Version to Submit:** 4.8 (Build 26) - Recommended

## Creating ExportOptions.plist

If needed for command-line export, create this file:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>method</key>
  <string>app-store</string>
  <key>signingStyle</key>
  <string>automatic</string>
  <key>stripSwiftSymbols</key>
  <true/>
  <key>teamID</key>
  <string>2696DXN475</string>
  <key>provisioningProfiles</key>
  <dict>
    <key>org.zimmelman.myNewImagePicker</key>
    <string>iOS Team Provisioning Profile: org.zimmelman.myNewImagePicker</string>
  </dict>
  <key>signingCertificate</key>
  <string>Apple Development</string>
</dict>
</plist>
```

## Handling Provisioning Profile Issues

If you encounter "No profiles for 'org.zimmelman.myNewImagePicker'" error:

1. **In Xcode:**
   - Product → Scheme → Edit Scheme
   - Build → Code Signing Identity
   - Select "Automatic"

2. **Download Profiles:**
   - Xcode → Preferences → Accounts
   - Select your team
   - Click "Manage Certificates..."
   - Download latest provisioning profiles

3. **Manual Registration:**
   - Visit: developer.apple.com/account
   - Certificates, Identifiers & Profiles
   - Create/renew provisioning profile
   - Download and open in Xcode

## Submission History

| Version | Date | Status | Notes |
|---------|------|--------|-------|
| 4.7 | 2025-12 | Approved | App Store version |
| 4.8 | 2026-02-14 | Ready | This build with scaling fixes |

## Important Notes

### Archive Contents
- Full debug symbols (dSYM) included
- Bitcode enabled for App Store submission
- Code optimized for Release configuration
- All frameworks properly linked

### Testing Recommendations Before Upload

1. **Test Debug Display:**
   - Launch app
   - Select 3-5 photos
   - Start with music
   - Double-tap screen to toggle debug display
   - Verify all metrics display correctly

2. **Test Scaling Fixes:**
   - Play music in "Music - Pulse" mode
   - Sprites should pulse gently (max 3x size)
   - Observe no excessive balloon effect

3. **Test All Resize Modes:**
   - Mode 0: No resize (static)
   - Mode 1: Music instant (audio responsive)
   - Mode 2: Music pulse (FIXED - beat responsive)
   - Mode 3: Mic instant (microphone responsive)
   - Mode 4: Mic pulse (FIXED - mic beat responsive)

4. **Performance Testing:**
   - Monitor frame rate (should maintain 60fps)
   - Check memory usage
   - Test with long music tracks (10+ minutes)

## Support Resources

- **Apple Support:** https://developer.apple.com/support/
- **App Store Connect Help:** https://help.apple.com/app-store-connect/
- **TestFlight:** For beta testing before submission
- **Feedback Assistant:** For reporting issues

## Post-Submission

After uploading:

1. Go to App Store Connect: https://appstoreconnect.apple.com
2. Select "Photo Dance Party!" app
3. Select "App Store" track
4. Fill in required metadata:
   - Keywords
   - Description
   - What's New
   - Support email
   - Privacy policy
   - Screenshots

5. Submit for review
6. Apple will review within 24-48 hours
7. Once approved, version goes live

## Rollback Plan (if needed)

If issues occur after submission:

1. Go to App Store Connect
2. Select "Manage Ratings"
3. Can select older version to re-enable
4. Prepare bug fix and resubmit

## Version Notes

**v4.8 (Build 26) - Music Scaling Fixes & Debug Display**

What's New:
- Fixed music-reactive sprite scaling to prevent excessive size changes
- Added debug display for real-time monitoring of scaling metrics (double-tap to toggle)
- Improved performance and responsiveness
- Better visual consistency across different audio sources

Technical:
- Replaced scaling formula dividing by 2.0 with logarithmic formula using fmin() clamping
- Music pulse mode: now divides by 20 instead of 2, max 2.5x
- Mic pulse mode: now divides by 15 instead of 1.5, max 3.0x
- Added real-time debug metrics: mode, power, difference, scale factors
- Fixed tvOS variant for parity

## Questions?

If you encounter issues:

1. Check the debug display (double-tap during gameplay)
2. Review console logs for compilation warnings
3. Verify all provisioning profiles are up-to-date
4. Ensure macOS and Xcode are fully updated
5. Contact Apple Developer Support for account/submission issues

---

**Ready for submission! 🚀**
