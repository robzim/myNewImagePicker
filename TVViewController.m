//
//  TVViewController.m
//  TV Photo Chaos
//
//  tvOS setup screen controller
//  Bundled default photos, iCloud Photo Library, MusicKit integration
//
//  Created by Robert Zimmelman.
//  Copyright (c) 2024 Robert Zimmelman. All rights reserved.
//

#import "TVViewController.h"
#import "TVGameScene.h"
#import "TVMusicPickerViewController.h"
#import "TVPhotoPickerViewController.h"

@implementation SKScene (Unarchive)

+ (instancetype)unarchiveFromFile:(NSString *)file {
    NSString *nodePath = [[NSBundle mainBundle] pathForResource:file ofType:@"sks"];
    NSData *data = [NSData dataWithContentsOfFile:nodePath options:NSDataReadingMappedIfSafe error:nil];
    NSError *myError = nil;
    NSKeyedUnarchiver *arch = [[NSKeyedUnarchiver alloc] initForReadingFromData:data error:&myError];
    if (myError) {
        NSLog(@"Error unarchiving: %@", myError);
        return nil;
    }
    [arch setClass:self forClassName:@"SKScene"];
    SKScene *scene = [arch decodeObjectForKey:NSKeyedArchiveRootObjectKey];
    [arch finishDecoding];
    return scene;
}

@end

@implementation TVViewController

@synthesize myImage1, myImage2, myImage3, myImage4, myImage5;
@synthesize myTempURL;
@synthesize mySongTitle;
@synthesize mySongArtist;
@synthesize myPhotos;
@synthesize myImageManager;
@synthesize myView2;
@synthesize myScene2;

TVGameScene *tvScene;
SKView *tvView;

bool myTestMode = NO;
bool myRandomImagesFlag = NO;
float myWidth;
float myViewImageSize;

// Modern UI color palette
#define MAGIC_PURPLE [UIColor colorWithRed:0.4 green:0.2 blue:0.8 alpha:1.0]
#define MAGIC_PINK [UIColor colorWithRed:1.0 green:0.4 blue:0.6 alpha:1.0]
#define MAGIC_CYAN [UIColor colorWithRed:0.2 green:0.8 blue:1.0 alpha:1.0]
#define MAGIC_GOLD [UIColor colorWithRed:1.0 green:0.85 blue:0.3 alpha:1.0]
#define GLASS_WHITE [UIColor colorWithWhite:1.0 alpha:0.15]
#define GLASS_BORDER [UIColor colorWithWhite:1.0 alpha:0.3]

#pragma mark - View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];

    myWidth = self.view.bounds.size.width;
    myViewImageSize = myWidth / 6.0;  // Larger for TV
    NSLog(@"TV Width = %f", myWidth);

    // Setup photo library access
    [[PHPhotoLibrary sharedPhotoLibrary] registerChangeObserver:self];

    myPhotos = [[PHFetchResult alloc] init];
    PHFetchOptions *myFetchOptions = [[PHFetchOptions alloc] init];
    [myFetchOptions setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:YES selector:NULL]]];
    myPhotos = [PHAsset fetchAssetsWithOptions:myFetchOptions];

    if (myPhotos.count != 0) {
        myImageManager = [[PHImageManager alloc] init];
    }

    // Load bundled default photos
    [self loadDefaultBundledPhotos];

    // Register for quit notification
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(myShowQuitAlertController) name:@"quitnotifictaion" object:nil];

    // Setup gradient background
    [self setupGradientBackground];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    // Style the view for TV
    [self styleForTV];
}

#pragma mark - UI Setup

- (void)setupGradientBackground {
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = self.view.bounds;
    gradient.colors = @[
        (id)[UIColor colorWithRed:0.05 green:0.0 blue:0.15 alpha:1.0].CGColor,
        (id)[UIColor colorWithRed:0.15 green:0.05 blue:0.3 alpha:1.0].CGColor,
        (id)[UIColor colorWithRed:0.1 green:0.0 blue:0.25 alpha:1.0].CGColor
    ];
    gradient.locations = @[@0.0, @0.5, @1.0];
    gradient.startPoint = CGPointMake(0, 0);
    gradient.endPoint = CGPointMake(1, 1);
    [self.view.layer insertSublayer:gradient atIndex:0];
}

- (void)styleForTV {
    // Style image views with rounded corners and glow
    NSArray *imageViews = @[myImage1, myImage2, myImage3, myImage4, myImage5];
    for (UIImageView *imageView in imageViews) {
        if (imageView) {
            imageView.layer.cornerRadius = 20;
            imageView.layer.masksToBounds = YES;
            imageView.layer.borderWidth = 2;
            imageView.layer.borderColor = [UIColor colorWithWhite:1.0 alpha:0.3].CGColor;
            imageView.contentMode = UIViewContentModeScaleAspectFill;
        }
    }
}

#pragma mark - Default Photos

- (void)loadDefaultBundledPhotos {
    // Load 5 bundled default photos
    UIImage *defaultPhoto1 = [UIImage imageNamed:@"DefaultPhoto1.jpg"];
    UIImage *defaultPhoto2 = [UIImage imageNamed:@"DefaultPhoto2.jpg"];
    UIImage *defaultPhoto3 = [UIImage imageNamed:@"DefaultPhoto3.jpg"];
    UIImage *defaultPhoto4 = [UIImage imageNamed:@"DefaultPhoto4.jpg"];
    UIImage *defaultPhoto5 = [UIImage imageNamed:@"DefaultPhoto5.jpg"];

    // Fallback to generating colored placeholder images if not found
    if (!defaultPhoto1) defaultPhoto1 = [self createPlaceholderImageWithColor:MAGIC_PINK];
    if (!defaultPhoto2) defaultPhoto2 = [self createPlaceholderImageWithColor:MAGIC_CYAN];
    if (!defaultPhoto3) defaultPhoto3 = [self createPlaceholderImageWithColor:MAGIC_PURPLE];
    if (!defaultPhoto4) defaultPhoto4 = [self createPlaceholderImageWithColor:MAGIC_GOLD];
    if (!defaultPhoto5) defaultPhoto5 = [self createPlaceholderImageWithColor:[UIColor colorWithRed:0.3 green:1.0 blue:0.5 alpha:1.0]];

    myImage1.image = defaultPhoto1;
    myImage2.image = defaultPhoto2;
    myImage3.image = defaultPhoto3;
    myImage4.image = defaultPhoto4;
    myImage5.image = defaultPhoto5;

    NSLog(@"Loaded default bundled photos for tvOS");
}

- (UIImage *)createPlaceholderImageWithColor:(UIColor *)color {
    CGSize size = CGSizeMake(200, 200);
    UIGraphicsBeginImageContextWithOptions(size, YES, 0);
    CGContextRef ctx = UIGraphicsGetCurrentContext();

    // Fill with color
    [color setFill];
    CGContextFillRect(ctx, CGRectMake(0, 0, size.width, size.height));

    // Add some visual interest with a gradient
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGFloat colors[] = {1.0, 1.0, 1.0, 0.3, 1.0, 1.0, 1.0, 0.0};
    CGFloat locations[] = {0.0, 1.0};
    CGGradientRef gradient = CGGradientCreateWithColorComponents(colorSpace, colors, locations, 2);

    CGPoint center = CGPointMake(size.width / 2, size.height / 2);
    CGContextDrawRadialGradient(ctx, gradient, center, 0, center, size.width / 2, kCGGradientDrawsAfterEndLocation);

    CGGradientRelease(gradient);
    CGColorSpaceRelease(colorSpace);

    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

#pragma mark - Photo Library

- (void)photoLibraryDidChange:(PHChange *)changeInstance {
    NSLog(@"TVViewController Photo Library Changed");
}

- (void)myAssignImages {
    if (myPhotos.count < 5) {
        NSLog(@"Not enough photos in library, using defaults");
        return;
    }

    int targetSize = 200;

    // Assign random photos from library
    for (int i = 0; i < 5; i++) {
        [myImageManager requestImageForAsset:myPhotos[arc4random() % myPhotos.count]
                                  targetSize:CGSizeMake(targetSize, targetSize)
                                 contentMode:PHImageContentModeAspectFit
                                     options:nil
                               resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
            if (result) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    switch (i) {
                        case 0: self->myImage1.image = result; break;
                        case 1: self->myImage2.image = result; break;
                        case 2: self->myImage3.image = result; break;
                        case 3: self->myImage4.image = result; break;
                        case 4: self->myImage5.image = result; break;
                    }
                });
            }
        }];
    }
}

#pragma mark - Actions

- (IBAction)playWithDefaultPhotos:(id)sender {
    [self myPlayGame:sender withRandomImages:NO];
}

- (IBAction)playWithRandomPhotos:(id)sender {
    [self myPlayGame:sender withRandomImages:YES];
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

#pragma mark - TVPhotoPickerDelegate

- (void)photoPickerDidSelectPhotos:(NSArray<UIImage *> *)photos {
    NSLog(@"Photo picker selected %lu photos", (unsigned long)photos.count);

    // Assign photos to image views
    if (photos.count >= 1) myImage1.image = photos[0];
    if (photos.count >= 2) myImage2.image = photos[1];
    if (photos.count >= 3) myImage3.image = photos[2];
    if (photos.count >= 4) myImage4.image = photos[3];
    if (photos.count >= 5) myImage5.image = photos[4];

    // If fewer than 5 photos, fill remaining with defaults
    if (photos.count < 5) {
        NSArray *defaults = @[
            [self createPlaceholderImageWithColor:MAGIC_PINK],
            [self createPlaceholderImageWithColor:MAGIC_CYAN],
            [self createPlaceholderImageWithColor:MAGIC_PURPLE],
            [self createPlaceholderImageWithColor:MAGIC_GOLD],
            [self createPlaceholderImageWithColor:[UIColor colorWithRed:0.3 green:1.0 blue:0.5 alpha:1.0]]
        ];

        if (photos.count < 5) myImage5.image = defaults[4];
        if (photos.count < 4) myImage4.image = defaults[3];
        if (photos.count < 3) myImage3.image = defaults[2];
        if (photos.count < 2) myImage2.image = defaults[1];
        if (photos.count < 1) myImage1.image = defaults[0];
    }
}

- (void)photoPickerDidCancel {
    NSLog(@"Photo picker cancelled");
}

#pragma mark - TVMusicPickerDelegate

- (void)musicPickerDidSelectSongWithURL:(NSURL *)url title:(NSString *)title artist:(NSString *)artist {
    NSLog(@"Music picker selected: %@ by %@", title, artist);

    myTempURL = url;
    mySongTitle = title;
    mySongArtist = artist;

    // Update the music label
    if (self.myMusicLabel) {
        self.myMusicLabel.text = [NSString stringWithFormat:@"Music: %@ - %@", title, artist];
    }
}

- (void)musicPickerDidCancel {
    NSLog(@"Music picker cancelled");
}

- (IBAction)showHelp:(id)sender {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Photo Dance Party!"
                                                                   message:@"Watch your photos dance to the music!\n\nPress Play to start.\nPress Menu during game for options.\nPress Play/Pause button to control music."
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - Game Launch

- (IBAction)myPlayGame:(id)sender withRandomImages:(BOOL)randomImages {
    NSLog(@"tvOS: Launching game with randomImages=%d", randomImages);

    // quitnotifictaion observer is already registered in viewDidLoad; do not re-register.

    // Create flash transition
    UIView *flashView = [[UIView alloc] initWithFrame:self.view.bounds];
    flashView.backgroundColor = [UIColor colorWithRed:1.0 green:0.4 blue:0.8 alpha:0.0];
    flashView.alpha = 0;
    [self.view addSubview:flashView];

    [UIView animateWithDuration:0.15 animations:^{
        flashView.alpha = 1.0;
        flashView.backgroundColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.8];
    } completion:^(BOOL finished) {
        // Setup the game scene
        SKView *skView = [[SKView alloc] initWithFrame:self.view.bounds];
        [skView setAutoresizingMask:(UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight)];
        skView.ignoresSiblingOrder = YES;
        skView.alpha = 0;

        // Create and configure the scene
        TVGameScene *scene = [TVGameScene unarchiveFromFile:@"GameScene"];
        if (!scene) {
            scene = [[TVGameScene alloc] initWithSize:self.view.bounds.size];
        }
        [scene setSize:self.view.bounds.size];
        scene.scaleMode = SKSceneScaleModeAspectFill;

        // tvOS: Always music mode (no mic)
        [scene setMyResizeMethod:2];  // Music pulse mode

        // Set music URL
        [scene setMyMusicURL:self->myTempURL];
        [scene setMySongTitle:self->mySongTitle];
        [scene setMySongArtist:self->mySongArtist];

        // Set images
        [scene setMySpriteImage1:self->myImage1.image];
        [scene setMySpriteImage2:self->myImage2.image];
        [scene setMySpriteImage3:self->myImage3.image];
        [scene setMySpriteImage4:self->myImage4.image];
        [scene setMySpriteImage5:self->myImage5.image];

        // Remove existing subviews and add SKView
        for (UIView *subview in self.view.subviews) {
            if (subview != flashView) {
                [subview removeFromSuperview];
            }
        }
        [self.view insertSubview:skView belowSubview:flashView];

        // Present the scene
        [skView presentScene:scene];

        // Store references
        tvView = skView;
        tvScene = scene;
        self->myView2 = skView;
        self->myScene2 = scene;

        tvScene.mySceneImageSize = myWidth / 6.0;  // Larger for TV

        // All images active by default
        tvScene.myImage1Flag = 1;
        tvScene.myImage2Flag = 1;
        tvScene.myImage3Flag = 1;
        tvScene.myImage4Flag = 1;
        tvScene.myImage5Flag = 1;

        tvScene.myPicturesArray = [@[@1, @2, @3, @4, @5] mutableCopy];

        if (randomImages) {
            [scene setMyAllRandomImagesFlag:YES];
        } else {
            [scene setMyAllRandomImagesFlag:NO];
        }

        [scene myStartTheGame];

        // Fade out flash and reveal game
        skView.transform = CGAffineTransformMakeScale(1.1, 1.1);
        [UIView animateWithDuration:0.4 delay:0 usingSpringWithDamping:0.8 initialSpringVelocity:0.5 options:UIViewAnimationOptionCurveEaseOut animations:^{
            flashView.alpha = 0;
            skView.alpha = 1.0;
            skView.transform = CGAffineTransformIdentity;
        } completion:^(BOOL finished) {
            [flashView removeFromSuperview];
        }];
    }];
}

#pragma mark - In-Game Menu

- (void)myShowQuitAlertController {
    NSLog(@"tvOS: Showing quit menu");

    // Pause the game timer
    [[tvScene myDropPicturesTimer] invalidate];

    // Create tvOS-style alert controller
    UIAlertController *menu = [UIAlertController alertControllerWithTitle:@"Photo Dance Party!"
                                                                  message:nil
                                                           preferredStyle:UIAlertControllerStyleActionSheet];

    // Resume
    [menu addAction:[UIAlertAction actionWithTitle:@"Resume" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [tvScene myStartDropPicturesTimer];
    }]];

    // Change Photos
    [menu addAction:[UIAlertAction actionWithTitle:@"Change Photos" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [tvScene myAssignImage1];
        [tvScene myAssignImage2];
        [tvScene myAssignImage3];
        [tvScene myAssignImage4];
        [tvScene myAssignImage5];
        [tvScene myStartDropPicturesTimer];
    }]];

    // All Random Photos
    [menu addAction:[UIAlertAction actionWithTitle:@"All Random Photos" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [tvScene setMyAllRandomImagesFlag:YES];
        [tvScene myStartDropPicturesTimer];
    }]];

    // Music Controls
    [menu addAction:[UIAlertAction actionWithTitle:@"Play/Pause Music" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [tvScene myPlayPause];
        [tvScene myStartDropPicturesTimer];
    }]];

    [menu addAction:[UIAlertAction actionWithTitle:@"Restart Music" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [tvScene myRestartTheMusic];
        [tvScene myStartDropPicturesTimer];
    }]];

    // Resize Modes
    [menu addAction:[UIAlertAction actionWithTitle:@"Music Pulse Mode" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [tvScene setMyResizeMethod:2];
        [tvScene mySetupAudioDisplay];
        [tvScene myStartDropPicturesTimer];
    }]];

    [menu addAction:[UIAlertAction actionWithTitle:@"Music Instant Mode" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [tvScene setMyResizeMethod:1];
        [tvScene mySetupAudioDisplay];
        [tvScene myStartDropPicturesTimer];
    }]];

    [menu addAction:[UIAlertAction actionWithTitle:@"No Music Reaction" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [tvScene setMyResizeMethod:0];
        [tvScene myStartDropPicturesTimer];
    }]];

    // Quit
    [menu addAction:[UIAlertAction actionWithTitle:@"Quit" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        exit(0);
    }]];

    // Cancel (resume)
    [menu addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [tvScene myStartDropPicturesTimer];
    }]];

    [self presentViewController:menu animated:YES completion:nil];
}

#pragma mark - Audio Player Delegate

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    NSLog(@"Audio finished playing");
}

- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError *)error {
    NSLog(@"Audio decode error: %@", error);
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[PHPhotoLibrary sharedPhotoLibrary] unregisterChangeObserver:self];
}

@end
