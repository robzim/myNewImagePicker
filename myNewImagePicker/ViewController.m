//
//  ViewController.m
//  myNewImagePicker
//
//  Created by Robert Zimmelman on 11/29/14.
//  Copyright (c) 2014 Robert Zimmelman. All rights reserved.
//

#import "ViewController.h"
#import "GameScene.h"


@implementation SKScene (Unarchive)

+ (instancetype)unarchiveFromFile:(NSString *)file {
    /* Retrieve scene file path from the application bundle */
    NSString *nodePath = [[NSBundle mainBundle] pathForResource:file ofType:@"sks"];
    /* Unarchive the file to an SKScene object */
    NSData *data = [NSData dataWithContentsOfFile:nodePath
                                          options:NSDataReadingMappedIfSafe
                                            error:nil];
    NSKeyedUnarchiver *arch = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    [arch setClass:self forClassName:@"SKScene"];
    SKScene *scene = [arch decodeObjectForKey:NSKeyedArchiveRootObjectKey];
    [arch finishDecoding];
    return scene;
}
@end


@implementation ViewController

@synthesize myImage1, myPicker1, myImage2, myPicker2, myImage3, myPicker3, myImage4, myImage5, myPicker4, myPicker5, myCameraPicker1, myCameraPicker2, myCameraPicker3, myCameraPicker4, myCameraPicker5;

@synthesize myTempURL;

@synthesize myCountdownTimer;
@synthesize myTimeRemaining;

@synthesize mySceneFromTheView;
@synthesize myViewFromTheScene;

@synthesize myAudioPlayer;

GameScene *myScene2;
SKView *myView2;




- (IBAction)unwindToThisViewController:(UIStoryboardSegue *)unwindSegue
{
    NSLog(@"unwound to here");
}


-(void)myShowTimesUpController{
    [myScene2 removeAllChildren];
    [[myScene2 myDropPicturesTimer] invalidate];
    [myCountdownTimer invalidate];
    myCountdownTimer=nil;
//    [myScene2 removeFromParent];
    UIAlertController *myQuitAlertController = [UIAlertController alertControllerWithTitle:@"Time's UP!" message:@"Do you want to Quit or Continue?" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *myCancelAction = [UIAlertAction actionWithTitle:@"Continue" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
        [self myStartCountdownTimer];
        [myScene2 myStartTheGame];
        [[self.view viewWithTag:11111] setHidden:NO];
        [myQuitAlertController removeFromParentViewController];
    }];
    UIAlertAction *myQuitAction = [UIAlertAction actionWithTitle:@"Quit" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        exit(0);
    }];
    [myQuitAlertController addAction:myCancelAction];
    [myQuitAlertController addAction:myQuitAction];
    [self presentViewController:myQuitAlertController animated:YES completion:^{
        [[[self view]viewWithTag:99999] setHidden:YES];
        //
        //
        //
        //  this is meant to re-start gameplay
        // from Shoot The Planes (myDropSpaceShips starts the dropping of the ships)
        //        [myScene2 myDropSpaceships];
    }];
    
    //Do something interesting here.
    
    
}

-(void)myReportHighScore {
    if (myScene2.myScore > myScene2.myHighScore) {
        UIAlertController *myReportHighScoreAlert = [UIAlertController alertControllerWithTitle:@"Report Score?" message:@"Would you like to report your Score?" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *myCancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            [myReportHighScoreAlert removeFromParentViewController];
            [self myStartCountdownTimer];
        }];
        UIAlertAction *myDefaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            NSLog(@"want to repot high score %d",myScene2.myScore);
            {
                int64_t score = myScene2.myScore;
                GKScore *scoreReporter = [[GKScore alloc] initWithLeaderboardIdentifier: @"org.zimmelman.flick_at_photos_high_scores"];
                scoreReporter.value = score;
                scoreReporter.context = 0;
                
                NSArray *scores = @[scoreReporter];
                [GKScore reportScores:scores withCompletionHandler:^(NSError *error) {
                    //Do something interesting here.
                    NSLog(@"Completed Reporting Scores");
                }];
            }
            
            //        [myReportScoreForLeaderboardID:@"org.zimmelman.flick_at_photos_high_scores"];
        }];
        [myReportHighScoreAlert addAction:myDefaultAction];
        [myReportHighScoreAlert addAction:myCancelAction];
        [self presentViewController:myReportHighScoreAlert animated:YES completion:^{
            NSLog(@"Reported High Score");
            
        } ];
        //
        //
        //
    }
    
    
    
}



-(void)myTimesUpAndReportHighScore{
    if (myScene2.myScore > myScene2.myHighScore) {
        [self myReportHighScore];
    }
    [self myShowTimesUpController];
}


-(void)myDoTimeLoop{
    [self setMyTimeRemaining: [NSNumber numberWithInteger: [myTimeRemaining integerValue] - 1]];
    if ([myTimeRemaining integerValue] <= 0) {
        [self myTimesUpAndReportHighScore];
    }
}


-(void)myStartCountdownTimer{
    // set time remaining low for testing
        [self setMyTimeRemaining:[NSNumber numberWithInteger:120]];
//    [self setMyTimeRemaining:[NSNumber numberWithInteger:15]];
//    [self setMyTimeRemaining:[NSNumber numberWithInteger:60]];
    myCountdownTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(myDoTimeLoop) userInfo:nil repeats:YES];
}



- (IBAction)playGame:(id)sender {
    
    //  code to play the game here
    SKView *skView = [[SKView alloc] init];
    //
    //
    /* Sprite Kit applies additional optimizations to improve rendering performance */
    skView.ignoresSiblingOrder = YES;
    //
    // Create and configure the scene.
    GameScene *scene = [GameScene unarchiveFromFile:@"GameScene"];
    [scene setSize:self.view.bounds.size];
    scene.scaleMode = SKSceneScaleModeAspectFit;
    
    [scene setMyMusicURL:myTempURL];
    [scene setMyTestNumber:[NSNumber numberWithInt:100]];
    NSLog(@"Setting Test Number %@",scene.myTestNumber);
    [scene setMyTestInt:10];
    NSLog(@"Setting Test Int %d",scene.myTestInt);
    scene.myAudioPlayer = myAudioPlayer;
//    [skView setShowsFPS:YES];
//    [skView setShowsDrawCount:YES];
//    [skView setShowsNodeCount:YES];
//    [skView setShowsQuadCount:YES];
    [skView setShouldCullNonVisibleNodes:YES];
//    [skView setShowsPhysics:YES];
    // rz set the images in the scene here
    //
    [scene setMySpriteImage1:myImage1.image];
    [scene setMySpriteImage2:myImage2.image];
    [scene setMySpriteImage3:myImage3.image];
    [scene setMySpriteImage4:myImage4.image];
    [scene setMySpriteImage5:myImage5.image];
    //
    //
    //  set the view to the SpriteKit View (skView)
    [self setView:skView];
    //
    //
    //  let the skView (SpriteKit View) present the scene
    //
    [skView presentScene:scene];
    //
    // fix this!!
    myView2 = skView;
    myScene2 = scene;
    //
    //
    // these are useless ?
    myViewFromTheScene = skView;
    [self myStartCountdownTimer];
}

-(void)myPlayTheMusic{
    NSURL *fileURL;
    if (myTempURL) {
        fileURL = myTempURL;
    } else {
        NSString *soundFilePath =
        //    [[NSBundle mainBundle] pathForResource: @"Normalized 03 Respect"
        //         [[NSBundle mainBundle] pathForResource: @"Smooth Criminal"
        //     [[NSBundle mainBundle] pathForResource: @"01 Welcome to My Life"
        
        //         [[NSBundle mainBundle] pathForResource: @"Normalized 12 Desafinado"
        //         [[NSBundle mainBundle] pathForResource: @"05 Dream On"
        [[NSBundle mainBundle] pathForResource: @"Shoot The Planes Intro Music"
                                        ofType: @"mp3"];
        
        
        fileURL = [[NSURL alloc] initFileURLWithPath: soundFilePath];
    }
    
    
    
    NSLog(@"Music URL %@",myTempURL);
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


-(void)mediaPickerDidCancel:(MPMediaPickerController *)mediaPicker{
    myTempURL = [NSURL URLWithString:@"TEST STRING"];
    NSLog(@"Temp URL in did cancel %@",myTempURL);
    [mediaPicker dismissViewControllerAnimated:YES completion:nil];
}




-(void)mediaPicker:(MPMediaPickerController *)mediaPicker didPickMediaItems:(MPMediaItemCollection *)mediaItemCollection{
    MPMediaItem *item = [mediaItemCollection.items  objectAtIndex:0];
//    NSLog(@"Media Item in DidPickMediaItems %@",item);
    myTempURL = [item valueForProperty: MPMediaItemPropertyAssetURL];
//    NSLog (@"URL from Library  %@", myTempURL);
    
//    NSLog(@"Media Item Title in DidPickMediaItems %@, Temp URL = %@",item.title ,myReallyTempURL);
    NSLog(@"Media Item Title in DidPickMediaItems %@, URL = %@",item.title ,item.assetURL);

    // let's get the song ready to play in the game
    [mediaPicker dismissViewControllerAnimated:YES completion:^{
        
    }];
}


- (IBAction)SelectMusic:(UIButton *)sender {
    
    MPMediaPickerController *myMediaPickerController = [[MPMediaPickerController alloc] initWithMediaTypes:MPMediaTypeMusic];
    [myMediaPickerController setDelegate:self];
    [myMediaPickerController setAllowsPickingMultipleItems:NO];
    [self presentViewController:myMediaPickerController animated:YES completion:nil];
    
}



- (IBAction)SelectMyImage1FromLib:(id)sender {
    myImageNum = 1 ;
    myPicker1 = [[ UIImagePickerController alloc] init];
    myPicker1.delegate = self;
    myPicker1.allowsEditing = YES;
    [myPicker1 setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
    [self presentViewController:myPicker1 animated:YES completion:nil];
}

- (IBAction)SelectMyImage2FromLib:(id)sender {
    myImageNum = 2 ;
    myPicker2 = [[ UIImagePickerController alloc] init];
    myPicker2.delegate = self;
    myPicker2.allowsEditing = YES;
    [myPicker2 setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
    [self presentViewController:myPicker2 animated:YES completion:nil];
}

- (IBAction)SelectMyImage3FromLib:(id)sender {
    myImageNum = 3 ;
    myPicker3 = [[ UIImagePickerController alloc] init];
    myPicker3.delegate = self;
    myPicker3.allowsEditing = YES;
    [myPicker3 setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
    [self presentViewController:myPicker3 animated:YES completion:nil];
}

- (IBAction)SelectMyImage5FromLib:(id)sender {
    myImageNum = 5 ;
    myPicker5 = [[ UIImagePickerController alloc] init];
    myPicker5.delegate = self;
    myPicker5.allowsEditing = YES;
    [myPicker5 setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
    [self presentViewController:myPicker5 animated:YES completion:nil];

}

- (IBAction)SelectMyImage4FromLib:(id)sender {
    myImageNum = 4 ;
    myPicker4 = [[ UIImagePickerController alloc] init];
    myPicker4.delegate = self;
    myPicker4.allowsEditing = YES;
    [myPicker4 setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
    [self presentViewController:myPicker4 animated:YES completion:nil];
}

- (IBAction)pickMyImage1:(id)sender {
    myImageNum = 1 ;
    ///
//    NSLog(@"just before the test");
    bool myTest1 = [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
    myCameraPicker1 = [[ UIImagePickerController alloc] init];
//    NSLog(@"mytest1 = %o",myTest1);
    myCameraPicker1.delegate = self;
    myCameraPicker1.allowsEditing = YES;
//    NSLog(@"before camera avail check");
    if (myTest1) {
//        NSLog(@"setting to camera");
        [myCameraPicker1 setSourceType:UIImagePickerControllerSourceTypeCamera];
    }
    else {
        UIAlertController *myAlertController = [UIAlertController alertControllerWithTitle:@"No Camera" message:@"This device has no camera or the camera is disabled.  Select images from the Photo Library." preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *myAlertAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
        [myAlertController addAction:myAlertAction];
        [self presentViewController:myAlertController animated:YES completion:nil ];
//        NSLog(@"setting to photo library");
        [myCameraPicker1 setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
    }
    [self presentViewController:myCameraPicker1 animated:YES completion:nil];
}



- (IBAction)pickMyImage2:(id)sender {
    myImageNum = 2 ;
    bool myTest1 = [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
    myCameraPicker2 = [[ UIImagePickerController alloc] init];
    myCameraPicker2.delegate = self;
    myCameraPicker2.allowsEditing = YES;
    if (myTest1) {
        [myCameraPicker2 setSourceType:UIImagePickerControllerSourceTypeCamera];
    }
    else {
        UIAlertController *myAlertController = [UIAlertController alertControllerWithTitle:@"No Camera" message:@"This device has no camera or the camera is disabled.  Select images from the Photo Library." preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *myAlertAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
        [myAlertController addAction:myAlertAction];
        [self presentViewController:myAlertController animated:YES completion:nil ];
        [myCameraPicker2 setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
    }
    [self presentViewController:myCameraPicker2 animated:YES completion:nil];
}

- (IBAction)pickMyImage3:(id)sender {
    myImageNum = 3 ;
    bool myTest1 = [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
    myCameraPicker3 = [[ UIImagePickerController alloc] init];
    myCameraPicker3.delegate = self;
    myCameraPicker3.allowsEditing = YES;
    if (myTest1) {
        [myCameraPicker3 setSourceType:UIImagePickerControllerSourceTypeCamera];
    }
    else
    {
        UIAlertController *myAlertController = [UIAlertController alertControllerWithTitle:@"No Camera" message:@"This device has no camera or the camera is disabled.  Select images from the Photo Library." preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *myAlertAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
        [myAlertController addAction:myAlertAction];
        [self presentViewController:myAlertController animated:YES completion:nil ];
        [myCameraPicker3 setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
    }
    [self presentViewController:myCameraPicker3 animated:YES completion:nil];
    
    
}

- (IBAction)pickMyImage4:(id)sender {
    myImageNum = 4 ;
    bool myTest1 = [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
    myCameraPicker4 = [[ UIImagePickerController alloc] init];
    myCameraPicker4.delegate = self;
    myCameraPicker4.allowsEditing = YES;
    if (myTest1) {
        [myCameraPicker4 setSourceType:UIImagePickerControllerSourceTypeCamera];
    }
    else
    {
        UIAlertController *myAlertController = [UIAlertController alertControllerWithTitle:@"No Camera" message:@"This device has no camera or the camera is disabled.  Select images from the Photo Library." preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *myAlertAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
        [myAlertController addAction:myAlertAction];
        [self presentViewController:myAlertController animated:YES completion:nil ];
        [myCameraPicker4 setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
    }
    [self presentViewController:myCameraPicker4 animated:YES completion:nil];
}

- (IBAction)pickMyImage5:(id)sender {
    myImageNum = 5 ;
    bool myTest1 = [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
    myCameraPicker5 = [[ UIImagePickerController alloc] init];
    myCameraPicker5.delegate = self;
    myCameraPicker5.allowsEditing = YES;
    if (myTest1) {

//        [myCameraPicker5 setMediaTypes:@[  ]];
        [myCameraPicker5 setSourceType:UIImagePickerControllerSourceTypeCamera];
    }
    else
    {
        UIAlertController *myAlertController = [UIAlertController alertControllerWithTitle:@"No Camera" message:@"This device has no camera or the camera is disabled.  Select images from the Photo Library." preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *myAlertAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
        [myAlertController addAction:myAlertAction];
        [self presentViewController:myAlertController animated:YES completion:nil ];
        [myCameraPicker5 setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
    }
    [self presentViewController:myCameraPicker5 animated:YES completion:nil];

}



- (IBAction)quitGame:(id)sender {
    
    
    exit(0);
}


- (void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    switch (myImageNum) {
        case 1:
            myImage1.image = [ info objectForKey:UIImagePickerControllerEditedImage];
            [picker dismissViewControllerAnimated:YES completion:nil];
            break;
        case 2:
            myImage2.image = [ info objectForKey:UIImagePickerControllerEditedImage];
            [picker dismissViewControllerAnimated:YES completion:nil];
            break;
        case 3:
            myImage3.image = [ info objectForKey:UIImagePickerControllerEditedImage];
            [picker dismissViewControllerAnimated:YES completion:nil];
            break;
        case 4:
            myImage4.image = [ info objectForKey:UIImagePickerControllerEditedImage];
            [picker dismissViewControllerAnimated:YES completion:nil];
            break;
        case 5:
            myImage5.image = [ info objectForKey:UIImagePickerControllerEditedImage];
            [picker dismissViewControllerAnimated:YES completion:nil];
            break;
        default:
            break;
    }
}



- (void) imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [ picker dismissViewControllerAnimated:YES completion:nil];
}

//
//
//
//    rz
//   setting prefersStatusBarHidden makes the top of the screen (status bar) hidden so the buttons work all
//    the way to the top of the screen
//
- (BOOL)prefersStatusBarHidden {
    return YES;
}



@end
