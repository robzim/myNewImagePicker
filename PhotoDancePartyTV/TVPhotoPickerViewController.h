//
//  TVPhotoPickerViewController.h
//  PhotoDancePartyTV
//
//  Created by Robert Zimmelman.
//  Copyright © 2024 Robert Zimmelman. All rights reserved.
//

@import UIKit;
@import Photos;

@protocol TVPhotoPickerDelegate <NSObject>
- (void)photoPickerDidSelectPhotos:(NSArray<UIImage *> *)photos;
- (void)photoPickerDidCancel;
@end

@interface TVPhotoPickerViewController : UIViewController <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

@property (weak, nonatomic) id<TVPhotoPickerDelegate> delegate;

@end
