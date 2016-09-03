//
//  UIImage+HLServiceBundle.h
//  accesssdk
//
//  Created by Hoolai on 16/8/31.
//  Copyright © 2016年 wsj_hoolai. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (HLServiceBundle)

+ (UIImage *)imageNamedFromServiceBundle:(NSString *)name;

-(UIImage*)scaleToSize:(CGSize)size;

/**
 * 返回一张可以随意拉伸不变形的图片
 *
 * @param name 图片名称
 */
+ (UIImage *)resizableImage:(NSString *)name;

@end
