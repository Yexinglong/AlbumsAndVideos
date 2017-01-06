//
//  NYAssetModel.m
//  DDNM-NY
//
//  Created by 叶星龙 on 2016/12/29.
//  Copyright © 2016年 北京叮咚柠檬科技有限公司. All rights reserved.
//

#import "NYAssetModel.h"
#import "NYImageManager.h"

@implementation NYAssetModel

+ (instancetype)modelWithAsset:(id)asset type:(NYAssetModelMediaType)type{
    NYAssetModel *model = [[NYAssetModel alloc] init];
    model.asset = asset;
    model.isSelected = NO;
    model.type = type;
    return model;
}

+ (instancetype)modelWithAsset:(id)asset type:(NYAssetModelMediaType)type timeLength:(NSString *)timeLength {
    NYAssetModel *model = [self modelWithAsset:asset type:type];
    model.timeLength = timeLength;
    return model;
}

@end



@implementation NYAlbumModel


-(instancetype)init{
    self=[super init];
    if (self) {
        self.selectedModels=[NSMutableArray array];
    }
    return self;
}


//- (void)setResult:(id)result {
//    _result = result;
//    BOOL allowPickingImage = [[[NSUserDefaults standardUserDefaults] objectForKey:@"NY_allowPickingImage"] isEqualToString:@"1"];
//    BOOL allowPickingVideo = [[[NSUserDefaults standardUserDefaults] objectForKey:@"NY_allowPickingVideo"] isEqualToString:@"1"];
//    [[NYImageManager manager] getAssetsFromFetchResult:result allowPickingVideo:allowPickingVideo allowPickingImage:allowPickingImage completion:^(NSArray<NYAssetModel *> *models) {
//        _models = models;
//        if (_selectedModels) {
//            [self checkSelectedModels];
//        }
//    }];
//}

//- (void)setSelectedModels:(NSArray *)selectedModels {
//    _selectedModels = selectedModels;
//    if (_models) {
//        [self checkSelectedModels];
//    }
//}
//
//- (void)checkSelectedModels {
//    self.selectedCount = 0;
//    NSMutableArray *selectedAssets = [NSMutableArray array];
//    for (NYAssetModel *model in _selectedModels) {
//        [selectedAssets addObject:model.asset];
//    }
//    for (NYAssetModel *model in _models) {
//        if ([[NYImageManager manager] isAssetsArray:selectedAssets containAsset:model.asset]) {
//            self.selectedCount ++;
//        }
//    }
//}

@end
