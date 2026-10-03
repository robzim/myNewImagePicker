//
//  TVMusicPickerViewController.h
//  TV Photo Chaos
//
//  tvOS Apple Music picker using MusicKit
//  Allows users to search and select songs from Apple Music
//
//  Created by Robert Zimmelman.
//  Copyright (c) 2024 Robert Zimmelman. All rights reserved.
//

@import UIKit;
@import StoreKit;
@import MediaPlayer;

@protocol TVMusicPickerDelegate <NSObject>
- (void)musicPickerDidSelectSongWithURL:(NSURL *)url title:(NSString *)title artist:(NSString *)artist;
- (void)musicPickerDidCancel;
@end

@interface TVMusicPickerViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate>

@property (weak, nonatomic) id<TVMusicPickerDelegate> delegate;

// UI Elements
@property (strong, nonatomic) UISearchBar *searchBar;
@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) UIActivityIndicatorView *loadingIndicator;
@property (strong, nonatomic) UILabel *statusLabel;

// Search results
@property (strong, nonatomic) NSMutableArray *searchResults;

// Authorization
- (void)requestMusicAuthorization;
- (BOOL)isMusicAuthorized;

// Search
- (void)searchForSongs:(NSString *)query;

@end
