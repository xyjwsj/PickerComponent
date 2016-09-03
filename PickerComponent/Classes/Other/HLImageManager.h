//
//  HLImageManager.h
//  ImagePickerComponent
//
//  Created by Hoolai on 16/8/27.
//  Copyright © 2016年 wsj_proj. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HLAlbumModel.h"
#import "HLAssetModel.h"

@interface HLImageManager : NSObject

@property (nonatomic, assign) BOOL shouldFixOrientation;

/// Default is 600px / 默认600像素宽
@property (nonatomic, assign) CGFloat photoPreviewMaxWidth;

/// Default is 4, Use in photos collectionView in TZPhotoPickerController
/// 默认4列, TZPhotoPickerController中的照片collectionView
@property (nonatomic, assign) NSInteger columnNumber;

/// Sort photos ascending by modificationDate，Default is YES
/// 对照片排序，按修改时间升序，默认是YES。如果设置为NO,最新的照片会显示在最前面，内部的拍照按钮会排在第一个
@property (nonatomic, assign) BOOL sortAscendingByModificationDate;

@property (nonatomic, strong) PHCachingImageManager *cachingImageManager;

+ (instancetype)manager;

/// Return YES if Authorized 返回YES如果得到了授权
- (BOOL)authorizationStatusAuthorized;

- (void)cameraRollAlbum:(void (^)(HLAlbumModel *model))completion;

- (void)allAlbums:(void (^)(NSArray<HLAlbumModel *>*models))completion;

- (void)assetsFromFetchResult:(id)result completion:(void (^)(NSArray<HLAssetModel *> *))completion;

/// Get photo 获得照片
- (void)postImageWithAlbumModel:(HLAlbumModel *)model completion:(void (^)(UIImage *postImage))completion;

- (void)photoWithAlbumModel:(HLAlbumModel *)model completion:(void (^)(UIImage *postImage))completion;

- (PHImageRequestID)photoWithAsset:(id)asset completion:(void (^)(UIImage *photo,NSDictionary *info,BOOL isDegraded))completion;;

- (PHImageRequestID)photoWithAsset:(id)asset photoWidth:(CGFloat)photoWidth completion:(void (^)(UIImage *, NSDictionary *, BOOL isDegraded))completion;

- (void)photosBytesWithArray:(NSArray *)photos completion:(void (^)(NSString *totalBytes))completion;

/// Judge is a assets array contain the asset 判断一个assets数组是否包含这个asset
- (BOOL)isAssetsArray:(NSArray *)assets containAsset:(id)asset;

- (NSString *)getAssetIdentifier:(id)asset;

- (BOOL)isCameraRollAlbum:(NSString *)albumName;

- (BOOL)checkAvisibleAlbum:(NSString*)albumName;

@end
