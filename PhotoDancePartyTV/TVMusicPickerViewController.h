//
//  TVMusicPickerViewController.h
//  PhotoDancePartyTV
//
//  Created by Robert Zimmelman.
//  Copyright © 2024 Robert Zimmelman. All rights reserved.
//

@import UIKit;
@import AVFoundation;
@import StoreKit;
@import MediaPlayer;

@protocol TVMusicPickerDelegate <NSObject>
- (void)musicPickerDidSelectSongWithURL:(NSURL *)url storeID:(NSString *)storeID title:(NSString *)title artist:(NSString *)artist isUserLibrary:(BOOL)isUserLibrary;
- (void)musicPickerDidCancel;
@end

@interface TVMusicPickerViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, AVAudioPlayerDelegate>

@property (weak, nonatomic) id<TVMusicPickerDelegate> delegate;

@end
