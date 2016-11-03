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

@interface ViewController : UIViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate>
{
int  myImageNum;
}



@property NSNumber *myTimeRemaining;
@property NSTimer *myCountdownTimer;

@property (weak, nonatomic) IBOutlet UIImageView *myImage1;
@property (weak, nonatomic) IBOutlet UIImageView *myImage2;
@property (weak, nonatomic) IBOutlet UIImageView *myImage3;
@property (weak, nonatomic) IBOutlet UIImageView *myImage4;
@property (weak, nonatomic) IBOutlet UIImageView *myImage5;



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
- (IBAction)playGame:(id)sender;

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

@property GKScene *mySceneFromTheView;
@property SKView *myViewFromTheScene;



@end

