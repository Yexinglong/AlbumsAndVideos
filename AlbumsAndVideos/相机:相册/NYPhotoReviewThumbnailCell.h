//
//  NYPhotoReviewThumbnailCell.h
//  DDNM-NY
//
//  Created by 叶星龙 on 2016/12/29.
//  Copyright © 2016年 北京叮咚柠檬科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NYAssetModel.h"

@interface NYPhotoReviewThumbnailCell : UICollectionViewCell

@property (nonatomic ,strong) NYAssetModel *model;

@property (nonatomic ,assign) BOOL isShowGIFIcon;

@end
