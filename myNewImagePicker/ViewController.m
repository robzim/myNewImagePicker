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

@synthesize myTimeRemaining;

//@synthesize mySceneFromTheView;
//@synthesize myViewFromTheScene;

@synthesize myPhotos;
@synthesize myImageManager;

GameScene *myScene2;
SKView *myView2;

bool myTestMode = NO;

bool myRandomImagesFlag = NO;

float myWidth;
float myViewImageSize;



-(void)myRemoveImageObservers{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"assignimage1" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"assignimage2" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"assignimage3" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"assignimage4" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"assignimage5" object:nil];
    
}


-(void)myAddImageObservers{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(myAssignImage1:) name:@"assignimage1" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(myAssignImage2:) name:@"assignimage2" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(myAssignImage3:) name:@"assignimage3" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(myAssignImage4:) name:@"assignimage4" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(myAssignImage5:) name:@"assignimage5" object:nil];
}


-(void)viewDidLoad{
        [super viewDidLoad];
    
    
    myWidth = self.view.bounds.size.width;
    myViewImageSize = myWidth / 4.0;
    NSLog(@"Width = %f",myWidth);
    
    [[PHPhotoLibrary sharedPhotoLibrary] registerChangeObserver:self];
    
    myPhotos = [[PHFetchResult alloc] init];
    //    PHFetchResult *myAlbums = [[PHFetchResult alloc] init];
    //    PHFetchResult *myCollections = [[PHFetchResult alloc] init];
    PHFetchOptions *myFetchOptions = [[PHFetchOptions alloc] init];
    
    [myFetchOptions setSortDescriptors:(NSArray<NSSortDescriptor *> * _Nullable) @[
                                                                                   [NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:YES selector:NULL]]];
    myPhotos = [PHAsset fetchAssetsWithOptions:myFetchOptions];
    if (myPhotos.count != 0) {
        if (myTestMode) {
            [self myListAllPhotoAssets];
        }
        myImageManager = [[PHImageManager alloc] init];
        [self myAssignImages:self.view];
    }
}

-(IBAction) myAssignImage1: (id) sender {
    NSLog(@"View Controller in Assign Image 1");
    if (myPhotos.count<=4) {
        UIAlertController *myNoPhotosAlertController = [UIAlertController alertControllerWithTitle:@"Photos Library" message:@"Grant Access to the Photos Library.  Go to Settings, then to Apps Meny then Select 'TV Photo Chaos' and make sure that 'Always' is selected. Then you will see YOUR PHOTOS in the Game." preferredStyle:UIAlertControllerStyleAlert];
        [myNoPhotosAlertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
        [self showViewController:myNoPhotosAlertController sender:self];
    } else {
        [myImageManager requestImageForAsset:myPhotos[arc4random()%myPhotos.count] targetSize:CGSizeMake(myViewImageSize, myViewImageSize) contentMode:PHImageContentModeAspectFit options:nil resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
            if (result) {
                [self->myImage1 setImage:result];
                [myScene2 setMySpriteImage1:self->myImage1.image];
            } else {
                NSLog(@"error retreiving photo");
            }
            
        }];
    }
}





-(IBAction) myAssignImage2: (id) sender {
    if (myPhotos.count<=4) {
        UIAlertController *myNoPhotosAlertController = [UIAlertController alertControllerWithTitle:@"Photos Library" message:@"Grant Access to the Photos Library.  Go to Settings, then to Apps Meny then Select 'TV Photo Chaos' and make sure that 'Always' is selected. Then you will see YOUR PHOTOS in the Game." preferredStyle:UIAlertControllerStyleAlert];
        [myNoPhotosAlertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
        [self showViewController:myNoPhotosAlertController sender:self];
    } else {
        
        [myImageManager requestImageForAsset:myPhotos[arc4random()%myPhotos.count] targetSize:CGSizeMake(myViewImageSize, myViewImageSize) contentMode:PHImageContentModeAspectFit options:nil resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
            if (result) {
                [self->myImage2 setImage:result];
                [myScene2 setMySpriteImage2:self->myImage2.image];
            } else {
                NSLog(@"error retreiving photo");
            }
        }];
    }
}




-(IBAction) myAssignImage3: (id) sender {
    if (myPhotos.count<=4) {
        UIAlertController *myNoPhotosAlertController = [UIAlertController alertControllerWithTitle:@"Photos Library" message:@"Grant Access to the Photos Library.  Go to Settings, then to Apps Meny then Select 'TV Photo Chaos' and make sure that 'Always' is selected. Then you will see YOUR PHOTOS in the Game." preferredStyle:UIAlertControllerStyleAlert];
        [myNoPhotosAlertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
        [self showViewController:myNoPhotosAlertController sender:self];
    } else {
        [myImageManager requestImageForAsset:myPhotos[arc4random()%myPhotos.count] targetSize:CGSizeMake(myViewImageSize, myViewImageSize) contentMode:PHImageContentModeAspectFit options:nil resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
            if (result) {
                [self->myImage3 setImage:result];
                [myScene2 setMySpriteImage3:self->myImage3.image];
            } else {
                NSLog(@"error retreiving photo");
            }
        }];
    }
    
}


-(IBAction) myAssignImage4: (id) sender {
    if (myPhotos.count<=4) {
        UIAlertController *myNoPhotosAlertController = [UIAlertController alertControllerWithTitle:@"Photos Library" message:@"Grant Access to the Photos Library.  Go to Settings, then to Apps Meny then Select 'TV Photo Chaos' and make sure that 'Always' is selected. Then you will see YOUR PHOTOS in the Game." preferredStyle:UIAlertControllerStyleAlert];
        [myNoPhotosAlertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
        [self showViewController:myNoPhotosAlertController sender:self];
    }
    else {
        [myImageManager requestImageForAsset:myPhotos[arc4random()%myPhotos.count] targetSize:CGSizeMake(myViewImageSize, myViewImageSize) contentMode:PHImageContentModeAspectFit options:nil resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
            if (result) {
                [self->myImage4 setImage:result];
                [myScene2 setMySpriteImage4:self->myImage4.image];
            } else {
                NSLog(@"error retreiving photo");
            }
        }];
    }
}


-(IBAction) myAssignImage5: (id) sender {
    if (myPhotos.count<=4) {
        UIAlertController *myNoPhotosAlertController = [UIAlertController alertControllerWithTitle:@"Photos Library" message:@"Grant Access to the Photos Library.  Go to Settings, then to Apps Meny then Select 'TV Photo Chaos' and make sure that 'Always' is selected. Then you will see YOUR PHOTOS in the Game." preferredStyle:UIAlertControllerStyleAlert];
        [myNoPhotosAlertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
        [self showViewController:myNoPhotosAlertController sender:self];
    }
    else {
        [myImageManager requestImageForAsset:myPhotos[arc4random()%myPhotos.count] targetSize:CGSizeMake(myViewImageSize, myViewImageSize) contentMode:PHImageContentModeAspectFit options:nil resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
            if (result) {
                [self->myImage5 setImage:result];
                [myScene2 setMySpriteImage5:self->myImage5.image];
            } else {
                NSLog(@"error retreiving photo");
            }
        }];
    }
}

- (IBAction)myPickFiveImages:(UIButton *)sender {
    //
    // this is when the user presses the 'Refresh' button
    //
    [self myAssignImage1:self];
    [self myAssignImage2:self];
    [self myAssignImage3:self];
    [self myAssignImage4:self];
    [self myAssignImage5:self];

}

- (IBAction)mySetRandomImages:(id)sender {
    //
    // this is when the user presses the 'Random' button
    [self myPlayGame:self withRandomImages:YES];
}

- (IBAction)mySetNoRandomImages:(UIButton *)sender {
    //
    //
    // this is when the user presses the 'Go' button
    [self myPlayGame:self withRandomImages:NO];
}

-(IBAction) myAssignImages: (id) sender {
    if (myPhotos.count<=4) {
        UIAlertController *myNoPhotosAlertController = [UIAlertController alertControllerWithTitle:@"Photos Library" message:@"Grant Access to the Photos Library.  Go to Settings, then to Apps Meny then Select 'TV Photo Chaos' and make sure that 'Always' is selected. Then you will see YOUR PHOTOS in the Game." preferredStyle:UIAlertControllerStyleAlert];
        [myNoPhotosAlertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
        [self showViewController:myNoPhotosAlertController sender:self];
    }
    if (myPhotos.count > 4) {
        //    [myPhotos enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        //        NSLog(@"Object: %@",  (PHAsset *)  obj   );
        //        NSLog(@"Description: %@, #%ld",  (PHAsset *)  [obj description], idx   );
        //    }];
        //    NSLog(@"Photos: %@",myPhotos.description);
        //
        //    NSLog(@"Photos First Object: %@",myPhotos.firstObject);
        
        [self myAssignImage1:self];
        [self myAssignImage2:self];
        [self myAssignImage3:self];
        [self myAssignImage4:self];
        [self myAssignImage5:self];
        [myScene2 myAssignImage1];
        [myScene2 myAssignImage2];
        [myScene2 myAssignImage3];
        [myScene2 myAssignImage4];
        [myScene2 myAssignImage5];
    }
    
}





-(void)photoLibraryDidChange:(PHChange *)changeInstance{
    NSLog(@"View Controller - Photo Library Changed");
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
        if (myTestMode) {
            [self myListAllPhotoAssets];
        }
        
        myImageManager = [[PHImageManager alloc] init];
        
        [self myAssignImages:self.view];
    }
}



-(void)myShowQuitAlertController{
    NSLog(@" in myShowQuitAlertController");
//    UIAlertController *myQuitAlertController = [UIAlertController alertControllerWithTitle:@"How May I Help You?" message:nil preferredStyle:UIAlertControllerStyleAlert];
    UIAlertController *myQuitAlertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleAlert];
    
    
//    [myQuitAlertController addAction:[UIAlertAction actionWithTitle:@"Drop a Picture Now" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//        int myRandomPictureNumber = arc4random()%5;
//        [myScene2 myDropPictureNumber:myRandomPictureNumber];
//    }]];
    
    
    
//    [myQuitAlertController.view setTransform:CGAffineTransformMakeScale(0.5, 0.5)];
    
    
    
    
    [myQuitAlertController addAction:[UIAlertAction actionWithTitle:@"Resume Dropping Pictures" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [[myScene2 myDropPicturesTimer] invalidate];
        [myScene2 myStartDropPicturesTimer];
    }]];

    [myQuitAlertController addAction:[UIAlertAction actionWithTitle:@"Use 5 New Random Photos" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [myScene2 myAssignImage1];
        [myScene2 myAssignImage2];
        [myScene2 myAssignImage3];
        [myScene2 myAssignImage4];
        [myScene2 myAssignImage5];
    }]];
    [myQuitAlertController addAction:[UIAlertAction actionWithTitle:@"Use ALL of your Photos" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [myScene2 setMyAllRandomImagesFlag:YES];
    }]];
    [myQuitAlertController addAction:[UIAlertAction actionWithTitle:@"Choose A Song" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self SelectMusic:nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"selectedmusic" object:nil];
    }]];
    [myQuitAlertController addAction:[UIAlertAction actionWithTitle:@"Pause / Resume Music" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [myScene2 myPlayPause];
        //        [[NSNotificationCenter defaultCenter] postNotificationName:@"playpause" object:nil];
    }]];
    [myQuitAlertController addAction:[UIAlertAction actionWithTitle:@"Restart Music"
                                                              style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                                                                  [myScene2 myRestartTheMusic];
//        [[NSNotificationCenter defaultCenter] postNotificationName:@"restartmusic" object:nil];
    }]];
    [myQuitAlertController addAction:[UIAlertAction actionWithTitle:@"Size on Music Power Change" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [myScene2 setMyResizeMethod:2];
    }]];
    [myQuitAlertController addAction:[UIAlertAction actionWithTitle:@"Size on Music Instant Power" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [myScene2 setMyResizeMethod:1];
    }]];
    [myQuitAlertController addAction:[UIAlertAction actionWithTitle:@"Don't Resize to Music" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [myScene2 setMyResizeMethod:0];
        //
    }]];
    if (myScene2.myOSVersion >= 10) {
        [myQuitAlertController addAction:[UIAlertAction actionWithTitle:@"Vibrate/Don't Vibrate iPhone7"
                                                                  style:UIAlertActionStyleDefault
                                                                handler:^(UIAlertAction * _Nonnull action) {
                                                                    if (myScene2.myVibrateFlag == YES) {
                                                                        myScene2.myVibrateFlag = NO;
                                                                        NSLog(@"Turn Off Vibrate");
                                                                    }
                                                                    else {
                                                                        myScene2.myVibrateFlag = YES;
                                                                        NSLog(@"Turn On Vibrate");
                                                                    }
                                                                    return;
                                                                }]];
    }
    [myQuitAlertController addAction:[UIAlertAction actionWithTitle:@"Quit" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        exit(0);
    }]];
    [self showViewController:myQuitAlertController sender:nil];
}



- (IBAction)unwindToThisViewController:(UIStoryboardSegue *)unwindSegue
{
    NSLog(@"unwound to here");
}


-(void)myShowTimesUpController{
    [myScene2 removeAllChildren];
    [[myScene2 myDropPicturesTimer] invalidate];
//    [myCountdownTimer invalidate];
//    myCountdownTimer=nil;
    //    [myScene2 removeFromParent];
    UIAlertController *myQuitAlertController = [UIAlertController alertControllerWithTitle:@"Time's UP!" message:@"Do you want to Quit or Continue?" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *myCancelAction = [UIAlertAction actionWithTitle:@"Continue" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
//        [self myStartCountdownTimer];
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
    }];
    
    //Do something interesting here.
    
    
}


- (IBAction)myPlayGame: (id) sender withRandomImages: (BOOL)myRandomImagesFlag{
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(myShowQuitAlertController) name:@"quitnotifictaion" object:nil];
    
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
    [scene setMyResizeMethod:2];
    [scene setMyMusicURL:myTempURL];
    [scene setMyTestNumber:[NSNumber numberWithInt:100]];
    NSLog(@"Setting Test Number %@",scene.myTestNumber);
    [scene setMyTestInt:10];
    NSLog(@"Setting Test Int %d",scene.myTestInt);
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
    
    myScene2.mySceneImageSize = myWidth/4.0;
    
    myScene2.myImage1Flag=myImage1.isHighlighted?0:1;
    myScene2.myImage2Flag=myImage2.isHighlighted?0:1;
    myScene2.myImage3Flag=myImage3.isHighlighted?0:1;
    myScene2.myImage4Flag=myImage4.isHighlighted?0:1;
    myScene2.myImage5Flag=myImage5.isHighlighted?0:1;
 
//    NSLog(@"Flag 1 %d",myScene2.myImage1Flag);
//    NSLog(@"Flag 2 %d",myScene2.myImage2Flag);
//    NSLog(@"Flag 3 %d",myScene2.myImage3Flag);
//    NSLog(@"Flag 4 %d",myScene2.myImage4Flag);
//    NSLog(@"Flag 5 %d",myScene2.myImage5Flag);

    NSMutableArray *myTempArray = [[NSMutableArray alloc] init];
    if (myScene2.myImage1Flag == 1) {
        [myTempArray addObject:[NSNumber numberWithInt:1]];
    }
    
    if (myScene2.myImage2Flag == 1) {
        [myTempArray addObject:[NSNumber numberWithInt:2]];
    }
    if (myScene2.myImage3Flag == 1) {
        [myTempArray addObject:[NSNumber numberWithInt:3]];
    }
    if (myScene2.myImage4Flag == 1) {
        [myTempArray addObject:[NSNumber numberWithInt:4]];
    }
    if (myScene2.myImage5Flag == 1) {
        [myTempArray addObject:[NSNumber numberWithInt:5]];
    }

//    NSLog(@"Pictures Array %@",myTempArray);
    
    myScene2.myPicturesArray = [myTempArray copy];
    
    
    
    //
    // these are useless ?
//    myViewFromTheScene = skView;
    
    if (myRandomImagesFlag) {
        [scene setMyAllRandomImagesFlag:YES];
    } else {
        [scene setMyAllRandomImagesFlag:NO];
    }

    
}


- (IBAction)myPlayGameWithRandomPictures:(UIButton *)sender {
    [myScene2 setMyVibrateFlag:YES];
    [self myPlayGame:self withRandomImages:YES];
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
    myScene2.myMusicURL = myTempURL;
    //    NSLog(@"Media Item Title in DidPickMediaItems %@, Temp URL = %@",item.title ,myReallyTempURL);
    NSLog(@"Media Item Title in DidPickMediaItems %@, URL = %@",item.title ,item.assetURL);
    // let's get the song ready to play in the game
    [mediaPicker dismissViewControllerAnimated:YES completion:^{
        [[NSNotificationCenter defaultCenter] postNotificationName:@"musicselected" object:nil];
    }];
}



- (IBAction)SelectMusic:(UIButton *)sender {
    MPMediaPickerController *myMediaPickerController = [[MPMediaPickerController alloc] initWithMediaTypes:MPMediaTypeMusic];
//    MPMediaQuery *myMediaQuery = [MPMediaQuery songsQuery];
    [myMediaPickerController setDelegate:self];
    [myMediaPickerController setAllowsPickingMultipleItems:NO];
    [myMediaPickerController setShowsCloudItems:NO];
    [myMediaPickerController setPrompt:@"Pick a Song!"];
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

- (IBAction)removeMyImage1:(id)sender {
    if (myImage1.isHighlighted) {
        [myImage1 setHighlighted:NO];
    } else {
        [myImage1 setHighlighted:YES];
    }
}

- (IBAction)removeMyImage2:(id)sender {
    if (myImage2.isHighlighted) {
        [myImage2 setHighlighted:NO];
    } else {
        [myImage2 setHighlighted:YES];
    }
}

- (IBAction)removeMyImage3:(id)sender {
    if (myImage3.isHighlighted) {
        [myImage3 setHighlighted:NO];
    } else {
        [myImage3 setHighlighted:YES];
    }
}

- (IBAction)removeMyImage4:(id)sender {
    if (myImage4.isHighlighted) {
        [myImage4 setHighlighted:NO];
    } else {
        [myImage4 setHighlighted:YES];
    }
}

- (IBAction)removeMyImage5:(id)sender {
    if (myImage5.isHighlighted) {
        [myImage5 setHighlighted:NO];
    } else {
        [myImage5 setHighlighted:YES];
    }
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
