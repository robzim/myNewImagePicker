//
//  ViewController.h
//  myNewImagePicker
//
//  Created by Robert Zimmelman on 11/29/14.
//  Copyright (c) 2014 Robert Zimmelman. All rights reserved.
//

@import UIKit;
@import SpriteKit;
@import AVFoundation;
@import GameKit;
@import MobileCoreServices;
@import MediaPlayer;
@import Photos;


@interface ViewController : UIViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate,MPMediaPickerControllerDelegate,AVAudioPlayerDelegate,PHPhotoLibraryChangeObserver>
{
int  myImageNum;
}

@property NSURL *myTempURL;

@property NSNumber *myTimeRemaining;
//@property NSTimer *myCountdownTimer;

@property (weak, nonatomic) IBOutlet UIImageView *myImage1;
@property (weak, nonatomic) IBOutlet UIImageView *myImage2;
@property (weak, nonatomic) IBOutlet UIImageView *myImage3;
@property (weak, nonatomic) IBOutlet UIImageView *myImage4;
@property (weak, nonatomic) IBOutlet UIImageView *myImage5;

@property PHFetchResult *myPhotos;
@property PHImageManager *myImageManager;
- (IBAction)myPickFiveImages:(UIButton *)sender;

- (IBAction)mySetRandomImages:(UIButton *)sender;

- (IBAction)SelectMyImage1FromLib:(id)sender;
- (IBAction)SelectMyImage2FromLib:(id)sender;
- (IBAction)SelectMyImage3FromLib:(id)sender;
- (IBAction)SelectMyImage5FromLib:(id)sender;
- (IBAction)SelectMyImage4FromLib:(id)sender;

- (IBAction)pickMyImage1:(id)sender;
- (IBAction)pickMyImage2:(id)sender;
- (IBAction)pickMyImage3:(id)sender;
- (IBAction)pickMyImage4:(id)sender;
- (IBAction)pickMyImage5:(id)sender;

- (IBAction)removeMyImage1:(id)sender;

- (IBAction)removeMyImage2:(id)sender;

- (IBAction)removeMyImage3:(id)sender;

- (IBAction)removeMyImage4:(id)sender;

- (IBAction)removeMyImage5:(id)sender;

- (IBAction)mySetNoRandomImages:(UIButton *)sender;
- (IBAction)myPlayGame: (id) sender withRandomImages: (BOOL)myRandomImagesFlag;
- (IBAction)myPlayGameWithRandomPictures:(UIButton *)sender;

- (IBAction)SelectMusic:(UIButton *)sender;

- (IBAction)quitGame:(id)sender;

@property (strong,nonatomic) UIImagePickerController *myPicker1;
@property (strong,nonatomic) UIImagePickerController *myPicker2;
@property (strong,nonatomic) UIImagePickerController *myPicker3;
@property (strong,nonatomic) UIImagePickerController *myPicker4;
@property (strong,nonatomic) UIImagePickerController *myPicker5;


@property (strong,nonatomic) UIImagePickerController *myCameraPicker1;
@property (strong,nonatomic) UIImagePickerController *myCameraPicker2;
@property (strong,nonatomic) UIImagePickerController *myCameraPicker3;
@property (strong,nonatomic) UIImagePickerController *myCameraPicker4;
@property (strong,nonatomic) UIImagePickerController *myCameraPicker5;


//
//
// do some tests to see the right way to do this, or else just use nsnotifications
//@property GKScene *mySceneFromTheView;
//@property SKView *myViewFromTheScene;


//@property AVAudioPlayer *myAudioPlayer;

//- (IBAction)myMusicOnOff:(UIButton *)sender;
//@property (weak, nonatomic) IBOutlet UIButton *myMusicOnOffButton;

@end

