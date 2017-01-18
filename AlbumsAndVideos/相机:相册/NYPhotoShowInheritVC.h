//
//  NYPhotoShowInheritVC.h
//  DDNM-NY
//
//  Created by 叶星龙 on 2016/12/30.
//  Copyright © 2016年 北京叮咚柠檬科技有限公司. All rights reserved.
//

#import "NYPhotoShowVC.h"

@interface NYPhotoShowInheritVC : NYPhotoShowVC

/**
 设置ClassName的字符串，需要继承NYPhotoPushVC，如果className不设置的话，重写
 pushController方法，重写点击右边按钮后控制push那个控制器
 */
@property (nonatomic ,copy) NSString *className;
-(void)pushController;

/**
 是否显示多选按钮 默认不显示   yes为显示   no为不显示
 */
@property (nonatomic ,assign) BOOL isMultipleChoice;

/**
 是否需要右边按钮   yes是不显示  no是显示 默认 按钮显示
 */
@property (nonatomic ,assign) BOOL isRequiredRightButton;

/**
 设置右边按钮文字，默认@"确定"
 */
@property (nonatomic ,copy) NSString *rightButtonTitle;

/**
 是否点击图片后就把控制器dismiss isClickPhotoDismiss设置YES时，clickPhotoDismissBlock才会调用
 */
@property (nonatomic ,assign) BOOL isClickPhotoDismiss;
@property (nonatomic, copy) void (^clickPhotoDismissBlock)(NYAssetModel *model);

/**
 设置选择视频数量 默认1个
 */
@property (nonatomic ,assign) NSInteger videoSelectCount;
/**
 设置选择图片数量 默认9个
 */
@property (nonatomic ,assign) NSInteger photoSelectCount;


@end
