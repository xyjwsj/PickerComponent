//
//  HLAlbumCell.h
//  ImagePickerComponent
//
//  Created by Hoolai on 16/8/28.
//  Copyright © 2016年 wsj_proj. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HLAlbumModel.h"

@interface HLAlbumCell : UITableViewCell

@property (nonatomic, strong) HLAlbumModel *model;
@property (weak, nonatomic) UIButton *selectedCountButton;

@end
