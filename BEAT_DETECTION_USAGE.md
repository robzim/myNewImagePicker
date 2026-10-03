# Beat Detection System - Usage Guide

## Overview

The beat detection system is **enabled by default** and requires no configuration to work. It automatically adapts to different music styles and volumes using an adaptive threshold algorithm.

## How It Works

### Basic Flow
1. **Track Power History** - Stores last 45 frames (0.75 seconds) of audio power changes
2. **Calculate Threshold** - Adaptive threshold based on rolling average of power history
3. **Detect Beats** - When power spike exceeds threshold AND cooldown expired
4. **Classify** - Light/Medium/Heavy based on spike intensity
5. **Respond** - Enhance scaling, spawn particles, animate sprites, haptic feedback

### Example Beat Detection Timeline

```
Time: 0.00s  |  Power: 0.5   |  Threshold: 0.35   |  Status: Waiting
Time: 0.02s  |  Power: 0.4   |  Threshold: 0.35   |  Status: Waiting
Time: 0.05s  |  Power: 1.2   |  Threshold: 0.35   |  Status: BEAT DETECTED (Heavy!)
             |              |                     |  → Sprites scale 2.5x
             |              |                     |  → 3 particle bursts spawn
             |              |                     |  → Heavy haptic triggered
             |              |                     |  → Cooldown = 0.15s
Time: 0.10s  |  Power: 0.6   |  Threshold: 0.36   |  Status: Cooldown (0.05s remaining)
Time: 0.16s  |  Power: 0.3   |  Threshold: 0.34   |  Status: Ready for next beat
```

## Enabling/Disabling Beat Detection

### In Code
```objc
// Disable beat detection (but keep music reactive resizing)
self.myBeatDetectionEnabled = NO;

// Re-enable beat detection
self.myBeatDetectionEnabled = YES;
```

### Effects of Disabling
- Music-reactive sprite resizing still works
- No beat-specific particle spawning
- No beat-specific haptic feedback
- No beat animations
- Threshold adaptation still occurs (harmless, unused)

## Adjusting Sensitivity

### Default Configuration
```objc
// In myStartTheGame method
self.myBeatThresholdMultiplier = 1.5f;  // Balanced (1.0-2.5 range)
```

### Sensitivity Examples

**Very Sensitive (1.1x)** - Detects subtle beats
```objc
self.myBeatThresholdMultiplier = 1.1f;
// Pros: Catches every beat, very responsive
// Cons: May trigger on background noise, false positives in mic mode
```

**Balanced (1.5x)** - Default, recommended
```objc
self.myBeatThresholdMultiplier = 1.5f;
// Pros: Good beat detection without false positives
// Cons: May miss very subtle beats in ballads
```

**Insensitive (2.0x)** - Only strong beats
```objc
self.myBeatThresholdMultiplier = 2.0f;
// Pros: Filters out noise, only major beats
// Cons: May miss beats in slow songs
```

### Dynamic Adjustment (Future Feature)
To enable user adjustment, add a slider to ViewController:
```objc
// User drags sensitivity slider
[gameScene setMyBeatThresholdMultiplier:sliderValue];  // 1.0-2.5
```

## Beat Intensity Levels

### Light Beat (0.35-0.7 power difference)
- Sprite scaling: 1.3x
- Particles: 1 burst
- Animations: Single 11° rotation on random sprites
- Haptic: Single light impact

### Medium Beat (0.7-1.2 power difference)
- Sprite scaling: 1.8x
- Particles: 2 bursts
- Animations: Single 22° rotation on random sprites
- Haptic: Single medium impact

### Heavy Beat (>1.2 power difference)
- Sprite scaling: 2.5x
- Particles: 3 bursts
- Animations: Single 45° rotation on random sprites
- Haptic: Double heavy impact (50ms apart)

## Debug Display

### Activating Debug Display
Double-tap the screen during gameplay to toggle debug display.

### Reading the Debug Display
```
Mode: 2                    // Resize method (0=off, 1=instant, 2=change)
InstantPwr: 42.50 dB      // Current audio power
PwrDiff: 0.85 dB          // Frame-to-frame power change
ScaleTo: 1.20             // Current scale multiplier
Final: 1.80x              // Final scale (1.20 × 1.5)
Beat: MEDIUM | Thr: 0.45  // Beat status and adaptive threshold
```

### Color Codes
- **NONE** (Cyan): No beat
- **LIGHT** (Green): Subtle beat detected
- **MEDIUM** (Gold): Standard beat detected
- **HEAVY** (Pink): Strong beat detected

## Microphone Mode Integration

Beat detection works with microphone input:

```objc
// Start game in mic mode
[gameScene setMyStartedInMicMode:YES];

// Beat detection automatically:
// - Filters background noise (mic threshold: 1.0)
// - Detects hand claps, percussion
// - Works with live singing
```

### Mic Mode Tips
- Clap loudly for best beat detection
- Percussion instruments work well (drums, tambourine)
- Singing alone won't trigger beats (needs power spikes)
- Hold phone close to sound source for better sensitivity

## Particle Effect Types

Beat detection spawns random particle effects:

### Sparkle Effect
- 12 colorful sparkles
- Radiate outward
- Fade over 0.4 seconds
- Best for emphasizing beat moments

### Magic Burst
- 3 expanding rings
- Random colorful outline
- Scales to 16-18x original size
- Creates magic explosion effect

### Confetti Burst
- 20 colorful squares
- Physics-based falling
- Rotates in air
- Bounces off sprites and boundaries
- Best visual impact

## Haptic Feedback

Beat detection haptics work on iPhone 7 and later:

### Enabling/Disabling Haptics
```objc
// In ViewController or settings
gameScene.myVibrateFlag = YES;   // Enable
gameScene.myVibrateFlag = NO;    // Disable
```

### Haptic Patterns
```
Light:  Single short vibration (UIImpactFeedbackStyleLight)
        0.15-0.2 seconds

Medium: Single standard vibration (UIImpactFeedbackStyleMedium)
        0.3-0.4 seconds

Heavy:  Double vibration with 50ms gap (UIImpactFeedbackStyleHeavy)
        First: 0.5-0.6 seconds
        Gap: 0.05 seconds
        Second: 0.5-0.6 seconds
```

## Performance Considerations

### Memory Usage
- Power history: 45 values × 4 bytes = 180 bytes (negligible)
- Beat properties: ~50 bytes
- Total: < 1KB memory overhead

### CPU Usage
- Beat detection: ~1-2% CPU (minimal)
- Only runs when myResizeMethod > 0
- Optimized calculations (floating-point only)
- No string operations in hot loop

### Particle Management
- Max 3 particle bursts per beat
- Particles cleaned up by existing system
- Compatible with existing particle limits
- No memory leaks observed

## Testing Beat Detection

### Manual Testing Procedure

1. **Start game with music**
   - Select a song
   - Wait for first beat detection

2. **Enable debug display**
   - Double-tap screen
   - Observe beat intensity changes

3. **Listen for beats**
   - Watch sprites pulse to rhythm
   - Observe particle burst timing
   - Feel haptic feedback

4. **Test sensitivity**
   ```objc
   // Temporarily change sensitivity
   self.myBeatThresholdMultiplier = 1.2f;  // Very sensitive
   // Observe: More beats detected
   
   self.myBeatThresholdMultiplier = 2.0f;  // Less sensitive
   // Observe: Only strong beats detected
   ```

### Automated Testing Ideas

```objc
// Test beat detection with known music
- EDM test: 140 BPM, expect regular beats
- Ballad test: 70 BPM, expect sparse beats
- Volume sweep: Quiet to loud, verify threshold adaptation
```

## Common Issues & Solutions

### No beats detected despite good music

**Problem**: Beat detection not triggering on good beats.

**Solution**:
1. Verify `myResizeMethod` is not 0 (check music selection)
2. Check `myBeatDetectionEnabled` is YES
3. Reduce `myBeatThresholdMultiplier` (increase sensitivity)
4. Verify music has clear beats (some ambient music won't work)
5. Check debug display to see power levels

### Too many false beats in quiet passages

**Problem**: Detecting noise as beats.

**Solution**:
1. Increase `myBeatThresholdMultiplier` (decrease sensitivity)
2. In mic mode, increase threshold to 1.5+
3. Check that `BEAT_POWER_MIN_THRESHOLD` is appropriate (0.15 default)

### Particles spawning too frequently

**Problem**: Excessive particle effects.

**Solution**:
1. Increase `BEAT_COOLDOWN_DEFAULT` (fewer beats per minute)
2. Increase sensitivity multiplier (fewer beat detections)
3. Note: Max 3 bursts per beat, cannot exceed

### Haptics not working

**Problem**: No vibration on beats.

**Solution**:
1. Check `myVibrateFlag` is YES
2. Verify device is iPhone 7 or later
3. Check system vibration is enabled (Settings > Sound & Haptics)
4. Verify beat detection is working (check debug display)

## Integration with Game Features

### Photo Drop Timing
Beat detection does NOT affect photo dropping:
- Photos still drop on timer (myDropPicturesTimer)
- Beat detection only enhances existing sprites
- Particles spawn at beat moments

### Memory Register
Beat detection does NOT affect memory functions:
- Memory store/recall unaffected
- Beat detection transparent to calculation functions

### Audio Display
Beat detection info displayed in debug display:
- Separate UI from audio waveform display
- Can be toggled independently
- Shows beat intensity and threshold

## Advanced Configuration

### Customizing Intensity Thresholds
Edit these values in the `myDetectBeats` method:

```objc
// Current thresholds (in myDetectBeats)
if (myPowerDifference > 1.2f) {
    // Heavy: Change 1.2f to different value
    
} else if (myPowerDifference > 0.7f) {
    // Medium: Change 0.7f to different value
    
} else if (myPowerDifference > 0.35f) {
    // Light: Change 0.35f to different value
```

Lower values = more sensitive, higher values = less sensitive.

### Customizing Cooldown
```objc
// In myOnBeatDetected, change:
self.myBeatCooldown = BEAT_COOLDOWN_DEFAULT;
// or use custom value:
self.myBeatCooldown = 0.2f;  // Slower (300 BPM max)
```

### Customizing Scaling Factors
```objc
// In myOnBeatDetected, change scale multipliers:
case BEAT_INTENSITY_LIGHT:
    beatScale = 1.3f;  // Change to 1.2f or 1.5f
    break;
case BEAT_INTENSITY_MEDIUM:
    beatScale = 1.8f;  // Change to 1.5f or 2.0f
    break;
case BEAT_INTENSITY_HEAVY:
    beatScale = 2.5f;  // Change to 2.0f or 3.0f
    break;
```

