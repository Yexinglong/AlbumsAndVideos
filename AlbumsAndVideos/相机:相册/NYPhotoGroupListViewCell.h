//
//  NYPhotoGroupListViewCell.h
//  DDNM-NY
//
//  Created by 叶星龙 on 2017/1/6.
//  Copyright © 2017年 北京叮咚柠檬科技有限公司. All rights reserved.
//

#import "NYBaseTableViewCell.h"
@class NYAlbumModel;
@interface NYPhotoGroupListViewCell : NYBaseTableViewCell

@property (nonatomic ,strong) NYAlbumModel *asset;

@property (nonatomic ,strong) UIImageView *imageCheck;


@end
