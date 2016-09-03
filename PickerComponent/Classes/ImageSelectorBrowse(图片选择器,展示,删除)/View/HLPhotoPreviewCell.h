//
//  HLPhotoPreviewCell.h
//  ImagePickerComponent
//
//  Created by Hoolai on 16/8/28.
//  Copyright © 2016年 wsj_proj. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HLAssetModel.h"

@interface HLPhotoPreviewCell : UICollectionViewCell

@property (nonatomic, strong) HLAssetModel *model;
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, copy) void (^singleTapGestureBlock)();

- (void)recoverSubviews;

@end
