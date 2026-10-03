//
//  TVSetupViewController.m
//  PhotoDancePartyTV
//
//  Created by Robert Zimmelman.
//  Copyright © 2024 Robert Zimmelman. All rights reserved.
//

#import "TVSetupViewController.h"
#import "TVGameScene.h"
#import "PhotoDancePartyTV-Swift.h"

@implementation SKScene (Unarchive)

+ (instancetype)unarchiveFromFile:(NSString *)file {
    NSString *nodePath = [[NSBundle mainBundle] pathForResource:file ofType:@"sks"];
    if (!nodePath) return nil;
    NSData *data = [NSData dataWithContentsOfFile:nodePath options:NSDataReadingMappedIfSafe error:nil];
    if (!data) return nil;
    NSError *archiveError = nil;
    NSKeyedUnarchiver *archiver = [[NSKeyedUnarchiver alloc] initForReadingFromData:data error:&archiveError];
    if (archiveError) {
        NSLog(@"Error unarchiving: %@", archiveError);
        return nil;
    }
    [archiver setClass:self forClassName:@"SKScene"];
    SKScene *scene = [archiver decodeObjectForKey:NSKeyedArchiveRootObjectKey];
    [archiver finishDecoding];
    return scene;
}

@end

#define MAGIC_PINK [UIColor colorWithRed:1.0 green:0.4 blue:0.6 alpha:1.0]
#define MAGIC_CYAN [UIColor colorWithRed:0.2 green:0.8 blue:1.0 alpha:1.0]
#define MAGIC_PURPLE [UIColor colorWithRed:0.6 green:0.3 blue:1.0 alpha:1.0]
#define MAGIC_GOLD [UIColor colorWithRed:1.0 green:0.85 blue:0.3 alpha:1.0]

@implementation TVSetupViewController {
    TVGameScene *activeGameScene;
    SKView *activeGameView;
    CAGradientLayer *backgroundGradientLayer;
    NSTimer *gradientAnimationTimer;
    CGFloat gradientHueValue;
}

@synthesize myImage1, myImage2, myImage3, myImage4, myImage5;
@synthesize myMusicLabel;
@synthesize myPlayButton, myRandomButton, mySelectPhotosButton, mySelectMusicButton;
@synthesize myPhotos, myImageManager;
@synthesize myMusicURL, myMusicStoreID, mySongTitle, mySongArtist;

#pragma mark - View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];

    [self setupGradientBackground];
    [self loadDefaultBundledPhotos];
    [self setupPhotoLibrary];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleQuitNotification)
                                                 name:@"quitnotifictaion"
                                               object:nil];

    [self styleImageViews];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [gradientAnimationTimer invalidate];
    [[PHPhotoLibrary sharedPhotoLibrary] unregisterChangeObserver:self];
}

#pragma mark - Gradient Background

- (UIColor *)colorFromHue:(CGFloat)hue saturation:(CGFloat)saturation brightness:(CGFloat)brightness alpha:(CGFloat)alpha {
    return [UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:alpha];
}

- (void)setupGradientBackground {
    backgroundGradientLayer = [CAGradientLayer layer];
    backgroundGradientLayer.frame = self.view.bounds;
    backgroundGradientLayer.colors = @[
        (id)[UIColor colorWithRed:0.05 green:0.0 blue:0.15 alpha:1.0].CGColor,
        (id)[UIColor colorWithRed:0.15 green:0.05 blue:0.3 alpha:1.0].CGColor,
        (id)[UIColor colorWithRed:0.1 green:0.0 blue:0.25 alpha:1.0].CGColor,
        (id)[UIColor colorWithRed:0.0 green:0.05 blue:0.2 alpha:1.0].CGColor
    ];
    backgroundGradientLayer.locations = @[@0.0, @0.35, @0.7, @1.0];
    backgroundGradientLayer.startPoint = CGPointMake(0, 0);
    backgroundGradientLayer.endPoint = CGPointMake(1, 1);
    [self.view.layer insertSublayer:backgroundGradientLayer atIndex:0];

    gradientHueValue = 0.0;
    gradientAnimationTimer = [NSTimer scheduledTimerWithTimeInterval:0.05
                                                             target:self
                                                           selector:@selector(animateGradient)
                                                           userInfo:nil
                                                            repeats:YES];
}

- (void)animateGradient {
    gradientHueValue += 0.002;
    if (gradientHueValue > 1.0) gradientHueValue = 0.0;

    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    backgroundGradientLayer.colors = @[
        (id)[self colorFromHue:gradientHueValue saturation:0.8 brightness:0.15 alpha:1.0].CGColor,
        (id)[self colorFromHue:fmod(gradientHueValue + 0.1, 1.0) saturation:0.7 brightness:0.25 alpha:1.0].CGColor,
        (id)[self colorFromHue:fmod(gradientHueValue + 0.2, 1.0) saturation:0.75 brightness:0.2 alpha:1.0].CGColor,
        (id)[self colorFromHue:fmod(gradientHueValue + 0.3, 1.0) saturation:0.8 brightness:0.1 alpha:1.0].CGColor
    ];
    [CATransaction commit];
}

#pragma mark - Default Photos

- (void)loadDefaultBundledPhotos {
    NSArray *defaultPhotoNames = @[@"DefaultPhoto1", @"DefaultPhoto2", @"DefaultPhoto3", @"DefaultPhoto4", @"DefaultPhoto5"];
    NSArray *imageViews = @[myImage1, myImage2, myImage3, myImage4, myImage5];

    for (int i = 0; i < 5; i++) {
        NSString *path = [[NSBundle mainBundle] pathForResource:defaultPhotoNames[i] ofType:@"jpg"];
        UIImage *defaultImage = path ? [UIImage imageWithContentsOfFile:path] : nil;
        if (defaultImage && imageViews[i]) {
            [(UIImageView *)imageViews[i] setImage:defaultImage];
        }
    }
}

#pragma mark - Photo Library

- (void)setupPhotoLibrary {
    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
        if (status == PHAuthorizationStatusAuthorized) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self fetchPhotos];
            });
        }
    }];
    [[PHPhotoLibrary sharedPhotoLibrary] registerChangeObserver:self];
}

- (void)fetchPhotos {
    PHFetchOptions *fetchOptions = [[PHFetchOptions alloc] init];
    [fetchOptions setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:YES]]];
    myPhotos = [PHAsset fetchAssetsWithOptions:fetchOptions];
    myImageManager = [[PHImageManager alloc] init];
}

- (void)photoLibraryDidChange:(PHChange *)changeInstance {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self fetchPhotos];
    });
}

#pragma mark - Style

- (void)styleImageViews {
    NSArray *imageViews = @[myImage1, myImage2, myImage3, myImage4, myImage5];
    for (UIImageView *imageView in imageViews) {
        if (imageView) {
            imageView.layer.cornerRadius = 20;
            imageView.layer.masksToBounds = YES;
            imageView.contentMode = UIViewContentModeScaleAspectFill;
            imageView.layer.borderWidth = 3;
            imageView.layer.borderColor = [UIColor colorWithWhite:1.0 alpha:0.25].CGColor;
        }
    }

    // Round corners on main buttons
    NSArray *mainButtons = @[myPlayButton, myRandomButton, mySelectPhotosButton, mySelectMusicButton];
    for (UIButton *button in mainButtons) {
        if (button) {
            button.layer.cornerRadius = 36;
            button.clipsToBounds = YES;
        }
    }

    // Round corners on remaining buttons (Help, etc.) with smaller radius
    for (UIView *subview in self.view.subviews) {
        if ([subview isKindOfClass:[UIButton class]] && ![mainButtons containsObject:subview]) {
            subview.layer.cornerRadius = 16;
            subview.clipsToBounds = YES;
        }
    }
}

#pragma mark - IBActions

- (IBAction)playWithDefaultPhotos:(id)sender {
    [self launchGameWithRandomImages:NO];
}

- (IBAction)playWithRandomPhotos:(id)sender {
    [self launchGameWithRandomImages:YES];
}

- (IBAction)selectFromPhotoLibrary:(id)sender {
    TVPhotoPickerViewController *photoPicker = [[TVPhotoPickerViewController alloc] init];
    photoPicker.delegate = self;
    photoPicker.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:photoPicker animated:YES completion:nil];
}

- (IBAction)selectMusic:(id)sender {
    TVMusicPickerViewController *musicPicker = [[TVMusicPickerViewController alloc] init];
    musicPicker.delegate = self;
    musicPicker.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:musicPicker animated:YES completion:nil];
}

- (IBAction)showHelp:(id)sender {
    UIAlertController *helpAlert = [UIAlertController alertControllerWithTitle:@"Photo Dance Party!"
                                                                      message:@"Select up to 5 photos and a song, then press Play to watch your photos dance to the music!\n\nUse the Siri Remote:\n- Press Play/Pause to toggle music\n- Press Menu for options\n\nResize Modes:\n- Pulse: Photos pulse with the beat\n- Instant: Photos size matches volume\n- None: No music reactivity"
                                                               preferredStyle:UIAlertControllerStyleAlert];
    [helpAlert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:helpAlert animated:YES completion:nil];
}

#pragma mark - Game Launch

- (void)launchGameWithRandomImages:(BOOL)randomImagesFlag {
    SKView *gameView = [[SKView alloc] initWithFrame:self.view.bounds];
    [gameView setAutoresizingMask:(UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight)];
    gameView.ignoresSiblingOrder = YES;

    TVGameScene *gameScene = [TVGameScene unarchiveFromFile:@"GameScene"];
    if (!gameScene) {
        gameScene = [[TVGameScene alloc] initWithSize:self.view.bounds.size];
    }
    [gameScene setSize:self.view.bounds.size];
    gameScene.scaleMode = SKSceneScaleModeAspectFill;

    // Set resize method to music pulse
    [gameScene setMyResizeMethod:2];

    // Pass music URL/store ID and info
    [gameScene setMyMusicURL:myMusicURL];
    [gameScene setMyMusicStoreID:myMusicStoreID];
    [gameScene setMySongTitle:mySongTitle ? mySongTitle : @"Caution"];
    [gameScene setMySongArtist:mySongArtist ? mySongArtist : @"Skrxlla"];
    [gameScene setMyIsUserLibrarySong:self.myIsUserLibrarySong];

    // Pass images
    [gameScene setMySpriteImage1:myImage1.image];
    [gameScene setMySpriteImage2:myImage2.image];
    [gameScene setMySpriteImage3:myImage3.image];
    [gameScene setMySpriteImage4:myImage4.image];
    [gameScene setMySpriteImage5:myImage5.image];

    // Set image flags (all enabled)
    gameScene.myImage1Flag = 1;
    gameScene.myImage2Flag = 1;
    gameScene.myImage3Flag = 1;
    gameScene.myImage4Flag = 1;
    gameScene.myImage5Flag = 1;

    // Build pictures array
    NSMutableArray *picturesArray = [[NSMutableArray alloc] init];
    [picturesArray addObject:[NSNumber numberWithInt:1]];
    [picturesArray addObject:[NSNumber numberWithInt:2]];
    [picturesArray addObject:[NSNumber numberWithInt:3]];
    [picturesArray addObject:[NSNumber numberWithInt:4]];
    [picturesArray addObject:[NSNumber numberWithInt:5]];
    gameScene.myPicturesArray = picturesArray;

    // Random images mode
    [gameScene setMyAllRandomImagesFlag:randomImagesFlag];

    // Remove existing subviews and add game view
    for (UIView *subview in self.view.subviews) {
        subview.hidden = YES;
    }
    [self.view addSubview:gameView];

    // Present scene
    [gameView presentScene:gameScene];

    // Store references
    activeGameView = gameView;
    activeGameScene = gameScene;

    // Start the game
    [gameScene myStartTheGame];
}

- (void)handleQuitNotification {
    [self showQuitAlertController];
}

#pragma mark - In-Game Menu

- (void)showQuitAlertController {
    UIAlertController *menuAlert = [UIAlertController alertControllerWithTitle:@"Photo Dance Party!"
                                                                      message:nil
                                                               preferredStyle:UIAlertControllerStyleActionSheet];
    [menuAlert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];

    [menuAlert addAction:[UIAlertAction actionWithTitle:@"Quit" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
        [self->activeGameScene.myAudioPlayer stop];
        [self->activeGameScene.mySystemMusicPlayer stop];
        [MusicLibraryHelper stopPlayback];
        [self->activeGameScene.myDropPicturesTimer invalidate];
        [self->activeGameView removeFromSuperview];
        self->activeGameScene = nil;
        self->activeGameView = nil;

        // Show all setup subviews again
        for (UIView *subview in self.view.subviews) {
            subview.hidden = NO;
        }
    }]];

    [menuAlert addAction:[UIAlertAction actionWithTitle:@"Resume" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self->activeGameScene.myDropPicturesTimer invalidate];
        [self->activeGameScene myStartDropPicturesTimer];
    }]];

    [menuAlert addAction:[UIAlertAction actionWithTitle:@"Change Photos" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self->activeGameScene myAssignImage1];
        [self->activeGameScene myAssignImage2];
        [self->activeGameScene myAssignImage3];
        [self->activeGameScene myAssignImage4];
        [self->activeGameScene myAssignImage5];
    }]];

    [menuAlert addAction:[UIAlertAction actionWithTitle:@"All Random Photos" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self->activeGameScene setMyAllRandomImagesFlag:YES];
    }]];

    [menuAlert addAction:[UIAlertAction actionWithTitle:@"Play / Pause" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self->activeGameScene myPlayPause];
    }]];

    [menuAlert addAction:[UIAlertAction actionWithTitle:@"Restart Music" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self->activeGameScene myRestartTheMusic];
    }]];

    [menuAlert addAction:[UIAlertAction actionWithTitle:@"Select Music" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        TVMusicPickerViewController *musicPicker = [[TVMusicPickerViewController alloc] init];
        musicPicker.delegate = self;
        musicPicker.modalPresentationStyle = UIModalPresentationFullScreen;
        [self presentViewController:musicPicker animated:YES completion:nil];
    }]];

    [menuAlert addAction:[UIAlertAction actionWithTitle:@"Pulse Resize" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self->activeGameScene setMyResizeMethod:2];
        [self->activeGameScene mySetupAudioDisplay];
    }]];

    [menuAlert addAction:[UIAlertAction actionWithTitle:@"Instant Resize" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self->activeGameScene setMyResizeMethod:1];
        [self->activeGameScene mySetupAudioDisplay];
    }]];

    [menuAlert addAction:[UIAlertAction actionWithTitle:@"No Resize" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self->activeGameScene setMyResizeMethod:0];
    }]];



    [self presentViewController:menuAlert animated:YES completion:nil];
}

#pragma mark - TVPhotoPickerDelegate

- (void)photoPickerDidSelectPhotos:(NSArray<UIImage *> *)photos {
    NSArray *imageViews = @[myImage1, myImage2, myImage3, myImage4, myImage5];
    for (int i = 0; i < photos.count && i < 5; i++) {
        [(UIImageView *)imageViews[i] setImage:photos[i]];
    }
}

- (void)photoPickerDidCancel {
    // Nothing to do
}

#pragma mark - TVMusicPickerDelegate

- (void)musicPickerDidSelectSongWithURL:(NSURL *)url storeID:(NSString *)storeID title:(NSString *)title artist:(NSString *)artist isUserLibrary:(BOOL)isUserLibrary {
    myMusicURL = url;
    myMusicStoreID = storeID;
    mySongTitle = title;
    mySongArtist = artist;
    self.myIsUserLibrarySong = isUserLibrary;

    NSString *sourceLabel = @"";
    if (isUserLibrary) {
        sourceLabel = @"My Library: ";
    } else if (storeID) {
        sourceLabel = @"Apple Music: ";
    } else if (url) {
        sourceLabel = @"Preview: ";
    } else {
        sourceLabel = @"Bundled Music: ";
    }

    if (title && artist) {
        myMusicLabel.text = [NSString stringWithFormat:@"%@%@ - %@", sourceLabel, title, artist];
    } else if (title) {
        myMusicLabel.text = [NSString stringWithFormat:@"%@%@", sourceLabel, title];
    }

    // If a game is running, stop all music sources and start the new selection
    if (activeGameScene) {
        [activeGameScene.myAudioPlayer stop];
        [activeGameScene.mySystemMusicPlayer stop];
        [MusicLibraryHelper stopPlayback];
        activeGameScene.myMusicURL = url;
        activeGameScene.myMusicStoreID = storeID;
        activeGameScene.mySongTitle = title;
        activeGameScene.mySongArtist = artist;
        activeGameScene.myIsUserLibrarySong = isUserLibrary;
        [activeGameScene myStartTheMusic];
    }
}

- (void)musicPickerDidCancel {
    // Nothing to do
}

#pragma mark - Siri Remote Press Handling

- (void)pressesBegan:(NSSet<UIPress *> *)presses withEvent:(UIPressesEvent *)event {
    if (activeGameScene) {
        for (UIPress *press in presses) {
            if (press.type == UIPressTypeMenu) {
                [self showQuitAlertController];
                return;
            } else if (press.type == UIPressTypePlayPause) {
                [activeGameScene myPlayPause];
                return;
            }
        }
    }
    [super pressesBegan:presses withEvent:event];
}

#pragma mark - Focus Engine

- (void)didUpdateFocusInContext:(UIFocusUpdateContext *)context withAnimationCoordinator:(UIFocusAnimationCoordinator *)coordinator {
    // Unfocus previous button
    if ([context.previouslyFocusedView isKindOfClass:[UIButton class]]) {
        UIButton *prevButton = (UIButton *)context.previouslyFocusedView;
        [coordinator addCoordinatedAnimations:^{
            prevButton.transform = CGAffineTransformIdentity;
            prevButton.layer.shadowOpacity = 0;
            prevButton.layer.borderWidth = 0;
        } completion:nil];
    }

    // Focus new button
    if ([context.nextFocusedView isKindOfClass:[UIButton class]]) {
        UIButton *nextButton = (UIButton *)context.nextFocusedView;
        [coordinator addCoordinatedAnimations:^{
            nextButton.transform = CGAffineTransformMakeScale(1.1, 1.1);
            nextButton.layer.shadowColor = [UIColor whiteColor].CGColor;
            nextButton.layer.shadowOffset = CGSizeMake(0, 8);
            nextButton.layer.shadowRadius = 20;
            nextButton.layer.shadowOpacity = 0.8;
            nextButton.layer.borderWidth = 4;
            nextButton.layer.borderColor = [UIColor colorWithWhite:1.0 alpha:0.9].CGColor;
        } completion:nil];
    }
}

#pragma mark - AVAudioPlayerDelegate

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    // Music loops infinitely, so this shouldn't trigger
}

@end
