//
//  HLAlbumModel.h
//  ImagePickerComponent
//
//  Created by Hoolai on 16/8/27.
//  Copyright © 2016年 wsj_proj. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HLAlbumModel : NSObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, assign) NSInteger count;

//id只能是这两种类型<PHFetchResult,ALAssetsGroup>
@property (nonatomic, retain) id result;


@property (nonatomic, strong) NSArray *models;
@property (nonatomic, strong) NSArray *selectedModels;
@property (nonatomic, assign) NSUInteger selectedCount;

@end
