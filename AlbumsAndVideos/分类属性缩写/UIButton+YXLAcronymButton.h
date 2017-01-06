//
//  UIButton+YXLAcronymButton.h
//  DDNM
//
//  Created by YXL on 2016/9/12.
//  Copyright © 2016年 叶星龙. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIView+YXLBaseClassPropertyAcronym.h"

@interface UIButton (YXLAcronymButton)

/**
 *   支持 NSString UIimage
 示例
 button.kImage(@"icon").kImage(UIImage);
 */
- (UIButton * (^)(id image))kNormalImage;

/**
 *  支持 NSString UIimage
 示例
 button.kImage(@"icon").kImage(UIImage);
 */
- (UIButton * (^)(id image))kHighlightedImage;

/**
 * 设置选中 支持 NSString UIimage
 示例
 button.kImage(@"icon").kImage(UIImage);
 */
- (UIButton * (^)(id image))kSelectedImage;

/**
 *  文本
 示例
 button.kText(@"我是大帅哥");
 */
- (UIButton * (^)(NSString *text))kNormalText;
/**
 *  文本
 示例
 button.kText(@"我是大帅哥");
 */
- (UIButton * (^)(NSString *text))kHighlightedText;
/**
 *  文本
 示例
 button.kText(@"我是大帅哥");
 */
- (UIButton * (^)(NSString *text))kSelectedText;

/**
 *  添加点击手势
 示例
    button.kAddTouchUpInside(self,@selector(tap));
 */
- (UIButton * (^)(id target ,SEL action))kAddTouchUpInside;

/**
 *  字体大小  kFont([UIFont systemFontOfSize:13]) and kFont(@13)
 示例
 button.kFont([UIFont systemFontOfSize:13]).kFont(@13);
 */
- (UIButton * (^)(id font))kFont;


/**
 *  文字颜色 支持十六进制字符串(@"0xffffff")
 示例
 button.kTextColor(@"0xffffff").kTextColor([UIColor blackColor]) 默认Normal
 */
- (UIButton * (^)(id textColor))kTextColor;

/**
 *  高亮字体颜色 支持十六进制字符串(@"0xffffff") UIColor([UIColor blackColor])
 示例
 button.kHighlightedTextColor(@"0xffffff").kHighlightedTextColor([UIColor blackColor]) 默认Highlighted
 */
- (UIButton * (^)(id textColor))kHighlightedTextColor;

/**
 * 选中文字颜色 支持十六进制字符串(@"0xffffff") UIColor([UIColor blackColor])
 示例
 button.kSelectedTextColor(@"0xffffff").kSelectedTextColor([UIColor blackColor]) 默认Selected
 */
- (UIButton * (^)(id textColor))kSelectedTextColor;

@end
