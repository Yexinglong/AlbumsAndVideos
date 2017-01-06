//
//  NYPhotoPreviewView.h
//  DDNM-NY
//
//  Created by 叶星龙 on 2016/12/29.
//  Copyright © 2016年 北京叮咚柠檬科技有限公司. All rights reserved.
//

#import "NYBaseVC.h"
#import "NYAssetModel.h"

@interface NYPhotoPreviewView : NYBaseVC

@property (nonatomic ,strong) NSMutableArray *albumAssetArray;

@property (nonatomic ,strong) NYAssetModel *assetModel;


@end
