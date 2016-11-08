//
//  GameScene.m
//  eyeCandy
//
//  Created by Robert Zimmelman on 11/10/14.
//  Copyright (c) 2016 Robert Zimmelman. All rights reserved.
//
#import "GameScene.h"

int myButtonWidth = 30;
int myCounter = 0;
int myFiveSpriteLoops = 1;
int myMassMult = 1;
int myYOffset = 30;
float myImageSpriteDamping = 0.0;

float myRestitution = 0.5;

vector_float2 mySourceVector;
vector_float2 myDestVector;


float myImageSpriteMass = 0.5;
float myImageSpriteRestitution = 0.9;
float myImageSpriteSize = 100;
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
float myCircleSpriteRestitution = 1.01;
int myCircleSpriteLoops = 3;


dispatch_queue_t myDispatchQueue;
dispatch_queue_t myColorQueue;



@implementation GameScene{
    NSString *deviceType;
    NSString *myPhoneModel;
    
    UIImpactFeedbackGenerator *myHeavyImpactFeedbackGenerator;
    UIImpactFeedbackGenerator *myMediumImpactFeedbackGenerator;
    UIImpactFeedbackGenerator *myLightImpactFeedbackGenerator;
    UISelectionFeedbackGenerator *myUISelectionFeedbackGenerator;
    UINotificationFeedbackGenerator *myNotificationFeedbackGenerator;
    
}
@synthesize mySpriteImage1, mySpriteImage2, mySpriteImage3, mySpriteImage4, mySpriteImage5;
@synthesize myImageSprite1, myImageSprite2, myImageSprite3, myImageSprite4, myImageSprite5;

@synthesize myImageSpriteAction;
@synthesize myBG;
@synthesize myQueue;
@synthesize myScore;
@synthesize myHighScore;
@synthesize mySnowParticle;

@synthesize myTimeSinceLastFrame;
@synthesize myLastTimeSample;

-(void)update:(NSTimeInterval)currentTime{
    myTimeSinceLastFrame = currentTime - myLastTimeSample;
    myLastTimeSample = currentTime;
    if (myTimeSinceLastFrame > 0.3) {
        NSLog(@"REMOVING - Slow");
        [self removeAllChildren];
        [self setPhysicsBody:[SKPhysicsBody bodyWithEdgeLoopFromRect:self.frame]];
    }
}






-(void)myDropPictures{
    int myPic = (arc4random()%5)+1;
    NSLog(@"Picure %d, TimeSinceLastFrame %f",myPic,myTimeSinceLastFrame);
    switch (myPic) {
        case 1:
        {
            [self myDropPicture1];
        }
            break;
        case 2:
        {
            [self myDropPicture2];
        }
            break;
        case 3:
        {
            [self myDropPicture3];
        }
            break;
        case 4:
        {
            [self myDropPicture4];
        }
            break;
        case 5:
        {
            [self myDropPicture5];
        }
            break;
        default:
            break;
    }
}



-(void)didMoveToView:(SKView *)view {

    myHeavyImpactFeedbackGenerator = [[UIImpactFeedbackGenerator alloc] initWithStyle:UIImpactFeedbackStyleHeavy];
    myMediumImpactFeedbackGenerator = [[UIImpactFeedbackGenerator alloc] initWithStyle:UIImpactFeedbackStyleMedium];
    myLightImpactFeedbackGenerator = [[UIImpactFeedbackGenerator alloc] initWithStyle:UIImpactFeedbackStyleLight];
    myUISelectionFeedbackGenerator = [[UISelectionFeedbackGenerator alloc] init];
    myNotificationFeedbackGenerator = [[UINotificationFeedbackGenerator alloc] init];
//    CGFloat w = (self.size.width + self.size.height) * 0.05;

    myImageSpriteSize = (self.size.width + self.size.height) * 0.08;
    
    struct utsname systemInfo;
    uname(&systemInfo);
    NSString *myTempDeviceType = [NSString stringWithCString:systemInfo.machine
                                                    encoding:NSUTF8StringEncoding];
    if (myTempDeviceType.length >= 7) {
        deviceType = [NSString stringWithString: [myTempDeviceType substringWithRange:NSMakeRange(0, 7)]];
    } else {
        deviceType = [NSString stringWithString: [myTempDeviceType substringWithRange:NSMakeRange(1, myTempDeviceType.length-1)]];
    }
    NSLog(@"Device is %@",deviceType);
    
    
    [self runAction: [SKAction sequence:@[
                                          [SKAction runBlock:^{
        [myNotificationFeedbackGenerator notificationOccurred:UINotificationFeedbackTypeSuccess];
    }],
                                          [SKAction waitForDuration:0.75],
                                          [SKAction customActionWithDuration:0.1 actionBlock:^(SKNode * _Nonnull node, CGFloat elapsedTime) {
        AudioServicesPlayAlertSound(kSystemSoundID_Vibrate);
    }],
                                          [SKAction waitForDuration:0.5],
                                          [SKAction customActionWithDuration:0.1 actionBlock:^(SKNode * _Nonnull node, CGFloat elapsedTime) {
        AudioServicesPlayAlertSound(kSystemSoundID_Vibrate);
    }],
                                          [SKAction waitForDuration:0.5],
                                          [SKAction customActionWithDuration:0.1 actionBlock:^(SKNode * _Nonnull node, CGFloat elapsedTime) {
        AudioServicesPlayAlertSound(kSystemSoundID_Vibrate);
    }],
                                          
                                          ]] ];
    
    
    
    //    mySlowMotionMode = FALSE;
    //    myLeaderboardID = @"org.zimmelman.flick_at_photos_high_scores";
    myQueue = [NSOperationQueue mainQueue];
    myScore = 0;
    //    [self myMakeScoreLabels];
    [NSTimer scheduledTimerWithTimeInterval:3.0 target:self selector:@selector(myDropPictures) userInfo:nil repeats:YES];
    mySourceVector = vector2(2.0f, 2.0f);
    myDestVector = vector2(2.0f, 2.0f);
        NSString *mySnowParticlePath = [[NSBundle mainBundle] pathForResource:@"mySnowEmitter" ofType:@"sks"];
        mySnowParticle =  [NSKeyedUnarchiver unarchiveObjectWithFile:mySnowParticlePath];
    //
    myDispatchQueue = dispatch_queue_create("myqueue", DISPATCH_QUEUE_CONCURRENT);
    myColorQueue = dispatch_queue_create("mycolorqueue", DISPATCH_QUEUE_CONCURRENT);
    
    [self myMakeIntroLabels];
    //        [self makeMyInstructionLabels];
    
    // rz set the gravity to be light
    
    [self.physicsWorld setGravity:CGVectorMake(0.0, -0.5)];
    [self setBackgroundColor:[UIColor blackColor]];
    [self.view setIgnoresSiblingOrder:YES];
    self.physicsBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:self.frame];
    //
    //  contact 0x04 is the edge of the scene
    self.physicsBody.contactTestBitMask = 0x04;
    self.physicsWorld.contactDelegate = self;
    //
}

-(void)myMakeIntroLabels{
    SKLabelNode *myHoldOnLabel = [SKLabelNode labelNodeWithFontNamed:@"Helvetica"];
    myHoldOnLabel.position = CGPointMake(CGRectGetMidX(self.frame),
                                   CGRectGetMidY(self.frame) + 100 );
    [myHoldOnLabel setZPosition:20.0];
    myHoldOnLabel.text = @"Hold On...";
    [self addChild:myHoldOnLabel];
    [myHoldOnLabel runAction:[SKAction sequence:@[
                                                  [SKAction waitForDuration:3.0],
                                                  [SKAction group:@[
                                                                    [SKAction fadeAlphaTo:0.1 duration:1.0],
                                                                    [SKAction scaleTo:0.1 duration:1.0],
                                                                    ]],
                                                  [SKAction removeFromParent],
                                                  ]]];
    
    
    SKAction *myIntroHelperLabelAction = [SKAction repeatActionForever:[SKAction
                                                                        sequence:@[
                                                                                   [SKAction waitForDuration:3.0],
                                                                                   [SKAction fadeAlphaTo:1.0 duration:1.0],
                                                                                    [SKAction waitForDuration:5.0],
                                                                                    [SKAction fadeAlphaTo:0.0 duration:3.0],
                                                                                    [SKAction waitForDuration:60.0],
                                                                                    ]]];
    SKLabelNode *myLabel = [SKLabelNode labelNodeWithFontNamed:@"Helvetica"];
    myLabel.text = @"Try again with Your Pictures";
    SKLabelNode *my2ndLabel = [SKLabelNode labelNodeWithFontNamed:@"Helvetica"];
    my2ndLabel.text = @"From the Camera or Library!";
    //
    // set the font size proportional to the image sprite size
    myLabel.fontSize = myImageSpriteSize/3.0;
    my2ndLabel.fontSize = myImageSpriteSize/3.0;
    myLabel.horizontalAlignmentMode = my2ndLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeCenter;
    [myLabel setZPosition:20.0];
    [my2ndLabel setZPosition:20.0];
    myLabel.position = CGPointMake(CGRectGetMidX(self.frame),
                                   CGRectGetMidY(self.frame) - 100 );
    my2ndLabel.position = CGPointMake(CGRectGetMidX(self.frame),
                                      CGRectGetMidY(self.frame) - 160);
    [self addChild:myLabel];
    [self addChild:my2ndLabel];
    [myLabel setAlpha:0.0];
    [my2ndLabel setAlpha:0.0];
    [myLabel runAction:myIntroHelperLabelAction];
    [my2ndLabel runAction:myIntroHelperLabelAction];
    
}




- (void)myDropPicture1{
    myImageSprite1 = [SKSpriteNode spriteNodeWithTexture:[ SKTexture textureWithImage:mySpriteImage1]];
    myImageSprite1.position = CGPointMake(CGRectGetMidX(self.frame) - 100, CGRectGetMaxY(self.frame) - myYOffset );
    //            dispatch_async(myColorQueue, ^{
    [myImageSprite1 setSize:CGSizeMake(myImageSpriteSize, myImageSpriteSize)];
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



-(void)myWarpSprite: (SKSpriteNode *) theSprite  {
    int myGridSize = 3;
    vector_float2 myReferenceGrid[myGridSize * myGridSize];
    vector_float2 mySources[myGridSize * myGridSize];
    vector_float2 myDests[myGridSize * myGridSize];
    float myIncrement = 1.0 / myGridSize ;
    float myRandomX;
    float myRandomY;
    int myGridEntry = 0;
    float myGridXValue;
    float myGridYValue;
    float myDestX;
    float myDestY;
    int myRandomDirection;
    for (int myRow = myGridSize  ; myRow > 0 ; myRow-- ) {
        for (int myCol = 0  ; myCol < myGridSize ; myCol++) {
            myRandomDirection = arc4random()%2;
            myRandomX = arc4random()%100;
            myRandomX = (myRandomX / 1000.0) ;
            myRandomY = arc4random()%100;
            myRandomY = (myRandomY / 1000.0) ;
            // put the grid within the picture by offsetting the x and y values by half the increment
            myGridXValue = ((myCol * myIncrement)  + (myIncrement/2.0));
            myGridYValue = ((myRow * myIncrement)  - (myIncrement/2.0));
            myReferenceGrid[myGridEntry] = vector2(myGridXValue, myGridYValue);
            mySources[myGridEntry] = vector2(myGridXValue, myGridYValue);
            myRandomDirection = arc4random()%2;
            if (myRandomDirection == 0) {
                myDestX = myGridXValue + myRandomX;
            } else {
                myDestX = myGridXValue - myRandomX;
            }
            myRandomDirection = arc4random()%2;
            if (myRandomDirection == 0) {
                myDestY = myGridYValue + myRandomY;
            } else {
                myDestY = myGridYValue - myRandomY;
            }
//            NSLog(@"Source Grid Entry %d X %f  Y %f",myGridEntry,myGridXValue,myGridYValue);
//            NSLog(@"Destination Grid Entry %d X %f  Y %f",myGridEntry,myDestX,myDestY);
            myDests[myGridEntry] = vector2(myDestX,myDestY);
            myGridEntry++;
        }
    }
    SKWarpGeometryGrid *myWarpGeometryGrid = [SKWarpGeometryGrid gridWithColumns:myGridSize-1 rows:myGridSize-1 sourcePositions:mySources destPositions:myDests];
    [theSprite setWarpGeometry:myWarpGeometryGrid];
    [theSprite runAction:[SKAction warpTo:myWarpGeometryGrid duration:3.0]];
    
}




- (void)didBeginContact:(SKPhysicsContact *)contact {
    SKNode *firstNode;
    SKNode *secondNode;
//    NSArray *myNodes = [NSArray arrayWithObjects:firstNode, secondNode, nil];
    if (contact.bodyA.node.physicsBody.contactTestBitMask < contact.bodyB.node.physicsBody.contactTestBitMask) {
        firstNode = contact.bodyA.node;
        secondNode = contact.bodyB.node;
    } else {
        firstNode = contact.bodyB.node;
        secondNode = contact.bodyA.node;
    }
    
    // flicked sprite = 0x01
    // photo sprite = 0x02
    //
    // wall = 0x04
    //
    //  photo sprite hits photo sprite
    //
    if (( firstNode.physicsBody.contactTestBitMask == 0x02 ) && ( secondNode.physicsBody.contactTestBitMask == 0x02 )  )   {
        if ([deviceType isEqualToString:@"iPhone9"]) {
            [myMediumImpactFeedbackGenerator impactOccurred];
        }
        
//        if (myScore > 0) {
//            myScore--;
//        }
        int myRandomPhotoPhotoAction = arc4random()%2;
        for (SKNode *theNode in [NSArray arrayWithObjects:firstNode,secondNode, nil]) {
            if (myRandomPhotoPhotoAction == 0) {
                [theNode  runAction:[SKAction sequence:@[
                                                         [SKAction runBlock:^{
                    [self myWarpSprite:(SKSpriteNode *) theNode];
                }],
                                                         [SKAction waitForDuration:5.0],
                                                         
                                                         [SKAction scaleTo:0.1 duration:0.25],
                                                         [SKAction group:(NSArray<SKAction *> *)@[
                                                                                                  [SKAction fadeAlphaTo:0.5 duration:5.0],
                                                                                                  [SKAction scaleTo:1.0 duration:5.0],
                                                                                                  ]],
                                                         // don't remove this because it will eventually
                                                         // get removed when it gets segmented
//                                                         [SKAction removeFromParent],
                                                         ]]];
            } else if (myRandomPhotoPhotoAction == 1){
                [theNode  runAction:[SKAction sequence:@[
                                                         [SKAction runBlock:^{
                    [self myBetterSegmentPhotoAndDrop: (SKSpriteNode *) theNode];
                }],
                                                         [SKAction scaleTo:1.1 duration:0.1],
                                                         [SKAction waitForDuration:0.1],
                                                         [SKAction group:(NSArray<SKAction *> *)@[
                                                                                                  [SKAction fadeAlphaTo:0.1 duration:0.1],
                                                                                                  [SKAction scaleTo:0.1 duration:0.1],
                                                                                                  ]],
                                                         [SKAction removeFromParent],
                                                         ]]];
            }
        }
    }
    //
    //
    // flicked sprite = 0x01
    // photo sprite = 0x02
    //
    // wall = 0x04
    //
    //  if a photo hits the wall
    //
    if((firstNode.physicsBody.contactTestBitMask == 0x02) && (secondNode.physicsBody.contactTestBitMask == 0x04)){
        //
        if ([deviceType isEqualToString:@"iPhone9"]) {
            [myLightImpactFeedbackGenerator impactOccurred];
        }
//        else {
//            AudioServicesPlayAlertSound(kSystemSoundID_Vibrate);
//        }
                SKNode *myS = [mySnowParticle copy];
                [myS setPosition:contact.contactPoint];
                [self addChild:myS];
                [myS runAction:[SKAction sequence:@[[SKAction waitForDuration:0.5],
                                                    [SKAction removeFromParent],]]];
    }
}




-(void)myBetterSegmentPhotoAndDrop: (SKSpriteNode *) thePhoto  {
    if (myTimeSinceLastFrame > 0.2) {
        NSLog(@"Returning Early from Segment --- SLOW");
        return;
    }
    // first grab the texture.  we'll use the texture from here on
    SKTexture *myTexture = [[SKTexture alloc] init];
    myTexture = thePhoto.texture;
    int myRandomMass = arc4random()%10;
    int myRandomGravity = arc4random()%3;
    int myRandomRestitutionSet = arc4random()%2;
    float myRandomRestitution = arc4random()%100;
    myRandomRestitution = (myRandomRestitution/100);
    int myTypeOfDrop = arc4random()%2;
    int myTypeOfSegment = arc4random()%2;
    int myTypeOfColorize = arc4random()%2;
    int myRandomScaleTo = arc4random()%5;
    float myRandomScaleToDuration = arc4random()%100;
    myRandomScaleToDuration = (myRandomScaleToDuration/100.0);
    
    int myRandomFirstWaitFor = arc4random()%9;
    float myRandomSecondWaitFor = arc4random()%10;
    myRandomSecondWaitFor = myRandomSecondWaitFor/10.0;
    float myRandomScaleOutDuration = arc4random()%10;
    myRandomScaleOutDuration = myRandomScaleOutDuration/10.0;
    float myRandomIncrement = arc4random()%20;
    myRandomIncrement = (myRandomIncrement/100.0)+0.1;
    NSLog(@"Mass %d, Drop %d, Increment %f,Segment %d, Colorize %d, 1st Wait %d, Scale %d, Restitution Set %d, Restitution = %f, 2nd Wait %f, Gravity %d, ScaleTo Time %f, ScaleOut Time %f",myRandomMass, myTypeOfDrop, myRandomIncrement, myTypeOfSegment, myTypeOfColorize, myRandomFirstWaitFor, myRandomScaleTo, myRandomRestitutionSet, myRandomRestitution,   myRandomSecondWaitFor, myRandomGravity, myRandomScaleToDuration, myRandomScaleOutDuration);
    CGPoint myPosition = thePhoto.position;
    //    float myIncrement = 0.10;
    float myIncrement = myRandomIncrement;
    CGSize myPhotoSize = CGSizeMake(thePhoto.size.width * myIncrement , thePhoto.size.height * myIncrement  );
    
    //    CGSize myPhotoSize = CGSizeMake(thePhoto.size.width * myIncrement * 2.0, thePhoto.size.height * myIncrement * 2.0 );
    for (float x = 0.0 ; x < 1.0 ; x = x + myIncrement) {
        for (float y = 0.0 ; y < 1.0 ; y = y + myIncrement) {
            SKSpriteNode *mySegment;
            if (myTypeOfSegment == 0 ) {
                mySegment = [SKSpriteNode spriteNodeWithTexture:[SKTexture textureWithRect:CGRectMake(x, y, myIncrement, myIncrement) inTexture:myTexture]];
            } else if (myTypeOfSegment == 1) {
                mySegment = [SKSpriteNode spriteNodeWithTexture:myTexture];
            }
            if (myTypeOfDrop == 1) {
                CGVector theOffset = CGVectorMake(x*100.0, y*100.0);
                //                [mySegment setPosition:CGPointMake(myPosition.x+theOffset.dx * 2.0, myPosition.y+theOffset.dy * 2.0)];
                [mySegment setPosition:CGPointMake(myPosition.x+theOffset.dx, myPosition.y+theOffset.dy)];
            } else if (myTypeOfDrop == 0){
                [mySegment setPosition:myPosition];
            }
            [mySegment setSize:myPhotoSize];
            [mySegment setPhysicsBody:[SKPhysicsBody bodyWithRectangleOfSize:myPhotoSize]];
            [mySegment.physicsBody setMass:myRandomMass];
            if (myRandomRestitutionSet == 0) {
                [mySegment.physicsBody setRestitution:myRandomRestitution];
            }
            if ((mySegment.size.width > 3.0)  && (mySegment.size.width < 150.0))  {
                [self addChild:mySegment];
                if (myRandomGravity == 0) {
                    [mySegment.physicsBody setAffectedByGravity:NO];
                }
                else if (myRandomGravity == 1){
                    [mySegment.physicsBody setMass:-1.0];
                }
                else if (myRandomGravity == 2){
                    [mySegment.physicsBody setMass:-2.0];
                }
                if (myTypeOfColorize == 0) {
                    float myRandomRed = arc4random()%100;
                    float myRandomGreen = arc4random()%100;
                    float myRandomBlue = arc4random()%100;
                    float myRandomColorBlendFactor = arc4random()%100;
                    myRandomRed = myRandomRed/100.0;
                    myRandomGreen = myRandomGreen/100.0;
                    myRandomBlue = myRandomBlue/100.0;
                    myRandomColorBlendFactor = myRandomColorBlendFactor/100.0;
                    [mySegment setColor:[UIColor colorWithRed:myRandomRed green:myRandomGreen blue:myRandomBlue alpha:1.0]];
                    [mySegment setColorBlendFactor:myRandomColorBlendFactor];
                }
                [mySegment runAction:[SKAction sequence:@[
                                                          [SKAction waitForDuration:myRandomFirstWaitFor],
                                                          [SKAction scaleTo:myRandomScaleTo duration:myRandomScaleToDuration],
                                                          [SKAction waitForDuration:myRandomSecondWaitFor],
                                                          [SKAction group:@[
                                                                            [SKAction scaleTo:0.1 duration:myRandomScaleOutDuration],
                                                                            [SKAction fadeAlphaTo:0.1 duration:myRandomScaleOutDuration],
                                                                            ]],
                                                          [SKAction removeFromParent],
                                                          ]]];
            }
        }
    }
}

@end

//-(void)myKickPictures{
//    long myTempX = 0;
//    long myTempY = 0;
//    myTempX = arc4random_uniform(9)-5l;
//    myTempY = arc4random_uniform(9)-5l;
//
//    //    myTempY = ((arc4random()%5)-3)/10.0;
//    //    myTempX = ((arc4random()%5)-3)/10.0;
//    NSLog(@"in myKickPictures, X = %ld, Y = %ld",myTempX,myTempY);
//    [self enumerateChildNodesWithName:@"photosprite" usingBlock:^(SKNode *node, BOOL *stop){
//        [node.physicsBody applyImpulse:CGVectorMake(myTempX,myTempY)];
//    }];
//}
//
//-(void)myKickTextures{
//    long myTempX = 0;
//    long myTempY = 0;
//    myTempX = arc4random_uniform(5)-3l;
//    myTempY = arc4random_uniform(5)-3l;
//
//    //    myTempY = ((arc4random()%3)-2.0)/10.0;
//    //    myTempX = ((arc4random()%3)-2.0)/10.0;
//    NSLog(@"in myKickTextures, X = %ld, Y = %ld",myTempX,myTempY);
//    [self enumerateChildNodesWithName:@"circlesprite" usingBlock:^(SKNode *node, BOOL *stop){
//        [node.physicsBody applyImpulse:CGVectorMake(myTempX,myTempY)];
//    }];
//}
//
//-(void)myKickColors{
//    long myTempX = 0;
//    long myTempY = 0;
//    myTempX = arc4random_uniform(3)-2l;
//    myTempY = arc4random_uniform(3)-2l;
//    NSLog(@"in myKickColors, X = %ld, Y = %ld",myTempX,myTempY);
//    [self enumerateChildNodesWithName:@"colorsprite" usingBlock:^(SKNode *node, BOOL *stop){
//        [node.physicsBody applyImpulse:CGVectorMake(myTempX,myTempY)];
//    }];
//}

