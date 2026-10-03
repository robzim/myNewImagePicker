# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.
## IMPORTANT INSTRUCTIONS
- NEVER OFFER TO COMMIT TO GIT.  THE USER WILL HANDLE GIT
- NEVER USE GIT TO PUSH
- NEVER ADD COMMENTS TO GIT UNLESS REQUESTED

## Project Overview

**Photo Dance Party!** is an iOS app that creates an interactive physics-based photo simulation with music. Users select up to 5 photos from their library (or camera), choose a song, and watch their photos bounce and animate in response to the music's audio levels.

- **Bundle ID**: org.zimmelman.myNewImagePicker
- **Target iOS Version**: iOS 12.0+
- **Language**: Objective-C
- **Current Version**: 4.7 (Build 25)
- **App Display Name**: Photo Dance Party!

## Build Commands

```bash
# Build the project
xcodebuild -project PhotoDanceParty.xcodeproj -scheme myNewImagePicker -configuration Debug build

# Build for release
xcodebuild -project PhotoDanceParty.xcodeproj -scheme myNewImagePicker -configuration Release build

# Clean build
xcodebuild -project PhotoDanceParty.xcodeproj -scheme myNewImagePicker clean
```

## Architecture

### Core Structure

This is a **SpriteKit-based iOS app** using UIKit storyboards for the setup interface. The app has two main phases:

1. **Setup Phase** (`ViewController`) - User selects photos and music
2. **Game Phase** (`GameScene`) - Physics simulation with music-reactive visuals

### Key Components

**ViewController.m** (~800 lines) - Setup screen controller:
- Photo library access via `PHPhotoLibrary` and `PHImageManager`
- Camera/library image picker integration (`UIImagePickerController`)
- Music selection via `MPMediaPickerController`
- Launches the `GameScene` when user presses Go/Random buttons
- Passes selected images and music URL to the scene

**GameScene.m** (~1200 lines) - Main SpriteKit game scene:
- Physics simulation with edge-loop boundary
- Periodic photo dropping via `NSTimer` (`myDropPicturesTimer`)
- Music playback with `AVAudioPlayer` and audio metering
- Music-reactive sprite resizing based on audio power levels
- Haptic feedback integration for iPhone 7+ (`UIImpactFeedbackGenerator`)
- Photo library change observation (`PHPhotoLibraryChangeObserver`)

### Custom Node Classes

Custom SpriteKit node subclasses with `myResizeValue` property for music-reactive behavior:
- `myCustomSpriteNode` - extends `SKSpriteNode`
- `myCustomEmitterNode` - extends `SKEmitterNode`
- `myCustomShapeNode` - extends `SKShapeNode` (also has `myZValue`)

### Communication Pattern

The app uses `NSNotificationCenter` extensively for communication between ViewController and GameScene:
- `quitnotifictaion` - Triggers menu display
- `musicselected` - Signals music selection complete
- `playpause`, `restartmusic` - Music control
- `assignimage1-5` - Photo reassignment

### Music-Reactive System

Three resize methods controlled by `myResizeMethod`:
- `0` - No resizing
- `1` - Size based on instant audio power (`peakPowerForChannel:`)
- `2` - Size based on power change/difference (default)

Audio metering happens in `update:` via `myResizeSpritesToMusic` which calls `AVAudioPlayer.updateMeters`.

### Physics Configuration

- Gravity: `(0.0, -9.5)`
- Edge loop boundary from scene frame
- Sprites have configurable mass, restitution, damping
- Contact detection via `contactTestBitMask = 0x09`

## Important Constraints

### Performance Management

The scene monitors frame rate via `myTimeSinceLastFrame` in `update:`:
- If frame time exceeds `myScreenRefreshTimeToDump` (0.35s), clears sprites and particle systems
- Maximum node count limited by `myAcceptableNodeCount` (25)
- Older iOS versions (< 10.0) get longer intervals between photo drops

### Photo Library Access

- Requires `NSPhotoLibraryUsageDescription` permission
- Minimum 5 photos required in library for random photo mode
- Photos fetched sorted by `creationDate` ascending
- Target image size: 160x160 for scene, width/4 for preview

### TV Photo Chaos Target

The `TV Photo Chaos/` directory contains a tvOS variant of the app with simplified AppDelegate. The main target is the iOS `myNewImagePicker`.

## File Organization

```
LatestVersionPhoto Dance Party/
├── PhotoDanceParty.xcodeproj/     # Xcode project
├── myNewImagePicker/              # Main iOS app source
│   ├── AppDelegate.m/h            # App lifecycle
│   ├── SceneDelegate.m/h          # iOS 13+ scene lifecycle
│   ├── ViewController.m/h         # Setup screen
│   ├── GameScene.m/h              # SpriteKit physics scene
│   ├── myCustomSpriteNode.m/h     # Custom sprite node
│   ├── myCustomEmitterNode.m/h    # Custom particle emitter
│   ├── myCustomShapeNode.m/h      # Custom shape node
│   ├── Main.storyboard            # UI layout
│   ├── *.sks                      # SpriteKit scene/particle files
│   └── Assets.xcassets/           # App icons and images
├── TV Photo Chaos/                # tvOS target
└── myNewImagePickerTests/         # Unit tests
```
