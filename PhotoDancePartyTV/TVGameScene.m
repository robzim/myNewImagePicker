//
//  TVGameScene.m
//  PhotoDancePartyTV
//
//  Created by Robert Zimmelman.
//  Copyright © 2024 Robert Zimmelman. All rights reserved.
//

#import "TVGameScene.h"
#import "PhotoDancePartyTV-Swift.h"

// Performance thresholds
float tvScreenRefreshTimeToDump = 0.35;
float tvScreenRefreshTimeToHoldOffDroppingPictures = 0.2;
int tvAcceptableNodeCount = 300;

// Scale multipliers
float tvPhotoScaleMultiplier = 1.5;
float tvParticleSystemScaleMultiplier = 1.2;

// Sprite configuration
int tvYOffset = 30;
float tvImageSpriteDamping = 0.0;
float tvImageSpriteMass = 0.5;
float tvImageSpriteRestitution = 0.7;
float tvImageSpriteSize = 0;
int tvFrameWidth;

// Magical colors for effects
#define MAGIC_PINK [SKColor colorWithRed:1.0 green:0.4 blue:0.6 alpha:1.0]
#define MAGIC_CYAN [SKColor colorWithRed:0.2 green:0.9 blue:1.0 alpha:1.0]
#define MAGIC_PURPLE [SKColor colorWithRed:0.6 green:0.3 blue:1.0 alpha:1.0]
#define MAGIC_GOLD [SKColor colorWithRed:1.0 green:0.85 blue:0.3 alpha:1.0]
#define MAGIC_GREEN [SKColor colorWithRed:0.3 green:1.0 blue:0.5 alpha:1.0]

@implementation TVGameScene {
    GKRandomDistribution *randomOffsetSource;
    GKRandomDistribution *shuffledRandomSource;
    float lastInstantPower;
    float powerDifference;
}

@synthesize myVibrateFlag, myImage1Flag, myImage2Flag, myImage3Flag, myImage4Flag, myImage5Flag;
@synthesize myResizeMethod;
@synthesize myDropPicturesTimer;
@synthesize mySpriteImage1, mySpriteImage2, mySpriteImage3, mySpriteImage4, mySpriteImage5;
@synthesize myImageSprite1, myImageSprite2, myImageSprite3, myImageSprite4, myImageSprite5;
@synthesize myAllRandomImagesFlag;
@synthesize myPhotos, myImageManager;
@synthesize myTexture1, myTexture2, myTexture3, myTexture4, myTexture5;
@synthesize myImageSpriteAction, myBG;
@synthesize myTimeSinceLastFrame, myLastTimeSample;
@synthesize firstNode, secondNode;
@synthesize myAudioPlayer;
@synthesize myAudioLevelLabel, myInstantPower, myAveragePower;
@synthesize myMusicURL, myMusicStoreID, mySongTitle, mySongArtist;
@synthesize mySystemMusicPlayer, myUsingAppleMusic, myIsUserLibrarySong;
@synthesize myPicturesArray;
@synthesize myAudioDisplayNode;
@synthesize mySceneImageSize;
@synthesize myBaseBPM, myLastBeatTime, myBeatInterval, myBeatCount, myBeatVariance, myCurrentSceneTime;

#pragma mark - dB Conversion

- (double)myDbToAmp:(double)inDb {
    return pow(10., 0.05 * inDb);
}

#pragma mark - Scene Lifecycle

- (void)didMoveToView:(SKView *)view {
    [self.view setShouldCullNonVisibleNodes:YES];

    randomOffsetSource = [GKRandomDistribution distributionWithLowestValue:-100 highestValue:100];
    shuffledRandomSource = [GKShuffledDistribution distributionWithLowestValue:1 highestValue:8];

    [[PHPhotoLibrary sharedPhotoLibrary] registerChangeObserver:self];

    PHFetchOptions *fetchOptions = [[PHFetchOptions alloc] init];
    [fetchOptions setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:YES]]];
    myPhotos = [PHAsset fetchAssetsWithOptions:fetchOptions];
    myImageManager = [[PHImageManager alloc] init];

    // Start music
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        [weakSelf myStartTheMusic];
    });

    [self myStartTheGame];
    [self myMakeMenuReminderLabel];

    // Setup audio display after short delay
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [weakSelf mySetupAudioDisplay];
    });

    // Setup and show debug display after delay
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [weakSelf myToggleDebugDisplay];  // Show debug display on tvOS
    });

    // Add menu press gesture to toggle debug display
    if (@available(tvOS 14.0, *)) {
        UITapGestureRecognizer *menuPress = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(myToggleDebugDisplay)];
        menuPress.allowedPressTypes = @[@(UIPressTypeMenu)];
        [self.view addGestureRecognizer:menuPress];
    }

    // Notifications
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(myMusicSelected) name:@"musicselected" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(myPlayPauseNotification) name:@"playpause" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(myRestartTheMusic) name:@"restartmusic" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(myDoAssignImage1) name:@"assignimage1" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(myDoAssignImage2) name:@"assignimage2" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(myDoAssignImage3) name:@"assignimage3" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(myDoAssignImage4) name:@"assignimage4" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(myDoAssignImage5) name:@"assignimage5" object:nil];

}

- (void)willMoveFromView:(SKView *)view {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[PHPhotoLibrary sharedPhotoLibrary] unregisterChangeObserver:self];
    [myDropPicturesTimer invalidate];
    myDropPicturesTimer = nil;
    [myAudioPlayer stop];
    [MusicLibraryHelper stopPlayback];
    if (myUsingAppleMusic) {
        [mySystemMusicPlayer stop];
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[PHPhotoLibrary sharedPhotoLibrary] unregisterChangeObserver:self];
    [myDropPicturesTimer invalidate];
}

#pragma mark - Game Start

- (void)myStartTheGame {
    self.backgroundColor = [SKColor colorWithRed:0.05 green:0.0 blue:0.1 alpha:1.0];

    // Enable music-reactive resizing by default (mode 2 = pulse mode)
    if (myResizeMethod == 0) {
        myResizeMethod = 2;
    }

    // Initialize BPM-based beat generation
    self.myBaseBPM = 120.0;
    self.myBeatInterval = 60.0 / self.myBaseBPM;
    self.myLastBeatTime = 0;
    self.myBeatCount = 0;
    self.myBeatVariance = 0.05;
    self.myCurrentSceneTime = 0;

    // Setup animated gradient background
    [self setupAnimatedBackground];

    tvFrameWidth = (int)self.frame.size.width;

    self.physicsWorld.gravity = CGVectorMake(0.0, -9.5);
    [self setPhysicsBody:[SKPhysicsBody bodyWithEdgeLoopFromRect:self.frame]];
    self.physicsWorld.contactDelegate = self;

    // Create sprite nodes from images
    myImageSprite1 = [SKSpriteNode spriteNodeWithTexture:[SKTexture textureWithImage:mySpriteImage1]];
    myImageSprite2 = [SKSpriteNode spriteNodeWithTexture:[SKTexture textureWithImage:mySpriteImage2]];
    myImageSprite3 = [SKSpriteNode spriteNodeWithTexture:[SKTexture textureWithImage:mySpriteImage3]];
    myImageSprite4 = [SKSpriteNode spriteNodeWithTexture:[SKTexture textureWithImage:mySpriteImage4]];
    myImageSprite5 = [SKSpriteNode spriteNodeWithTexture:[SKTexture textureWithImage:mySpriteImage5]];

    // TV-optimized sprite size (larger for TV viewing distance)
    tvImageSpriteSize = (self.size.width + self.size.height) * 0.03;

    [self myMakeIntroLabels];
    [self myStartDropPicturesTimer];

    // Celebration effect on game start
    [self celebrationEffect];
}

#pragma mark - Animated Background

- (void)setupAnimatedBackground {
    // Create a gradient background using SKShapeNode layers
    SKSpriteNode *backgroundNode = [SKSpriteNode spriteNodeWithColor:[SKColor colorWithRed:0.05 green:0.0 blue:0.1 alpha:1.0] size:self.size];
    backgroundNode.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
    backgroundNode.zPosition = -100;
    backgroundNode.name = @"background";
    [self addChild:backgroundNode];

    // Add floating particles in the background
    SKEmitterNode *ambientParticles = [SKEmitterNode node];
    ambientParticles.particleTexture = [SKTexture textureWithImageNamed:@"spark"];
    ambientParticles.particleBirthRate = 3;
    ambientParticles.particleLifetime = 8;
    ambientParticles.particleLifetimeRange = 4;
    ambientParticles.particlePositionRange = CGVectorMake(self.size.width, self.size.height);
    ambientParticles.particleSpeed = 20;
    ambientParticles.particleSpeedRange = 15;
    ambientParticles.emissionAngle = M_PI_2;
    ambientParticles.emissionAngleRange = M_PI;
    ambientParticles.particleAlpha = 0.3;
    ambientParticles.particleAlphaSpeed = -0.03;
    ambientParticles.particleScale = 0.15;
    ambientParticles.particleScaleRange = 0.1;
    ambientParticles.particleColorBlendFactor = 1.0;
    ambientParticles.particleColor = MAGIC_PURPLE;
    ambientParticles.particleBlendMode = SKBlendModeAdd;
    ambientParticles.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
    ambientParticles.zPosition = -99;
    ambientParticles.name = @"ambientParticles";
    [self addChild:ambientParticles];
}

#pragma mark - Labels

- (void)myMakeMenuReminderLabel {
    SKLabelNode *reminderLabel = [SKLabelNode labelNodeWithFontNamed:@"HelveticaNeue-Medium"];
    reminderLabel.text = @"Press Menu for Options • Play/Pause to Toggle Music";
    reminderLabel.fontSize = 28;
    reminderLabel.fontColor = [SKColor colorWithWhite:0.5 alpha:0.8];
    reminderLabel.position = CGPointMake(CGRectGetMidX(self.frame), 40);
    reminderLabel.zPosition = 50;
    reminderLabel.name = @"reminderLabel";

    [self addChild:reminderLabel];

    // Fade out after 5 seconds
    [reminderLabel runAction:[SKAction sequence:@[
        [SKAction waitForDuration:5.0],
        [SKAction fadeOutWithDuration:1.0],
        [SKAction removeFromParent]
    ]]];
}

- (void)myMakeIntroLabels {
    SKLabelNode *titleLabel = [SKLabelNode labelNodeWithFontNamed:@"HelveticaNeue-Bold"];
    titleLabel.text = @"Photo Dance Party!";
    titleLabel.fontSize = 72;
    titleLabel.fontColor = MAGIC_CYAN;
    titleLabel.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame) + 40);
    titleLabel.zPosition = 50;

    [self addChild:titleLabel];

    [titleLabel runAction:[SKAction sequence:@[
        [SKAction waitForDuration:2.0],
        [SKAction fadeOutWithDuration:1.0],
        [SKAction removeFromParent]
    ]]];
}

#pragma mark - Drop Pictures Timer

- (void)myStartDropPicturesTimer {
    [myDropPicturesTimer invalidate];
    float dropInterval = 1.0 + ((arc4random() % 50) / 100.0);
    myDropPicturesTimer = [NSTimer scheduledTimerWithTimeInterval:dropInterval
                                                          target:self
                                                        selector:@selector(myDropPictures)
                                                        userInfo:nil
                                                         repeats:NO];
}

- (void)myDropPictures {
    if (self.children.count > tvAcceptableNodeCount) {
        NSLog(@"Too many nodes (%d), cleaning up", (int)self.children.count);
        [self enumerateChildNodesWithName:@"sprite" usingBlock:^(SKNode *node, BOOL *stop) {
            [node removeFromParent];
        }];
        [self enumerateChildNodesWithName:@"particle system" usingBlock:^(SKNode *node, BOOL *stop) {
            [node removeFromParent];
        }];
        [self myStartDropPicturesTimer];
        return;
    }

    if ((myTimeSinceLastFrame > tvScreenRefreshTimeToHoldOffDroppingPictures) && (myTimeSinceLastFrame < 10.0)) {
        [self enumerateChildNodesWithName:@"sprite" usingBlock:^(SKNode *node, BOOL *stop) {
            [node removeFromParent];
        }];
        [self enumerateChildNodesWithName:@"particle system" usingBlock:^(SKNode *node, BOOL *stop) {
            [node removeFromParent];
        }];
        [self myStartDropPicturesTimer];
        return;
    }

    // Pick random picture from enabled array
    int pictureIndex = arc4random() % 5;
    if (myPicturesArray.count > 0) {
        pictureIndex = arc4random() % myPicturesArray.count;
    }

    int pictureToDrop = (int)[[myPicturesArray objectAtIndex:pictureIndex] integerValue];

    // If all-random mode, assign random photo from library first
    if (myAllRandomImagesFlag && myPhotos.count > 4) {
        [self assignRandomPhotoToSlot:pictureToDrop];
    }

    [self myDropPictureNumber:pictureToDrop];
    [self myStartDropPicturesTimer];
}

- (void)assignRandomPhotoToSlot:(int)slot {
    if (!myImageManager || myPhotos.count == 0) return;

    int randomIndex = arc4random() % myPhotos.count;
    PHAsset *asset = myPhotos[randomIndex];

    PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
    options.synchronous = YES;
    options.deliveryMode = PHImageRequestOptionsDeliveryModeFastFormat;

    [myImageManager requestImageForAsset:asset
                              targetSize:CGSizeMake(200, 200)
                             contentMode:PHImageContentModeAspectFill
                                 options:options
                           resultHandler:^(UIImage *result, NSDictionary *info) {
        if (!result) return;
        switch (slot) {
            case 1:
                self.mySpriteImage1 = result;
                self.myImageSprite1 = [SKSpriteNode spriteNodeWithTexture:[SKTexture textureWithImage:result]];
                break;
            case 2:
                self.mySpriteImage2 = result;
                self.myImageSprite2 = [SKSpriteNode spriteNodeWithTexture:[SKTexture textureWithImage:result]];
                break;
            case 3:
                self.mySpriteImage3 = result;
                self.myImageSprite3 = [SKSpriteNode spriteNodeWithTexture:[SKTexture textureWithImage:result]];
                break;
            case 4:
                self.mySpriteImage4 = result;
                self.myImageSprite4 = [SKSpriteNode spriteNodeWithTexture:[SKTexture textureWithImage:result]];
                break;
            case 5:
                self.mySpriteImage5 = result;
                self.myImageSprite5 = [SKSpriteNode spriteNodeWithTexture:[SKTexture textureWithImage:result]];
                break;
        }
    }];
}

#pragma mark - Drop Picture

- (void)myDropPictureNumber:(int)thePictureNumber {
    SKSpriteNode *pictureSprite = nil;

    switch (thePictureNumber) {
        case 1: pictureSprite = [myImageSprite1 copy]; break;
        case 2: pictureSprite = [myImageSprite2 copy]; break;
        case 3: pictureSprite = [myImageSprite3 copy]; break;
        case 4: pictureSprite = [myImageSprite4 copy]; break;
        case 5: pictureSprite = [myImageSprite5 copy]; break;
        default: return;
    }

    if (!pictureSprite) return;

    int randomXPosition = arc4random() % tvFrameWidth;
    pictureSprite.position = CGPointMake(randomXPosition, CGRectGetMaxY(self.frame) - tvYOffset);
    [pictureSprite setSize:CGSizeMake(tvImageSpriteSize, tvImageSpriteSize)];
    pictureSprite.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:pictureSprite.size];

    float randomRestitution = ((arc4random() % 50) / 50.0) + 0.5;
    if (randomRestitution > 1.0) randomRestitution = 1.0;
    pictureSprite.physicsBody.restitution = randomRestitution;
    pictureSprite.physicsBody.contactTestBitMask = 0x02;

    [pictureSprite setName:@"sprite"];
    [pictureSprite setBlendMode:SKBlendModeReplace];

    // Add glow effect with random color
    SKColor *glowColor = [self randomMagicColor];
    [self addGlowToSprite:pictureSprite withColor:glowColor];

    // Rainbow trail (50% chance)
    if (arc4random() % 2 == 0) {
        [self createRainbowTrailForSprite:pictureSprite];
    }

    [self addChild:pictureSprite];

    // Entrance sparkle
    [self createSparkleEffectAtPosition:pictureSprite.position withColor:glowColor];

    [pictureSprite.physicsBody setLinearDamping:tvImageSpriteDamping];
}

#pragma mark - Music

- (void)myStartTheMusic {
    // Stop any currently playing music first
    [myAudioPlayer stop];
    myAudioPlayer = nil;
    [mySystemMusicPlayer stop];
    [MusicLibraryHelper stopPlayback];

    // Refresh the now playing display with the new song info
    [self mySetupAudioDisplay];

    // User library song — play via MusicKit ApplicationMusicPlayer
    if (myIsUserLibrarySong && myMusicStoreID) {
        myUsingAppleMusic = YES;

        __weak typeof(self) weakSelf = self;
        [MusicLibraryHelper playSongWithID:myMusicStoreID completion:^(BOOL success) {
            if (!success) {
                NSLog(@"MusicKit playback failed, falling back to bundled music");
                [weakSelf playBundledMusic];
            }
        }];
        return;
    }

    // Apple Music playback via MPMusicPlayerController
    if (myMusicStoreID) {
        myUsingAppleMusic = YES;

        self.mySystemMusicPlayer = [MPMusicPlayerController applicationMusicPlayer];
        [self.mySystemMusicPlayer setQueueWithStoreIDs:@[myMusicStoreID]];
        self.mySystemMusicPlayer.repeatMode = MPMusicRepeatModeAll;
        [self.mySystemMusicPlayer play];
        return;
    }

    // AVAudioPlayer playback (bundled or preview URL)
    myUsingAppleMusic = NO;
    myIsUserLibrarySong = NO;

    if (myMusicURL) {
        if ([myMusicURL.scheme hasPrefix:@"http"]) {
            // Remote URL — download to temp file first (AVAudioPlayer needs local files)
            NSLog(@"Downloading preview from: %@", myMusicURL);
            NSURLSessionDownloadTask *downloadTask = [[NSURLSession sharedSession] downloadTaskWithURL:myMusicURL completionHandler:^(NSURL *tempLocation, NSURLResponse *response, NSError *downloadError) {
                if (downloadError || !tempLocation) {
                    NSLog(@"Preview download failed: %@", downloadError);
                    // Fall back to bundled music
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self playBundledMusic];
                    });
                    return;
                }

                // Move to a persistent temp path (download temp file gets deleted)
                NSString *tempPath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"preview_music.m4a"];
                NSURL *localURL = [NSURL fileURLWithPath:tempPath];
                [[NSFileManager defaultManager] removeItemAtURL:localURL error:nil];
                NSError *moveError = nil;
                [[NSFileManager defaultManager] moveItemAtURL:tempLocation toURL:localURL error:&moveError];
                if (moveError) {
                    NSLog(@"Failed to move preview file: %@", moveError);
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self playBundledMusic];
                    });
                    return;
                }

                dispatch_async(dispatch_get_main_queue(), ^{
                    [self playAudioFromLocalURL:localURL];
                });
            }];
            [downloadTask resume];
            return;
        }

        // Local file URL
        [self playAudioFromLocalURL:myMusicURL];
        return;
    }

    // No URL — play bundled music
    [self playBundledMusic];
}

- (void)playBundledMusic {
    // Reset flags so AVAudioPlayer metering path is used
    myUsingAppleMusic = NO;
    myIsUserLibrarySong = NO;

    NSString *soundFilePath = [[NSBundle mainBundle] pathForResource:@"Skrxlla - Caution" ofType:@"mp3"];
    if (!soundFilePath) return;
    NSURL *fileURL = [[NSURL alloc] initFileURLWithPath:soundFilePath];
    [self playAudioFromLocalURL:fileURL];
}

- (void)playAudioFromLocalURL:(NSURL *)fileURL {
    NSError *audioError = nil;
    AVAudioPlayer *newPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:fileURL error:&audioError];
    if (audioError) {
        NSLog(@"Audio error: %@", audioError);
        return;
    }

    self.myAudioPlayer = newPlayer;
    [myAudioPlayer prepareToPlay];
    [myAudioPlayer setDelegate:self];
    [myAudioPlayer setMeteringEnabled:YES];
    [myAudioPlayer setNumberOfLoops:-1];
    [myAudioPlayer play];
}

- (void)myPlayPause {
    if (myIsUserLibrarySong) {
        // MusicKit library song — stop or restart
        [MusicLibraryHelper stopPlayback];
        if (myMusicStoreID) {
            [MusicLibraryHelper playSongWithID:myMusicStoreID completion:^(BOOL success) {
                if (!success) {
                    NSLog(@"MusicKit play/pause failed");
                }
            }];
        }
    } else if (myUsingAppleMusic) {
        if (mySystemMusicPlayer.playbackState == MPMusicPlaybackStatePlaying) {
            [mySystemMusicPlayer pause];
        } else {
            [mySystemMusicPlayer play];
        }
    } else {
        if (myAudioPlayer.isPlaying) {
            [myAudioPlayer stop];
        } else {
            [myAudioPlayer play];
        }
    }
}

- (void)myPlayPauseNotification {
    [self myPlayPause];
}

- (void)myRestartTheMusic {
    if (myIsUserLibrarySong) {
        [MusicLibraryHelper stopPlayback];
        if (myMusicStoreID) {
            [MusicLibraryHelper playSongWithID:myMusicStoreID completion:^(BOOL success) {
                if (!success) {
                    NSLog(@"MusicKit restart failed");
                }
            }];
        }
    } else if (myUsingAppleMusic) {
        [mySystemMusicPlayer skipToBeginning];
        [mySystemMusicPlayer play];
    } else {
        [myAudioPlayer stop];
        [myAudioPlayer setCurrentTime:0.0];
        [myAudioPlayer prepareToPlay];
        [myAudioPlayer setDelegate:self];
        [myAudioPlayer setMeteringEnabled:YES];
        [myAudioPlayer setNumberOfLoops:-1];
        [myAudioPlayer play];
    }
}

- (void)myMusicSelected {
    [self myRestartTheMusic];
    [self mySetupAudioDisplay];
}

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    // Music loops infinitely
}

#pragma mark - Procedural Beat Generation (Mode 3)

- (void)myGenerateProceduralBeats {
    NSTimeInterval now = self.myCurrentSceneTime;
    float timeSinceLastBeat = now - myLastBeatTime;

    if (timeSinceLastBeat >= myBeatInterval) {
        // Generate beat strength with variance for natural feel
        float beatStrength = 1.5 + ((arc4random() % 100) / 100.0);

        // Add occasional accent beats (2x strength every 4-8 beats)
        if (myBeatCount % 4 == 0 && (arc4random() % 2 == 0)) {
            beatStrength += 0.5;
        }

        [self myResizePhotosToSize:beatStrength];
        [self myResizeParticlesToSize:beatStrength];

        // Update stored scale for debug display
        self.myCurrentScaleTo = beatStrength;

        myLastBeatTime = now;
        myBeatCount++;
    }
}

#pragma mark - Music-Reactive Resize

- (void)myResizeSpritesToMusic {
    myInstantPower = 0;
    myAveragePower = 0;

    if (myResizeMethod == 0) return;

    // Mode 3: Procedural beat generation (used with Apple Music)
    if (myResizeMethod == 3) {
        [self myGenerateProceduralBeats];
        return;
    }

    if (myUsingAppleMusic) {
        // Switch to procedural beats for Apple Music (no metering available)
        NSLog(@"Switching to procedural beat generation: Apple Music audio metering unavailable on tvOS");
        myResizeMethod = 3;
        [self showProceduralBeatsMessage];
        [self myGenerateProceduralBeats];
        return;
    }

    // Real metering with AVAudioPlayer (bundled or preview music)
    if (!myAudioPlayer || !myAudioPlayer.isPlaying) return;

    [myAudioPlayer updateMeters];
    for (int i = 0; i < myAudioPlayer.numberOfChannels; i++) {
        myInstantPower += [myAudioPlayer peakPowerForChannel:i];
        myAveragePower += [myAudioPlayer averagePowerForChannel:i];
    }
    myInstantPower = myInstantPower / myAudioPlayer.numberOfChannels;

    powerDifference = fabs(myInstantPower - lastInstantPower);
    lastInstantPower = myInstantPower;

    float scaleTo = 1.0;
    if (myResizeMethod == 2) {
        // Music pulse mode - FIXED: divide by 20, add baseline, clamp max
        scaleTo = fmin(1.0 + (powerDifference / 20.0), 2.5);
    } else if (myResizeMethod == 1) {
        // Instant audio mode - scale based on current audio level
        scaleTo = [self myDbToAmp:myInstantPower];
    }

    // Store for debug display
    self.myCurrentScaleTo = scaleTo;

    // Apply resizing: In mode 1, always resize. In mode 2, only if there's a power change
    // or if the audio is above a minimum threshold to avoid no-resizing on quiet passages
    BOOL shouldResize = NO;
    if (myResizeMethod == 1) {
        shouldResize = YES;  // Always resize in instant mode
    } else if (myResizeMethod == 2 && (powerDifference > 0.05 || myInstantPower > -20.0)) {
        shouldResize = YES;  // In pulse mode, resize if there's change OR audio is reasonably loud
    }

    if (shouldResize) {
        [self myResizePhotosToSize:scaleTo];
        [self myResizeParticlesToSize:scaleTo];
    }
}

- (void)myResizePhotosToSize:(float)scaleToSize {
    [self enumerateChildNodesWithName:@"sprite" usingBlock:^(SKNode *node, BOOL *stop) {
        [node runAction:[SKAction sequence:@[
            [SKAction scaleTo:scaleToSize * tvPhotoScaleMultiplier duration:0.0],
            [SKAction scaleTo:1.0 duration:0.0],
        ]]];
    }];
}

- (void)myResizeParticlesToSize:(float)scaleToSize {
    int resizeGate = arc4random() % 5;
    if (resizeGate != 0) return;

    [self enumerateChildNodesWithName:@"particle system" usingBlock:^(SKNode *node, BOOL *stop) {
        if (![node isKindOfClass:[myCustomEmitterNode class]]) return;
        if ([(myCustomEmitterNode *)node myResizeValue] == 0) {
            float savedXScale = node.xScale;
            [node runAction:[SKAction sequence:@[
                [SKAction scaleTo:scaleToSize * tvParticleSystemScaleMultiplier duration:0.0],
                [SKAction scaleTo:savedXScale duration:0.0],
            ]]];
        }
    }];
}

#pragma mark - User Messaging

- (void)showBeatsUnavailableMessage {
    // Only show message once
    static BOOL hasShownMessage = NO;
    if (hasShownMessage) return;
    hasShownMessage = YES;

    SKLabelNode *messageLabel = [SKLabelNode labelNodeWithFontNamed:@"HelveticaNeue-Medium"];
    messageLabel.text = @"Music-Reactive Features Unavailable";
    messageLabel.fontSize = 32;
    messageLabel.fontColor = MAGIC_GOLD;
    messageLabel.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame) - 100);
    messageLabel.zPosition = 100;
    messageLabel.name = @"beatsUnavailableMessage";

    SKLabelNode *detailLabel = [SKLabelNode labelNodeWithFontNamed:@"HelveticaNeue"];
    detailLabel.text = @"Apple Music audio cannot be metered on tvOS";
    detailLabel.fontSize = 20;
    detailLabel.fontColor = [SKColor colorWithWhite:0.7 alpha:1.0];
    detailLabel.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame) - 140);
    detailLabel.zPosition = 100;
    detailLabel.name = @"beatsUnavailableDetail";

    [self addChild:messageLabel];
    [self addChild:detailLabel];

    // Fade out and remove after 5 seconds
    [messageLabel runAction:[SKAction sequence:@[
        [SKAction waitForDuration:5.0],
        [SKAction fadeOutWithDuration:1.0],
        [SKAction removeFromParent]
    ]]];

    [detailLabel runAction:[SKAction sequence:@[
        [SKAction waitForDuration:5.0],
        [SKAction fadeOutWithDuration:1.0],
        [SKAction removeFromParent]
    ]]];
}

- (void)showProceduralBeatsMessage {
    // Only show message once
    static BOOL hasShownMessage = NO;
    if (hasShownMessage) return;
    hasShownMessage = YES;

    SKLabelNode *messageLabel = [SKLabelNode labelNodeWithFontNamed:@"HelveticaNeue-Bold"];
    messageLabel.text = @"Procedural Beat Mode Active";
    messageLabel.fontSize = 32;
    messageLabel.fontColor = MAGIC_GREEN;
    messageLabel.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame) - 100);
    messageLabel.zPosition = 100;
    messageLabel.name = @"proceduralBeatsMessage";

    SKLabelNode *detailLabel = [SKLabelNode labelNodeWithFontNamed:@"HelveticaNeue"];
    detailLabel.text = @"AI-generated beats based on 120 BPM baseline";
    detailLabel.fontSize = 20;
    detailLabel.fontColor = [SKColor colorWithWhite:0.7 alpha:1.0];
    detailLabel.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame) - 140);
    detailLabel.zPosition = 100;
    detailLabel.name = @"proceduralBeatsDetail";

    [self addChild:messageLabel];
    [self addChild:detailLabel];

    // Fade out and remove after 5 seconds
    [messageLabel runAction:[SKAction sequence:@[
        [SKAction waitForDuration:5.0],
        [SKAction fadeOutWithDuration:1.0],
        [SKAction removeFromParent]
    ]]];

    [detailLabel runAction:[SKAction sequence:@[
        [SKAction waitForDuration:5.0],
        [SKAction fadeOutWithDuration:1.0],
        [SKAction removeFromParent]
    ]]];
}

#pragma mark - Update Loop

- (void)update:(NSTimeInterval)currentTime {
    myTimeSinceLastFrame = currentTime - myLastTimeSample;
    myLastTimeSample = currentTime;
    self.myCurrentSceneTime = currentTime;

    if ((myTimeSinceLastFrame > tvScreenRefreshTimeToDump) && (myTimeSinceLastFrame < 10.0)) {
        [self runAction:[SKAction runBlock:^{
            [self->myDropPicturesTimer invalidate];
            [self enumerateChildNodesWithName:@"sprite" usingBlock:^(SKNode *node, BOOL *stop) {
                [node removeFromParent];
            }];
            [self enumerateChildNodesWithName:@"particle system" usingBlock:^(SKNode *node, BOOL *stop) {
                [node removeFromParent];
            }];
            [self setPhysicsBody:[SKPhysicsBody bodyWithEdgeLoopFromRect:self.frame]];
            [self myMakeMenuReminderLabel];
            [self myStartDropPicturesTimer];
        }]];
    }

    if (myResizeMethod > 0) {
        [self myResizeSpritesToMusic];
    }

    [self myUpdateAudioDisplay];

    // Update debug display if visible
    if (self.myDebugDisplayVisible) {
        [self myUpdateDebugDisplay];
    }
}

#pragma mark - Collision Detection

- (void)didEndContact:(SKPhysicsContact *)contact {
    if (myTimeSinceLastFrame > tvScreenRefreshTimeToHoldOffDroppingPictures) return;

    if (contact.bodyA.node.physicsBody.contactTestBitMask < contact.bodyB.node.physicsBody.contactTestBitMask) {
        firstNode = contact.bodyA.node;
        secondNode = contact.bodyB.node;
    } else {
        firstNode = contact.bodyB.node;
        secondNode = contact.bodyA.node;
    }

    // Photo-to-photo collision
    if ((firstNode.physicsBody.contactTestBitMask == 0x02) && (secondNode.physicsBody.contactTestBitMask == 0x02)) {
        CGPoint collisionPoint = contact.contactPoint;
        [self createMagicBurstAtPosition:collisionPoint];

        for (SKNode *theNode in @[firstNode, secondNode]) {
            NSInteger randomAction = [shuffledRandomSource nextInt];

            switch (randomAction) {
                case 1: {
                    // 2x2 segment breakup (only works on sprite nodes with textures)
                    if ([theNode isKindOfClass:[SKSpriteNode class]] && [(SKSpriteNode *)theNode texture]) {
                        [self createSegmentBreakup:(SKSpriteNode *)theNode];
                    } else {
                        [self createConfettiBurstAtPosition:theNode.position];
                    }
                    break;
                }
                case 2: {
                    // Particle explosion
                    SKEmitterNode *particleExplosion = [SKEmitterNode nodeWithFileNamed:@"myImpactParticle"];
                    if (particleExplosion) {
                        particleExplosion.position = theNode.position;
                        particleExplosion.zPosition = 40;
                        particleExplosion.name = @"particle system";
                        [self addChild:particleExplosion];
                        [particleExplosion runAction:[SKAction sequence:@[
                            [SKAction waitForDuration:2.0],
                            [SKAction fadeOutWithDuration:0.5],
                            [SKAction removeFromParent]
                        ]]];
                    }
                    break;
                }
                case 3: {
                    // Cloud particles
                    SKEmitterNode *cloudParticle = [SKEmitterNode nodeWithFileNamed:@"myCloudEmitter"];
                    if (cloudParticle) {
                        cloudParticle.position = theNode.position;
                        cloudParticle.zPosition = 40;
                        cloudParticle.name = @"particle system";
                        [self addChild:cloudParticle];
                        [cloudParticle runAction:[SKAction sequence:@[
                            [SKAction waitForDuration:3.0],
                            [SKAction fadeOutWithDuration:0.5],
                            [SKAction removeFromParent]
                        ]]];
                    }
                    break;
                }
                case 4: {
                    // Triangle decomposition
                    [self createTriangleDecomposition:theNode.position];
                    break;
                }
                case 5: {
                    // Circle spawning
                    [self createCircleSpawn:theNode.position];
                    break;
                }
                case 6: {
                    // Random squares
                    [self createRandomSquares:theNode.position count:15];
                    break;
                }
                case 7: {
                    // Random quads
                    [self createRandomSquares:theNode.position count:5];
                    break;
                }
                default: {
                    // Confetti burst
                    [self createConfettiBurstAtPosition:theNode.position];
                    break;
                }
            }
        }
    }
}

#pragma mark - Collision Effects

- (void)createSegmentBreakup:(SKSpriteNode *)spriteNode {
    CGSize halfSize = CGSizeMake(spriteNode.size.width / 2, spriteNode.size.height / 2);

    for (int row = 0; row < 2; row++) {
        for (int col = 0; col < 2; col++) {
            SKSpriteNode *segment = [SKSpriteNode spriteNodeWithTexture:spriteNode.texture size:halfSize];
            segment.position = CGPointMake(
                spriteNode.position.x + (col - 0.5) * halfSize.width,
                spriteNode.position.y + (row - 0.5) * halfSize.height
            );
            segment.name = @"sprite";
            segment.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:halfSize];
            segment.physicsBody.restitution = 0.8;
            segment.physicsBody.contactTestBitMask = 0;
            segment.physicsBody.linearDamping = 0.1;

            CGFloat impulseX = (col == 0 ? -1 : 1) * (0.5 + (arc4random() % 50) / 100.0);
            CGFloat impulseY = (row == 0 ? -1 : 1) * (0.5 + (arc4random() % 50) / 100.0);
            [segment.physicsBody applyImpulse:CGVectorMake(impulseX, impulseY)];

            [self addChild:segment];

            [segment runAction:[SKAction sequence:@[
                [SKAction waitForDuration:3.0 + (arc4random() % 200) / 100.0],
                [SKAction fadeOutWithDuration:0.5],
                [SKAction removeFromParent]
            ]]];
        }
    }
}

- (void)createTriangleDecomposition:(CGPoint)position {
    for (int i = 0; i < 4; i++) {
        CGFloat triangleSize = 30 + arc4random() % 40;
        UIBezierPath *trianglePath = [UIBezierPath bezierPath];
        [trianglePath moveToPoint:CGPointMake(0, triangleSize)];
        [trianglePath addLineToPoint:CGPointMake(-triangleSize / 2, 0)];
        [trianglePath addLineToPoint:CGPointMake(triangleSize / 2, 0)];
        [trianglePath closePath];

        myCustomShapeNode *triangle = [myCustomShapeNode shapeNodeWithPath:trianglePath.CGPath];
        triangle.fillColor = [self randomMagicColor];
        triangle.strokeColor = [SKColor clearColor];
        triangle.glowWidth = 3.0;
        triangle.position = position;
        triangle.zPosition = 30;
        triangle.name = @"sprite";

        triangle.physicsBody = [SKPhysicsBody bodyWithPolygonFromPath:trianglePath.CGPath];
        triangle.physicsBody.restitution = 0.9;
        triangle.physicsBody.contactTestBitMask = 0;
        triangle.physicsBody.mass = 0.02;

        CGFloat impulseAngle = (arc4random() % 360) * M_PI / 180.0;
        [triangle.physicsBody applyImpulse:CGVectorMake(cos(impulseAngle) * 0.5, sin(impulseAngle) * 0.5 + 0.3)];

        [self addChild:triangle];

        [triangle runAction:[SKAction sequence:@[
            [SKAction waitForDuration:4.0],
            [SKAction fadeOutWithDuration:0.5],
            [SKAction removeFromParent]
        ]]];
    }
}

- (void)createCircleSpawn:(CGPoint)position {
    for (int i = 0; i < 6; i++) {
        CGFloat radius = 10 + arc4random() % 20;
        myCustomShapeNode *circle = [myCustomShapeNode shapeNodeWithCircleOfRadius:radius];
        circle.fillColor = [self randomMagicColor];
        circle.strokeColor = [SKColor clearColor];
        circle.glowWidth = 4.0;
        circle.position = position;
        circle.zPosition = 30;
        circle.name = @"sprite";

        circle.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:radius];
        circle.physicsBody.restitution = 1.0;
        circle.physicsBody.contactTestBitMask = 0;
        circle.physicsBody.mass = 0.01;

        CGFloat impulseAngle = (i * 60) * M_PI / 180.0;
        [circle.physicsBody applyImpulse:CGVectorMake(cos(impulseAngle) * 0.3, sin(impulseAngle) * 0.3 + 0.2)];

        [self addChild:circle];

        [circle runAction:[SKAction sequence:@[
            [SKAction waitForDuration:5.0],
            [SKAction fadeOutWithDuration:0.5],
            [SKAction removeFromParent]
        ]]];
    }
}

- (void)createRandomSquares:(CGPoint)position count:(int)squareCount {
    for (int i = 0; i < squareCount; i++) {
        CGFloat squareSize = 8 + arc4random() % 20;
        SKSpriteNode *square = [SKSpriteNode spriteNodeWithColor:[self randomMagicColor] size:CGSizeMake(squareSize, squareSize)];
        square.position = position;
        square.zPosition = 30;
        square.name = @"sprite";

        square.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:square.size];
        square.physicsBody.restitution = 0.8;
        square.physicsBody.contactTestBitMask = 0;
        square.physicsBody.mass = 0.005;

        CGFloat impulseAngle = (arc4random() % 360) * M_PI / 180.0;
        CGFloat impulseStrength = 0.1 + (arc4random() % 50) / 100.0;
        [square.physicsBody applyImpulse:CGVectorMake(cos(impulseAngle) * impulseStrength, sin(impulseAngle) * impulseStrength + 0.2)];

        [self addChild:square];

        [square runAction:[SKAction sequence:@[
            [SKAction waitForDuration:3.0 + (arc4random() % 300) / 100.0],
            [SKAction fadeOutWithDuration:0.5],
            [SKAction removeFromParent]
        ]]];
    }
}

#pragma mark - Visual Effects

- (SKColor *)randomMagicColor {
    NSArray *colors = @[MAGIC_PINK, MAGIC_CYAN, MAGIC_PURPLE, MAGIC_GOLD, MAGIC_GREEN];
    return colors[arc4random() % colors.count];
}

- (void)createSparkleEffectAtPosition:(CGPoint)position withColor:(SKColor *)color {
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

- (void)createMagicBurstAtPosition:(CGPoint)position {
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

- (void)createConfettiBurstAtPosition:(CGPoint)position {
    for (int i = 0; i < 20; i++) {
        CGSize confettiSize = CGSizeMake(4 + arc4random() % 6, 8 + arc4random() % 10);
        SKSpriteNode *confetti = [SKSpriteNode spriteNodeWithColor:[self randomMagicColor] size:confettiSize];
        confetti.position = position;
        confetti.zPosition = 98;
        confetti.zRotation = (arc4random() % 360) * M_PI / 180.0;

        confetti.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:confettiSize];
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

- (void)celebrationEffect {
    CGPoint center = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));

    for (int i = 0; i < 5; i++) {
        CGFloat delay = i * 0.15;
        CGFloat offsetX = (arc4random() % 200) - 100;
        CGFloat offsetY = (arc4random() % 200) - 100;
        CGPoint burstPosition = CGPointMake(center.x + offsetX, center.y + offsetY);

        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self createConfettiBurstAtPosition:burstPosition];
            [self createMagicBurstAtPosition:burstPosition];
        });
    }
}

- (void)addGlowToSprite:(SKSpriteNode *)sprite withColor:(SKColor *)color {
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

- (UIImage *)createGlowParticleImage {
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

- (void)createRainbowTrailForSprite:(SKSpriteNode *)sprite {
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

#pragma mark - Audio Display

- (void)mySetupAudioDisplay {
    SKNode *existingDisplay = [self childNodeWithName:@"audioDisplayContainer"];
    if (existingDisplay) {
        [existingDisplay removeFromParent];
    }

    myAudioDisplayNode = [SKNode node];
    myAudioDisplayNode.name = @"audioDisplayContainer";
    myAudioDisplayNode.zPosition = 50;
    myAudioDisplayNode.position = CGPointMake(CGRectGetMidX(self.frame), self.frame.size.height - 80);
    [self addChild:myAudioDisplayNode];

    // Background pill
    CGFloat pillWidth = MIN(self.frame.size.width - 100, 500);
    CGFloat pillHeight = 70;
    SKShapeNode *backgroundPill = [SKShapeNode shapeNodeWithRectOfSize:CGSizeMake(pillWidth, pillHeight) cornerRadius:pillHeight / 2];
    backgroundPill.fillColor = [SKColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.6];
    backgroundPill.strokeColor = [SKColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.2];
    backgroundPill.lineWidth = 1.5;
    backgroundPill.name = @"audioDisplayBG";
    [myAudioDisplayNode addChild:backgroundPill];

    // Inner glow
    SKShapeNode *innerGlow = [SKShapeNode shapeNodeWithRectOfSize:CGSizeMake(pillWidth - 4, pillHeight - 4) cornerRadius:(pillHeight - 4) / 2];
    innerGlow.fillColor = [SKColor clearColor];
    innerGlow.strokeColor = [SKColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.1];
    innerGlow.lineWidth = 1;
    [myAudioDisplayNode addChild:innerGlow];

    // NOW PLAYING label
    SKLabelNode *nowPlayingLabel = [SKLabelNode labelNodeWithFontNamed:@"HelveticaNeue-Bold"];
    nowPlayingLabel.text = @"NOW PLAYING";
    nowPlayingLabel.fontSize = 16;
    nowPlayingLabel.fontColor = [SKColor colorWithWhite:0.5 alpha:1.0];
    nowPlayingLabel.position = CGPointMake(0, 12);
    [myAudioDisplayNode addChild:nowPlayingLabel];

    // Song title
    NSString *displayTitle = mySongTitle ? mySongTitle : @"Caution";
    NSString *displayArtist = mySongArtist ? mySongArtist : @"Skrxlla";
    NSString *songText = [NSString stringWithFormat:@"%@ - %@", displayTitle, displayArtist];

    SKLabelNode *songLabel = [SKLabelNode labelNodeWithFontNamed:@"HelveticaNeue-Medium"];
    songLabel.text = songText;
    songLabel.fontSize = 24;
    songLabel.fontColor = MAGIC_CYAN;
    songLabel.position = CGPointMake(0, -12);
    [myAudioDisplayNode addChild:songLabel];

    // Music bars
    for (int i = 0; i < 4; i++) {
        SKShapeNode *bar = [SKShapeNode shapeNodeWithRectOfSize:CGSizeMake(4, 16)];
        bar.fillColor = MAGIC_CYAN;
        bar.strokeColor = [SKColor clearColor];
        bar.position = CGPointMake(-pillWidth / 2 + 25 + i * 8, 0);
        bar.name = [NSString stringWithFormat:@"musicBar%d", i];
        [myAudioDisplayNode addChild:bar];

        // Animate bars
        CGFloat randomDuration = 0.3 + (arc4random() % 30) / 100.0;
        [bar runAction:[SKAction repeatActionForever:[SKAction sequence:@[
            [SKAction scaleYTo:0.5 + (arc4random() % 100) / 100.0 duration:randomDuration],
            [SKAction scaleYTo:0.3 duration:randomDuration]
        ]]]];
    }

    // VU meter
    CGFloat vuMeterWidth = pillWidth - 60;
    CGFloat vuMeterHeight = 5;
    CGFloat vuMeterY = -pillHeight / 2 - 16;

    SKShapeNode *vuMeterBG = [SKShapeNode shapeNodeWithRectOfSize:CGSizeMake(vuMeterWidth, vuMeterHeight) cornerRadius:vuMeterHeight / 2];
    vuMeterBG.fillColor = [SKColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:0.8];
    vuMeterBG.strokeColor = [SKColor clearColor];
    vuMeterBG.position = CGPointMake(0, vuMeterY);
    vuMeterBG.name = @"vuMeterBG";
    [myAudioDisplayNode addChild:vuMeterBG];

    // VU meter fill container
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

    // Entrance animation
    myAudioDisplayNode.alpha = 0;
    [myAudioDisplayNode setScale:0.8];
    [myAudioDisplayNode runAction:[SKAction group:@[
        [SKAction fadeInWithDuration:0.5],
        [SKAction scaleTo:1.0 duration:0.5]
    ]]];
}

- (void)myUpdateAudioDisplay {
    if (!myAudioDisplayNode) return;

    BOOL isAudioActive = myUsingAppleMusic
        ? (mySystemMusicPlayer.playbackState == MPMusicPlaybackStatePlaying)
        : (myAudioPlayer && myAudioPlayer.isPlaying);

    CGFloat vuMeterWidth = MIN(self.frame.size.width - 100, 500) - 60;
    CGFloat amplitudeLevel = isAudioActive ? [self myDbToAmp:myInstantPower] : 0.0;
    CGFloat normalizedLevel = MIN(amplitudeLevel, 1.0);

    static CGFloat smoothedLevel = 0;
    if (isAudioActive) {
        smoothedLevel = smoothedLevel * 0.6 + normalizedLevel * 0.4;
    } else {
        smoothedLevel = smoothedLevel * 0.85;
        if (smoothedLevel < 0.01) smoothedLevel = 0;
    }

    // Update VU meter
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

    // Animate music bars based on audio level
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

#pragma mark - Debug Display

- (void)mySetupDebugDisplay {
    // Remove existing debug display if present
    SKNode *existingDebugDisplay = [self childNodeWithName:@"debugDisplayContainer"];
    if (existingDebugDisplay) {
        [existingDebugDisplay removeFromParent];
    }

    // Create container node for all debug display elements
    self.myDebugDisplayNode = [SKNode node];
    self.myDebugDisplayNode.name = @"debugDisplayContainer";
    self.myDebugDisplayNode.zPosition = 51;
    self.myDebugDisplayNode.position = CGPointMake(self.frame.size.width / 2 - 200, self.frame.size.height / 2 - 100);
    [self addChild:self.myDebugDisplayNode];

    // Create background pill shape
    CGFloat pillWidth = 400;
    CGFloat pillHeight = 200;
    SKShapeNode *backgroundPill = [SKShapeNode shapeNodeWithRectOfSize:CGSizeMake(pillWidth, pillHeight) cornerRadius:12];
    backgroundPill.fillColor = [SKColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.8];
    backgroundPill.strokeColor = [SKColor colorWithRed:1.0 green:0.4 blue:0.6 alpha:0.4];
    backgroundPill.lineWidth = 2.0;
    backgroundPill.name = @"debugDisplayBG";
    [self.myDebugDisplayNode addChild:backgroundPill];

    // Create header label
    SKLabelNode *headerLabel = [SKLabelNode labelNodeWithFontNamed:@"Courier-Bold"];
    headerLabel.text = @"DEBUG (tvOS)";
    headerLabel.fontSize = 18;
    headerLabel.fontColor = MAGIC_PINK;
    headerLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeLeft;
    headerLabel.verticalAlignmentMode = SKLabelVerticalAlignmentModeTop;
    headerLabel.position = CGPointMake(-pillWidth/2 + 20, pillHeight/2 - 20);
    headerLabel.name = @"debugHeader";
    [self.myDebugDisplayNode addChild:headerLabel];

    // Create labels for each debug value
    NSArray *labelNames = @[@"debugMode", @"debugInstantPwr", @"debugPwrDiff", @"debugScaleTo", @"debugFinal"];
    CGFloat yOffset = -35;
    for (int i = 0; i < labelNames.count; i++) {
        SKLabelNode *label = [SKLabelNode labelNodeWithFontNamed:@"Courier-Bold"];
        label.text = @"---";
        label.fontSize = 15;
        label.fontColor = [SKColor whiteColor];
        label.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeLeft;
        label.verticalAlignmentMode = SKLabelVerticalAlignmentModeTop;
        label.position = CGPointMake(-pillWidth/2 + 20, pillHeight/2 + yOffset);
        label.name = labelNames[i];
        [self.myDebugDisplayNode addChild:label];
        yOffset -= 32;
    }

    // Entrance animation
    self.myDebugDisplayNode.alpha = 0;
    [self.myDebugDisplayNode runAction:[SKAction fadeInWithDuration:0.3]];
}

- (void)myUpdateDebugDisplay {
    if (!self.myDebugDisplayNode || !self.myDebugDisplayVisible) return;

    // Update Mode label
    SKLabelNode *modeLabel = (SKLabelNode *)[self.myDebugDisplayNode childNodeWithName:@"debugMode"];
    if (modeLabel) {
        modeLabel.text = [NSString stringWithFormat:@"Mode: %d", myResizeMethod];
    }

    // Update InstantPower label
    SKLabelNode *powerLabel = (SKLabelNode *)[self.myDebugDisplayNode childNodeWithName:@"debugInstantPwr"];
    if (powerLabel) {
        powerLabel.text = [NSString stringWithFormat:@"InstantPwr: %.2f dB", myInstantPower];
    }

    // Update PowerDifference label
    SKLabelNode *diffLabel = (SKLabelNode *)[self.myDebugDisplayNode childNodeWithName:@"debugPwrDiff"];
    if (diffLabel) {
        diffLabel.text = [NSString stringWithFormat:@"PwrDiff: %.2f dB", powerDifference];
    }

    // Update ScaleTo label
    SKLabelNode *scaleLabel = (SKLabelNode *)[self.myDebugDisplayNode childNodeWithName:@"debugScaleTo"];
    if (scaleLabel) {
        scaleLabel.text = [NSString stringWithFormat:@"ScaleTo: %.2f", self.myCurrentScaleTo];
        // Color code: red for high values
        if (self.myCurrentScaleTo > 2.0) {
            scaleLabel.fontColor = MAGIC_PINK;
        } else if (self.myCurrentScaleTo > 1.5) {
            scaleLabel.fontColor = MAGIC_GOLD;
        } else {
            scaleLabel.fontColor = MAGIC_GREEN;
        }
    }

    // Update Final scale label
    SKLabelNode *finalLabel = (SKLabelNode *)[self.myDebugDisplayNode childNodeWithName:@"debugFinal"];
    if (finalLabel) {
        float finalScale = self.myCurrentScaleTo * tvPhotoScaleMultiplier;
        finalLabel.text = [NSString stringWithFormat:@"Final: %.2fx", finalScale];
        if (finalScale > 3.0) {
            finalLabel.fontColor = MAGIC_PINK;
        } else if (finalScale > 2.0) {
            finalLabel.fontColor = MAGIC_GOLD;
        } else {
            finalLabel.fontColor = MAGIC_GREEN;
        }
    }
}

- (void)myToggleDebugDisplay {
    if (self.myDebugDisplayVisible) {
        // Hide debug display
        self.myDebugDisplayVisible = NO;
        if (self.myDebugDisplayNode) {
            [self.myDebugDisplayNode runAction:[SKAction sequence:@[
                [SKAction fadeOutWithDuration:0.2],
                [SKAction runBlock:^{
                    [self.myDebugDisplayNode removeFromParent];
                    self.myDebugDisplayNode = nil;
                }]
            ]]];
        }
    } else {
        // Show debug display
        self.myDebugDisplayVisible = YES;
        [self mySetupDebugDisplay];
    }
}

#pragma mark - Quit

- (void)mySendQuitNotification {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"quitnotifictaion" object:nil];
}

#pragma mark - Image Assignment

- (void)myAssignImage1 { [self assignRandomPhotoToSlot:1]; }
- (void)myAssignImage2 { [self assignRandomPhotoToSlot:2]; }
- (void)myAssignImage3 { [self assignRandomPhotoToSlot:3]; }
- (void)myAssignImage4 { [self assignRandomPhotoToSlot:4]; }
- (void)myAssignImage5 { [self assignRandomPhotoToSlot:5]; }

- (void)myDoAssignImage1 { [self myAssignImage1]; }
- (void)myDoAssignImage2 { [self myAssignImage2]; }
- (void)myDoAssignImage3 { [self myAssignImage3]; }
- (void)myDoAssignImage4 { [self myAssignImage4]; }
- (void)myDoAssignImage5 { [self myAssignImage5]; }

#pragma mark - PHPhotoLibraryChangeObserver

- (void)photoLibraryDidChange:(PHChange *)changeInstance {
    dispatch_async(dispatch_get_main_queue(), ^{
        PHFetchOptions *fetchOptions = [[PHFetchOptions alloc] init];
        [fetchOptions setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:YES]]];
        self.myPhotos = [PHAsset fetchAssetsWithOptions:fetchOptions];
    });
}

@end
