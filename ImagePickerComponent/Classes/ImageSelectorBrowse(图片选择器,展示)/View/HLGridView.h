//
//  HLGridView.h
//  ImagePickerComponent
//
//  Created by Hoolai on 16/8/30.
//  Copyright © 2016年 wsj_proj. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HLGridView : UIView

@property (nonatomic, strong) NSMutableArray *assets;                  ///< All photo assets / 所有图片资源
@property (nonatomic, strong) NSMutableArray<UIImage*> *photos;                  ///< All photos  / 所有图片数组

@property (nonatomic, copy) void (^singleTapGestureBlock)(NSInteger index, NSMutableArray* assets, NSArray<UIImage *> *photos);

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

@end
