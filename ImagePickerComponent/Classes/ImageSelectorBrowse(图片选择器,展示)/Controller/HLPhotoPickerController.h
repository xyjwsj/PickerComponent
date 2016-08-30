//
//  HLPhotoPickerController.h
//  ImagePickerComponent
//
//  Created by Hoolai on 16/8/28.
//  Copyright © 2016年 wsj_proj. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "HLAlbumModel.h"

@interface HLPhotoPickerController : UIViewController

@property (nonatomic, assign) BOOL isFirstAppear;
@property (nonatomic, assign) NSInteger columnNumber;
@property (nonatomic, strong) HLAlbumModel *model;

@property (nonatomic, copy) void (^backButtonClickHandle)(HLAlbumModel *model);

@end
