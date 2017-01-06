//
//  UIImage+YXL.h
//  DDNM-NY
//
//  Created by 叶星龙 on 2016/11/27.
//  Copyright © 2016年 北京叮咚柠檬科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (YXL)

/**
 将颜色变成image

 @param color 颜色值
 @return 返回一个带有颜色的image
 */
+ (UIImage *)createImageWithColor:(UIColor *)color;

/**
 裁剪圆形图
 */
+ (UIImage *)circleImage:(UIImage *)image;

/**
 图片剪裁圆形

 @param imageV 需要剪裁图片
 @param borderWidth 剪裁后的外圆线的宽度，可为0
 @param borderColor 外圆线的颜色，不需要可为nil
 @param size 图片大小
 @return 返回一个剪裁后的图片
 */
+ (UIImage *)circleImage:(UIImage *)imageV borderWidth:(CGFloat)borderWidth borderColor:(UIColor *)borderColor size:(CGSize)size;

/// 裁剪框背景的处理  needCircleCrop YES为圆形 NO是正方形
+ (void)overlayClippingCropRect:(CGRect)cropRect containerView:(UIView *)containerView needCircleCrop:(BOOL)needCircleCrop;

/// 获得裁剪后的图片
+ (UIImage *)cropImageView:(UIImageView *)imageView toRect:(CGRect)rect zoomScale:(double)zoomScale containerView:(UIView *)containerView;




@end
