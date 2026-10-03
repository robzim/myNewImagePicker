//
//  TVPhotoPickerViewController.m
//  TV Photo Chaos
//
//  tvOS photo picker for iCloud Photo Library
//  Grid-based selection of up to 5 photos
//
//  Created by Robert Zimmelman.
//  Copyright (c) 2024 Robert Zimmelman. All rights reserved.
//

#import "TVPhotoPickerViewController.h"

@interface TVPhotoPickerViewController ()
@property (strong, nonatomic) NSMutableDictionary<NSString *, UIImage *> *imageCache;
@property (strong, nonatomic) NSMutableSet<NSString *> *selectedIndexPaths;
@end

@implementation TVPhotoPickerViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor blackColor];
    self.maxSelection = 5;
    self.selectedAssets = [NSMutableArray array];
    self.selectedIndexPaths = [NSMutableSet set];
    self.imageCache = [NSMutableDictionary dictionary];

    // Calculate thumbnail size for TV
    CGFloat screenScale = [UIScreen mainScreen].scale;
    self.thumbnailSize = CGSizeMake(300 * screenScale, 300 * screenScale);

    self.imageManager = [PHImageManager defaultManager];
    self.cachingImageManager = [[PHCachingImageManager alloc] init];

    [self setupUI];
    [self requestPhotoLibraryAccess];

    // Register for photo library changes
    [[PHPhotoLibrary sharedPhotoLibrary] registerChangeObserver:self];
}

- (void)dealloc {
    [[PHPhotoLibrary sharedPhotoLibrary] unregisterChangeObserver:self];
}

- (void)setupUI {
    CGFloat screenWidth = self.view.bounds.size.width;
    CGFloat screenHeight = self.view.bounds.size.height;

    // Title label
    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 40, screenWidth, 60)];
    self.titleLabel.text = @"Select Photos";
    self.titleLabel.textColor = [UIColor whiteColor];
    self.titleLabel.font = [UIFont boldSystemFontOfSize:48];
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:self.titleLabel];

    // Selection count label
    self.selectionCountLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 100, screenWidth, 40)];
    self.selectionCountLabel.text = @"Select up to 5 photos";
    self.selectionCountLabel.textColor = [UIColor lightGrayColor];
    self.selectionCountLabel.font = [UIFont systemFontOfSize:28];
    self.selectionCountLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:self.selectionCountLabel];

    // Loading indicator
    self.loadingIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleLarge];
    self.loadingIndicator.center = self.view.center;
    self.loadingIndicator.color = [UIColor whiteColor];
    self.loadingIndicator.hidesWhenStopped = YES;
    [self.view addSubview:self.loadingIndicator];

    // Collection view layout
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.itemSize = CGSizeMake(280, 280);
    layout.minimumInteritemSpacing = 30;
    layout.minimumLineSpacing = 30;
    layout.sectionInset = UIEdgeInsetsMake(20, 80, 20, 80);
    layout.scrollDirection = UICollectionViewScrollDirectionVertical;

    // Collection view
    CGFloat collectionTop = 150;
    CGFloat collectionHeight = screenHeight - collectionTop - 120;
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, collectionTop, screenWidth, collectionHeight) collectionViewLayout:layout];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.backgroundColor = [UIColor clearColor];
    self.collectionView.allowsMultipleSelection = YES;
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"PhotoCell"];
    [self.view addSubview:self.collectionView];

    // Bottom button bar
    CGFloat buttonY = screenHeight - 100;
    CGFloat buttonWidth = 250;
    CGFloat buttonSpacing = 50;
    CGFloat totalWidth = buttonWidth * 2 + buttonSpacing;
    CGFloat startX = (screenWidth - totalWidth) / 2;

    // Cancel button
    self.cancelButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.cancelButton.frame = CGRectMake(startX, buttonY, buttonWidth, 60);
    [self.cancelButton setTitle:@"Cancel" forState:UIControlStateNormal];
    self.cancelButton.titleLabel.font = [UIFont systemFontOfSize:32];
    [self.cancelButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [self.cancelButton addTarget:self action:@selector(cancelButtonPressed) forControlEvents:UIControlEventPrimaryActionTriggered];
    [self.view addSubview:self.cancelButton];

    // Done button
    self.doneButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.doneButton.frame = CGRectMake(startX + buttonWidth + buttonSpacing, buttonY, buttonWidth, 60);
    [self.doneButton setTitle:@"Done" forState:UIControlStateNormal];
    self.doneButton.titleLabel.font = [UIFont boldSystemFontOfSize:32];
    [self.doneButton setTitleColor:[UIColor systemGreenColor] forState:UIControlStateNormal];
    [self.doneButton addTarget:self action:@selector(doneButtonPressed) forControlEvents:UIControlEventPrimaryActionTriggered];
    self.doneButton.enabled = NO;
    self.doneButton.alpha = 0.5;
    [self.view addSubview:self.doneButton];
}

#pragma mark - Photo Library Access

- (void)requestPhotoLibraryAccess {
    [self.loadingIndicator startAnimating];

    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];

    switch (status) {
        case PHAuthorizationStatusAuthorized:
        case PHAuthorizationStatusLimited: {
            [self loadPhotos];
            break;
        }

        case PHAuthorizationStatusNotDetermined: {
            [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus newStatus) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (newStatus == PHAuthorizationStatusAuthorized || newStatus == PHAuthorizationStatusLimited) {
                        [self loadPhotos];
                    } else {
                        [self showAccessDeniedAlert];
                    }
                });
            }];
            break;
        }

        case PHAuthorizationStatusDenied:
        case PHAuthorizationStatusRestricted: {
            [self showAccessDeniedAlert];
            break;
        }

        default:
            break;
    }
}

- (void)showAccessDeniedAlert {
    [self.loadingIndicator stopAnimating];

    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Photo Access Required"
                                                                   message:@"Please allow access to your photos in Settings to select custom photos for the dance party."
                                                            preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self cancelButtonPressed];
    }];

    [alert addAction:okAction];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)loadPhotos {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        PHFetchOptions *options = [[PHFetchOptions alloc] init];
        options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO]];
        options.predicate = [NSPredicate predicateWithFormat:@"mediaType == %d", PHAssetMediaTypeImage];

        self.allPhotos = [PHAsset fetchAssetsWithMediaType:PHAssetMediaTypeImage options:options];

        dispatch_async(dispatch_get_main_queue(), ^{
            [self.loadingIndicator stopAnimating];

            if (self.allPhotos.count == 0) {
                self.selectionCountLabel.text = @"No photos found in your library";
            } else {
                self.selectionCountLabel.text = [NSString stringWithFormat:@"Select up to %ld photos (%lu available)", (long)self.maxSelection, (unsigned long)self.allPhotos.count];
            }

            [self.collectionView reloadData];

            // Start caching thumbnails for visible items
            [self startCachingImages];
        });
    });
}

- (void)startCachingImages {
    if (self.allPhotos.count == 0) return;

    // Cache first 50 images
    NSInteger cacheCount = MIN(50, self.allPhotos.count);
    NSMutableArray *assetsToCache = [NSMutableArray array];

    for (NSInteger i = 0; i < cacheCount; i++) {
        [assetsToCache addObject:[self.allPhotos objectAtIndex:i]];
    }

    PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
    options.deliveryMode = PHImageRequestOptionsDeliveryModeOpportunistic;
    options.resizeMode = PHImageRequestOptionsResizeModeFast;

    [self.cachingImageManager startCachingImagesForAssets:assetsToCache
                                               targetSize:self.thumbnailSize
                                              contentMode:PHImageContentModeAspectFill
                                                  options:options];
}

#pragma mark - PHPhotoLibraryChangeObserver

- (void)photoLibraryDidChange:(PHChange *)changeInstance {
    dispatch_async(dispatch_get_main_queue(), ^{
        PHFetchResultChangeDetails *changes = [changeInstance changeDetailsForFetchResult:self.allPhotos];
        if (changes) {
            self.allPhotos = changes.fetchResultAfterChanges;
            [self.collectionView reloadData];
        }
    });
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.allPhotos.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"PhotoCell" forIndexPath:indexPath];

    // Configure cell appearance
    cell.backgroundColor = [UIColor darkGrayColor];
    cell.layer.cornerRadius = 12;
    cell.clipsToBounds = YES;

    // Get or create image view
    UIImageView *imageView = [cell viewWithTag:100];
    if (!imageView) {
        imageView = [[UIImageView alloc] initWithFrame:cell.contentView.bounds];
        imageView.tag = 100;
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.clipsToBounds = YES;
        imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [cell.contentView addSubview:imageView];
    }

    // Get or create selection indicator
    UIView *selectionOverlay = [cell viewWithTag:101];
    if (!selectionOverlay) {
        selectionOverlay = [[UIView alloc] initWithFrame:cell.contentView.bounds];
        selectionOverlay.tag = 101;
        selectionOverlay.backgroundColor = [UIColor colorWithRed:0 green:0.8 blue:0.4 alpha:0.4];
        selectionOverlay.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        selectionOverlay.hidden = YES;

        // Checkmark
        UIImageView *checkmark = [[UIImageView alloc] initWithImage:[UIImage systemImageNamed:@"checkmark.circle.fill"]];
        checkmark.tintColor = [UIColor whiteColor];
        checkmark.frame = CGRectMake(cell.contentView.bounds.size.width - 50, 10, 40, 40);
        checkmark.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin;
        [selectionOverlay addSubview:checkmark];

        [cell.contentView addSubview:selectionOverlay];
    }

    // Get or create selection number label
    UILabel *numberLabel = [cell viewWithTag:102];
    if (!numberLabel) {
        numberLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 40, 40)];
        numberLabel.tag = 102;
        numberLabel.backgroundColor = [UIColor systemGreenColor];
        numberLabel.textColor = [UIColor whiteColor];
        numberLabel.font = [UIFont boldSystemFontOfSize:24];
        numberLabel.textAlignment = NSTextAlignmentCenter;
        numberLabel.layer.cornerRadius = 20;
        numberLabel.clipsToBounds = YES;
        numberLabel.hidden = YES;
        [cell.contentView addSubview:numberLabel];
    }

    // Reset state
    imageView.image = nil;
    selectionOverlay.hidden = YES;
    numberLabel.hidden = YES;

    // Check if this cell is selected
    PHAsset *asset = [self.allPhotos objectAtIndex:indexPath.item];
    NSInteger selectionIndex = [self.selectedAssets indexOfObject:asset];
    if (selectionIndex != NSNotFound) {
        selectionOverlay.hidden = NO;
        numberLabel.hidden = NO;
        numberLabel.text = [NSString stringWithFormat:@"%ld", (long)(selectionIndex + 1)];
        cell.layer.borderWidth = 4;
        cell.layer.borderColor = [UIColor systemGreenColor].CGColor;
    } else {
        cell.layer.borderWidth = 0;
    }

    // Load image
    NSString *cacheKey = asset.localIdentifier;
    UIImage *cachedImage = self.imageCache[cacheKey];

    if (cachedImage) {
        imageView.image = cachedImage;
    } else {
        PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
        options.deliveryMode = PHImageRequestOptionsDeliveryModeOpportunistic;
        options.resizeMode = PHImageRequestOptionsResizeModeFast;
        options.networkAccessAllowed = YES;

        [self.imageManager requestImageForAsset:asset
                                     targetSize:self.thumbnailSize
                                    contentMode:PHImageContentModeAspectFill
                                        options:options
                                  resultHandler:^(UIImage *result, NSDictionary *info) {
            dispatch_async(dispatch_get_main_queue(), ^{
                // Verify cell hasn't been reused
                UICollectionViewCell *currentCell = [collectionView cellForItemAtIndexPath:indexPath];
                if (currentCell == cell && result) {
                    UIImageView *imgView = [cell viewWithTag:100];
                    imgView.image = result;
                    self.imageCache[cacheKey] = result;
                }
            });
        }];
    }

    return cell;
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    PHAsset *asset = [self.allPhotos objectAtIndex:indexPath.item];

    // Check if already selected
    NSInteger existingIndex = [self.selectedAssets indexOfObject:asset];

    if (existingIndex != NSNotFound) {
        // Deselect
        [self.selectedAssets removeObjectAtIndex:existingIndex];
    } else {
        // Check max selection
        if (self.selectedAssets.count >= self.maxSelection) {
            // Show max reached alert
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Maximum Reached"
                                                                           message:[NSString stringWithFormat:@"You can only select up to %ld photos.", (long)self.maxSelection]
                                                                    preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
            [alert addAction:okAction];
            [self presentViewController:alert animated:YES completion:nil];
            return;
        }

        // Add to selection
        [self.selectedAssets addObject:asset];
    }

    // Update UI
    [self updateSelectionUI];
    [collectionView reloadData];
}

- (void)updateSelectionUI {
    NSInteger count = self.selectedAssets.count;

    if (count == 0) {
        self.selectionCountLabel.text = [NSString stringWithFormat:@"Select up to %ld photos", (long)self.maxSelection];
        self.doneButton.enabled = NO;
        self.doneButton.alpha = 0.5;
    } else {
        self.selectionCountLabel.text = [NSString stringWithFormat:@"%ld of %ld photos selected", (long)count, (long)self.maxSelection];
        self.doneButton.enabled = YES;
        self.doneButton.alpha = 1.0;
    }
}

- (void)collectionView:(UICollectionView *)collectionView didUpdateFocusInContext:(UICollectionViewFocusUpdateContext *)context withAnimationCoordinator:(UIFocusAnimationCoordinator *)coordinator {
    // Animate focus for tvOS
    if (context.nextFocusedIndexPath) {
        UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:context.nextFocusedIndexPath];
        [coordinator addCoordinatedAnimations:^{
            cell.transform = CGAffineTransformMakeScale(1.1, 1.1);
            cell.layer.shadowColor = [UIColor whiteColor].CGColor;
            cell.layer.shadowOffset = CGSizeZero;
            cell.layer.shadowRadius = 15;
            cell.layer.shadowOpacity = 0.5;
        } completion:nil];
    }

    if (context.previouslyFocusedIndexPath) {
        UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:context.previouslyFocusedIndexPath];
        [coordinator addCoordinatedAnimations:^{
            cell.transform = CGAffineTransformIdentity;
            cell.layer.shadowOpacity = 0;
        } completion:nil];
    }
}

#pragma mark - Actions

- (void)cancelButtonPressed {
    if (self.delegate) {
        [self.delegate photoPickerDidCancel];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)doneButtonPressed {
    if (self.selectedAssets.count == 0) {
        return;
    }

    [self.loadingIndicator startAnimating];
    self.doneButton.enabled = NO;

    // Fetch full-size images for selected assets
    NSMutableArray<UIImage *> *images = [NSMutableArray array];
    __block NSInteger loadedCount = 0;

    PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
    options.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
    options.resizeMode = PHImageRequestOptionsResizeModeExact;
    options.networkAccessAllowed = YES;
    options.synchronous = NO;

    // Target size for game (not too large, but good quality)
    CGSize targetSize = CGSizeMake(400, 400);

    for (PHAsset *asset in self.selectedAssets) {
        [self.imageManager requestImageForAsset:asset
                                     targetSize:targetSize
                                    contentMode:PHImageContentModeAspectFill
                                        options:options
                                  resultHandler:^(UIImage *result, NSDictionary *info) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (result) {
                    [images addObject:result];
                }

                loadedCount++;

                if (loadedCount == self.selectedAssets.count) {
                    [self.loadingIndicator stopAnimating];

                    if (self.delegate && images.count > 0) {
                        [self.delegate photoPickerDidSelectPhotos:images];
                    }

                    [self dismissViewControllerAnimated:YES completion:nil];
                }
            });
        }];
    }
}

#pragma mark - Focus Engine

- (UIView *)preferredFocusedView {
    return self.collectionView;
}

@end
