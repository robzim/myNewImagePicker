//
//  TVPhotoPickerViewController.h
//  TV Photo Chaos
//
//  tvOS photo picker for iCloud Photo Library
//  Grid-based selection of up to 5 photos
//
//  Created by Robert Zimmelman.
//  Copyright (c) 2024 Robert Zimmelman. All rights reserved.
//

@import UIKit;
@import Photos;

@protocol TVPhotoPickerDelegate <NSObject>
- (void)photoPickerDidSelectPhotos:(NSArray<UIImage *> *)photos;
- (void)photoPickerDidCancel;
@end

@interface TVPhotoPickerViewController : UIViewController <UICollectionViewDelegate, UICollectionViewDataSource, PHPhotoLibraryChangeObserver>

@property (weak, nonatomic) id<TVPhotoPickerDelegate> delegate;

// UI Elements
@property (strong, nonatomic) UICollectionView *collectionView;
@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) UILabel *selectionCountLabel;
@property (strong, nonatomic) UIButton *doneButton;
@property (strong, nonatomic) UIButton *cancelButton;
@property (strong, nonatomic) UIActivityIndicatorView *loadingIndicator;

// Photo library
@property (strong, nonatomic) PHFetchResult *allPhotos;
@property (strong, nonatomic) PHImageManager *imageManager;
@property (strong, nonatomic) PHCachingImageManager *cachingImageManager;
@property CGSize thumbnailSize;

// Selection
@property (strong, nonatomic) NSMutableArray<PHAsset *> *selectedAssets;
@property NSInteger maxSelection; // Default 5

// Methods
- (void)requestPhotoLibraryAccess;
- (void)loadPhotos;

@end
