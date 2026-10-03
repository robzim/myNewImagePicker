# Photo Dance Party - Music Resizing System Deep Dive

## Overview

Both the iOS and tvOS versions of Photo Dance Party feature a sophisticated **music-reactive resizing system** that makes sprites and particles pulse and bounce in sync with the music's audio levels. This document provides a detailed breakdown of how the system works.

---

## High-Level Architecture

### Data Flow

```
Audio Player (AVAudioPlayer)
        ↓
    Update Meters
        ↓
Calculate Power Values (instant, average, difference)
        ↓
Determine Scale Factor (based on myResizeMethod)
        ↓
Resize Sprites/Particles
        ↓
Visual Feedback (scale animations)
```

### Key Properties

All values stored in the scene:
- **`myInstantPower`** - Current audio power level (dB)
- **`myAveragePower`** - Average audio power level (dB)
- **`myLastInstantPower`** - Previous frame's instant power (for delta calculation)
- **`myPowerDifference`** - Absolute difference between current and last instant power
- **`myResizeMethod`** - Integer flag controlling which resizing mode is active
- **`myVibrateFlag`** - iOS only: Whether haptic feedback is enabled

---

## Resize Methods

### iOS Version (GameScene.m)

The iOS app supports **4 resize methods**:

| Method | Name | Formula | Input Source | Use Case |
|--------|------|---------|--------------|----------|
| 0 | No Resize | N/A | N/A | Disabled |
| 1 | Music Instant | `DbToAmp(instantPower)` | Audio Player | Responsive to immediate volume spikes |
| 2 | Music Pulse | `abs(powerDifference / 2.0)` | Audio Player | Music beat detection |
| 3 | Mic Instant | `DbToAmp(instantPower) * 1.5` | Microphone | Real-time mic input |
| 4 | Mic Pulse | `abs(powerDifference / 1.5)` | Microphone | Mic beat detection |

**Key iOS Logic:**
```objective-c
if (myStartedInMicMode) {
    // Mic mode - only use mic input, never fall back to audio
    [myMicRecorder updateMeters];
    myInstantPower = [myMicRecorder peakPowerForChannel:0];
} else {
    // Music mode
    [myAudioPlayer updateMeters];
    for (int i = 0; i < myAudioPlayer.numberOfChannels; i++) {
        myInstantPower += [myAudioPlayer peakPowerForChannel:i];
    }
    myInstantPower = myInstantPower / myAudioPlayer.numberOfChannels;
}
```

### tvOS Version (TVGameScene.m)

The tvOS version has **simplified resizing** (no microphone support):

| Method | Name | Formula | Input Source |
|--------|------|---------|--------------|
| 0 | No Resize | N/A | N/A |
| 1 | Music Instant | `DbToAmp(instantPower)` | Audio Player |
| 2 | Music Pulse | `abs(powerDifference / 2.0)` | Audio Player |

**tvOS Logic:**
```objective-c
// tvOS: Music mode only (no mic support)
if (myResizeMethod == 0) {
    return;  // No resize mode
}

if (!myAudioPlayer || !myAudioPlayer.isPlaying) {
    return;
}

[myAudioPlayer updateMeters];
for (int i = 0; i < myAudioPlayer.numberOfChannels; i++) {
    myInstantPower += [myAudioPlayer peakPowerForChannel:i];
    myAveragePower += [myAudioPlayer averagePowerForChannel:i];
}
myInstantPower = myInstantPower / myAudioPlayer.numberOfChannels;
```

---

## Power Calculation & dB to Amplitude Conversion

### dB to Amplitude Function

Both versions use the same conversion formula:

```objective-c
-(double)myDbToAmp:(double)inDb {
    double power = pow(10., 0.05 * inDb);
    return power;
}
```

**Example conversions:**
- -80 dB (silence) → ~0.0001 amplitude
- -40 dB (soft) → 0.01 amplitude
- -20 dB (moderate) → 0.1 amplitude
- 0 dB (loud) → 1.0 amplitude
- +10 dB (very loud) → 3.16 amplitude

### Power Difference Calculation

```objective-c
myPowerDifference = fabs(myInstantPower - myLastInstantPower);
myLastInstantPower = myInstantPower;
```

This captures **audio transients** (sudden changes in volume), making it excellent for beat detection.

### Threshold Filtering (iOS Only)

```objective-c
float minThreshold = myStartedInMicMode ? 1.0 : 0.0;

if (myPowerDifference > minThreshold) {
    [self myResizeTheParticlesToSize:myScaleTo];
    [self myResizePhotosAndSegmentsToSize:myScaleTo];
}
```

Microphone mode uses a **threshold of 1.0** to filter ambient noise; music mode has **no threshold**.

---

## Sprite Resizing

### iOS Resizing (OS Version Specific)

The iOS version checks OS version to use different animation APIs:

```objective-c
-(void)myResizePhotosAndSegmentsToSize:(float)theScaleTo {
    myScaleTo = theScaleTo;

    [self enumerateChildNodesWithName:@"sprite" usingBlock:^(SKNode * _Nonnull node, BOOL * _Nonnull stop) {
        if (self->myOSVersion >= 10.0) {
            // Modern API (iOS 10+)
            [node runAction:[SKAction sequence:@[
                [SKAction scaleTo:myScaleTo * myPhotoScaleMultiplier duration:0.0],
                [SKAction scaleTo:1.0 duration:0.0],
            ]]];
        } else {
            // Legacy API (iOS 9 and earlier)
            [node runAction:[SKAction sequence:@[
                [SKAction group:@[
                    [SKAction scaleXTo:myScaleTo * myPhotoScaleMultiplier duration:0.0],
                    [SKAction scaleYTo:myScaleTo * myPhotoScaleMultiplier duration:0.0],
                ]],
                [SKAction group:@[
                    [SKAction scaleXTo:1.0 duration:0.0],
                    [SKAction scaleYTo:1.0 duration:0.0],
                ]],
            ]]];
        }
    }];
}
```

### tvOS Resizing (Simplified)

tvOS doesn't need OS version checking—simpler code:

```objective-c
-(void)myResizePhotosAndSegmentsToSize:(float)theScaleTo {
    myScaleTo = theScaleTo;

    [self enumerateChildNodesWithName:@"sprite" usingBlock:^(SKNode * _Nonnull node, BOOL * _Nonnull stop) {
        [node runAction:[SKAction sequence:@[
            [SKAction scaleTo:myScaleTo * myPhotoScaleMultiplier duration:0.0],
            [SKAction scaleTo:1.0 duration:0.0],
        ]]];
    }];
}
```

### Animation Behavior

Both versions perform the same visual effect:

1. **Instant scale up**: `scaleTo:myScaleTo * myPhotoScaleMultiplier`
   - `myPhotoScaleMultiplier = 1.5` (defined globally)
   - So if audio is loud (myScaleTo = 0.5), sprite scales to **0.75x** (0.5 × 1.5)

2. **Instant scale back**: `scaleTo:1.0`
   - Duration 0.0 for immediate response

3. **Result**: Sprites pulse instantly with audio changes, creating a bouncy effect

### Scale Multipliers (Global Constants)

```objective-c
float myScaleTo = 1.0;
float myPhotoScaleMultiplier = 1.5;      // Photos
float mySegmentScaleMultiplier = 1.2;    // Segments
float myParticleSystemScaleMultiplier = 1.2;  // Particles
float myTriangleScaleMultiplier = 1.5;   // Triangles
float myCircleScaleMultiplier = 0.75;    // Circles
```

Different multipliers create varied visual effects for different element types.

---

## Particle System Resizing

### tvOS Particle Resizing

```objective-c
-(void)myResizeTheParticlesToSize:(float)theScleToSize {
    int myRandomParticleSystemResizeGate = arc4random() % 5;
    float localScaleTo = theScleToSize;

    if (myRandomParticleSystemResizeGate == 0) {  // 20% of the time
        [self enumerateChildNodesWithName:@"particle system" usingBlock:^(SKNode * _Nonnull node, BOOL * _Nonnull stop) {
            // Three different resize modes based on myResizeValue

            if ([(myCustomEmitterNode *)node myResizeValue] == 0) {
                // Mode 0: Resize the entire emitter node
                float myNodeXScale = node.xScale;
                float myNodeYScale = node.yScale;

                [node runAction:[SKAction sequence:@[
                    [SKAction scaleTo:localScaleTo * myParticleSystemScaleMultiplier duration:0.0],
                    [SKAction scaleTo:myNodeXScale duration:0.0],
                ]]];

            } else if ([(myCustomEmitterNode *)node myResizeValue] == 1) {
                // Mode 1: Resize individual particles
                CGSize myParticleSize = [(SKEmitterNode *)node particleSize];
                [node runAction:[SKAction sequence:@[
                    [SKAction runBlock:^{
                        [(SKEmitterNode *)node setParticleSize:
                            CGSizeMake(localScaleTo * myParticleSystemScaleMultiplier,
                                     localScaleTo * myParticleSystemScaleMultiplier)];
                    }],
                    [SKAction runBlock:^{
                        [(SKEmitterNode *)node setParticleSize:myParticleSize];
                    }],
                ]]];

            } else if ([(myCustomEmitterNode *)node myResizeValue] == 2) {
                // Mode 2: Fade in/out effect
                [node runAction:[SKAction sequence:@[
                    [SKAction fadeOutWithDuration:0.0],
                    [SKAction fadeInWithDuration:0.0],
                ]]];
            }
        }];
    }
}
```

### Key Particle Behaviors

1. **Probabilistic Resizing**: Only resizes 20% of the time (`arc4random() % 5 == 0`)
   - Prevents visual clutter and reduces performance load

2. **Three Resize Modes** (set when particle system is created):
   - **Mode 0**: Scale the entire emitter node (affects all particles)
   - **Mode 1**: Change individual particle size (more granular control)
   - **Mode 2**: Fade in/out (visual shimmer effect)

3. **Emitter Node Property**: `myResizeValue` custom property on `myCustomEmitterNode`
   - Set during particle system creation: `[myPP setResizeValue:theValue]`
   - Queried during resize: `[(myCustomEmitterNode *)node myResizeValue]`

### iOS Particle Resizing (Similar Logic)

iOS version has identical logic but with OS version checking for pre-iOS 10 compatibility.

---

## Update Loop Integration

### Called From update:

Both versions call resizing from the main game loop:

```objective-c
-(void)update:(NSTimeInterval)currentTime {
    // ... other update logic ...

    if (myResizeMethod > 0) {
        [self myResizeSpritesToMusic];
    }

    // ... update audio display ...
}
```

This runs **every frame** (typically 60 FPS), allowing smooth real-time response to audio.

---

## Custom Node Classes for Resizing

### myCustomSpriteNode

```objective-c
// myCustomSpriteNode.h
@interface myCustomSpriteNode : SKSpriteNode
@property int myResizeValue;
@end
```

Extends `SKSpriteNode` with a single property to control particle resize behavior.

### myCustomEmitterNode

```objective-c
// myCustomEmitterNode.m
@implementation myCustomEmitterNode {
    int myEmitterNodeResizeValue;
}

-(void)setResizeValue:(int)theValue {
    myEmitterNodeResizeValue = theValue;
}

-(int)myResizeValue {
    return myEmitterNodeResizeValue;
}

@end
```

Extends `SKEmitterNode` with getter/setter for resize mode.

### myCustomShapeNode

Similar pattern for shape nodes, with `myZValue` for layering control.

---

## iOS-Specific: Haptic Feedback

The iOS version adds haptic feedback synchronized with resizing:

```objective-c
-(void)myBumpNewPhoneWithMusic {
    if (myPowerDifference > 0.7) {
        if ([deviceType isEqualToString:@"iPhone9"]) {  // iPhone 7+
            [myHeavyImpactFeedbackGenerator impactOccurred];
        }
    }
    else if (myPowerDifference > 0.5) {
        [myMediumImpactFeedbackGenerator impactOccurred];
    }
    else if (myPowerDifference > 0.25) {
        [myLightImpactFeedbackGenerator impactOccurred];
    }
}
```

Called from `myResizeSpritesToMusic` when `myVibrateFlag == YES`:
- Power difference > 0.7 → Heavy vibration
- Power difference > 0.5 → Medium vibration
- Power difference > 0.25 → Light vibration

This creates a **tactile connection** between audio and physics on supported devices.

---

## Performance Considerations

### Throttling Mechanisms

1. **Probabilistic Particle Resizing**
   - Only 20% of particle systems resize per frame
   - Prevents excessive state changes

2. **Frame Time Monitoring**
   ```objective-c
   if (myTimeSinceLastFrame > myScreenRefreshTimeToDump) {
       // Clear all nodes if frame time > 0.35s
       [self enumerateChildNodesWithName:@"sprite" usingBlock:^...];
   }
   ```

3. **Node Count Limiting**
   ```objective-c
   if (self.children.count > myAcceptableNodeCount) {
       // Remove oldest sprites/particles
   }
   ```

### Optimization Tips

- Duration 0.0 on actions prevents queuing
- Minimal number of enumerations per frame
- Reuse of scale multiplier constants

---

## Visual Flow Examples

### Example 1: Music Pulse Mode (Method 2)

```
Audio: [loud kick] [quiet] [loud kick]
            ↓          ↓         ↓
Power:    -20dB    -80dB     -20dB
Diff:     60dB     60dB      60dB
          ↓        ↓         ↓
Scale:   30.0     30.0      30.0 (60/2)
          ↓        ↓         ↓
Sprite:  ↑ 45x    ↓ 1x      ↑ 45x  (30 * 1.5)
         (bounces)          (bounces)
```

### Example 2: Music Instant Mode (Method 1)

```
Audio: [crescendo] [peak] [decay]
           ↓       ↓        ↓
Power:   -40dB   -20dB   -60dB
         ↓        ↓        ↓
Scale:  0.01    0.1     0.001 (DbToAmp result)
         ↓        ↓        ↓
Sprite: 1.5x    15x      1.5x
        (follows waveform)
```

---

## Debugging Tips

### Enable Logging

The iOS version has built-in logging (every 60 frames):
```objective-c
NSLog(@">>> MIC POWER: instant=%f, avg=%f, diff=%f, audioPlaying=%d",
      myInstantPower, myAveragePower, fabs(myInstantPower - myLastInstantPower),
      myAudioPlayer.isPlaying);
```

### Key Values to Monitor

| Value | Range | Meaning |
|-------|-------|---------|
| `myInstantPower` | -80 to +10 dB | Current audio level |
| `myPowerDifference` | 0 to ~60 dB | Change in audio (beat detector) |
| `myScaleTo` | 0.0 to 3.0+ | Scale multiplier applied |
| `myResizeMethod` | 0-4 | Active resize mode |

### Common Issues

1. **No resizing**: Check that `myResizeMethod > 0` and audio is playing
2. **Jittery sprites**: Might be threshold too low—increase `minThreshold`
3. **Performance drops**: Reduce `myAcceptableNodeCount` or check for unremoved nodes

---

## Summary

The resizing system elegantly synchronizes visual effects with audio by:

1. **Measuring audio** via AVAudioPlayer metering
2. **Computing power differences** to detect beats
3. **Calculating scale factors** based on selected resize method
4. **Applying instant animations** to sprites and particles
5. **Running every frame** for responsive real-time feedback

The tvOS version simplifies this by removing microphone support, while the iOS version adds haptic feedback for a more immersive experience.
