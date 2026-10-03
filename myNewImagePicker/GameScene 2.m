//
//  GameScene.m
//  eyeCandy
//
//  Created by Robert Zimmelman on 11/10/14.
//  Copyright (c) 2016 Robert Zimmelman. All rights reserved.
//
#import "GameScene.h"

bool mySceneTestMode = NO;

float myScreenRefreshTimeToDump = 0.35;
float myScreenRefreshTimeToHoldOffDroppingPictures = 0.2;

int myAcceptableNodeCount = 25;

float myScaleTo = 1.0;
float myPhotoScaleMultiplier = 1.5;
float mySegmentScaleMultiplier = 1.2;
float myParticleSystemScaleMultiplier = 1.2;
float myTriangleScaleMultiplier = 1.5;
float myCircleScaleMultiplier = 0.75;

int myButtonWidth = 30;
int myCounter = 0;
int myFiveSpriteLoops = 1;
int myMassMult = 1;
int myYOffset = 30;
float myImageSpriteDamping = 0.0;

float myRestitution = 0.5;

int mySpriteCount = 0;

// Magical colors for effects
#define MAGIC_PINK [SKColor colorWithRed:1.0 green:0.4 blue:0.6 alpha:1.0]
#define MAGIC_CYAN [SKColor colorWithRed:0.2 green:0.9 blue:1.0 alpha:1.0]
#define MAGIC_PURPLE [SKColor colorWithRed:0.6 green:0.3 blue:1.0 alpha:1.0]
#define MAGIC_GOLD [SKColor colorWithRed:1.0 green:0.85 blue:0.3 alpha:1.0]
#define MAGIC_GREEN [SKColor colorWithRed:0.3 green:1.0 blue:0.5 alpha:1.0]




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
    GKRandomDistribution *my100OffsetRandomSource;
    GKRandomDistribution *myShuffledRandomSource;
}

@synthesize myOSVersion;
@synthesize myVibrateFlag;
@synthesize myImage1Flag;
@synthesize myImage2Flag;
@synthesize myImage3Flag;
@synthesize myImage4Flag;
@synthesize myImage5Flag;
@synthesize myProcessInfo;
@synthesize myDropPicturesTimer;
@synthesize mySpriteImage1, mySpriteImage2, mySpriteImage3, mySpriteImage4, mySpriteImage5;
@synthesize myImageSprite1, myImageSprite2, myImageSprite3, myImageSprite4, myImageSprite5;

@synthesize myAllRandomImagesFlag;

@synthesize myPhotos;
@synthesize myImageManager;


@synthesize myResizeMethod;
@synthesize myMicRecorder;
@synthesize myMicInputEnabled;
@synthesize myStartedInMicMode;
@synthesize myTexture;

@synthesize myTexture1;
@synthesize myTexture2;
@synthesize myTexture3;
@synthesize myTexture4;
@synthesize myTexture5;


@synthesize myImageSpriteAction;
@synthesize myBG;
//@synthesize myScore;
//@synthesize myHighScore;
//@synthesize mySnowParticle;
//@synthesize myCloudParticle;

@synthesize myTimeSinceLastFrame;
@synthesize myLastTimeSample;

@synthesize firstNode;
@synthesize secondNode;

@synthesize myAudioPlayer;
@synthesize myAudioLevelLabel;
@synthesize myInstantPower;
@synthesize myAveragePower;

@synthesize myTestNumber;
@synthesize myTestInt;

@synthesize myMusicURL;
@synthesize mySongTitle;
@synthesize mySongArtist;

@synthesize myPicturesArray;
@synthesize myAudioDisplayNode;

@synthesize mySceneImageSize;
//@synthesize myMusicPlayer;


float myLastInstantPower;
float myPowerDifference;

// sub-class these for debugging allocs and de-allocs
//-(void)addChild:(SKNode *)node{
//    myAllocCount++;
//    [super addChild:node];
//    NSLog(@"%d Allocs",myAllocCount);
//}
//
//-(void)copy:(id)sender{
//    myAllocCount++;
//    [super copy:(id)sender];
//    NSLog(@"%d Allocs",myAllocCount);
//}



-(double)myDbToAmp: (double)inDb {
    double power;
    power = pow(10., 0.05 * inDb);
    return power;
}

-(void)myBumpNewPhoneWithMusic{
    if (myPowerDifference > 0.7) {
        if ([deviceType isEqualToString:@"iPhone9"]) {
            [myHeavyImpactFeedbackGenerator impactOccurred];
        }
    }
    else if (myPowerDifference > 0.5) {
        if ([deviceType isEqualToString:@"iPhone9"]) {
            [myMediumImpactFeedbackGenerator impactOccurred];
        }
    }
    else if (myPowerDifference > 0.25) {
        if ([deviceType isEqualToString:@"iPhone9"]) {
            [myLightImpactFeedbackGenerator impactOccurred];
        }
    }
    
}



-(void)myResizeTheParticlesToSize: (float) theScleToSize {
    int myRandomParticleSystemResizeGate = arc4random()%5;
    float myScaleTo = theScleToSize;
    if (myRandomParticleSystemResizeGate == 0) {
        [self enumerateChildNodesWithName:@"particle system" usingBlock:^(SKNode * _Nonnull node, BOOL * _Nonnull stop) {
            if ([(myCustomEmitterNode *) node myResizeValue]  == 0 ) {
                NSLog(@"");
                // resize the whole particle system
                float myNodeXScale = node.xScale;
                float myNodeYScale = node.yScale;
                
                if (self->myOSVersion >= 10.0) {
                    [node runAction:[SKAction sequence:@[
                                                         [SKAction scaleTo:myScaleTo*myParticleSystemScaleMultiplier duration:0.0],
                                                         [SKAction scaleTo:myNodeXScale duration:0.0],
                                                         ]]];
                } else {
                    [node runAction:[SKAction sequence:@[
                                                         [SKAction group:@[
                                                                           [SKAction scaleXTo:myScaleTo*myParticleSystemScaleMultiplier duration:0.0],
                                                                           [SKAction scaleYTo:myScaleTo*myParticleSystemScaleMultiplier duration:0.0],
                                                                           ]],
                                                         [SKAction group:@[
                                                                           [SKAction scaleXTo:myNodeXScale duration:0.0],
                                                                           [SKAction scaleYTo:myNodeYScale duration:0.0],
                                                                           ]],
                                                         ]]];
                }
                
                
                
                
            }
            else if ([(myCustomEmitterNode *) node myResizeValue] == 1 ) {
                NSLog(@"");
                // resize the particles
                CGSize myParticleSize = [(SKEmitterNode *) node particleSize];
                [node runAction:[SKAction sequence:@[
                                                     [SKAction runBlock:^{
                    [(SKEmitterNode *) node setParticleSize:CGSizeMake(myScaleTo*myParticleSystemScaleMultiplier, myScaleTo*myParticleSystemScaleMultiplier)];
                }],
                                                     [SKAction runBlock:^{
                    [(SKEmitterNode *) node setParticleSize:myParticleSize];
                }],
                                                     ]]];
            } else if ([(myCustomEmitterNode *) node myResizeValue] == 2 ) {
                [node runAction:[SKAction sequence:@[
                                                     [SKAction fadeOutWithDuration:0.0],
                                                     [SKAction fadeInWithDuration:0.0],
                                                     ]]];
            }
        }
         ];
    }
    
}

-(void)myResizePhotosAndSegmentsToSize: (float) theScaleTo{
    myScaleTo = theScaleTo;
    
    //    NSArray *mySpriteNamesToResize = [NSArray arrayWithObjects:@"photosprite",  nil];
    
    [self enumerateChildNodesWithName:@"sprite" usingBlock:^(SKNode * _Nonnull node, BOOL * _Nonnull stop) {
        if (self->myOSVersion >= 10.0) {
            [node runAction:[SKAction sequence:@[
                                                 
                                                 [SKAction scaleTo:myScaleTo*myPhotoScaleMultiplier duration:0.0],
                                                 [SKAction scaleTo:1.0 duration:0.0],
                                                 ]]];
        }  else {
            [node runAction:[SKAction sequence:@[
                                                 [SKAction group:@[
                                                                   [SKAction scaleXTo:myScaleTo*myPhotoScaleMultiplier duration:0.0],
                                                                   [SKAction scaleYTo:myScaleTo*myPhotoScaleMultiplier duration:0.0],
                                                                   ]],
                                                 [SKAction group:@[
                                                                   [SKAction scaleXTo:1.0 duration:0.0],
                                                                   [SKAction scaleYTo:1.0 duration:0.0],
                                                                   ]],
                                                 ]]];
        }
    }];
    
    
//    [self enumerateChildNodesWithName:@"square" usingBlock:^(SKNode * _Nonnull node, BOOL * _Nonnull stop) {
//        if (myOSVersion >= 10.0) {
//            [node runAction:[SKAction sequence:@[
//                                                 
//                                                 [SKAction scaleTo:myScaleTo*myPhotoScaleMultiplier duration:0.0],
//                                                 [SKAction scaleTo:1.0 duration:0.0],
//                                                 ]]];
//        }  else {
//            [node runAction:[SKAction sequence:@[
//                                                 [SKAction group:@[
//                                                                   [SKAction scaleXTo:myScaleTo*myPhotoScaleMultiplier duration:0.0],
//                                                                   [SKAction scaleYTo:myScaleTo*myPhotoScaleMultiplier duration:0.0],
//                                                                   ]],
//                                                 [SKAction group:@[
//                                                                   [SKAction scaleXTo:1.0 duration:0.0],
//                                                                   [SKAction scaleYTo:1.0 duration:0.0],
//                                                                   ]],
//                                                 ]]];
//        }
//    }];
//    
//    
//    
//    
//    [self enumerateChildNodesWithName:@"crop" usingBlock:^(SKNode * _Nonnull node, BOOL * _Nonnull stop) {
//        if (myOSVersion >= 10.0) {
//            [node runAction:[SKAction sequence:@[
//                                                 
//                                                 [SKAction scaleTo:myScaleTo*myPhotoScaleMultiplier duration:0.0],
//                                                 [SKAction scaleTo:1.0 duration:0.0],
//                                                 ]]];
//        }  else {
//            [node runAction:[SKAction sequence:@[
//                                                 [SKAction group:@[
//                                                                   [SKAction scaleXTo:myScaleTo*myPhotoScaleMultiplier duration:0.0],
//                                                                   [SKAction scaleYTo:myScaleTo*myPhotoScaleMultiplier duration:0.0],
//                                                                   ]],
//                                                 [SKAction group:@[
//                                                                   [SKAction scaleXTo:1.0 duration:0.0],
//                                                                   [SKAction scaleYTo:1.0 duration:0.0],
//                                                                   ]],
//                                                 ]]];
//        }
//    }];
//    
//    
//    [self enumerateChildNodesWithName:@"photosprite" usingBlock:^(SKNode * _Nonnull node, BOOL * _Nonnull stop) {
//        if (myOSVersion >= 10.0) {
//            [node runAction:[SKAction sequence:@[
//                                                 
//                                                 [SKAction scaleTo:myScaleTo*myPhotoScaleMultiplier duration:0.0],
//                                                 [SKAction scaleTo:1.0 duration:0.0],
//                                                 ]]];
//        }  else {
//            [node runAction:[SKAction sequence:@[
//                                                 [SKAction group:@[
//                                                                   [SKAction scaleXTo:myScaleTo*myPhotoScaleMultiplier duration:0.0],
//                                                                   [SKAction scaleYTo:myScaleTo*myPhotoScaleMultiplier duration:0.0],
//                                                                   ]],
//                                                 [SKAction group:@[
//                                                                   [SKAction scaleXTo:1.0 duration:0.0],
//                                                                   [SKAction scaleYTo:1.0 duration:0.0],
//                                                                   ]],
//                                                 ]]];
//        }
//    }];
//    
//    
//    int myRandomSegmentAction = arc4random()%5;
//    if (myRandomSegmentAction == 0) {
//        [self enumerateChildNodesWithName:@"segmentsprite" usingBlock:^(SKNode * _Nonnull node, BOOL * _Nonnull stop) {
//            float myTempXScale = node.xScale;
//            float myTempYScale = node.yScale;
//            [node runAction:[SKAction sequence:@[
//                                                 [SKAction group:@[
//                                                                   [SKAction scaleXTo:myScaleTo*mySegmentScaleMultiplier duration:0.0],
//                                                                   [SKAction scaleYTo:myScaleTo*mySegmentScaleMultiplier duration:0.0],
//                                                                   ]],
//                                                 [SKAction group:@[
//                                                                   [SKAction scaleXTo:myTempXScale duration:0.0],
//                                                                   [SKAction scaleYTo:myTempYScale duration:0.0],
//                                                                   ]],
//                                                 
//                                                 ]]];
//        }];
//        
//    }
//    
//    [self enumerateChildNodesWithName:@"trianglesprite" usingBlock:^(SKNode * _Nonnull node, BOOL * _Nonnull stop) {
//        float myTempXScale = node.xScale;
//        float myTempYScale = node.yScale;
//        [node runAction:[SKAction sequence:@[
//                                             [SKAction group:@[
//                                                               [SKAction scaleXTo:myScaleTo*myTriangleScaleMultiplier duration:0.0],
//                                                               [SKAction scaleYTo:myScaleTo*myTriangleScaleMultiplier duration:0.0],
//                                                               ]],
//                                             [SKAction group:@[
//                                                               [SKAction scaleXTo:myTempXScale duration:0.0],
//                                                               [SKAction scaleYTo:myTempYScale duration:0.0],
//                                                               ]],
//                                             ]]];
//    }];
//    
//    [self enumerateChildNodesWithName:@"circlesprite" usingBlock:^(SKNode * _Nonnull node, BOOL * _Nonnull stop) {
//        float myTempXScale = node.xScale;
//        float myTempYScale = node.yScale;
//        [node runAction:[SKAction sequence:@[
//                                             [SKAction group:@[
//                                                               [SKAction scaleXTo:myScaleTo*myCircleScaleMultiplier duration:0.0],
//                                                               [SKAction scaleYTo:myScaleTo*myCircleScaleMultiplier duration:0.0],
//                                                               ]],
//                                             [SKAction group:@[
//                                                               [SKAction scaleXTo:myTempXScale duration:0.0],
//                                                               [SKAction scaleYTo:myTempYScale duration:0.0],
//                                                               ]],
//                                             
//                                             ]]];
//    }];
    
}




-(void)myResizeSpritesToMusic{
//    double myInstantAmplitude;
    myInstantPower=0;
    myAveragePower=0;

    // Use the sticky flag to determine input source
    if (myStartedInMicMode) {
        // Mic mode - only use mic input, never fall back to audio
        if (myMicInputEnabled && myMicRecorder.isRecording) {
            [myMicRecorder updateMeters];
            myInstantPower = [myMicRecorder peakPowerForChannel:0];
            myAveragePower = [myMicRecorder averagePowerForChannel:0];

            // Log mic power values (every ~60 frames to avoid spam)
            static int logCounter = 0;
            if (logCounter++ % 60 == 0) {
                NSLog(@">>> MIC POWER: instant=%f, avg=%f, diff=%f, audioPlaying=%d",
                      myInstantPower, myAveragePower, fabs(myInstantPower - myLastInstantPower),
                      myAudioPlayer.isPlaying);
            }
        } else {
            // Mic not ready yet - don't resize at all
            return;
        }
    } else {
        // NOT in mic mode - check if we should use music
        if (myResizeMethod == 0) {
            return;  // No resize mode
        }
        // Music mode - only resize if audio player exists and is playing
        if (!myAudioPlayer) {
            return;
        }
        if (!myAudioPlayer.isPlaying) {
            return;
        }
        [myAudioPlayer updateMeters];
        for (int i = 0 ; i < myAudioPlayer.numberOfChannels;  i++) {
            myInstantPower+= [myAudioPlayer peakPowerForChannel:i];
            myAveragePower+= [myAudioPlayer averagePowerForChannel:i];
        }
        myInstantPower = myInstantPower / myAudioPlayer.numberOfChannels;
    }

    myPowerDifference = fabs(myInstantPower - myLastInstantPower);
    myLastInstantPower = myInstantPower;

    float myScaleTo = 1.0;
    if (myResizeMethod == 2) {
        // Music pulse mode
        myScaleTo = fabs(myPowerDifference / 2.0);
    } else if (myResizeMethod == 1) {
        // Music instant mode
        myScaleTo = [self myDbToAmp:myInstantPower];
    } else if (myResizeMethod == 4) {
        // Mic pulse mode
        myScaleTo = fabs(myPowerDifference / 1.5);
    } else if (myResizeMethod == 3) {
        // Mic instant mode
        myScaleTo = [self myDbToAmp:myInstantPower] * 1.5;
    }

    if (myVibrateFlag == YES) {
        [self myBumpNewPhoneWithMusic];
    }

    // Use higher threshold for mic mode to filter ambient noise
    float minThreshold = myStartedInMicMode ? 1.0 : 0.0;

    if (myPowerDifference > minThreshold) {
        [self myResizeTheParticlesToSize:myScaleTo];
        [self myResizePhotosAndSegmentsToSize:myScaleTo];
    }
}

#pragma mark - Microphone Input

-(void)myStartMicInput {
    NSLog(@"Starting microphone input");

    // Request microphone permission
    [[AVAudioSession sharedInstance] requestRecordPermission:^(BOOL granted) {
        if (granted) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self setupMicRecorder];
            });
        } else {
            NSLog(@"Microphone permission denied");
            dispatch_async(dispatch_get_main_queue(), ^{
                [self showMicError:@"Microphone access denied. Please enable microphone access in Settings to use Mic Mode."];
            });
        }
    }];
}

-(void)showMicError:(NSString *)message {
    // Post notification to show alert from ViewController
    [[NSNotificationCenter defaultCenter] postNotificationName:@"micError" object:message];
}

-(void)setupMicRecorder {
    NSError *error = nil;

    // Configure audio session for recording
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setCategory:AVAudioSessionCategoryPlayAndRecord
             withOptions:AVAudioSessionCategoryOptionDefaultToSpeaker | AVAudioSessionCategoryOptionMixWithOthers
                   error:&error];
    if (error) {
        NSLog(@"Audio session error: %@", error);
        [self showMicError:[NSString stringWithFormat:@"Audio session error: %@", error.localizedDescription]];
        return;
    }
    [session setActive:YES error:&error];

    // Create temporary file URL for recorder (required but we won't use the file)
    NSString *tempDir = NSTemporaryDirectory();
    NSString *tempFile = [tempDir stringByAppendingPathComponent:@"mic_input.caf"];
    NSURL *fileURL = [NSURL fileURLWithPath:tempFile];

    // Recording settings
    NSDictionary *settings = @{
        AVFormatIDKey: @(kAudioFormatAppleLossless),
        AVSampleRateKey: @44100.0,
        AVNumberOfChannelsKey: @1,
        AVEncoderAudioQualityKey: @(AVAudioQualityMedium)
    };

    myMicRecorder = [[AVAudioRecorder alloc] initWithURL:fileURL settings:settings error:&error];
    if (error) {
        NSLog(@"Recorder init error: %@", error);
        [self showMicError:[NSString stringWithFormat:@"Microphone setup error: %@", error.localizedDescription]];
        return;
    }

    myMicRecorder.meteringEnabled = YES;
    [myMicRecorder prepareToRecord];
    [myMicRecorder record];
    myMicInputEnabled = YES;

    NSLog(@"Microphone input started successfully");
}

-(void)myStopMicInput {
    NSLog(@"Stopping microphone input");

    if (myMicRecorder && myMicRecorder.isRecording) {
        [myMicRecorder stop];
    }
    myMicInputEnabled = NO;
}

-(void)myToggleMicInput {
    if (myMicInputEnabled) {
        [self myStopMicInput];
    } else {
        [self myStartMicInput];
    }
}



-(void)update:(NSTimeInterval)currentTime{
    myTimeSinceLastFrame = currentTime - myLastTimeSample;
    myLastTimeSample = currentTime;
    if ((myTimeSinceLastFrame > myScreenRefreshTimeToDump) && (myTimeSinceLastFrame < 10.0)  ) {
        [self runAction:[SKAction runBlock:^{
            NSLog(@"IN update -- REMOVING - Slow");
            [self->myDropPicturesTimer invalidate];
            NSLog(@"BEFORE  CLEANUP  IN UPDATE - %d NODES",(int) self.children.count);
            NSLog(@"%@",self.children);
            NSLog(@"______________________________________________________________________");

            
            [self enumerateChildNodesWithName:@"sprite" usingBlock:^(SKNode * _Nonnull node, BOOL * _Nonnull stop) {
                [node removeFromParent];
            }];
            [self enumerateChildNodesWithName:@"particle system" usingBlock:^(SKNode * _Nonnull node, BOOL * _Nonnull stop) {
                [node removeFromParent];
            }];
            NSLog(@"AFTER  CLEANUP  IN UPDATE - %d NODES",(int) self.children.count);
            NSLog(@"%@",self.children);
            NSLog(@"______________________________________________________________________");
            [self setPhysicsBody:[SKPhysicsBody bodyWithEdgeLoopFromRect:self.frame]];
            [self myMakeMenuReminderLabel];
            [self myMakeIntroLabels];
            [self myStartDropPicturesTimer];
        }]];
    }
    // if myResizeMethod == 0 then we're not resizing, so dont do the routine
    if (myResizeMethod > 0) {
        [self myResizeSpritesToMusic];
    }

    // Always update audio display (handles pause state, decay animations)
    [self myUpdateAudioDisplay];
}


-(void)photoLibraryDidChange:(PHChange *)changeInstance{
    NSLog(@"GameScene Photo Library Changed");
}


-(void)myListAllPhotoAssets{
    [myPhotos enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSLog(@"%@",obj);
    }];
}


-(void)myFetchPhotosFromLibrary{
    [[PHPhotoLibrary sharedPhotoLibrary] registerChangeObserver:self];
    myPhotos = [[PHFetchResult alloc] init];
    //    PHFetchResult *myAlbums = [[PHFetchResult alloc] init];
    //    PHFetchResult *myCollections = [[PHFetchResult alloc] init];
    PHFetchOptions *myFetchOptions = [[PHFetchOptions alloc] init];
    [myFetchOptions setSortDescriptors:(NSArray<NSSortDescriptor *> * _Nullable) @[
                                                                                   [NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:YES selector:NULL]]];
    myPhotos = [PHAsset fetchAssetsWithOptions:myFetchOptions];
    if (myPhotos.count != 0) {
        if (mySceneTestMode) {
            [self myListAllPhotoAssets];
        }
        myImageManager = [[PHImageManager alloc] init];
        [self myReassignImages];
    }
}


-(void)myReassignImages{
    NSLog(@"in GameScene ReassignImages");
    if (myPhotos.count != 0) {
        if (mySceneTestMode) {
            [self myListAllPhotoAssets];
        }
        for (int i = 1; i <=5 ; i++) {
            [self myAssignImageNumber:i];
        }
    }
}







-(void)myDropPictures{
    if (self.children.count > myAcceptableNodeCount) {
        NSLog(@"______________________________________________________________________");
        NSLog(@"IN DROP PICTURES - RETURNING - %d NODES",(int) self.children.count);
//        NSLog(@"%@",self.children);
        [self enumerateChildNodesWithName:@"sprite" usingBlock:^(SKNode * _Nonnull node, BOOL * _Nonnull stop) {
            [node removeFromParent];
        }];
        [self enumerateChildNodesWithName:@"particle system" usingBlock:^(SKNode * _Nonnull node, BOOL * _Nonnull stop) {
            [node removeFromParent];
        }];
        NSLog(@"AFTER CLEANUP - %d NODES",(int) self.children.count);
//        NSLog(@"%@",self.children);
        NSLog(@"______________________________________________________________________");

        [self myStartDropPicturesTimer];
        return;
    }
    if ((myTimeSinceLastFrame > myScreenRefreshTimeToHoldOffDroppingPictures) && (myTimeSinceLastFrame < 10.0)   ) {
        NSLog(@"IN DROP PICTURES - RETURNING - %d NODES -- SLOW",(int) self.children.count);
        NSLog(@"%@",self.children);
        [self enumerateChildNodesWithName:@"sprite" usingBlock:^(SKNode * _Nonnull node, BOOL * _Nonnull stop) {
            [node removeFromParent];
        }];
        [self enumerateChildNodesWithName:@"particle system" usingBlock:^(SKNode * _Nonnull node, BOOL * _Nonnull stop) {
            [node removeFromParent];
        }];
        NSLog(@"AFTER CLEANUP - %d NODES",(int) self.children.count);
        NSLog(@"%@",self.children);
        NSLog(@"______________________________________________________________________");
        [self myStartDropPicturesTimer];
        return;
        //
        //  if the child count is low then drop another picture
    } else  {
        
        //
        //
        // only use images that are not highlighted, so index into the array
        //
        //
        int myPic = (arc4random()%5);
        //
        if (myPicturesArray.count > 0) {
            myPic = (arc4random()%myPicturesArray.count);
        }
        //
        //
        //   what if all random here?
        //
        int myPictureToDrop =  (int) [[myPicturesArray objectAtIndex:myPic] integerValue];
        if (myAllRandomImagesFlag) {
            [self myAssignImageNumber:myPictureToDrop];
        }
        
        //        NSLog(@"Dropping Picture Number %d",myPictureToDrop);
        [self myDropPictureNumber:myPictureToDrop];
        [self myStartDropPicturesTimer];
    }
}




-(void)myStartDropPicturesTimer{
    //    float myRandomInterval = ((arc4random()%50)/10.0)+0.5;
    float myRandomInterval = (arc4random()%5/10.0+1.0);
    
    if (myOSVersion < 10.0) {
        myRandomInterval = myRandomInterval + 1.5;
    }
    NSLog(@"Interval is %f",myRandomInterval);
    myDropPicturesTimer = [NSTimer scheduledTimerWithTimeInterval:myRandomInterval target:self selector:@selector(myDropPictures) userInfo:nil repeats:NO];
}

-(void)myMusicSelected{
    NSLog(@"in myMusicSelected.  URL is %@",myMusicURL);
    // Don't start music if we started in mic mode
    if (myStartedInMicMode) {
        NSLog(@">>> Skipping myMusicSelected - in mic mode");
        return;
    }
    myAudioPlayer = nil;
    [self myStartTheMusic];

    // Refresh the audio display with new song info
    [self mySetupAudioDisplay];
}


-(void)willMoveFromView:(SKView *)view{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"playpause" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"selectedmusic" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"restartmusic" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"musicselected" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"assignimage1" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"assignimage2" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"assignimage3" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"assignimage4" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"assignimage5" object:nil];
}

-(void)mySendQuitNotification{
    NSLog(@" in mySendQuitNotification");
    [[NSNotificationCenter defaultCenter] postNotificationName:@"quitnotifictaion" object:nil];
}


-(void)myAssignImageNumber:  (int) theImageNumber{
    
    
    int myTargetImageSizeFromLibrary = 160;
//    int myTargetImageSizeFromLibrary = 300;
    
    
    
    
    
    
    NSLog(@"GameScene in Assign ImageNumber with Image Number %d",theImageNumber);
    if (theImageNumber > 5) {
        return;
    }
    [self->myImageManager requestImageForAsset:myPhotos[arc4random()%myPhotos.count] targetSize:CGSizeMake(myTargetImageSizeFromLibrary, myTargetImageSizeFromLibrary) contentMode:PHImageContentModeAspectFit options:nil resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        if (result) {
            switch (theImageNumber) {
                case 1:
                    self->mySpriteImage1 = result;
                    [[self myImageSprite1] setTexture:[SKTexture textureWithImage:self->mySpriteImage1]];
                    break;
                case 2:
                    self->mySpriteImage2 = result;
                    [[self myImageSprite2] setTexture:[SKTexture textureWithImage:self->mySpriteImage2]];
                    break;
                case 3:
                    self->mySpriteImage3 = result;
                    [[self myImageSprite3] setTexture:[SKTexture textureWithImage:self->mySpriteImage3]];
                    break;
                case 4:
                    self->mySpriteImage4 = result;
                    [[self myImageSprite4] setTexture:[SKTexture textureWithImage:self->mySpriteImage4]];
                    break;
                case 5:
                    self->mySpriteImage5 = result;
                    [[self myImageSprite5] setTexture:[SKTexture textureWithImage:self->mySpriteImage5]];
                    break;
                default:
                    break;
            }
        } else {
            NSLog(@"error retreiving photo");
        }
    }];
}



-(void)myAssignImage1{
    NSLog(@"GameScene in Assign Image 1");
    [self->myImageManager requestImageForAsset:myPhotos[arc4random()%myPhotos.count] targetSize:CGSizeMake(160, 160) contentMode:PHImageContentModeAspectFit options:nil resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        if (result) {
            self->mySpriteImage1 = result;
            [[self myImageSprite1] setTexture:[SKTexture textureWithImage:self->mySpriteImage1]];
        } else {
            NSLog(@"error retreiving photo");
        }
    }];
}
-(void)myAssignImage2{
    [self->myImageManager requestImageForAsset:myPhotos[arc4random()%myPhotos.count] targetSize:CGSizeMake(160, 160) contentMode:PHImageContentModeAspectFit options:nil resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        if (result) {
            self->mySpriteImage2 = result;
            [[self myImageSprite2] setTexture:[SKTexture textureWithImage:self->mySpriteImage2]];
        } else {
            NSLog(@"error retreiving photo");
        }
    }];
}
-(void)myAssignImage3{
    [self->myImageManager requestImageForAsset:myPhotos[arc4random()%myPhotos.count] targetSize:CGSizeMake(160, 160) contentMode:PHImageContentModeAspectFit options:nil resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        if (result) {
            self->mySpriteImage3 = result;
            [[self myImageSprite3] setTexture:[SKTexture textureWithImage:self->mySpriteImage3]];
        } else {
            NSLog(@"error retreiving photo");
        }
    }];
}
-(void)myAssignImage4{
    [self->myImageManager requestImageForAsset:myPhotos[arc4random()%myPhotos.count] targetSize:CGSizeMake(160, 160) contentMode:PHImageContentModeAspectFit options:nil resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        if (result) {
            self->mySpriteImage4 = result;
            [[self myImageSprite4] setTexture:[SKTexture textureWithImage:self->mySpriteImage4]];
        } else {
            NSLog(@"error retreiving photo");
        }
    }];
}
-(void)myAssignImage5{
    [self->myImageManager requestImageForAsset:myPhotos[arc4random()%myPhotos.count] targetSize:CGSizeMake(160, 160) contentMode:PHImageContentModeAspectFit options:nil resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        if (result) {
            self->mySpriteImage5 = result;
            [[self myImageSprite5] setTexture:[SKTexture textureWithImage:self->mySpriteImage5]];
        } else {
            NSLog(@"error retreiving photo");
        }
    }];
}




-(void)didMoveToView:(SKView *)view {
    NSLog(@">>> didMoveToView CALLED: myStartedInMicMode=%d, myResizeMethod=%d", myStartedInMicMode, myResizeMethod);
    [self.view setShouldCullNonVisibleNodes:YES];
    //    [self.view setShowsFPS:YES];
    //    [self.view setShowsDrawCount:YES];
    //    [self.view setShowsNodeCount:YES];
    //    [self.view setShowsQuadCount:YES];
    
    my100OffsetRandomSource = [GKRandomDistribution distributionWithLowestValue:-100 highestValue:100];
    myShuffledRandomSource = [GKShuffledDistribution distributionWithLowestValue:1 highestValue:18];
    
    [[PHPhotoLibrary sharedPhotoLibrary] registerChangeObserver:self];
    
    myPhotos = [[PHFetchResult alloc] init];
    //    PHFetchResult *myAlbums = [[PHFetchResult alloc] init];
    //    PHFetchResult *myCollections = [[PHFetchResult alloc] init];
    PHFetchOptions *myFetchOptions = [[PHFetchOptions alloc] init];
    
    [myFetchOptions setSortDescriptors:(NSArray<NSSortDescriptor *> * _Nullable) @[
                                                                                   [NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:YES selector:NULL]]];
    myPhotos = [PHAsset fetchAssetsWithOptions:myFetchOptions];
    
    
    
    myImageManager = [[PHImageManager alloc] init];



    // Delay music/mic decision to ensure properties are set
    // (presentScene may trigger didMoveToView before property setters complete)
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@">>> DELAYED CHECK: myStartedInMicMode=%d, myResizeMethod=%d", self->myStartedInMicMode, self->myResizeMethod);
        if (self->myStartedInMicMode) {
            // Mic mode - start mic input, no music
            NSLog(@">>> Starting MIC mode");
            [self myStartMicInput];
        } else {
            // Music mode - start music
            NSLog(@">>> Starting MUSIC mode");
            [self myStartTheMusic];
        }
    });
    [self myStartTheGame];
    [self myMakeMenuReminderLabel];

    // Setup audio display after a short delay to ensure mode is determined
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self mySetupAudioDisplay];
    });

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(myMusicSelected) name:@"musicselected" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(myPlayPause) name:@"playpause" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(myStartTheMusic) name:@"selectedmusic" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(myRestartTheMusic) name:@"restartmusic" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(myAssignImage1) name:@"assignimage1" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(myAssignImage2) name:@"assignimage2" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(myAssignImage3) name:@"assignimage3" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(myAssignImage4) name:@"assignimage4" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(myAssignImage5) name:@"assignimage5" object:nil];
    
    UITapGestureRecognizer *myTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(mySendQuitNotification)];
    [self.view addGestureRecognizer:myTapGestureRecognizer];
    //
    NSLog(@"in Game Scene myPicturesArray %@",myPicturesArray);
    
}


-(void)myRestartTheMusic{
    // Don't restart music if we started in mic mode
    if (myStartedInMicMode) {
        return;
    }
    [myAudioPlayer stop];
    [myAudioPlayer setCurrentTime:0.0];
    [myAudioPlayer prepareToPlay];
    [myAudioPlayer setDelegate: self];
    [myAudioPlayer setMeteringEnabled:YES];
    [myAudioPlayer setNumberOfLoops:-1];
    [myAudioPlayer play];
}




-(void)myStartTheMusic{
    NSLog(@">>> myStartTheMusic CALLED: myStartedInMicMode=%d", myStartedInMicMode);
    // Don't start music if we started in mic mode
    if (myStartedInMicMode) {
        NSLog(@">>> Skipping music start - in mic mode");
        return;
    }

    // Turn off mic when music starts
    [self myStopMicInput];

    NSLog(@">>> Starting music...");

    NSLog(@"My Test Int %d   My Test Number %@ in GameScene.m",myTestInt,myTestNumber);
    NSLog(@"Music URL in GameScene.m %@",myMusicURL);
    NSURL *fileURL;
    if (myMusicURL) {
        fileURL = myMusicURL;
    } else {
        NSString *soundFilePath =
        //                            [[NSBundle mainBundle] pathForResource: @"03 Respect"
        //                    [[NSBundle mainBundle] pathForResource: @"Normalized 03 Respect"
        //                 [[NSBundle mainBundle] pathForResource: @"Smooth Criminal"
        //             [[NSBundle mainBundle] pathForResource: @"01 Welcome to My Life"
        //                         [[NSBundle mainBundle] pathForResource: @"12 Desafinado"
        //                 [[NSBundle mainBundle] pathForResource: @"Normalized 12 Desafinado"
        //                 [[NSBundle mainBundle] pathForResource: @"05 Dream On"
        [[NSBundle mainBundle] pathForResource: @"Skrxlla - Caution"
                                        ofType: @"mp3"];
        fileURL = [[NSURL alloc] initFileURLWithPath: soundFilePath];
    }
    NSLog(@"Music URL %@, Test Number %@",myMusicURL,myTestNumber);
    
    
    AVAudioPlayer *newPlayer =
    //    [[AVAudioPlayer alloc] initWithContentsOfURL: myMusicURL
    [[AVAudioPlayer alloc] initWithContentsOfURL: fileURL
                                           error: nil];
    self.myAudioPlayer = newPlayer;
    [myAudioPlayer prepareToPlay];
    [myAudioPlayer setDelegate: self];
    [myAudioPlayer setMeteringEnabled:YES];
    [myAudioPlayer setNumberOfLoops:-1];
    [myAudioPlayer play];
}


-(void)myPlayPause{
    // Don't control music if we started in mic mode
    if (myStartedInMicMode) {
        return;
    }
    if (myAudioPlayer.isPlaying) {
        [myAudioPlayer stop];
    } else {
        [myAudioPlayer play];
    }
}

-(void)myStartTheGame{
    
    myProcessInfo = [NSProcessInfo processInfo];
    myOSVersion = myProcessInfo.operatingSystemVersion.majorVersion;
    NSLog(@"Operating System Version is %ld.%ld",(long)myProcessInfo.operatingSystemVersion.majorVersion, (long)myProcessInfo.operatingSystemVersion.minorVersion);
    
    
    
    myFrameWidth = self.view.frame.size.width;
    
    myImageSprite1 = [SKSpriteNode spriteNodeWithTexture:[SKTexture textureWithImage:mySpriteImage1]];
    myImageSprite2 = [SKSpriteNode spriteNodeWithTexture:[SKTexture textureWithImage:mySpriteImage2]];
    myImageSprite3 = [SKSpriteNode spriteNodeWithTexture:[SKTexture textureWithImage:mySpriteImage3]];
    myImageSprite4 = [SKSpriteNode spriteNodeWithTexture:[SKTexture textureWithImage:mySpriteImage4]];
    myImageSprite5 = [SKSpriteNode spriteNodeWithTexture:[SKTexture textureWithImage:mySpriteImage5]];
    myHeavyImpactFeedbackGenerator = [[UIImpactFeedbackGenerator alloc] initWithStyle:UIImpactFeedbackStyleHeavy];
    myMediumImpactFeedbackGenerator = [[UIImpactFeedbackGenerator alloc] initWithStyle:UIImpactFeedbackStyleMedium];
    myLightImpactFeedbackGenerator = [[UIImpactFeedbackGenerator alloc] initWithStyle:UIImpactFeedbackStyleLight];
    myUISelectionFeedbackGenerator = [[UISelectionFeedbackGenerator alloc] init];
    myNotificationFeedbackGenerator = [[UINotificationFeedbackGenerator alloc] init];
    
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
        [self->myNotificationFeedbackGenerator notificationOccurred:UINotificationFeedbackTypeSuccess];
    }],
                                          [SKAction waitForDuration:0.75],
                                          [SKAction customActionWithDuration:0.1 actionBlock:^(SKNode * _Nonnull node, CGFloat elapsedTime) {
        AudioServicesPlayAlertSound(kSystemSoundID_Vibrate);
    }],                                   ]] ];
    
//    myScore = 0;
    //    [self myMakeScoreLabels];
    [self myStartDropPicturesTimer];
//    NSString *mySnowParticlePath = [[NSBundle mainBundle] pathForResource:@"mySnowEmitter" ofType:@"sks"];
//    myCustomEmitterNode *myTempSnowParticle = [NSKeyedUnarchiver unarchiveObjectWithFile:mySnowParticlePath];
//    mySnowParticle = [myTempSnowParticle copy];
//    NSString *myPictureCloudPath = [[NSBundle mainBundle] pathForResource:@"myCloudEmitter" ofType:@"sks"];
//    myCustomEmitterNode *myCloudTempParticle =  [NSKeyedUnarchiver unarchiveObjectWithFile:myPictureCloudPath];
//    myCloudParticle = [myCloudTempParticle copy];
    // rz set the gravity to be light   (0.5 looks ok)
    //    [self.physicsWorld setGravity:CGVectorMake(0.0, -0.5)];
    
    [self.physicsWorld setGravity:CGVectorMake(0.0, -9.5)];

    // Set beautiful dark background
    [self setBackgroundColor:[SKColor colorWithRed:0.02 green:0.0 blue:0.08 alpha:1.0]];

    // Add animated gradient background
    [self createAnimatedBackgroundGradient];

    [self.view setIgnoresSiblingOrder:YES];
    self.physicsBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:self.frame];
    //
    //  contact 0x09 is the edge of the scene
    self.physicsBody.contactTestBitMask = 0x09;
    self.physicsWorld.contactDelegate = self;

    // Celebrate game start!
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self celebrationEffect];
    });
}



-(SKLabelNode *)createMagicalLabelWithText:(NSString *)text fontSize:(CGFloat)fontSize color:(SKColor *)color {
    SKLabelNode *label = [SKLabelNode labelNodeWithFontNamed:@"AvenirNext-Bold"];
    label.text = text;
    label.fontSize = fontSize;
    label.fontColor = color;
    label.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeCenter;

    // Add glow effect
    SKLabelNode *glowLabel = [label copy];
    glowLabel.fontColor = color;
    glowLabel.alpha = 0.6;
    glowLabel.zPosition = -1;

    SKEffectNode *glowEffect = [SKEffectNode node];
    glowEffect.shouldRasterize = YES;
    glowEffect.filter = [CIFilter filterWithName:@"CIGaussianBlur" keysAndValues:@"inputRadius", @8.0, nil];
    [glowEffect addChild:glowLabel];
    [label addChild:glowEffect];

    // Add sparkle animation
    SKAction *pulseAction = [SKAction repeatActionForever:[SKAction sequence:@[
        [SKAction group:@[
            [SKAction scaleTo:1.05 duration:0.8],
            [SKAction fadeAlphaTo:0.9 duration:0.8]
        ]],
        [SKAction group:@[
            [SKAction scaleTo:1.0 duration:0.8],
            [SKAction fadeAlphaTo:1.0 duration:0.8]
        ]]
    ]]];
    [label runAction:pulseAction];

    return label;
}

-(void)myMakeIntroLabels{
    if (![self childNodeWithName:@"hold on"]) {
        // Create magical "Let's Dance!" intro label
        SKLabelNode *myHoldOnLabel = [self createMagicalLabelWithText:@"Let's Dance!" fontSize:32.0 color:MAGIC_PINK];
        myHoldOnLabel.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame) + 100);
        [myHoldOnLabel setZPosition:20.0];
        [myHoldOnLabel setName:@"hold on"];
        myHoldOnLabel.alpha = 0;
        [myHoldOnLabel setScale:0.5];
        [self addChild:myHoldOnLabel];

        // Entrance animation
        [myHoldOnLabel runAction:[SKAction sequence:@[
            [SKAction group:@[
                [SKAction fadeAlphaTo:1.0 duration:0.4],
                [SKAction scaleTo:1.2 duration:0.4]
            ]],
            [SKAction scaleTo:1.0 duration:0.2],
            [SKAction waitForDuration:1.5],
            [SKAction group:@[
                [SKAction fadeAlphaTo:0.0 duration:0.5],
                [SKAction scaleTo:1.5 duration:0.5]
            ]],
            [SKAction removeFromParent]
        ]]];

        // Create sparkle burst at label position
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self createSparkleEffectAtPosition:myHoldOnLabel.position withColor:MAGIC_PINK];
        });
    }

    if ([self childNodeWithName:@"get"]) {
        SKAction *myIntroHelperLabelAction = [SKAction repeatActionForever:[SKAction
                                                                            sequence:@[
                                                                                       [SKAction waitForDuration:1.0],
                                                                                       [SKAction fadeAlphaTo:1.0 duration:0.5],
                                                                                       [SKAction waitForDuration:1.0],
                                                                                       [SKAction fadeAlphaTo:0.0 duration:0.5],
                                                                                       [SKAction waitForDuration:60.0],
                                                                                       ]]];

        // Create magical labels with glow
        SKLabelNode *myLabel = [self createMagicalLabelWithText:@"Get" fontSize:myImageSpriteSize/4.0 color:MAGIC_CYAN];
        SKLabelNode *my2ndLabel = [self createMagicalLabelWithText:@"Ready!" fontSize:myImageSpriteSize/4.0 color:MAGIC_GOLD];

        [myLabel setName:@"get"];
        [my2ndLabel setName:@"ready"];
        [myLabel setZPosition:20.0];
        [my2ndLabel setZPosition:20.0];
        myLabel.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame) - 200);
        my2ndLabel.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame) - (200 + myImageSpriteSize / 3.0));
        [self addChild:myLabel];
        [self addChild:my2ndLabel];
        [myLabel setAlpha:0.0];
        [my2ndLabel setAlpha:0.0];
        [myLabel runAction:myIntroHelperLabelAction];
        [my2ndLabel runAction:myIntroHelperLabelAction];
    }
}


-(void)myMakeMenuReminderLabel{
    if (![self childNodeWithName:@"tap for label"]) {
        SKLabelNode *myTapForMenuLabel = [SKLabelNode labelNodeWithText:@"Tap for Menus"];
        [myTapForMenuLabel setFontColor:[UIColor whiteColor]];
        [myTapForMenuLabel setFontSize:18.0];
        [myTapForMenuLabel setName:@"tap for label"];
        [myTapForMenuLabel setPosition:CGPointMake(CGRectGetMidX(self.view.frame), 10.0)  ];

        // Add glow effect to label
        SKLabelNode *glowLabel = [myTapForMenuLabel copy];
        [glowLabel setFontColor:MAGIC_CYAN];
        [glowLabel setAlpha:0.5];
        [glowLabel setZPosition:-1];
        SKEffectNode *glowEffect = [SKEffectNode node];
        glowEffect.shouldRasterize = YES;
        glowEffect.filter = [CIFilter filterWithName:@"CIGaussianBlur" keysAndValues:@"inputRadius", @5.0, nil];
        [glowEffect addChild:glowLabel];
        [myTapForMenuLabel addChild:glowEffect];

        [self addChild:myTapForMenuLabel];
        [myTapForMenuLabel runAction:[SKAction repeatActionForever:[SKAction sequence:@[
            [SKAction waitForDuration:30.0],
            [SKAction fadeAlphaTo:0.1 duration:10],
            [SKAction fadeAlphaTo:1.0 duration:20.0],
        ]]]];
    }
}

#pragma mark - Audio Display (Song Title, Mic Indicator, VU Meter)

-(void)mySetupAudioDisplay {
    // Remove existing display if present
    SKNode *existingDisplay = [self childNodeWithName:@"audioDisplayContainer"];
    if (existingDisplay) {
        [existingDisplay removeFromParent];
    }

    // Create container node for all audio display elements
    myAudioDisplayNode = [SKNode node];
    myAudioDisplayNode.name = @"audioDisplayContainer";
    myAudioDisplayNode.zPosition = 50;
    myAudioDisplayNode.position = CGPointMake(CGRectGetMidX(self.frame), self.frame.size.height - 60);
    [self addChild:myAudioDisplayNode];

    // Create background pill shape
    CGFloat pillWidth = MIN(self.frame.size.width - 40, 320);
    CGFloat pillHeight = 50;
    SKShapeNode *backgroundPill = [SKShapeNode shapeNodeWithRectOfSize:CGSizeMake(pillWidth, pillHeight) cornerRadius:pillHeight/2];
    backgroundPill.fillColor = [SKColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.6];
    backgroundPill.strokeColor = [SKColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.2];
    backgroundPill.lineWidth = 1.5;
    backgroundPill.name = @"audioDisplayBG";
    [myAudioDisplayNode addChild:backgroundPill];

    // Add subtle inner glow
    SKShapeNode *innerGlow = [SKShapeNode shapeNodeWithRectOfSize:CGSizeMake(pillWidth - 4, pillHeight - 4) cornerRadius:(pillHeight-4)/2];
    innerGlow.fillColor = [SKColor clearColor];
    innerGlow.strokeColor = [SKColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.1];
    innerGlow.lineWidth = 1;
    [myAudioDisplayNode addChild:innerGlow];

    // Determine display mode
    BOOL isMicMode = myStartedInMicMode;

    if (isMicMode) {
        // --- MIC MODE DISPLAY ---

        // Mic icon (using unicode microphone or simple shape)
        SKLabelNode *micIcon = [SKLabelNode labelNodeWithFontNamed:@"AvenirNext-Bold"];
        micIcon.text = @"MIC";
        micIcon.fontSize = 12;
        micIcon.fontColor = MAGIC_PINK;
        micIcon.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeLeft;
        micIcon.verticalAlignmentMode = SKLabelVerticalAlignmentModeCenter;
        micIcon.position = CGPointMake(-pillWidth/2 + 20, 8);
        micIcon.name = @"micIcon";
        [myAudioDisplayNode addChild:micIcon];

        // "Listening..." text with pulsing animation
        SKLabelNode *micLabel = [SKLabelNode labelNodeWithFontNamed:@"AvenirNext-Medium"];
        micLabel.text = @"Listening to you...";
        micLabel.fontSize = 14;
        micLabel.fontColor = [SKColor whiteColor];
        micLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeLeft;
        micLabel.verticalAlignmentMode = SKLabelVerticalAlignmentModeCenter;
        micLabel.position = CGPointMake(-pillWidth/2 + 20, -8);
        micLabel.name = @"micLabel";
        [myAudioDisplayNode addChild:micLabel];

        // Pulsing mic indicator dot
        SKShapeNode *pulsingDot = [SKShapeNode shapeNodeWithCircleOfRadius:6];
        pulsingDot.fillColor = MAGIC_PINK;
        pulsingDot.strokeColor = [SKColor clearColor];
        pulsingDot.glowWidth = 4;
        pulsingDot.position = CGPointMake(pillWidth/2 - 30, 0);
        pulsingDot.name = @"pulsingDot";
        [myAudioDisplayNode addChild:pulsingDot];

        // Pulsing animation
        SKAction *pulseAction = [SKAction repeatActionForever:[SKAction sequence:@[
            [SKAction group:@[
                [SKAction scaleTo:1.3 duration:0.5],
                [SKAction fadeAlphaTo:0.5 duration:0.5]
            ]],
            [SKAction group:@[
                [SKAction scaleTo:0.8 duration:0.5],
                [SKAction fadeAlphaTo:1.0 duration:0.5]
            ]]
        ]]];
        [pulsingDot runAction:pulseAction];

    } else {
        // --- MUSIC MODE DISPLAY ---

        // Music note icon
        SKLabelNode *musicIcon = [SKLabelNode labelNodeWithFontNamed:@"AvenirNext-Bold"];
        musicIcon.text = @"NOW PLAYING";
        musicIcon.fontSize = 10;
        musicIcon.fontColor = MAGIC_CYAN;
        musicIcon.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeLeft;
        musicIcon.verticalAlignmentMode = SKLabelVerticalAlignmentModeCenter;
        musicIcon.position = CGPointMake(-pillWidth/2 + 20, 12);
        musicIcon.name = @"nowPlayingLabel";
        [myAudioDisplayNode addChild:musicIcon];

        // Song title with scrolling if too long
        NSString *displayTitle = mySongTitle ? mySongTitle : @"Photo Dance Party!";
        SKLabelNode *titleLabel = [SKLabelNode labelNodeWithFontNamed:@"AvenirNext-DemiBold"];
        titleLabel.text = displayTitle;
        titleLabel.fontSize = 15;
        titleLabel.fontColor = [SKColor whiteColor];
        titleLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeLeft;
        titleLabel.verticalAlignmentMode = SKLabelVerticalAlignmentModeCenter;
        titleLabel.position = CGPointMake(-pillWidth/2 + 20, -6);
        titleLabel.name = @"songTitleLabel";
        [myAudioDisplayNode addChild:titleLabel];

        // Artist name if available
        if (mySongArtist && mySongArtist.length > 0) {
            titleLabel.position = CGPointMake(-pillWidth/2 + 20, 0);

            SKLabelNode *artistLabel = [SKLabelNode labelNodeWithFontNamed:@"AvenirNext-Regular"];
            artistLabel.text = mySongArtist;
            artistLabel.fontSize = 11;
            artistLabel.fontColor = [SKColor colorWithRed:0.7 green:0.7 blue:0.7 alpha:1.0];
            artistLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeLeft;
            artistLabel.verticalAlignmentMode = SKLabelVerticalAlignmentModeCenter;
            artistLabel.position = CGPointMake(-pillWidth/2 + 20, -14);
            artistLabel.name = @"artistLabel";
            [myAudioDisplayNode addChild:artistLabel];
        }

        // Music bars - controlled by audio level in myUpdateAudioDisplay
        CGFloat barsStartX = pillWidth/2 - 45;
        for (int i = 0; i < 4; i++) {
            SKShapeNode *bar = [SKShapeNode shapeNodeWithRectOfSize:CGSizeMake(4, 15) cornerRadius:2];
            bar.fillColor = MAGIC_GOLD;
            bar.strokeColor = [SKColor clearColor];
            bar.position = CGPointMake(barsStartX + i * 8, 0);
            bar.name = [NSString stringWithFormat:@"musicBar%d", i];
            [bar setYScale:0.3];  // Start at resting state
            [myAudioDisplayNode addChild:bar];
        }
    }

    // --- VU METER (shown in both modes) ---
    CGFloat vuMeterWidth = pillWidth - 40;
    CGFloat vuMeterHeight = 4;
    CGFloat vuMeterY = -pillHeight/2 - 12;

    // VU meter background
    SKShapeNode *vuMeterBG = [SKShapeNode shapeNodeWithRectOfSize:CGSizeMake(vuMeterWidth, vuMeterHeight) cornerRadius:vuMeterHeight/2];
    vuMeterBG.fillColor = [SKColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:0.8];
    vuMeterBG.strokeColor = [SKColor clearColor];
    vuMeterBG.position = CGPointMake(0, vuMeterY);
    vuMeterBG.name = @"vuMeterBG";
    [myAudioDisplayNode addChild:vuMeterBG];

    // VU meter fill - use a container node so we can scale from left edge
    SKNode *vuMeterFillContainer = [SKNode node];
    vuMeterFillContainer.position = CGPointMake(-vuMeterWidth/2, vuMeterY);
    vuMeterFillContainer.name = @"vuMeterFillContainer";
    [myAudioDisplayNode addChild:vuMeterFillContainer];

    SKShapeNode *vuMeterFill = [SKShapeNode shapeNodeWithRectOfSize:CGSizeMake(2, vuMeterHeight - 1) cornerRadius:(vuMeterHeight-1)/2];
    vuMeterFill.fillColor = MAGIC_CYAN;
    vuMeterFill.strokeColor = [SKColor clearColor];
    vuMeterFill.position = CGPointMake(1, 0);  // Offset so scaling appears from left
    vuMeterFill.name = @"vuMeterFill";
    [vuMeterFillContainer addChild:vuMeterFill];

    // VU meter glow
    SKShapeNode *vuMeterGlow = [SKShapeNode shapeNodeWithRectOfSize:CGSizeMake(2, vuMeterHeight + 4) cornerRadius:(vuMeterHeight+4)/2];
    vuMeterGlow.fillColor = MAGIC_CYAN;
    vuMeterGlow.strokeColor = [SKColor clearColor];
    vuMeterGlow.alpha = 0.4;
    vuMeterGlow.position = CGPointMake(1, 0);
    vuMeterGlow.name = @"vuMeterGlow";
    [vuMeterFillContainer addChild:vuMeterGlow];

    // Entrance animation for the whole display
    myAudioDisplayNode.alpha = 0;
    [myAudioDisplayNode setScale:0.8];
    [myAudioDisplayNode runAction:[SKAction group:@[
        [SKAction fadeInWithDuration:0.5],
        [SKAction scaleTo:1.0 duration:0.5]
    ]]];
}

-(void)myUpdateAudioDisplay {
    if (!myAudioDisplayNode) return;

    // Check if we're actually producing audio
    BOOL isAudioActive = NO;
    if (myStartedInMicMode) {
        isAudioActive = myMicInputEnabled && myMicRecorder.isRecording;
    } else {
        isAudioActive = myAudioPlayer && myAudioPlayer.isPlaying;
    }

    // Calculate VU meter level based on audio power
    CGFloat vuMeterWidth = MIN(self.frame.size.width - 40, 320) - 40;

    // Convert dB power to linear amplitude (0-1 range)
    // myInstantPower is in dB (typically -160 to 0, where 0 is loudest)
    CGFloat amplitudeLevel = isAudioActive ? [self myDbToAmp:myInstantPower] : 0.0;
    CGFloat normalizedLevel = MIN(amplitudeLevel, 1.0);

    // Add some smoothing - decay faster when not active
    static CGFloat smoothedLevel = 0;
    if (isAudioActive) {
        smoothedLevel = smoothedLevel * 0.6 + normalizedLevel * 0.4;  // Responsive smoothing
    } else {
        smoothedLevel = smoothedLevel * 0.85;  // Decay to zero when paused
        if (smoothedLevel < 0.01) smoothedLevel = 0;
    }

    // Update VU meter fill width - nodes are inside container
    SKNode *vuMeterFillContainer = [myAudioDisplayNode childNodeWithName:@"vuMeterFillContainer"];
    SKNode *vuMeterFill = [vuMeterFillContainer childNodeWithName:@"vuMeterFill"];
    SKNode *vuMeterGlow = [vuMeterFillContainer childNodeWithName:@"vuMeterGlow"];

    if (vuMeterFill) {
        CGFloat targetWidth = MAX(smoothedLevel * vuMeterWidth, 2);
        vuMeterFill.xScale = targetWidth;

        // Change color based on level
        SKShapeNode *fillShape = (SKShapeNode *)vuMeterFill;
        if (smoothedLevel > 0.8) {
            fillShape.fillColor = MAGIC_PINK;
        } else if (smoothedLevel > 0.5) {
            fillShape.fillColor = MAGIC_GOLD;
        } else if (smoothedLevel > 0.25) {
            fillShape.fillColor = MAGIC_GREEN;
        } else {
            fillShape.fillColor = MAGIC_CYAN;
        }
    }

    if (vuMeterGlow) {
        CGFloat targetWidth = MAX(smoothedLevel * vuMeterWidth, 2);
        vuMeterGlow.xScale = targetWidth;

        SKShapeNode *glowShape = (SKShapeNode *)vuMeterGlow;
        SKShapeNode *fillShape = (SKShapeNode *)vuMeterFill;
        if (fillShape) {
            glowShape.fillColor = fillShape.fillColor;
        }
    }

    // Update mic mode pulsing dot size based on audio level
    if (myStartedInMicMode) {
        SKNode *pulsingDot = [myAudioDisplayNode childNodeWithName:@"pulsingDot"];
        if (pulsingDot && normalizedLevel > 0.1) {
            CGFloat scale = 1.0 + normalizedLevel * 0.5;
            [pulsingDot runAction:[SKAction scaleTo:scale duration:0.05]];
        }
    }

    // Make music bars react to actual audio level
    if (!myStartedInMicMode) {
        for (int i = 0; i < 4; i++) {
            SKNode *bar = [myAudioDisplayNode childNodeWithName:[NSString stringWithFormat:@"musicBar%d", i]];
            if (bar) {
                if (isAudioActive && smoothedLevel > 0.05) {
                    // Active - animate bars based on level
                    CGFloat barScale = 0.5 + smoothedLevel * 1.5 * ((arc4random() % 50 + 50) / 100.0);
                    [bar runAction:[SKAction scaleYTo:barScale duration:0.08]];
                } else if (!isAudioActive) {
                    // Paused - shrink bars to resting state
                    [bar runAction:[SKAction scaleYTo:0.3 duration:0.2]];
                }
            }
        }
    }
}

#pragma mark - Magical Visual Effects

-(SKColor *)randomMagicColor {
    NSArray *colors = @[MAGIC_PINK, MAGIC_CYAN, MAGIC_PURPLE, MAGIC_GOLD, MAGIC_GREEN];
    return colors[arc4random() % colors.count];
}

-(void)createSparkleEffectAtPosition:(CGPoint)position withColor:(SKColor *)color {
    // Create a burst of sparkles at the given position
    for (int i = 0; i < 12; i++) {
        SKShapeNode *sparkle = [SKShapeNode shapeNodeWithCircleOfRadius:3.0];
        sparkle.fillColor = color;
        sparkle.strokeColor = [SKColor clearColor];
        sparkle.glowWidth = 4.0;
        sparkle.position = position;
        sparkle.zPosition = 100;
        sparkle.alpha = 1.0;

        // Random direction
        CGFloat angle = (arc4random() % 360) * M_PI / 180.0;
        CGFloat distance = 50 + arc4random() % 100;
        CGFloat endX = position.x + cos(angle) * distance;
        CGFloat endY = position.y + sin(angle) * distance;

        [self addChild:sparkle];

        // Animate outward with fade
        [sparkle runAction:[SKAction sequence:@[
            [SKAction group:@[
                [SKAction moveTo:CGPointMake(endX, endY) duration:0.4],
                [SKAction fadeOutWithDuration:0.4],
                [SKAction scaleTo:0.1 duration:0.4]
            ]],
            [SKAction removeFromParent]
        ]]];
    }
}

-(void)createMagicBurstAtPosition:(CGPoint)position {
    // Create colorful magic burst with multiple rings
    for (int ring = 0; ring < 3; ring++) {
        SKShapeNode *circle = [SKShapeNode shapeNodeWithCircleOfRadius:5.0];
        circle.strokeColor = [self randomMagicColor];
        circle.lineWidth = 3.0;
        circle.fillColor = [SKColor clearColor];
        circle.glowWidth = 5.0;
        circle.position = position;
        circle.zPosition = 99;

        [self addChild:circle];

        CGFloat delay = ring * 0.08;
        CGFloat targetRadius = 80 + ring * 30;

        [circle runAction:[SKAction sequence:@[
            [SKAction waitForDuration:delay],
            [SKAction group:@[
                [SKAction scaleTo:targetRadius / 5.0 duration:0.35],
                [SKAction fadeOutWithDuration:0.35]
            ]],
            [SKAction removeFromParent]
        ]]];
    }

    // Add sparkles on top
    [self createSparkleEffectAtPosition:position withColor:[self randomMagicColor]];
}

-(void)createConfettiBurstAtPosition:(CGPoint)position {
    // Create colorful confetti explosion
    for (int i = 0; i < 20; i++) {
        CGSize size = CGSizeMake(4 + arc4random() % 6, 8 + arc4random() % 10);
        SKSpriteNode *confetti = [SKSpriteNode spriteNodeWithColor:[self randomMagicColor] size:size];
        confetti.position = position;
        confetti.zPosition = 98;

        // Random rotation
        confetti.zRotation = (arc4random() % 360) * M_PI / 180.0;

        // Physics body for natural falling
        confetti.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:size];
        confetti.physicsBody.mass = 0.001;
        confetti.physicsBody.linearDamping = 2.0;
        confetti.physicsBody.angularDamping = 0.5;
        confetti.physicsBody.categoryBitMask = 0;
        confetti.physicsBody.collisionBitMask = 0;
        confetti.physicsBody.contactTestBitMask = 0;

        // Random initial velocity
        CGFloat angle = (arc4random() % 360) * M_PI / 180.0;
        CGFloat speed = 200 + arc4random() % 300;
        [confetti.physicsBody applyImpulse:CGVectorMake(cos(angle) * speed * 0.001, sin(angle) * speed * 0.001 + 0.3)];
        [confetti.physicsBody applyAngularImpulse:0.001 * (arc4random() % 100 - 50)];

        [self addChild:confetti];

        // Fade out and remove
        [confetti runAction:[SKAction sequence:@[
            [SKAction waitForDuration:1.5 + (arc4random() % 100) / 100.0],
            [SKAction fadeOutWithDuration:0.5],
            [SKAction removeFromParent]
        ]]];
    }
}

-(void)addGlowToSprite:(SKSpriteNode *)sprite withColor:(SKColor *)color {
    // Add a pulsing glow effect to a sprite
    SKShapeNode *glow = [SKShapeNode shapeNodeWithRectOfSize:CGSizeMake(sprite.size.width + 20, sprite.size.height + 20) cornerRadius:8];
    glow.fillColor = color;
    glow.strokeColor = [SKColor clearColor];
    glow.alpha = 0.4;
    glow.zPosition = -1;
    glow.name = @"glow";

    // Add blur effect
    SKEffectNode *glowEffect = [SKEffectNode node];
    glowEffect.shouldRasterize = YES;
    glowEffect.filter = [CIFilter filterWithName:@"CIGaussianBlur" keysAndValues:@"inputRadius", @10.0, nil];
    [glowEffect addChild:glow];

    [sprite addChild:glowEffect];

    // Pulsing animation
    [glow runAction:[SKAction repeatActionForever:[SKAction sequence:@[
        [SKAction fadeAlphaTo:0.6 duration:0.5],
        [SKAction fadeAlphaTo:0.3 duration:0.5]
    ]]]];
}

-(void)createRainbowTrailForSprite:(SKSpriteNode *)sprite {
    // Create rainbow trail particles that follow the sprite
    SKEmitterNode *trail = [[SKEmitterNode alloc] init];
    trail.particleTexture = [SKTexture textureWithImage:[self createGlowParticleImage]];
    trail.particleBirthRate = 30;
    trail.particleLifetime = 0.8;
    trail.particleLifetimeRange = 0.3;
    trail.particleScale = 0.3;
    trail.particleScaleRange = 0.1;
    trail.particleScaleSpeed = -0.2;
    trail.particleAlpha = 0.7;
    trail.particleAlphaSpeed = -0.8;
    trail.particleColorBlendFactor = 1.0;
    trail.particleColorSequence = [[SKKeyframeSequence alloc] initWithKeyframeValues:@[
        MAGIC_PINK, MAGIC_PURPLE, MAGIC_CYAN, MAGIC_GREEN, MAGIC_GOLD
    ] times:@[@0.0, @0.25, @0.5, @0.75, @1.0]];
    trail.particleBlendMode = SKBlendModeAdd;
    trail.targetNode = self;
    trail.zPosition = -1;
    trail.name = @"rainbow_trail";

    [sprite addChild:trail];
}

-(UIImage *)createGlowParticleImage {
    CGSize size = CGSizeMake(32, 32);
    UIGraphicsBeginImageContextWithOptions(size, NO, 0);
    CGContextRef ctx = UIGraphicsGetCurrentContext();

    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGFloat colors[] = {1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 0.0};
    CGFloat locations[] = {0.0, 1.0};
    CGGradientRef gradient = CGGradientCreateWithColorComponents(colorSpace, colors, locations, 2);

    CGPoint center = CGPointMake(16, 16);
    CGContextDrawRadialGradient(ctx, gradient, center, 0, center, 16, kCGGradientDrawsBeforeStartLocation);

    CGGradientRelease(gradient);
    CGColorSpaceRelease(colorSpace);

    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

-(void)createAnimatedBackgroundGradient {
    // Create a beautiful animated gradient background
    SKSpriteNode *gradientBG = [SKSpriteNode spriteNodeWithColor:[SKColor blackColor] size:self.size];
    gradientBG.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
    gradientBG.zPosition = -100;
    gradientBG.name = @"gradient_bg";

    // Add shader for animated gradient
    SKShader *gradientShader = [SKShader shaderWithSource:@"\
        void main() {\
            vec2 uv = v_tex_coord;\
            float t = u_time * 0.1;\
            vec3 col1 = vec3(0.1, 0.0, 0.2);\
            vec3 col2 = vec3(0.0, 0.1, 0.3);\
            vec3 col3 = vec3(0.2, 0.0, 0.3);\
            float blend = sin(uv.y * 3.14159 + t) * 0.5 + 0.5;\
            vec3 finalColor = mix(mix(col1, col2, uv.y), col3, blend);\
            gl_FragColor = vec4(finalColor, 1.0);\
        }"];

    gradientBG.shader = gradientShader;
    [self addChild:gradientBG];
}

-(void)celebrationEffect {
    // Big celebration with confetti and sparkles
    CGPoint center = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));

    // Multiple confetti bursts
    for (int i = 0; i < 5; i++) {
        CGFloat delay = i * 0.15;
        CGFloat offsetX = (arc4random() % 200) - 100;
        CGFloat offsetY = (arc4random() % 200) - 100;
        CGPoint pos = CGPointMake(center.x + offsetX, center.y + offsetY);

        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self createConfettiBurstAtPosition:pos];
            [self createMagicBurstAtPosition:pos];
        });
    }
}


-(void)myDropPictureNumber: (int) thePictureNumber{
    
    //    if ((myTimeSinceLastFrame > myScreenRefreshTimeToHoldOffDroppingPictures) || ( self.children.count > myScreenRefreshTimeToHoldOffDroppingPictures ))   {
    //        NSLog(@"Returning Early from DropPictureNumber: --- SLOW OR TOO MANY SPRITES");
    //        return;
    //    }
    SKSpriteNode *myPictureSprite = [SKSpriteNode alloc];
    
    switch (thePictureNumber) {
        case 1:
            myPictureSprite = [myImageSprite1 copy];
            break;
        case 2:
            myPictureSprite = [myImageSprite2 copy];
            break;
        case 3:
            myPictureSprite = [myImageSprite3 copy];
            break;
        case 4:
            myPictureSprite = [myImageSprite4 copy];
            break;
        case 5:
            myPictureSprite = [myImageSprite5 copy];
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
    myPictureSprite.physicsBody = [ SKPhysicsBody bodyWithRectangleOfSize:myPictureSprite.size];
    
    //    myPictureSprite.physicsBody = [ SKPhysicsBody bodyWithCircleOfRadius:myPictureSprite.size.width/2.0];
    float myRandomRestitution = ((arc4random()%50)/50.0)+0.5;
    if (myRandomRestitution > 1.0) {
        myRandomRestitution = 1.0;
    }
    //    NSLog(@"Restitution = %f",myRandomRestitution);
    myPictureSprite.physicsBody.restitution = myRandomRestitution;
    myPictureSprite.physicsBody.contactTestBitMask = 0x02;
    //            [myPictureSprite.physicsBody setMass:myImageSpriteMass];
    
//    [myPictureSprite setName:@"photosprite"];
    [myPictureSprite setName:@"sprite"];

    [myPictureSprite runAction:myImageSpriteAction];
    [myPictureSprite setBlendMode:SKBlendModeReplace];

    // Add magical glow effect with random color
    SKColor *glowColor = [self randomMagicColor];
    [self addGlowToSprite:myPictureSprite withColor:glowColor];

    // Add rainbow trail for extra magic (50% chance)
    if (arc4random() % 2 == 0) {
        [self createRainbowTrailForSprite:myPictureSprite];
    }

    [self addChild:myPictureSprite];

    // Entrance sparkle effect
    [self createSparkleEffectAtPosition:myPictureSprite.position withColor:glowColor];

    [myPictureSprite.physicsBody setLinearDamping:myImageSpriteDamping];
}




-(void)myWarpSprite: (SKSpriteNode *) theSourceSprite  {
    if (myTimeSinceLastFrame > myScreenRefreshTimeToHoldOffDroppingPictures) {
        NSLog(@"Returning Early from WarpSprite --- SLOW");
        return;
    }
    [theSourceSprite removeAllActions];
    SKSpriteNode *theSprite = [theSourceSprite copy];
    [theSourceSprite removeFromParent];
    
    
    
    
//    [theSprite setPhysicsBody:[SKPhysicsBody bodyWithTexture:theSprite.texture size:theSprite.size]];
    
    
    
    
    [theSprite.physicsBody setContactTestBitMask:0x06];

    [theSprite setZPosition:3.0];
//    [theSprite setName:@"warpsprite"];
    [theSprite setName:@"sprite"];
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
    [self addChild:theSprite];
    // sources was mySources
    myWarpGeometryGrid = [SKWarpGeometryGrid gridWithColumns:myWarpGeometryGridSize-1 rows:myWarpGeometryGridSize-1 sourcePositions:mySources destPositions:myDests];
    
    myReverseWarpGeometryGrid = [SKWarpGeometryGrid gridWithColumns:myWarpGeometryGridSize-1 rows:myWarpGeometryGridSize-1 sourcePositions:myDests destPositions:mySources];
    [theSprite setWarpGeometry:myWarpGeometryGrid];
    
    int myRandomWarpAction = arc4random()%4;
    int myRandomSpinDirection = arc4random()%2;
    float myRandomSpinMultiplier = 1.0;
    if (myRandomSpinDirection == 1 ) {
        myRandomSpinMultiplier = -1.0;
    }
    
    
    
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
                                                                      [SKAction warpTo:myWarpGeometryGrid duration:2.5],
                                                                      [SKAction warpTo:myReverseWarpGeometryGrid duration:0.5],
                                                                      ]],
                                                 [SKAction rotateByAngle:(M_PI * myRandomSpinMultiplier) duration:2.0],
                                                 ]]]];
    }
    
    
}




- (void)didEndContact:(SKPhysicsContact *)contact {
    if (myTimeSinceLastFrame > myScreenRefreshTimeToHoldOffDroppingPictures) {
        NSLog(@"Returning Early from DidEndContact --- SLOW");
        return;
    }
    if (contact.bodyA.node.physicsBody.contactTestBitMask < contact.bodyB.node.physicsBody.contactTestBitMask) {
        firstNode = contact.bodyA.node;
        secondNode = contact.bodyB.node;
    } else {
        firstNode = contact.bodyB.node;
        secondNode = contact.bodyA.node;
    }
    
    //    NSLog(@"Contact Force = %f",contact.collisionImpulse);
    
    // photo sprite = 0x02
    //
    NSString *myFilterName = [[NSString alloc] init];
    // wall = 0x09
    //
    //  photo sprite hits photo sprite
    //
    if (( firstNode.physicsBody.contactTestBitMask == 0x02 ) && ( secondNode.physicsBody.contactTestBitMask == 0x02 )  )   {
        // Create magical collision effect at contact point
        CGPoint collisionPoint = contact.contactPoint;
        [self createMagicBurstAtPosition:collisionPoint];

        // Haptic feedback on collision
        [myMediumImpactFeedbackGenerator impactOccurred];

        for (SKNode *theNode in [NSArray arrayWithObjects:firstNode,secondNode, nil]) {
            
            NSInteger  myRandomPhotoPhotoAction = [myShuffledRandomSource nextInt];
            
//            myRandomPhotoPhotoAction = 17;
            
            NSDictionary *myFilterParameters = [[NSDictionary alloc] init];
            myFilterParameters = nil;
  

            switch (myRandomPhotoPhotoAction) {
                case 0:
                    if (myRandomPhotoPhotoAction == 0 && myOSVersion >= 10.0 ) {
                        NSLog(@" warping");
                        [self myWarpSprite:(SKSpriteNode *) theNode];
                    }
                    break;
                case 1:
                    NSLog(@"segmenting");
                    [self myBetterSegmentPhotoAndDrop: (SKSpriteNode *) theNode];
                    break;
                case 2:
                    NSLog(@"particle system");
                    int myRandomEmitterResize = arc4random()%3;
                    [self myParticleSystemFromPhoto: (SKSpriteNode *) theNode withResizeValue:myRandomEmitterResize];
                    break;
                case 3:
                    NSLog(@"cloud");
                    myRandomEmitterResize = arc4random()%2;
                    [self myCloudFromPhoto: (SKSpriteNode *) theNode withResizeValue:myRandomEmitterResize];
                    break;
                case 4:
                    NSLog(@"triangles");
                    myRandomEmitterResize = arc4random()%2;
                    [self myTrianglesFromPhoto: (SKSpriteNode *) theNode withResizeValue:myRandomEmitterResize];
                    break;
                case 5:
                    NSLog(@"circles");
                    myRandomEmitterResize = arc4random()%2;
                    [self myCirclesFromPhoto:(SKSpriteNode *) theNode withResize:myRandomEmitterResize];
                    break;
                case 6:
                    NSLog(@"square");
                    myRandomEmitterResize = arc4random()%2;
                    [self myRandomSquaresFromPhoto: (SKSpriteNode *) theNode withResizeValue:myRandomEmitterResize];
                    break;
                case 7:
                    NSLog(@"quads");
                    myRandomEmitterResize = arc4random()%2;
                    [self myRandomQuadsFromPhoto: (SKSpriteNode *) theNode withResizeValue:myRandomEmitterResize];
                    break;
                case 8:
                    NSLog(@"crop");
                    myRandomEmitterResize = arc4random()%2;
                    [self myCroppedNodesFromPhoto: (SKSpriteNode *) theNode withResizeValue:myRandomEmitterResize];
                    break;
                case 9:
                    myFilterName = @"CIKaleidoscope";
                    NSLog(@"Filter is %@",myFilterName);
                    myRandomEmitterResize = arc4random()%2;
                    [self myEffectNodeFromPhoto:(SKSpriteNode *) theNode withFilter:myFilterName withResizeValue:myRandomEmitterResize withParameters: myFilterParameters ] ;
                    break;
                case 10:
                    myFilterName = @"CIBumpDistortion";
                    NSLog(@"Filter is %@",myFilterName);
                    myRandomEmitterResize = arc4random()%2;
                    [self myEffectNodeFromPhoto:(SKSpriteNode *) theNode withFilter:myFilterName withResizeValue:myRandomEmitterResize withParameters: myFilterParameters ] ;
                    break;
                case 11:
                    myFilterName = @"CIZoomBlur";
                    NSLog(@"Filter is %@",myFilterName);
                    myRandomEmitterResize = arc4random()%2;
                    //
                    [self myEffectNodeFromPhoto:(SKSpriteNode *) theNode withFilter:myFilterName withResizeValue:myRandomEmitterResize withParameters: myFilterParameters ] ;
                    break;
                case 12:
                    myFilterName = @"CIColorPosterize";
                    NSLog(@"Filter is %@",myFilterName);
                    myRandomEmitterResize = arc4random()%2;
                    [self myEffectNodeFromPhoto:(SKSpriteNode *) theNode withFilter:myFilterName withResizeValue:myRandomEmitterResize withParameters: myFilterParameters ] ;
                    break;
                case 13:
                    myFilterName = @"CIPointillize";
                    NSLog(@"Filter is %@",myFilterName);
                    myFilterParameters = [NSDictionary dictionaryWithObjectsAndKeys:@"", @"", nil];
                    myRandomEmitterResize = arc4random()%2;
                    [self myEffectNodeFromPhoto:(SKSpriteNode *) theNode withFilter:myFilterName withResizeValue:myRandomEmitterResize withParameters: myFilterParameters ] ;
                    break;
                case 14:
                    myRandomEmitterResize = arc4random()%2;
                    // below are too expensive to run in real time
                    //
                    //CIDroste - x
                    //CIPointillize
                    //CICrystallize
                    //CICircularScreen
                    //CIComicEffect
                    //CIEightfoldReflectedTile - x
                    //CITriangleKaleidaScope - x
//                    [self myEffectNodeFromPhoto:(SKSpriteNode *) theNode withFilter:@"CIZoomBlur" withResizeValue:myRandomEmitterResize];
                    myFilterName = @"CICrystallize";
                    NSLog(@"Filter is %@",myFilterName);
                    [self myEffectNodeFromPhoto:(SKSpriteNode *) theNode withFilter:myFilterName withResizeValue:myRandomEmitterResize withParameters: myFilterParameters ] ;
                    break;
                case 15:
                    myFilterName = @"CIEdgeWork";
                    NSLog(@"Filter is %@",myFilterName);
                    myRandomEmitterResize = arc4random()%2;
                    [self myEffectNodeFromPhoto:(SKSpriteNode *) theNode withFilter:myFilterName withResizeValue:myRandomEmitterResize withParameters: myFilterParameters ] ;
                    break;
                case 16:
                    myFilterName = @"CIComicEffect";
                    myFilterParameters = nil;
                    NSLog(@"Filter is %@",myFilterName);
                    myRandomEmitterResize = arc4random()%2;
                    [self myEffectNodeFromPhoto:(SKSpriteNode *) theNode withFilter:myFilterName withResizeValue:myRandomEmitterResize withParameters: myFilterParameters ] ;
                    break;
                case 17:
                    myFilterName = @"CICircularWrap";
                    myFilterParameters =   @{
                      @"inputAngle": @5.0,
                      @"inputRadius": @300.0
                      };

                    NSLog(@"Filter is %@",myFilterName);
                    myRandomEmitterResize = arc4random()%2;
                    [self myEffectNodeFromPhoto:(SKSpriteNode *) theNode withFilter:myFilterName withResizeValue:myRandomEmitterResize withParameters: myFilterParameters ] ;
                    break;
                case 18:
//                    myFilterName = @"CIGlassDistortion";
                    myFilterName = @"CIGlassLozenge";
                    NSLog(@"Filter is %@",myFilterName);
                    myRandomEmitterResize = arc4random()%2;
                    [self myEffectNodeFromPhoto:(SKSpriteNode *) theNode withFilter:myFilterName withResizeValue:myRandomEmitterResize withParameters: myFilterParameters ] ;
                    break;
                default:
                    break;
            }
        }
    }
    //
    //
    // photo sprite = 0x02
    //
    // wall = 0x09
    //
    //  if a photo hits the wall
    //
    if(  (  (firstNode.physicsBody.contactTestBitMask == 0x02)  || (firstNode.physicsBody.contactTestBitMask == 0x06) )    && (secondNode.physicsBody.contactTestBitMask == 0x09) )
        
    {
        //        NSLog(@"hit wall");
        //
        //        if ([deviceType isEqualToString:@"iPhone9"]) {
        //            [myLightImpactFeedbackGenerator impactOccurred];
        //        }
    }
    
    // if a warp sprite hits a warp sprite, just do a light impact on new phones
    if((firstNode.physicsBody.contactTestBitMask == 0x06) && (secondNode.physicsBody.contactTestBitMask == 0x06)){
        //
//        if ([deviceType isEqualToString:@"iPhone9"]) {
//            [myLightImpactFeedbackGenerator impactOccurred];
//        }
                [firstNode runAction:[SKAction sequence:@[
                                                          [SKAction waitForDuration:1.5],
//                                                          [SKAction scaleTo:2.5 duration:0.1],
                                                          [SKAction scaleTo:0.1 duration:0.1],
                                                          [SKAction removeFromParent],
                                                          ]]];
                [secondNode runAction:[SKAction sequence:@[
                                                           [SKAction waitForDuration:1.5],
//                                                           [SKAction scaleTo:3.5 duration:0.1],
                                                           [SKAction scaleTo:0.1 duration:0.1],
                                                           [SKAction removeFromParent],
                                                           ]]];
    }
    
    
}







-(void)myTrianglesFromPhoto: (SKSpriteNode *) thePhoto withResizeValue: (int) theValue {
    //    if ([deviceType isEqualToString:@"iPhone9"]) {
    //        [myUISelectionFeedbackGenerator selectionChanged];
    //    }
    NSLog(@"in Triangles");
    
    //    int myResizeValue = theValue;
    
    
    //
    //    0,1       1,1
    //
    //       .5,.5
    //
    //    0,0        1,0
    //
    //
    //
    
    //    CGPoint myLowerLeft = CGPointMake(0.0, 0.0);
    //    CGPoint myLowerRight = CGPointMake(1.0, 0.0);
    //    CGPoint myUpperLeft = CGPointMake(0.0, 1.0);
    //    CGPoint myUpperRight = CGPointMake(1.0, 1.0);
    //    CGPoint myCenter = CGPointMake(0.5, 0.5);
    
    CGMutablePathRef myLeftPath = CGPathCreateMutable();
    CGPathMoveToPoint(myLeftPath, nil, 050, 050);
    CGPathAddLineToPoint(myLeftPath, nil, 00, 00);
    CGPathAddLineToPoint(myLeftPath, nil, 00, 100);
    CGPathCloseSubpath(myLeftPath);
    
    
    
    CGMutablePathRef myTopPath = CGPathCreateMutable();
    CGPathMoveToPoint(myTopPath, nil, 100, 100);
    CGPathAddLineToPoint(myTopPath, nil, 050, 050);
    CGPathAddLineToPoint(myTopPath, nil, 000, 100);
    CGPathCloseSubpath(myTopPath);
    
    CGMutablePathRef myBottomPath = CGPathCreateMutable();
    CGPathMoveToPoint(myBottomPath, nil, 050, 050);
    CGPathAddLineToPoint(myBottomPath, nil, 000, 000);
    CGPathAddLineToPoint(myBottomPath, nil, 100, 00);
    CGPathCloseSubpath(myBottomPath);
    
    CGMutablePathRef myRightPath = CGPathCreateMutable();
    CGPathMoveToPoint(myRightPath, nil, 050, 050);
    CGPathAddLineToPoint(myRightPath, nil, 100, 000);
    CGPathAddLineToPoint(myRightPath, nil, 100, 100);
    CGPathCloseSubpath(myRightPath);
    
    myCustomShapeNode *myLeftTriangle  = [myCustomShapeNode shapeNodeWithPath:myLeftPath];
    myCustomShapeNode *myRightTriangle = [myCustomShapeNode shapeNodeWithPath:myRightPath];
    myCustomShapeNode *myTopTriangle = [myCustomShapeNode shapeNodeWithPath:myTopPath];
    myCustomShapeNode *myBottomTriangle = [myCustomShapeNode shapeNodeWithPath:myBottomPath];
    
    [myLeftTriangle setPhysicsBody:[SKPhysicsBody bodyWithPolygonFromPath:myLeftPath]];
    [myRightTriangle setPhysicsBody:[SKPhysicsBody bodyWithPolygonFromPath:myRightPath]];
    [myTopTriangle setPhysicsBody:[SKPhysicsBody bodyWithPolygonFromPath:myTopPath]];
    [myBottomTriangle setPhysicsBody:[SKPhysicsBody bodyWithPolygonFromPath:myBottomPath]];
    
    
    [myRightTriangle setFillTexture:thePhoto.texture];
    [myLeftTriangle setFillTexture:thePhoto.texture];
    [myBottomTriangle setFillTexture:thePhoto.texture];
    [myTopTriangle setFillTexture:thePhoto.texture];
    
    
    NSArray *myTriangles = [NSArray arrayWithObjects:myLeftTriangle,myRightTriangle,myTopTriangle,myBottomTriangle, nil];
    int myRandomWait = (arc4random()%30/100)+1.5;
    SKAction *myTriangleAction = [SKAction sequence:@[
                                                      [SKAction waitForDuration:myRandomWait],
                                                      [SKAction removeFromParent],
                                                      ]];
    
    int myRandomColorize = arc4random()%2;
    for ( myCustomShapeNode * node  in myTriangles) {
//        [node setName:@"trianglesprite"];
        [node setName:@"sprite"];
        [node setZPosition:4.0];
        [node setMyResizeValue:theValue];
        [node setScale:thePhoto.xScale];
        if (myRandomColorize == 0) {
            float myRandomRed = arc4random()%100;
            float myRandomGreen = arc4random()%100;
            float myRandomBlue = arc4random()%100;
            float myRandomColorBlendFactor = arc4random()%100;
            myRandomRed = myRandomRed/100.0;
            myRandomGreen = myRandomGreen/100.0;
            myRandomBlue = myRandomBlue/100.0;
            myRandomColorBlendFactor = myRandomColorBlendFactor/100.0;
            [node setFillColor:[UIColor colorWithRed:myRandomRed green:myRandomGreen blue:myRandomBlue alpha:1.0]];
        } else {
            [node setFillColor:[UIColor whiteColor]];
        }
        int myRandomLineWidth = arc4random()%5;
        [node setLineWidth:myRandomLineWidth];
        int myRandomGlowWidth = arc4random()%3;
        [node setGlowWidth:myRandomGlowWidth];
        [node setBlendMode:SKBlendModeReplace];
        
        [node setPosition:thePhoto.position];
        [self addChild:node];
        [node runAction:myTriangleAction];
    }
    
}

                     
-(void)myEffectNodeFromPhoto: (SKSpriteNode *) thePhoto withFilter: (NSString *) theFilterName  withResizeValue: (int) theValue  withParameters: (NSDictionary *) theParameters {
    SKEffectNode *myEffectNode = [[SKEffectNode alloc] init];
    myCustomSpriteNode *myBackgroundPicture = [myCustomSpriteNode spriteNodeWithTexture:thePhoto.texture size:CGSizeMake(150.0, 150.0)];
    myEffectNode.position = thePhoto.position;
    [myEffectNode addChild:myBackgroundPicture];
    CIFilter *myFilter = [CIFilter filterWithName:theFilterName] ;
//    NSLog(@"Filter Attribute Keys are %@",myFilter.attributes.allKeys);
//    NSLog(@"Filter Attribute Values are %@",myFilter.attributes.allValues);
    [myEffectNode setFilter:myFilter];
    if ([theFilterName isEqualToString:@"CICircularWrap"]) {
        [myFilter setValuesForKeysWithDictionary:theParameters];
    }
    [myEffectNode setName:@"sprite"];
    [self addChild:myEffectNode];
    [myEffectNode runAction:[SKAction sequence:@[
                                                 [SKAction waitForDuration:3.0],
                                                 [SKAction scaleTo:0.1 duration:0.1],
                                                 [SKAction removeFromParent],
                                                 ]]];
    [thePhoto removeFromParent];
}





-(void)myRandomSquaresFromPhoto: (SKSpriteNode *) thePhoto withResizeValue: (int) theValue {
    for (int i = 1; i <= 15; i++) {
        float myXStart = (arc4random()%100)/100.0;
        float myYStart = (arc4random()%100)/100.0;
        float myXSize =  (arc4random()%100)/100.0;
        float myYSize =  (arc4random()%100)/100.0;
        if (myXStart + myXSize > 1.0) {
            myXSize = 1.0 - myXStart;
        }
        if (myYStart + myYSize > 1.0) {
            myYSize = 1.0 - myYStart;
        }
        SKTexture *myShapeTexture = thePhoto.texture;
        myCustomSpriteNode *myRandomQuad = [[myCustomSpriteNode alloc] init];
        CGPoint myPhotoPosition = CGPointMake(thePhoto.position.x+my100OffsetRandomSource.nextInt, thePhoto.position.y+my100OffsetRandomSource.nextInt);
        [myRandomQuad setPosition:myPhotoPosition];
        [myRandomQuad setSize:CGSizeMake(50.0, 50.0)];
        [myRandomQuad setPhysicsBody:[SKPhysicsBody bodyWithRectangleOfSize:myRandomQuad.size]];
        [myRandomQuad setMyResizeValue:theValue];
        [myRandomQuad setTexture:[SKTexture textureWithRect:CGRectMake(myXStart, myYStart, myXSize, myYSize) inTexture:myShapeTexture]];
//        [myRandomQuad setName:@"square"];
        [myRandomQuad setName:@"sprite"];

        [myRandomQuad runAction:[SKAction sequence:@[
                                                     [SKAction waitForDuration:2.0],
                                                     [SKAction scaleTo:0.1 duration:0.1],
                                                     [SKAction removeFromParent],
                                                     ]]];
        [self addChild:myRandomQuad];
    }
    [thePhoto removeFromParent];
}



-(void)myCroppedNodesFromPhoto: (SKSpriteNode *) thePhoto withResizeValue: (int) theValue {
    
    SKCropNode *myCropNode = [[SKCropNode alloc] init];
    SKSpriteNode  *myImageToBeMasked = [SKSpriteNode spriteNodeWithTexture:thePhoto.texture];
    SKSpriteNode *myMaskNode1;
    int myRandomMask = arc4random()%4;
    switch (myRandomMask) {
        case 0:
            myMaskNode1 = [SKSpriteNode spriteNodeWithTexture:[SKTexture textureWithImageNamed:@"YellowCloud.png"]];
            break;
        case 1:
            myMaskNode1 = [SKSpriteNode spriteNodeWithTexture:[SKTexture textureWithImageNamed:@"Clock.png"]];
            break;
        case 2:
            myMaskNode1 = [SKSpriteNode spriteNodeWithTexture:[SKTexture textureWithImageNamed:@"LargePowerup.png"]];
            break;
        case 3:
            myMaskNode1 = [SKSpriteNode spriteNodeWithTexture:[SKTexture textureWithImageNamed:@"Red No Sign.png"]];
            break;
        default:
            break;
    }
    
//    [myCropNode setXScale:myImageSpriteSize/10.0];
//    [myCropNode setYScale:myImageSpriteSize/10.0];
//    [myMaskNode1 setXScale:myImageSpriteSize/10.0];
//    [myMaskNode1 setYScale:myImageSpriteSize/10.0];
    
    [myMaskNode1 setSize:CGSizeMake(myImageSpriteSize/4.0,myImageSpriteSize/4.0)];
    [myCropNode setScale:10.0];
    [myCropNode setMaskNode:myMaskNode1];
    
    
    [myCropNode addChild:myImageToBeMasked];
    [myCropNode setPosition:thePhoto.position];
    
    [myCropNode setPhysicsBody:[SKPhysicsBody bodyWithRectangleOfSize:thePhoto.size]];
    [myCropNode.physicsBody setRestitution:myImageSpriteRestitution];
    
//    [myCropNode setName:@"crop"];
    [myCropNode setName:@"sprite"];

    [self addChild:myCropNode];
    
    
    [thePhoto removeFromParent];
    
    [myCropNode runAction:[SKAction sequence:@[
//                                               [SKAction applyImpulse:CGVectorMake(0.0, -100.0) duration:1.0],
                                               [SKAction waitForDuration:2.0],
                                               [SKAction scaleTo:0.1 duration:0.1],
                                               [SKAction removeFromParent],
                                               ]]];
    
    
}


-(void)myRandomQuadsFromPhoto: (SKSpriteNode *) thePhoto withResizeValue: (int) theValue {
    
    for (int i = 1; i <=5 ; i++) {
        
        
        CGPoint myLowerLeft = CGPointMake(0.0, 0.0);
        CGPoint myLowerRight = CGPointMake(myLowerLeft.x +(arc4random()%10)+50 ,  myLowerLeft.y+(arc4random()%25)) ;
        CGPoint myUpperRight = CGPointMake(myLowerRight.x+(arc4random()%10) ,   myLowerRight.y + (arc4random()%10)+80.0);
        CGPoint myUpperLeft = CGPointMake(myUpperRight.x - ((arc4random()%10)+80), myUpperRight.y + arc4random()%10);
        CGMutablePathRef myPathRef = CGPathCreateMutable();
        CGPathMoveToPoint(myPathRef, nil, myLowerLeft.x, myLowerLeft.y);
        CGPathAddLineToPoint(myPathRef, nil, myLowerRight.x, myLowerRight.y);
        CGPathAddLineToPoint(myPathRef, nil, myUpperRight.x , myUpperRight.y);
        CGPathAddLineToPoint(myPathRef, nil, myUpperLeft.x , myUpperLeft.y);
        CGPathCloseSubpath(myPathRef);
        
        float myXStart = (arc4random()%100)/100.0;
        float myYStart = (arc4random()%100)/100.0;
        float myXSize =  arc4random()%100;
        float myYSize =  arc4random()%100;
        if (myXStart + myXSize > 1.0) {
            myXSize = 1.0 - myXStart;
        }
        if (myYStart + myYSize > 1.0) {
            myYSize = 1.0 - myYStart;
        }
        SKTexture *myShapeTexture = thePhoto.texture;
        myCustomShapeNode *myRandomQuad = [myCustomShapeNode shapeNodeWithPath:myPathRef];
        
        [myRandomQuad setPhysicsBody:[SKPhysicsBody bodyWithPolygonFromPath:myPathRef]];
        float myRandomRestitution = (arc4random()%100)/100.0;
        [myRandomQuad.physicsBody setRestitution:myRandomRestitution];
        [myRandomQuad setPosition:thePhoto.position];
        [myRandomQuad setZPosition:4.0];
        [myRandomQuad setMyResizeValue:theValue];
        [myRandomQuad setFillTexture:[SKTexture textureWithRect:CGRectMake(myXStart, myYStart, myXSize, myYSize) inTexture:myShapeTexture]];
//        [myRandomQuad setName:@"quad"];
        [myRandomQuad setName:@"sprite"];

        //    [myRandomQuad setXScale:myXSize];
        //    [myRandomQuad setYScale:myYSize];
        
        int myRandomColorize = arc4random()%2;
        if (myRandomColorize == 0) {
            float myRandomRed = arc4random()%100;
            float myRandomGreen = arc4random()%100;
            float myRandomBlue = arc4random()%100;
            float myRandomColorBlendFactor = arc4random()%100;
            myRandomRed = myRandomRed/100.0;
            myRandomGreen = myRandomGreen/100.0;
            myRandomBlue = myRandomBlue/100.0;
            myRandomColorBlendFactor = myRandomColorBlendFactor/100.0;
            [myRandomQuad setFillColor:[UIColor colorWithRed:myRandomRed green:myRandomGreen blue:myRandomBlue alpha:1.0]];
        } else {
            [myRandomQuad setFillColor:[UIColor whiteColor]];
        }
        int myRandomLineWidth = arc4random()%3;
        [myRandomQuad setLineWidth:myRandomLineWidth];
        int myRandomGlowWidth = arc4random()%3;
        [myRandomQuad setGlowWidth:myRandomGlowWidth];
        [thePhoto removeFromParent];
        [self addChild:myRandomQuad];
        [myRandomQuad runAction:[SKAction sequence:@[
                                                     [SKAction waitForDuration:3.0],
                                                     [SKAction fadeAlphaTo:0.1 duration:0.25],
                                                     [SKAction removeFromParent],
                                                     ]]];
    }
    
    
    
    
}




-(void)myCloudFromPhoto: (SKSpriteNode *) thePhoto withResizeValue: (int) theValue {
    SKTexture *myEmitterTexture = thePhoto.texture;
    myCustomEmitterNode *myPP = [[myCustomEmitterNode alloc] init];
    [myPP setPosition:thePhoto.position];
    [thePhoto removeFromParent];
    
    
    
    //    if ([deviceType isEqualToString:@"iPhone9"]) {
    //        [myUISelectionFeedbackGenerator selectionChanged];
    //    }
    
    
    [myPP setResizeValue:theValue];
    [myPP setParticleBirthRate:1000.0];
    int myRandomNumParticlesToEmit = (arc4random()%100)+50;
    [myPP setNumParticlesToEmit:myRandomNumParticlesToEmit];
    [myPP setParticleLifetime:3.0];
    [myPP setParticleSpeed:5.0];
    [myPP setParticleSpeedRange:5.0];
    [myPP setParticleScale:0.1];
    [myPP setParticleScaleRange:0.2];
    [myPP setParticleScaleSpeed:-0.6];
    
    [myPP setParticleTexture:myEmitterTexture];
    float myRandomParticleScale = ((arc4random()%10)/100.0)+0.5;
    [myPP setParticleScale:myRandomParticleScale];
    float myRandomParticlePositionRange = (arc4random()%200)+100.0;
    [myPP setParticlePositionRange:CGVectorMake(myRandomParticlePositionRange, myRandomParticlePositionRange)];
    
    int myRandomParticleWait = arc4random()%3;
    
    
    
    //    int myRandomParticleActionGate = arc4random()%3;
    //    if (myRandomParticleActionGate ==0) {
    //        [myPP setParticleAction:[SKAction sequence:@[
    //                                                     [SKAction scaleXTo:0.1 duration:myRandomParticleWait/2.0],
    //                                                     [SKAction scaleYTo:0.1 duration:myRandomParticleWait/2.0],
    //                                                     ]]];
    //    }
    
    [myPP setZPosition:0.0];
    
    [self addChild:myPP];
    [myPP setParticleBlendMode:SKBlendModeReplace];
    [myPP setName:@"particle system"];
    [myPP runAction:[SKAction sequence:@[
                                         [SKAction waitForDuration:myRandomParticleWait],
                                         [SKAction removeFromParent],
                                         ]]];
}



-(void)myParticleSystemFromPhoto: (SKSpriteNode *) thePhoto withResizeValue: (int) theValue {
    
    SKTexture *myEmitterTexture = thePhoto.texture;
    myCustomEmitterNode *myPP = [[myCustomEmitterNode alloc] init];
    [myPP setPosition:thePhoto.position];
    [thePhoto removeFromParent];
    
    [myPP setParticleBlendMode:SKBlendModeReplace];
    [myPP setName:@"particle system"];
    [myPP setResizeValue:theValue];
    [myPP setParticleBirthRate:1000.0];
    int myRandomNumParticlesToEmit = (arc4random()%150)+50;
    [myPP setNumParticlesToEmit:myRandomNumParticlesToEmit];
    [myPP setParticleLifetime:3.0];
    [myPP setParticleSpeed:200.0];
    [myPP setParticleSpeedRange:1000.0];
    [myPP setParticleScale:0.1];
    [myPP setParticleScaleRange:-0.1];
    [myPP setEmissionAngleRange:M_PI];
    [myPP setParticlePositionRange:CGVectorMake(0.0, 0.0)];
    [myPP setParticleTexture:myEmitterTexture];
    [myPP setZPosition:0.0];
    float myRandomParticleScale = ((arc4random()%10)/20.0)+0.5;
    [myPP setParticleScale:myRandomParticleScale];
    [self addChild:myPP];
    
    
    float myRandomParticleWait = (arc4random()%30)/10.0;
    [myPP runAction:[SKAction sequence:@[
                                         [SKAction waitForDuration:myRandomParticleWait],
                                         [SKAction removeFromParent],
                                         ]]];
}


-(void)myCirclesFromPhoto: (SKSpriteNode *) thePhoto withResize: (int) theResizeValue {
    [thePhoto runAction:[SKAction sequence:@[
                                             [SKAction waitForDuration:3.0],
                                             [SKAction removeFromParent],
                                             ]]];
    SKTexture *myCircleTexture = thePhoto.texture;
    CGPoint myCirclePosition = thePhoto.position;
    int myRandomRadius = (arc4random()%100)+1;
    myCustomShapeNode *myCircle = [myCustomShapeNode shapeNodeWithCircleOfRadius:myRandomRadius];
    [myCircle setPhysicsBody:[SKPhysicsBody bodyWithCircleOfRadius:myRandomRadius]];
    float myRandomRestitution = (arc4random()%100)/100.0;
    [myCircle.physicsBody setRestitution:myRandomRestitution];
//    [myCircle setName:@"circlesprite"];
    [myCircle setName:@"sprite"];

    [myCircle setPosition:myCirclePosition];
    [myCircle setZPosition:4.0];
    int myRandomColorize = arc4random()%2;
    if (myRandomColorize == 0) {
        float myRandomRed = arc4random()%100;
        float myRandomGreen = arc4random()%100;
        float myRandomBlue = arc4random()%100;
        float myRandomColorBlendFactor = arc4random()%100;
        myRandomRed = myRandomRed/100.0;
        myRandomGreen = myRandomGreen/100.0;
        myRandomBlue = myRandomBlue/100.0;
        myRandomColorBlendFactor = myRandomColorBlendFactor/100.0;
        [myCircle setFillColor:[UIColor colorWithRed:myRandomRed green:myRandomGreen blue:myRandomBlue alpha:1.0]];
    } else {
        [myCircle setFillColor:[UIColor whiteColor]];
    }
    int myRandomLineWidth = arc4random()%3;
    [myCircle setLineWidth:myRandomLineWidth];
    int myRandomGlowWidth = arc4random()%3;
    [myCircle setGlowWidth:myRandomGlowWidth];
    
    
    [myCircle setFillTexture:myCircleTexture];
    [myCircle setBlendMode:SKBlendModeReplace];
    SKNode *myCopy1;
    int mySecondCircleGate = arc4random()%2;
    if (mySecondCircleGate) {
        myCopy1 = [myCircle copy];
    }
    //    SKNode *myCopy2 = [myCircle copy];
    //    SKNode *myCopy3 = [myCircle copy];
    //    SKNode *myCopy4 = [myCircle copy];
    float myRandomCircleWait = ((arc4random()%30)/100)+1.5;
    SKAction *myCircleAction = [SKAction sequence:@[
                                                    [SKAction waitForDuration:myRandomCircleWait],
                                                    [SKAction removeFromParent],
                                                    ]];
    [self addChild:myCircle];
    if (mySecondCircleGate) {
        [self addChild:myCopy1];
    }
    //    [self addChild:myCopy2];
    //    [self addChild:myCopy3];
    //    [self addChild:myCopy4];
    NSMutableArray *myCircles = [NSMutableArray arrayWithObjects:myCircle, nil];
    if (mySecondCircleGate) {
        [myCircles addObject:myCopy1];
    }
    for (SKNode *node in myCircles) {
        [node runAction:myCircleAction];
    }
    
}



-(void)myBetterSegmentPhotoAndDrop: (SKSpriteNode *) thePhoto  {
    if (myTimeSinceLastFrame > myScreenRefreshTimeToHoldOffDroppingPictures) {
        NSLog(@"Returning Early from Segment --- SLOW");
        
        return;
    }
    
    //    if ([deviceType isEqualToString:@"iPhone9"]) {
    //        [myHeavyImpactFeedbackGenerator impactOccurred];
    //    }
    
    
    
    
    // first grab the texture.  we'll use the texture from here on
    myTexture = thePhoto.texture;
    int myRandomMass = arc4random()%10;
    int myRandomRestitutionSet = arc4random()%2;
    int myTypeOfDrop = arc4random()%2;
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
    
    
    int myRandomGeometryAction = arc4random()%4;
    //    NSLog(@"Mass %d, Drop %d, Increment %f,Segment %d, Colorize %d, 1st Wait %f, Scale %d, Restitution Set %d, Restitution = %f, 2nd Wait %f, Gravity %d, ScaleTo Time %f, ScaleOut Time %f, Geometry Remove %d",myRandomMass, myTypeOfDrop, myRandomIncrement, myTypeOfSegment, myTypeOfColorize, myRandomFirstWaitFor, myRandomScaleTo, myRandomRestitutionSet, myRandomRestitution,   myRandomSecondWaitFor, myRandomGravity, myRandomScaleToDuration, myRandomScaleOutDuration,myRandomGeometryAction);
    CGPoint myPosition = thePhoto.position;
    //    float myIncrement = 0.10;
    
    //    CGSize myPhotoSize = CGSizeMake(thePhoto.size.width * myIncrement * 2.0, thePhoto.size.height * myIncrement * 2.0 );
    //    float myRandomIncrement = ((arc4random()%9)/10.0)+0.1;
    float myRandomXIncrement = ((arc4random()%50)/100.0);
    if (myRandomXIncrement < 0.1) {
        myRandomXIncrement = 0.1;
    }
    float myRandomYIncrement;
    int myRandomIncrementEqual = arc4random()%3;
    if (myRandomIncrementEqual == 0 ) {
        myRandomYIncrement = myRandomXIncrement;
    } else {
        myRandomYIncrement = ((arc4random()%50)/100.0);
        if (myRandomYIncrement < 0.1) {
            myRandomYIncrement = 0.1;
        }
    }
    
    // make random increment larger for debugging
    //    myRandomIncrement = (myRandomIncrement/100.0)+0.4;
    //    float myIncrement = myRandomIncrement;
    //    CGSize myPhotoSize = CGSizeMake(thePhoto.size.width * myIncrement , thePhoto.size.height * myIncrement  );
    CGSize myPhotoSize = CGSizeMake(thePhoto.size.width * myRandomXIncrement , thePhoto.size.height * myRandomYIncrement  );
    
    for (float x = 0.0 ; x <= (1.0 - myRandomXIncrement) ; x = x + myRandomXIncrement) {
        for (float y = 0.0 ; y <= (1.0 - myRandomYIncrement) ; y = y + myRandomYIncrement) {
            SKSpriteNode *mySegment;
            int myTypeOfSegment = arc4random()%2;
            if (myTypeOfSegment == 0 ) {
                mySegment = [SKSpriteNode spriteNodeWithTexture:[SKTexture textureWithRect:CGRectMake(x, y, myRandomXIncrement, myRandomYIncrement) inTexture:myTexture]];
            } else if (myTypeOfSegment == 1) {
                mySegment = [SKSpriteNode spriteNodeWithTexture:myTexture];
            }
            
            
            
            
            if (myTypeOfDrop == 1) {
                CGVector theOffset = CGVectorMake(x*100.0, y*100.0);
                [mySegment setPosition:CGPointMake(myPosition.x+theOffset.dx, myPosition.y+theOffset.dy)];
            } else if (myTypeOfDrop == 0){
                [mySegment setPosition:myPosition];
            }
            [mySegment setSize:myPhotoSize];
            [mySegment setPhysicsBody:[SKPhysicsBody bodyWithRectangleOfSize:myPhotoSize]];
            [mySegment.physicsBody setMass:myRandomMass];
            if (myRandomRestitutionSet == 0) {
                float myRandomRestitution = ((arc4random()%50)/50.0)+0.5;
                [mySegment.physicsBody setRestitution:myRandomRestitution];
            }
            
            if ((mySegment.size.width > 3.0)  && (mySegment.size.width < 150.0))  {

//                [mySegment setName:@"segmentsprite"];
                [mySegment setName:@"sprite"];
                [mySegment setBlendMode:SKBlendModeReplace];
                
                [mySegment setZPosition:3.0];
                [self addChild:mySegment];
                
                int myRandomGravity = arc4random()%3;
                if (myRandomGravity == 0) {
                    [mySegment.physicsBody setAffectedByGravity:NO];
                }
                else if (myRandomGravity == 1){
                    [mySegment.physicsBody setAffectedByGravity:NO];
                    [mySegment.physicsBody applyForce:CGVectorMake(0, 50)];
                }
                else if (myRandomGravity == 2){
                    [mySegment.physicsBody setAffectedByGravity:NO];
                    [mySegment.physicsBody applyForce:CGVectorMake(0, 100)];
                }
                
                
                int myTypeOfColorize = arc4random()%2;
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
                        [mySegment setPhysicsBody:[SKPhysicsBody bodyWithRectangleOfSize:mySegment.size]];
                    }],
                                                              [SKAction waitForDuration:0.1],
                                                              [SKAction runBlock:^{
                    }],
                                                              ]]];
                }
                
                
                [mySegment runAction:[SKAction sequence:@[
                                                          [SKAction waitForDuration:0.5],
                                                          [SKAction waitForDuration:myRandomFirstWaitFor],
                                                          
                                                          [SKAction scaleXTo:myRandomScaleTo duration:myRandomScaleToDuration],
                                                          [SKAction scaleYTo:myRandomScaleTo duration:myRandomScaleToDuration],
                                                          
                                                          //                                                          [SKAction scaleTo:myRandomScaleTo duration:myRandomScaleToDuration],
                                                          [SKAction waitForDuration:myRandomSecondWaitFor],
                                                          
                                                          [SKAction scaleXTo:0.1 duration:myRandomScaleOutDuration],
                                                          [SKAction scaleYTo:0.1 duration:myRandomScaleOutDuration],
                                                          //                                                          [SKAction scaleTo:0.1 duration:myRandomScaleOutDuration],
                                                          [SKAction removeFromParent],
                                                          ]]];
            }
        }
    }
}

@end

//-(void)myReassignImageNumber: (int) theImageNumber{
//    if (theImageNumber > 5) {
//        return;
//    }
//    if (myPhotos.count != 0) {
//        switch (theImageNumber) {
//            case 1:
//                [self myAssignImage1];
//                break;
//            case 2:
//                [self myAssignImage2];
//                break;
//            case 3:
//                [self myAssignImage3];
//                break;
//            case 4:
//                [self myAssignImage4];
//                break;
//            case 5:
//                [self myAssignImage5];
//                break;
//            default:
//                break;
//        }
//    }
//}


