//
//  TVGameScene.h
//  PhotoDancePartyTV
//
//  Created by Robert Zimmelman.
//  Copyright © 2024 Robert Zimmelman. All rights reserved.
//

#import "myCustomEmitterNode.h"
#import "myCustomShapeNode.h"
#import "myCustomSpriteNode.h"

@import SpriteKit;
@import UIKit;
@import AVFoundation;
@import Photos;
@import GameplayKit;
@import CoreImage;
@import MediaPlayer;

@interface TVGameScene : SKScene <SKPhysicsContactDelegate, AVAudioPlayerDelegate, PHPhotoLibraryChangeObserver>

- (void)myStartDropPicturesTimer;
- (void)myStartTheGame;
- (void)myPlayPause;
- (void)myStartTheMusic;
- (void)myRestartTheMusic;
- (double)myDbToAmp:(double)inDb;
- (void)myDropPictureNumber:(int)thePictureNumber;

- (void)myAssignImage1;
- (void)myAssignImage2;
- (void)myAssignImage3;
- (void)myAssignImage4;
- (void)myAssignImage5;

// Visual effects
- (void)createSparkleEffectAtPosition:(CGPoint)position withColor:(SKColor *)color;
- (void)createMagicBurstAtPosition:(CGPoint)position;
- (void)createConfettiBurstAtPosition:(CGPoint)position;
- (void)celebrationEffect;
- (void)addGlowToSprite:(SKSpriteNode *)sprite withColor:(SKColor *)color;
- (void)createRainbowTrailForSprite:(SKSpriteNode *)sprite;
- (SKColor *)randomMagicColor;

// Audio display
- (void)mySetupAudioDisplay;
- (void)myUpdateAudioDisplay;

// Debug display for resize values
@property SKNode *myDebugDisplayNode;
@property BOOL myDebugDisplayVisible;
@property float myCurrentScaleTo;
- (void)mySetupDebugDisplay;
- (void)myUpdateDebugDisplay;
- (void)myToggleDebugDisplay;

@property float mySceneImageSize;
@property BOOL myVibrateFlag;
@property int myImage1Flag;
@property int myImage2Flag;
@property int myImage3Flag;
@property int myImage4Flag;
@property int myImage5Flag;

@property int myResizeMethod;
@property NSTimer *myDropPicturesTimer;
@property SKLabelNode *myAudioLevelLabel;
@property float myInstantPower;
@property float myAveragePower;

@property (weak, nonatomic) SKTexture *myTexture1;
@property (weak, nonatomic) SKTexture *myTexture2;
@property (weak, nonatomic) SKTexture *myTexture3;
@property (weak, nonatomic) SKTexture *myTexture4;
@property (weak, nonatomic) SKTexture *myTexture5;

@property UIImage *mySpriteImage1;
@property UIImage *mySpriteImage2;
@property UIImage *mySpriteImage3;
@property UIImage *mySpriteImage4;
@property UIImage *mySpriteImage5;

@property SKSpriteNode *myImageSprite1;
@property SKSpriteNode *myImageSprite2;
@property SKSpriteNode *myImageSprite3;
@property SKSpriteNode *myImageSprite4;
@property SKSpriteNode *myImageSprite5;

@property PHFetchResult *myPhotos;
@property PHImageManager *myImageManager;

@property BOOL myAllRandomImagesFlag;

@property SKSpriteNode *myBG;
@property SKAction *myImageSpriteAction;

@property float myTimeSinceLastFrame;
@property float myLastTimeSample;
@property SKNode *firstNode;
@property SKNode *secondNode;
@property AVAudioPlayer *myAudioPlayer;

@property NSURL *myMusicURL;
@property NSString *myMusicStoreID;
@property NSString *mySongTitle;
@property NSString *mySongArtist;
@property MPMusicPlayerController *mySystemMusicPlayer;
@property BOOL myUsingAppleMusic;
@property BOOL myIsUserLibrarySong;

@property NSMutableArray *myPicturesArray;
@property SKNode *myAudioDisplayNode;

// BPM-based procedural beat generation (Mode 3)
@property float myBaseBPM;
@property NSTimeInterval myLastBeatTime;
@property float myBeatInterval;
@property int myBeatCount;
@property float myBeatVariance;
@property NSTimeInterval myCurrentSceneTime;

@end
