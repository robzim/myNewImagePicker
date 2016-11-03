//
//  GameScene.h
//  eyeCandy
//

//  Copyright (c) 2014 Robert Zimmelman. All rights reserved.
//
#import <sys/utsname.h>

@import SpriteKit;
@import UIKit;
@import AVFoundation;
//@import CoreMotion;

@interface GameScene : SKScene<SKPhysicsContactDelegate>

@property UIImage  *mySpriteImage1;
@property UIImage  *mySpriteImage2;
@property UIImage  *mySpriteImage3;
@property UIImage  *mySpriteImage4;
@property UIImage  *mySpriteImage5;

@property SKSpriteNode  *myImageSprite1;
@property SKSpriteNode  *myImageSprite2;
@property SKSpriteNode  *myImageSprite3;
@property SKSpriteNode  *myImageSprite4;
@property SKSpriteNode  *myImageSprite5;


@property SKSpriteNode *myBG;

@property NSOperationQueue *myQueue;

@property SKAction *myImageSpriteAction;
@property int myScore;
@property uint64_t myHighScore;

@property SKEmitterNode *mySnowParticle;

@end
