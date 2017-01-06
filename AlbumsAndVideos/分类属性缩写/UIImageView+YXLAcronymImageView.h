//
//  UIImageView+YXLAcronymImageView.h
//  DDNM
//
//  Created by YXL on 2016/9/12.
//  Copyright © 2016年 叶星龙. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImageView (YXLAcronymImageView)

/**
 *  支持 NSString UIimage
 示例
    imageView.kImage(@"icon").kImage(UIImage);
 */
- (UIImageView * (^)(id image))kImage;

/**
 *  支持 NSString UIimage
 示例
    imageView.kImage(@"icon").kImage(UIImage);
 */
- (UIImageView * (^)(id image))kHighlightedImage;



@end
