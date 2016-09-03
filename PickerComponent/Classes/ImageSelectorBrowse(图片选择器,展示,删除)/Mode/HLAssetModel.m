//
//  HLAssetModel.m
//  ImagePickerComponent
//
//  Created by Hoolai on 16/8/28.
//  Copyright © 2016年 wsj_proj. All rights reserved.
//

#import "HLAssetModel.h"

@implementation HLAssetModel

+ (instancetype)modelWithAsset:(id)asset type:(HLAssetModelMediaType)type {
    HLAssetModel* assetModel = [[HLAssetModel alloc] init];
    assetModel.asset = asset;
    assetModel.type = type;
    return assetModel;
}

@end
