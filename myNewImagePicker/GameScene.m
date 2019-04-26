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

@synthesize myPicturesArray;

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
    [myAudioPlayer updateMeters];
    for (int i = 0 ; i < myAudioPlayer.numberOfChannels;  i++) {
        myInstantPower+= [myAudioPlayer peakPowerForChannel:i];
        myAveragePower+= [myAudioPlayer averagePowerForChannel:i];
    }
    myInstantPower = myInstantPower / myAudioPlayer.numberOfChannels;
    //    myAveragePower = myAveragePower / myAudioPlayer.numberOfChannels;
    myPowerDifference = fabs(myInstantPower - myLastInstantPower);
    myLastInstantPower = myInstantPower;
    //    }
//    myInstantAmplitude = [self myDbToAmp:myInstantPower] ;
    //        NSLog(@"AP %f IP %f Dif %f Amp %f",myAveragePower,myInstantPower,myPowerDifference,myInstantAmplitude   );
    //    NSLog(@"Power Difference %f",myPowerDifference);
    float myScaleTo = 1.0;
    if (myResizeMethod == 2) {
        myScaleTo =   fabs(myPowerDifference / 2.0);
    } else if (myResizeMethod == 1) {
        myScaleTo = [self myDbToAmp:myInstantPower];
    }
//    NSLog(@"%f",myScaleTo);
    if (myVibrateFlag == YES) {
        [self myBumpNewPhoneWithMusic];
    }
    //        NSLog(@"Power Difference %f",myPowerDifference);
    if (myPowerDifference > 0.0) {
        [self myResizeTheParticlesToSize:myScaleTo];
        [self myResizePhotosAndSegmentsToSize:myScaleTo];
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
    myAudioPlayer = nil;
    [self myStartTheMusic];
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
    
    
    
    [self myStartTheMusic];
    [self myStartTheGame];
    [self myMakeMenuReminderLabel];
    
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
    [myAudioPlayer stop];
    [myAudioPlayer setCurrentTime:0.0];
    [myAudioPlayer prepareToPlay];
    [myAudioPlayer setDelegate: self];
    [myAudioPlayer setMeteringEnabled:YES];
    [myAudioPlayer setNumberOfLoops:-1];
    [myAudioPlayer play];
}




-(void)myStartTheMusic{
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
        [[NSBundle mainBundle] pathForResource: @"Shoot The Planes Intro Music"
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
    if (myAudioPlayer.isPlaying) {
        [myAudioPlayer stop];
    } else {
        [ myAudioPlayer play];
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
    
    
    [self setBackgroundColor:[UIColor blackColor]];
    [self.view setIgnoresSiblingOrder:YES];
    self.physicsBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:self.frame];
    //
    //  contact 0x09 is the edge of the scene
    self.physicsBody.contactTestBitMask = 0x09;
    self.physicsWorld.contactDelegate = self;
    //
    
    
    
}



-(void)myMakeIntroLabels{
    if (![self childNodeWithName:@"hold on"]) {
        SKLabelNode *myHoldOnLabel = [SKLabelNode labelNodeWithFontNamed:@"Helvetica"];
        myHoldOnLabel.position = CGPointMake(CGRectGetMidX(self.frame),
                                             CGRectGetMidY(self.frame) + 220 );
        [myHoldOnLabel setFontSize:24.0];
        [myHoldOnLabel setZPosition:20.0];
        [myHoldOnLabel setName:@"hold on"];
        myHoldOnLabel.text = @"Hold On...";
        [self addChild:myHoldOnLabel];
        
        [myHoldOnLabel runAction:[SKAction sequence:@[
                                                      [SKAction waitForDuration:1.0],
                                                      [SKAction group:@[
                                                                        [SKAction fadeAlphaTo:0.1 duration:1.0],
                                                                        //                                                                    [SKAction scaleTo:0.1 duration:1.0],
                                                                        ]],
                                                      [SKAction removeFromParent],
                                                      ]]];
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
        
        SKLabelNode *myLabel = [SKLabelNode labelNodeWithFontNamed:@"Helvetica"];
        myLabel.text = @"Get";
        SKLabelNode *my2ndLabel = [SKLabelNode labelNodeWithFontNamed:@"Helvetica"];
        my2ndLabel.text = @" Ready!";
        [myLabel setName:@"get"];
        [my2ndLabel setName:@"ready"];
        //
        // set the font size proportional to the image sprite size
        myLabel.fontSize = myImageSpriteSize/5.0;
        my2ndLabel.fontSize = myImageSpriteSize/5.0;
        myLabel.horizontalAlignmentMode = my2ndLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeCenter;
        [myLabel setZPosition:20.0];
        [my2ndLabel setZPosition:20.0];
        myLabel.position = CGPointMake(CGRectGetMidX(self.frame),
                                       CGRectGetMidY(self.frame) - 200 );
        my2ndLabel.position = CGPointMake(CGRectGetMidX(self.frame),
                                          CGRectGetMidY(self.frame) - (  200 + myImageSpriteSize /3.0 ));
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
        [self addChild:myTapForMenuLabel];
        [myTapForMenuLabel runAction:    [SKAction repeatActionForever:      [SKAction sequence:@[
                                                                                                  [SKAction waitForDuration:30.0],
                                                                                                  [SKAction fadeAlphaTo:0.1 duration:10],
                                                                                                  [SKAction fadeAlphaTo:1.0 duration:20.0],
                                                                                                  ]]]];
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
    [self addChild:myPictureSprite];
    
    
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
        //        if ([deviceType isEqualToString:@"iPhone9"]) {
        //            [myMediumImpactFeedbackGenerator impactOccurred];
        //        }
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
                    [mySegment.physicsBody setMass:-1.0];
                }
                else if (myRandomGravity == 2){
                    [mySegment.physicsBody setMass:-2.0];
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


