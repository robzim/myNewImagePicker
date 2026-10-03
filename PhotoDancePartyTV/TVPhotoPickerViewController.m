//
//  TVPhotoPickerViewController.m
//  PhotoDancePartyTV
//
//  Created by Robert Zimmelman.
//  Copyright © 2024 Robert Zimmelman. All rights reserved.
//

#import "TVPhotoPickerViewController.h"

static NSString *const PhotoCellIdentifier = @"PhotoCell";

#define MAGIC_CYAN [UIColor colorWithRed:0.2 green:0.8 blue:1.0 alpha:1.0]
#define MAGIC_GREEN [UIColor colorWithRed:0.2 green:0.78 blue:0.35 alpha:1.0]
#define MAGIC_PURPLE [UIColor colorWithRed:0.6 green:0.3 blue:1.0 alpha:1.0]

@interface TVPhotoPickerViewController () <CAAnimationDelegate>
@property (strong, nonatomic) CAGradientLayer *backgroundGradientLayer;
@property (strong, nonatomic) UICollectionView *collectionView;
@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) UILabel *selectionCountLabel;
@property (strong, nonatomic) UILabel *hintLabel;
@property (strong, nonatomic) UIButton *doneButton;
@property (strong, nonatomic) UIButton *cancelButton;

@property (strong, nonatomic) PHFetchResult *allPhotos;
@property (strong, nonatomic) PHCachingImageManager *cachingImageManager;
@property (strong, nonatomic) NSMutableOrderedSet *selectedIndexPaths;
@property (nonatomic) CGFloat gradientHueValue;
@property (strong, nonatomic) NSTimer *gradientAnimationTimer;
@end

@implementation TVPhotoPickerViewController

@synthesize delegate;

#pragma mark - View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];

    self.selectedIndexPaths = [[NSMutableOrderedSet alloc] init];
    self.cachingImageManager = [[PHCachingImageManager alloc] init];
    self.gradientHueValue = 0.0;

    [self setupGradientBackground];
    [self setupUI];
    [self requestPhotoAccess];
}

- (void)dealloc {
    [self.gradientAnimationTimer invalidate];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    self.backgroundGradientLayer.frame = self.view.bounds;
}

#pragma mark - Gradient Background

- (UIColor *)colorFromHue:(CGFloat)hue saturation:(CGFloat)saturation brightness:(CGFloat)brightness alpha:(CGFloat)alpha {
    return [UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:alpha];
}

- (void)setupGradientBackground {
    self.backgroundGradientLayer = [CAGradientLayer layer];
    self.backgroundGradientLayer.frame = self.view.bounds;
    self.backgroundGradientLayer.colors = @[
        (id)[UIColor colorWithRed:0.05 green:0.0 blue:0.15 alpha:1.0].CGColor,
        (id)[UIColor colorWithRed:0.15 green:0.05 blue:0.3 alpha:1.0].CGColor,
        (id)[UIColor colorWithRed:0.1 green:0.0 blue:0.25 alpha:1.0].CGColor,
        (id)[UIColor colorWithRed:0.0 green:0.05 blue:0.2 alpha:1.0].CGColor
    ];
    self.backgroundGradientLayer.locations = @[@0.0, @0.35, @0.7, @1.0];
    self.backgroundGradientLayer.startPoint = CGPointMake(0, 0);
    self.backgroundGradientLayer.endPoint = CGPointMake(1, 1);
    [self.view.layer insertSublayer:self.backgroundGradientLayer atIndex:0];

    self.gradientAnimationTimer = [NSTimer scheduledTimerWithTimeInterval:0.05
                                                                    target:self
                                                                  selector:@selector(animateGradient)
                                                                  userInfo:nil
                                                                   repeats:YES];
}

- (void)animateGradient {
    self.gradientHueValue += 0.002;
    if (self.gradientHueValue > 1.0) self.gradientHueValue = 0.0;

    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    self.backgroundGradientLayer.colors = @[
        (id)[self colorFromHue:self.gradientHueValue saturation:0.8 brightness:0.15 alpha:1.0].CGColor,
        (id)[self colorFromHue:fmod(self.gradientHueValue + 0.1, 1.0) saturation:0.7 brightness:0.25 alpha:1.0].CGColor,
        (id)[self colorFromHue:fmod(self.gradientHueValue + 0.2, 1.0) saturation:0.75 brightness:0.2 alpha:1.0].CGColor,
        (id)[self colorFromHue:fmod(self.gradientHueValue + 0.3, 1.0) saturation:0.8 brightness:0.1 alpha:1.0].CGColor
    ];
    [CATransaction commit];
}

#pragma mark - UI Setup

- (void)setupUI {
    // Title label
    self.titleLabel = [[UILabel alloc] init];
    self.titleLabel.text = @"Select Up to 5 Photos";
    self.titleLabel.font = [UIFont systemFontOfSize:52 weight:UIFontWeightBold];
    self.titleLabel.textColor = MAGIC_CYAN;
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.titleLabel];

    // Selection count label with enhanced styling
    self.selectionCountLabel = [[UILabel alloc] init];
    self.selectionCountLabel.text = @"0 of 5 selected";
    self.selectionCountLabel.font = [UIFont systemFontOfSize:36 weight:UIFontWeightSemibold];
    self.selectionCountLabel.textColor = [UIColor colorWithRed:0.6 green:0.3 blue:1.0 alpha:1.0];
    self.selectionCountLabel.textAlignment = NSTextAlignmentCenter;
    self.selectionCountLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.selectionCountLabel];

    // Hint label with remote control instructions
    self.hintLabel = [[UILabel alloc] init];
    self.hintLabel.text = @"Press Select to choose • Press Play/Pause to confirm";
    self.hintLabel.font = [UIFont systemFontOfSize:26 weight:UIFontWeightRegular];
    self.hintLabel.textColor = [UIColor colorWithWhite:0.65 alpha:1.0];
    self.hintLabel.textAlignment = NSTextAlignmentCenter;
    self.hintLabel.numberOfLines = 0;
    self.hintLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.hintLabel];

    // Collection view layout - larger photos for TV
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.itemSize = CGSizeMake(320, 320);
    flowLayout.minimumInteritemSpacing = 40;
    flowLayout.minimumLineSpacing = 40;
    flowLayout.sectionInset = UIEdgeInsetsMake(20, 80, 20, 80);

    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:flowLayout];
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    self.collectionView.backgroundColor = [UIColor clearColor];
    self.collectionView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:PhotoCellIdentifier];
    [self.view addSubview:self.collectionView];

    // Done button with enhanced styling
    self.doneButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.doneButton setTitle:@"Done" forState:UIControlStateNormal];
    self.doneButton.titleLabel.font = [UIFont systemFontOfSize:40 weight:UIFontWeightBold];
    [self.doneButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.doneButton.backgroundColor = MAGIC_GREEN;
    self.doneButton.layer.cornerRadius = 20;
    self.doneButton.clipsToBounds = YES;
    self.doneButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.doneButton addTarget:self action:@selector(doneTapped) forControlEvents:UIControlEventPrimaryActionTriggered];
    [self.view addSubview:self.doneButton];

    // Cancel button with enhanced styling
    self.cancelButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.cancelButton setTitle:@"Cancel" forState:UIControlStateNormal];
    self.cancelButton.titleLabel.font = [UIFont systemFontOfSize:40 weight:UIFontWeightSemibold];
    [self.cancelButton setTitleColor:[UIColor colorWithWhite:0.85 alpha:1.0] forState:UIControlStateNormal];
    self.cancelButton.backgroundColor = [UIColor colorWithWhite:0.15 alpha:1.0];
    self.cancelButton.layer.cornerRadius = 20;
    self.cancelButton.clipsToBounds = YES;
    self.cancelButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.cancelButton addTarget:self action:@selector(cancelTapped) forControlEvents:UIControlEventPrimaryActionTriggered];
    [self.view addSubview:self.cancelButton];

    // Layout constraints
    [NSLayoutConstraint activateConstraints:@[
        [self.titleLabel.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor constant:30],
        [self.titleLabel.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],

        [self.selectionCountLabel.topAnchor constraintEqualToAnchor:self.titleLabel.bottomAnchor constant:15],
        [self.selectionCountLabel.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],

        [self.hintLabel.topAnchor constraintEqualToAnchor:self.selectionCountLabel.bottomAnchor constant:8],
        [self.hintLabel.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],

        [self.collectionView.topAnchor constraintEqualToAnchor:self.hintLabel.bottomAnchor constant:25],
        [self.collectionView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [self.collectionView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [self.collectionView.bottomAnchor constraintEqualToAnchor:self.doneButton.topAnchor constant:-25],

        [self.doneButton.bottomAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.bottomAnchor constant:-25],
        [self.doneButton.trailingAnchor constraintEqualToAnchor:self.view.centerXAnchor constant:-25],
        [self.doneButton.widthAnchor constraintEqualToConstant:320],
        [self.doneButton.heightAnchor constraintEqualToConstant:90],

        [self.cancelButton.bottomAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.bottomAnchor constant:-25],
        [self.cancelButton.leadingAnchor constraintEqualToAnchor:self.view.centerXAnchor constant:25],
        [self.cancelButton.widthAnchor constraintEqualToConstant:320],
        [self.cancelButton.heightAnchor constraintEqualToConstant:90],
    ]];
}

#pragma mark - Photo Access

- (void)requestPhotoAccess {
    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
        dispatch_async(dispatch_get_main_queue(), ^{
            switch (status) {
                case PHAuthorizationStatusAuthorized:
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 140000
                case PHAuthorizationStatusLimited:
#endif
                    [self fetchAllPhotos];
                    break;
                case PHAuthorizationStatusDenied:
                case PHAuthorizationStatusRestricted:
                    [self showAccessDeniedMessage];
                    break;
                default:
                    break;
            }
        });
    }];
}

- (void)fetchAllPhotos {
    PHFetchOptions *fetchOptions = [[PHFetchOptions alloc] init];
    [fetchOptions setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO]]];
    self.allPhotos = [PHAsset fetchAssetsWithMediaType:PHAssetMediaTypeImage options:fetchOptions];
    [self.collectionView reloadData];
}

- (void)showAccessDeniedMessage {
    self.titleLabel.text = @"Photo Access Required";
    self.titleLabel.textColor = [UIColor colorWithRed:1.0 green:0.4 blue:0.4 alpha:1.0];
    self.selectionCountLabel.text = @"Please grant photo access in Settings";
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.allPhotos.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:PhotoCellIdentifier forIndexPath:indexPath];

    // Clear previous content
    for (UIView *subview in cell.contentView.subviews) {
        [subview removeFromSuperview];
    }

    // Enhanced cell styling
    cell.contentView.layer.cornerRadius = 24;
    cell.contentView.clipsToBounds = YES;
    cell.contentView.backgroundColor = [UIColor colorWithWhite:0.1 alpha:1.0];
    cell.layer.shadowColor = [UIColor colorWithRed:0.6 green:0.3 blue:1.0 alpha:0.4].CGColor;
    cell.layer.shadowOffset = CGSizeMake(0, 8);
    cell.layer.shadowRadius = 12;
    cell.layer.shadowOpacity = 0.3;

    // Image view with overlay
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:cell.contentView.bounds];
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    imageView.clipsToBounds = YES;
    imageView.tag = 100;
    [cell.contentView addSubview:imageView];

    // Load thumbnail
    PHAsset *asset = self.allPhotos[indexPath.item];
    [self.cachingImageManager requestImageForAsset:asset
                                        targetSize:CGSizeMake(320, 320)
                                       contentMode:PHImageContentModeAspectFill
                                           options:nil
                                     resultHandler:^(UIImage *result, NSDictionary *info) {
        dispatch_async(dispatch_get_main_queue(), ^{
            UICollectionViewCell *updateCell = [collectionView cellForItemAtIndexPath:indexPath];
            if (updateCell) {
                UIImageView *cellImageView = [updateCell.contentView viewWithTag:100];
                if (cellImageView) {
                    cellImageView.image = result;
                }
            }
        });
    }];

    // Selection overlay and styling
    BOOL isSelected = [self.selectedIndexPaths containsObject:indexPath];
    if (isSelected) {
        NSUInteger selectionNumber = [self.selectedIndexPaths indexOfObject:indexPath] + 1;

        // Green tinted overlay for selected items
        UIView *selectionOverlay = [[UIView alloc] initWithFrame:cell.contentView.bounds];
        selectionOverlay.backgroundColor = MAGIC_GREEN;
        selectionOverlay.alpha = 0.25;
        selectionOverlay.tag = 200;
        selectionOverlay.layer.cornerRadius = 24;
        [cell.contentView addSubview:selectionOverlay];

        // Enhanced border
        cell.contentView.layer.borderWidth = 5;
        cell.contentView.layer.borderColor = MAGIC_GREEN.CGColor;
        cell.layer.shadowColor = MAGIC_GREEN.CGColor;
        cell.layer.shadowOpacity = 0.7;

        // Number badge with improved design
        UIView *badgeContainer = [[UIView alloc] initWithFrame:CGRectMake(cell.contentView.bounds.size.width - 70, 10, 60, 60)];
        badgeContainer.backgroundColor = MAGIC_GREEN;
        badgeContainer.layer.cornerRadius = 30;
        badgeContainer.layer.masksToBounds = YES;
        badgeContainer.layer.shadowColor = [UIColor blackColor].CGColor;
        badgeContainer.layer.shadowOffset = CGSizeMake(0, 4);
        badgeContainer.layer.shadowRadius = 8;
        badgeContainer.layer.shadowOpacity = 0.6;
        badgeContainer.tag = 250;
        [cell.contentView addSubview:badgeContainer];

        UILabel *numberLabel = [[UILabel alloc] initWithFrame:badgeContainer.bounds];
        numberLabel.text = [NSString stringWithFormat:@"%lu", (unsigned long)selectionNumber];
        numberLabel.font = [UIFont systemFontOfSize:36 weight:UIFontWeightBold];
        numberLabel.textColor = [UIColor whiteColor];
        numberLabel.textAlignment = NSTextAlignmentCenter;
        numberLabel.tag = 300;
        [badgeContainer addSubview:numberLabel];
    } else {
        cell.contentView.layer.borderWidth = 0;
        cell.layer.shadowOpacity = 0.3;
    }

    return cell;
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    BOOL isCurrentlySelected = [self.selectedIndexPaths containsObject:indexPath];

    if (isCurrentlySelected) {
        [self.selectedIndexPaths removeObject:indexPath];
    } else {
        if (self.selectedIndexPaths.count >= 5) {
            // Remove oldest selection
            NSIndexPath *oldestPath = self.selectedIndexPaths.firstObject;
            [self.selectedIndexPaths removeObjectAtIndex:0];
            [collectionView reloadItemsAtIndexPaths:@[oldestPath]];
        }
        [self.selectedIndexPaths addObject:indexPath];
    }

    // Update counter with animation
    [UIView animateWithDuration:0.3 animations:^{
        self.selectionCountLabel.transform = CGAffineTransformMakeScale(1.15, 1.15);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.2 animations:^{
            self.selectionCountLabel.transform = CGAffineTransformIdentity;
        }];
    }];

    self.selectionCountLabel.text = [NSString stringWithFormat:@"%lu of 5 selected", (unsigned long)self.selectedIndexPaths.count];

    // Update hint text based on selection count
    if (self.selectedIndexPaths.count >= 5) {
        self.hintLabel.text = @"Maximum 5 photos selected • Press Play/Pause to start";
        self.hintLabel.textColor = [UIColor colorWithRed:1.0 green:0.85 blue:0.3 alpha:1.0];
    } else if (self.selectedIndexPaths.count > 0) {
        self.hintLabel.text = [NSString stringWithFormat:@"Ready to start • Press Play/Pause or tap Done"];
        self.hintLabel.textColor = MAGIC_GREEN;
    } else {
        self.hintLabel.text = @"Press Select to choose • Press Play/Pause to confirm";
        self.hintLabel.textColor = [UIColor colorWithWhite:0.65 alpha:1.0];
    }

    [collectionView reloadItemsAtIndexPaths:@[indexPath]];
}

- (void)didUpdateFocusInContext:(UIFocusUpdateContext *)context withAnimationCoordinator:(UIFocusAnimationCoordinator *)coordinator {
    // Enhanced focus handling with glow effects

    // Unfocus previous cell
    if ([context.previouslyFocusedView isKindOfClass:[UICollectionViewCell class]]) {
        UICollectionViewCell *previousCell = (UICollectionViewCell *)context.previouslyFocusedView;
        [coordinator addCoordinatedAnimations:^{
            previousCell.transform = CGAffineTransformIdentity;
            previousCell.layer.shadowOpacity = 0.3;
            previousCell.layer.shadowRadius = 12;
        } completion:nil];
    }

    // Focus new cell with enhanced scale and glow
    if ([context.nextFocusedView isKindOfClass:[UICollectionViewCell class]]) {
        UICollectionViewCell *nextCell = (UICollectionViewCell *)context.nextFocusedView;
        [coordinator addCoordinatedAnimations:^{
            nextCell.transform = CGAffineTransformMakeScale(1.15, 1.15);
            nextCell.layer.shadowColor = MAGIC_PURPLE.CGColor;
            nextCell.layer.shadowOffset = CGSizeMake(0, 12);
            nextCell.layer.shadowRadius = 25;
            nextCell.layer.shadowOpacity = 0.8;
        } completion:nil];
    }

    // Enhanced button focus
    if ([context.previouslyFocusedView isKindOfClass:[UIButton class]]) {
        UIButton *prevButton = (UIButton *)context.previouslyFocusedView;
        [coordinator addCoordinatedAnimations:^{
            prevButton.transform = CGAffineTransformIdentity;
            prevButton.layer.shadowOpacity = 0;
        } completion:nil];
    }

    if ([context.nextFocusedView isKindOfClass:[UIButton class]]) {
        UIButton *nextButton = (UIButton *)context.nextFocusedView;
        [coordinator addCoordinatedAnimations:^{
            nextButton.transform = CGAffineTransformMakeScale(1.12, 1.12);
            nextButton.layer.shadowColor = [UIColor whiteColor].CGColor;
            nextButton.layer.shadowOffset = CGSizeMake(0, 10);
            nextButton.layer.shadowRadius = 20;
            nextButton.layer.shadowOpacity = 0.8;
            nextButton.layer.borderWidth = 3;
            nextButton.layer.borderColor = [UIColor whiteColor].CGColor;
        } completion:nil];
    }
}

#pragma mark - Actions

- (void)doneTapped {
    if (self.selectedIndexPaths.count == 0) {
        [self playDismissalAnimation];
        return;
    }

    // Visual feedback
    [self animateButtonPress:self.doneButton];

    // Show loading state
    self.doneButton.enabled = NO;
    self.cancelButton.enabled = NO;

    NSMutableArray<UIImage *> *selectedImages = [[NSMutableArray alloc] init];
    dispatch_group_t loadGroup = dispatch_group_create();

    PHImageRequestOptions *requestOptions = [[PHImageRequestOptions alloc] init];
    requestOptions.synchronous = NO;
    requestOptions.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
    requestOptions.resizeMode = PHImageRequestOptionsResizeModeExact;

    for (NSIndexPath *indexPath in self.selectedIndexPaths) {
        dispatch_group_enter(loadGroup);
        PHAsset *asset = self.allPhotos[indexPath.item];

        [self.cachingImageManager requestImageForAsset:asset
                                            targetSize:CGSizeMake(400, 400)
                                           contentMode:PHImageContentModeAspectFill
                                               options:requestOptions
                                         resultHandler:^(UIImage *result, NSDictionary *info) {
            if (result) {
                @synchronized (selectedImages) {
                    [selectedImages addObject:result];
                }
            }
            dispatch_group_leave(loadGroup);
        }];
    }

    __weak typeof(self) weakSelf = self;
    dispatch_group_notify(loadGroup, dispatch_get_main_queue(), ^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (!strongSelf) { return; }
        [strongSelf dismissViewControllerAnimated:YES completion:^{
            [strongSelf.delegate photoPickerDidSelectPhotos:selectedImages];
        }];
    });
}

- (void)cancelTapped {
    [self animateButtonPress:self.cancelButton];
    [self playDismissalAnimation];
}

- (void)playDismissalAnimation {
    [UIView animateWithDuration:0.3 animations:^{
        self.view.alpha = 0.5;
        self.titleLabel.transform = CGAffineTransformMakeTranslation(0, -50);
    } completion:^(BOOL finished) {
        [self dismissViewControllerAnimated:YES completion:^{
            [self.delegate photoPickerDidCancel];
        }];
    }];
}

- (void)animateButtonPress:(UIButton *)button {
    [UIView animateWithDuration:0.1 animations:^{
        button.transform = CGAffineTransformMakeScale(0.95, 0.95);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.1 animations:^{
            button.transform = CGAffineTransformIdentity;
        }];
    }];
}

#pragma mark - Remote Button Handling

- (void)pressesBegan:(NSSet<UIPress *> *)presses withEvent:(UIPressesEvent *)event {
    for (UIPress *press in presses) {
        if (press.type == UIPressTypePlayPause) {
            [self doneTapped];
            return;
        } else if (press.type == UIPressTypeMenu) {
            [self cancelTapped];
            return;
        }
    }
    [super pressesBegan:presses withEvent:event];
}

#pragma mark - Focus Engine

- (NSArray<id<UIFocusEnvironment>> *)preferredFocusEnvironments {
    if (self.collectionView) {
        return @[self.collectionView];
    }
    return @[];
}

@end
