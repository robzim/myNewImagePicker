//
//  GameScene.h
//  eyeCandy
//

//  Copyright (c) 2014 Robert Zimmelman. All rights reserved.
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

//@import CoreMotion;

@interface GameScene : SKScene<SKPhysicsContactDelegate,AVAudioPlayerDelegate,UIGestureRecognizerDelegate,PHPhotoLibraryChangeObserver>
-(void)myStartDropPicturesTimer;
-(void)myStartTheGame;
-(void)myPlayPause;
-(void)myRestartTheMusic;
-(double)myDbToAmp: (double)inDb;
-(void)myDropPictureNumber: (int) thePictureNumber;

-(void)myAssignImage1;
-(void)myAssignImage2;
-(void)myAssignImage3;
-(void)myAssignImage4;
-(void)myAssignImage5;

@property float mySceneImageSize;
@property BOOL myVibrateFlag;
@property int myImage1Flag;
@property int myImage2Flag;
@property int myImage3Flag;
@property int myImage4Flag;
@property int myImage5Flag;

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


@property UIImage  *mySpriteImage1;
@property UIImage  *mySpriteImage2;
@property UIImage  *mySpriteImage3;
@property UIImage  *mySpriteImage4;
@property UIImage  *mySpriteImage5;

//@property SKSpriteNode  *myImageSprite1;
//@property SKSpriteNode  *myImageSprite2;
//@property SKSpriteNode  *myImageSprite3;
//@property SKSpriteNode  *myImageSprite4;
//@property SKSpriteNode  *myImageSprite5;
@property SKSpriteNode  *myImageSprite1;
@property SKSpriteNode  *myImageSprite2;
@property SKSpriteNode  *myImageSprite3;
@property SKSpriteNode  *myImageSprite4;
@property SKSpriteNode  *myImageSprite5;


@property PHFetchResult *myPhotos;
@property PHImageManager *myImageManager;


@property BOOL myAllRandomImagesFlag;
@property long myOSVersion;

@property SKSpriteNode *myBG;


@property SKAction *myImageSpriteAction;
//@property int myScore;
//@property uint64_t myHighScore;

//@property myCustomEmitterNode *mySnowParticle;
//@property myCustomEmitterNode *myCloudParticle;

@property float myTimeSinceLastFrame;
@property float myLastTimeSample;
@property SKNode *firstNode;
@property SKNode *secondNode;
@property AVAudioPlayer *myAudioPlayer;

@property NSNumber *myTestNumber;
@property int myTestInt;

@property NSURL *myMusicURL;

@property NSMutableArray *myPicturesArray;

//@property AVAudioPlayer *myMusicPlayer;
@end
