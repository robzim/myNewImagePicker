//
//  TVSetupViewController.h
//  PhotoDancePartyTV
//
//  Created by Robert Zimmelman.
//  Copyright © 2024 Robert Zimmelman. All rights reserved.
//

@import UIKit;
@import SpriteKit;
@import AVFoundation;
@import Photos;

#import "TVPhotoPickerViewController.h"
#import "TVMusicPickerViewController.h"

@interface TVSetupViewController : UIViewController <PHPhotoLibraryChangeObserver, AVAudioPlayerDelegate, TVPhotoPickerDelegate, TVMusicPickerDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *myImage1;
@property (weak, nonatomic) IBOutlet UIImageView *myImage2;
@property (weak, nonatomic) IBOutlet UIImageView *myImage3;
@property (weak, nonatomic) IBOutlet UIImageView *myImage4;
@property (weak, nonatomic) IBOutlet UIImageView *myImage5;

@property (weak, nonatomic) IBOutlet UILabel *myMusicLabel;
@property (weak, nonatomic) IBOutlet UIButton *myPlayButton;
@property (weak, nonatomic) IBOutlet UIButton *myRandomButton;
@property (weak, nonatomic) IBOutlet UIButton *mySelectPhotosButton;
@property (weak, nonatomic) IBOutlet UIButton *mySelectMusicButton;

@property PHFetchResult *myPhotos;
@property PHImageManager *myImageManager;

@property NSURL *myMusicURL;
@property NSString *myMusicStoreID;
@property NSString *mySongTitle;
@property NSString *mySongArtist;
@property BOOL myIsUserLibrarySong;

- (IBAction)playWithDefaultPhotos:(id)sender;
- (IBAction)playWithRandomPhotos:(id)sender;
- (IBAction)selectFromPhotoLibrary:(id)sender;
- (IBAction)selectMusic:(id)sender;
- (IBAction)showHelp:(id)sender;

@end
