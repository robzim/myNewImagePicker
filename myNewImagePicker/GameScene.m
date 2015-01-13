//
//  GameScene.m
//  eyeCandy
//
//  Created by Robert Zimmelman on 11/10/14.
//  Copyright (c) 2014 Robert Zimmelman. All rights reserved.
//

int myCounter = 0;
int myLoops = 2;
int myMassMult = 1;
int myYOffset = 30;
int myColorSpriteLoops = 3;
float myRestitution = .9;
float myScale = .1;

#import "GameScene.h"



@implementation GameScene
@synthesize mySpriteImage1, mySpriteImage2, mySpriteImage3, mySpriteImage4, mySpriteImage5;

- (void)didBeginContact:(SKPhysicsContact *)contact {
        //NSLog(@"Contact started between %@ and %@", contact.bodyA, contact.bodyB);
}

- (void)didEndContact:(SKPhysicsContact *)contact {
    
        
        bool myWait =  YES;
        
        if ( contact.bodyA.contactTestBitMask == 0x1 ){
            switch (contact.bodyB.contactTestBitMask) {
                                        case 1:
                                            // rz a dropped sprite hits another dropped sprite
                                            [self runAction:[SKAction playSoundFileNamed:@"hit.m4a" waitForCompletion:myWait]];
                                            break;
                case 2:
                    // rz a dropped sprite hits another dropped sprite
                    [self runAction:[SKAction playSoundFileNamed:@"cymbalhit.m4a" waitForCompletion:myWait]];
                    break;
                case 4:
                    [self runAction:[SKAction playSoundFileNamed:@"boom.m4a" waitForCompletion:myWait]];
                    break;
                default:
                    break;
            }
        }
        if (contact.bodyA.contactTestBitMask == 0x2 ){
            switch (contact.bodyB.contactTestBitMask) {
                case 2:
                    [self runAction:[SKAction playSoundFileNamed:@"ow.m4a" waitForCompletion:myWait]];
                    break;
                case 3:
                    // rz an image sprite hits a dropped sprite
                    [self runAction:[SKAction playSoundFileNamed:@"crash.m4a" waitForCompletion:myWait]];
                    break;
                case 4:
                    [self runAction:[SKAction playSoundFileNamed:@"hit.m4a" waitForCompletion:myWait]];
                    break;
                default:
                    break;
            }
        }
}


-(void)didMoveToView:(SKView *)view {
    [self runAction:[SKAction repeatActionForever:[SKAction playSoundFileNamed:@"BG Music.m4a" waitForCompletion:YES]]];
    /* Setup your scene here */
    NSArray *myControlValues  = [[ NSArray alloc] initWithObjects:@"DZ",@"MZ",@"AZ", @"CZ" , @"RZ", @"Spray", @"Quit", nil] ;
    
    UISegmentedControl *myControl = [[ UISegmentedControl alloc] initWithItems:myControlValues ];
//    UISegmentedControl *myControl = [[ UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:mySpriteImage1, mySpriteImage2, mySpriteImage3, mySpriteImage4, mySpriteImage5, nil]];

    int myWidth = 50;
    
    [myControl setFrame:CGRectMake(20, 20 , 290 , 50)];
    [myControl setWidth:(myWidth) forSegmentAtIndex:0];
    [myControl addTarget:self action:@selector(mySwitchChanged:) forControlEvents:UIControlEventValueChanged ];
    [myControl setSelectedSegmentIndex:-1];
    [self.view addSubview:myControl];
    self.physicsWorld.contactDelegate = self;
    //
    //  set up the physics body so the sprites don't fall through the bottom
    //
    self.physicsBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:self.frame];
    //
    // rz set up the labels describing the scene
    //
    [self myLabels];
    [self runAction:[SKAction playSoundFileNamed:@"BG Music.m4a" waitForCompletion:YES]];
    //
}

-(void)myLabels{
    SKLabelNode *myLabel = [SKLabelNode labelNodeWithFontNamed:@"Helvetica"];
    myLabel.text = @"eyeCandy! Tap for Little Nuggets made from Pictures that will expand";
    SKLabelNode *my2ndLabel = [SKLabelNode labelNodeWithFontNamed:@"Helvetica"];
    my2ndLabel.text = @"and kick each other around.  Enter Background to Exit the Program";
    myLabel.fontSize = my2ndLabel.fontSize = 12;
    myLabel.horizontalAlignmentMode = my2ndLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeCenter;
    myLabel.position = CGPointMake(CGRectGetMidX(self.frame),
                                   CGRectGetMidY(self.frame));
    my2ndLabel.position = CGPointMake(CGRectGetMidX(self.frame),
                                      CGRectGetMidY(self.frame) - 20);
    [myLabel runAction:[SKAction sequence:@[[SKAction waitForDuration:5.0],
                                            [SKAction removeFromParent],]]];
    [my2ndLabel runAction:[SKAction sequence:@[ [SKAction waitForDuration:5.0],
                                                [SKAction removeFromParent],
                                                ]]];
    //    NSLog(@"ready to add the labels");
    [self addChild:myLabel];
    [self addChild:my2ndLabel];
    

}


- (IBAction)mySwitchChanged:(UISegmentedControl *)sender{
    long myValue = sender.selectedSegmentIndex;
    //NSLog(@"Value = %ld",myValue);
    
    SKAction *myImageSpriteAction =    [SKAction sequence:@[
                                                            [SKAction waitForDuration:10.0 withRange:1.5],
                                                            [SKAction removeFromParent],
                                                            ]];
    switch (myValue) {
        case 0: {
            SKSpriteNode *myImageSprite1 = [ SKSpriteNode spriteNodeWithImageNamed:@"Danny"];
            myImageSprite1.position = CGPointMake(CGRectGetMidX(self.frame) - 100, CGRectGetMaxY(self.frame) - myYOffset );
            [myImageSprite1 setScale: myScale];
            myImageSprite1.physicsBody = [ SKPhysicsBody bodyWithRectangleOfSize:myImageSprite1.size];
            myImageSprite1.physicsBody.restitution = 0.94;
            myImageSprite1.physicsBody.contactTestBitMask = 0x02;
            [myImageSprite1.physicsBody setMass:100.0];
            [myImageSprite1 runAction:myImageSpriteAction];
            [self addChild:myImageSprite1];
            break;
        }
        case 1: {
            SKSpriteNode *myImageSprite2 = [ SKSpriteNode spriteNodeWithImageNamed:@"Mike"];
            myImageSprite2.position = CGPointMake(CGRectGetMidX(self.frame) - 50, CGRectGetMaxY(self.frame) - myYOffset );
            [myImageSprite2 setScale: myScale];
            myImageSprite2.physicsBody = [ SKPhysicsBody bodyWithRectangleOfSize:myImageSprite2.size];
            myImageSprite2.physicsBody.restitution = 0.94;
            myImageSprite2.physicsBody.contactTestBitMask = 0x02;
            [myImageSprite2.physicsBody setMass:100.0];
            [myImageSprite2 runAction:myImageSpriteAction];
            [self addChild:myImageSprite2];
            break;
        }
        case 2: {
            SKSpriteNode *myImageSprite3 = [ SKSpriteNode spriteNodeWithImageNamed:@"Andy"];
            myImageSprite3.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMaxY(self.frame) - myYOffset );
            [myImageSprite3 setScale: myScale];
            myImageSprite3.physicsBody = [ SKPhysicsBody bodyWithRectangleOfSize:myImageSprite3.size];
            myImageSprite3.physicsBody.restitution = 0.94;
            myImageSprite3.physicsBody.contactTestBitMask = 0x02;
            [myImageSprite3.physicsBody setMass:100.0];
            [myImageSprite3 runAction:myImageSpriteAction];
            [self addChild:myImageSprite3];
            break;
        }
        case 3: {
            SKSpriteNode *myImageSprite4 = [ SKSpriteNode spriteNodeWithImageNamed:@"Cindy"];
            myImageSprite4.position = CGPointMake(CGRectGetMidX(self.frame) + 50, CGRectGetMaxY(self.frame) - myYOffset );
            [myImageSprite4 setScale: myScale];
            myImageSprite4.physicsBody = [ SKPhysicsBody bodyWithRectangleOfSize:myImageSprite4.size];
            myImageSprite4.physicsBody.restitution = 0.94;
            myImageSprite4.physicsBody.contactTestBitMask = 0x02;
            [myImageSprite4.physicsBody setMass:100.0];
            [myImageSprite4 runAction:myImageSpriteAction];
            [self addChild:myImageSprite4];
            break;
        }
        case 4: {
            SKSpriteNode *myImageSprite5 = [ SKSpriteNode spriteNodeWithImageNamed:@"Dad"];
            myImageSprite5.position = CGPointMake(CGRectGetMidX(self.frame) + 100, CGRectGetMaxY(self.frame) - myYOffset );
            [myImageSprite5 setScale: myScale];
            myImageSprite5.physicsBody = [ SKPhysicsBody bodyWithRectangleOfSize:myImageSprite5.size];
            myImageSprite5.physicsBody.restitution = 0.94;
            myImageSprite5.physicsBody.contactTestBitMask = 0x02;
            [myImageSprite5.physicsBody setMass:100.0];
            [myImageSprite5 runAction:myImageSpriteAction];
            [self addChild:myImageSprite5];
            break;
        }
        case 5:
            [self mySpray];
            break;
            case 6:
            exit(0);
        default:
            break;
    }
    [sender setSelectedSegmentIndex:-1];
}


-(void)mySpray{
    NSInteger myColorSpriteSize = 10;
    for ( int i = 1 ; i < myColorSpriteLoops ; i++){
        SKSpriteNode *colorsprite1 = [SKSpriteNode spriteNodeWithColor:[UIColor redColor] size:CGSizeMake(myColorSpriteSize, myColorSpriteSize)  ];
        SKSpriteNode *colorsprite2 = [SKSpriteNode spriteNodeWithColor:[UIColor blackColor] size:CGSizeMake(myColorSpriteSize, myColorSpriteSize)  ];      // 0.0 white
        SKSpriteNode *colorsprite3 = [SKSpriteNode spriteNodeWithColor:[UIColor darkGrayColor] size:CGSizeMake(myColorSpriteSize, myColorSpriteSize)  ];   // 0.333 white
        SKSpriteNode *colorsprite4 = [SKSpriteNode spriteNodeWithColor:[UIColor lightGrayColor] size:CGSizeMake(myColorSpriteSize, myColorSpriteSize)  ];  // 0.667 white
        SKSpriteNode *colorsprite5 = [SKSpriteNode spriteNodeWithColor:[UIColor whiteColor] size:CGSizeMake(myColorSpriteSize, myColorSpriteSize)  ];      // 1.0 white
        SKSpriteNode *colorsprite6 = [SKSpriteNode spriteNodeWithColor:[UIColor grayColor] size:CGSizeMake(myColorSpriteSize, myColorSpriteSize)  ];       // 0.5 white
        SKSpriteNode *colorsprite7 = [SKSpriteNode spriteNodeWithColor:[UIColor redColor] size:CGSizeMake(myColorSpriteSize, myColorSpriteSize)  ];        // 1.0, 0.0, 0.0 RGB
        SKSpriteNode *colorsprite8 = [SKSpriteNode spriteNodeWithColor:[UIColor greenColor] size:CGSizeMake(myColorSpriteSize, myColorSpriteSize)  ];      // 0.0, 1.0, 0.0 RGB
        SKSpriteNode *colorsprite9 = [SKSpriteNode spriteNodeWithColor:[UIColor blueColor] size:CGSizeMake(myColorSpriteSize, myColorSpriteSize)  ];       // 0.0, 0.0, 1.0 RGB
        SKSpriteNode *colorsprite10 = [SKSpriteNode spriteNodeWithColor:[UIColor cyanColor] size:CGSizeMake(myColorSpriteSize, myColorSpriteSize)  ];       // 0.0, 1.0, 1.0 RGB
        SKSpriteNode *colorsprite11 = [SKSpriteNode spriteNodeWithColor:[UIColor yellowColor] size:CGSizeMake(myColorSpriteSize, myColorSpriteSize)  ];     // 1.0, 1.0, 0.0 RGB
        SKSpriteNode *colorsprite12 = [SKSpriteNode spriteNodeWithColor:[UIColor magentaColor] size:CGSizeMake(myColorSpriteSize, myColorSpriteSize)  ];    // 1.0, 0.0, 1.0 RGB
        SKSpriteNode *colorsprite13 = [SKSpriteNode spriteNodeWithColor:[UIColor orangeColor] size:CGSizeMake(myColorSpriteSize, myColorSpriteSize)  ];     // 1.0, 0.5, 0.0 RGB
        SKSpriteNode *colorsprite14 = [SKSpriteNode spriteNodeWithColor:[UIColor purpleColor] size:CGSizeMake(myColorSpriteSize, myColorSpriteSize)  ];     // 0.5, 0.0, 0.5 RGB
        SKSpriteNode *colorsprite15 = [SKSpriteNode spriteNodeWithColor:[UIColor brownColor] size:CGSizeMake(myColorSpriteSize, myColorSpriteSize)  ];      // 0.6, 0.4, 0.2 RGB
        
        
        
        
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
        
        
        colorsprite1.physicsBody = [ SKPhysicsBody bodyWithRectangleOfSize:colorsprite1.size];
        colorsprite2.physicsBody = [ SKPhysicsBody bodyWithRectangleOfSize:colorsprite2.size];
        colorsprite3.physicsBody = [ SKPhysicsBody bodyWithRectangleOfSize:colorsprite3.size];
        colorsprite4.physicsBody = [ SKPhysicsBody bodyWithRectangleOfSize:colorsprite4.size];
        colorsprite5.physicsBody = [ SKPhysicsBody bodyWithRectangleOfSize:colorsprite5.size];
        colorsprite6.physicsBody = [ SKPhysicsBody bodyWithRectangleOfSize:colorsprite6.size];
        colorsprite7.physicsBody = [ SKPhysicsBody bodyWithRectangleOfSize:colorsprite7.size];
        colorsprite8.physicsBody = [ SKPhysicsBody bodyWithRectangleOfSize:colorsprite8.size];
        colorsprite9.physicsBody = [ SKPhysicsBody bodyWithRectangleOfSize:colorsprite9.size];
        colorsprite10.physicsBody = [ SKPhysicsBody bodyWithRectangleOfSize:colorsprite10.size];
        colorsprite11.physicsBody = [ SKPhysicsBody bodyWithRectangleOfSize:colorsprite11.size];
        colorsprite12.physicsBody = [ SKPhysicsBody bodyWithRectangleOfSize:colorsprite12.size];
        colorsprite13.physicsBody = [ SKPhysicsBody bodyWithRectangleOfSize:colorsprite13.size];
        colorsprite14.physicsBody = [ SKPhysicsBody bodyWithRectangleOfSize:colorsprite14.size];
        colorsprite15.physicsBody = [ SKPhysicsBody bodyWithRectangleOfSize:colorsprite15.size];
        
        
        colorsprite1.physicsBody.affectedByGravity =
        colorsprite2.physicsBody.affectedByGravity =
        colorsprite3.physicsBody.affectedByGravity =
        colorsprite4.physicsBody.affectedByGravity =
        colorsprite5.physicsBody.affectedByGravity =
        colorsprite6.physicsBody.affectedByGravity =
        colorsprite7.physicsBody.affectedByGravity =
        colorsprite8.physicsBody.affectedByGravity =
        colorsprite9.physicsBody.affectedByGravity =
        colorsprite10.physicsBody.affectedByGravity =
        colorsprite11.physicsBody.affectedByGravity =
        colorsprite12.physicsBody.affectedByGravity =
        colorsprite13.physicsBody.affectedByGravity =
        colorsprite14.physicsBody.affectedByGravity =
        colorsprite15.physicsBody.affectedByGravity =
        YES;
        
        colorsprite1.physicsBody.restitution =
        colorsprite2.physicsBody.restitution =
        colorsprite3.physicsBody.restitution =
        colorsprite4.physicsBody.restitution =
        colorsprite5.physicsBody.restitution =
        colorsprite6.physicsBody.restitution =
        colorsprite7.physicsBody.restitution =
        colorsprite8.physicsBody.restitution =
        colorsprite9.physicsBody.restitution =
        colorsprite10.physicsBody.restitution =
        colorsprite11.physicsBody.restitution =
        colorsprite12.physicsBody.restitution =
        colorsprite13.physicsBody.restitution =
        colorsprite14.physicsBody.restitution =
        colorsprite15.physicsBody.restitution = 1.5;
        
        colorsprite1.blendMode = SKBlendModeReplace;
        colorsprite2.blendMode = SKBlendModeReplace ;
        colorsprite3.blendMode = SKBlendModeReplace ;
        colorsprite4.blendMode = SKBlendModeReplace ;
        colorsprite5.blendMode = SKBlendModeReplace ;
        colorsprite6.blendMode = SKBlendModeReplace ;
        colorsprite7.blendMode = SKBlendModeReplace ;
        colorsprite8.blendMode = SKBlendModeReplace ;
        colorsprite9.blendMode = SKBlendModeReplace ;
        colorsprite10.blendMode = SKBlendModeReplace ;
        colorsprite11.blendMode = SKBlendModeReplace ;
        colorsprite12.blendMode = SKBlendModeReplace ;
        colorsprite13.blendMode = SKBlendModeReplace ;
        colorsprite14.blendMode = SKBlendModeReplace ;
        colorsprite15.blendMode = SKBlendModeReplace ;
        
        
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
        
        
        
        colorsprite1.physicsBody.contactTestBitMask = 0x03;
        colorsprite2.physicsBody.contactTestBitMask = 0x03;
        colorsprite3.physicsBody.contactTestBitMask = 0x03;
        colorsprite4.physicsBody.contactTestBitMask = 0x03;
        colorsprite5.physicsBody.contactTestBitMask = 0x03;
        colorsprite6.physicsBody.contactTestBitMask = 0x03;
        colorsprite7.physicsBody.contactTestBitMask = 0x03;
        colorsprite8.physicsBody.contactTestBitMask = 0x03;
        colorsprite9.physicsBody.contactTestBitMask = 0x03;
        colorsprite10.physicsBody.contactTestBitMask = 0x03;
        colorsprite11.physicsBody.contactTestBitMask = 0x03;
        colorsprite12.physicsBody.contactTestBitMask = 0x03;
        colorsprite13.physicsBody.contactTestBitMask = 0x03;
        colorsprite14.physicsBody.contactTestBitMask = 0x03;
        colorsprite15.physicsBody.contactTestBitMask = 0x03 ;
        
        
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
        
        
        SKAction *mycolorSpriteAction =    [SKAction sequence:@[
                                                                [SKAction rotateByAngle:( M_PI ) duration:1],
                                                                [SKAction waitForDuration:5.0 withRange:1.5],
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
    }
}


-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    /* Called when a touch begins */
    NSString *myPath = [[NSBundle mainBundle] pathForResource:@"myParticle" ofType:@"sks"];
    //
    SKSpriteNode *sprite = [SKSpriteNode spriteNodeWithTexture:[ SKTexture textureWithImage:mySpriteImage1]];
    for (UITouch *touch in touches) {
        CGPoint location = [touch locationInNode:self];
        for (int myLoopCount = 1 ; myLoopCount < myLoops ; myLoopCount++) {
            for (int myI = 1; myI <=5 ; myI++) {
                switch (myI) {
                    case 1:
                        sprite = [SKSpriteNode spriteNodeWithTexture:[ SKTexture textureWithImage:mySpriteImage1]];
                        break;
                    case 2:
                        sprite = [SKSpriteNode spriteNodeWithTexture:[ SKTexture textureWithImage:mySpriteImage2]];
                        break;
                    case 3:
                        sprite = [SKSpriteNode spriteNodeWithTexture:[ SKTexture textureWithImage:mySpriteImage3]];
                        break;
                    case 4:
                        sprite = [SKSpriteNode spriteNodeWithTexture:[ SKTexture textureWithImage:mySpriteImage4]];
                        break;
                    case 5:
                        sprite = [SKSpriteNode spriteNodeWithTexture:[ SKTexture textureWithImage:mySpriteImage5]];
                        break;
                    default:
                        break;
                }
                sprite.position = location;
                sprite.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:sprite.size];
                sprite.physicsBody.mass = myMassMult ; // make them heavy if we want to
                sprite.physicsBody.restitution = myRestitution;
                CGSize mySpriteSize = sprite.size;
//                NSLog(@"X = %f  Y = %f", mySpriteSize.width, mySpriteSize.height);
                if (mySpriteSize.width > 320) {
                    sprite.xScale = sprite.yScale = (myScale / 4) ;
                }
                else {
                    sprite.xScale = sprite.yScale = (myScale / 2) ;
                }
                sprite.physicsBody.contactTestBitMask = 0x1;
                [sprite runAction:
                 [SKAction sequence:@[
                                      [SKAction waitForDuration:15.0],
                                      [SKAction removeFromParent],
                                      ]]  ];
                [self addChild:sprite];
                SKEmitterNode *myExitEmitter =  [NSKeyedUnarchiver unarchiveObjectWithFile:myPath];
                [myExitEmitter setScale:.1];
                [myExitEmitter runAction:[SKAction sequence:@[
                                                              [SKAction fadeInWithDuration:(NSTimeInterval) 2.5],
                                                              [SKAction fadeOutWithDuration:(NSTimeInterval) 2.5],
                                                              [SKAction removeFromParent],
                                                              ]]];
                [sprite addChild:myExitEmitter];
            } // end of loopcount
        }
    } // end of touches loop
}



-(void)update:(CFTimeInterval)currentTime {
    /* Called before each frame is rendered */
}

-(void)didSimulatePhysics{
//    NSLog(@"count = %d",self.children.count);
    if ( self.children.count > 600) {
        [self enumerateChildNodesWithName:@"colorsprite" usingBlock:^(SKNode *node, BOOL *stop) {
            [node removeFromParent];
        }];
    }

    
}

@end
