//
//  UIImage+YXL.m
//  DDNM-NY
//
//  Created by 叶星龙 on 2016/11/27.
//  Copyright © 2016年 北京叮咚柠檬科技有限公司. All rights reserved.
//

#import "UIImage+YXL.h"
#import "NYImageManager.h"

@implementation UIImage (YXL)

/**
 * 将UIColor变换为UIImage
 **/
+ (UIImage *)createImageWithColor:(UIColor *)color
{
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return theImage;
}

+ (UIImage *)circleImage:(UIImage *)image{
    UIGraphicsBeginImageContextWithOptions(image.size, NO, [UIScreen mainScreen].scale);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGRect rect = CGRectMake(0, 0, image.size.width, image.size.height);
    CGContextAddEllipseInRect(ctx, rect);
    CGContextClip(ctx);
    [image drawInRect:rect];
    UIImage *circleImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return circleImage;
}


+ (UIImage *)circleImage:(UIImage *)imageV borderWidth:(CGFloat)borderWidth borderColor:(UIColor *)borderColor size:(CGSize)size;
{
    UIImage *oldImage = imageV;
    
    CGFloat imageW = size.width + 2 * borderWidth;
    CGFloat imageH = size.height + 2 * borderWidth;
    
    CGSize imageSize = CGSizeMake(imageW, imageH);
    UIGraphicsBeginImageContextWithOptions(imageSize, NO, 1);
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    [borderColor set];
    CGFloat bigRadius = imageW * 0.5; // 大圆半径
    CGFloat centerX = bigRadius; // 圆心
    CGFloat centerY = bigRadius;
    CGContextAddArc(ctx, centerX, centerY, bigRadius, 0, M_PI * 2, 0);
    CGContextFillPath(ctx); // 画圆
    
    CGFloat smallRadius = bigRadius - borderWidth;
    CGContextAddArc(ctx, centerX, centerY, smallRadius, 0, M_PI * 2, 0);
    CGContextClip(ctx);
    
    [oldImage drawInRect:CGRectMake(borderWidth, borderWidth, imageSize.width, imageSize.height)];
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return newImage;
}

/// 裁剪框背景的处理
+ (void)overlayClippingCropRect:(CGRect)cropRect containerView:(UIView *)containerView needCircleCrop:(BOOL)needCircleCrop{
    UIView *view =[UIView new];
    view.userInteractionEnabled = NO;
    view.backgroundColor = [UIColor clearColor];
    view.frame = containerView.bounds;
    [containerView addSubview:view];
    
    UIBezierPath *path= [UIBezierPath bezierPathWithRect:[UIScreen mainScreen].bounds];
    CAShapeLayer *layer = [CAShapeLayer layer];
    if (needCircleCrop) { // 圆形裁剪框
        [path appendPath:[UIBezierPath bezierPathWithArcCenter:containerView.center radius:cropRect.size.width / 2 startAngle:0 endAngle: 2 * M_PI clockwise:NO]];
    } else { // 矩形裁剪框
        [path appendPath:[UIBezierPath bezierPathWithRect:cropRect]];
    }
    layer.path = path.CGPath;
    layer.fillRule = kCAFillRuleEvenOdd;
    layer.fillColor = [[UIColor blackColor] CGColor];
    layer.opacity = 0.5;
    [view.layer addSublayer:layer];
    
    UIView *viewCropLine = [UIView new];
    viewCropLine.userInteractionEnabled = NO;
    viewCropLine.backgroundColor = [UIColor clearColor];
    viewCropLine.frame = cropRect;
    viewCropLine.layer.borderColor = [UIColor whiteColor].CGColor;
    viewCropLine.layer.borderWidth = 1.0;
    if (needCircleCrop) {
        viewCropLine.layer.cornerRadius = cropRect.size.width / 2;
        viewCropLine.clipsToBounds = YES;
    }
    [view addSubview:viewCropLine];
}

/// 获得裁剪后的图片
+ (UIImage *)cropImageView:(UIImageView *)imageView toRect:(CGRect)rect zoomScale:(double)zoomScale containerView:(UIView *)containerView {
    CGAffineTransform transform = CGAffineTransformIdentity;
    // 平移的处理
    CGRect imageViewRect = [imageView convertRect:imageView.bounds toView:containerView];
    CGPoint point = CGPointMake(imageViewRect.origin.x + imageViewRect.size.width / 2, imageViewRect.origin.y + imageViewRect.size.height / 2);
    CGFloat xMargin = containerView.frame.size.width - CGRectGetMaxX(rect) - rect.origin.x;
    CGPoint zeroPoint = CGPointMake((CGRectGetWidth(containerView.frame) - xMargin) / 2, containerView.center.y);
    CGPoint translation = CGPointMake(point.x - zeroPoint.x, point.y - zeroPoint.y);
    transform = CGAffineTransformTranslate(transform, translation.x, translation.y);
    // 缩放的处理
    transform = CGAffineTransformScale(transform, zoomScale, zoomScale);
    
    CGImageRef imageRef = [self newTransformedImage:transform
                                        sourceImage:imageView.image.CGImage
                                         sourceSize:imageView.image.size
                                        outputWidth:rect.size.width * [UIScreen mainScreen].scale
                                           cropSize:rect.size
                                      imageViewSize:imageView.frame.size];
    UIImage *cropedImage = [UIImage imageWithCGImage:imageRef];
    cropedImage = [[NYImageManager manager] fixOrientation:cropedImage];
    CGImageRelease(imageRef);
    return cropedImage;
}

+ (CGImageRef)newTransformedImage:(CGAffineTransform)transform sourceImage:(CGImageRef)sourceImage sourceSize:(CGSize)sourceSize  outputWidth:(CGFloat)outputWidth cropSize:(CGSize)cropSize imageViewSize:(CGSize)imageViewSize {
    CGImageRef source = [self newScaledImage:sourceImage toSize:sourceSize];
    CGFloat aspect = cropSize.height/cropSize.width;
    CGSize outputSize = CGSizeMake(outputWidth, outputWidth*aspect);
    CGContextRef context = CGBitmapContextCreate(NULL, outputSize.width, outputSize.height, CGImageGetBitsPerComponent(source), 0, CGImageGetColorSpace(source), CGImageGetBitmapInfo(source));
    CGContextSetFillColorWithColor(context, [[UIColor clearColor] CGColor]);
    CGContextFillRect(context, CGRectMake(0, 0, outputSize.width, outputSize.height));
    CGAffineTransform uiCoords = CGAffineTransformMakeScale(outputSize.width / cropSize.width, outputSize.height / cropSize.height);
    uiCoords = CGAffineTransformTranslate(uiCoords, cropSize.width/2.0, cropSize.height / 2.0);
    uiCoords = CGAffineTransformScale(uiCoords, 1.0, -1.0);
    CGContextConcatCTM(context, uiCoords);
    CGContextConcatCTM(context, transform);
    CGContextScaleCTM(context, 1.0, -1.0);
    
    CGContextDrawImage(context, CGRectMake(-imageViewSize.width/2, -imageViewSize.height/2.0, imageViewSize.width, imageViewSize.height), source);
    CGImageRef resultRef = CGBitmapContextCreateImage(context);
    CGContextRelease(context);
    CGImageRelease(source);
    return resultRef;
}

+ (CGImageRef)newScaledImage:(CGImageRef)source toSize:(CGSize)size {
    CGSize srcSize = size;
    CGColorSpaceRef rgbColorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(NULL, size.width, size.height, 8, 0, rgbColorSpace, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    CGColorSpaceRelease(rgbColorSpace);
    
    CGContextSetInterpolationQuality(context, kCGInterpolationNone);
    CGContextTranslateCTM(context, size.width/2, size.height/2);
    
    CGContextDrawImage(context, CGRectMake(-srcSize.width/2, -srcSize.height/2, srcSize.width, srcSize.height), source);
    
    CGImageRef resultRef = CGBitmapContextCreateImage(context);
    CGContextRelease(context);
    return resultRef;
}



@end
