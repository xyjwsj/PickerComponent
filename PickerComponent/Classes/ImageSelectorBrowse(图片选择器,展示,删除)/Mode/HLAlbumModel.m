//
//  HLAlbumModel.m
//  ImagePickerComponent
//
//  Created by Hoolai on 16/8/27.
//  Copyright © 2016年 wsj_proj. All rights reserved.
//

#import "HLAlbumModel.h"
#import "HLImageManager.h"
#import "HLAssetModel.h"

@implementation HLAlbumModel

- (void)setResult:(id)result {
    _result = result;
    [[HLImageManager manager] assetsFromFetchResult:result completion:^(NSArray<HLAssetModel *> *models) {
        _models = models;
        if (_selectedModels) {
            [self checkSelectModels];
        }
    }];
}

- (void)setSelectedModels:(NSArray *)selectedModels {
    _selectedModels = selectedModels;
    if (_models) {
        [self checkSelectModels];
    }
}

- (void)checkSelectModels {
    self.selectedCount = 0;
    NSMutableArray* selectAssets = [NSMutableArray array];
    for (HLAssetModel* model in _selectedModels) {
        [selectAssets addObject:model.asset];
    }
    
    for (HLAssetModel *model in _models) {
        if ([[HLImageManager manager] isAssetsArray:selectAssets containAsset:model.asset]) {
            self.selectedCount ++;
        }
    }
    
}

- (void)setName:(NSString *)name {
    if ([@"Recently Added" isEqualToString:name]) {
        _name = @"最近添加";
    } else if ([@"Screenshots" isEqualToString:name]) {
        _name = @"屏幕快照";
    } else if ([@"Camera Roll" isEqualToString:name]) {
        _name = @"相机胶卷";
    } else {
        _name = name;
    }

}

@end
