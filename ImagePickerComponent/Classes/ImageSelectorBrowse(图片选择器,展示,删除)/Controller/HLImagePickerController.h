//
//  HLImagePickerController.h
//  ImagePickerComponent
//
//  Created by Hoolai on 16/8/28.
//  Copyright © 2016年 wsj_proj. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HLAssetModel.h"

@protocol HLImagePickerControllerDelegate;

@interface HLImagePickerController : UINavigationController

/// Use this init method / 用这个初始化方法
- (instancetype)initWithMaxImagesCount:(NSInteger)maxImagesCount delegate:(id<HLImagePickerControllerDelegate>)delegate;
- (instancetype)initWithMaxImagesCount:(NSInteger)maxImagesCount columnNumber:(NSInteger)columnNumber delegate:(id<HLImagePickerControllerDelegate>)delegate;
/// This init method just for previewing photos / 用这个初始化方法以预览图片
- (instancetype)initWithSelectedAssets:(NSMutableArray *)selectedAssets selectedPhotos:(NSMutableArray *)selectedPhotos index:(NSInteger)index;
- (instancetype)initWithSelectedAssets:(NSMutableArray *)selectedAssets selectedPhotos:(NSMutableArray *)selectedPhotos index:(NSInteger)index mode:(HLPreViewType)mode okCallback:(void (^)(NSArray<UIImage *> *photos, NSArray *assets, BOOL isSelectOriginalPhoto))callback;

/// Default is 9 / 默认最大可选9张图片
@property (nonatomic, assign) NSInteger maxImagesCount;

/// Sort photos ascending by modificationDate，Default is YES
/// 对照片排序，按修改时间升序，默认是YES。如果设置为NO,最新的照片会显示在最前面，内部的拍照按钮会排在第一个
@property (nonatomic, assign) BOOL sortAscendingByModificationDate;

/// Default is 828px / 默认828像素宽
@property (nonatomic, assign) CGFloat photoWidth;

/// Default is 600px / 默认600像素宽
@property (nonatomic, assign) CGFloat photoPreviewMaxWidth;

/// Default is 15, While fetching photo, HUD will dismiss automatic if timeout;
/// 超时时间，默认为15秒，当取图片时间超过15秒还没有取成功时，会自动dismiss HUD；
@property (nonatomic, assign) NSInteger timeout;

/// Default is YES.if set NO, the original photo button will hide. user can't picking original photo.
/// 默认为YES，如果设置为NO,原图按钮将隐藏，用户不能选择发送原图
@property (nonatomic, assign) BOOL allowPickingOriginalPhoto;

/// Default is YES.if set NO, user can't picking video.
/// 默认为YES，如果设置为NO,用户将不能选择发送视频
@property (nonatomic, assign) BOOL allowPickingVideo;

/// Default is YES.if set NO, user can't picking image.
/// 默认为YES，如果设置为NO,用户将不能选择发送图片
@property(nonatomic, assign) BOOL allowPickingImage;

/// Default is YES.if set NO, user can't take picture.
/// 默认为YES，如果设置为NO,拍照按钮将隐藏,用户将不能在选择器中拍照
@property(nonatomic, assign) BOOL allowTakePicture;

/// Default is YES.if set NO, the picker don't dismiss itself.
/// 默认为YES，如果设置为NO, 选择器将不会自己dismiss
@property(nonatomic, assign) BOOL autoDismiss;

/// The photos user have selected
/// 用户选中过的图片数组
@property (nonatomic, strong) NSMutableArray *selectedAssets;
@property (nonatomic, strong) NSMutableArray<HLAssetModel *> *selectedModels;

- (void)showAlertWithTitle:(NSString *)title;
- (void)showProgressHUD;
- (void)hideProgressHUD;
@property (nonatomic, assign) BOOL isSelectOriginalPhoto;

@property (nonatomic, copy) NSString *takePictureImageName;
@property (nonatomic, copy) NSString *photoSelImageName;
@property (nonatomic, copy) NSString *photoDefImageName;
@property (nonatomic, copy) NSString *photoOriginSelImageName;
@property (nonatomic, copy) NSString *photoOriginDefImageName;
@property (nonatomic, copy) NSString *photoPreviewOriginDefImageName;
@property (nonatomic, copy) NSString *photoNumberIconImageName;

/// Appearance / 外观颜色
@property (nonatomic, strong) UIColor *oKButtonTitleColorNormal;
@property (nonatomic, strong) UIColor *oKButtonTitleColorDisabled;
@property (nonatomic, strong) UIColor *barItemTextColor;
@property (nonatomic, strong) UIFont *barItemTextFont;

// The picker should dismiss itself; when it dismissed these handle will be called.
// You can also set autoDismiss to NO, then the picker don't dismiss itself.
// If isOriginalPhoto is YES, user picked the original photo.
// You can get original photo with asset, by the method [[TZImageManager manager] getOriginalPhotoWithAsset:completion:].
// The UIImage Object in photos default width is 828px, you can set it by photoWidth property.
// 这个照片选择器会自己dismiss，当选择器dismiss的时候，会执行下面的handle
// 你也可以设置autoDismiss属性为NO，选择器就不会自己dismis了
// 如果isSelectOriginalPhoto为YES，表明用户选择了原图
// 你可以通过一个asset获得原图，通过这个方法：[[TZImageManager manager] getOriginalPhotoWithAsset:completion:]
// photos数组里的UIImage对象，默认是828像素宽，你可以通过设置photoWidth属性的值来改变它
@property (nonatomic, copy) void (^didFinishPickingPhotosHandle)(NSArray<UIImage *> *photos,NSArray *assets,BOOL isSelectOriginalPhoto);
@property (nonatomic, copy) void (^didFinishPickingPhotosWithInfosHandle)(NSArray<UIImage *> *photos,NSArray *assets,BOOL isSelectOriginalPhoto,NSArray<NSDictionary *> *infos);
@property (nonatomic, copy) void (^imagePickerControllerDidCancelHandle)();
// If user picking a video, this handle will be called.
// If system version > iOS8,asset is kind of PHAsset class, else is ALAsset class.
// 如果用户选择了一个视频，下面的handle会被执行
// 如果系统版本大于iOS8，asset是PHAsset类的对象，否则是ALAsset类的对象
@property (nonatomic, copy) void (^didFinishPickingVideoHandle)(UIImage *coverImage,id asset);

@property (nonatomic, weak) id<HLImagePickerControllerDelegate> pickerDelegate;

@end


@protocol HLImagePickerControllerDelegate <NSObject>
@optional
// The picker should dismiss itself; when it dismissed these handle will be called.
// You can also set autoDismiss to NO, then the picker don't dismiss itself.
// If isOriginalPhoto is YES, user picked the original photo.
// You can get original photo with asset, by the method [[TZImageManager manager] getOriginalPhotoWithAsset:completion:].
// The UIImage Object in photos default width is 828px, you can set it by photoWidth property.
// 这个照片选择器会自己dismiss，当选择器dismiss的时候，会执行下面的handle
// 你也可以设置autoDismiss属性为NO，选择器就不会自己dismis了
// 如果isSelectOriginalPhoto为YES，表明用户选择了原图
// 你可以通过一个asset获得原图，通过这个方法：[[TZImageManager manager] getOriginalPhotoWithAsset:completion:]
// photos数组里的UIImage对象，默认是828像素宽，你可以通过设置photoWidth属性的值来改变它
- (void)imagePickerController:(HLImagePickerController *)picker didFinishPickingPhotos:(NSArray<UIImage *> *)photos sourceAssets:(NSArray *)assets isSelectOriginalPhoto:(BOOL)isSelectOriginalPhoto;
- (void)imagePickerController:(HLImagePickerController *)picker didFinishPickingPhotos:(NSArray<UIImage *> *)photos sourceAssets:(NSArray *)assets isSelectOriginalPhoto:(BOOL)isSelectOriginalPhoto infos:(NSArray<NSDictionary *> *)infos;
- (void)imagePickerControllerDidCancel:(HLImagePickerController *)picker;
// If user picking a video, this callback will be called.
// If system version > iOS8,asset is kind of PHAsset class, else is ALAsset class.
// 如果用户选择了一个视频，下面的handle会被执行
// 如果系统版本大于iOS8，asset是PHAsset类的对象，否则是ALAsset类的对象
- (void)imagePickerController:(HLImagePickerController *)picker didFinishPickingVideo:(UIImage *)coverImage sourceAssets:(id)asset;

@end
