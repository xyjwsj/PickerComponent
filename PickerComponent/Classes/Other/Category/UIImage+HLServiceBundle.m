//
//  UIImage+HLServiceBundle.m
//  accesssdk
//
//  Created by Hoolai on 16/8/31.
//  Copyright © 2016年 wsj_hoolai. All rights reserved.
//

#import "UIImage+HLServiceBundle.h"

@implementation UIImage (HLServiceBundle)

+ (UIImage *)imageNamedFromServiceBundle:(NSString *)name {
    UIImage *image = [UIImage imageNamed:[@"access_service.bundle" stringByAppendingPathComponent:name]];
    if (image) {
        return image;
    }
    return nil;
}

-(UIImage*)scaleToSize:(CGSize)size
{
    // 创建一个bitmap的context
    // 并把它设置成为当前正在使用的context
    UIGraphicsBeginImageContext(size);
    // 绘制改变大小的图片
    [self drawInRect:CGRectMake(0, 0, size.width, size.height)];
    // 从当前context中创建一个改变大小后的图片
    UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    // 使当前的context出堆栈
    UIGraphicsEndImageContext();
    // 返回新的改变大小后的图片
    return scaledImage;
}

/**
 * 返回一张可以随意拉伸不变形的图片
 *
 * @param name 图片名称
 */
+ (UIImage *)resizableImage:(NSString *)name
{
    UIImage *normal = [UIImage imageNamedFromServiceBundle:name];
    CGFloat top = normal.size.height * 0.5;
    CGFloat left = normal.size.width * 0.5;
    CGFloat bottom = normal.size.height * 0.5;
    CGFloat right = normal.size.width * 0.5;
    return [normal resizableImageWithCapInsets:UIEdgeInsetsMake(top, left, bottom, right) resizingMode:UIImageResizingModeStretch];
}

+ (UIImage *)resizableImage:(NSString *)name edgeInsetsRate:(UIEdgeInsets)edgeInsetsRate {
    UIImage *normal = [UIImage imageNamedFromServiceBundle:name];
    CGFloat top = normal.size.height * edgeInsetsRate.top;
    CGFloat left = normal.size.width * edgeInsetsRate.left;
    CGFloat bottom = normal.size.height * edgeInsetsRate.bottom;
    CGFloat right = normal.size.width * edgeInsetsRate.right;
    return [normal resizableImageWithCapInsets:UIEdgeInsetsMake(top, left, bottom, right) resizingMode:UIImageResizingModeStretch];
}

@end
