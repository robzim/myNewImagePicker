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

int mySpriteCount = 0;

//vector_float2 mySourceVector;
//vector_float2 myDestVector;





float myImageSpriteMass = 0.5;
float myImageSpriteRestitution = 0.7;
float myImageSpriteSize = 0;
float myPhotoSpriteScale = 1.0;


int myImageSpriteNumber = 1;

//

int myColorSpriteDefaultSize = 8;
int myColorSpriteLoops = 1;
float myColorSpriteRestitution = 0.5;


int myNumberOfLoopsForSquares = 20;

int myShape = 0;
int myFrameWidth;

//
int myCircleSpriteSize = 4;
float myCircleSpriteScale = 0.03;
float myCircleSpriteRestitution = 1.01;
int myCircleSpriteLoops = 3;


int myAllocCount = 0;

dispatch_queue_t myDispatchQueue;
//dispatch_queue_t myColorQueue;



@implementation GameScene{
    NSString *deviceType;
    NSString *myPhoneModel;
    
    UIImpactFeedbackGenerator *myHeavyImpactFeedbackGenerator;
    UIImpactFeedbackGenerator *myMediumImpactFeedbackGenerator;
    UIImpactFeedbackGenerator *myLightImpactFeedbackGenerator;
    UISelectionFeedbackGenerator *myUISelectionFeedbackGenerator;
    UINotificationFeedbackGenerator *myNotificationFeedbackGenerator;
    
    SKWarpGeometryGrid *myWarpGeometryGrid;
    SKWarpGeometryGrid *myReverseWarpGeometryGrid;
}




@synthesize myDropPicturesTimer;
@synthesize mySpriteImage1, mySpriteImage2, mySpriteImage3, mySpriteImage4, mySpriteImage5;
@synthesize myImageSprite1, myImageSprite2, myImageSprite3, myImageSprite4, myImageSprite5;

@synthesize myTexture;

@synthesize myTexture1;
@synthesize myTexture2;
@synthesize myTexture3;
@synthesize myTexture4;
@synthesize myTexture5;


@synthesize myImageSpriteAction;
@synthesize myBG;
@synthesize myOperationQueue;
@synthesize myScore;
@synthesize myHighScore;
@synthesize mySnowParticle;

@synthesize myTimeSinceLastFrame;
@synthesize myLastTimeSample;

@synthesize firstNode;
@synthesize secondNode;

@synthesize myAudioPlayer;
@synthesize myAudioLevelLabel;
@synthesize myInstantPower;
@synthesize myAveragePower;

@synthesize myTestNumber;

@synthesize myMusicURL;
//@synthesize myMusicPlayer;

//-(void)didApplyConstraints{

float myLastInstantPower;
float myPowerDifference;
//    float myLastAveragePower = myAveragePower;
    
    
    
//    myInstantPower=0;
//    myAveragePower=0;
//    [myAudioPlayer updateMeters];
//    for (int i = 0 ; i < myAudioPlayer.numberOfChannels;  i++) {
//        myInstantPower+= [myAudioPlayer peakPowerForChannel:i];
//        myAveragePower+= [myAudioPlayer averagePowerForChannel:i];
//    }
//    myInstantPower = myInstantPower / myAudioPlayer.numberOfChannels;
//    myAveragePower = myAveragePower / myAudioPlayer.numberOfChannels;
//    //    }
//    float myPowerDifference = myLastInstantPower - myInstantPower;

    //        [self myCalculateAudioPeaks];
    //    [myAudioLevelLabel setText:[NSString stringWithFormat:@"Level = %f dB",myInstantPower]];
    //    }];
    
    //
    //
    //
    //
    //
    //   use the excursions (myPowerDifference) to tell the beats regardless of dB
    //
//    if (myPowerDifference > 1.0) {
//        NSLog(@"Instant = %f dB, Avg = %f dB, Diff %f",myInstantPower,myAveragePower,myPowerDifference);
//    }
    
    //    if (myInstantPower > -5.0) {
//    [self enumerateChildNodesWithName:@"photosprite" usingBlock:^(SKNode * _Nonnull node, BOOL * _Nonnull stop) {
//        [node runAction:[SKAction scaleTo:2.0-(myInstantPower/-1.0) duration:0.00]];
//    }];
    
//}

-(void)myAddChild: (SKNode *) theNode{
    myAllocCount++;
    NSLog(@"%d Allocs",myAllocCount);
    [self addChild:theNode];
}


-(void)update:(NSTimeInterval)currentTime{
    
    myTimeSinceLastFrame = currentTime - myLastTimeSample;
    myLastTimeSample = currentTime;
    //    NSLog(@"T = %f",myTimeSinceLastFrame);
    if ((myTimeSinceLastFrame > 0.3) && (myTimeSinceLastFrame < 10.0)  ) {
        NSLog(@"IN UPDATE -- REMOVING - Slow");
        [myDropPicturesTimer invalidate];
        [myOperationQueue cancelAllOperations];
        [myOperationQueue setSuspended:YES];
        [self removeAllChildren];
        [self setPhysicsBody:[SKPhysicsBody bodyWithEdgeLoopFromRect:self.frame]];
        [myOperationQueue setSuspended:NO];
        [self myStartDropPicturesTimer];
    }
    
    [self myCalculateAudioPeaks];
    
    
    
    
//    NSLog(@"instant Power  %f",myInstantPower);
//    NSLog(@"Power Difference %f",myPowerDifference);
    if ((myPowerDifference > 1.0) || (myPowerDifference < -1.0)  ) {
        [self enumerateChildNodesWithName:@"photosprite" usingBlock:^(SKNode * _Nonnull node, BOOL * _Nonnull stop) {
            
            //
            //  bump the sizes up and down here
            float myScaleTo = myInstantPower / 2.0;
            //
            [node runAction:[SKAction sequence:@[
//                                                 [SKAction fadeOutWithDuration:0.0],
//                                                 //                                                 [SKAction waitForDuration:0.2],
//                                                 [SKAction fadeInWithDuration:0.0],
                                                 [SKAction scaleTo:myScaleTo duration:0.0],
//                                                 [SKAction waitForDuration:0.2],
                                                 [SKAction scaleTo:1.0 duration:0.0],
                                                 ]]];
        }];
        
        [self enumerateChildNodesWithName:@"segmentsprite" usingBlock:^(SKNode * _Nonnull node, BOOL * _Nonnull stop) {
            // flash the segments
            [node runAction:[SKAction sequence:@[
                                                 [SKAction fadeOutWithDuration:0.0],
//                                                 [SKAction waitForDuration:0.2],
                                                 [SKAction fadeInWithDuration:0.0],
                                                 ]]];
        }];
        
    }
}



-(void)myCalculateAudioPeaks{
    myInstantPower=0;
    [myAudioPlayer updateMeters];
    for (int i = 0 ; i < myAudioPlayer.numberOfChannels;  i++) {
        myInstantPower+= [myAudioPlayer peakPowerForChannel:i];
        //        myAveragePower+= [myAudioPlayer averagePowerForChannel:i];
    }
    myInstantPower = myInstantPower / myAudioPlayer.numberOfChannels;
    //    myAveragePower = myAveragePower / myAudioPlayer.numberOfChannels;
    myPowerDifference = myInstantPower - myLastInstantPower;
    myLastInstantPower = myInstantPower;
    

}


-(void)myDropPictures{
    if ((myTimeSinceLastFrame > 0.2) && (myTimeSinceLastFrame < 10.0)  ) {
        NSLog(@"IN DROP PICTURES - REMOVING - Slow");
        [myOperationQueue cancelAllOperations];
        [myDropPicturesTimer invalidate];
        [myOperationQueue setSuspended:YES];
        [self removeAllChildren];
        [self setPhysicsBody:[SKPhysicsBody bodyWithEdgeLoopFromRect:self.frame]];
        [myOperationQueue setSuspended:NO];
        [self myStartDropPicturesTimer];
        return;
    } else {
        int myPic = (arc4random()%5)+1;
        //    NSLog(@"Picure %d, TimeSinceLastFrame %f",myPic,myTimeSinceLastFrame);
        [self myDropPictureNumber:myPic];
    }
}




-(void)myStartDropPicturesTimer{
    myDropPicturesTimer = [NSTimer scheduledTimerWithTimeInterval:3.5 target:self selector:@selector(myDropPictures) userInfo:nil repeats:YES];
    
    //    myAudioLevelLabel = [SKLabelNode labelNodeWithText:@"test"];
    //    [myAudioLevelLabel setPosition:CGPointMake(100.0, 100.0)];
    //    [myAudioLevelLabel setFontColor:[UIColor whiteColor]];
    //    [myAudioLevelLabel setZPosition:15.0];
    //    [myAudioLevelLabel setName:@"test"];
    //    [self myAddChild:myAudioLevelLabel];
    
    
    
    
}

-(void)didMoveToView:(SKView *)view {
    NSLog(@"Music URL in GameScene.m %@",myMusicURL);
    [self myStartTheGame];
}


-(void)myStartTheGame{
//    NSURL *fileURL;
//    if (myMusicURL) {
//            fileURL = myMusicURL;
//    } else {
//        NSString *soundFilePath =
//        //    [[NSBundle mainBundle] pathForResource: @"Normalized 03 Respect"
//        //         [[NSBundle mainBundle] pathForResource: @"Smooth Criminal"
//        //     [[NSBundle mainBundle] pathForResource: @"01 Welcome to My Life"
//        
//        //         [[NSBundle mainBundle] pathForResource: @"Normalized 12 Desafinado"
//        //         [[NSBundle mainBundle] pathForResource: @"05 Dream On"
//        [[NSBundle mainBundle] pathForResource: @"Shoot The Planes Intro Music"
//                                        ofType: @"mp3"];
//        
//        
//        fileURL = [[NSURL alloc] initFileURLWithPath: soundFilePath];
//    }
//    
//
//
//    NSLog(@"Music URL %@, Test Number %@",myMusicURL,myTestNumber);
//    AVAudioPlayer *newPlayer =
////    [[AVAudioPlayer alloc] initWithContentsOfURL: myMusicURL
//     [[AVAudioPlayer alloc] initWithContentsOfURL: fileURL
//                                           error: nil];
//    self.myAudioPlayer = newPlayer;
    
    
    
    
//    [myAudioPlayer prepareToPlay];
//    [myAudioPlayer setDelegate: self];
//    [myAudioPlayer setMeteringEnabled:YES];
//    [myAudioPlayer setNumberOfLoops:-1];
//    [myAudioPlayer play];
    
    
    
    
    //    myTexture1 = [SKTexture textureWithImage:mySpriteImage1];
    //    myTexture2 = [SKTexture textureWithImage:mySpriteImage2];
    //    myTexture3 = [SKTexture textureWithImage:mySpriteImage3];
    //    myTexture4 = [SKTexture textureWithImage:mySpriteImage4];
    //    myTexture5 = [SKTexture textureWithImage:mySpriteImage5];
    
    
//    [NSTimer scheduledTimerWithTimeInterval:10.0 repeats:YES block:^(NSTimer * _Nonnull timer) {
//        NSLog(@"%d Allocs from AddChild Count",mySpriteCount);
//    }];
    
    myFrameWidth = self.view.frame.size.width;
    myImageSprite1 = [myCustomSpriteNode spriteNodeWithTexture:[SKTexture textureWithImage:mySpriteImage1]];

    myImageSprite2 = [myCustomSpriteNode spriteNodeWithTexture:[SKTexture textureWithImage:mySpriteImage2]];


    myImageSprite3 = [myCustomSpriteNode spriteNodeWithTexture:[SKTexture textureWithImage:mySpriteImage3]];


    myImageSprite4 = [myCustomSpriteNode spriteNodeWithTexture:[SKTexture textureWithImage:mySpriteImage4]];


    myImageSprite5 = [myCustomSpriteNode spriteNodeWithTexture:[SKTexture textureWithImage:mySpriteImage5]];

    
    
    
    myHeavyImpactFeedbackGenerator = [[UIImpactFeedbackGenerator alloc] initWithStyle:UIImpactFeedbackStyleHeavy];
    myMediumImpactFeedbackGenerator = [[UIImpactFeedbackGenerator alloc] initWithStyle:UIImpactFeedbackStyleMedium];
    myLightImpactFeedbackGenerator = [[UIImpactFeedbackGenerator alloc] initWithStyle:UIImpactFeedbackStyleLight];
    myUISelectionFeedbackGenerator = [[UISelectionFeedbackGenerator alloc] init];
    myNotificationFeedbackGenerator = [[UINotificationFeedbackGenerator alloc] init];
    //    CGFloat w = (self.size.width + self.size.height) * 0.05;
    
    myImageSpriteSize = (self.size.width + self.size.height) * 0.1;
    
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
    
    //    myOperationQueue = [NSOperationQueue mainQueue];
    myScore = 0;
    //    [self myMakeScoreLabels];
    [self myStartDropPicturesTimer];
//    myDropPicturesTimer = [NSTimer scheduledTimerWithTimeInterval:3.0 target:self selector:@selector(myDropPictures) userInfo:nil repeats:YES];
//    mySourceVector = vector2(2.0f, 2.0f);
//    myDestVector = vector2(2.0f, 2.0f);
    NSString *mySnowParticlePath = [[NSBundle mainBundle] pathForResource:@"mySnowEmitter" ofType:@"sks"];
    mySnowParticle =  [NSKeyedUnarchiver unarchiveObjectWithFile:mySnowParticlePath];
    //
    myDispatchQueue = dispatch_queue_create("myqueue", DISPATCH_QUEUE_CONCURRENT);
    //    myColorQueue = dispatch_queue_create("mycolorqueue", DISPATCH_QUEUE_CONCURRENT);
    
    //        [self makeMyInstructionLabels];
    
    // rz set the gravity to be light   (0.5 looks ok)
    //    [self.physicsWorld setGravity:CGVectorMake(0.0, -0.5)];
    [self.physicsWorld setGravity:CGVectorMake(0.0, -2.5)];
    //    [self.physicsWorld setSpeed:0.1];
    
    [self setBackgroundColor:[UIColor blackColor]];
    [self.view setIgnoresSiblingOrder:YES];
    self.physicsBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:self.frame];
    //
    //  contact 0x04 is the edge of the scene
    self.physicsBody.contactTestBitMask = 0x04;
    self.physicsWorld.contactDelegate = self;
    //
    [self myMakeIntroLabels];
}



-(void)myMakeIntroLabels{
    SKLabelNode *myHoldOnLabel = [SKLabelNode labelNodeWithFontNamed:@"Helvetica"];
    myHoldOnLabel.position = CGPointMake(CGRectGetMidX(self.frame),
                                         CGRectGetMidY(self.frame) + 100 );
    [myHoldOnLabel setZPosition:20.0];
    myHoldOnLabel.text = @"Hold On...";
    [self myAddChild:myHoldOnLabel];

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
    myLabel.fontSize = myImageSpriteSize/5.0;
    my2ndLabel.fontSize = myImageSpriteSize/5.0;
    myLabel.horizontalAlignmentMode = my2ndLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeCenter;
    [myLabel setZPosition:20.0];
    [my2ndLabel setZPosition:20.0];
    myLabel.position = CGPointMake(CGRectGetMidX(self.frame),
                                   CGRectGetMidY(self.frame) - 100 );
    my2ndLabel.position = CGPointMake(CGRectGetMidX(self.frame),
                                      CGRectGetMidY(self.frame) - 160);
    [self myAddChild:myLabel];


    [self myAddChild:my2ndLabel];

    [myLabel setAlpha:0.0];
    [my2ndLabel setAlpha:0.0];
    [myLabel runAction:myIntroHelperLabelAction];
    [my2ndLabel runAction:myIntroHelperLabelAction];
    
}

-(void)didEvaluateActions{
    [super didEvaluateActions];
    if (myTimeSinceLastFrame > 0.2) {
        NSLog(@"in DIDEVALUATEACTIONS AND Removing Objects: --- SLOW");
        [myDropPicturesTimer invalidate];
        [myOperationQueue cancelAllOperations];
        [myOperationQueue setSuspended:YES];
        [self removeAllChildren];
        [self setPhysicsBody:[SKPhysicsBody bodyWithEdgeLoopFromRect:self.frame]];
        [myOperationQueue setSuspended:NO];
        [self myStartDropPicturesTimer];
    }
}

-(void)didSimulatePhysics{
    [super didSimulatePhysics];
    if (myTimeSinceLastFrame > 0.2) {
        NSLog(@"in DIDSIMULATEPYSICS AND Removing Objects: --- SLOW");
        [myDropPicturesTimer invalidate];
        [myOperationQueue cancelAllOperations];
        [myOperationQueue setSuspended:YES];
        [self removeAllChildren];
        [self setPhysicsBody:[SKPhysicsBody bodyWithEdgeLoopFromRect:self.frame]];
        [myOperationQueue setSuspended:NO];
        [self myStartDropPicturesTimer];
    }
}


-(void)myDropPictureNumber: (int) thePictureNumber{
    
    // dont drop more than 3 pictures in the scene at once to avoid the memory leak
    // and dont drop pictures if the frame refresh is getting too slow
    NSLog(@"Child Count %lu",(unsigned long)self.children.count);
    if ((myTimeSinceLastFrame > 0.2) || ( self.children.count > 300 ))   {
        NSLog(@"Returning Early from DropPictureNumber: --- SLOW OR TOO MANY SPRITES");
        [myOperationQueue cancelAllOperations];
        [myOperationQueue setSuspended:YES];
        [self removeAllChildren];
        [self setPhysicsBody:[SKPhysicsBody bodyWithEdgeLoopFromRect:self.frame]];
        [myOperationQueue setSuspended:NO];
        return;
    }
    myCustomSpriteNode *myPictureSprite = [myCustomSpriteNode alloc];

    switch (thePictureNumber) {
        case 1:
            myPictureSprite = [myImageSprite1 copy];
            break;
        case 2:
            myPictureSprite = [myImageSprite2 copy];
            //            [myPictureSprite setTexture:[SKTexture textureWithImage:mySpriteImage2]];
            break;
        case 3:
            myPictureSprite = [myImageSprite3 copy];
            //            [myPictureSprite setTexture:[SKTexture textureWithImage:mySpriteImage3]];
            break;
        case 4:
            myPictureSprite = [myImageSprite4 copy];
            //            [myPictureSprite setTexture:[SKTexture textureWithImage:mySpriteImage4]];
            break;
        case 5:
            myPictureSprite = [myImageSprite5 copy];
            //            [myPictureSprite setTexture:[SKTexture textureWithImage:mySpriteImage5]];
            break;
        default:
            break;
    }
    //    int myRandomMultiplierSeed = arc4random()%2;
    float myRandomMultiplier = 1.0;
    //    if (myRandomMultiplierSeed == 1) {
    //        myRandomMultiplier = -1.0;
    //    }
    
    int myRandomXPosition = (arc4random()%myFrameWidth) * myRandomMultiplier;
//    NSLog(@"X = %d",myRandomXPosition);
    myPictureSprite.position = CGPointMake(myRandomXPosition, CGRectGetMaxY(self.frame) - myYOffset );
    //            dispatch_async(myColorQueue, ^{
    [myPictureSprite setSize:CGSizeMake(myImageSpriteSize, myImageSpriteSize)];
    myPictureSprite.physicsBody = [ SKPhysicsBody bodyWithCircleOfRadius:myPictureSprite.size.width/2.0];
    myPictureSprite.physicsBody.restitution = myImageSpriteRestitution;
    myPictureSprite.physicsBody.contactTestBitMask = 0x02;
    //            [myPictureSprite.physicsBody setMass:myImageSpriteMass];
    [myPictureSprite setName:@"photosprite"];
    [myPictureSprite runAction:myImageSpriteAction];
    [myPictureSprite setBlendMode:SKBlendModeReplace];
    [self myAddChild:myPictureSprite];


    [myPictureSprite.physicsBody setLinearDamping:myImageSpriteDamping];
    
}




-(void)myWarpSprite: (myCustomSpriteNode *) theSprite  {
    
    if (myTimeSinceLastFrame > 0.2) {
        NSLog(@"Returning Early from WarpSprite --- SLOW");
        [myOperationQueue cancelAllOperations];
        [myDropPicturesTimer invalidate];
        
        [self removeAllChildren];
        [self setPhysicsBody:[SKPhysicsBody bodyWithEdgeLoopFromRect:self.frame]];
        [self myStartDropPicturesTimer];
        return;
    }
    int myWarpGeometryGridSize = 3;
    
    vector_float2 myReferenceGrid[myWarpGeometryGridSize * myWarpGeometryGridSize];
    vector_float2 mySources[myWarpGeometryGridSize * myWarpGeometryGridSize];
    vector_float2 myDests[myWarpGeometryGridSize * myWarpGeometryGridSize];
    
    float myIncrement = 1.0 / myWarpGeometryGridSize ;
    float myRandomX;
    float myRandomY;
    int myGridEntry = 0;
    float myGridXValue;
    float myGridYValue;
    float myDestX;
    float myDestY;
    int myRandomDirection;
    
    int myRandomDurationSeed = arc4random()%100;
    float myRandomDuration = (myRandomDurationSeed/100.0)*3.0;
    
    for (int myRow = myWarpGeometryGridSize  ; myRow > 0 ; myRow-- ) {
        for (int myCol = 0  ; myCol < myWarpGeometryGridSize ; myCol++) {
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
    myWarpGeometryGrid = [SKWarpGeometryGrid gridWithColumns:myWarpGeometryGridSize-1 rows:myWarpGeometryGridSize-1 sourcePositions:mySources destPositions:myDests];
    
    myReverseWarpGeometryGrid = [SKWarpGeometryGrid gridWithColumns:myWarpGeometryGridSize-1 rows:myWarpGeometryGridSize-1 sourcePositions:myDests destPositions:mySources];
    [theSprite setWarpGeometry:myWarpGeometryGrid];
    
    int myRandomWarpAction = arc4random()%4;
    int myRandomSpinDirection = arc4random()%2;
    float myRandomSpinMultiplier = 1.0;
    if (myRandomSpinDirection == 1 ) {
        myRandomSpinMultiplier = -1.0;
    }
    
    // take some pressure off the contact tester in CPU
    //    [theSprite.physicsBody setDynamic:NO];
    
    if (myRandomWarpAction == 0) {
        [theSprite runAction: [SKAction repeatActionForever:
                               [SKAction sequence:@[
                                                    [SKAction warpTo:myWarpGeometryGrid duration:myRandomDuration],
                                                    [SKAction warpTo:myReverseWarpGeometryGrid duration:2.5],
                                                    ]]]];
    } else if (myRandomWarpAction == 1) {
        [theSprite runAction: [SKAction repeatActionForever:
                               [SKAction sequence:@[
                                                    [SKAction warpTo:myWarpGeometryGrid duration:myRandomDuration],
                                                    [SKAction warpTo:myReverseWarpGeometryGrid duration:1.5],
                                                    ]]]];
        
    } else if (myRandomWarpAction == 2) {
        [theSprite runAction: [SKAction repeatActionForever:
                               
                               [SKAction group:@[
                                                 
                                                 
                                                 [SKAction sequence:@[
                                                                      [SKAction warpTo:myWarpGeometryGrid duration:myRandomDuration],
                                                                      [SKAction warpTo:myReverseWarpGeometryGrid duration:myRandomDuration],
                                                                      ]],
                                                 [SKAction rotateByAngle:(M_PI * myRandomSpinMultiplier) duration:myRandomDuration],
                                                 ]]]];
    } else if (myRandomWarpAction == 3) {
        [theSprite runAction: [SKAction repeatActionForever:
                               
                               [SKAction group:@[
                                                 [SKAction sequence:@[
                                                                      [SKAction warpTo:myWarpGeometryGrid duration:0.5],
                                                                      [SKAction warpTo:myReverseWarpGeometryGrid duration:1.25],
                                                                      ]],
                                                 [SKAction rotateByAngle:(M_PI * myRandomSpinMultiplier) duration:2.0],
                                                 ]]]];
    }
    
    
}




- (void)didBeginContact:(SKPhysicsContact *)contact {
    //    [[NSOperationQueue mainQueue] cancelAllOperations];
    if (myTimeSinceLastFrame > 0.2) {
        NSLog(@"Returning Early from DidBeginContact --- SLOW");
        [myDropPicturesTimer invalidate];
        [myOperationQueue cancelAllOperations];
        [self removeAllChildren];
        [self setPhysicsBody:[SKPhysicsBody bodyWithEdgeLoopFromRect:self.frame]];
        [self myStartDropPicturesTimer];
        return;
    }
    
    
    
    //    SKNode *firstNode;
    //    SKNode *secondNode;
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
        int myRandomPhotoPhotoAction = arc4random()%3;
        
        for (SKNode *theNode in [NSArray arrayWithObjects:firstNode,secondNode, nil]) {
            if (myRandomPhotoPhotoAction == 0) {
                //                [myOperationQueue addOperationWithBlock:^{
                
                [theNode  runAction:[SKAction sequence:@[
                                                         [SKAction runBlock:^{
                    [self myWarpSprite:(myCustomSpriteNode *) theNode];
                }],
                                                         [SKAction waitForDuration:5.0],
                                                         
                                                         [SKAction scaleTo:0.1 duration:0.25],
                                                         [SKAction removeFromParent],
                                                         ]]
                 //                            withKey:@"warpspriteaction"
                 ];
                
                //                }];
                
            }
            
            else if (myRandomPhotoPhotoAction == 1){
                //                [myOperationQueue addOperationWithBlock:^{
                [theNode  runAction:[SKAction sequence:@[
                                                         [SKAction runBlock:^{
                    [self myBetterSegmentPhotoAndDrop: (myCustomSpriteNode *) theNode];
                }],
                                                         [SKAction waitForDuration:0.1],
                                                         [SKAction scaleTo:0.1 duration:0.1],
                                                         [SKAction removeFromParent],]]
                 ];
                //                }];
            }
            else if (myRandomPhotoPhotoAction == 2){
                //                [myOperationQueue addOperationWithBlock:^{
                [theNode  runAction:[SKAction sequence:@[
                                                         [SKAction runBlock:^{
                    [self myParticleSystemFromPhoto: (myCustomSpriteNode *) theNode];
                }],
                                                         [SKAction waitForDuration:1.0],
                                                         [SKAction removeFromParent],]]
                 ];
                //                }];
            }
        }
    }
    //
    //
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
        
        //        dispatch_async(myDispatchQueue, ^{
        SKNode *myS = [mySnowParticle copy];
        [myS setPosition:firstNode.position];
        //        [myS setPosition:contact.contactPoint];
        [self myAddChild:myS];
    

        [myS runAction:[SKAction sequence:@[[SKAction waitForDuration:0.5],
                                            [SKAction removeFromParent],]]];
        //        });
        
    }
}

-(void)myParticleSystemFromPhoto: (myCustomSpriteNode *) thePhoto  {
    [thePhoto setSize:CGSizeMake(5.0, 5.0)];
    SKEmitterNode *myPP = [mySnowParticle copy];
    [myPP setParticleTexture:thePhoto.texture];
    [myPP setPosition:thePhoto.position];
    [myPP setZPosition:10.0];
    [self myAddChild:myPP];


    [myPP setParticleBlendMode:SKBlendModeReplace];
    [myPP runAction:[SKAction sequence:@[
                                         [SKAction waitForDuration:1.0],
                                         [SKAction removeFromParent],
                                         ]]];
    
    
}


-(void)myBetterSegmentPhotoAndDrop: (myCustomSpriteNode *) thePhoto  {
    if (myTimeSinceLastFrame > 0.2) {
        NSLog(@"Returning Early from Segment --- SLOW");
        [myOperationQueue cancelAllOperations];
        [myDropPicturesTimer invalidate];
        [myOperationQueue setSuspended:YES];
        [self removeAllChildren];
        [self setPhysicsBody:[SKPhysicsBody bodyWithEdgeLoopFromRect:self.frame]];
        [myOperationQueue setSuspended:NO];
        [self myStartDropPicturesTimer];
        return;
    }
    // first grab the texture.  we'll use the texture from here on
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
    
    float myRandomFirstWaitFor = arc4random()%9;
    myRandomFirstWaitFor = myRandomFirstWaitFor/10.0;
    myRandomFirstWaitFor*=2.0;
    float myRandomSecondWaitFor = arc4random()%10;
    myRandomSecondWaitFor = myRandomSecondWaitFor/10.0;
    myRandomSecondWaitFor*=2.0;
    float myRandomScaleOutDuration = arc4random()%10;
    myRandomScaleOutDuration = myRandomScaleOutDuration/10.0;
    float myRandomIncrement = arc4random()%20;
    myRandomIncrement = (myRandomIncrement/100.0)+0.1;
    int myRandomGeometryAction = arc4random()%4;
//    NSLog(@"Mass %d, Drop %d, Increment %f,Segment %d, Colorize %d, 1st Wait %f, Scale %d, Restitution Set %d, Restitution = %f, 2nd Wait %f, Gravity %d, ScaleTo Time %f, ScaleOut Time %f, Geometry Remove %d",myRandomMass, myTypeOfDrop, myRandomIncrement, myTypeOfSegment, myTypeOfColorize, myRandomFirstWaitFor, myRandomScaleTo, myRandomRestitutionSet, myRandomRestitution,   myRandomSecondWaitFor, myRandomGravity, myRandomScaleToDuration, myRandomScaleOutDuration,myRandomGeometryAction);
    CGPoint myPosition = thePhoto.position;
    //    float myIncrement = 0.10;
    float myIncrement = myRandomIncrement;
    CGSize myPhotoSize = CGSizeMake(thePhoto.size.width * myIncrement , thePhoto.size.height * myIncrement  );
    
    //    CGSize myPhotoSize = CGSizeMake(thePhoto.size.width * myIncrement * 2.0, thePhoto.size.height * myIncrement * 2.0 );
    for (float x = 0.0 ; x < 1.0 ; x = x + myIncrement) {
        for (float y = 0.0 ; y < 1.0 ; y = y + myIncrement) {
            myCustomSpriteNode *mySegment;
            if (myTypeOfSegment == 0 ) {
                mySegment = [myCustomSpriteNode spriteNodeWithTexture:[SKTexture textureWithRect:CGRectMake(x, y, myIncrement, myIncrement) inTexture:myTexture]];
            } else if (myTypeOfSegment == 1) {
                mySegment = [myCustomSpriteNode spriteNodeWithTexture:myTexture];
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
            
            //            [mySegment setPhysicsBody:[SKPhysicsBody bodyWithCircleOfRadius:myPhotoSize.width/2.0]];
            [mySegment.physicsBody setMass:myRandomMass];
            if (myRandomRestitutionSet == 0) {
                [mySegment.physicsBody setRestitution:myRandomRestitution];
            }
            
            if ((mySegment.size.width > 3.0)  && (mySegment.size.width < 150.0))  {
                [mySegment setName:@"segmentsprite"];
                [mySegment setBlendMode:SKBlendModeReplace];
                [self myAddChild:mySegment];
            

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
                if (myRandomGeometryAction == 0) {
                    [mySegment runAction:[SKAction sequence:@[
                                                              [SKAction waitForDuration:0.5],
                                                              [SKAction runBlock:^{
                        [mySegment setPhysicsBody:nil];
                    }],
                                                              ]]];
                } else if (myRandomGeometryAction == 1) {
                    [mySegment runAction:[SKAction sequence:@[
                                                              [SKAction runBlock:^{
                        [mySegment setPhysicsBody:[SKPhysicsBody bodyWithCircleOfRadius:mySegment.size.width]];
                    }],
                                                              [SKAction waitForDuration:0.1],
                                                              [SKAction runBlock:^{
                        // take some pressure off the contact tester
                        //                        [mySegment.physicsBody setDynamic:NO];
                    }],
                                                              ]]];
                }
                [mySegment runAction:[SKAction sequence:@[
                                                          [SKAction waitForDuration:myRandomFirstWaitFor],
                                                          [SKAction scaleTo:myRandomScaleTo duration:myRandomScaleToDuration],
                                                          [SKAction waitForDuration:myRandomSecondWaitFor],
                                                          [SKAction scaleTo:0.1 duration:myRandomScaleOutDuration],
                                                          [SKAction removeFromParent],
                                                          ]]];
            }
        }
    }
}

@end


