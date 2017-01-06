//
//  NYPhotoScrollView.h
//  DDNM-NY
//
//  Created by 叶星龙 on 2016/12/29.
//  Copyright © 2016年 北京叮咚柠檬科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NYPhotoScrollView : UIScrollView

/**
 当视图超出屏幕长度时，YES 先显示顶部一部分，NO 缩小显示全部  默认NO
 */
@property (nonatomic ,assign) BOOL isViewTop;

/**
 恢复缩放
 */
-(void)restoreZoom;

/**
 设置哪个控件需要缩放
 */
- (void)displayView:(id)view;


@end
