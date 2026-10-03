//
//  TVMusicPickerViewController.m
//  PhotoDancePartyTV
//
//  Created by Robert Zimmelman.
//  Copyright © 2024 Robert Zimmelman. All rights reserved.
//

#import "TVMusicPickerViewController.h"
#import "PhotoDancePartyTV-Swift.h"

@interface TVMusicPickerViewController ()
@property (strong, nonatomic) UISearchBar *searchBar;
@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) UIButton *cancelButton;
@property (strong, nonatomic) UISegmentedControl *segmentedControl;
@property (strong, nonatomic) UILabel *statusLabel;

@property (strong, nonatomic) NSMutableArray *demoSongItems;
@property (strong, nonatomic) NSMutableArray *userLibraryItems;
@property (strong, nonatomic) NSMutableArray *topSongsItems;
@property (strong, nonatomic) NSMutableArray *searchResults;

@property (strong, nonatomic) AVAudioPlayer *previewPlayer;
@property (strong, nonatomic) NSURLSessionDataTask *activeSearchTask;
@property (assign, nonatomic) NSInteger playingIndex;
@property (assign, nonatomic) BOOL hasAppleMusicSubscription;
@property (assign, nonatomic) BOOL showingSearchResults;
@property (assign, nonatomic) NSInteger selectedSegment;

@property (strong, nonatomic) NSLayoutConstraint *searchBarTopConstraint;
@property (strong, nonatomic) NSLayoutConstraint *tableViewTopToSearchBarConstraint;
@property (strong, nonatomic) NSLayoutConstraint *tableViewTopToSegmentConstraint;
@end

@implementation TVMusicPickerViewController

@synthesize delegate;

#pragma mark - View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor colorWithRed:0.05 green:0.0 blue:0.15 alpha:1.0];
    self.demoSongItems = [[NSMutableArray alloc] init];
    self.userLibraryItems = [[NSMutableArray alloc] init];
    self.topSongsItems = [[NSMutableArray alloc] init];
    self.searchResults = [[NSMutableArray alloc] init];
    self.playingIndex = -1;
    self.hasAppleMusicSubscription = NO;
    self.showingSearchResults = NO;
    self.selectedSegment = 0;

    [self setupUI];
    [self addBundledMusicEntry];
    [self checkAppleMusicSubscription];
    [self loadTopSongs];
    [self loadUserLibrary];
    [self updateDisplayForSelectedSegment];
}

- (void)dealloc {
    [self.previewPlayer stop];
    [self.activeSearchTask cancel];
}

#pragma mark - UI Setup

- (void)setupUI {
    // Title
    self.titleLabel = [[UILabel alloc] init];
    self.titleLabel.text = @"Select Music";
    self.titleLabel.font = [UIFont systemFontOfSize:48 weight:UIFontWeightBold];
    self.titleLabel.textColor = [UIColor colorWithRed:1.0 green:0.4 blue:0.6 alpha:1.0];
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.titleLabel];

    // Segmented control
    self.segmentedControl = [[UISegmentedControl alloc] initWithItems:@[@"Demo Song", @"My Library", @"Top Songs"]];
    self.segmentedControl.selectedSegmentIndex = 0;
    self.segmentedControl.translatesAutoresizingMaskIntoConstraints = NO;
    [self.segmentedControl addTarget:self action:@selector(segmentChanged:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:self.segmentedControl];

    // Search bar (only visible for Top Songs segment)
    self.searchBar = [[UISearchBar alloc] init];
    self.searchBar.placeholder = @"Search Apple Music...";
    self.searchBar.delegate = self;
    self.searchBar.translatesAutoresizingMaskIntoConstraints = NO;
    self.searchBar.hidden = YES;
    [self.view addSubview:self.searchBar];

    // Status label (for My Library messages)
    self.statusLabel = [[UILabel alloc] init];
    self.statusLabel.text = @"";
    self.statusLabel.font = [UIFont systemFontOfSize:30 weight:UIFontWeightMedium];
    self.statusLabel.textColor = [UIColor colorWithWhite:0.5 alpha:1.0];
    self.statusLabel.textAlignment = NSTextAlignmentCenter;
    self.statusLabel.numberOfLines = 0;
    self.statusLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.statusLabel.hidden = YES;
    [self.view addSubview:self.statusLabel];

    // Table view
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.rowHeight = 100;
    self.tableView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"MusicCell"];
    [self.view addSubview:self.tableView];

    // Cancel button
    self.cancelButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.cancelButton setTitle:@"Cancel" forState:UIControlStateNormal];
    self.cancelButton.titleLabel.font = [UIFont systemFontOfSize:36 weight:UIFontWeightMedium];
    [self.cancelButton setTitleColor:[UIColor colorWithWhite:0.8 alpha:1.0] forState:UIControlStateNormal];
    self.cancelButton.backgroundColor = [UIColor colorWithWhite:0.2 alpha:1.0];
    self.cancelButton.layer.cornerRadius = 16;
    self.cancelButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.cancelButton addTarget:self action:@selector(cancelTapped) forControlEvents:UIControlEventPrimaryActionTriggered];
    [self.view addSubview:self.cancelButton];

    // Search bar top constraint (to segmented control)
    self.searchBarTopConstraint = [self.searchBar.topAnchor constraintEqualToAnchor:self.segmentedControl.bottomAnchor constant:20];

    // Two mutually exclusive table view top constraints
    self.tableViewTopToSearchBarConstraint = [self.tableView.topAnchor constraintEqualToAnchor:self.searchBar.bottomAnchor constant:20];
    self.tableViewTopToSegmentConstraint = [self.tableView.topAnchor constraintEqualToAnchor:self.segmentedControl.bottomAnchor constant:20];

    // Layout
    [NSLayoutConstraint activateConstraints:@[
        [self.titleLabel.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor constant:20],
        [self.titleLabel.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],

        [self.segmentedControl.topAnchor constraintEqualToAnchor:self.titleLabel.bottomAnchor constant:20],
        [self.segmentedControl.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
        [self.segmentedControl.widthAnchor constraintLessThanOrEqualToAnchor:self.view.widthAnchor multiplier:0.7],

        self.searchBarTopConstraint,
        [self.searchBar.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:200],
        [self.searchBar.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-200],

        [self.statusLabel.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
        [self.statusLabel.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor],
        [self.statusLabel.widthAnchor constraintLessThanOrEqualToAnchor:self.view.widthAnchor multiplier:0.6],

        [self.tableView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:100],
        [self.tableView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-100],
        [self.tableView.bottomAnchor constraintEqualToAnchor:self.cancelButton.topAnchor constant:-20],

        [self.cancelButton.bottomAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.bottomAnchor constant:-20],
        [self.cancelButton.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
        [self.cancelButton.widthAnchor constraintEqualToConstant:300],
        [self.cancelButton.heightAnchor constraintEqualToConstant:80],
    ]];

    // Start with table connected to segment (search bar hidden)
    self.tableViewTopToSegmentConstraint.active = YES;
    self.tableViewTopToSearchBarConstraint.active = NO;
}

#pragma mark - Segment Control

- (void)segmentChanged:(UISegmentedControl *)sender {
    self.selectedSegment = sender.selectedSegmentIndex;
    [self.previewPlayer stop];
    self.playingIndex = -1;
    [self updateDisplayForSelectedSegment];
}

- (void)updateDisplayForSelectedSegment {
    self.statusLabel.hidden = YES;
    self.tableView.hidden = NO;

    if (self.selectedSegment == 2) {
        // Top Songs — show search bar
        self.searchBar.hidden = NO;
        self.tableViewTopToSegmentConstraint.active = NO;
        self.tableViewTopToSearchBarConstraint.active = YES;
    } else {
        // Demo Song or My Library — hide search bar
        self.searchBar.hidden = YES;
        self.tableViewTopToSearchBarConstraint.active = NO;
        self.tableViewTopToSegmentConstraint.active = YES;
    }

    [self reloadCurrentSegmentData];
    [self setNeedsFocusUpdate];
}

- (void)reloadCurrentSegmentData {
    [self.searchResults removeAllObjects];

    switch (self.selectedSegment) {
        case 0: // Demo Song
            [self.searchResults addObjectsFromArray:self.demoSongItems];
            break;
        case 1: // My Library
            if (self.userLibraryItems.count > 0) {
                [self.searchResults addObjectsFromArray:self.userLibraryItems];
                self.statusLabel.hidden = YES;
                self.tableView.hidden = NO;
            } else {
                self.statusLabel.hidden = NO;
                self.tableView.hidden = YES;
                // statusLabel text is set in loadUserLibrary based on auth status
                if (self.statusLabel.text.length == 0) {
                    self.statusLabel.text = @"Loading library...";
                }
            }
            break;
        case 2: // Top Songs
            if (self.showingSearchResults) {
                // Keep current search results
            } else {
                [self.searchResults addObjectsFromArray:self.topSongsItems];
            }
            break;
        default:
            break;
    }

    [self.tableView reloadData];
}

- (NSArray *)currentDataSource {
    return self.searchResults;
}

#pragma mark - Apple Music Subscription

- (void)checkAppleMusicSubscription {
    [SKCloudServiceController requestAuthorization:^(SKCloudServiceAuthorizationStatus status) {
        if (status == SKCloudServiceAuthorizationStatusAuthorized) {
            SKCloudServiceController *cloudController = [[SKCloudServiceController alloc] init];
            [cloudController requestCapabilitiesWithCompletionHandler:^(SKCloudServiceCapability capabilities, NSError *error) {
                if (!error && (capabilities & SKCloudServiceCapabilityMusicCatalogPlayback)) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        self.hasAppleMusicSubscription = YES;
                    });
                }
            }];
        }
    }];
}

#pragma mark - User Library (MusicKit)

- (void)loadUserLibrary {
    if (![MusicLibraryHelper isLibraryAvailable]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.statusLabel.text = @"Library access requires tvOS 16 or later.";
            if (self.selectedSegment == 1) {
                self.statusLabel.hidden = NO;
                self.tableView.hidden = YES;
            }
        });
        return;
    }

    [MusicLibraryHelper requestAuthorizationWithCompletion:^(BOOL authorized) {
        if (!authorized) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.statusLabel.text = @"Music library access not authorized.\nGo to Settings > Privacy to enable.";
                if (self.selectedSegment == 1) {
                    self.statusLabel.hidden = NO;
                    self.tableView.hidden = YES;
                }
            });
            return;
        }

        [MusicLibraryHelper fetchLibrarySongsWithCompletion:^(NSArray *songs) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.userLibraryItems removeAllObjects];
                if (songs && songs.count > 0) {
                    for (NSDictionary *song in songs) {
                        NSMutableDictionary *songEntry = [song mutableCopy];
                        songEntry[@"isBundled"] = @NO;
                        songEntry[@"isUserLibrary"] = @YES;
                        [self.userLibraryItems addObject:songEntry];
                    }
                    self.statusLabel.text = @"";
                } else {
                    self.statusLabel.text = @"No songs found in your library.";
                }

                if (self.selectedSegment == 1) {
                    [self reloadCurrentSegmentData];
                }
            });
        }];
    }];
}

#pragma mark - Top Songs (RSS Feed)

- (void)loadTopSongs {
    NSURL *rssURL = [NSURL URLWithString:@"https://itunes.apple.com/us/rss/topsongs/limit=25/json"];

    NSURLSessionDataTask *rssTask = [[NSURLSession sharedSession] dataTaskWithURL:rssURL completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error || !data) return;

        NSError *jsonError = nil;
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
        if (jsonError) return;

        NSDictionary *feed = json[@"feed"];
        NSArray *entries = feed[@"entry"];
        if (!entries) return;

        NSMutableArray *tempItems = [[NSMutableArray alloc] init];
        NSMutableArray *storeIDs = [[NSMutableArray alloc] init];

        for (NSDictionary *entry in entries) {
            NSMutableDictionary *item = [[NSMutableDictionary alloc] init];
            item[@"trackName"] = entry[@"im:name"][@"label"] ?: @"Unknown";
            item[@"artistName"] = entry[@"im:artist"][@"label"] ?: @"Unknown Artist";
            item[@"isBundled"] = @NO;
            item[@"isTopSong"] = @YES;

            NSString *storeID = entry[@"id"][@"attributes"][@"im:id"];
            if (storeID) {
                item[@"storeID"] = storeID;
                [storeIDs addObject:storeID];
            }

            NSArray *images = entry[@"im:image"];
            if (images.count > 0) {
                NSString *artworkURL = [images lastObject][@"label"];
                if (artworkURL) item[@"artworkUrl100"] = artworkURL;
            }

            [tempItems addObject:item];
        }

        // Batch lookup to get preview URLs
        if (storeIDs.count > 0) {
            NSString *idsString = [storeIDs componentsJoinedByString:@","];
            NSString *lookupURLString = [NSString stringWithFormat:@"https://itunes.apple.com/lookup?id=%@", idsString];
            NSURL *lookupURL = [NSURL URLWithString:lookupURLString];

            NSURLSessionDataTask *lookupTask = [[NSURLSession sharedSession] dataTaskWithURL:lookupURL completionHandler:^(NSData *lookupData, NSURLResponse *lookupResponse, NSError *lookupError) {
                NSMutableDictionary *previewMap = [[NSMutableDictionary alloc] init];
                if (!lookupError && lookupData) {
                    NSDictionary *lookupJSON = [NSJSONSerialization JSONObjectWithData:lookupData options:0 error:nil];
                    NSArray *lookupResults = lookupJSON[@"results"];
                    for (NSDictionary *result in lookupResults) {
                        NSNumber *trackId = result[@"trackId"];
                        NSString *previewUrl = result[@"previewUrl"];
                        if (trackId && previewUrl) {
                            previewMap[[trackId stringValue]] = previewUrl;
                        }
                    }
                }

                for (NSMutableDictionary *item in tempItems) {
                    NSString *sid = item[@"storeID"];
                    if (sid && previewMap[sid]) {
                        item[@"previewUrl"] = previewMap[sid];
                    }
                }

                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.topSongsItems removeAllObjects];
                    [self.topSongsItems addObjectsFromArray:tempItems];
                    if (self.selectedSegment == 2 && !self.showingSearchResults) {
                        [self reloadCurrentSegmentData];
                    }
                });
            }];
            [lookupTask resume];
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.topSongsItems removeAllObjects];
                [self.topSongsItems addObjectsFromArray:tempItems];
                if (self.selectedSegment == 2 && !self.showingSearchResults) {
                    [self reloadCurrentSegmentData];
                }
            });
        }
    }];
    [rssTask resume];
}

#pragma mark - Bundled Music

- (void)addBundledMusicEntry {
    NSDictionary *bundledEntry = @{
        @"trackName": @"Caution",
        @"artistName": @"Skrxlla",
        @"isBundled": @YES
    };
    [self.demoSongItems addObject:[bundledEntry mutableCopy]];
}

#pragma mark - UISearchBarDelegate

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    NSString *searchTerm = searchBar.text;
    if (searchTerm.length == 0) return;

    [self searchiTunesWithTerm:searchTerm];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    if (searchText.length == 0) {
        self.showingSearchResults = NO;
        [self reloadCurrentSegmentData];
    }
}

#pragma mark - iTunes Search

- (void)searchiTunesWithTerm:(NSString *)term {
    [self.activeSearchTask cancel];

    NSString *encodedTerm = [term stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    NSString *urlString = [NSString stringWithFormat:@"https://itunes.apple.com/search?term=%@&media=music&limit=25", encodedTerm];
    NSURL *searchURL = [NSURL URLWithString:urlString];

    self.activeSearchTask = [[NSURLSession sharedSession] dataTaskWithURL:searchURL completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error || !data) return;

        NSError *jsonError = nil;
        NSDictionary *jsonResponse = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
        if (jsonError) return;

        NSArray *results = jsonResponse[@"results"];
        if (!results) return;

        dispatch_async(dispatch_get_main_queue(), ^{
            self.showingSearchResults = YES;
            [self.searchResults removeAllObjects];

            for (NSDictionary *result in results) {
                NSMutableDictionary *entry = [[NSMutableDictionary alloc] init];
                entry[@"trackName"] = result[@"trackName"] ?: @"Unknown";
                entry[@"artistName"] = result[@"artistName"] ?: @"Unknown Artist";
                entry[@"artworkUrl100"] = result[@"artworkUrl100"] ?: @"";
                entry[@"previewUrl"] = result[@"previewUrl"] ?: @"";
                entry[@"trackId"] = result[@"trackId"] ?: @"";
                entry[@"isBundled"] = @NO;
                entry[@"isSearchResult"] = @YES;
                [self.searchResults addObject:entry];
            }

            [self.tableView reloadData];
        });
    }];
    [self.activeSearchTask resume];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.searchResults.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MusicCell" forIndexPath:indexPath];

    // Clear previous content
    for (UIView *subview in cell.contentView.subviews) {
        [subview removeFromSuperview];
    }

    cell.backgroundColor = [UIColor colorWithWhite:0.1 alpha:0.8];
    cell.selectionStyle = UITableViewCellSelectionStyleDefault;

    NSDictionary *songInfo = self.searchResults[indexPath.row];
    BOOL isBundled = [songInfo[@"isBundled"] boolValue];

    // Artwork placeholder
    UIView *artworkContainer = [[UIView alloc] initWithFrame:CGRectMake(20, 10, 80, 80)];
    artworkContainer.backgroundColor = [UIColor colorWithWhite:0.2 alpha:1.0];
    artworkContainer.layer.cornerRadius = 12;
    artworkContainer.clipsToBounds = YES;
    [cell.contentView addSubview:artworkContainer];

    if (isBundled) {
        UILabel *bundledIcon = [[UILabel alloc] initWithFrame:artworkContainer.bounds];
        bundledIcon.text = @"🎵";
        bundledIcon.font = [UIFont systemFontOfSize:40];
        bundledIcon.textAlignment = NSTextAlignmentCenter;
        [artworkContainer addSubview:bundledIcon];
    } else {
        NSString *artworkURLString = songInfo[@"artworkUrl100"];
        if (artworkURLString.length > 0) {
            NSURL *artworkURL = [NSURL URLWithString:artworkURLString];
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                NSData *imageData = [NSData dataWithContentsOfURL:artworkURL];
                if (imageData) {
                    UIImage *artworkImage = [UIImage imageWithData:imageData];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        UITableViewCell *updateCell = [tableView cellForRowAtIndexPath:indexPath];
                        if (updateCell) {
                            UIImageView *artworkImageView = [[UIImageView alloc] initWithFrame:artworkContainer.bounds];
                            artworkImageView.image = artworkImage;
                            artworkImageView.contentMode = UIViewContentModeScaleAspectFill;
                            artworkImageView.clipsToBounds = YES;
                            [artworkContainer addSubview:artworkImageView];
                        }
                    });
                }
            });
        }
    }

    // Title label
    UILabel *trackLabel = [[UILabel alloc] initWithFrame:CGRectMake(120, 15, cell.contentView.bounds.size.width - 160, 40)];
    trackLabel.text = songInfo[@"trackName"];
    trackLabel.font = [UIFont systemFontOfSize:32 weight:UIFontWeightSemibold];
    trackLabel.textColor = [UIColor whiteColor];
    [cell.contentView addSubview:trackLabel];

    // Artist label
    UILabel *artistLabel = [[UILabel alloc] initWithFrame:CGRectMake(120, 55, cell.contentView.bounds.size.width - 160, 30)];
    artistLabel.text = songInfo[@"artistName"];
    artistLabel.font = [UIFont systemFontOfSize:26 weight:UIFontWeightRegular];
    artistLabel.textColor = [UIColor colorWithWhite:0.6 alpha:1.0];
    [cell.contentView addSubview:artistLabel];

    // Badges
    if (isBundled) {
        UILabel *bundledBadge = [[UILabel alloc] initWithFrame:CGRectMake(cell.contentView.bounds.size.width - 250, 30, 200, 40)];
        bundledBadge.text = @"BUNDLED";
        bundledBadge.font = [UIFont systemFontOfSize:22 weight:UIFontWeightBold];
        bundledBadge.textColor = [UIColor colorWithRed:0.2 green:0.78 blue:0.35 alpha:1.0];
        bundledBadge.textAlignment = NSTextAlignmentRight;
        [cell.contentView addSubview:bundledBadge];
    } else if ([songInfo[@"isUserLibrary"] boolValue]) {
        UILabel *libraryBadge = [[UILabel alloc] initWithFrame:CGRectMake(cell.contentView.bounds.size.width - 250, 30, 200, 40)];
        libraryBadge.text = @"MY LIBRARY";
        libraryBadge.font = [UIFont systemFontOfSize:20 weight:UIFontWeightBold];
        libraryBadge.textColor = [UIColor colorWithRed:0.6 green:0.4 blue:0.98 alpha:1.0];
        libraryBadge.textAlignment = NSTextAlignmentRight;
        [cell.contentView addSubview:libraryBadge];
    } else if ([songInfo[@"isTopSong"] boolValue]) {
        UILabel *topSongBadge = [[UILabel alloc] initWithFrame:CGRectMake(cell.contentView.bounds.size.width - 250, 30, 200, 40)];
        topSongBadge.text = @"TOP SONGS";
        topSongBadge.font = [UIFont systemFontOfSize:20 weight:UIFontWeightBold];
        topSongBadge.textColor = [UIColor colorWithRed:0.2 green:0.78 blue:0.98 alpha:1.0];
        topSongBadge.textAlignment = NSTextAlignmentRight;
        [cell.contentView addSubview:topSongBadge];
    } else if (self.hasAppleMusicSubscription && songInfo[@"trackId"]) {
        UILabel *appleMusicBadge = [[UILabel alloc] initWithFrame:CGRectMake(cell.contentView.bounds.size.width - 300, 30, 250, 40)];
        appleMusicBadge.text = @"APPLE MUSIC";
        appleMusicBadge.font = [UIFont systemFontOfSize:20 weight:UIFontWeightBold];
        appleMusicBadge.textColor = [UIColor colorWithRed:1.0 green:0.4 blue:0.6 alpha:1.0];
        appleMusicBadge.textAlignment = NSTextAlignmentRight;
        [cell.contentView addSubview:appleMusicBadge];
    }

    // Playing indicator
    if (indexPath.row == self.playingIndex) {
        UILabel *playingLabel = [[UILabel alloc] initWithFrame:CGRectMake(cell.contentView.bounds.size.width - 250, 30, 200, 40)];
        playingLabel.text = @"♪ Playing";
        playingLabel.font = [UIFont systemFontOfSize:24 weight:UIFontWeightMedium];
        playingLabel.textColor = [UIColor colorWithRed:1.0 green:0.4 blue:0.6 alpha:1.0];
        playingLabel.textAlignment = NSTextAlignmentRight;
        [cell.contentView addSubview:playingLabel];
    }

    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    NSDictionary *songInfo = self.searchResults[indexPath.row];
    BOOL isBundled = [songInfo[@"isBundled"] boolValue];

    if (isBundled) {
        [self.previewPlayer stop];
        self.playingIndex = -1;
        [self dismissViewControllerAnimated:YES completion:^{
            [self.delegate musicPickerDidSelectSongWithURL:nil storeID:nil title:@"Caution" artist:@"Skrxlla" isUserLibrary:NO];
        }];
        return;
    }

    NSString *trackName = songInfo[@"trackName"];
    NSString *artistName = songInfo[@"artistName"];

    // User library item — play via storeID (user owns it)
    if ([songInfo[@"isUserLibrary"] boolValue]) {
        NSString *libraryStoreID = songInfo[@"storeID"];
        [self.previewPlayer stop];
        self.playingIndex = -1;

        [self dismissViewControllerAnimated:YES completion:^{
            [self.delegate musicPickerDidSelectSongWithURL:nil storeID:libraryStoreID title:trackName artist:artistName isUserLibrary:YES];
        }];
        return;
    }

    // Top song item — use preview URL, or Apple Music store ID if subscribed
    if ([songInfo[@"isTopSong"] boolValue]) {
        NSString *topSongStoreID = songInfo[@"storeID"];
        NSString *topSongPreviewURL = songInfo[@"previewUrl"];
        [self.previewPlayer stop];
        self.playingIndex = -1;

        NSURL *previewURL = topSongPreviewURL.length > 0 ? [NSURL URLWithString:topSongPreviewURL] : nil;
        NSString *passedStoreID = self.hasAppleMusicSubscription ? topSongStoreID : nil;

        [self dismissViewControllerAnimated:YES completion:^{
            [self.delegate musicPickerDidSelectSongWithURL:previewURL storeID:passedStoreID title:trackName artist:artistName isUserLibrary:NO];
        }];
        return;
    }

    // iTunes/Apple Music search result
    NSString *previewURLString = songInfo[@"previewUrl"];
    NSNumber *trackIdNumber = songInfo[@"trackId"];
    NSString *storeID = ([trackIdNumber isKindOfClass:[NSNumber class]]) ? [trackIdNumber stringValue] : nil;

    if (previewURLString.length > 0) {
        [self playPreviewAtURL:[NSURL URLWithString:previewURLString] forIndex:indexPath.row];
    }

    UIAlertController *selectionAlert = [UIAlertController alertControllerWithTitle:trackName
                                                                           message:[NSString stringWithFormat:@"by %@", artistName]
                                                                    preferredStyle:UIAlertControllerStyleAlert];

    if (self.hasAppleMusicSubscription && storeID) {
        [selectionAlert addAction:[UIAlertAction actionWithTitle:@"Play Full Song (Apple Music)" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [self.previewPlayer stop];
            [self dismissViewControllerAnimated:YES completion:^{
                [self.delegate musicPickerDidSelectSongWithURL:nil storeID:storeID title:trackName artist:artistName isUserLibrary:NO];
            }];
        }]];
    }

    if (previewURLString.length > 0) {
        NSString *previewTitle = self.hasAppleMusicSubscription ? @"Use 30-Second Preview" : @"Use This Song (30s Preview)";
        [selectionAlert addAction:[UIAlertAction actionWithTitle:previewTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            NSURL *previewURL = [NSURL URLWithString:previewURLString];
            [self.previewPlayer stop];
            [self dismissViewControllerAnimated:YES completion:^{
                [self.delegate musicPickerDidSelectSongWithURL:previewURL storeID:nil title:trackName artist:artistName isUserLibrary:NO];
            }];
        }]];
    }

    [selectionAlert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        [self.previewPlayer stop];
        self.playingIndex = -1;
        [self.tableView reloadData];
    }]];

    [self presentViewController:selectionAlert animated:YES completion:nil];
}

- (void)didUpdateFocusInContext:(UIFocusUpdateContext *)context withAnimationCoordinator:(UIFocusAnimationCoordinator *)coordinator {
    if ([context.previouslyFocusedView isKindOfClass:[UITableViewCell class]]) {
        [coordinator addCoordinatedAnimations:^{
            context.previouslyFocusedView.transform = CGAffineTransformIdentity;
            context.previouslyFocusedView.backgroundColor = [UIColor colorWithWhite:0.1 alpha:0.8];
        } completion:nil];
    }

    if ([context.nextFocusedView isKindOfClass:[UITableViewCell class]]) {
        [coordinator addCoordinatedAnimations:^{
            context.nextFocusedView.transform = CGAffineTransformMakeScale(1.02, 1.02);
            context.nextFocusedView.backgroundColor = [UIColor colorWithWhite:0.2 alpha:0.9];
        } completion:nil];
    }
}

#pragma mark - Audio Preview

- (void)playPreviewAtURL:(NSURL *)previewURL forIndex:(NSInteger)index {
    [self.previewPlayer stop];

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSData *audioData = [NSData dataWithContentsOfURL:previewURL];
        if (!audioData) return;

        dispatch_async(dispatch_get_main_queue(), ^{
            NSError *playerError = nil;
            self.previewPlayer = [[AVAudioPlayer alloc] initWithData:audioData error:&playerError];
            if (!playerError) {
                self.previewPlayer.delegate = self;
                [self.previewPlayer play];
                self.playingIndex = index;
                [self.tableView reloadData];
            }
        });
    });
}

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    self.playingIndex = -1;
    [self.tableView reloadData];
}

#pragma mark - Actions

- (void)cancelTapped {
    [self.previewPlayer stop];
    [self dismissViewControllerAnimated:YES completion:^{
        [self.delegate musicPickerDidCancel];
    }];
}

#pragma mark - Focus

- (NSArray<id<UIFocusEnvironment>> *)preferredFocusEnvironments {
    if (self.tableView && !self.tableView.hidden && self.searchResults.count > 0) {
        return @[self.tableView];
    }
    if (self.segmentedControl) {
        return @[self.segmentedControl];
    }
    return @[];
}

@end
