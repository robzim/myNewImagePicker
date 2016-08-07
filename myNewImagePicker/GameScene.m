//
//  GameScene.m
//  eyeCandy
//
//  Created by Robert Zimmelman on 11/10/14.
//  Copyright (c) 2014 Robert Zimmelman. All rights reserved.
//
#import "GameScene.h"

int myButtonWidth = 30;
int myCounter = 0;
int myFiveSpriteLoops = 1;
int myMassMult = 1;
int myYOffset = 30;
float myImageSpriteDamping = 2.0;
float myColorSpriteDamping = 1.1;
float myCircleSpriteDamping = 1.1;

float myRestitution = 0.5;

vector_float2 mySourceVector;
vector_float2 myDestVector;


float myImageSpriteMass = 2.0;
float myImageSpriteRestitution = 0.5;
int myImageSpriteSize = 20;
float myPhotoSpriteScale = 1.0;


int myImageSpriteNumber = 1;

//

int myColorSpriteDefaultSize = 8;
int myColorSpriteLoops = 1;
float myColorSpriteRestitution = 0.5;


int myNumberOfLoopsForSquares = 20;

int myShape = 0;


//
int myCircleSpriteSize = 4;
float myCircleSpriteScale = 0.03;
float myCircleSpriteRestitution = 0.5;
int myCircleSpriteLoops = 3;


dispatch_queue_t myDispatchQueue;
dispatch_queue_t myColorQueue;



@implementation GameScene
@synthesize mySpriteImage1, mySpriteImage2, mySpriteImage3, mySpriteImage4, mySpriteImage5;
@synthesize myImageSprite1, myImageSprite2, myImageSprite3, myImageSprite4, myImageSprite5;

@synthesize myImageSpriteAction;
@synthesize myBG;
@synthesize myQueue;


-(void)update:(NSTimeInterval)currentTime{
    [self enumerateChildNodesWithName:@"photosprite" usingBlock:^(SKNode *node, BOOL *stop){
        if ((node.position.x <=0) || (node.position.x >= self.view.bounds.size.width ) )
        {
//            NSLog(@"removing photo node");
            [node removeFromParent];
        }
        if ((node.position.y <=0) || (node.position.y >= self.view.bounds.size.height ) )
        {
//            NSLog(@"removing photo node");
            [node removeFromParent];
        }
    }];
    [self enumerateChildNodesWithName:@"colorsprite" usingBlock:^(SKNode *node, BOOL *stop){
        if ((node.position.x <=0) || (node.position.x >= self.view.bounds.size.width ) ) {
            {
//                NSLog(@"removing colorsprite node");
                [node removeFromParent];
            }
            if ((node.position.y <=0) || (node.position.y >= self.view.bounds.size.height ) )
            {
//                NSLog(@"removing colorsprite node");
                [node removeFromParent];
            }
        }
    }];
    [self enumerateChildNodesWithName:@"circlesprite" usingBlock:^(SKNode *node, BOOL *stop){
        if ((node.position.x <=0) || (node.position.x >= self.view.bounds.size.width ) ) {
            {
//                NSLog(@"removing circlesprite node");
                [node removeFromParent];
            }
            if ((node.position.y <=0) || (node.position.y >= self.view.bounds.size.height ) )
            {
//                NSLog(@"removing circlesprite node");
                [node removeFromParent];
            }
        }
    }];
}





-(void)myKickPictures{
    long myTempX = 0;
    long myTempY = 0;
    myTempX = arc4random_uniform(9)-5l;
    myTempY = arc4random_uniform(9)-5l;
    
//    myTempY = ((arc4random()%5)-3)/10.0;
//    myTempX = ((arc4random()%5)-3)/10.0;
    NSLog(@"in myKickPictures, X = %ld, Y = %ld",myTempX,myTempY);
    [self enumerateChildNodesWithName:@"photosprite" usingBlock:^(SKNode *node, BOOL *stop){
        [node.physicsBody applyImpulse:CGVectorMake(myTempX,myTempY)];
    }];
}

-(void)myKickTextures{
    long myTempX = 0;
    long myTempY = 0;
    myTempX = arc4random_uniform(5)-3l;
    myTempY = arc4random_uniform(5)-3l;

//    myTempY = ((arc4random()%3)-2.0)/10.0;
//    myTempX = ((arc4random()%3)-2.0)/10.0;
    NSLog(@"in myKickTextures, X = %ld, Y = %ld",myTempX,myTempY);
    [self enumerateChildNodesWithName:@"circlesprite" usingBlock:^(SKNode *node, BOOL *stop){
        [node.physicsBody applyImpulse:CGVectorMake(myTempX,myTempY)];
    }];
}

-(void)myKickColors{
    long myTempX = 0;
    long myTempY = 0;
    myTempX = arc4random_uniform(3)-2l;
    myTempY = arc4random_uniform(3)-2l;

//    myTempY = ((arc4random()%3)-2.0)/10.0;
//    myTempX = ((arc4random()%3)-2.0)/10.0;
    NSLog(@"in myKickColors, X = %ld, Y = %ld",myTempX,myTempY);
    [self enumerateChildNodesWithName:@"colorsprite" usingBlock:^(SKNode *node, BOOL *stop){
        [node.physicsBody applyImpulse:CGVectorMake(myTempX,myTempY)];
    }];
}





-(void)didMoveToView:(SKView *)view {
    
    mySourceVector = vector2(2.0f, 2.0f);
    myDestVector = vector2(2.0f, 2.0f);
    
    
    
    NSTimer *myKickPicturesTimer;
    myKickPicturesTimer = [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(myKickPictures) userInfo:nil repeats:YES];
    
    
    NSTimer *myKickTexturesTimer;
    myKickTexturesTimer = [NSTimer scheduledTimerWithTimeInterval:3.0 target:self selector:@selector(myKickTextures) userInfo:nil repeats:YES];
    
    NSTimer *myKickColorsTimer;
    myKickColorsTimer = [NSTimer scheduledTimerWithTimeInterval:10.0 target:self selector:@selector(myKickColors) userInfo:nil repeats:YES];
    
    
    myImageSpriteAction =    [SKAction sequence:@[
                                                  [SKAction waitForDuration:60.0 withRange:15.0],
                                                  [SKAction removeFromParent],
                                                  ]];
    //
    // rz set up the labels describing the scene
    //
    myDispatchQueue = dispatch_queue_create("myqueue", DISPATCH_QUEUE_CONCURRENT);
    myColorQueue = dispatch_queue_create("mycolorqueue", DISPATCH_QUEUE_CONCURRENT);
    
    dispatch_async(myDispatchQueue, ^{
        
        [self makeMyIntroLabels];
        [self makeMyInstructionLabels];
        //
    });
    
    
    // rz set the physics world to go 1/2 speed
    //
    [self.physicsWorld setSpeed:0.5];
    //
    //
    //
    // rz set the gravity to be light
    //
    //
    [self.physicsWorld setGravity:CGVectorMake(0.0, -1.2)];
    
    [self setBackgroundColor:[UIColor blackColor]];
    
    //
    //
    //  contact 0x04 is the edge of the scene
    [self.physicsBody setContactTestBitMask:0x04];
    
    UISwipeGestureRecognizer *myUpSwipeGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(myUpSwipeAction)];
    [myUpSwipeGestureRecognizer setDirection:UISwipeGestureRecognizerDirectionUp];
    [self.view addGestureRecognizer:myUpSwipeGestureRecognizer];
    UISwipeGestureRecognizer *myDownSwipeGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(myDownSwipeAction)];
    [myDownSwipeGestureRecognizer setDirection:UISwipeGestureRecognizerDirectionDown];
    [self.view addGestureRecognizer:myDownSwipeGestureRecognizer];
    UISwipeGestureRecognizer *myLeftSwipeGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(myLeftSwipeAction)];
    [myLeftSwipeGestureRecognizer setDirection:UISwipeGestureRecognizerDirectionLeft];
    [self.view addGestureRecognizer:myLeftSwipeGestureRecognizer];
    UISwipeGestureRecognizer *myRightSwipeGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(myRightSwipeAction)];
    [myRightSwipeGestureRecognizer setDirection:UISwipeGestureRecognizerDirectionRight];
    [self.view addGestureRecognizer:myRightSwipeGestureRecognizer];
    
    //
    // rz single tap recognizer
    UITapGestureRecognizer *singleFingerTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapAction)];
    [singleFingerTapGesture setNumberOfTouchesRequired:1];
    [self.view addGestureRecognizer:singleFingerTapGesture];
    //
    
    //        UITapGestureRecognizer *doubleFingerTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTapAction)];
    //        [doubleFingerTapGesture setNumberOfTouchesRequired:2];
    //        [self.view addGestureRecognizer:doubleFingerTapGesture];
    //        //
    //        UITapGestureRecognizer *tripleFingerTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tripleTapAction)];
    //        [tripleFingerTapGesture setNumberOfTouchesRequired:3];
    //        [self.view addGestureRecognizer:tripleFingerTapGesture];
    
    
    //    });
    
    
    [self runAction:[SKAction repeatActionForever:[SKAction playSoundFileNamed:@"BG Music.m4a" waitForCompletion:YES]]];
    /* Setup your scene here */
    
    NSArray *myControlValues  = [[ NSArray alloc] initWithObjects:@"1",@"2",@"3", @"4", @"5", @"Circles", @"Squares", @"Quit", nil] ;
    
    UISegmentedControl *myControl = [[ UISegmentedControl alloc] initWithItems:myControlValues ];
    
    [myControl setFrame:CGRectMake(0, 0, self.view.bounds.size.width, 50)];
    
    //    [myControl setMomentary:YES];
    //    [myControl setHighlighted:YES];
    //    [myControl se]
    //
    //
    //   rz  WHY DOES THIS CONTROL HAVE DEAD SPACE AT THE VERY TOP OF THE SCREEN  ???
    //
    //
    //
    //    [myControl setFrame:CGRectMake(20, 20 , 290 , 50)];
    [myControl setWidth:(myButtonWidth) forSegmentAtIndex:0];
    [myControl setWidth:(myButtonWidth) forSegmentAtIndex:1];
    [myControl setWidth:(myButtonWidth) forSegmentAtIndex:2];
    [myControl setWidth:(myButtonWidth) forSegmentAtIndex:3];
    [myControl setWidth:(myButtonWidth) forSegmentAtIndex:4];
    
    [myControl addTarget:self action:@selector(mySwitchChanged:) forControlEvents:UIControlEventValueChanged ];
    [myControl setSelectedSegmentIndex:-1];
    [self.view addSubview:myControl];
    
    //
    //  set up the physics body so the sprites don't fall through the bottom
    //
    [self.view setIgnoresSiblingOrder:YES];
    self.physicsBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:self.frame];
    self.physicsWorld.contactDelegate = self;
    //
    
}

-(void)makeMyIntroLabels{
    SKLabelNode *myLabel = [SKLabelNode labelNodeWithFontNamed:@"Helvetica"];
    [myLabel setZPosition:20.0];
    myLabel.text = @"Try again with Your Pictures";
    SKLabelNode *my2ndLabel = [SKLabelNode labelNodeWithFontNamed:@"Helvetica"];
    my2ndLabel.text = @"From the Camera or Library!";
    myLabel.fontSize = my2ndLabel.fontSize = 12;
    myLabel.horizontalAlignmentMode = my2ndLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeCenter;
    [my2ndLabel setZPosition:20.0];
    myLabel.position = CGPointMake(CGRectGetMidX(self.frame),
                                   CGRectGetMidY(self.frame) + 100 );
    my2ndLabel.position = CGPointMake(CGRectGetMidX(self.frame),
                                      CGRectGetMidY(self.frame) + 80);
    //    [my2ndLabel runAction:[SKAction sequence:@[ [SKAction waitForDuration:5.0],
    //                                                [SKAction removeFromParent],
    //                                                ]]];
    //    NSLog(@"ready to add the labels");
    [self addChild:myLabel];
    [self addChild:my2ndLabel];
    
    
}



-(void)makeMyInstructionLabels{
    SKAction *myPrimaryHelperLabelAction = [SKAction repeatActionForever:[SKAction
                                                                          sequence:@[ [SKAction fadeAlphaTo:1.0 duration:1.0],
                                                                                      [SKAction waitForDuration:5.0],
                                                                                      [SKAction fadeAlphaTo:0.0 duration:3.0],
                                                                                      [SKAction waitForDuration:10.0],
                                                                                      ]]];
    
    
    
    SKLabelNode *myLabel1 = [SKLabelNode labelNodeWithFontNamed:@"Helvetica"];
    [myLabel1 setText:@"Tap or Swipe"];
    //    , tap with two fingers to create snow, tap with three fingers to create smoke, swipe right to clear the screen!"];
    [myLabel1 setPosition:CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame))];
    [myLabel1 setFontSize:16];
    [myLabel1 setFontColor:[UIColor redColor]];
    [myLabel1 setAlpha:0.0];
    [myLabel1 setZPosition:20.0];
    [self addChild:myLabel1];
    
    [myLabel1 runAction:myPrimaryHelperLabelAction];
    
    
    //    [myLabel1 runAction:[SKAction sequence:@[[SKAction waitForDuration:1.0],
    //                                             [SKAction fadeInWithDuration:2.0],]]];
    SKLabelNode *myLabel2 = [SKLabelNode labelNodeWithFontNamed:@"Helvetica"];
    //    , tap with two fingers to create snow, tap with three fingers to create smoke, swipe right to clear the screen!"];
    [myLabel2 setPosition:CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame)-20)];
    [myLabel2 setFontSize:14];
    [myLabel2 setFontColor:[UIColor redColor]];
    [myLabel2 setText:@"Swipe Up or Down To Change Picture Sizes"];
    [myLabel2 setAlpha:0.0];
    [myLabel2 setZPosition:20.0];
    [self addChild:myLabel2];
    //    [myLabel2 runAction:[SKAction sequence:@[[SKAction waitForDuration:1.0],
    //                                             [SKAction fadeInWithDuration:3.0],]]];
    
    [myLabel2 runAction:myPrimaryHelperLabelAction];
    
    
    SKLabelNode *myLabel3 = [SKLabelNode labelNodeWithFontNamed:@"Helvetica"];
    //    , tap with two fingers to create snow, tap with three fingers to create smoke, swipe right to clear the screen!"];
    
    
    [myLabel3 setPosition:CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame)-40)];
    [myLabel3 setFontSize:14];
    [myLabel3 setFontColor:[UIColor redColor]];
    [myLabel3 setText:@"Swipe Right to Clear the Screen"];
    [myLabel3 setAlpha:0.0];
    [myLabel3 setZPosition:20.0];
    
    [self addChild:myLabel3];
    //    [myLabel3 runAction:[SKAction sequence:@[[SKAction waitForDuration:1.0],
    //                                             [SKAction fadeInWithDuration:4.0],]]];
    
    [myLabel3 runAction:myPrimaryHelperLabelAction];
    
    SKLabelNode *myLabel4 = [SKLabelNode labelNodeWithFontNamed:@"Helvetica"];
    //    , tap with two fingers to create snow, tap with three fingers to create smoke, swipe right to clear the screen!"];
    [myLabel4 setPosition:CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame)-60)];
    [myLabel4 setFontSize:14];
    [myLabel4 setFontColor:[UIColor redColor]];
    [myLabel4 setText:@"Tap for all 5 Pictures"];
    [myLabel4 setAlpha:0.0];
    [myLabel4 setZPosition:20.0];
    
    [self addChild:myLabel4];
    
    //    [myLabel4 runAction:[SKAction sequence:@[[SKAction waitForDuration:1.0],
    //                                             [SKAction fadeInWithDuration:5.0],]]];
    [myLabel4 runAction:myPrimaryHelperLabelAction];
    
}



-(void)singleTapAction {
    /* Called when a touch begins */
    
    
    for (int myLoopCount = 1 ; myLoopCount <= myFiveSpriteLoops ; myLoopCount++) {
        for (int mySpriteNum = 1; mySpriteNum <= 5; mySpriteNum++) {
            
            //            CGPoint location = CGPointMake(CGRectGetMidX(self.frame) + arc4random()%100 - 50.0, CGRectGetMaxY(self.frame) - myYOffset );
            //            SKSpriteNode *sprite = [SKSpriteNode spriteNodeWithTexture:[SKTexture textureWithImage:mySpriteImage1]];
            
            switch (mySpriteNum) {
                case 1:
                {
                    [self myDropPicture1];
                    //                        [sprite setTexture:[SKTexture textureWithImage:mySpriteImage1]];
                    break;
                }
                case 2:
                {
                    [self myDropPicture2];
                    //                        dispatch_async(myDispatchQueue, ^{
                    //                    [sprite setTexture:[SKTexture textureWithImage:mySpriteImage2]];
                    //                        });
                    break;
                }
                case 3:
                {
                    [self myDropPicture3];
                    //                    [sprite setTexture:[SKTexture textureWithImage:mySpriteImage3]];
                    break;
                }
                case 4:
                {
                    [self myDropPicture4];
                    //                    [sprite setTexture:[SKTexture textureWithImage:mySpriteImage4]];
                    break;
                }
                case 5:
                {
                    [self myDropPicture5];
                    //                    [sprite setTexture:[SKTexture textureWithImage:mySpriteImage5]];
                    break;
                }
                default:
                    break;
            }
            
            //            dispatch_async(myDispatchQueue, ^{
            //                [sprite setSize:CGSizeMake(myImageSpriteSize, myImageSpriteSize)];
            //            });
            
            
            
            
            
            //            [sprite setName:@"photosprite"];
            //            [sprite setPosition: location ];
            //            [sprite.physicsBody setRestitution:1.05];
            //            [sprite.physicsBody setAffectedByGravity:YES];
            //            [sprite setPhysicsBody:[SKPhysicsBody bodyWithRectangleOfSize:CGSizeMake(myImageSpriteSize, myImageSpriteSize)]];
            //                            [sprite setPhysicsBody:[SKPhysicsBody bodyWithCircleOfRadius:myCircleSpriteSize]];
            //            [sprite.physicsBody setContactTestBitMask:0x1];
            //                [sprite.physicsBody setMass:myImageSpriteMass];
            //            [sprite.physicsBody setMass:1.0];
            
            
            
            
            //            [self addChild:sprite];
            
            
            
            //                NSString *myPath = [[NSBundle mainBundle] pathForResource:@"myParticle" ofType:@"sks"];
            //
            //                SKEmitterNode *myExitEmitter =  [NSKeyedUnarchiver unarchiveObjectWithFile:myPath];
            //                [sprite addChild:myExitEmitter];
            //            [sprite runAction:
            //             [SKAction sequence:@[
            //                                  [SKAction waitForDuration:20.0 withRange:2.5],
            //                                  [SKAction removeFromParent],
            //                                  ]]  ];
            
        }
        
        
    } // end of loopcount
    
}


- (void)myDropPicture1{
    myImageSprite1 = [SKSpriteNode spriteNodeWithTexture:[ SKTexture textureWithImage:mySpriteImage1]];
    myImageSprite1.position = CGPointMake(CGRectGetMidX(self.frame) - 100, CGRectGetMaxY(self.frame) - myYOffset );
    //            dispatch_async(myColorQueue, ^{
    [myImageSprite1 setSize:CGSizeMake(myImageSpriteSize, myImageSpriteSize)];

    
    
//    SKWarpGeometryGrid *myWarpGeometryGrid = [SKWarpGeometryGrid gridWithColumns:3 rows:3 sourcePositions:nil destPositions:nil];
//    [myWarpGeometryGrid destPositionAtIndex:1];
//    [myWarpGeometryGrid gridByReplacingSourcePositions:&mySourceVector];
//    [myWarpGeometryGrid gridByReplacingDestPositions:&myDestVector];
    
    
    
    
    
    //            });
    myImageSprite1.physicsBody = [ SKPhysicsBody bodyWithRectangleOfSize:myImageSprite1.size];
    myImageSprite1.physicsBody.restitution = myImageSpriteRestitution;
    myImageSprite1.physicsBody.contactTestBitMask = 0x02;
    //            [myImageSprite1.physicsBody setMass:myImageSpriteMass];
    [myImageSprite1 setName:@"photosprite"];
    [myImageSprite1 runAction:myImageSpriteAction];
    [self addChild:myImageSprite1];
    [myImageSprite1.physicsBody setLinearDamping:myImageSpriteDamping];

}

-(void)myDropPicture2{
    myImageSprite2 = [SKSpriteNode spriteNodeWithTexture:[ SKTexture textureWithImage:mySpriteImage2]];
    myImageSprite2.position = CGPointMake(CGRectGetMidX(self.frame) - 50, CGRectGetMaxY(self.frame) - myYOffset );
    //            dispatch_async(myColorQueue, ^{
    [myImageSprite2 setSize:CGSizeMake(myImageSpriteSize, myImageSpriteSize)];
    //            });
    myImageSprite2.physicsBody = [ SKPhysicsBody bodyWithRectangleOfSize:myImageSprite2.size];
    myImageSprite2.physicsBody.restitution = myImageSpriteRestitution;
    myImageSprite2.physicsBody.contactTestBitMask = 0x02;
    //            [myImageSprite2.physicsBody setMass:myImageSpriteMass];
    [myImageSprite2 setName:@"photosprite"];
    [myImageSprite2 runAction:myImageSpriteAction];
    [self addChild:myImageSprite2];
    [myImageSprite2.physicsBody setLinearDamping:myImageSpriteDamping];

}


- (void)myDropPicture3{
    myImageSprite3 = [SKSpriteNode spriteNodeWithTexture:[ SKTexture textureWithImage:mySpriteImage3]];
    myImageSprite3.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMaxY(self.frame) - myYOffset );
    //            dispatch_async(myColorQueue, ^{
    [myImageSprite3 setSize:CGSizeMake(myImageSpriteSize, myImageSpriteSize)];
    //            });
    myImageSprite3.physicsBody = [ SKPhysicsBody bodyWithRectangleOfSize:myImageSprite3.size];
    myImageSprite3.physicsBody.restitution = myImageSpriteRestitution;
    myImageSprite3.physicsBody.contactTestBitMask = 0x02;
    //            [myImageSprite3.physicsBody setMass:myImageSpriteMass];
    [myImageSprite3 setName:@"photosprite"];
    [myImageSprite3 runAction:myImageSpriteAction];
    [self addChild:myImageSprite3];
    [myImageSprite3.physicsBody setLinearDamping:myImageSpriteDamping];

}


- (void)myDropPicture4{
    myImageSprite4 = [SKSpriteNode spriteNodeWithTexture:[ SKTexture textureWithImage:mySpriteImage4]];
    myImageSprite4.position = CGPointMake(CGRectGetMidX(self.frame) + 50, CGRectGetMaxY(self.frame) - myYOffset );
    //            dispatch_async(myColorQueue, ^{
    [myImageSprite4 setSize:CGSizeMake(myImageSpriteSize, myImageSpriteSize)];
    //            });
    
    myImageSprite4.physicsBody = [ SKPhysicsBody bodyWithRectangleOfSize:myImageSprite4.size];
    myImageSprite4.physicsBody.restitution = myImageSpriteRestitution;
    myImageSprite4.physicsBody.contactTestBitMask = 0x02;
//    [myImageSprite4.physicsBody setMass:myImageSpriteMass];
    [myImageSprite4 setName:@"photosprite"];
    [myImageSprite4 runAction:myImageSpriteAction];
    [self addChild:myImageSprite4];
    [myImageSprite4.physicsBody setLinearDamping:myImageSpriteDamping];
    
}

- (void)myDropPicture5{
    myImageSprite5 = [SKSpriteNode spriteNodeWithTexture:[ SKTexture textureWithImage:mySpriteImage5]];
    myImageSprite5.position = CGPointMake(CGRectGetMidX(self.frame) + 100, CGRectGetMaxY(self.frame) - myYOffset );
    //            dispatch_async(myColorQueue, ^{
    [myImageSprite5 setSize:CGSizeMake(myImageSpriteSize, myImageSpriteSize)];
    //            });
    myImageSprite5.physicsBody = [ SKPhysicsBody bodyWithRectangleOfSize:myImageSprite5.size];
    myImageSprite5.physicsBody.restitution = myImageSpriteRestitution;
    myImageSprite5.physicsBody.contactTestBitMask = 0x02;
    //            [myImageSprite5.physicsBody setMass:myImageSpriteMass];
    [myImageSprite5 setName:@"photosprite"];
    [myImageSprite5 runAction:myImageSpriteAction];
    [self addChild:myImageSprite5];
    [myImageSprite5.physicsBody setLinearDamping:myImageSpriteDamping];
    
}





- (IBAction)mySwitchChanged:(UISegmentedControl *)sender{
    long myValue = sender.selectedSegmentIndex;
    //NSLog(@"Value = %ld",myValue);
    
    
    //    dispatch_async(myDispatchQueue, ^{
    
    switch (myValue) {
        case 0: {
            [self myDropPicture1];
            break;
        }
        case 1: {
            [self myDropPicture2];
            break;
        }
        case 2: {
            [self myDropPicture3];
            break;
        }
        case 3: {
            [self myDropPicture4];
            break;
        }
        case 4: {
            [self myDropPicture5];
            break;
        }
        case 5:{
            // rz have to put circle sprites in here
            //
            [self myCircles];
            break;
        }
        case 6:
        {
            [self mySpray];
            break;
        }
        case 7:
            exit(0);
        default:
            break;
    }
    [sender setSelectedSegmentIndex:-1];
    //    });
    
}

-(void)mySpray{
    CGSize myColorSpriteSize =   CGSizeMake(myColorSpriteDefaultSize, myColorSpriteDefaultSize) ;
    for ( int i = 1 ; i <= myColorSpriteLoops ; i++){
        
        SKSpriteNode *colorsprite1 = [SKSpriteNode spriteNodeWithColor:[UIColor redColor] size:myColorSpriteSize];
        SKSpriteNode *colorsprite2 = [SKSpriteNode spriteNodeWithColor:[UIColor blackColor] size:myColorSpriteSize ];      // 0.0 white
        SKSpriteNode *colorsprite3 = [SKSpriteNode spriteNodeWithColor:[UIColor darkGrayColor] size:myColorSpriteSize ];   // 0.333 white
        SKSpriteNode *colorsprite4 = [SKSpriteNode spriteNodeWithColor:[UIColor lightGrayColor] size:myColorSpriteSize ];  // 0.667 white
        SKSpriteNode *colorsprite5 = [SKSpriteNode spriteNodeWithColor:[UIColor whiteColor] size:myColorSpriteSize ];      // 1.0 white
        SKSpriteNode *colorsprite6 = [SKSpriteNode spriteNodeWithColor:[UIColor grayColor] size:myColorSpriteSize ];       // 0.5 white
        SKSpriteNode *colorsprite7 = [SKSpriteNode spriteNodeWithColor:[UIColor redColor] size:myColorSpriteSize ];        // 1.0, 0.0, 0.0 RGB
        SKSpriteNode *colorsprite8 = [SKSpriteNode spriteNodeWithColor:[UIColor greenColor] size:myColorSpriteSize ];      // 0.0, 1.0, 0.0 RGB
        SKSpriteNode *colorsprite9 = [SKSpriteNode spriteNodeWithColor:[UIColor blueColor] size:myColorSpriteSize ];       // 0.0, 0.0, 1.0 RGB
        SKSpriteNode *colorsprite10 = [SKSpriteNode spriteNodeWithColor:[UIColor cyanColor] size:myColorSpriteSize ];       // 0.0, 1.0, 1.0 RGB
        SKSpriteNode *colorsprite11 = [SKSpriteNode spriteNodeWithColor:[UIColor yellowColor] size:myColorSpriteSize ];     // 1.0, 1.0, 0.0 RGB
        SKSpriteNode *colorsprite12 = [SKSpriteNode spriteNodeWithColor:[UIColor magentaColor] size:myColorSpriteSize ];    // 1.0, 0.0, 1.0 RGB
        SKSpriteNode *colorsprite13 = [SKSpriteNode spriteNodeWithColor:[UIColor orangeColor] size:myColorSpriteSize ];     // 1.0, 0.5, 0.0 RGB
        SKSpriteNode *colorsprite14 = [SKSpriteNode spriteNodeWithColor:[UIColor purpleColor] size:myColorSpriteSize ];     // 0.5, 0.0, 0.5 RGB
        SKSpriteNode *colorsprite15 = [SKSpriteNode spriteNodeWithColor:[UIColor brownColor] size:myColorSpriteSize ];      // 0.6, 0.4, 0.2 RGB
        colorsprite1.position = CGPointMake(CGRectGetMidX(self.frame) - 175 , CGRectGetMaxY(self.frame) - myYOffset );
        colorsprite2.position = CGPointMake(CGRectGetMidX(self.frame) - 150 , CGRectGetMaxY(self.frame) - myYOffset );
        colorsprite3.position = CGPointMake(CGRectGetMidX(self.frame) - 125 , CGRectGetMaxY(self.frame) - myYOffset );
        colorsprite4.position = CGPointMake(CGRectGetMidX(self.frame) - 100, CGRectGetMaxY(self.frame) - myYOffset );
        colorsprite5.position = CGPointMake(CGRectGetMidX(self.frame) - 75 , CGRectGetMaxY(self.frame) - myYOffset );
        colorsprite6.position = CGPointMake(CGRectGetMidX(self.frame) - 50 , CGRectGetMaxY(self.frame) - myYOffset );
        colorsprite7.position = CGPointMake(CGRectGetMidX(self.frame) - 25 , CGRectGetMaxY(self.frame) - myYOffset );
        colorsprite8.position = CGPointMake(CGRectGetMidX(self.frame) , CGRectGetMaxY(self.frame) - myYOffset );
        colorsprite9.position = CGPointMake(CGRectGetMidX(self.frame) + 25 , CGRectGetMaxY(self.frame) - myYOffset );
        colorsprite10.position = CGPointMake(CGRectGetMidX(self.frame) + 50 , CGRectGetMaxY(self.frame) - myYOffset );
        colorsprite11.position = CGPointMake(CGRectGetMidX(self.frame) + 75 , CGRectGetMaxY(self.frame) - myYOffset );
        colorsprite12.position = CGPointMake(CGRectGetMidX(self.frame) + 100 , CGRectGetMaxY(self.frame) - myYOffset );
        colorsprite13.position = CGPointMake(CGRectGetMidX(self.frame) + 125 , CGRectGetMaxY(self.frame) - myYOffset );
        colorsprite14.position = CGPointMake(CGRectGetMidX(self.frame) + 150 , CGRectGetMaxY(self.frame) - myYOffset );
        colorsprite15.position =  CGPointMake(CGRectGetMidX(self.frame) + 175 , CGRectGetMaxY(self.frame) - myYOffset );
        
        
        colorsprite1.physicsBody = [ SKPhysicsBody bodyWithRectangleOfSize:myColorSpriteSize];
        colorsprite2.physicsBody = [ SKPhysicsBody bodyWithRectangleOfSize:myColorSpriteSize];
        colorsprite3.physicsBody = [ SKPhysicsBody bodyWithRectangleOfSize:myColorSpriteSize];
        colorsprite4.physicsBody = [ SKPhysicsBody bodyWithRectangleOfSize:myColorSpriteSize];
        colorsprite5.physicsBody = [ SKPhysicsBody bodyWithRectangleOfSize:myColorSpriteSize];
        colorsprite6.physicsBody = [ SKPhysicsBody bodyWithRectangleOfSize:myColorSpriteSize];
        colorsprite7.physicsBody = [ SKPhysicsBody bodyWithRectangleOfSize:myColorSpriteSize];
        colorsprite8.physicsBody = [ SKPhysicsBody bodyWithRectangleOfSize:myColorSpriteSize];
        colorsprite9.physicsBody = [ SKPhysicsBody bodyWithRectangleOfSize:myColorSpriteSize];
        colorsprite10.physicsBody = [ SKPhysicsBody bodyWithRectangleOfSize:myColorSpriteSize];
        colorsprite11.physicsBody = [ SKPhysicsBody bodyWithRectangleOfSize:myColorSpriteSize];
        colorsprite12.physicsBody = [ SKPhysicsBody bodyWithRectangleOfSize:myColorSpriteSize];
        colorsprite13.physicsBody = [ SKPhysicsBody bodyWithRectangleOfSize:myColorSpriteSize];
        colorsprite14.physicsBody = [ SKPhysicsBody bodyWithRectangleOfSize:myColorSpriteSize];
        colorsprite15.physicsBody = [ SKPhysicsBody bodyWithRectangleOfSize:myColorSpriteSize];
        
        
        colorsprite1.physicsBody.affectedByGravity = YES;
        colorsprite2.physicsBody.affectedByGravity = YES;
        colorsprite3.physicsBody.affectedByGravity = YES;
        colorsprite4.physicsBody.affectedByGravity = YES;
        colorsprite5.physicsBody.affectedByGravity = YES;
        colorsprite6.physicsBody.affectedByGravity = YES;
        colorsprite7.physicsBody.affectedByGravity = YES;
        colorsprite8.physicsBody.affectedByGravity = YES;
        colorsprite9.physicsBody.affectedByGravity = YES;
        colorsprite10.physicsBody.affectedByGravity = YES;
        colorsprite11.physicsBody.affectedByGravity = YES;
        colorsprite12.physicsBody.affectedByGravity = YES;
        colorsprite13.physicsBody.affectedByGravity = YES;
        colorsprite14.physicsBody.affectedByGravity = YES;
        colorsprite15.physicsBody.affectedByGravity = YES;
        
        colorsprite1.physicsBody.linearDamping = myColorSpriteDamping;
        colorsprite2.physicsBody.linearDamping = myColorSpriteDamping;
        colorsprite3.physicsBody.linearDamping = myColorSpriteDamping;
        colorsprite4.physicsBody.linearDamping = myColorSpriteDamping;
        colorsprite5.physicsBody.linearDamping = myColorSpriteDamping;
        colorsprite6.physicsBody.linearDamping = myColorSpriteDamping;
        colorsprite7.physicsBody.linearDamping = myColorSpriteDamping;
        colorsprite8.physicsBody.linearDamping = myColorSpriteDamping;
        colorsprite9.physicsBody.linearDamping = myColorSpriteDamping;
        colorsprite10.physicsBody.linearDamping = myColorSpriteDamping;
        colorsprite11.physicsBody.linearDamping = myColorSpriteDamping;
        colorsprite12.physicsBody.linearDamping = myColorSpriteDamping;
        colorsprite13.physicsBody.linearDamping = myColorSpriteDamping;
        colorsprite14.physicsBody.linearDamping = myColorSpriteDamping;
        colorsprite15.physicsBody.linearDamping = myColorSpriteDamping;
        
        
        
        
        colorsprite1.name = @"colorsprite";
        colorsprite2.name = @"colorsprite" ;
        colorsprite3.name = @"colorsprite" ;
        colorsprite4.name = @"colorsprite" ;
        colorsprite5.name = @"colorsprite" ;
        colorsprite6.name = @"colorsprite" ;
        colorsprite7.name = @"colorsprite" ;
        colorsprite8.name = @"colorsprite" ;
        colorsprite9.name = @"colorsprite" ;
        colorsprite10.name = @"colorsprite" ;
        colorsprite11.name = @"colorsprite" ;
        colorsprite12.name = @"colorsprite" ;
        colorsprite13.name = @"colorsprite" ;
        colorsprite14.name = @"colorsprite" ;
        colorsprite15.name = @"colorsprite" ;
        
        
        
        colorsprite1.physicsBody.contactTestBitMask = 0x01;
        colorsprite2.physicsBody.contactTestBitMask = 0x01;
        colorsprite3.physicsBody.contactTestBitMask = 0x01;
        colorsprite4.physicsBody.contactTestBitMask = 0x01;
        colorsprite5.physicsBody.contactTestBitMask = 0x01;
        colorsprite6.physicsBody.contactTestBitMask = 0x01;
        colorsprite7.physicsBody.contactTestBitMask = 0x01;
        colorsprite8.physicsBody.contactTestBitMask = 0x01;
        colorsprite9.physicsBody.contactTestBitMask = 0x01;
        colorsprite10.physicsBody.contactTestBitMask = 0x01;
        colorsprite11.physicsBody.contactTestBitMask = 0x01;
        colorsprite12.physicsBody.contactTestBitMask = 0x01;
        colorsprite13.physicsBody.contactTestBitMask = 0x01;
        colorsprite14.physicsBody.contactTestBitMask = 0x01;
        colorsprite15.physicsBody.contactTestBitMask = 0x01 ;
        
        
        
        
        SKAction *mycolorSpriteAction =    [SKAction sequence:@[
                                                                //                                                                [SKAction rotateByAngle:( M_PI ) duration:1],
                                                                [SKAction waitForDuration:15.0 withRange:1.5],
                                                                [SKAction removeFromParent],
                                                                ]];
        
        
        
        [colorsprite1 runAction:mycolorSpriteAction];
        [colorsprite2 runAction:mycolorSpriteAction];
        [colorsprite3 runAction:mycolorSpriteAction];
        [colorsprite4 runAction:mycolorSpriteAction];
        [colorsprite5 runAction:mycolorSpriteAction];
        [colorsprite6 runAction:mycolorSpriteAction];
        [colorsprite7 runAction:mycolorSpriteAction];
        [colorsprite8 runAction:mycolorSpriteAction];
        [colorsprite9 runAction:mycolorSpriteAction];
        [colorsprite10 runAction:mycolorSpriteAction];
        [colorsprite11 runAction:mycolorSpriteAction];
        [colorsprite12 runAction:mycolorSpriteAction];
        [colorsprite13 runAction:mycolorSpriteAction];
        [colorsprite14 runAction:mycolorSpriteAction];
        [colorsprite15 runAction:mycolorSpriteAction];
        
        
        
        
        [self addChild:colorsprite1];
        [self addChild:colorsprite2];
        [self addChild:colorsprite3];
        [self addChild:colorsprite4];
        [self addChild:colorsprite5];
        [self addChild:colorsprite6];
        [self addChild:colorsprite7];
        [self addChild:colorsprite8];
        [self addChild:colorsprite9];
        [self addChild:colorsprite10];
        [self addChild:colorsprite11];
        [self addChild:colorsprite12];
        [self addChild:colorsprite13];
        [self addChild:colorsprite14];
        [self addChild:colorsprite15];
        
    } // end of loop
}


-(void)myCircles{
    for ( int i = 1 ; i <= myCircleSpriteLoops ; i++){
        
        SKSpriteNode *myCircleSprite1 = [ SKSpriteNode spriteNodeWithImageNamed:@"Leopard"];
        [myCircleSprite1 setScale: myCircleSpriteScale ];
        [myCircleSprite1 setPhysicsBody:[SKPhysicsBody bodyWithCircleOfRadius:myCircleSpriteSize]];
        [myCircleSprite1.physicsBody setAffectedByGravity:YES];
        [myCircleSprite1.physicsBody setRestitution:myCircleSpriteRestitution];
        [myCircleSprite1.physicsBody setContactTestBitMask:0x03];
        myCircleSprite1.position = CGPointMake(CGRectGetMidX(self.frame) - 175 , CGRectGetMaxY(self.frame) - myYOffset );
        [self addChild:myCircleSprite1];
        SKAction *myCircleSpriteAction =    [SKAction sequence:@[
                                                                 [SKAction waitForDuration:15.0 withRange:1.5],
                                                                 [SKAction removeFromParent],
                                                                 ]];
        [myCircleSprite1 runAction:myCircleSpriteAction];
        
        SKSpriteNode *myCircleSprite2 = [ SKSpriteNode spriteNodeWithImageNamed:@"Blue"];
        [myCircleSprite2 setScale: myCircleSpriteScale ];
        [myCircleSprite2 setPhysicsBody:[SKPhysicsBody bodyWithCircleOfRadius:myCircleSpriteSize]];
        [myCircleSprite2.physicsBody setAffectedByGravity:YES];
        [myCircleSprite2.physicsBody setRestitution:myCircleSpriteRestitution];
        [myCircleSprite2.physicsBody setContactTestBitMask:0x03];
        myCircleSprite2.position = CGPointMake(CGRectGetMidX(self.frame) - 150 , CGRectGetMaxY(self.frame) - myYOffset );
        [self addChild:myCircleSprite2];
        [myCircleSprite2 runAction:myCircleSpriteAction];
        
        SKSpriteNode *myCircleSprite3 = [ SKSpriteNode spriteNodeWithImageNamed:@"Grey"];
        [myCircleSprite3 setScale: myCircleSpriteScale ];
        [myCircleSprite3 setPhysicsBody:[SKPhysicsBody bodyWithCircleOfRadius:myCircleSpriteSize]];
        [myCircleSprite3.physicsBody setAffectedByGravity:YES];
        [myCircleSprite3.physicsBody setRestitution:myCircleSpriteRestitution];
        [myCircleSprite3.physicsBody setContactTestBitMask:0x03];
        myCircleSprite3.position = CGPointMake(CGRectGetMidX(self.frame) - 125 , CGRectGetMaxY(self.frame) - myYOffset );
        [self addChild:myCircleSprite3];
        [myCircleSprite3 runAction:myCircleSpriteAction];
        
        SKSpriteNode *myCircleSprite4 = [ SKSpriteNode spriteNodeWithImageNamed:@"Wood"];
        [myCircleSprite4 setScale: myCircleSpriteScale ];
        [myCircleSprite4 setPhysicsBody:[SKPhysicsBody bodyWithCircleOfRadius:myCircleSpriteSize]];
        [myCircleSprite4.physicsBody setAffectedByGravity:YES];
        [myCircleSprite4.physicsBody setRestitution:myCircleSpriteRestitution];
        [myCircleSprite4.physicsBody setContactTestBitMask:0x03];
        myCircleSprite4.position = CGPointMake(CGRectGetMidX(self.frame) - 100 , CGRectGetMaxY(self.frame) - myYOffset );
        [self addChild:myCircleSprite4];
        [myCircleSprite4 runAction:myCircleSpriteAction];
        
        SKSpriteNode *myCircleSprite5 = [ SKSpriteNode spriteNodeWithImageNamed:@"Yellow"];
        [myCircleSprite5 setScale: myCircleSpriteScale ];
        [myCircleSprite5 setPhysicsBody:[SKPhysicsBody bodyWithCircleOfRadius:myCircleSpriteSize]];
        [myCircleSprite5.physicsBody setAffectedByGravity:YES];
        [myCircleSprite5.physicsBody setRestitution:myCircleSpriteRestitution];
        [myCircleSprite5.physicsBody setContactTestBitMask:0x03];
        myCircleSprite5.position = CGPointMake(CGRectGetMidX(self.frame) - 75 , CGRectGetMaxY(self.frame) - myYOffset );
        [self addChild:myCircleSprite5];
        [myCircleSprite5 runAction:myCircleSpriteAction];
        
        SKSpriteNode *myCircleSprite6 = [ SKSpriteNode spriteNodeWithImageNamed:@"Red"];
        [myCircleSprite6 setScale: myCircleSpriteScale ];
        [myCircleSprite6 setPhysicsBody:[SKPhysicsBody bodyWithCircleOfRadius:myCircleSpriteSize]];
        [myCircleSprite6.physicsBody setAffectedByGravity:YES];
        [myCircleSprite6.physicsBody setRestitution:myCircleSpriteRestitution];
        [myCircleSprite6.physicsBody setContactTestBitMask:0x03];
        myCircleSprite6.position = CGPointMake(CGRectGetMidX(self.frame) - 50 , CGRectGetMaxY(self.frame) - myYOffset );
        [self addChild:myCircleSprite6];
        [myCircleSprite6 runAction:myCircleSpriteAction];
        
        SKSpriteNode *myCircleSprite7 = [ SKSpriteNode spriteNodeWithImageNamed:@"Green"];
        [myCircleSprite7 setScale: myCircleSpriteScale ];
        [myCircleSprite7 setPhysicsBody:[SKPhysicsBody bodyWithCircleOfRadius:myCircleSpriteSize]];
        [myCircleSprite7.physicsBody setAffectedByGravity:YES];
        [myCircleSprite7.physicsBody setRestitution:myCircleSpriteRestitution];
        [myCircleSprite7.physicsBody setContactTestBitMask:0x03];
        myCircleSprite7.position = CGPointMake(CGRectGetMidX(self.frame) - 25 , CGRectGetMaxY(self.frame) - myYOffset );
        [self addChild:myCircleSprite7];
        [myCircleSprite7 runAction:myCircleSpriteAction];
        
        SKSpriteNode *myCircleSprite8 = [ SKSpriteNode spriteNodeWithImageNamed:@"Basket"];
        [myCircleSprite8 setScale: myCircleSpriteScale ];
        [myCircleSprite8 setPhysicsBody:[SKPhysicsBody bodyWithCircleOfRadius:myCircleSpriteSize]];
        [myCircleSprite8.physicsBody setAffectedByGravity:YES];
        [myCircleSprite8.physicsBody setRestitution:myCircleSpriteRestitution];
        [myCircleSprite8.physicsBody setContactTestBitMask:0x03];
        myCircleSprite8.position = CGPointMake(CGRectGetMidX(self.frame)  , CGRectGetMaxY(self.frame) - myYOffset );
        [self addChild:myCircleSprite8];
        [myCircleSprite8 runAction:myCircleSpriteAction];
        
        SKSpriteNode *myCircleSprite9 = [ SKSpriteNode spriteNodeWithImageNamed:@"Checker"];
        [myCircleSprite9 setScale: myCircleSpriteScale ];
        [myCircleSprite9 setPhysicsBody:[SKPhysicsBody bodyWithCircleOfRadius:myCircleSpriteSize]];
        [myCircleSprite9.physicsBody setAffectedByGravity:YES];
        [myCircleSprite9.physicsBody setRestitution:myCircleSpriteRestitution];
        [myCircleSprite9.physicsBody setContactTestBitMask:0x03];
        myCircleSprite9.position = CGPointMake(CGRectGetMidX(self.frame) + 25 , CGRectGetMaxY(self.frame) - myYOffset );
        [self addChild:myCircleSprite9];
        [myCircleSprite9 runAction:myCircleSpriteAction];
        
        
        SKSpriteNode *myCircleSprite10 = [ SKSpriteNode spriteNodeWithImageNamed:@"Swirly"];
        [myCircleSprite10 setScale: myCircleSpriteScale ];
        [myCircleSprite10 setPhysicsBody:[SKPhysicsBody bodyWithCircleOfRadius:myCircleSpriteSize]];
        [myCircleSprite10.physicsBody setAffectedByGravity:YES];
        [myCircleSprite10.physicsBody setRestitution:myCircleSpriteRestitution];
        [myCircleSprite10.physicsBody setContactTestBitMask:0x03];
        myCircleSprite10.position = CGPointMake(CGRectGetMidX(self.frame) + 50 , CGRectGetMaxY(self.frame) - myYOffset );
        [self addChild:myCircleSprite10];
        [myCircleSprite10 runAction:myCircleSpriteAction];
        
        
        SKSpriteNode *myCircleSprite11 = [ SKSpriteNode spriteNodeWithImageNamed:@"BrownSwirly"];
        [myCircleSprite11 setScale: myCircleSpriteScale ];
        [myCircleSprite11 setPhysicsBody:[SKPhysicsBody bodyWithCircleOfRadius:myCircleSpriteSize]];
        [myCircleSprite11.physicsBody setAffectedByGravity:YES];
        [myCircleSprite11.physicsBody setRestitution:myCircleSpriteRestitution];
        [myCircleSprite11.physicsBody setContactTestBitMask:0x03];
        myCircleSprite11.position = CGPointMake(CGRectGetMidX(self.frame) + 75 , CGRectGetMaxY(self.frame) - myYOffset );
        [self addChild:myCircleSprite11];
        [myCircleSprite11 runAction:myCircleSpriteAction];
        
        
        SKSpriteNode *myCircleSprite12 = [ SKSpriteNode spriteNodeWithImageNamed:@"Rocks"];
        [myCircleSprite12 setScale: myCircleSpriteScale ];
        [myCircleSprite12 setPhysicsBody:[SKPhysicsBody bodyWithCircleOfRadius:myCircleSpriteSize]];
        [myCircleSprite12.physicsBody setAffectedByGravity:YES];
        [myCircleSprite12.physicsBody setRestitution:myCircleSpriteRestitution];
        [myCircleSprite12.physicsBody setContactTestBitMask:0x03];
        myCircleSprite12.position = CGPointMake(CGRectGetMidX(self.frame) + 100 , CGRectGetMaxY(self.frame) - myYOffset );
        [self addChild:myCircleSprite12];
        [myCircleSprite12 runAction:myCircleSpriteAction];
        
        
        SKSpriteNode *myCircleSprite13 = [ SKSpriteNode spriteNodeWithImageNamed:@"Paper"];
        [myCircleSprite13 setScale: myCircleSpriteScale ];
        [myCircleSprite13 setPhysicsBody:[SKPhysicsBody bodyWithCircleOfRadius:myCircleSpriteSize]];
        [myCircleSprite13.physicsBody setAffectedByGravity:YES];
        [myCircleSprite13.physicsBody setRestitution:myCircleSpriteRestitution];
        [myCircleSprite13.physicsBody setContactTestBitMask:0x03];
        myCircleSprite13.position = CGPointMake(CGRectGetMidX(self.frame) + 125 , CGRectGetMaxY(self.frame) - myYOffset );
        [self addChild:myCircleSprite13];
        [myCircleSprite13 runAction:myCircleSpriteAction];
        
        
        SKSpriteNode *myCircleSprite14 = [ SKSpriteNode spriteNodeWithImageNamed:@"Marble"];
        [myCircleSprite14 setScale: myCircleSpriteScale ];
        [myCircleSprite14 setPhysicsBody:[SKPhysicsBody bodyWithCircleOfRadius:myCircleSpriteSize]];
        [myCircleSprite14.physicsBody setAffectedByGravity:YES];
        [myCircleSprite14.physicsBody setRestitution:myCircleSpriteRestitution];
        [myCircleSprite14.physicsBody setContactTestBitMask:0x03];
        myCircleSprite14.position = CGPointMake(CGRectGetMidX(self.frame) + 150 , CGRectGetMaxY(self.frame) - myYOffset );
        [self addChild:myCircleSprite14];
        [myCircleSprite14 runAction:myCircleSpriteAction];
        
        
        SKSpriteNode *myCircleSprite15 = [ SKSpriteNode spriteNodeWithImageNamed:@"Bricks"];
        [myCircleSprite15 setScale: myCircleSpriteScale ];
        [myCircleSprite15 setPhysicsBody:[SKPhysicsBody bodyWithCircleOfRadius:myCircleSpriteSize]];
        [myCircleSprite15.physicsBody setAffectedByGravity:YES];
        [myCircleSprite15.physicsBody setRestitution:myCircleSpriteRestitution];
        [myCircleSprite15.physicsBody setContactTestBitMask:0x03];
        myCircleSprite15.position = CGPointMake(CGRectGetMidX(self.frame) + 175 , CGRectGetMaxY(self.frame) - myYOffset );
        [self addChild:myCircleSprite15];
        [myCircleSprite15 runAction:myCircleSpriteAction];
        
        myCircleSprite1.name = @"circlesprite";
        myCircleSprite2.name = @"circlesprite" ;
        myCircleSprite3.name = @"circlesprite" ;
        myCircleSprite4.name = @"circlesprite" ;
        myCircleSprite5.name = @"circlesprite" ;
        myCircleSprite6.name = @"circlesprite" ;
        myCircleSprite7.name = @"circlesprite" ;
        myCircleSprite8.name = @"circlesprite" ;
        myCircleSprite9.name = @"circlesprite" ;
        myCircleSprite10.name = @"circlesprite" ;
        myCircleSprite11.name = @"circlesprite" ;
        myCircleSprite12.name = @"circlesprite" ;
        myCircleSprite13.name = @"circlesprite" ;
        myCircleSprite14.name = @"circlesprite" ;
        myCircleSprite15.name = @"circlesprite" ;
        
        
        myCircleSprite1.physicsBody.linearDamping = myCircleSpriteDamping;
        myCircleSprite2.physicsBody.linearDamping = myCircleSpriteDamping;
        myCircleSprite3.physicsBody.linearDamping = myCircleSpriteDamping;
        myCircleSprite4.physicsBody.linearDamping = myCircleSpriteDamping;
        myCircleSprite5.physicsBody.linearDamping = myCircleSpriteDamping;
        myCircleSprite6.physicsBody.linearDamping = myCircleSpriteDamping;
        myCircleSprite7.physicsBody.linearDamping = myCircleSpriteDamping;
        myCircleSprite8.physicsBody.linearDamping = myCircleSpriteDamping;
        myCircleSprite9.physicsBody.linearDamping = myCircleSpriteDamping;
        myCircleSprite10.physicsBody.linearDamping = myCircleSpriteDamping;
        myCircleSprite11.physicsBody.linearDamping = myCircleSpriteDamping;
        myCircleSprite12.physicsBody.linearDamping = myCircleSpriteDamping;
        myCircleSprite13.physicsBody.linearDamping = myCircleSpriteDamping;
        myCircleSprite14.physicsBody.linearDamping = myCircleSpriteDamping;
        myCircleSprite15.physicsBody.linearDamping = myCircleSpriteDamping;

        
        
        
    } // end of loop
}






-(void)myUpSwipeAction
{
    //    NSLog(@"up swipe!");
    // rz make photo sprites larger
    [self enumerateChildNodesWithName:@"photosprite" usingBlock:^(SKNode *node, BOOL *stop) {
        [node setXScale: node.xScale + 0.25];
        [node setYScale: node.yScale + 0.25];
    }];
}

-(void)myDownSwipeAction
{
    //    NSLog(@"down swipe!");
    // rz make photo sprites smaller
    [self enumerateChildNodesWithName:@"photosprite" usingBlock:^(SKNode *node, BOOL *stop) {
        if (node.xScale > 0.5) {
            [node setXScale: node.xScale - 0.25];
            [node setYScale: node.yScale - 0.25];
        }
    }];
}




-(void)myLeftSwipeAction
{
    //    NSLog(@"left swipe!");
}



-(void)myRightSwipeAction
{
    //    NSLog(@"right swipe!");
    [self removeAllChildren];
    [self makeMyInstructionLabels];
}






//- (void)didBeginContact:(SKPhysicsContact *)contact {
//    //NSLog(@"Contact started between %@ and %@", contact.bodyA, contact.bodyB);
//}

- (void)didEndContact:(SKPhysicsContact *)contact {
    
    // circle 3
    // picture 2
    // color 1
    
    
    bool myWait =  NO;
    
    
    SKAction *myBlink = [SKAction sequence:@[
                                             [SKAction fadeInWithDuration:0.01],
                                             [SKAction waitForDuration:0.05],
                                             [SKAction removeFromParent],
                                             ]]  ;
    
    

    
    if ( contact.bodyA.contactTestBitMask == 0x01 ){
        switch (contact.bodyB.contactTestBitMask) {
                //
                //
                // if a color sprite hits
                //
                //
            case 1:
            {
//                NSLog(@"color-color");
                NSString *myPath = [[NSBundle mainBundle] pathForResource:@"myColorSpriteEmitter" ofType:@"sks"];
                
                SKEmitterNode *myNodeAEmitter =  [NSKeyedUnarchiver unarchiveObjectWithFile:myPath];
                SKEmitterNode *myNodeBEmitter =  [NSKeyedUnarchiver unarchiveObjectWithFile:myPath];
                
                [contact.bodyA.node  addChild:myNodeAEmitter];
                [contact.bodyB.node  addChild:myNodeBEmitter];
                [myNodeAEmitter runAction: myBlink ];
                // rz a color sprite hits a color sprite
                [contact.bodyA.node  runAction:[SKAction scaleBy:1.01 duration:0.5]];
                [contact.bodyB.node  runAction:[SKAction scaleBy:1.01 duration:0.5]];
                [self runAction:[SKAction playSoundFileNamed:@"marimba.m4a" waitForCompletion:myWait]];
                
            }
                break;
            case 2:
                // rz a color sprite hits a circle sprite
                [self runAction:[SKAction playSoundFileNamed:@"cymbalhit.m4a" waitForCompletion:myWait]];
                break;
            case 4:
            {
//                NSLog(@"color-flooor");
                // rz a color sprite hits the floor
                NSString *myPath = [[NSBundle mainBundle] pathForResource:@"myTextureEmitter" ofType:@"sks"];
                SKEmitterNode *myNodeAEmitter =  [NSKeyedUnarchiver unarchiveObjectWithFile:myPath];
                [contact.bodyA.node  addChild:myNodeAEmitter];
                [myNodeAEmitter runAction: myBlink ];
                [contact.bodyA.node  runAction:[SKAction scaleBy:2.01 duration:0.5]];
                [self runAction:[SKAction playSoundFileNamed:@"snare.m4a" waitForCompletion:myWait]];
                
            }
                // rz a color hits the floor
                //
                break;
            default:
                break;
        }
    }
    
    
    
    
    
    if (contact.bodyA.contactTestBitMask == 0x02 ){
        //
        //
        //
        // if a picture sprite hits
        //
        
        
        switch (contact.bodyB.contactTestBitMask) {
            case 2:
            {
                //
                // picture - picture contact
                //
                SKAction *myPictureAction =  [SKAction sequence:@[
                                                          [SKAction waitForDuration:30.0 withRange:2.5],
                                                          [SKAction removeFromParent],
                                                          ]];
                NSString *myPath = [[NSBundle mainBundle] pathForResource:@"myParticle" ofType:@"sks"];
                
                SKEmitterNode *myNodeAEmitter =  [NSKeyedUnarchiver unarchiveObjectWithFile:myPath];
                SKEmitterNode *myNodeBEmitter =  [NSKeyedUnarchiver unarchiveObjectWithFile:myPath];
          
                [contact.bodyA.node  addChild:myNodeAEmitter];
                [contact.bodyB.node  addChild:myNodeBEmitter];
                [contact.bodyA.node runAction: myPictureAction];
                [contact.bodyB.node runAction: myPictureAction];
                [myNodeAEmitter setAlpha:0.0];
                [myNodeBEmitter setAlpha:0.0];
                [myNodeAEmitter runAction: myBlink ];
                [myNodeBEmitter runAction: myBlink ];
                
                [contact.bodyA.node   runAction:[SKAction scaleBy:0.999 duration:0.5]];
                [contact.bodyB.node   runAction:[SKAction scaleBy:0.999 duration:0.5]];
                [self runAction:[SKAction playSoundFileNamed:@"snare.m4a" waitForCompletion:myWait]];
            }
                break;
            case 3:
                // rz an image sprite hits a dropped sprite
                [self runAction:[SKAction playSoundFileNamed:@"cymbalhit.m4a" waitForCompletion:myWait]];
                break;
            case 4:
                [self runAction:[SKAction playSoundFileNamed:@"crash.m4a" waitForCompletion:myWait]];
                break;
            default:
                break;
        }
    }
    
    
    
    
    if (contact.bodyA.contactTestBitMask == 0x03 ){
        //
        //
        //
        // if a texture sprite hits
        //
        switch (contact.bodyB.contactTestBitMask) {
            case 0x2:
            {
                //
                // texture - picture contact
                //
                [contact.bodyA.node   runAction:[SKAction scaleBy:0.99 duration:0.5]];
                [contact.bodyB.node   runAction:[SKAction scaleBy:0.99 duration:0.5]];
                [self runAction:[SKAction playSoundFileNamed:@"ding.m4a" waitForCompletion:myWait]];
                
            }
                break;
            case 0x3:
            {
                
//                NSLog(@"texture-texture");
                //
                //
                //
                //
                //  can't put an emitter on a texture, add a new sprite to receive the emitter
                //
                //
                //
                SKSpriteNode *myBodyAEmitterSprite = [SKSpriteNode spriteNodeWithColor:[UIColor clearColor] size:CGSizeMake(1.0, 1.0)];
                SKSpriteNode *myBodyBEmitterSprite = [SKSpriteNode spriteNodeWithColor:[UIColor clearColor] size:CGSizeMake(1.0, 1.0)];
                
                
                SKAction *myTextureAction =  [SKAction sequence:@[
                                                                  [SKAction waitForDuration:15.0 withRange:2.5],
                                                                  [SKAction removeFromParent],
                                                                  ]];
//                NSString *myPath = [[NSBundle mainBundle] pathForResource:@"myTextureSpriteEmitter" ofType:@"sks"];
                NSString *myPath = [[NSBundle mainBundle] pathForResource:@"mySnowEmitter" ofType:@"sks"];
                
                SKEmitterNode *myNodeAEmitter =  [NSKeyedUnarchiver unarchiveObjectWithFile:myPath];
                SKEmitterNode *myNodeBEmitter =  [NSKeyedUnarchiver unarchiveObjectWithFile:myPath];
                
                [myBodyAEmitterSprite setPosition:contact.bodyA.node.position];
                [myBodyBEmitterSprite setPosition:contact.bodyB.node.position];
                
                
                
                [myBodyAEmitterSprite  addChild:myNodeAEmitter];
                [myBodyBEmitterSprite  addChild:myNodeBEmitter];
                
                [self addChild:myBodyAEmitterSprite];
                [self addChild:myBodyBEmitterSprite];
                
//                [contact.bodyA.node runAction: myPictureAction];
//                [contact.bodyB.node runAction: myPictureAction];
                
                [myBodyAEmitterSprite  runAction: myTextureAction];
                [myBodyBEmitterSprite  runAction: myTextureAction];
                
                [myNodeAEmitter setAlpha:0.0];
                [myNodeBEmitter setAlpha:0.0];
                
                //            [myExitEmitter setScale:10];
                [myNodeAEmitter runAction: myBlink ];
                [myNodeBEmitter runAction: myBlink ];
                
                
                [contact.bodyA.node   runAction:[SKAction scaleBy:0.999 duration:1.5]];
                [contact.bodyB.node   runAction:[SKAction scaleBy:0.999 duration:1.5]];
                [self runAction:[SKAction playSoundFileNamed:@"tick.m4a" waitForCompletion:myWait]];

//                [self runAction:[SKAction playSoundFileNamed:@"crash.m4a" waitForCompletion:myWait]];
            }
                break;
                // rz a texture sprite hits the wall
            case 0x4:
                [self runAction:[SKAction playSoundFileNamed:@"ow.m4a" waitForCompletion:myWait]];
                break;
            default:
                break;
        }
    }
    
    
    
}

@end






