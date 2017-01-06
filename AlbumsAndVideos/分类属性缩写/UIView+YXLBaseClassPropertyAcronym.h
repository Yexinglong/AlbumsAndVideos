//
//  UIView+YXLBaseClassPropertyAcronym.h
//  DDNM
//
//  Created by YXL on 2016/9/12.
//  Copyright © 2016年 叶星龙. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, YXLViewEvents) {
    YXLTap
};

@interface UIView (YXLBaseClassPropertyAcronym)


#pragma  颜色
/**
 *  背景颜色 支持十六进制字符串(@"0xffffff") UIColor([UIColor blackColor])
 示例
 view.kBackgroundColor(@"0xffffff").kBackgroundColor([UIColor blackColor])
 */
- (UIView * (^)(id color))kBackgroundColor;

#pragma 坐标
/**
 *  设置控件坐标大小
 示例
 view.kFrame(view.frame);
 */
- (UIView * (^)(CGRect frame))kFrame;
/**
 示例
 kFrameXYWH(0,0,0,0);
 */
- (UIView * (^)(CGFloat x,CGFloat y,CGFloat w,CGFloat h))kFrameXYWH;

/**
 *  中心
 示例
 view.kCenter(view.center);
 */
- (UIView * (^)(CGPoint center))kCenter;
/**
 *  X-Y
 示例
 view.kCenterXY(0,0);
 */
- (UIView * (^)(CGFloat x,CGFloat y))kCenterXY;

#pragma 手势添加
/**
 *  给当前控件添加点击事件，点击返回手势:UITapGestureRecognizer 可自己添加需要的手势进去
 示例
 view.kAddTargetAction(self,@selector(tap),UpInside);
 */
- (UIView * (^)(id target ,SEL action ,YXLViewEvents events))kAddTargetAction;
-(void)addTarget:(id)target action:(SEL)action forControlEvents:(YXLViewEvents)controlEvents;

#pragma Layer层
/**
 *  Layer边层的颜色和宽度 支持十六进制字符串(@"0xffffff") UIColor([UIColor blackColor])
 示例
 view.kBorderColor(@"0xffffff").kBorderColor([UIColor blackColor])
 view.kBorderWidth(1.3)
 */
- (UIView * (^)(CGFloat w , id color))kLayerBorderWidthAndBorderColor;
/**
 *  Layer边层的圆角和是否裁剪
 示例
 view.kLayerCornerRadiusToMasks(6,YES)
 */
- (UIView * (^)(CGFloat radius , BOOL masks))kLayerCornerRadiusToMasks;


-(UIColor *)colorWithHexString: (NSString *)color alpha:(CGFloat)alpha;
@end
