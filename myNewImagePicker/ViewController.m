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
    //
    
    
//    [skView setShowsFPS:YES];
//    [skView setShowsDrawCount:YES];
//    [skView setShowsNodeCount:YES];
//    [skView setShowsQuadCount:YES];
    
    //
    // rz set the images in the scene here
    //
    [scene setMySpriteImage1:myImage1.image];
    [scene setMySpriteImage2:myImage2.image];
    [scene setMySpriteImage3:myImage3.image];
    [scene setMySpriteImage4:myImage4.image];
    [scene setMySpriteImage5:myImage5.image];
    // Present the scene.
    [self setView:skView];
    
    [skView presentScene:scene];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view, typically from a nib.
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
