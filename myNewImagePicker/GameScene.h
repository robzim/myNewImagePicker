//
//  GameScene.h
//  eyeCandy
//

//  Copyright (c) 2014 Robert Zimmelman. All rights reserved.
//

@import SpriteKit;
@import UIKit;
@import AVFoundation;


@interface GameScene : SKScene<SKPhysicsContactDelegate>

@property UIImage  *mySpriteImage1;
@property UIImage  *mySpriteImage2;
@property UIImage  *mySpriteImage3;
@property UIImage  *mySpriteImage4;
@property UIImage  *mySpriteImage5;

@property (nonatomic, retain) AVAudioPlayer *player1;
@property (nonatomic, retain) AVAudioPlayer *player2;



@end
