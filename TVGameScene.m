//
//  TVGameScene.m
//  TV Photo Chaos
//
//  tvOS version of GameScene - adapted for Apple TV
//  No microphone support, Siri Remote input, no haptic feedback
//
//  Created by Robert Zimmelman.
//  Copyright (c) 2024 Robert Zimmelman. All rights reserved.
//

#import "TVGameScene.h"

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

int myColorSpriteDefaultSize = 8;
int myColorSpriteLoops = 1;
float myColorSpriteRestitution = 0.5;

int myNumberOfLoopsForSquares = 20;

int myShape = 0;
int myFrameWidth;

int myCircleSpriteSize = 4;
float myCircleSpriteScale = 0.03;
float myCircleSpriteRestitution = 1.01;
int myCircleSpriteLoops = 3;

int myAllocCount = 0;

dispatch_queue_t myDispatchQueue;

@implementation TVGameScene {
    NSString *deviceType;
    NSString *myPhoneModel;
    SKWarpGeometryGrid *myWarpGeometryGrid;
    SKWarpGeometryGrid *myReverseWarpGeometryGrid;
    GKRandomDistribution *my100OffsetRandomSource;
    GKRandomDistribution *myShuffledRandomSource;
}

@synthesize myOSVersion;
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

float myLastInstantPower;
float myPowerDifference;

#pragma mark - Audio Processing

-(double)myDbToAmp:(double)inDb {
    double power;
    power = pow(10., 0.05 * inDb);
    return power;
}

-(void)myResizeTheParticlesToSize:(float)theScleToSize {
    int myRandomParticleSystemResizeGate = arc4random() % 5;
    float localScaleTo = theScleToSize;
    if (myRandomParticleSystemResizeGate == 0) {
        [self enumerateChildNodesWithName:@"particle system" usingBlock:^(SKNode * _Nonnull node, BOOL * _Nonnull stop) {
            if ([(myCustomEmitterNode *)node myResizeValue] == 0) {
                float myNodeXScale = node.xScale;
                float myNodeYScale = node.yScale;

                [node runAction:[SKAction sequence:@[
                    [SKAction scaleTo:localScaleTo * myParticleSystemScaleMultiplier duration:0.0],
                    [SKAction scaleTo:myNodeXScale duration:0.0],
                ]]];
            } else if ([(myCustomEmitterNode *)node myResizeValue] == 1) {
                CGSize myParticleSize = [(SKEmitterNode *)node particleSize];
                [node runAction:[SKAction sequence:@[
                    [SKAction runBlock:^{
                        [(SKEmitterNode *)node setParticleSize:CGSizeMake(localScaleTo * myParticleSystemScaleMultiplier, localScaleTo * myParticleSystemScaleMultiplier)];
                    }],
                    [SKAction runBlock:^{
                        [(SKEmitterNode *)node setParticleSize:myParticleSize];
                    }],
                ]]];
            } else if ([(myCustomEmitterNode *)node myResizeValue] == 2) {
                [node runAction:[SKAction sequence:@[
                    [SKAction fadeOutWithDuration:0.0],
                    [SKAction fadeInWithDuration:0.0],
                ]]];
            }
        }];
    }
}

-(void)myResizePhotosAndSegmentsToSize:(float)theScaleTo {
    myScaleTo = theScaleTo;

    [self enumerateChildNodesWithName:@"sprite" usingBlock:^(SKNode * _Nonnull node, BOOL * _Nonnull stop) {
        [node runAction:[SKAction sequence:@[
            [SKAction scaleTo:myScaleTo * myPhotoScaleMultiplier duration:0.0],
            [SKAction scaleTo:1.0 duration:0.0],
        ]]];
    }];
}

-(void)myResizeSpritesToMusic {
    myInstantPower = 0;
    myAveragePower = 0;

    // tvOS: Music mode only (no mic support)
    if (myResizeMethod == 0) {
        return;  // No resize mode
    }

    if (!myAudioPlayer) {
        return;
    }
    if (!myAudioPlayer.isPlaying) {
        return;
    }

    [myAudioPlayer updateMeters];
    for (int i = 0; i < myAudioPlayer.numberOfChannels; i++) {
        myInstantPower += [myAudioPlayer peakPowerForChannel:i];
        myAveragePower += [myAudioPlayer averagePowerForChannel:i];
    }
    myInstantPower = myInstantPower / myAudioPlayer.numberOfChannels;

    myPowerDifference = fabs(myInstantPower - myLastInstantPower);
    myLastInstantPower = myInstantPower;
    // this is the critical resize logic
    float localScaleTo = 1.0;
    if (myResizeMethod == 2) {
        // Music pulse mode - FIXED: divide by 20, add baseline, clamp max
        localScaleTo = fmin(1.0 + (myPowerDifference / 20.0), 2.5);
    } else if (myResizeMethod == 1) {
        // Music instant mode
        localScaleTo = [self myDbToAmp:myInstantPower];
    }

    if (myPowerDifference > 0.0) {
        [self myResizeTheParticlesToSize:localScaleTo];
        [self myResizePhotosAndSegmentsToSize:localScaleTo];
    }
}

#pragma mark - Update Loop

-(void)update:(NSTimeInterval)currentTime {
    myTimeSinceLastFrame = currentTime - myLastTimeSample;
    myLastTimeSample = currentTime;

    if ((myTimeSinceLastFrame > myScreenRefreshTimeToDump) && (myTimeSinceLastFrame < 10.0)) {
        [self runAction:[SKAction runBlock:^{
            NSLog(@"IN update -- REMOVING - Slow");
            [self->myDropPicturesTimer invalidate];

            [self enumerateChildNodesWithName:@"sprite" usingBlock:^(SKNode * _Nonnull node, BOOL * _Nonnull stop) {
                [node removeFromParent];
            }];
            [self enumerateChildNodesWithName:@"particle system" usingBlock:^(SKNode * _Nonnull node, BOOL * _Nonnull stop) {
                [node removeFromParent];
            }];

            [self setPhysicsBody:[SKPhysicsBody bodyWithEdgeLoopFromRect:self.frame]];
            [self myMakeMenuReminderLabel];
            [self myMakeIntroLabels];
            [self myStartDropPicturesTimer];
        }]];
    }

    if (myResizeMethod > 0) {
        [self myResizeSpritesToMusic];
    }

    [self myUpdateAudioDisplay];
}

#pragma mark - Photo Library

-(void)photoLibraryDidChange:(PHChange *)changeInstance {
    NSLog(@"TVGameScene Photo Library Changed");
}

-(void)myListAllPhotoAssets {
    [myPhotos enumerateObjectsUsingBlock:^(id _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSLog(@"%@", obj);
    }];
}

-(void)myFetchPhotosFromLibrary {
    // PHPhotoLibrary observer is registered once in didMoveToView; do not re-register here.
    myPhotos = [[PHFetchResult alloc] init];
    PHFetchOptions *myFetchOptions = [[PHFetchOptions alloc] init];
    [myFetchOptions setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:YES selector:NULL]]];
    myPhotos = [PHAsset fetchAssetsWithOptions:myFetchOptions];
    if (myPhotos.count != 0) {
        if (mySceneTestMode) {
            [self myListAllPhotoAssets];
        }
        myImageManager = [[PHImageManager alloc] init];
        [self myReassignImages];
    }
}

-(void)myReassignImages {
    NSLog(@"in TVGameScene ReassignImages");
    if (myPhotos.count != 0) {
        for (int i = 1; i <= 5; i++) {
            [self myAssignImageNumber:i];
        }
    }
}

#pragma mark - Drop Pictures

-(void)myDropPictures {
    if (self.children.count > myAcceptableNodeCount) {
        [self enumerateChildNodesWithName:@"sprite" usingBlock:^(SKNode * _Nonnull node, BOOL * _Nonnull stop) {
            [node removeFromParent];
        }];
        [self enumerateChildNodesWithName:@"particle system" usingBlock:^(SKNode * _Nonnull node, BOOL * _Nonnull stop) {
            [node removeFromParent];
        }];
        [self myStartDropPicturesTimer];
        return;
    }

    if ((myTimeSinceLastFrame > myScreenRefreshTimeToHoldOffDroppingPictures) && (myTimeSinceLastFrame < 10.0)) {
        [self enumerateChildNodesWithName:@"sprite" usingBlock:^(SKNode * _Nonnull node, BOOL * _Nonnull stop) {
            [node removeFromParent];
        }];
        [self enumerateChildNodesWithName:@"particle system" usingBlock:^(SKNode * _Nonnull node, BOOL * _Nonnull stop) {
            [node removeFromParent];
        }];
        [self myStartDropPicturesTimer];
        return;
    } else {
        int myPic = (arc4random() % 5);
        if (myPicturesArray.count > 0) {
            myPic = (arc4random() % myPicturesArray.count);
        }

        int myPictureToDrop = (int)[[myPicturesArray objectAtIndex:myPic] integerValue];
        if (myAllRandomImagesFlag) {
            [self myAssignImageNumber:myPictureToDrop];
        }

        [self myDropPictureNumber:myPictureToDrop];
        [self myStartDropPicturesTimer];
    }
}

-(void)myStartDropPicturesTimer {
    float myRandomInterval = (arc4random() % 5 / 10.0 + 1.0);
    NSLog(@"Interval is %f", myRandomInterval);
    myDropPicturesTimer = [NSTimer scheduledTimerWithTimeInterval:myRandomInterval target:self selector:@selector(myDropPictures) userInfo:nil repeats:NO];
}

#pragma mark - Music Control

-(void)myMusicSelected {
    NSLog(@"in myMusicSelected. URL is %@", myMusicURL);
    myAudioPlayer = nil;
    [self myStartTheMusic];
    [self mySetupAudioDisplay];
}

-(void)willMoveFromView:(SKView *)view {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[PHPhotoLibrary sharedPhotoLibrary] unregisterChangeObserver:self];
    [myDropPicturesTimer invalidate];
    myDropPicturesTimer = nil;
    [myAudioPlayer stop];
    myAudioPlayer = nil;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[PHPhotoLibrary sharedPhotoLibrary] unregisterChangeObserver:self];
    [myDropPicturesTimer invalidate];
    [myAudioPlayer stop];
}

-(void)mySendQuitNotification {
    NSLog(@"in mySendQuitNotification");
    [[NSNotificationCenter defaultCenter] postNotificationName:@"quitnotifictaion" object:nil];
}

-(void)myAssignImageNumber:(int)theImageNumber {
    int myTargetImageSizeFromLibrary = 160;

    NSLog(@"TVGameScene in Assign ImageNumber with Image Number %d", theImageNumber);
    if (theImageNumber > 5) {
        return;
    }

    [self->myImageManager requestImageForAsset:myPhotos[arc4random() % myPhotos.count] targetSize:CGSizeMake(myTargetImageSizeFromLibrary, myTargetImageSizeFromLibrary) contentMode:PHImageContentModeAspectFit options:nil resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
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
            NSLog(@"error retrieving photo");
        }
    }];
}

-(void)myAssignImage1 {
    NSLog(@"TVGameScene in Assign Image 1");
    [self->myImageManager requestImageForAsset:myPhotos[arc4random() % myPhotos.count] targetSize:CGSizeMake(160, 160) contentMode:PHImageContentModeAspectFit options:nil resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        if (result) {
            self->mySpriteImage1 = result;
            [[self myImageSprite1] setTexture:[SKTexture textureWithImage:self->mySpriteImage1]];
        }
    }];
}

-(void)myAssignImage2 {
    [self->myImageManager requestImageForAsset:myPhotos[arc4random() % myPhotos.count] targetSize:CGSizeMake(160, 160) contentMode:PHImageContentModeAspectFit options:nil resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        if (result) {
            self->mySpriteImage2 = result;
            [[self myImageSprite2] setTexture:[SKTexture textureWithImage:self->mySpriteImage2]];
        }
    }];
}

-(void)myAssignImage3 {
    [self->myImageManager requestImageForAsset:myPhotos[arc4random() % myPhotos.count] targetSize:CGSizeMake(160, 160) contentMode:PHImageContentModeAspectFit options:nil resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        if (result) {
            self->mySpriteImage3 = result;
            [[self myImageSprite3] setTexture:[SKTexture textureWithImage:self->mySpriteImage3]];
        }
    }];
}

-(void)myAssignImage4 {
    [self->myImageManager requestImageForAsset:myPhotos[arc4random() % myPhotos.count] targetSize:CGSizeMake(160, 160) contentMode:PHImageContentModeAspectFit options:nil resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        if (result) {
            self->mySpriteImage4 = result;
            [[self myImageSprite4] setTexture:[SKTexture textureWithImage:self->mySpriteImage4]];
        }
    }];
}

-(void)myAssignImage5 {
    [self->myImageManager requestImageForAsset:myPhotos[arc4random() % myPhotos.count] targetSize:CGSizeMake(160, 160) contentMode:PHImageContentModeAspectFit options:nil resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        if (result) {
            self->mySpriteImage5 = result;
            [[self myImageSprite5] setTexture:[SKTexture textureWithImage:self->mySpriteImage5]];
        }
    }];
}

#pragma mark - Scene Lifecycle

-(void)didMoveToView:(SKView *)view {
    NSLog(@">>> didMoveToView CALLED: myResizeMethod=%d", myResizeMethod);
    [self.view setShouldCullNonVisibleNodes:YES];

    my100OffsetRandomSource = [GKRandomDistribution distributionWithLowestValue:-100 highestValue:100];
    myShuffledRandomSource = [GKShuffledDistribution distributionWithLowestValue:1 highestValue:18];

    [[PHPhotoLibrary sharedPhotoLibrary] registerChangeObserver:self];

    myPhotos = [[PHFetchResult alloc] init];
    PHFetchOptions *myFetchOptions = [[PHFetchOptions alloc] init];
    [myFetchOptions setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:YES selector:NULL]]];
    myPhotos = [PHAsset fetchAssetsWithOptions:myFetchOptions];

    myImageManager = [[PHImageManager alloc] init];

    // Start music (tvOS: always music mode, no mic)
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@">>> Starting MUSIC mode (tvOS)");
        [self myStartTheMusic];
    });

    [self myStartTheGame];
    [self myMakeMenuReminderLabel];

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self mySetupAudioDisplay];
    });

    // Register for notifications
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(myMusicSelected) name:@"musicselected" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(myPlayPause) name:@"playpause" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(myStartTheMusic) name:@"selectedmusic" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(myRestartTheMusic) name:@"restartmusic" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(myAssignImage1) name:@"assignimage1" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(myAssignImage2) name:@"assignimage2" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(myAssignImage3) name:@"assignimage3" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(myAssignImage4) name:@"assignimage4" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(myAssignImage5) name:@"assignimage5" object:nil];

    // tvOS: Menu button opens menu
    UITapGestureRecognizer *menuTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(mySendQuitNotification)];
    menuTap.allowedPressTypes = @[@(UIPressTypeMenu)];
    [self.view addGestureRecognizer:menuTap];

    // tvOS: Play/Pause button controls music
    UITapGestureRecognizer *playPauseTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(myPlayPause)];
    playPauseTap.allowedPressTypes = @[@(UIPressTypePlayPause)];
    [self.view addGestureRecognizer:playPauseTap];

    NSLog(@"in TVGameScene myPicturesArray %@", myPicturesArray);
}

-(void)myRestartTheMusic {
    [myAudioPlayer stop];
    [myAudioPlayer setCurrentTime:0.0];
    [myAudioPlayer prepareToPlay];
    [myAudioPlayer setDelegate:self];
    [myAudioPlayer setMeteringEnabled:YES];
    [myAudioPlayer setNumberOfLoops:-1];
    [myAudioPlayer play];
}

-(void)myStartTheMusic {
    NSLog(@">>> myStartTheMusic CALLED");

    NSURL *fileURL;
    if (myMusicURL) {
        fileURL = myMusicURL;
    } else {
        NSString *soundFilePath = [[NSBundle mainBundle] pathForResource:@"Skrxlla - Caution" ofType:@"mp3"];
        fileURL = [[NSURL alloc] initFileURLWithPath:soundFilePath];
    }
    NSLog(@"Music URL %@", fileURL);

    AVAudioPlayer *newPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:fileURL error:nil];
    self.myAudioPlayer = newPlayer;
    [myAudioPlayer prepareToPlay];
    [myAudioPlayer setDelegate:self];
    [myAudioPlayer setMeteringEnabled:YES];
    [myAudioPlayer setNumberOfLoops:-1];
    [myAudioPlayer play];
}

-(void)myPlayPause {
    if (myAudioPlayer.isPlaying) {
        [myAudioPlayer stop];
    } else {
        [myAudioPlayer play];
    }
}

-(void)myStartTheGame {
    myProcessInfo = [NSProcessInfo processInfo];
    myOSVersion = myProcessInfo.operatingSystemVersion.majorVersion;
    NSLog(@"Operating System Version is %ld.%ld", (long)myProcessInfo.operatingSystemVersion.majorVersion, (long)myProcessInfo.operatingSystemVersion.minorVersion);

    myFrameWidth = self.view.frame.size.width;

    myImageSprite1 = [SKSpriteNode spriteNodeWithTexture:[SKTexture textureWithImage:mySpriteImage1]];
    myImageSprite2 = [SKSpriteNode spriteNodeWithTexture:[SKTexture textureWithImage:mySpriteImage2]];
    myImageSprite3 = [SKSpriteNode spriteNodeWithTexture:[SKTexture textureWithImage:mySpriteImage3]];
    myImageSprite4 = [SKSpriteNode spriteNodeWithTexture:[SKTexture textureWithImage:mySpriteImage4]];
    myImageSprite5 = [SKSpriteNode spriteNodeWithTexture:[SKTexture textureWithImage:mySpriteImage5]];

    // tvOS: Larger image size for TV viewing distance
    myImageSpriteSize = (self.size.width + self.size.height) * 0.12;

    struct utsname systemInfo;
    uname(&systemInfo);
    NSString *myTempDeviceType = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
    if (myTempDeviceType.length >= 7) {
        deviceType = [NSString stringWithString:[myTempDeviceType substringWithRange:NSMakeRange(0, 7)]];
    } else {
        deviceType = [NSString stringWithString:[myTempDeviceType substringWithRange:NSMakeRange(1, myTempDeviceType.length - 1)]];
    }
    NSLog(@"Device is %@", deviceType);

    [self myStartDropPicturesTimer];

    [self.physicsWorld setGravity:CGVectorMake(0.0, -9.5)];

    // Beautiful dark background
    [self setBackgroundColor:[SKColor colorWithRed:0.02 green:0.0 blue:0.08 alpha:1.0]];

    // Animated gradient background
    [self createAnimatedBackgroundGradient];

    [self.view setIgnoresSiblingOrder:YES];
    self.physicsBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:self.frame];
    self.physicsBody.contactTestBitMask = 0x09;
    self.physicsWorld.contactDelegate = self;

    // Celebrate game start!
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self celebrationEffect];
    });
}

#pragma mark - UI Labels

-(SKLabelNode *)createMagicalLabelWithText:(NSString *)text fontSize:(CGFloat)fontSize color:(SKColor *)color {
    SKLabelNode *label = [SKLabelNode labelNodeWithFontNamed:@"AvenirNext-Bold"];
    label.text = text;
    label.fontSize = fontSize;
    label.fontColor = color;
    label.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeCenter;

    // Glow effect
    SKLabelNode *glowLabel = [label copy];
    glowLabel.fontColor = color;
    glowLabel.alpha = 0.6;
    glowLabel.zPosition = -1;

    SKEffectNode *glowEffect = [SKEffectNode node];
    glowEffect.shouldRasterize = YES;
    glowEffect.filter = [CIFilter filterWithName:@"CIGaussianBlur" keysAndValues:@"inputRadius", @8.0, nil];
    [glowEffect addChild:glowLabel];
    [label addChild:glowEffect];

    // Pulse animation
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

-(void)myMakeIntroLabels {
    if (![self childNodeWithName:@"hold on"]) {
        // tvOS: Larger font for TV viewing distance
        SKLabelNode *myHoldOnLabel = [self createMagicalLabelWithText:@"Let's Dance!" fontSize:48.0 color:MAGIC_PINK];
        myHoldOnLabel.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame) + 100);
        [myHoldOnLabel setZPosition:20.0];
        [myHoldOnLabel setName:@"hold on"];
        myHoldOnLabel.alpha = 0;
        [myHoldOnLabel setScale:0.5];
        [self addChild:myHoldOnLabel];

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

        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self createSparkleEffectAtPosition:myHoldOnLabel.position withColor:MAGIC_PINK];
        });
    }
}

-(void)myMakeMenuReminderLabel {
    if (![self childNodeWithName:@"tap for label"]) {
        // tvOS: Different text for remote control
        SKLabelNode *myTapForMenuLabel = [SKLabelNode labelNodeWithText:@"Press Menu for Options"];
        [myTapForMenuLabel setFontColor:[UIColor whiteColor]];
        [myTapForMenuLabel setFontSize:28.0];  // Larger for TV
        [myTapForMenuLabel setName:@"tap for label"];
        [myTapForMenuLabel setPosition:CGPointMake(CGRectGetMidX(self.view.frame), 30.0)];

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

#pragma mark - Audio Display

-(void)mySetupAudioDisplay {
    SKNode *existingDisplay = [self childNodeWithName:@"audioDisplayContainer"];
    if (existingDisplay) {
        [existingDisplay removeFromParent];
    }

    myAudioDisplayNode = [SKNode node];
    myAudioDisplayNode.name = @"audioDisplayContainer";
    myAudioDisplayNode.zPosition = 50;
    myAudioDisplayNode.position = CGPointMake(CGRectGetMidX(self.frame), self.frame.size.height - 80);
    [self addChild:myAudioDisplayNode];

    CGFloat pillWidth = MIN(self.frame.size.width - 80, 400);  // Larger for TV
    CGFloat pillHeight = 60;

    SKShapeNode *backgroundPill = [SKShapeNode shapeNodeWithRectOfSize:CGSizeMake(pillWidth, pillHeight) cornerRadius:pillHeight / 2];
    backgroundPill.fillColor = [SKColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.6];
    backgroundPill.strokeColor = [SKColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.2];
    backgroundPill.lineWidth = 1.5;
    backgroundPill.name = @"audioDisplayBG";
    [myAudioDisplayNode addChild:backgroundPill];

    SKShapeNode *innerGlow = [SKShapeNode shapeNodeWithRectOfSize:CGSizeMake(pillWidth - 4, pillHeight - 4) cornerRadius:(pillHeight - 4) / 2];
    innerGlow.fillColor = [SKColor clearColor];
    innerGlow.strokeColor = [SKColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.1];
    innerGlow.lineWidth = 1;
    [myAudioDisplayNode addChild:innerGlow];

    // Music mode display (tvOS: always music mode)
    SKLabelNode *musicIcon = [SKLabelNode labelNodeWithFontNamed:@"AvenirNext-Bold"];
    musicIcon.text = @"NOW PLAYING";
    musicIcon.fontSize = 12;
    musicIcon.fontColor = MAGIC_CYAN;
    musicIcon.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeLeft;
    musicIcon.verticalAlignmentMode = SKLabelVerticalAlignmentModeCenter;
    musicIcon.position = CGPointMake(-pillWidth / 2 + 25, 14);
    musicIcon.name = @"nowPlayingLabel";
    [myAudioDisplayNode addChild:musicIcon];

    NSString *displayTitle = mySongTitle ? mySongTitle : @"Photo Dance Party!";
    SKLabelNode *titleLabel = [SKLabelNode labelNodeWithFontNamed:@"AvenirNext-DemiBold"];
    titleLabel.text = displayTitle;
    titleLabel.fontSize = 18;
    titleLabel.fontColor = [SKColor whiteColor];
    titleLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeLeft;
    titleLabel.verticalAlignmentMode = SKLabelVerticalAlignmentModeCenter;
    titleLabel.position = CGPointMake(-pillWidth / 2 + 25, -6);
    titleLabel.name = @"songTitleLabel";
    [myAudioDisplayNode addChild:titleLabel];

    if (mySongArtist && mySongArtist.length > 0) {
        titleLabel.position = CGPointMake(-pillWidth / 2 + 25, 2);

        SKLabelNode *artistLabel = [SKLabelNode labelNodeWithFontNamed:@"AvenirNext-Regular"];
        artistLabel.text = mySongArtist;
        artistLabel.fontSize = 13;
        artistLabel.fontColor = [SKColor colorWithRed:0.7 green:0.7 blue:0.7 alpha:1.0];
        artistLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeLeft;
        artistLabel.verticalAlignmentMode = SKLabelVerticalAlignmentModeCenter;
        artistLabel.position = CGPointMake(-pillWidth / 2 + 25, -16);
        artistLabel.name = @"artistLabel";
        [myAudioDisplayNode addChild:artistLabel];
    }

    // Music bars
    CGFloat barsStartX = pillWidth / 2 - 55;
    for (int i = 0; i < 4; i++) {
        SKShapeNode *bar = [SKShapeNode shapeNodeWithRectOfSize:CGSizeMake(5, 18) cornerRadius:2.5];
        bar.fillColor = MAGIC_GOLD;
        bar.strokeColor = [SKColor clearColor];
        bar.position = CGPointMake(barsStartX + i * 10, 0);
        bar.name = [NSString stringWithFormat:@"musicBar%d", i];
        [bar setYScale:0.3];
        [myAudioDisplayNode addChild:bar];
    }

    // VU meter
    CGFloat vuMeterWidth = pillWidth - 50;
    CGFloat vuMeterHeight = 5;
    CGFloat vuMeterY = -pillHeight / 2 - 15;

    SKShapeNode *vuMeterBG = [SKShapeNode shapeNodeWithRectOfSize:CGSizeMake(vuMeterWidth, vuMeterHeight) cornerRadius:vuMeterHeight / 2];
    vuMeterBG.fillColor = [SKColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:0.8];
    vuMeterBG.strokeColor = [SKColor clearColor];
    vuMeterBG.position = CGPointMake(0, vuMeterY);
    vuMeterBG.name = @"vuMeterBG";
    [myAudioDisplayNode addChild:vuMeterBG];

    SKNode *vuMeterFillContainer = [SKNode node];
    vuMeterFillContainer.position = CGPointMake(-vuMeterWidth / 2, vuMeterY);
    vuMeterFillContainer.name = @"vuMeterFillContainer";
    [myAudioDisplayNode addChild:vuMeterFillContainer];

    SKShapeNode *vuMeterFill = [SKShapeNode shapeNodeWithRectOfSize:CGSizeMake(2, vuMeterHeight - 1) cornerRadius:(vuMeterHeight - 1) / 2];
    vuMeterFill.fillColor = MAGIC_CYAN;
    vuMeterFill.strokeColor = [SKColor clearColor];
    vuMeterFill.position = CGPointMake(1, 0);
    vuMeterFill.name = @"vuMeterFill";
    [vuMeterFillContainer addChild:vuMeterFill];

    SKShapeNode *vuMeterGlow = [SKShapeNode shapeNodeWithRectOfSize:CGSizeMake(2, vuMeterHeight + 4) cornerRadius:(vuMeterHeight + 4) / 2];
    vuMeterGlow.fillColor = MAGIC_CYAN;
    vuMeterGlow.strokeColor = [SKColor clearColor];
    vuMeterGlow.alpha = 0.4;
    vuMeterGlow.position = CGPointMake(1, 0);
    vuMeterGlow.name = @"vuMeterGlow";
    [vuMeterFillContainer addChild:vuMeterGlow];

    myAudioDisplayNode.alpha = 0;
    [myAudioDisplayNode setScale:0.8];
    [myAudioDisplayNode runAction:[SKAction group:@[
        [SKAction fadeInWithDuration:0.5],
        [SKAction scaleTo:1.0 duration:0.5]
    ]]];
}

-(void)myUpdateAudioDisplay {
    if (!myAudioDisplayNode) return;

    BOOL isAudioActive = myAudioPlayer && myAudioPlayer.isPlaying;

    CGFloat vuMeterWidth = MIN(self.frame.size.width - 80, 400) - 50;
    CGFloat amplitudeLevel = isAudioActive ? [self myDbToAmp:myInstantPower] : 0.0;
    CGFloat normalizedLevel = MIN(amplitudeLevel, 1.0);

    static CGFloat smoothedLevel = 0;
    if (isAudioActive) {
        smoothedLevel = smoothedLevel * 0.6 + normalizedLevel * 0.4;
    } else {
        smoothedLevel = smoothedLevel * 0.85;
        if (smoothedLevel < 0.01) smoothedLevel = 0;
    }

    SKNode *vuMeterFillContainer = [myAudioDisplayNode childNodeWithName:@"vuMeterFillContainer"];
    SKNode *vuMeterFill = [vuMeterFillContainer childNodeWithName:@"vuMeterFill"];
    SKNode *vuMeterGlow = [vuMeterFillContainer childNodeWithName:@"vuMeterGlow"];

    if (vuMeterFill) {
        CGFloat targetWidth = MAX(smoothedLevel * vuMeterWidth, 2);
        vuMeterFill.xScale = targetWidth;

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

    // Music bars
    for (int i = 0; i < 4; i++) {
        SKNode *bar = [myAudioDisplayNode childNodeWithName:[NSString stringWithFormat:@"musicBar%d", i]];
        if (bar) {
            if (isAudioActive && smoothedLevel > 0.05) {
                CGFloat barScale = 0.5 + smoothedLevel * 1.5 * ((arc4random() % 50 + 50) / 100.0);
                [bar runAction:[SKAction scaleYTo:barScale duration:0.08]];
            } else if (!isAudioActive) {
                [bar runAction:[SKAction scaleYTo:0.3 duration:0.2]];
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
    for (int i = 0; i < 12; i++) {
        SKShapeNode *sparkle = [SKShapeNode shapeNodeWithCircleOfRadius:3.0];
        sparkle.fillColor = color;
        sparkle.strokeColor = [SKColor clearColor];
        sparkle.glowWidth = 4.0;
        sparkle.position = position;
        sparkle.zPosition = 100;
        sparkle.alpha = 1.0;

        CGFloat angle = (arc4random() % 360) * M_PI / 180.0;
        CGFloat distance = 50 + arc4random() % 100;
        CGFloat endX = position.x + cos(angle) * distance;
        CGFloat endY = position.y + sin(angle) * distance;

        [self addChild:sparkle];

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

    [self createSparkleEffectAtPosition:position withColor:[self randomMagicColor]];
}

-(void)createConfettiBurstAtPosition:(CGPoint)position {
    for (int i = 0; i < 20; i++) {
        CGSize size = CGSizeMake(4 + arc4random() % 6, 8 + arc4random() % 10);
        SKSpriteNode *confetti = [SKSpriteNode spriteNodeWithColor:[self randomMagicColor] size:size];
        confetti.position = position;
        confetti.zPosition = 98;
        confetti.zRotation = (arc4random() % 360) * M_PI / 180.0;

        confetti.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:size];
        confetti.physicsBody.mass = 0.001;
        confetti.physicsBody.linearDamping = 2.0;
        confetti.physicsBody.angularDamping = 0.5;
        confetti.physicsBody.categoryBitMask = 0;
        confetti.physicsBody.collisionBitMask = 0;
        confetti.physicsBody.contactTestBitMask = 0;

        CGFloat angle = (arc4random() % 360) * M_PI / 180.0;
        CGFloat speed = 200 + arc4random() % 300;
        [confetti.physicsBody applyImpulse:CGVectorMake(cos(angle) * speed * 0.001, sin(angle) * speed * 0.001 + 0.3)];
        [confetti.physicsBody applyAngularImpulse:0.001 * (arc4random() % 100 - 50)];

        [self addChild:confetti];

        [confetti runAction:[SKAction sequence:@[
            [SKAction waitForDuration:1.5 + (arc4random() % 100) / 100.0],
            [SKAction fadeOutWithDuration:0.5],
            [SKAction removeFromParent]
        ]]];
    }
}

-(void)addGlowToSprite:(SKSpriteNode *)sprite withColor:(SKColor *)color {
    SKShapeNode *glow = [SKShapeNode shapeNodeWithRectOfSize:CGSizeMake(sprite.size.width + 20, sprite.size.height + 20) cornerRadius:8];
    glow.fillColor = color;
    glow.strokeColor = [SKColor clearColor];
    glow.alpha = 0.4;
    glow.zPosition = -1;
    glow.name = @"glow";

    SKEffectNode *glowEffect = [SKEffectNode node];
    glowEffect.shouldRasterize = YES;
    glowEffect.filter = [CIFilter filterWithName:@"CIGaussianBlur" keysAndValues:@"inputRadius", @10.0, nil];
    [glowEffect addChild:glow];

    [sprite addChild:glowEffect];

    [glow runAction:[SKAction repeatActionForever:[SKAction sequence:@[
        [SKAction fadeAlphaTo:0.6 duration:0.5],
        [SKAction fadeAlphaTo:0.3 duration:0.5]
    ]]]];
}

-(void)createRainbowTrailForSprite:(SKSpriteNode *)sprite {
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
    SKSpriteNode *gradientBG = [SKSpriteNode spriteNodeWithColor:[SKColor blackColor] size:self.size];
    gradientBG.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
    gradientBG.zPosition = -100;
    gradientBG.name = @"gradient_bg";

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
    CGPoint center = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));

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

#pragma mark - Drop Picture

-(void)myDropPictureNumber:(int)thePictureNumber {
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

    float myRandomMultiplier = 1.0;
    int myRandomXPosition = (arc4random() % myFrameWidth) * myRandomMultiplier;
    myPictureSprite.position = CGPointMake(myRandomXPosition, CGRectGetMaxY(self.frame) - myYOffset);
    [myPictureSprite setSize:CGSizeMake(myImageSpriteSize, myImageSpriteSize)];
    myPictureSprite.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:myPictureSprite.size];

    float myRandomRestitution = ((arc4random() % 50) / 50.0) + 0.5;
    if (myRandomRestitution > 1.0) {
        myRandomRestitution = 1.0;
    }
    myPictureSprite.physicsBody.restitution = myRandomRestitution;
    myPictureSprite.physicsBody.contactTestBitMask = 0x02;

    [myPictureSprite setName:@"sprite"];
    [myPictureSprite runAction:myImageSpriteAction];
    [myPictureSprite setBlendMode:SKBlendModeReplace];

    // Magical glow
    SKColor *glowColor = [self randomMagicColor];
    [self addGlowToSprite:myPictureSprite withColor:glowColor];

    // Rainbow trail (50% chance)
    if (arc4random() % 2 == 0) {
        [self createRainbowTrailForSprite:myPictureSprite];
    }

    [self addChild:myPictureSprite];

    // Entrance sparkle
    [self createSparkleEffectAtPosition:myPictureSprite.position withColor:glowColor];

    [myPictureSprite.physicsBody setLinearDamping:myImageSpriteDamping];
}

#pragma mark - Physics Contact

-(void)didEndContact:(SKPhysicsContact *)contact {
    if (myTimeSinceLastFrame > myScreenRefreshTimeToHoldOffDroppingPictures) {
        return;
    }

    if (contact.bodyA.node.physicsBody.contactTestBitMask < contact.bodyB.node.physicsBody.contactTestBitMask) {
        firstNode = contact.bodyA.node;
        secondNode = contact.bodyB.node;
    } else {
        firstNode = contact.bodyB.node;
        secondNode = contact.bodyA.node;
    }

    // Photo sprite hits photo sprite
    if ((firstNode.physicsBody.contactTestBitMask == 0x02) && (secondNode.physicsBody.contactTestBitMask == 0x02)) {
        CGPoint collisionPoint = contact.contactPoint;
        [self createMagicBurstAtPosition:collisionPoint];

        for (SKNode *theNode in @[firstNode, secondNode]) {
            NSInteger myRandomPhotoPhotoAction = [myShuffledRandomSource nextInt];

            switch (myRandomPhotoPhotoAction) {
                case 0:
                    if (myOSVersion >= 10.0) {
                        [self myWarpSprite:(SKSpriteNode *)theNode];
                    }
                    break;
                case 1:
                    [self myBetterSegmentPhotoAndDrop:(SKSpriteNode *)theNode];
                    break;
                case 2: {
                    int myRandomEmitterResize = arc4random() % 3;
                    [self myParticleSystemFromPhoto:(SKSpriteNode *)theNode withResizeValue:myRandomEmitterResize];
                    break;
                }
                case 3: {
                    int myRandomEmitterResize = arc4random() % 2;
                    [self myCloudFromPhoto:(SKSpriteNode *)theNode withResizeValue:myRandomEmitterResize];
                    break;
                }
                case 4: {
                    int myRandomEmitterResize = arc4random() % 2;
                    [self myTrianglesFromPhoto:(SKSpriteNode *)theNode withResizeValue:myRandomEmitterResize];
                    break;
                }
                case 5: {
                    int myRandomEmitterResize = arc4random() % 2;
                    [self myCirclesFromPhoto:(SKSpriteNode *)theNode withResize:myRandomEmitterResize];
                    break;
                }
                case 6: {
                    int myRandomEmitterResize = arc4random() % 2;
                    [self myRandomSquaresFromPhoto:(SKSpriteNode *)theNode withResizeValue:myRandomEmitterResize];
                    break;
                }
                case 7: {
                    int myRandomEmitterResize = arc4random() % 2;
                    [self myRandomQuadsFromPhoto:(SKSpriteNode *)theNode withResizeValue:myRandomEmitterResize];
                    break;
                }
                default:
                    break;
            }
        }
    }

    // Warp sprite hits warp sprite
    if ((firstNode.physicsBody.contactTestBitMask == 0x06) && (secondNode.physicsBody.contactTestBitMask == 0x06)) {
        [firstNode runAction:[SKAction sequence:@[
            [SKAction waitForDuration:1.5],
            [SKAction scaleTo:0.1 duration:0.1],
            [SKAction removeFromParent],
        ]]];
        [secondNode runAction:[SKAction sequence:@[
            [SKAction waitForDuration:1.5],
            [SKAction scaleTo:0.1 duration:0.1],
            [SKAction removeFromParent],
        ]]];
    }
}

#pragma mark - Visual Effect Helpers

-(void)myWarpSprite:(SKSpriteNode *)theSourceSprite {
    if (myTimeSinceLastFrame > myScreenRefreshTimeToHoldOffDroppingPictures) {
        return;
    }

    [theSourceSprite removeAllActions];
    SKSpriteNode *theSprite = [theSourceSprite copy];
    [theSourceSprite removeFromParent];

    [theSprite.physicsBody setContactTestBitMask:0x06];
    [theSprite setZPosition:3.0];
    [theSprite setName:@"sprite"];

    int myWarpGeometryGridSize = 3;

    vector_float2 mySources[myWarpGeometryGridSize * myWarpGeometryGridSize];
    vector_float2 myDests[myWarpGeometryGridSize * myWarpGeometryGridSize];

    float myIncrement = 1.0 / myWarpGeometryGridSize;
    int myGridEntry = 0;

    int myRandomDurationSeed = arc4random() % 100;
    float myRandomDuration = (myRandomDurationSeed / 100.0) * 3.0;

    for (int myRow = myWarpGeometryGridSize; myRow > 0; myRow--) {
        for (int myCol = 0; myCol < myWarpGeometryGridSize; myCol++) {
            float myRandomX = (arc4random() % 100) / 1000.0;
            float myRandomY = (arc4random() % 100) / 1000.0;
            float myGridXValue = ((myCol * myIncrement) + (myIncrement / 2.0));
            float myGridYValue = ((myRow * myIncrement) - (myIncrement / 2.0));
            mySources[myGridEntry] = vector2(myGridXValue, myGridYValue);

            int myRandomDirection = arc4random() % 2;
            float myDestX = myRandomDirection == 0 ? myGridXValue + myRandomX : myGridXValue - myRandomX;
            myRandomDirection = arc4random() % 2;
            float myDestY = myRandomDirection == 0 ? myGridYValue + myRandomY : myGridYValue - myRandomY;
            myDests[myGridEntry] = vector2(myDestX, myDestY);
            myGridEntry++;
        }
    }

    [self addChild:theSprite];
    myWarpGeometryGrid = [SKWarpGeometryGrid gridWithColumns:myWarpGeometryGridSize - 1 rows:myWarpGeometryGridSize - 1 sourcePositions:mySources destPositions:myDests];
    myReverseWarpGeometryGrid = [SKWarpGeometryGrid gridWithColumns:myWarpGeometryGridSize - 1 rows:myWarpGeometryGridSize - 1 sourcePositions:myDests destPositions:mySources];
    [theSprite setWarpGeometry:myWarpGeometryGrid];

    int myRandomWarpAction = arc4random() % 4;
    int myRandomSpinDirection = arc4random() % 2;
    float myRandomSpinMultiplier = myRandomSpinDirection == 1 ? -1.0 : 1.0;

    if (myRandomWarpAction == 0 || myRandomWarpAction == 1) {
        [theSprite runAction:[SKAction repeatActionForever:[SKAction sequence:@[
            [SKAction warpTo:myWarpGeometryGrid duration:myRandomDuration],
            [SKAction warpTo:myReverseWarpGeometryGrid duration:myRandomWarpAction == 0 ? 2.5 : 1.5],
        ]]]];
    } else {
        [theSprite runAction:[SKAction repeatActionForever:[SKAction group:@[
            [SKAction sequence:@[
                [SKAction warpTo:myWarpGeometryGrid duration:myRandomWarpAction == 2 ? myRandomDuration : 2.5],
                [SKAction warpTo:myReverseWarpGeometryGrid duration:myRandomWarpAction == 2 ? myRandomDuration : 0.5],
            ]],
            [SKAction rotateByAngle:(M_PI * myRandomSpinMultiplier) duration:myRandomWarpAction == 2 ? myRandomDuration : 2.0],
        ]]]];
    }
}

-(void)myTrianglesFromPhoto:(SKSpriteNode *)thePhoto withResizeValue:(int)theValue {
    CGMutablePathRef myLeftPath = CGPathCreateMutable();
    CGPathMoveToPoint(myLeftPath, nil, 50, 50);
    CGPathAddLineToPoint(myLeftPath, nil, 0, 0);
    CGPathAddLineToPoint(myLeftPath, nil, 0, 100);
    CGPathCloseSubpath(myLeftPath);

    CGMutablePathRef myTopPath = CGPathCreateMutable();
    CGPathMoveToPoint(myTopPath, nil, 100, 100);
    CGPathAddLineToPoint(myTopPath, nil, 50, 50);
    CGPathAddLineToPoint(myTopPath, nil, 0, 100);
    CGPathCloseSubpath(myTopPath);

    CGMutablePathRef myBottomPath = CGPathCreateMutable();
    CGPathMoveToPoint(myBottomPath, nil, 50, 50);
    CGPathAddLineToPoint(myBottomPath, nil, 0, 0);
    CGPathAddLineToPoint(myBottomPath, nil, 100, 0);
    CGPathCloseSubpath(myBottomPath);

    CGMutablePathRef myRightPath = CGPathCreateMutable();
    CGPathMoveToPoint(myRightPath, nil, 50, 50);
    CGPathAddLineToPoint(myRightPath, nil, 100, 0);
    CGPathAddLineToPoint(myRightPath, nil, 100, 100);
    CGPathCloseSubpath(myRightPath);

    myCustomShapeNode *myLeftTriangle = [myCustomShapeNode shapeNodeWithPath:myLeftPath];
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

    NSArray *myTriangles = @[myLeftTriangle, myRightTriangle, myTopTriangle, myBottomTriangle];
    int myRandomWait = (arc4random() % 30 / 100) + 1.5;
    SKAction *myTriangleAction = [SKAction sequence:@[
        [SKAction waitForDuration:myRandomWait],
        [SKAction removeFromParent],
    ]];

    int myRandomColorize = arc4random() % 2;
    for (myCustomShapeNode *node in myTriangles) {
        [node setName:@"sprite"];
        [node setZPosition:4.0];
        [node setMyResizeValue:theValue];
        [node setScale:thePhoto.xScale];
        if (myRandomColorize == 0) {
            float myRandomRed = (arc4random() % 100) / 100.0;
            float myRandomGreen = (arc4random() % 100) / 100.0;
            float myRandomBlue = (arc4random() % 100) / 100.0;
            [node setFillColor:[UIColor colorWithRed:myRandomRed green:myRandomGreen blue:myRandomBlue alpha:1.0]];
        } else {
            [node setFillColor:[UIColor whiteColor]];
        }
        int myRandomLineWidth = arc4random() % 5;
        [node setLineWidth:myRandomLineWidth];
        int myRandomGlowWidth = arc4random() % 3;
        [node setGlowWidth:myRandomGlowWidth];
        [node setBlendMode:SKBlendModeReplace];
        [node setPosition:thePhoto.position];
        [self addChild:node];
        [node runAction:myTriangleAction];
    }

    CGPathRelease(myLeftPath);
    CGPathRelease(myTopPath);
    CGPathRelease(myBottomPath);
    CGPathRelease(myRightPath);
}

-(void)myRandomSquaresFromPhoto:(SKSpriteNode *)thePhoto withResizeValue:(int)theValue {
    for (int i = 1; i <= 15; i++) {
        float myXStart = (arc4random() % 100) / 100.0;
        float myYStart = (arc4random() % 100) / 100.0;
        float myXSize = (arc4random() % 100) / 100.0;
        float myYSize = (arc4random() % 100) / 100.0;
        if (myXStart + myXSize > 1.0) {
            myXSize = 1.0 - myXStart;
        }
        if (myYStart + myYSize > 1.0) {
            myYSize = 1.0 - myYStart;
        }
        SKTexture *myShapeTexture = thePhoto.texture;
        myCustomSpriteNode *myRandomQuad = [[myCustomSpriteNode alloc] init];
        CGPoint myPhotoPosition = CGPointMake(thePhoto.position.x + my100OffsetRandomSource.nextInt, thePhoto.position.y + my100OffsetRandomSource.nextInt);
        [myRandomQuad setPosition:myPhotoPosition];
        [myRandomQuad setSize:CGSizeMake(50.0, 50.0)];
        [myRandomQuad setPhysicsBody:[SKPhysicsBody bodyWithRectangleOfSize:myRandomQuad.size]];
        [myRandomQuad setMyResizeValue:theValue];
        [myRandomQuad setTexture:[SKTexture textureWithRect:CGRectMake(myXStart, myYStart, myXSize, myYSize) inTexture:myShapeTexture]];
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

-(void)myRandomQuadsFromPhoto:(SKSpriteNode *)thePhoto withResizeValue:(int)theValue {
    for (int i = 1; i <= 5; i++) {
        CGPoint myLowerLeft = CGPointMake(0.0, 0.0);
        CGPoint myLowerRight = CGPointMake(myLowerLeft.x + (arc4random() % 10) + 50, myLowerLeft.y + (arc4random() % 25));
        CGPoint myUpperRight = CGPointMake(myLowerRight.x + (arc4random() % 10), myLowerRight.y + (arc4random() % 10) + 80.0);
        CGPoint myUpperLeft = CGPointMake(myUpperRight.x - ((arc4random() % 10) + 80), myUpperRight.y + arc4random() % 10);

        CGMutablePathRef myPathRef = CGPathCreateMutable();
        CGPathMoveToPoint(myPathRef, nil, myLowerLeft.x, myLowerLeft.y);
        CGPathAddLineToPoint(myPathRef, nil, myLowerRight.x, myLowerRight.y);
        CGPathAddLineToPoint(myPathRef, nil, myUpperRight.x, myUpperRight.y);
        CGPathAddLineToPoint(myPathRef, nil, myUpperLeft.x, myUpperLeft.y);
        CGPathCloseSubpath(myPathRef);

        float myXStart = (arc4random() % 100) / 100.0;
        float myYStart = (arc4random() % 100) / 100.0;
        float myXSize = arc4random() % 100;
        float myYSize = arc4random() % 100;
        if (myXStart + myXSize > 1.0) {
            myXSize = 1.0 - myXStart;
        }
        if (myYStart + myYSize > 1.0) {
            myYSize = 1.0 - myYStart;
        }

        SKTexture *myShapeTexture = thePhoto.texture;
        myCustomShapeNode *myRandomQuad = [myCustomShapeNode shapeNodeWithPath:myPathRef];

        [myRandomQuad setPhysicsBody:[SKPhysicsBody bodyWithPolygonFromPath:myPathRef]];
        float myRandomRestitution = (arc4random() % 100) / 100.0;
        [myRandomQuad.physicsBody setRestitution:myRandomRestitution];
        [myRandomQuad setPosition:thePhoto.position];
        [myRandomQuad setZPosition:4.0];
        [myRandomQuad setMyResizeValue:theValue];
        [myRandomQuad setFillTexture:[SKTexture textureWithRect:CGRectMake(myXStart, myYStart, myXSize, myYSize) inTexture:myShapeTexture]];
        [myRandomQuad setName:@"sprite"];

        int myRandomColorize = arc4random() % 2;
        if (myRandomColorize == 0) {
            float myRandomRed = (arc4random() % 100) / 100.0;
            float myRandomGreen = (arc4random() % 100) / 100.0;
            float myRandomBlue = (arc4random() % 100) / 100.0;
            [myRandomQuad setFillColor:[UIColor colorWithRed:myRandomRed green:myRandomGreen blue:myRandomBlue alpha:1.0]];
        } else {
            [myRandomQuad setFillColor:[UIColor whiteColor]];
        }
        int myRandomLineWidth = arc4random() % 3;
        [myRandomQuad setLineWidth:myRandomLineWidth];
        int myRandomGlowWidth = arc4random() % 3;
        [myRandomQuad setGlowWidth:myRandomGlowWidth];
        [thePhoto removeFromParent];
        [self addChild:myRandomQuad];
        [myRandomQuad runAction:[SKAction sequence:@[
            [SKAction waitForDuration:3.0],
            [SKAction fadeAlphaTo:0.1 duration:0.25],
            [SKAction removeFromParent],
        ]]];

        CGPathRelease(myPathRef);
    }
}

-(void)myCloudFromPhoto:(SKSpriteNode *)thePhoto withResizeValue:(int)theValue {
    SKTexture *myEmitterTexture = thePhoto.texture;
    myCustomEmitterNode *myPP = [[myCustomEmitterNode alloc] init];
    [myPP setPosition:thePhoto.position];
    [thePhoto removeFromParent];

    [myPP setResizeValue:theValue];
    [myPP setParticleBirthRate:1000.0];
    int myRandomNumParticlesToEmit = (arc4random() % 100) + 50;
    [myPP setNumParticlesToEmit:myRandomNumParticlesToEmit];
    [myPP setParticleLifetime:3.0];
    [myPP setParticleSpeed:5.0];
    [myPP setParticleSpeedRange:5.0];
    [myPP setParticleScale:0.1];
    [myPP setParticleScaleRange:0.2];
    [myPP setParticleScaleSpeed:-0.6];

    [myPP setParticleTexture:myEmitterTexture];
    float myRandomParticleScale = ((arc4random() % 10) / 100.0) + 0.5;
    [myPP setParticleScale:myRandomParticleScale];
    float myRandomParticlePositionRange = (arc4random() % 200) + 100.0;
    [myPP setParticlePositionRange:CGVectorMake(myRandomParticlePositionRange, myRandomParticlePositionRange)];

    int myRandomParticleWait = arc4random() % 3;

    [myPP setZPosition:0.0];
    [self addChild:myPP];
    [myPP setParticleBlendMode:SKBlendModeReplace];
    [myPP setName:@"particle system"];
    [myPP runAction:[SKAction sequence:@[
        [SKAction waitForDuration:myRandomParticleWait],
        [SKAction removeFromParent],
    ]]];
}

-(void)myParticleSystemFromPhoto:(SKSpriteNode *)thePhoto withResizeValue:(int)theValue {
    SKTexture *myEmitterTexture = thePhoto.texture;
    myCustomEmitterNode *myPP = [[myCustomEmitterNode alloc] init];
    [myPP setPosition:thePhoto.position];
    [thePhoto removeFromParent];

    [myPP setParticleBlendMode:SKBlendModeReplace];
    [myPP setName:@"particle system"];
    [myPP setResizeValue:theValue];
    [myPP setParticleBirthRate:1000.0];
    int myRandomNumParticlesToEmit = (arc4random() % 150) + 50;
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
    float myRandomParticleScale = ((arc4random() % 10) / 20.0) + 0.5;
    [myPP setParticleScale:myRandomParticleScale];
    [self addChild:myPP];

    float myRandomParticleWait = (arc4random() % 30) / 10.0;
    [myPP runAction:[SKAction sequence:@[
        [SKAction waitForDuration:myRandomParticleWait],
        [SKAction removeFromParent],
    ]]];
}

-(void)myCirclesFromPhoto:(SKSpriteNode *)thePhoto withResize:(int)theResizeValue {
    [thePhoto runAction:[SKAction sequence:@[
        [SKAction waitForDuration:3.0],
        [SKAction removeFromParent],
    ]]];

    SKTexture *myCircleTexture = thePhoto.texture;
    CGPoint myCirclePosition = thePhoto.position;
    int myRandomRadius = (arc4random() % 100) + 1;
    myCustomShapeNode *myCircle = [myCustomShapeNode shapeNodeWithCircleOfRadius:myRandomRadius];
    [myCircle setPhysicsBody:[SKPhysicsBody bodyWithCircleOfRadius:myRandomRadius]];
    float myRandomRestitution = (arc4random() % 100) / 100.0;
    [myCircle.physicsBody setRestitution:myRandomRestitution];
    [myCircle setName:@"sprite"];
    [myCircle setPosition:myCirclePosition];
    [myCircle setZPosition:4.0];

    int myRandomColorize = arc4random() % 2;
    if (myRandomColorize == 0) {
        float myRandomRed = (arc4random() % 100) / 100.0;
        float myRandomGreen = (arc4random() % 100) / 100.0;
        float myRandomBlue = (arc4random() % 100) / 100.0;
        [myCircle setFillColor:[UIColor colorWithRed:myRandomRed green:myRandomGreen blue:myRandomBlue alpha:1.0]];
    } else {
        [myCircle setFillColor:[UIColor whiteColor]];
    }
    int myRandomLineWidth = arc4random() % 3;
    [myCircle setLineWidth:myRandomLineWidth];
    int myRandomGlowWidth = arc4random() % 3;
    [myCircle setGlowWidth:myRandomGlowWidth];

    [myCircle setFillTexture:myCircleTexture];
    [myCircle setBlendMode:SKBlendModeReplace];

    SKNode *myCopy1 = nil;
    int mySecondCircleGate = arc4random() % 2;
    if (mySecondCircleGate) {
        myCopy1 = [myCircle copy];
    }

    float myRandomCircleWait = ((arc4random() % 30) / 100) + 1.5;
    SKAction *myCircleAction = [SKAction sequence:@[
        [SKAction waitForDuration:myRandomCircleWait],
        [SKAction removeFromParent],
    ]];

    [self addChild:myCircle];
    if (mySecondCircleGate && myCopy1) {
        [self addChild:myCopy1];
    }

    NSMutableArray *myCircles = [NSMutableArray arrayWithObjects:myCircle, nil];
    if (mySecondCircleGate && myCopy1) {
        [myCircles addObject:myCopy1];
    }

    for (SKNode *node in myCircles) {
        [node runAction:myCircleAction];
    }
}

-(void)myBetterSegmentPhotoAndDrop:(SKSpriteNode *)thePhoto {
    if (myTimeSinceLastFrame > myScreenRefreshTimeToHoldOffDroppingPictures) {
        return;
    }

    // Create segments of the photo
    int numSegments = 4;
    CGFloat segmentWidth = thePhoto.size.width / 2.0;
    CGFloat segmentHeight = thePhoto.size.height / 2.0;

    for (int row = 0; row < 2; row++) {
        for (int col = 0; col < 2; col++) {
            CGRect textureRect = CGRectMake(col * 0.5, row * 0.5, 0.5, 0.5);
            SKTexture *segmentTexture = [SKTexture textureWithRect:textureRect inTexture:thePhoto.texture];

            myCustomSpriteNode *segment = [myCustomSpriteNode spriteNodeWithTexture:segmentTexture size:CGSizeMake(segmentWidth, segmentHeight)];

            CGFloat offsetX = (col - 0.5) * segmentWidth * 0.5;
            CGFloat offsetY = (row - 0.5) * segmentHeight * 0.5;
            segment.position = CGPointMake(thePhoto.position.x + offsetX, thePhoto.position.y + offsetY);

            segment.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:segment.size];
            segment.physicsBody.restitution = 0.6;
            segment.physicsBody.contactTestBitMask = 0x02;
            [segment setName:@"sprite"];
            [segment setBlendMode:SKBlendModeReplace];

            [self addChild:segment];

            // Apply impulse to spread segments
            CGFloat impulseX = (col == 0) ? -50 : 50;
            CGFloat impulseY = (row == 0) ? -50 : 50;
            [segment.physicsBody applyImpulse:CGVectorMake(impulseX * 0.01, impulseY * 0.01)];

            // Remove after delay
            [segment runAction:[SKAction sequence:@[
                [SKAction waitForDuration:3.0],
                [SKAction fadeAlphaTo:0.0 duration:0.3],
                [SKAction removeFromParent]
            ]]];
        }
    }

    [thePhoto removeFromParent];
}

@end
