//
//  HLSharedData.h
//  ImagePickerComponent
//
//  Created by Hoolai on 16/8/28.
//  Copyright © 2016年 wsj_proj. All rights reserved.
//

#import <Foundation/Foundation.h>

#define iOS7Later ([UIDevice currentDevice].systemVersion.floatValue >= 7.0f)
#define iOS8Later ([UIDevice currentDevice].systemVersion.floatValue >= 8.0f)
#define iOS9Later ([UIDevice currentDevice].systemVersion.floatValue >= 9.0f)
#define iOS9_1Later ([UIDevice currentDevice].systemVersion.floatValue >= 9.1f)

#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height

typedef enum : NSUInteger {
    HLAssetModelMediaTypePhoto = 0,
    HLAssetModelMediaTypeLivePhoto,
    HLAssetModelMediaTypeVideo,
    HLAssetModelMediaTypeAudio
} HLAssetModelMediaType;

typedef enum : NSUInteger {
    HLOscillatoryAnimationToBigger,
    HLOscillatoryAnimationToSmaller,
} TZOscillatoryAnimationType;

typedef enum : NSUInteger {
    HLAssetCellTypePhoto = 0,
    HLAssetCellTypeLivePhoto,
    HLAssetCellTypeVideo,
    HLAssetCellTypeAudio,
} HLAssetCellType;

typedef enum : NSUInteger {
    HLPreViewTypeSelect = 0,
    HLPreViewTypeBrowse,
    HLPreViewTypeEdite,
} HLPreViewType;

@interface HLSharedData : NSObject

@end
