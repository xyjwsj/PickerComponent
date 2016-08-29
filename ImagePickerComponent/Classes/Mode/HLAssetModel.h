//
//  HLAssetModel.h
//  ImagePickerComponent
//
//  Created by Hoolai on 16/8/28.
//  Copyright © 2016年 wsj_proj. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface HLAssetModel : NSObject

@property (nonatomic, strong) id asset;             ///< PHAsset or ALAsset
@property (nonatomic, assign) BOOL isSelected;      ///< The select status of a photo, default is No
@property (nonatomic, assign) HLAssetModelMediaType type;

+ (instancetype)modelWithAsset:(id)asset type:(HLAssetModelMediaType)type;

@end
