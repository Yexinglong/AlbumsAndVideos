//
//  NYImageManager.m
//  DDNM-NY
//
//  Created by 叶星龙 on 2016/12/29.
//  Copyright © 2016年 北京叮咚柠檬科技有限公司. All rights reserved.
//

#import "NYImageManager.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "NYAssetModel.h"

#define iOS7Later ([UIDevice currentDevice].systemVersion.floatValue >= 7.0f)
#define iOS8Later ([UIDevice currentDevice].systemVersion.floatValue >= 8.0f)
#define iOS9Later ([UIDevice currentDevice].systemVersion.floatValue >= 9.0f)
#define iOS9_1Later ([UIDevice currentDevice].systemVersion.floatValue >= 9.1f)

@interface NYImageManager ()
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
@property (nonatomic, strong) ALAssetsLibrary *assetLibrary;
@end

@implementation NYImageManager

static CGSize AssetGridThumbnailSize;
static CGFloat NYScreenWidth;
static CGFloat NYScreenScale;

+ (instancetype)manager {
    static NYImageManager *manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[self alloc] init];
        if (iOS8Later) {
            manager.cachingImageManager = [[PHCachingImageManager alloc] init];
        }
        NYScreenWidth = [UIScreen mainScreen].bounds.size.width;
        // 测试发现，如果scale在plus真机上取到3.0，内存会增大特别多。故这里写死成2.0
        NYScreenScale = 2.0;
        if (NYScreenWidth > 700) {
            NYScreenScale = 1.5;
        }
        manager.columnNumber=4;
        manager.photoPreviewMaxWidth=600;
        manager.sortAscendingByModificationDate=NO;
    });
    return manager;
}

- (void)setColumnNumber:(NSInteger)columnNumber {
    _columnNumber = columnNumber;
    CGFloat margin = 4;
    CGFloat itemWH = (NYScreenWidth - 2 * margin - 4) / columnNumber - margin;
    AssetGridThumbnailSize = CGSizeMake(itemWH * NYScreenScale, itemWH * NYScreenScale);
}

- (ALAssetsLibrary *)assetLibrary {
    if (_assetLibrary == nil) _assetLibrary = [[ALAssetsLibrary alloc] init];
    return _assetLibrary;
}

/// Return YES if Authorized 返回YES如果得到了授权
- (BOOL)authorizationStatusAuthorized {
    return [self authorizationStatus] == 3;
}

- (NSInteger)authorizationStatus {
    if (iOS8Later) {
        return [PHPhotoLibrary authorizationStatus];
    } else {
        return [ALAssetsLibrary authorizationStatus];
    }
    return NO;
}

#pragma mark - Get Album

/// Get Album 获得相册/相册数组
- (void)getCameraRollAlbum:(BOOL)allowPickingVideo allowPickingImage:(BOOL)allowPickingImage completion:(void (^)(NYAlbumModel *))completion{
    __block NYAlbumModel *model;
    if (iOS8Later) {
        PHFetchOptions *option = [[PHFetchOptions alloc] init];
        if (!allowPickingVideo) option.predicate = [NSPredicate predicateWithFormat:@"mediaType == %ld", PHAssetMediaTypeImage];
        if (!allowPickingImage) option.predicate = [NSPredicate predicateWithFormat:@"mediaType == %ld",
                                                    PHAssetMediaTypeVideo];
        // option.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"modificationDate" ascending:self.sortAscendingByModificationDate]];
        if (!self.sortAscendingByModificationDate) {
            option.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:self.sortAscendingByModificationDate]];
        }
        PHFetchResult *smartAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
        for (PHAssetCollection *collection in smartAlbums) {
            // 有可能是PHCollectionList类的的对象，过滤掉
            if (![collection isKindOfClass:[PHAssetCollection class]]) continue;
                if ([self isCameraRollAlbum:collection.localizedTitle]) {
            //if([collection.localizedTitle isEqualToString:@"Panoramas"]){
                PHFetchResult *fetchResult = [PHAsset fetchAssetsInAssetCollection:collection options:option];
                model = [self modelWithResult:fetchResult name:collection.localizedTitle];
                if (completion) completion(model);
                break;
            }
        }
    } else {
        [self.assetLibrary enumerateGroupsWithTypes:ALAssetsGroupAll usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
            if ([group numberOfAssets] < 1) return;
            NSString *name = [group valueForProperty:ALAssetsGroupPropertyName];
            if ([self isCameraRollAlbum:name]) {
                model = [self modelWithResult:group name:name];
                if (completion) completion(model);
                *stop = YES;
            }
        } failureBlock:nil];
    }
}

- (void)getAllAlbums:(BOOL)allowPickingVideo allowPickingImage:(BOOL)allowPickingImage completion:(void (^)(NSArray<NYAlbumModel *> *))completion{
    NSMutableArray *albumArr = [NSMutableArray array];
    if (iOS8Later) {
        PHFetchOptions *option = [[PHFetchOptions alloc] init];
        if (!allowPickingVideo) option.predicate = [NSPredicate predicateWithFormat:@"mediaType == %ld", PHAssetMediaTypeImage];
        if (!allowPickingImage) option.predicate = [NSPredicate predicateWithFormat:@"mediaType == %ld",
                                                    PHAssetMediaTypeVideo];
        // option.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"modificationDate" ascending:self.sortAscendingByModificationDate]];
        if (!self.sortAscendingByModificationDate) {
            option.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:self.sortAscendingByModificationDate]];
        }
        // 我的照片流 1.6.10重新加入..
        PHFetchResult *smartAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
        PHFetchResult *topLevelUserCollections = [PHCollectionList fetchTopLevelUserCollectionsWithOptions:nil];
        PHFetchResult *syncedAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumSyncedAlbum options:nil];
        NSArray *allAlbums = @[smartAlbums,topLevelUserCollections,syncedAlbums];
        for (PHFetchResult *fetchResult in allAlbums) {
            for (PHAssetCollection *collection in fetchResult) {
                // 有可能是PHCollectionList类的的对象，过滤掉
                if (![collection isKindOfClass:[PHAssetCollection class]]) continue;
                PHFetchResult *fetchResult = [PHAsset fetchAssetsInAssetCollection:collection options:option];
                if (fetchResult.count < 1) continue;
                if ([collection.localizedTitle containsString:@"Deleted"] || [collection.localizedTitle isEqualToString:@"最近删除"]) continue;
                if ([self isCameraRollAlbum:collection.localizedTitle]) {
                    [albumArr insertObject:[self modelWithResult:fetchResult name:collection.localizedTitle] atIndex:0];
                } else {
                    [albumArr addObject:[self modelWithResult:fetchResult name:collection.localizedTitle]];
                }
            }
        }
        if (completion && albumArr.count > 0) completion(albumArr);
    } else {
        [self.assetLibrary enumerateGroupsWithTypes:ALAssetsGroupAll usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
            if (group == nil) {
                if (completion && albumArr.count > 0) completion(albumArr);
            }
            if ([group numberOfAssets] < 1) return;
            NSString *name = [group valueForProperty:ALAssetsGroupPropertyName];
            if ([self isCameraRollAlbum:name]) {
                [albumArr insertObject:[self modelWithResult:group name:name] atIndex:0];
            } else if ([name isEqualToString:@"My Photo Stream"] || [name isEqualToString:@"我的照片流"]) {
                if (albumArr.count) {
                    [albumArr insertObject:[self modelWithResult:group name:name] atIndex:1];
                } else {
                    [albumArr addObject:[self modelWithResult:group name:name]];
                }
            } else {
                [albumArr addObject:[self modelWithResult:group name:name]];
            }
        } failureBlock:nil];
    }
}

#pragma mark - Get Assets

/// Get Assets 获得照片数组
- (void)getAssetsFromFetchResult:(id)result allowPickingVideo:(BOOL)allowPickingVideo allowPickingImage:(BOOL)allowPickingImage completion:(void (^)(NSArray<NYAssetModel *> *))completion {
    NSMutableArray *photoArr = [NSMutableArray array];
    if ([result isKindOfClass:[PHFetchResult class]]) {
        PHFetchResult *fetchResult = (PHFetchResult *)result;
        [fetchResult enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NYAssetModel *model = [self assetModelWithAsset:obj allowPickingVideo:allowPickingVideo allowPickingImage:allowPickingImage];
            if (model) {
                [photoArr addObject:model];
            }
        }];
        if (completion) completion(photoArr);
    } else if ([result isKindOfClass:[ALAssetsGroup class]]) {
        ALAssetsGroup *group = (ALAssetsGroup *)result;
        if (allowPickingImage && allowPickingVideo) {
            [group setAssetsFilter:[ALAssetsFilter allAssets]];
        } else if (allowPickingVideo) {
            [group setAssetsFilter:[ALAssetsFilter allVideos]];
        } else if (allowPickingImage) {
            [group setAssetsFilter:[ALAssetsFilter allPhotos]];
        }
        ALAssetsGroupEnumerationResultsBlock resultBlock = ^(ALAsset *result, NSUInteger index, BOOL *stop)  {
            if (result == nil) {
                if (completion) completion(photoArr);
            }
            NYAssetModel *model = [self assetModelWithAsset:result allowPickingVideo:allowPickingVideo allowPickingImage:allowPickingImage];
            if (model) {
                [photoArr addObject:model];
            }
        };
        if (self.sortAscendingByModificationDate) {
            [group enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
                if (resultBlock) { resultBlock(result,index,stop); }
            }];
        } else {
            [group enumerateAssetsWithOptions:NSEnumerationReverse usingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
                if (resultBlock) { resultBlock(result,index,stop); }
            }];
        }
    }
}

///  Get asset at index 获得下标为index的单个照片
///  if index beyond bounds, return nil in callback 如果索引越界, 在回调中返回 nil
- (void)getAssetFromFetchResult:(id)result atIndex:(NSInteger)index allowPickingVideo:(BOOL)allowPickingVideo allowPickingImage:(BOOL)allowPickingImage completion:(void (^)(NYAssetModel *))completion {
    if ([result isKindOfClass:[PHFetchResult class]]) {
        PHFetchResult *fetchResult = (PHFetchResult *)result;
        PHAsset *asset;
        @try {
            asset = fetchResult[index];
        }
        @catch (NSException* e) {
            if (completion) completion(nil);
            return;
        }
        NYAssetModel *model = [self assetModelWithAsset:asset allowPickingVideo:allowPickingVideo allowPickingImage:allowPickingImage];
        if (completion) completion(model);
    } else if ([result isKindOfClass:[ALAssetsGroup class]]) {
        ALAssetsGroup *group = (ALAssetsGroup *)result;
        if (allowPickingImage && allowPickingVideo) {
            [group setAssetsFilter:[ALAssetsFilter allAssets]];
        } else if (allowPickingVideo) {
            [group setAssetsFilter:[ALAssetsFilter allVideos]];
        } else if (allowPickingImage) {
            [group setAssetsFilter:[ALAssetsFilter allPhotos]];
        }
        NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:index];
        @try {
            [group enumerateAssetsAtIndexes:indexSet options:NSEnumerationConcurrent usingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
                if (!result) return;
                NYAssetModel *model = [self assetModelWithAsset:result allowPickingVideo:allowPickingVideo allowPickingImage:allowPickingImage];
                if (completion) completion(model);
            }];
        }
        @catch (NSException* e) {
            if (completion) completion(nil);
        }
    }
}

- (NYAssetModel *)assetModelWithAsset:(id)asset allowPickingVideo:(BOOL)allowPickingVideo allowPickingImage:(BOOL)allowPickingImage {
    NYAssetModel *model;
    NYAssetModelMediaType type = NYAssetModelMediaTypePhoto;
    if ([asset isKindOfClass:[PHAsset class]]) {
        PHAsset *phAsset = (PHAsset *)asset;
        if (phAsset.mediaType == PHAssetMediaTypeVideo)      type = NYAssetModelMediaTypeVideo;
        else if (phAsset.mediaType == PHAssetMediaTypeAudio) type = NYAssetModelMediaTypeAudio;
        else if (phAsset.mediaType == PHAssetMediaTypeImage) {
            if (iOS9_1Later) {
                // if (asset.mediaSubtypes == PHAssetMediaSubtypePhotoLive) type = NYAssetModelMediaTypeLivePhoto;
            }
            // Gif
            if ([[phAsset valueForKey:@"filename"] hasSuffix:@"GIF"]) {
                type = NYAssetModelMediaTypePhotoGif;
            }
        }
        if (!allowPickingVideo && type == NYAssetModelMediaTypeVideo) return nil;
        if (!allowPickingImage && type == NYAssetModelMediaTypePhoto) return nil;
        if (!allowPickingImage && type == NYAssetModelMediaTypePhotoGif) return nil;
        
        if (self.hideWhenCanNotSelect) {
            // 过滤掉尺寸不满足要求的图片
            if (![self isPhotoSelectableWithAsset:phAsset]) {
                return nil;
            }
        }
        NSString *timeLength = type == NYAssetModelMediaTypeVideo ? [NSString stringWithFormat:@"%0.0f",phAsset.duration] : @"";
        timeLength = [self getNewTimeFromDurationSecond:timeLength.integerValue];
        model = [NYAssetModel modelWithAsset:asset type:type timeLength:timeLength];
    } else {
        if (!allowPickingVideo){
            model = [NYAssetModel modelWithAsset:asset type:type];
            return model;
        }
        /// Allow picking video
        if ([[asset valueForProperty:ALAssetPropertyType] isEqualToString:ALAssetTypeVideo]) {
            type = NYAssetModelMediaTypeVideo;
            NSTimeInterval duration = [[asset valueForProperty:ALAssetPropertyDuration] integerValue];
            NSString *timeLength = [NSString stringWithFormat:@"%0.0f",duration];
            timeLength = [self getNewTimeFromDurationSecond:timeLength.integerValue];
            model = [NYAssetModel modelWithAsset:asset type:type timeLength:timeLength];
        } else {
            if (self.hideWhenCanNotSelect) {
                // 过滤掉尺寸不满足要求的图片
                if (![self isPhotoSelectableWithAsset:asset]) {
                    return nil;
                }
            }
            model = [NYAssetModel modelWithAsset:asset type:type];
        }
    }
    return model;
}

- (NSString *)getNewTimeFromDurationSecond:(NSInteger)duration {
    NSString *newTime;
    if (duration < 10) {
        newTime = [NSString stringWithFormat:@"0:0%zd",duration];
    } else if (duration < 60) {
        newTime = [NSString stringWithFormat:@"0:%zd",duration];
    } else {
        NSInteger min = duration / 60;
        NSInteger sec = duration - (min * 60);
        if (sec < 10) {
            newTime = [NSString stringWithFormat:@"%zd:0%zd",min,sec];
        } else {
            newTime = [NSString stringWithFormat:@"%zd:%zd",min,sec];
        }
    }
    return newTime;
}

/// Get photo bytes 获得一组照片的大小
- (void)getPhotosBytesWithArray:(NSArray *)photos completion:(void (^)(NSString *totalBytes))completion {
    __block NSInteger dataLength = 0;
    __block NSInteger assetCount = 0;
    for (NSInteger i = 0; i < photos.count; i++) {
        NYAssetModel *model = photos[i];
        if ([model.asset isKindOfClass:[PHAsset class]]) {
            [[PHImageManager defaultManager] requestImageDataForAsset:model.asset options:nil resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
                if (model.type != NYAssetModelMediaTypeVideo) dataLength += imageData.length;
                assetCount ++;
                if (assetCount >= photos.count) {
                    NSString *bytes = [self getBytesFromDataLength:dataLength];
                    if (completion) completion(bytes);
                }
            }];
        } else if ([model.asset isKindOfClass:[ALAsset class]]) {
            ALAssetRepresentation *representation = [model.asset defaultRepresentation];
            if (model.type != NYAssetModelMediaTypeVideo) dataLength += (NSInteger)representation.size;
            if (i >= photos.count - 1) {
                NSString *bytes = [self getBytesFromDataLength:dataLength];
                if (completion) completion(bytes);
            }
        }
    }
}

- (NSString *)getBytesFromDataLength:(NSInteger)dataLength {
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

#pragma mark - Get Photo

/// Get photo 获得照片本身
- (PHImageRequestID)getPhotoWithAsset:(id)asset completion:(void (^)(UIImage *, NSDictionary *, BOOL isDegraded))completion {
    CGFloat fullScreenWidth = NYScreenWidth;
    if (fullScreenWidth > _photoPreviewMaxWidth) {
        fullScreenWidth = _photoPreviewMaxWidth;
    }
    return [self getPhotoWithAsset:asset photoWidth:fullScreenWidth completion:completion progressHandler:nil networkAccessAllowed:YES];
}

- (PHImageRequestID)getPhotoWithAsset:(id)asset photoWidth:(CGFloat)photoWidth completion:(void (^)(UIImage *photo,NSDictionary *info,BOOL isDegraded))completion {
    return [self getPhotoWithAsset:asset photoWidth:photoWidth completion:completion progressHandler:nil networkAccessAllowed:YES];
}

- (PHImageRequestID)getPhotoWithAsset:(id)asset completion:(void (^)(UIImage *photo,NSDictionary *info,BOOL isDegraded))completion progressHandler:(void (^)(double progress, NSError *error, BOOL *stop, NSDictionary *info))progressHandler networkAccessAllowed:(BOOL)networkAccessAllowed {
    CGFloat fullScreenWidth = NYScreenWidth;
    if (fullScreenWidth > _photoPreviewMaxWidth) {
        fullScreenWidth = _photoPreviewMaxWidth;
    }
    return [self getPhotoWithAsset:asset photoWidth:fullScreenWidth completion:completion progressHandler:progressHandler networkAccessAllowed:networkAccessAllowed];
}

- (PHImageRequestID)getPhotoWithAsset:(id)asset photoWidth:(CGFloat)photoWidth completion:(void (^)(UIImage *photo,NSDictionary *info,BOOL isDegraded))completion progressHandler:(void (^)(double progress, NSError *error, BOOL *stop, NSDictionary *info))progressHandler networkAccessAllowed:(BOOL)networkAccessAllowed {
    if ([asset isKindOfClass:[PHAsset class]]) {
        CGSize imageSize;
        if (photoWidth < NYScreenWidth && photoWidth < _photoPreviewMaxWidth) {
            imageSize = AssetGridThumbnailSize;
        } else {
            PHAsset *phAsset = (PHAsset *)asset;
            CGFloat aspectRatio = phAsset.pixelWidth / (CGFloat)phAsset.pixelHeight;
            CGFloat pixelWidth = photoWidth * NYScreenScale;
            CGFloat pixelHeight = pixelWidth / aspectRatio;
            imageSize = CGSizeMake(pixelWidth, pixelHeight);
        }
        // 修复获取图片时出现的瞬间内存过高问题
        // 下面两行代码，来自hsjcom，他的github是：https://github.com/hsjcom 表示感谢
        PHImageRequestOptions *option = [[PHImageRequestOptions alloc] init];
        option.resizeMode = PHImageRequestOptionsResizeModeFast;
        PHImageRequestID imageRequestID = [[PHImageManager defaultManager] requestImageForAsset:asset targetSize:imageSize contentMode:PHImageContentModeAspectFill options:option resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
            BOOL downloadFinined = (![[info objectForKey:PHImageCancelledKey] boolValue] && ![info objectForKey:PHImageErrorKey]);
            if (downloadFinined && result) {
                result = [self fixOrientation:result];
                if (completion) completion(result,info,[[info objectForKey:PHImageResultIsDegradedKey] boolValue]);
            }
            // Download image from iCloud / 从iCloud下载图片
            if ([info objectForKey:PHImageResultIsInCloudKey] && !result && networkAccessAllowed) {
                PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
                options.progressHandler = ^(double progress, NSError *error, BOOL *stop, NSDictionary *info) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (progressHandler) {
                            progressHandler(progress, error, stop, info);
                        }
                    });
                };
                options.networkAccessAllowed = YES;
                options.resizeMode = PHImageRequestOptionsResizeModeFast;
                [[PHImageManager defaultManager] requestImageDataForAsset:asset options:options resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
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
    } else if ([asset isKindOfClass:[ALAsset class]]) {
        ALAsset *alAsset = (ALAsset *)asset;
        dispatch_async(dispatch_get_global_queue(0,0), ^{
            CGImageRef thumbnailImageRef = alAsset.thumbnail;
            UIImage *thumbnailImage = [UIImage imageWithCGImage:thumbnailImageRef scale:2.0 orientation:UIImageOrientationUp];
            dispatch_async(dispatch_get_main_queue(), ^{
                if (completion) completion(thumbnailImage,nil,YES);
                
                if (photoWidth == NYScreenWidth || photoWidth == _photoPreviewMaxWidth) {
                    dispatch_async(dispatch_get_global_queue(0,0), ^{
                        ALAssetRepresentation *assetRep = [alAsset defaultRepresentation];
                        CGImageRef fullScrennImageRef = [assetRep fullScreenImage];
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

/// Get postImage / 获取封面图
- (void)getPostImageWithAlbumModel:(NYAlbumModel *)model completion:(void (^)(UIImage *))completion {
    if (iOS8Later) {
        id asset = [model.result lastObject];
        if (!self.sortAscendingByModificationDate) {
            asset = [model.result firstObject];
        }
        [[NYImageManager manager] getPhotoWithAsset:asset photoWidth:80 completion:^(UIImage *photo, NSDictionary *info, BOOL isDegraded) {
            if (completion) completion(photo);
        }];
    } else {
        ALAssetsGroup *group = model.result;
        UIImage *postImage = [UIImage imageWithCGImage:group.posterImage];
        if (completion) completion(postImage);
    }
}

/// Get Original Photo / 获取原图
- (void)getOriginalPhotoWithAsset:(id)asset completion:(void (^)(UIImage *photo,NSDictionary *info))completion {
    [self getOriginalPhotoWithAsset:asset newCompletion:^(UIImage *photo, NSDictionary *info, BOOL isDegraded) {
        if (completion) {
            completion(photo,info);
        }
    }];
}

- (void)getOriginalPhotoWithAsset:(id)asset newCompletion:(void (^)(UIImage *photo,NSDictionary *info,BOOL isDegraded))completion {
    if ([asset isKindOfClass:[PHAsset class]]) {
        PHImageRequestOptions *option = [[PHImageRequestOptions alloc]init];
        option.networkAccessAllowed = YES;
        [[PHImageManager defaultManager] requestImageForAsset:asset targetSize:PHImageManagerMaximumSize contentMode:PHImageContentModeAspectFit options:option resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
            BOOL downloadFinined = (![[info objectForKey:PHImageCancelledKey] boolValue] && ![info objectForKey:PHImageErrorKey]);
            if (downloadFinined && result) {
                result = [self fixOrientation:result];
                BOOL isDegraded = [[info objectForKey:PHImageResultIsDegradedKey] boolValue];
                if (completion) completion(result,info,isDegraded);
            }
        }];
    } else if ([asset isKindOfClass:[ALAsset class]]) {
        ALAsset *alAsset = (ALAsset *)asset;
        ALAssetRepresentation *assetRep = [alAsset defaultRepresentation];
        
        dispatch_async(dispatch_get_global_queue(0,0), ^{
            CGImageRef originalImageRef = [assetRep fullResolutionImage];
            UIImage *originalImage = [UIImage imageWithCGImage:originalImageRef scale:1.0 orientation:UIImageOrientationUp];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if (completion) completion(originalImage,nil,NO);
            });
        });
    }
}

- (void)getOriginalPhotoDataWithAsset:(id)asset completion:(void (^)(NSData *data,NSDictionary *info,BOOL isDegraded))completion {
    if ([asset isKindOfClass:[PHAsset class]]) {
        PHImageRequestOptions *option = [[PHImageRequestOptions alloc]init];
        option.networkAccessAllowed = YES;
        [[PHImageManager defaultManager] requestImageDataForAsset:asset options:option resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
            BOOL downloadFinined = (![[info objectForKey:PHImageCancelledKey] boolValue] && ![info objectForKey:PHImageErrorKey]);
            if (downloadFinined && imageData) {
                BOOL isDegraded = [[info objectForKey:PHImageResultIsDegradedKey] boolValue];
                if (completion) completion(imageData,info,isDegraded);
            }
        }];
    } else if ([asset isKindOfClass:[ALAsset class]]) {
        ALAsset *alAsset = (ALAsset *)asset;
        ALAssetRepresentation *assetRep = [alAsset defaultRepresentation];
        Byte *imageBuffer = (Byte *)malloc(assetRep.size);
        NSUInteger bufferSize = [assetRep getBytes:imageBuffer fromOffset:0.0 length:assetRep.size error:nil];
        NSData *imageData = [NSData dataWithBytesNoCopy:imageBuffer length:bufferSize freeWhenDone:YES];
        if (completion) completion(imageData,nil,NO);
    }
}

#pragma mark - Save photo
///12-29-叶星龙修改存储图片方式，让GIF图片类型也能存储
- (void)savePhotoWithImage:(id )image completion:(void (^)(id obj,NSError *error))completion {
    NSData *data=nil;
    if ([image isKindOfClass:[NSData class]]) {
        data=image;
    }else{
        int alphaInfo = CGImageGetAlphaInfo([image CGImage]);
        BOOL hasAlpha = !(alphaInfo == kCGImageAlphaNone ||
                          alphaInfo == kCGImageAlphaNoneSkipFirst ||
                          alphaInfo == kCGImageAlphaNoneSkipLast);
        BOOL imageIsPng = hasAlpha;
        if (imageIsPng) {
            data = UIImagePNGRepresentation(image);
        }
        else {
            data = UIImageJPEGRepresentation(image, (CGFloat)1.0);
        }
    }
    if (iOS9Later) {
        [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
            PHAssetResourceCreationOptions *options = [[PHAssetResourceCreationOptions alloc] init];
            options.shouldMoveFile = YES;
            [[PHAssetCreationRequest creationRequestForAsset] addResourceWithType:PHAssetResourceTypePhoto data:data options:options];
        } completionHandler:^(BOOL success, NSError * _Nullable error) {
            dispatch_sync(dispatch_get_main_queue(), ^{
                if (success && completion) {
                    completion([NSNumber numberWithBool:success],nil);
                } else if (error) {
                    NSLog(@"保存照片出错:%@",error.localizedDescription);
                    if (completion) {
                        completion(nil,error);
                    }
                }
            });
        }];
    } else {
        CGImageSourceRef imgSource = CGImageSourceCreateWithData(( CFDataRef)data, NULL);
        NSDictionary *metadata = (NSDictionary *)CFBridgingRelease(CGImageSourceCopyPropertiesAtIndex(imgSource, 0, NULL));
        [self.assetLibrary writeImageDataToSavedPhotosAlbum:data metadata:metadata completionBlock:^(NSURL *assetURL, NSError *error) {
            if (error) {
                NSLog(@"保存图片失败:%@",error.localizedDescription);
                if (completion) {
                    completion(nil,error);
                }
            } else {
                    if (completion) {
                        completion(assetURL,nil);
                    }
            }
        }];
    }
}

#pragma mark - Get Video

/// Get Video / 获取视频
- (void)getVideoWithAsset:(id)asset completion:(void (^)(AVPlayerItem * _Nullable, NSDictionary * _Nullable))completion {
    if ([asset isKindOfClass:[PHAsset class]]) {
        [[PHImageManager defaultManager] requestPlayerItemForVideo:asset options:nil resultHandler:^(AVPlayerItem * _Nullable playerItem, NSDictionary * _Nullable info) {
            if (completion) completion(playerItem,info);
        }];
    } else if ([asset isKindOfClass:[ALAsset class]]) {
        ALAsset *alAsset = (ALAsset *)asset;
        ALAssetRepresentation *defaultRepresentation = [alAsset defaultRepresentation];
        NSString *uti = [defaultRepresentation UTI];
        NSURL *videoURL = [[asset valueForProperty:ALAssetPropertyURLs] valueForKey:uti];
        AVPlayerItem *playerItem = [[AVPlayerItem alloc] initWithURL:videoURL];
        if (completion && playerItem) completion(playerItem,nil);
    }
}

#pragma mark - Export video

/// Export Video / 导出视频
- (void)getVideoOutputPathWithAsset:(id)asset completion:(void (^)(NSString *outputPath))completion {
    if ([asset isKindOfClass:[PHAsset class]]) {
        PHVideoRequestOptions* options = [[PHVideoRequestOptions alloc] init];
        options.version = PHVideoRequestOptionsVersionOriginal;
        options.deliveryMode = PHVideoRequestOptionsDeliveryModeAutomatic;
        options.networkAccessAllowed = YES;
        [[PHImageManager defaultManager] requestAVAssetForVideo:asset options:options resultHandler:^(AVAsset* avasset, AVAudioMix* audioMix, NSDictionary* info){
            // NSLog(@"Info:\n%@",info);
            AVURLAsset *videoAsset = (AVURLAsset*)avasset;
            // NSLog(@"AVAsset URL: %@",myAsset.URL);
            [self startExportVideoWithVideoAsset:videoAsset completion:completion];
        }];
    } else if ([asset isKindOfClass:[ALAsset class]]) {
        NSURL *videoURL =[asset valueForProperty:ALAssetPropertyAssetURL]; // ALAssetPropertyURLs
        AVURLAsset *videoAsset = [[AVURLAsset alloc] initWithURL:videoURL options:nil];
        [self startExportVideoWithVideoAsset:videoAsset completion:completion];
    }
}

- (void)startExportVideoWithVideoAsset:(AVURLAsset *)videoAsset completion:(void (^)(NSString *outputPath))completion {
    // Find compatible presets by video asset.
    NSArray *presets = [AVAssetExportSession exportPresetsCompatibleWithAsset:videoAsset];
    
    // Begin to compress video
    // Now we just compress to low resolution if it supports
    // If you need to upload to the server, but server does't support to upload by streaming,
    // You can compress the resolution to lower. Or you can support more higher resolution.
    if ([presets containsObject:AVAssetExportPreset640x480]) {
        AVAssetExportSession *session = [[AVAssetExportSession alloc]initWithAsset:videoAsset presetName:AVAssetExportPreset640x480];
        
        NSDateFormatter *formater = [[NSDateFormatter alloc] init];
        [formater setDateFormat:@"yyyy-MM-dd-HH:mm:ss"];
        NSString *outputPath = [NSHomeDirectory() stringByAppendingFormat:@"/tmp/output-%@.mp4", [formater stringFromDate:[NSDate date]]];
        NSLog(@"video outputPath = %@",outputPath);
        session.outputURL = [NSURL fileURLWithPath:outputPath];
        
        // Optimize for network use.
        session.shouldOptimizeForNetworkUse = true;
        
        NSArray *supportedTypeArray = session.supportedFileTypes;
        if ([supportedTypeArray containsObject:AVFileTypeMPEG4]) {
            session.outputFileType = AVFileTypeMPEG4;
        } else if (supportedTypeArray.count == 0) {
            NSLog(@"No supported file types 视频类型暂不支持导出");
            return;
        } else {
            session.outputFileType = [supportedTypeArray objectAtIndex:0];
        }
        
        if (![[NSFileManager defaultManager] fileExistsAtPath:[NSHomeDirectory() stringByAppendingFormat:@"/tmp"]]) {
            [[NSFileManager defaultManager] createDirectoryAtPath:[NSHomeDirectory() stringByAppendingFormat:@"/tmp"] withIntermediateDirectories:YES attributes:nil error:nil];
        }
        
        AVMutableVideoComposition *videoComposition = [self fixedCompositionWithAsset:videoAsset];
        if (videoComposition.renderSize.width) {
            // 修正视频转向
            session.videoComposition = videoComposition;
        }
        
        // Begin to export video to the output path asynchronously.
        [session exportAsynchronouslyWithCompletionHandler:^(void) {
            switch (session.status) {
                case AVAssetExportSessionStatusUnknown:
                    NSLog(@"AVAssetExportSessionStatusUnknown"); break;
                case AVAssetExportSessionStatusWaiting:
                    NSLog(@"AVAssetExportSessionStatusWaiting"); break;
                case AVAssetExportSessionStatusExporting:
                    NSLog(@"AVAssetExportSessionStatusExporting"); break;
                case AVAssetExportSessionStatusCompleted: {
                    NSLog(@"AVAssetExportSessionStatusCompleted");
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (completion) {
                            completion(outputPath);
                        }
                    });
                }  break;
                case AVAssetExportSessionStatusFailed:
                    NSLog(@"AVAssetExportSessionStatusFailed"); break;
                default: break;
            }
        }];
    }
}

/// Judge is a assets array contain the asset 判断一个assets数组是否包含这个asset
- (BOOL)isAssetsArray:(NSArray *)assets containAsset:(id)asset {
    if (iOS8Later) {
        return [assets containsObject:asset];
    } else {
        NSMutableArray *selectedAssetUrls = [NSMutableArray array];
        for (ALAsset *asset_item in assets) {
            [selectedAssetUrls addObject:[asset_item valueForProperty:ALAssetPropertyURLs]];
        }
        return [selectedAssetUrls containsObject:[asset valueForProperty:ALAssetPropertyURLs]];
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
        ALAsset *alAsset = (ALAsset *)asset;
        NSURL *assetUrl = [alAsset valueForProperty:ALAssetPropertyAssetURL];
        return assetUrl.absoluteString;
    }
}

/// 检查照片大小是否满足最小要求
- (BOOL)isPhotoSelectableWithAsset:(id)asset {
    CGSize photoSize = [self photoSizeWithAsset:asset];
    if (self.minPhotoWidthSelectable > photoSize.width || self.minPhotoHeightSelectable > photoSize.height) {
        return NO;
    }
    return YES;
}

- (CGSize)photoSizeWithAsset:(id)asset {
    if (iOS8Later) {
        PHAsset *phAsset = (PHAsset *)asset;
        return CGSizeMake(phAsset.pixelWidth, phAsset.pixelHeight);
    } else {
        ALAsset *alAsset = (ALAsset *)asset;
        return alAsset.defaultRepresentation.dimensions;
    }
}

#pragma mark - Private Method

- (NYAlbumModel *)modelWithResult:(id)result name:(NSString *)name{
    NYAlbumModel *model = [[NYAlbumModel alloc] init];
    model.result = result;
    model.name = name;
    if ([result isKindOfClass:[PHFetchResult class]]) {
        PHFetchResult *fetchResult = (PHFetchResult *)result;
        model.count = fetchResult.count;
    } else if ([result isKindOfClass:[ALAssetsGroup class]]) {
        ALAssetsGroup *group = (ALAssetsGroup *)result;
        model.count = [group numberOfAssets];
    }
    return model;
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

- (ALAssetOrientation)orientationFromImage:(UIImage *)image {
    NSInteger orientation = image.imageOrientation;
    return orientation;
}

/// 获取优化后的视频转向信息
- (AVMutableVideoComposition *)fixedCompositionWithAsset:(AVAsset *)videoAsset {
    AVMutableVideoComposition *videoComposition = [AVMutableVideoComposition videoComposition];
    // 视频转向
    int degrees = [self degressFromVideoFileWithAsset:videoAsset];
    if (degrees != 0) {
        CGAffineTransform translateToCenter;
        CGAffineTransform mixedTransform;
        videoComposition.frameDuration = CMTimeMake(1, 30);
        
        NSArray *tracks = [videoAsset tracksWithMediaType:AVMediaTypeVideo];
        AVAssetTrack *videoTrack = [tracks objectAtIndex:0];
        
        if (degrees == 90) {
            // 顺时针旋转90°
            translateToCenter = CGAffineTransformMakeTranslation(videoTrack.naturalSize.height, 0.0);
            mixedTransform = CGAffineTransformRotate(translateToCenter,M_PI_2);
            videoComposition.renderSize = CGSizeMake(videoTrack.naturalSize.height,videoTrack.naturalSize.width);
        } else if(degrees == 180){
            // 顺时针旋转180°
            translateToCenter = CGAffineTransformMakeTranslation(videoTrack.naturalSize.width, videoTrack.naturalSize.height);
            mixedTransform = CGAffineTransformRotate(translateToCenter,M_PI);
            videoComposition.renderSize = CGSizeMake(videoTrack.naturalSize.width,videoTrack.naturalSize.height);
        } else if(degrees == 270){
            // 顺时针旋转270°
            translateToCenter = CGAffineTransformMakeTranslation(0.0, videoTrack.naturalSize.width);
            mixedTransform = CGAffineTransformRotate(translateToCenter,M_PI_2*3.0);
            videoComposition.renderSize = CGSizeMake(videoTrack.naturalSize.height,videoTrack.naturalSize.width);
        }
        
        AVMutableVideoCompositionInstruction *roateInstruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
        roateInstruction.timeRange = CMTimeRangeMake(kCMTimeZero, [videoAsset duration]);
        AVMutableVideoCompositionLayerInstruction *roateLayerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:videoTrack];
        
        [roateLayerInstruction setTransform:mixedTransform atTime:kCMTimeZero];
        
        roateInstruction.layerInstructions = @[roateLayerInstruction];
        // 加入视频方向信息
        videoComposition.instructions = @[roateInstruction];
    }
    return videoComposition;
}

/// 获取视频角度
- (int)degressFromVideoFileWithAsset:(AVAsset *)asset {
    int degress = 0;
    NSArray *tracks = [asset tracksWithMediaType:AVMediaTypeVideo];
    if([tracks count] > 0) {
        AVAssetTrack *videoTrack = [tracks objectAtIndex:0];
        CGAffineTransform t = videoTrack.preferredTransform;
        if(t.a == 0 && t.b == 1.0 && t.c == -1.0 && t.d == 0){
            // Portrait
            degress = 90;
        } else if(t.a == 0 && t.b == -1.0 && t.c == 1.0 && t.d == 0){
            // PortraitUpsideDown
            degress = 270;
        } else if(t.a == 1.0 && t.b == 0 && t.c == 0 && t.d == 1.0){
            // LandscapeRight
            degress = 0;
        } else if(t.a == -1.0 && t.b == 0 && t.c == 0 && t.d == -1.0){
            // LandscapeLeft
            degress = 180;
        }
    }
    return degress;
}

/// 修正图片转向
- (UIImage *)fixOrientation:(UIImage *)aImage {
    if (!self.shouldFixOrientation) return aImage;
    
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
#pragma clang diagnostic pop

@end


//@implementation NYSortDescriptor
//
//- (id)reversedSortDescriptor {
//    return [NSNumber numberWithBool:![NYImageManager manager].sortAscendingByModificationDate];
//}
//
//@end
