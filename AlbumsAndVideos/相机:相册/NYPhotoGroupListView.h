//
//  NYPhotoGroupListView.h
//  DDNM-NY
//
//  Created by 叶星龙 on 2017/1/6.
//  Copyright © 2017年 北京叮咚柠檬科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NYImageManager.h"
#import "NYAssetModel.h"


typedef void (^NYPhotoGroupListSelectBlock)(NYAlbumModel * selectGroup);

@interface NYPhotoGroupListView : UIView

+ (instancetype)showToView:(UIView *)view title:(NYAlbumModel *)group allGroup:(NSMutableArray *)allGroup block:(NYPhotoGroupListSelectBlock)block;

@property (nonatomic, copy) NYPhotoGroupListSelectBlock block;

- (void)dismiss;

@end
