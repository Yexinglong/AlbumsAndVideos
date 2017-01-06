//
//  NYPhotoPreviewCell.h
//  DDNM-NY
//
//  Created by 叶星龙 on 2016/12/29.
//  Copyright © 2016年 北京叮咚柠檬科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NYAssetModel.h"
#import "NYPhotoScrollView.h"

@interface NYPhotoPreviewCell : UICollectionViewCell

@property (nonatomic ,strong) NYAssetModel *model;

@property (nonatomic ,strong) NYPhotoScrollView *photoScrollView;

@end
