//
//  TVMusicPickerViewController.m
//  TV Photo Chaos
//
//  tvOS Apple Music picker using MusicKit
//  Allows users to search and select songs from Apple Music
//
//  Created by Robert Zimmelman.
//  Copyright (c) 2024 Robert Zimmelman. All rights reserved.
//

#import "TVMusicPickerViewController.h"
@import MediaPlayer;
@import StoreKit;

// Simple model class for search results
@interface TVMusicSearchResult : NSObject
@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) NSString *artist;
@property (strong, nonatomic) NSString *albumTitle;
@property (strong, nonatomic) UIImage *artwork;
@property (strong, nonatomic) NSString *musicID;
@property (strong, nonatomic) NSURL *previewURL;
@end

@implementation TVMusicSearchResult
@end

@interface TVMusicPickerViewController ()
@property (strong, nonatomic) NSURLSession *urlSession;
@property (strong, nonatomic) NSString *developerToken;
@property (strong, nonatomic) NSString *userToken;
@property (nonatomic) BOOL isSearching;
@end

@implementation TVMusicPickerViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor blackColor];
    self.searchResults = [NSMutableArray array];
    self.urlSession = [NSURLSession sharedSession];

    [self setupUI];
    [self requestMusicAuthorization];
}

- (void)setupUI {
    CGFloat screenWidth = self.view.bounds.size.width;
    CGFloat screenHeight = self.view.bounds.size.height;

    // Title label
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 60, screenWidth, 60)];
    titleLabel.text = @"Select Music";
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.font = [UIFont boldSystemFontOfSize:48];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:titleLabel];

    // Search bar
    self.searchBar = [[UISearchBar alloc] init];
    self.searchBar.frame = CGRectMake(100, 140, screenWidth - 200, 80);
    self.searchBar.placeholder = @"Search Apple Music";
    self.searchBar.delegate = self;
    self.searchBar.searchBarStyle = UISearchBarStyleMinimal;
    self.searchBar.keyboardAppearance = UIKeyboardAppearanceDark;
    [self.view addSubview:self.searchBar];

    // Status label
    self.statusLabel = [[UILabel alloc] initWithFrame:CGRectMake(100, 230, screenWidth - 200, 40)];
    self.statusLabel.textColor = [UIColor lightGrayColor];
    self.statusLabel.font = [UIFont systemFontOfSize:24];
    self.statusLabel.textAlignment = NSTextAlignmentCenter;
    self.statusLabel.text = @"Search for songs or use bundled music";
    [self.view addSubview:self.statusLabel];

    // Loading indicator
    self.loadingIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleLarge];
    self.loadingIndicator.center = CGPointMake(screenWidth / 2, 250);
    self.loadingIndicator.color = [UIColor whiteColor];
    self.loadingIndicator.hidesWhenStopped = YES;
    [self.view addSubview:self.loadingIndicator];

    // Table view for results
    CGFloat tableTop = 280;
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(100, tableTop, screenWidth - 200, screenHeight - tableTop - 150) style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.rowHeight = 100;
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"MusicCell"];
    [self.view addSubview:self.tableView];

    // Add "Use Bundled Music" option at top
    [self addBundledMusicOption];

    // Cancel button at bottom
    UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeSystem];
    cancelButton.frame = CGRectMake((screenWidth - 300) / 2, screenHeight - 120, 300, 60);
    [cancelButton setTitle:@"Cancel" forState:UIControlStateNormal];
    cancelButton.titleLabel.font = [UIFont systemFontOfSize:32];
    [cancelButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [cancelButton addTarget:self action:@selector(cancelButtonPressed) forControlEvents:UIControlEventPrimaryActionTriggered];
    [self.view addSubview:cancelButton];
}

- (void)addBundledMusicOption {
    // Add bundled music as first option
    TVMusicSearchResult *bundledOption = [[TVMusicSearchResult alloc] init];
    bundledOption.title = @"Caution (Bundled)";
    bundledOption.artist = @"Skrxlla";
    bundledOption.albumTitle = @"Default Music";
    bundledOption.musicID = @"bundled";
    [self.searchResults addObject:bundledOption];
    [self.tableView reloadData];
}

#pragma mark - Music Authorization

- (void)requestMusicAuthorization {
    if (@available(tvOS 15.0, *)) {
        // Request MusicKit authorization
        SKCloudServiceController *controller = [[SKCloudServiceController alloc] init];
        [SKCloudServiceController requestAuthorization:^(SKCloudServiceAuthorizationStatus status) {
            dispatch_async(dispatch_get_main_queue(), ^{
                switch (status) {
                    case SKCloudServiceAuthorizationStatusAuthorized:
                        self.statusLabel.text = @"Search for songs or use bundled music";
                        [self getUserToken];
                        break;
                    case SKCloudServiceAuthorizationStatusDenied:
                        self.statusLabel.text = @"Apple Music access denied - using bundled music";
                        self.searchBar.userInteractionEnabled = NO;
                        break;
                    case SKCloudServiceAuthorizationStatusRestricted:
                        self.statusLabel.text = @"Apple Music restricted - using bundled music";
                        self.searchBar.userInteractionEnabled = NO;
                        break;
                    case SKCloudServiceAuthorizationStatusNotDetermined:
                        self.statusLabel.text = @"Please authorize Apple Music access";
                        break;
                }
            });
        }];
    } else {
        // Fallback for older tvOS
        self.statusLabel.text = @"Apple Music requires tvOS 15+ - using bundled music";
        self.searchBar.userInteractionEnabled = NO;
    }
}

- (BOOL)isMusicAuthorized {
    if (@available(tvOS 15.0, *)) {
        return [SKCloudServiceController authorizationStatus] == SKCloudServiceAuthorizationStatusAuthorized;
    }
    return NO;
}

- (void)getUserToken {
    if (@available(tvOS 15.0, *)) {
        SKCloudServiceController *controller = [[SKCloudServiceController alloc] init];

        // First check capabilities
        [controller requestCapabilitiesWithCompletionHandler:^(SKCloudServiceCapability capabilities, NSError *error) {
            if (error) {
                NSLog(@"Error checking capabilities: %@", error);
                return;
            }

            BOOL canPlayCatalog = (capabilities & SKCloudServiceCapabilityMusicCatalogPlayback) != 0;
            BOOL hasSubscription = (capabilities & SKCloudServiceCapabilityMusicCatalogSubscriptionEligible) != 0;

            dispatch_async(dispatch_get_main_queue(), ^{
                if (canPlayCatalog) {
                    self.statusLabel.text = @"Apple Music ready - search for songs";
                } else if (hasSubscription) {
                    self.statusLabel.text = @"Subscribe to Apple Music to search songs";
                } else {
                    self.statusLabel.text = @"Apple Music subscription needed for search";
                }
            });
        }];

        // Get user token for API requests
        [controller requestUserTokenForDeveloperToken:self.developerToken completionHandler:^(NSString *userToken, NSError *error) {
            if (userToken) {
                self.userToken = userToken;
            } else if (error) {
                NSLog(@"Error getting user token: %@", error);
            }
        }];
    }
}

#pragma mark - Search

- (void)searchForSongs:(NSString *)query {
    if (query.length < 2) {
        return;
    }

    self.isSearching = YES;
    [self.loadingIndicator startAnimating];
    self.statusLabel.text = @"Searching...";

    // Clear previous results but keep bundled option
    [self.searchResults removeAllObjects];
    [self addBundledMusicOption];

    // Use Apple Music API to search
    // Note: This requires a valid developer token from Apple Music API
    // For now, we'll use the iTunes Search API which is free and doesn't require authentication

    NSString *encodedQuery = [query stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    NSString *urlString = [NSString stringWithFormat:@"https://itunes.apple.com/search?term=%@&media=music&entity=song&limit=20", encodedQuery];
    NSURL *url = [NSURL URLWithString:urlString];

    NSURLSessionDataTask *task = [self.urlSession dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.isSearching = NO;
            [self.loadingIndicator stopAnimating];

            if (error) {
                self.statusLabel.text = [NSString stringWithFormat:@"Search error: %@", error.localizedDescription];
                return;
            }

            NSError *jsonError;
            NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];

            if (jsonError) {
                self.statusLabel.text = @"Error parsing results";
                return;
            }

            NSArray *results = json[@"results"];

            if (results.count == 0) {
                self.statusLabel.text = @"No results found";
                return;
            }

            self.statusLabel.text = [NSString stringWithFormat:@"Found %lu songs", (unsigned long)results.count];

            for (NSDictionary *item in results) {
                TVMusicSearchResult *result = [[TVMusicSearchResult alloc] init];
                result.title = item[@"trackName"] ?: @"Unknown Title";
                result.artist = item[@"artistName"] ?: @"Unknown Artist";
                result.albumTitle = item[@"collectionName"] ?: @"Unknown Album";
                result.musicID = [item[@"trackId"] stringValue] ?: @"";

                // Preview URL for 30-second clips (free, no subscription needed)
                NSString *previewURLString = item[@"previewUrl"];
                if (previewURLString) {
                    result.previewURL = [NSURL URLWithString:previewURLString];
                }

                // Load artwork asynchronously
                NSString *artworkURL = item[@"artworkUrl100"];
                if (artworkURL) {
                    // Replace 100x100 with larger size
                    artworkURL = [artworkURL stringByReplacingOccurrencesOfString:@"100x100" withString:@"200x200"];
                    [self loadArtworkFromURL:artworkURL forResult:result];
                }

                [self.searchResults addObject:result];
            }

            [self.tableView reloadData];
        });
    }];

    [task resume];
}

- (void)loadArtworkFromURL:(NSString *)urlString forResult:(TVMusicSearchResult *)result {
    NSURL *url = [NSURL URLWithString:urlString];

    NSURLSessionDataTask *task = [self.urlSession dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (data && !error) {
            UIImage *image = [UIImage imageWithData:data];
            dispatch_async(dispatch_get_main_queue(), ^{
                result.artwork = image;
                // Find and update the cell
                NSUInteger index = [self.searchResults indexOfObject:result];
                if (index != NSNotFound) {
                    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
                    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
                    if (cell) {
                        cell.imageView.image = image;
                        [cell setNeedsLayout];
                    }
                }
            });
        }
    }];

    [task resume];
}

#pragma mark - UISearchBarDelegate

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
    [self searchForSongs:searchBar.text];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    // Optional: implement real-time search with debouncing
    if (searchText.length == 0) {
        [self.searchResults removeAllObjects];
        [self addBundledMusicOption];
        [self.tableView reloadData];
        self.statusLabel.text = @"Search for songs or use bundled music";
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.searchResults.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MusicCell" forIndexPath:indexPath];

    TVMusicSearchResult *result = self.searchResults[indexPath.row];

    // Configure cell for tvOS focus appearance
    cell.backgroundColor = [UIColor clearColor];
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.textLabel.font = [UIFont systemFontOfSize:28];
    cell.detailTextLabel.textColor = [UIColor lightGrayColor];
    cell.detailTextLabel.font = [UIFont systemFontOfSize:22];

    // Use subtitle style manually
    cell.textLabel.text = result.title;

    // Create attributed string for subtitle
    NSString *subtitle = [NSString stringWithFormat:@"%@ - %@", result.artist, result.albumTitle];

    // For bundled music, show special indicator
    if ([result.musicID isEqualToString:@"bundled"]) {
        cell.textLabel.text = [NSString stringWithFormat:@"🎵 %@", result.title];
        subtitle = [NSString stringWithFormat:@"%@ (Included with app)", result.artist];
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }

    // Set artwork or placeholder
    if (result.artwork) {
        cell.imageView.image = result.artwork;
    } else if ([result.musicID isEqualToString:@"bundled"]) {
        cell.imageView.image = [UIImage systemImageNamed:@"music.note"];
    } else {
        cell.imageView.image = [UIImage systemImageNamed:@"music.note.list"];
    }

    cell.imageView.contentMode = UIViewContentModeScaleAspectFit;
    cell.imageView.layer.cornerRadius = 8;
    cell.imageView.clipsToBounds = YES;

    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    TVMusicSearchResult *result = self.searchResults[indexPath.row];

    if ([result.musicID isEqualToString:@"bundled"]) {
        // Use bundled music
        NSString *bundledMusicPath = [[NSBundle mainBundle] pathForResource:@"Skrxlla - Caution" ofType:@"mp3"];
        NSURL *bundledURL = [NSURL fileURLWithPath:bundledMusicPath];

        if (bundledURL && self.delegate) {
            [self.delegate musicPickerDidSelectSongWithURL:bundledURL title:result.title artist:result.artist];
        }
    } else if (result.previewURL) {
        // Use preview URL (30-second clip)
        // Show alert explaining this is a preview
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Preview Mode"
                                                                       message:@"Without Apple Music subscription, only 30-second previews are available. The photo animation will loop with this preview."
                                                                preferredStyle:UIAlertControllerStyleAlert];

        UIAlertAction *useAction = [UIAlertAction actionWithTitle:@"Use Preview" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            if (self.delegate) {
                [self.delegate musicPickerDidSelectSongWithURL:result.previewURL title:result.title artist:result.artist];
            }
        }];

        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];

        [alert addAction:useAction];
        [alert addAction:cancelAction];

        [self presentViewController:alert animated:YES completion:nil];
    } else {
        // No URL available
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Unavailable"
                                                                       message:@"This song is not available for playback. Please try another song or use the bundled music."
                                                                preferredStyle:UIAlertControllerStyleAlert];

        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
        [alert addAction:okAction];

        [self presentViewController:alert animated:YES completion:nil];
    }
}

- (void)tableView:(UITableView *)tableView didUpdateFocusInContext:(UITableViewFocusUpdateContext *)context withAnimationCoordinator:(UIFocusAnimationCoordinator *)coordinator {
    // Animate focus changes for tvOS
    if (context.nextFocusedIndexPath) {
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:context.nextFocusedIndexPath];
        [coordinator addCoordinatedAnimations:^{
            cell.transform = CGAffineTransformMakeScale(1.05, 1.05);
            cell.backgroundColor = [UIColor colorWithWhite:0.2 alpha:1.0];
        } completion:nil];
    }

    if (context.previouslyFocusedIndexPath) {
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:context.previouslyFocusedIndexPath];
        [coordinator addCoordinatedAnimations:^{
            cell.transform = CGAffineTransformIdentity;
            cell.backgroundColor = [UIColor clearColor];
        } completion:nil];
    }
}

#pragma mark - Actions

- (void)cancelButtonPressed {
    if (self.delegate) {
        [self.delegate musicPickerDidCancel];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Focus Engine

- (UIView *)preferredFocusedView {
    // Start focus on search bar
    return self.searchBar;
}

- (NSArray<id<UIFocusEnvironment>> *)preferredFocusEnvironments {
    return @[self.searchBar];
}

@end
