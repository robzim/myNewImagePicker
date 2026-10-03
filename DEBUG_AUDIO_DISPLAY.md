# Audio Display & Playback Debug Guide

## Recent Changes Made

### 1. **Enhanced Audio Session Configuration**
- Changed from `PlayAndRecord` to `Playback` category (optimized for music playback, not recording)
- Using `DefaultToSpeaker` option to route audio to device speaker
- Added detailed logging of audio session status and output ports

### 2. **Comprehensive Debug Logging for Display**
Added NSLog statements to track:
- When `mySetupAudioDisplay` is called
- Scene dimensions and display node positioning
- Song title and artist values
- Background pill creation
- "NOW PLAYING" label creation
- Song title label creation and positioning
- Test red box creation (visual indicator)

### 3. **File Path Verification**
- Added detailed logging of bundled audio file path
- Logging file URL scheme, path, and existence check

---

## What to Watch For in Console Output

### Expected Console Log Flow:

```
🎵 mySetupAudioDisplay CALLED
   Scene size: 393.0 x 852.0
   Display position will be: (196.5, 792.0)
   Song title: Skrxlla - Caution
   Song artist: Photo Dance Party
```

**What this tells you:**
- ✅ Display setup is being called
- ✅ Scene is rendering at expected dimensions
- ✅ Song title and artist are set

### Background Pill Creation:
```
🎵 Creating background pill: width=320.0, height=50
🎵 Background pill created with zPosition=5
🎵 Background pill added
🎵 TEST RED BOX added at position (...)
```

**What this tells you:**
- ✅ Display node hierarchy is being created
- ✅ If you see the RED BOX on screen, the scene rendering is working

### Title Label Creation:
```
🎵 Creating 'NOW PLAYING' label
🎵 NOW PLAYING label at position: (-130.0, 12.0)
🎵 NOW PLAYING label added
🎵 Creating title label with text: 'Skrxlla - Caution'
🎵 Title label created at position: (-130.0, -6.0)
🎵 Title label added to display node
```

**What this tells you:**
- ✅ All UI elements are being created
- ✅ If RED BOX is visible but labels aren't, there's a font/color issue

### Audio Session Configuration:
```
✓ Audio session setCategory returned: 1
✓ Audio session category set successfully (Playback mode)
✓ Audio session setActive returned: 1
✓ Audio session activated successfully
✓ Current audio session category: AVAudioSessionCategoryPlayback
✓ Current audio session mode: AVAudioSessionModeDefault
✓ Output ports count: 1
  - Output Port: Speaker (Type: AVAudioSessionPortTypeSpeaker)
```

**What this tells you:**
- ✅ Audio session is properly configured
- ✅ Speaker is available as output port
- ⚠️ If "Output ports count: 0", audio won't play!

### Audio File & Playback:
```
Using bundled audio file. Sound file path: /var/containers/Bundle/Application/.../Skrxlla - Caution.mp3
✓ Audio file exists at: /var/containers/Bundle/Application/.../Skrxlla - Caution.mp3
✓ AVAudioPlayer created successfully
✓ AVAudioPlayer prepared to play
✓ AVAudioPlayer configured with metering and looping
✓ AVAudioPlayer volume set to maximum
🔊 AVAudioPlayer play() returned: 1, isPlaying: 1, volume: 1.000000
✓✓✓ MUSIC SHOULD BE PLAYING NOW ✓✓✓
```

**What this tells you:**
- ✅ File path is correct
- ✅ File exists in bundle
- ✅ AVAudioPlayer was created successfully
- ✅ play() returned 1 (success)
- ✅ isPlaying says 1 (true)
- ⚠️ If isPlaying is 0, something went wrong

---

## Troubleshooting

### Issue: RED BOX visible but NO SONG TITLE TEXT
**Possible Causes:**
- White text on white background (unlikely with black pill background)
- Labels not being added to node
- Font not available
- Z-position too low

**Check Console For:**
- "Creating 'NOW PLAYING' label"
- "Title label added to display node"
- If these logs DON'T appear, labels aren't being created

### Issue: NO RED BOX visible (display node not rendering)
**Possible Causes:**
- mySetupAudioDisplay not being called
- Scene not rendering
- Display node not being added to scene

**Check Console For:**
- "🎵 mySetupAudioDisplay CALLED"
- "Audio display node added to scene"
- If these logs DON'T appear, method isn't being called

### Issue: Audio not playing despite all logs saying it should be
**Possible Causes:**
- Device mute switch is ON (physical switch on side of phone)
- Volume is muted in Settings > Sounds
- Audio file is corrupted
- Output port is not Speaker (might be Receiver or Bluetooth)

**Check Console For:**
- "Output Port: Speaker" - if NOT Speaker, that's the problem
- "play() returned: 1" - if this is 0, AVAudioPlayer.play() failed
- "isPlaying: 1" - if this is 0, playback didn't actually start

### Issue: Audio plays but VERY QUIET
**Possible Causes:**
- AVAudioPlayer volume needs adjustment
- Audio file itself is quiet
- Device volume is low

**Check Console For:**
- "volume: 1.000000" should show 1.0 (maximum)
- Check physical device volume buttons/Control Center

---

## Testing Checklist

1. **Visual Test:**
   - [ ] RED BOX appears at top of screen?
   - [ ] "NOW PLAYING" text appears?
   - [ ] Song title appears?

2. **Audio Session Test:**
   - [ ] Console shows "Output Port: Speaker"?
   - [ ] Console shows "play() returned: 1"?
   - [ ] Console shows "isPlaying: 1"?

3. **Sound Test:**
   - [ ] Device mute switch is OFF (upward position)?
   - [ ] Device volume is HIGH (check Control Center)?
   - [ ] Audio actually plays from speaker?

---

## Key Files Modified

- **GameScene.m (mySetupAudioDisplay):**
  - Enhanced logging for display node creation
  - Added test red box for visual debugging

- **GameScene.m (myStartTheMusic):**
  - Changed audio session to `Playback` category
  - Added audio session status logging
  - Added output port verification
  - Enhanced file path logging

---

## Next Steps

1. Build and install the app
2. Launch on device
3. Check console output for the logs listed above
4. Look for the RED BOX on screen - this confirms rendering works
5. Check audio session output ports - should show "Speaker"
6. If audio still doesn't play:
   - Check device mute switch
   - Check device volume level
   - Check iOS Settings > Sounds

