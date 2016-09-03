# PickerComponent 1.0
[![Platform](http://img.shields.io/badge/platform-ios-blue.svg?style=flat)](https://developer.apple.com/iphone/index.action)
[![Objective-c]]
[![Build Status](https://www.bitrise.io/app/525c553aef64bd02.svg?token=BasjApmM7Nb3N5gSzhjYYw&branch=master)](https://www.bitrise.io/app/525c553aef64bd02)
[![License](http://img.shields.io/badge/license-MIT-lightgrey.svg?style=flat)](http://mit-license.org)

## Introduction

Extension of UIImagePickerController, support picking multiple photos、original photo, also allow preview photo.
Auto Create GridView of photo, also allow preview photo and edite photo(Delete and Select)
You can execute script to create framework of static

##Usage

- Create Framework

 > Enter the project directory.
 
 > Find the directory of script.
 
 > Edite the build.sh, modify the path of project directory, the path of target directory.
 
 > Execute the command "sh build.sh UISDK".
 
 > You can find the framework in the directory of target.

- Create GridView
```Objective-c
HLGridView * _gridView = [[HLGridView alloc] initWithFrame:CGRectMake(10, button.y + 50, SCREEN_WIDTH - 20, 100) columnNumber:3];
    
    _gridView.backgroundColor = [UIColor lightGrayColor];
    
    __block typeof(self) weakSelf = self;
    _gridView.singleTapGestureBlock = ^(NSInteger index, NSMutableArray* assets, NSArray<UIImage *> *photos) {
        HLImagePickerController* imagePickerController = [[HLImagePickerController alloc] initWithSelectedAssets:nil selectedPhotos:[NSMutableArray arrayWithArray:photos] index:index mode:HLPreViewTypeEdite okCallback:^(NSArray<UIImage *> *photos, NSArray *assets, BOOL isSelectOriginalPhoto){
            weakSelf.gridView.assets = [NSMutableArray arrayWithArray:assets];
            weakSelf.gridView.photos = [NSMutableArray arrayWithArray:photos];
            
        }];
        
        [weakSelf presentViewController:imagePickerController animated:YES completion:nil];
    };
```

- Create ImageSelector

```Objective-c
HLImagePickerController *imagePickerVc = [[HLImagePickerController alloc] initWithMaxImagesCount:9 columnNumber:4 delegate:self];
    
    imagePickerVc.allowPickingImage = YES;
    imagePickerVc.allowPickingOriginalPhoto = YES;

    
    // You can get the photos by block, the same as by delegate.
    // 你可以通过block或者代理，来得到用户选择的照片.
    [imagePickerVc setDidFinishPickingPhotosHandle:^(NSArray<UIImage *> *photos, NSArray *assets, BOOL isSelectOriginalPhoto) {
        _gridView.assets = [NSMutableArray arrayWithArray:assets];
        _gridView.photos = [NSMutableArray arrayWithArray:photos];
    }];
    
    [self presentViewController:imagePickerVc animated:YES completion:nil];
```

## Version
> 1.0
