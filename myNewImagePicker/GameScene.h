//
//  GameScene.h
//  eyeCandy
//

//  Copyright (c) 2014 Robert Zimmelman. All rights reserved.
//
#import <sys/utsname.h>
#import "myCustomSpriteNode.h"
@import SpriteKit;
@import UIKit;
@import AVFoundation;

//@import CoreMotion;

@interface GameScene : SKScene<SKPhysicsContactDelegate,AVAudioPlayerDelegate>
-(void)myStartDropPicturesTimer;
-(void)myStartTheGame;

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
@property myCustomSpriteNode  *myImageSprite1;
@property myCustomSpriteNode  *myImageSprite2;
@property myCustomSpriteNode  *myImageSprite3;
@property myCustomSpriteNode  *myImageSprite4;
@property myCustomSpriteNode  *myImageSprite5;


@property myCustomSpriteNode *myBG;

@property NSOperationQueue *myOperationQueue;

@property SKAction *myImageSpriteAction;
@property int myScore;
@property uint64_t myHighScore;

@property SKEmitterNode *mySnowParticle;

@property float myTimeSinceLastFrame;
@property float myLastTimeSample;
@property SKNode *firstNode;
@property SKNode *secondNode;
@property AVAudioPlayer *myAudioPlayer;

@property NSNumber *myTestNumber;
@property int myTestInt;

@property NSURL *myMusicURL;
//@property AVAudioPlayer *myMusicPlayer;
@end
