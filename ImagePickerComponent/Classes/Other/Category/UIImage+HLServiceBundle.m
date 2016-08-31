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

@end
