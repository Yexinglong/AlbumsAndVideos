//
//  NYAssetModel.h
//  DDNM-NY
//
//  Created by 叶星龙 on 2016/12/29.
//  Copyright © 2016年 北京叮咚柠檬科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    NYAssetModelMediaTypePhoto = 0,
    NYAssetModelMediaTypeLivePhoto,
    NYAssetModelMediaTypePhotoGif,
    NYAssetModelMediaTypeVideo,
    NYAssetModelMediaTypeAudio
} NYAssetModelMediaType;

@class PHAsset;
@interface NYAssetModel : NSObject

@property (nonatomic, strong) id asset;             ///< PHAsset or ALAsset
@property (nonatomic, assign) BOOL isSelected;      ///< The select status of a photo, default is No
@property (nonatomic, assign) NYAssetModelMediaType type;
@property (nonatomic, copy) NSString *timeLength;

/// Init a photo dataModel With a asset
/// 用一个PHAsset/ALAsset实例，初始化一个照片模型
+ (instancetype)modelWithAsset:(id)asset type:(NYAssetModelMediaType)type;
+ (instancetype)modelWithAsset:(id)asset type:(NYAssetModelMediaType)type timeLength:(NSString *)timeLength;

@end


@class PHFetchResult;
@interface NYAlbumModel : NSObject

@property (nonatomic, strong) NSString *name;        ///< The album name
@property (nonatomic, assign) NSInteger count;       ///< Count of photos the album contain
@property (nonatomic, strong) id result;             ///< PHFetchResult<PHAsset> or ALAssetsGroup<ALAsset>

@property (nonatomic, strong) NSArray *models;
@property (nonatomic, strong) NSMutableArray *selectedModels;
@end
