//
//  HLGridView.m
//  ImagePickerComponent
//
//  Created by Hoolai on 16/8/30.
//  Copyright © 2016年 wsj_proj. All rights reserved.
//

#import "HLGridView.h"
#import "HLAssetModel.h"

@interface HLGridView()<UIGestureRecognizerDelegate> {
    NSInteger _columnNumber;
    CGFloat _margin;
}

@end

@implementation HLGridView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (instancetype)initWithFrame:(CGRect)frame columnNumber:(NSInteger)column {
    _columnNumber = column;
    if (self = [super initWithFrame:frame]) {
        _margin = 5;
//        self.userInteractionEnabled = YES;
    }
    return self;
}

- (void)setPhotos:(NSMutableArray<UIImage *> *)photos {
    [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    _photos = photos;
    NSInteger count = photos.count;
    NSInteger row = (count + _columnNumber - 1) / _columnNumber;
    CGFloat width = (self.width - (_columnNumber + 1) * _margin) / _columnNumber;
    CGFloat height = width;
    
    for (int i = 0; i < photos.count; i++) {
        NSInteger currentRow = i / _columnNumber;
        NSInteger currentColumn = i % _columnNumber;
        CGFloat x = _margin + (width + _margin) * currentColumn;
        CGFloat y = _margin + (height + _margin) * currentRow;
        UIImageView * imageView = [[UIImageView alloc] initWithFrame:CGRectMake(x, y, width, height)];
        [imageView setImage:[photos objectAtIndex:i]];
        
        imageView.userInteractionEnabled = YES;
        imageView.tag = i;
        UITapGestureRecognizer* gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imagesingleTap:)];
        [imageView addGestureRecognizer:gesture];
        [self addSubview:imageView];
    }
    NSLog(@"%@", NSStringFromCGRect(self.frame));
    self.height = _margin + (_margin + height) * row;
    NSLog(@"%@", NSStringFromCGRect(self.frame));
}

- (void)imagesingleTap:(UITapGestureRecognizer *)tap {
    NSLog(@"imageClick");
    if (_singleTapGestureBlock) {
        @try {
            _singleTapGestureBlock(tap.view.tag, _assets, _photos);
        } @catch (NSException *exception) {
            NSLog(@"%@", exception.reason);
        } @finally {
            
        }
        
    }
}

@end
