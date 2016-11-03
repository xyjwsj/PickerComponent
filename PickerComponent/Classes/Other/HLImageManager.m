//
//  HLImageManager.m
//  ImagePickerComponent
//
//  Created by Hoolai on 16/8/27.
//  Copyright © 2016年 wsj_proj. All rights reserved.
//

#import "HLImageManager.h"

@interface HLImageManager()
@property (nonatomic, strong) NSMutableDictionary* albumNames;
@property (nonatomic, assign) CGSize assetGridThumbnailSize;
@property (nonatomic, assign) CGFloat HLScreenScale;

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
@property (nonatomic, strong) ALAssetsLibrary *assetLibrary;
#pragma clang diagnostic pop

@end

@implementation HLImageManager

+ (instancetype)manager {
    static dispatch_once_t once;
    static HLImageManager* instance = nil;
    dispatch_once(&once, ^{
        instance = [[HLImageManager alloc] init];
        
        if (iOS8Later) {
            instance.cachingImageManager = [[PHCachingImageManager alloc] init];
            // manager.cachingImageManager.allowsCachingHighQualityImages = YES;
        }
        
    });
    return instance;
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
- (ALAssetsLibrary *)assetLibrary {
    if (_assetLibrary == nil) _assetLibrary = [[ALAssetsLibrary alloc] init];
#pragma clang diagnostic pop
    return _assetLibrary;
}

- (instancetype)init {
    if (self = [super init]) {
        _HLScreenScale = 2.0;
        if (SCREEN_WIDTH > 700) {
            _HLScreenScale = 1.5;
        }
    }
    return self;
}

- (void)setColumnNumber:(NSInteger)columnNumber {
    _columnNumber = columnNumber;
    CGFloat margin = 4;
    CGFloat itemWH = (SCREEN_WIDTH - 2 * margin - 4) / columnNumber - margin;
    _assetGridThumbnailSize = CGSizeMake(itemWH * _HLScreenScale, itemWH * _HLScreenScale);
}

/// Return YES if Authorized 返回YES如果得到了授权
- (BOOL)authorizationStatusAuthorized {
    if (iOS8Later) {
        if ([PHPhotoLibrary authorizationStatus] == PHAuthorizationStatusAuthorized) return YES;
    } else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        if ([ALAssetsLibrary authorizationStatus] == ALAuthorizationStatusAuthorized) return YES;
#pragma clang diagnostic pop
    }
    return NO;
}

- (void)cameraRollAlbum:(void (^)(HLAlbumModel *model))completion {
    
    __block HLAlbumModel *model;
    if (iOS8Later) {
        PHFetchOptions *option = [[PHFetchOptions alloc] init];
    //    option.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:YES]];
        // 获得所有的自定义相簿
        PHFetchResult<PHAssetCollection *> *assetCollections = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:option];
        
        //遍历相册
        for (PHAssetCollection* collection in assetCollections) {
            
            if ([self checkAvisibleAlbum:collection.localizedTitle]) {
                PHFetchResult* fetchResult = [PHAsset fetchAssetsInAssetCollection:collection options:nil];
                
                //self为单例，忽略 __block
                model = [self albumModelResult:fetchResult name:collection.localizedTitle];
                if (completion) {
                    completion(model);
                }
            }
        }
    } else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        [self.assetLibrary enumerateGroupsWithTypes:ALAssetsGroupAll usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
            if ([group numberOfAssets] < 1) return;
            NSString *name = [group valueForProperty:ALAssetsGroupPropertyName];
#pragma clang diagnostic pop
            if ([self isCameraRollAlbum:name]) {
                model = [self albumModelResult:group name:name];
                if (completion) {
                    completion(model);
                }
                *stop = YES;
            }
        } failureBlock:nil];
    }
}

- (void)allAlbums:(void (^)(NSArray<HLAlbumModel *>*models))completion {
    NSMutableArray* modelArray = [NSMutableArray array];
    HLAlbumModel *model;
    if (iOS8Later) {
        PHFetchOptions *option = [[PHFetchOptions alloc] init];
    //    option.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:YES]];
        // 系统智能相册
        PHFetchResult<PHAssetCollection *> *systemAssetCollections = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:option];
        
        //遍历相册
        for (PHAssetCollection* collection in systemAssetCollections) {

            PHFetchResult* fetchResult = [PHAsset fetchAssetsInAssetCollection:collection options:nil];
            if (fetchResult.count == 0) {
                continue;
            }
            if ([collection.localizedTitle containsString:@"Deleted"] || [collection.localizedTitle isEqualToString:@"最近删除"]) {
                continue;
            }
            if ([collection.localizedTitle containsString:@"Videos"] || [collection.localizedTitle isEqualToString:@"视频"]) {
                continue;
            }
            if ([self checkAvisibleAlbum:collection.localizedTitle]) {
                //self为单例，忽略 __block
                model = [self albumModelResult:fetchResult name:collection.localizedTitle];
                [modelArray insertObject:model atIndex:0];
            } else {
                model = [self albumModelResult:fetchResult name:collection.localizedTitle];
                [modelArray addObject:model];
            }
        }
        
        PHFetchResult<PHAssetCollection *> *userAssetCollections = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:option];
        
        //遍历相册
        for (PHAssetCollection* collection in userAssetCollections) {
            PHFetchResult* fetchResult = [PHAsset fetchAssetsInAssetCollection:collection options:nil];
            
            if (fetchResult.count == 0) {
                continue;
            }
            model = [self albumModelResult:fetchResult name:collection.localizedTitle];
            [modelArray addObject:model];
        }

        if (completion) {
            completion(modelArray);
        }
    } else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        [self.assetLibrary enumerateGroupsWithTypes:ALAssetsGroupAll usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
#pragma clang diagnostic pop
            if (group == nil) {
                if (completion && modelArray.count > 0) completion(modelArray);
            }
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
            if ([group numberOfAssets] < 1) return;
            NSString *name = [group valueForProperty:ALAssetsGroupPropertyName];
#pragma clang diagnostic pop
            if ([self isCameraRollAlbum:name]) {
                [modelArray insertObject:[self albumModelResult:group name:name] atIndex:0];
            } else if ([name isEqualToString:@"My Photo Stream"] || [name isEqualToString:@"我的照片流"]) {
                if (modelArray.count) {
                    [modelArray insertObject:[self albumModelResult:group name:name] atIndex:1];
                } else {
                    [modelArray addObject:[self albumModelResult:group name:name]];
                }
            } else {
                [modelArray addObject:[self albumModelResult:group name:name]];
            }
        } failureBlock:nil];
    }
}

- (void)assetsFromFetchResult:(id)result completion:(void (^)(NSArray<HLAssetModel *> *))completion {
    NSMutableArray* assets = [NSMutableArray array];
    
    if ([result isKindOfClass:[PHFetchResult class]]) {
        PHFetchResult* fetchResult = (PHFetchResult*)result;
        [fetchResult enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            PHAsset *asset = (PHAsset *)obj;
            HLAssetModelMediaType type = HLAssetModelMediaTypePhoto;
            
            if (asset.mediaType == PHAssetMediaTypeVideo)
                return;
            else if (asset.mediaType == PHAssetMediaTypeAudio)
                return;
            else if (asset.mediaType == PHAssetMediaTypeImage) {
                
            }
            [assets addObject:[self assetModel:asset type:type]];
        }];
        if (completion) {
            completion(assets);
        }
        
    } else if ([result isKindOfClass:[ALAssetsGroup class]]) {
        ALAssetsGroup *group = (ALAssetsGroup *)result;
        [group setAssetsFilter:[ALAssetsFilter allPhotos]];
        ALAssetsGroupEnumerationResultsBlock resultBlock = ^(ALAsset *result, NSUInteger index, BOOL *stop)  {
#pragma clang diagnostic pop
            if (result == nil) {
                if (completion) completion(assets);
            }
            HLAssetModelMediaType type = HLAssetModelMediaTypePhoto;
            /// Allow picking video
            [assets addObject:[HLAssetModel modelWithAsset:result type:type]];
        };
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        if (self.sortAscendingByModificationDate) {
            [group enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
                if (resultBlock) { resultBlock(result,index,stop); }
#pragma clang diagnostic pop
            }];
        } else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
            [group enumerateAssetsWithOptions:NSEnumerationReverse usingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
#pragma clang diagnostic pop
                if (resultBlock) { resultBlock(result,index,stop); }
            }];
        }
    }
}

/// Get postImage / 获取封面图
- (void)postImageWithAlbumModel:(HLAlbumModel *)model completion:(void (^)(UIImage *))completion {
    if (iOS8Later) {
        id asset = [model.result lastObject];
        if (!self.sortAscendingByModificationDate) {
            asset = [model.result firstObject];
        }
        [[HLImageManager manager] photoWithAsset:asset photoWidth:80 completion:^(UIImage *photo, NSDictionary *info, BOOL isDegraded) {
            if (completion) completion(photo);
        }];
    } else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        ALAssetsGroup *group = model.result;
        UIImage *postImage = [UIImage imageWithCGImage:group.posterImage];
#pragma clang diagnostic pop
        if (completion) completion(postImage);
    }
}

- (void)photoWithAlbumModel:(HLAlbumModel *)model completion:(void (^)(UIImage *))completion {
    if (iOS8Later) {
        id asset = [model.result lastObject];
        [[HLImageManager manager] photoWithAsset:asset photoWidth:80 completion:^(UIImage *photo, NSDictionary *info, BOOL isDegraded) {
            if (completion) completion(photo);
        }];
    } else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        ALAssetsGroup *group = model.result;
        UIImage *postImage = [UIImage imageWithCGImage:group.posterImage];
#pragma clang diagnostic pop
        if (completion) completion(postImage);
    }

}

- (void)photosBytesWithArray:(NSArray *)photos completion:(void (^)(NSString * bytes))completion {
    __block NSInteger dataLength = 0;
    __block NSInteger assetCount = 0;
    
    for (HLAssetModel* model in photos) {
        if ([model.asset isKindOfClass:[PHAsset class]]) {
            [[PHImageManager defaultManager] requestImageDataForAsset:model.asset options:nil resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
                if (model.type != HLAssetModelMediaTypeVideo){
                    dataLength += imageData.length;
                }
                assetCount ++;
                if (assetCount >= photos.count) {
                    NSString *bytes = [self bytesFromDataLength:dataLength];
                    if (completion) completion(bytes);
                }
            }];
        }
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        if ([model.asset isKindOfClass:[ALAsset class]]) {
            ALAssetRepresentation *representation = [model.asset defaultRepresentation];
            if (model.type != HLAssetModelMediaTypeVideo) dataLength += (NSInteger)representation.size;
#pragma clang diagnostic pop
            assetCount ++;
            if (assetCount >= photos.count) {
                NSString *bytes = [self bytesFromDataLength:dataLength];
                if (completion) completion(bytes);
            }
        }
    }
    
}

- (BOOL)isAssetsArray:(NSArray *)assets containAsset:(id)asset {
    if (iOS8Later) {
        return [assets containsObject:asset];
    } else {
        NSMutableArray *selectedAssetUrls = [NSMutableArray array];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        for (ALAsset *asset_item in assets) {
            [selectedAssetUrls addObject:[asset_item valueForProperty:ALAssetPropertyURLs]];
        }
        return [selectedAssetUrls containsObject:[asset valueForProperty:ALAssetPropertyURLs]];
#pragma clang diagnostic pop
    }
}

- (BOOL)isCameraRollAlbum:(NSString *)albumName {
    NSString *versionStr = [[UIDevice currentDevice].systemVersion stringByReplacingOccurrencesOfString:@"." withString:@""];
    if (versionStr.length <= 1) {
        versionStr = [versionStr stringByAppendingString:@"00"];
    } else if (versionStr.length <= 2) {
        versionStr = [versionStr stringByAppendingString:@"0"];
    }
    CGFloat version = versionStr.floatValue;
    // 目前已知8.0.0 - 8.0.2系统，拍照后的图片会保存在最近添加中
    if (version >= 800 && version <= 802) {
        return [albumName isEqualToString:@"最近添加"] || [albumName isEqualToString:@"Recently Added"];
    } else {
        return [albumName isEqualToString:@"Camera Roll"] || [albumName isEqualToString:@"相机胶卷"] || [albumName isEqualToString:@"所有照片"] || [albumName isEqualToString:@"All Photos"];
    }
}

- (NSString *)getAssetIdentifier:(id)asset {
    if (iOS8Later) {
        PHAsset *phAsset = (PHAsset *)asset;
        return phAsset.localIdentifier;
    } else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        ALAsset *alAsset = (ALAsset *)asset;
        NSURL *assetUrl = [alAsset valueForProperty:ALAssetPropertyAssetURL];
#pragma clang diagnostic pop
        return assetUrl.absoluteString;
    }
}


#pragma -private method
/**
 *  确定显示哪几个相册
 *
 *  @param name 相册名
 *
 *  @return 是否支持
 */
- (BOOL)checkAvisibleAlbum:(NSString*)albumName {
    NSString *versionStr = [[UIDevice currentDevice].systemVersion stringByReplacingOccurrencesOfString:@"." withString:@""];
    if (versionStr.length <= 1) {
        versionStr = [versionStr stringByAppendingString:@"00"];
    } else if (versionStr.length <= 2) {
        versionStr = [versionStr stringByAppendingString:@"0"];
    }
    CGFloat version = versionStr.floatValue;
    // 目前已知8.0.0 - 8.0.2系统，拍照后的图片会保存在最近添加中
    if (version >= 800 && version <= 802) {
        return [albumName isEqualToString:@"最近添加"] || [albumName isEqualToString:@"Recently Added"];
    } else {
        return [albumName isEqualToString:@"Camera Roll"] || [albumName isEqualToString:@"相机胶卷"] || [albumName isEqualToString:@"所有照片"] || [albumName isEqualToString:@"All Photos"];
    }
}

- (NSString *)bytesFromDataLength:(NSInteger)dataLength {
    NSString *bytes;
    if (dataLength >= 0.1 * (1024 * 1024)) {
        bytes = [NSString stringWithFormat:@"%0.1fM",dataLength/1024/1024.0];
    } else if (dataLength >= 1024) {
        bytes = [NSString stringWithFormat:@"%0.0fK",dataLength/1024.0];
    } else {
        bytes = [NSString stringWithFormat:@"%zdB",dataLength];
    }
    return bytes;
}

- (HLAlbumModel*)albumModelResult:(id)result name:(NSString*)name {
    HLAlbumModel* model = [[HLAlbumModel alloc] init];
    model.result = result;
    model.name = name;
    if ([result isKindOfClass:[PHFetchResult class]]) {
        model.count = [(PHFetchResult*)result count];
    }
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    if ([result isKindOfClass:[ALAssetsGroup class]]) {
        model.count = [(ALAssetsGroup*)result numberOfAssets];
    }
#pragma clang diagnostic pop
    return model;
}

- (HLAssetModel*)assetModel:(id)asset type:(HLAssetModelMediaType)type{
    HLAssetModel* assetModel = [HLAssetModel modelWithAsset:asset type:type];
    if ([asset isKindOfClass:[PHAsset class]]) {
        PHAsset* phAsse = (PHAsset*)asset;
        
    }
    if ([asset isKindOfClass:[ALAsset class]]) {
        
    }
    return assetModel;
}

/// Get photo 获得照片本身
- (PHImageRequestID)photoWithAsset:(id)asset completion:(void (^)(UIImage *, NSDictionary *, BOOL isDegraded))completion {
    CGFloat fullScreenWidth = SCREEN_WIDTH;
    if (fullScreenWidth > _photoPreviewMaxWidth) {
        fullScreenWidth = _photoPreviewMaxWidth;
    }
    return [self photoWithAsset:asset photoWidth:fullScreenWidth completion:completion];
}

- (PHImageRequestID)photoWithAsset:(id)asset photoWidth:(CGFloat)photoWidth completion:(void (^)(UIImage *, NSDictionary *, BOOL isDegraded))completion {
    
    if ([asset isKindOfClass:[PHAsset class]]) {
        CGSize imageSize;
        if (photoWidth < SCREEN_WIDTH && photoWidth < _photoPreviewMaxWidth) {
            imageSize = _assetGridThumbnailSize;
        } else {
            PHAsset *phAsset = (PHAsset *)asset;
            CGFloat aspectRatio = phAsset.pixelWidth / (CGFloat)phAsset.pixelHeight;
            CGFloat pixelWidth = photoWidth * _HLScreenScale;
            CGFloat pixelHeight = pixelWidth / aspectRatio;
            imageSize = CGSizeMake(pixelWidth, pixelHeight);
        }
    
        PHImageRequestOptions *option = [[PHImageRequestOptions alloc] init];
        option.resizeMode = PHImageRequestOptionsResizeModeFast;
        PHImageRequestID imageRequestID = [[PHImageManager defaultManager] requestImageForAsset:asset targetSize:imageSize contentMode:PHImageContentModeAspectFill options:option resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
            BOOL downloadFinined = (![[info objectForKey:PHImageCancelledKey] boolValue] && ![info objectForKey:PHImageErrorKey]);
            if (downloadFinined && result) {
                result = [self fixOrientation:result];
                if (completion) completion(result,info,[[info objectForKey:PHImageResultIsDegradedKey] boolValue]);
            }
            // Download image from iCloud / 从iCloud下载图片
            if ([info objectForKey:PHImageResultIsInCloudKey] && !result) {
                PHImageRequestOptions *option = [[PHImageRequestOptions alloc]init];
                option.networkAccessAllowed = YES;
                option.resizeMode = PHImageRequestOptionsResizeModeFast;
                [[PHImageManager defaultManager] requestImageDataForAsset:asset options:option resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
                    UIImage *resultImage = [UIImage imageWithData:imageData scale:0.1];
                    resultImage = [self scaleImage:resultImage toSize:imageSize];
                    if (resultImage) {
                        resultImage = [self fixOrientation:resultImage];
                        if (completion) completion(resultImage,info,[[info objectForKey:PHImageResultIsDegradedKey] boolValue]);
                    }
                }];
            }
        }];
        return imageRequestID;
        
//        PHImageRequestOptions *option = [[PHImageRequestOptions alloc] init];
//        option.resizeMode = PHImageRequestOptionsResizeModeFast;
//        [[PHImageManager defaultManager] requestImageDataForAsset:asset options:option resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
//            UIImage *resultImage = [UIImage imageWithData:imageData scale:0.1];
//            resultImage = [self scaleImage:resultImage toSize:imageSize];
//            if (resultImage) {
//                resultImage = [self fixOrientation:resultImage];
//                if (completion) completion(resultImage,info,[[info objectForKey:PHImageResultIsDegradedKey] boolValue]);
//            }
//        }];
//        return imageRequestID;
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    } else if ([asset isKindOfClass:[ALAsset class]]) {
        ALAsset *alAsset = (ALAsset *)asset;
        dispatch_async(dispatch_get_global_queue(0,0), ^{
            CGImageRef thumbnailImageRef = alAsset.thumbnail;
            UIImage *thumbnailImage = [UIImage imageWithCGImage:thumbnailImageRef scale:2.0 orientation:UIImageOrientationUp];
#pragma clang diagnostic pop
            dispatch_async(dispatch_get_main_queue(), ^{
                if (completion) completion(thumbnailImage,nil,YES);
                
                if (photoWidth == SCREEN_WIDTH || photoWidth == _photoPreviewMaxWidth) {
                    dispatch_async(dispatch_get_global_queue(0,0), ^{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
                        ALAssetRepresentation *assetRep = [alAsset defaultRepresentation];
                        CGImageRef fullScrennImageRef = [assetRep fullScreenImage];
#pragma clang diagnostic pop
                        UIImage *fullScrennImage = [UIImage imageWithCGImage:fullScrennImageRef scale:2.0 orientation:UIImageOrientationUp];
                        
                        dispatch_async(dispatch_get_main_queue(), ^{
                            if (completion) completion(fullScrennImage,nil,NO);
                        });
                    });
                }
            });
        });
    }
    return 0;
}

- (UIImage *)scaleImage:(UIImage *)image toSize:(CGSize)size {
    if (image.size.width > size.width) {
        UIGraphicsBeginImageContext(size);
        [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
        UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return newImage;
    } else {
        return image;
    }
}

- (UIImage *)fixOrientation:(UIImage *)aImage {
    if (!self.shouldFixOrientation)
        return aImage;
    
    // No-op if the orientation is already correct
    if (aImage.imageOrientation == UIImageOrientationUp)
        return aImage;
    
    // We need to calculate the proper transformation to make the image upright.
    // We do it in 2 steps: Rotate if Left/Right/Down, and then flip if Mirrored.
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    switch (aImage.imageOrientation) {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, aImage.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, aImage.size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
        default:
            break;
    }
    
    switch (aImage.imageOrientation) {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        default:
            break;
    }
    
    // Now we draw the underlying CGImage into a new context, applying the transform
    // calculated above.
    CGContextRef ctx = CGBitmapContextCreate(NULL, aImage.size.width, aImage.size.height,
                                             CGImageGetBitsPerComponent(aImage.CGImage), 0,
                                             CGImageGetColorSpace(aImage.CGImage),
                                             CGImageGetBitmapInfo(aImage.CGImage));
    CGContextConcatCTM(ctx, transform);
    switch (aImage.imageOrientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            // Grr...
            CGContextDrawImage(ctx, CGRectMake(0,0,aImage.size.height,aImage.size.width), aImage.CGImage);
            break;
            
        default:
            CGContextDrawImage(ctx, CGRectMake(0,0,aImage.size.width,aImage.size.height), aImage.CGImage);
            break;
    }
    
    // And now we just create a new UIImage from the drawing context
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    return img;
}

@end
