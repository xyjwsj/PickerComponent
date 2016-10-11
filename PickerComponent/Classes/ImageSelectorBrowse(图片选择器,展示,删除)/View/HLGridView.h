//
//  HLGridView.h
//  ImagePickerComponent
//
//  Created by Hoolai on 16/8/30.
//  Copyright © 2016年 wsj_proj. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum :NSInteger {
    LOCAL_IMAGE = 0,
    NETWORK_IMAGE
}PictureType;

@interface HLGridView : UIView

@property (nonatomic, strong) NSMutableArray *assets;                  ///< All photo assets / 所有图片资源
@property (nonatomic, strong) NSMutableArray *photos;                  ///< All photos  / 所有图片数组
@property (nonatomic, assign) PictureType picType;

@property (nonatomic, copy) void (^singleTapGestureBlock)(NSInteger index, NSMutableArray* assets, NSArray *photos);

/**
 *  此方法会对高度进行自动适配
 *  
 *
 *  @param frame  view大小位置，宽度必须配置
 *  @param column 显示列数
 *
 *  @return 当前view
 */
- (instancetype)initWithFrame:(CGRect)frame columnNumber:(NSInteger)column;

/**
 *  此方法会对高度进行自动适配
 *
 *
 *  @param frame  view大小位置，宽度必须配置
 *  @param column 显示列数
 *  @param photosCount 图片数量
 *
 *  @return 当前view
 */
- (instancetype)initWithFrame:(CGRect)frame columnNumber:(NSInteger)column photosCount:(NSInteger)photosCount;

/**
 *  加载网络图片
 *
 *  @param photos             图片数组，字符串
 *  @param cacheImageDelegate 回调，去加载网络图片
 */
- (void)setPhotos:(NSMutableArray *)photos cacheImageDelegate:(void(^)(UIImageView * imageView, NSString* url))cacheImageDelegate;

@end
