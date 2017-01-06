//
//  UILabel+YXLAcronymLabel.h
//  DDNM
//
//  Created by YXL on 2016/9/12.
//  Copyright © 2016年 叶星龙. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIView+YXLBaseClassPropertyAcronym.h"

@interface UILabel (YXLAcronymLabel)

/**
 *   文本
 示例
 label.kText(@"我是大帅哥");
 */
- (UILabel * (^)(NSString *text))kText;
/**
 *  字体大小  kFont([UIFont systemFontOfSize:13]) and kFont(@13)
 示例
    label.kFont([UIFont systemFontOfSize:13]).kFont(@13);
 */
- (UILabel * (^)(id font))kFont;
/**
 *  文字颜色 支持十六进制字符串(@"0xffffff")
 示例
 label.kTextColor(@"0xffffff").kTextColor([UIColor blackColor])
 */
- (UILabel * (^)(id textColor))kTextColor;
/**
 *  高亮字体颜色 支持十六进制字符串(@"0xffffff") UIColor([UIColor blackColor])
 示例
 label.kHighlightedTextColor(@"0xffffff").kHighlightedTextColor([UIColor blackColor])
 */
- (UILabel * (^)(id textColor))kHighlightedTextColor;

@end
