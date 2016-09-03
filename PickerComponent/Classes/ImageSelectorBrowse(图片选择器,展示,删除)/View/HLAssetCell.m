//
//  HLAssetCell.m
//  ImagePickerComponent
//
//  Created by Hoolai on 16/8/28.
//  Copyright © 2016年 wsj_proj. All rights reserved.
//

#import "HLAssetCell.h"
#import "HLImageManager.h"

@interface HLAssetCell()

@property (retain, nonatomic) UIImageView *imageView;       // The photo / 照片
@property (retain, nonatomic) UIImageView *selectImageView;
@property (retain, nonatomic) UIView *bottomView;
@property (retain, nonatomic) UILabel *timeLength;

@property (nonatomic, weak) UIImageView *viewImgView;

@end

@implementation HLAssetCell

- (void)setModel:(HLAssetModel *)model {
    _model = model;
    if (iOS8Later) {
        self.representedAssetIdentifier = [[HLImageManager manager] getAssetIdentifier:model.asset];
    }
    
    PHImageRequestID imageRequestID = [[HLImageManager manager] photoWithAsset:model.asset photoWidth:self.width completion:^(UIImage *photo, NSDictionary *info, BOOL isDegraded) {
        if (!iOS8Later) {
            self.imageView.image = photo;
            return;
        }
        if ([self.representedAssetIdentifier isEqualToString:[[HLImageManager manager] getAssetIdentifier:model.asset]]) {
            self.imageView.image = photo;
        } else {
            // NSLog(@"this cell is showing other asset");
            [[PHImageManager defaultManager] cancelImageRequest:self.imageRequestID];
        }
        if (!isDegraded) {
            self.imageRequestID = 0;
        }
    }];
    
    if (imageRequestID && self.imageRequestID && imageRequestID != self.imageRequestID) {
        [[PHImageManager defaultManager] cancelImageRequest:self.imageRequestID];
        // NSLog(@"cancelImageRequest %d",self.imageRequestID);
    }
    self.imageRequestID = imageRequestID;
    self.selectPhotoButton.selected = model.isSelected;
    self.selectImageView.image = self.selectPhotoButton.isSelected ? [UIImage imageNamedFromServiceBundle:self.photoSelImageName] : [UIImage imageNamedFromServiceBundle:self.photoDefImageName];
}

- (void)setMaxImagesCount:(NSInteger)maxImagesCount {
    _maxImagesCount = maxImagesCount;
    if (!self.selectPhotoButton.hidden) {
        self.selectPhotoButton.hidden = maxImagesCount == 1;
    }
    if (!self.selectImageView.hidden) {
        self.selectImageView.hidden = maxImagesCount == 1;
    }
}

- (void)setType:(HLAssetCellType)type {
    _type = type;
    if (type == HLAssetCellTypePhoto || type == HLAssetCellTypeLivePhoto) {
        _selectImageView.hidden = NO;
        _selectPhotoButton.hidden = NO;
        _bottomView.hidden = YES;
    } else {
        _selectImageView.hidden = YES;
        _selectPhotoButton.hidden = YES;
        _bottomView.hidden = NO;
    }
}

- (void)selectPhotoButtonClick:(UIButton *)sender {
    if (self.didSelectPhotoBlock) {
        self.didSelectPhotoBlock(sender.isSelected);
    }
    self.selectImageView.image = sender.isSelected ? [UIImage imageNamedFromServiceBundle:self.photoSelImageName] : [UIImage imageNamedFromServiceBundle:self.photoDefImageName];
    if (sender.isSelected) {
        [UIView showOscillatoryAnimationWithLayer:_selectImageView.layer type:HLOscillatoryAnimationToBigger];
    }
}

#pragma mark - Lazy load

- (UIButton *)selectPhotoButton {
    if (_selectImageView == nil) {
        UIButton *selectImageView = [[UIButton alloc] init];
        selectImageView.frame = CGRectMake(self.width - 44, 0, 44, 44);
        [selectImageView addTarget:self action:@selector(selectPhotoButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:selectImageView];
        _selectPhotoButton = selectImageView;
    }
    return _selectPhotoButton;
}

- (UIImageView *)imageView {
    if (_imageView == nil) {
        UIImageView *imageView = [[UIImageView alloc] init];
        imageView.frame = CGRectMake(0, 0, self.width, self.height);
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.clipsToBounds = YES;
        [self.contentView addSubview:imageView];
        _imageView = imageView;
        
        [self.contentView bringSubviewToFront:_selectImageView];
        [self.contentView bringSubviewToFront:_bottomView];
    }
    return _imageView;
}

- (UIImageView *)selectImageView {
    if (_selectImageView == nil) {
        UIImageView *selectImageView = [[UIImageView alloc] init];
        selectImageView.frame = CGRectMake(self.width - 27, 0, 27, 27);
        [self.contentView addSubview:selectImageView];
        _selectImageView = selectImageView;
    }
    return _selectImageView;
}

- (UIView *)bottomView {
    if (_bottomView == nil) {
        UIView *bottomView = [[UIView alloc] init];
        bottomView.frame = CGRectMake(0, self.height - 17, self.width, 17);
        bottomView.backgroundColor = [UIColor blackColor];
        bottomView.alpha = 0.8;
        [self.contentView addSubview:bottomView];
        _bottomView = bottomView;
    }
    return _bottomView;
}

- (UIImageView *)viewImgView {
    if (_viewImgView == nil) {
        UIImageView *viewImgView = [[UIImageView alloc] init];
        viewImgView.frame = CGRectMake(8, 0, 17, 17);
        [viewImgView setImage:[UIImage imageNamedFromServiceBundle:@"VideoSendIcon.png"]];
        [self.bottomView addSubview:viewImgView];
        _viewImgView = viewImgView;
    }
    return _viewImgView;
}

@end
