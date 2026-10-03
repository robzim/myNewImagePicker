//
//  TVGameScene.h
//  TV Photo Chaos
//
//  tvOS version of GameScene - adapted for Apple TV
//  No microphone support, Siri Remote input
//
//  Created by Robert Zimmelman.
//  Copyright (c) 2024 Robert Zimmelman. All rights reserved.
//

#import <sys/utsname.h>
#import "myCustomEmitterNode.h"
#import "myCustomShapeNode.h"
#import "myCustomSpriteNode.h"

@import SpriteKit;
@import UIKit;
@import AVFoundation;
@import Photos;
@import GameplayKit;
@import CoreImage;

@interface TVGameScene : SKScene<SKPhysicsContactDelegate, AVAudioPlayerDelegate, UIGestureRecognizerDelegate, PHPhotoLibraryChangeObserver>

// Core methods
-(void)myStartDropPicturesTimer;
-(void)myStartTheGame;
-(void)myPlayPause;
-(void)myRestartTheMusic;
-(double)myDbToAmp:(double)inDb;
-(void)myDropPictureNumber:(int)thePictureNumber;

// Image assignment
-(void)myAssignImage1;
-(void)myAssignImage2;
-(void)myAssignImage3;
-(void)myAssignImage4;
-(void)myAssignImage5;

// Magical visual effects
-(void)createSparkleEffectAtPosition:(CGPoint)position withColor:(SKColor *)color;
-(void)createMagicBurstAtPosition:(CGPoint)position;
-(void)createConfettiBurstAtPosition:(CGPoint)position;
-(void)celebrationEffect;
-(void)addGlowToSprite:(SKSpriteNode *)sprite withColor:(SKColor *)color;
-(void)createRainbowTrailForSprite:(SKSpriteNode *)sprite;
-(SKColor *)randomMagicColor;

// Properties
@property float mySceneImageSize;
@property int myImage1Flag;
@property int myImage2Flag;
@property int myImage3Flag;
@property int myImage4Flag;
@property int myImage5Flag;

// Resize method: 0=none, 1=instant, 2=pulse (music only - no mic modes on tvOS)
@property int myResizeMethod;
@property NSProcessInfo *myProcessInfo;
@property NSTimer *myDropPicturesTimer;
@property SKLabelNode *myAudioLevelLabel;
@property float myInstantPower;
@property float myAveragePower;
@property (weak, nonatomic) SKTexture *myTexture;

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
@property long myOSVersion;

@property SKSpriteNode *myBG;
@property SKAction *myImageSpriteAction;

@property float myTimeSinceLastFrame;
@property float myLastTimeSample;
@property SKNode *firstNode;
@property SKNode *secondNode;
@property AVAudioPlayer *myAudioPlayer;

@property NSNumber *myTestNumber;
@property int myTestInt;

@property NSURL *myMusicURL;
@property NSString *mySongTitle;
@property NSString *mySongArtist;

@property NSMutableArray *myPicturesArray;

// Audio display UI
@property SKNode *myAudioDisplayNode;
-(void)myUpdateAudioDisplay;
-(void)mySetupAudioDisplay;

@end
