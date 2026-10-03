//
//  TVViewController.h
//  TV Photo Chaos
//
//  tvOS setup screen controller
//  Bundled default photos, iCloud Photo Library, MusicKit integration
//
//  Created by Robert Zimmelman.
//  Copyright (c) 2024 Robert Zimmelman. All rights reserved.
//

@import UIKit;
@import SpriteKit;
@import AVFoundation;
@import Photos;
@import QuartzCore;

#import "TVMusicPickerViewController.h"
#import "TVPhotoPickerViewController.h"

@interface TVViewController : UIViewController <AVAudioPlayerDelegate, PHPhotoLibraryChangeObserver, TVMusicPickerDelegate, TVPhotoPickerDelegate>

// Photo image views for preview
@property (weak, nonatomic) IBOutlet UIImageView *myImage1;
@property (weak, nonatomic) IBOutlet UIImageView *myImage2;
@property (weak, nonatomic) IBOutlet UIImageView *myImage3;
@property (weak, nonatomic) IBOutlet UIImageView *myImage4;
@property (weak, nonatomic) IBOutlet UIImageView *myImage5;

// Photo library access
@property PHFetchResult *myPhotos;
@property PHImageManager *myImageManager;

// Music URL for selected song
@property NSURL *myTempURL;
@property NSString *mySongTitle;
@property NSString *mySongArtist;

// UI elements
@property (weak, nonatomic) IBOutlet UILabel *myMusicLabel;
@property (weak, nonatomic) IBOutlet UIButton *myPlayButton;
@property (weak, nonatomic) IBOutlet UIButton *myRandomButton;
@property (weak, nonatomic) IBOutlet UIButton *mySelectPhotosButton;
@property (weak, nonatomic) IBOutlet UIButton *mySelectMusicButton;

// Game scene reference
@property SKView *myView2;
@property SKScene *myScene2;

// Actions
- (IBAction)playWithDefaultPhotos:(id)sender;
- (IBAction)playWithRandomPhotos:(id)sender;
- (IBAction)selectFromPhotoLibrary:(id)sender;
- (IBAction)selectMusic:(id)sender;
- (IBAction)showHelp:(id)sender;

// Internal methods
- (void)loadDefaultBundledPhotos;
- (void)myPlayGame:(id)sender withRandomImages:(BOOL)myRandomImagesFlag;
- (void)myShowQuitAlertController;

@end
