//
//  UILabel+YXLAcronymLabel.m
//  DDNM
//
//  Created by YXL on 2016/9/12.
//  Copyright © 2016年 叶星龙. All rights reserved.
//

#import "UILabel+YXLAcronymLabel.h"

@implementation UILabel (YXLAcronymLabel)

- (UILabel * (^)(NSString *text))kText{
    return ^id(NSString *text){
        [self setText:text];
       return  self;
    };
}

- (UILabel * (^)(id font))kFont{
    return ^id(id font){
        if ([font isKindOfClass:[UIFont class]]) {
            [self setFont:font];
        }else if ([font isKindOfClass:[NSNumber class]]){
            [self setFont:[UIFont systemFontOfSize:[font floatValue]]];
        }
        return self;
    };
}

- (UILabel * (^)(id textColor))kTextColor{
    return ^id(id textColor){
        if ([textColor isKindOfClass:[UIColor class]]) {
            [self setTextColor:textColor];
        }else if([textColor isKindOfClass:[NSString class]]){
            [self setTextColor:[self colorWithHexString:textColor alpha:1]];
        }
        return self;
    };
}

- (UILabel * (^)(id textColor))kHighlightedTextColor{
    return ^id(id textColor){
            if ([textColor isKindOfClass:[UIColor class]]) {
                [self setHighlightedTextColor:textColor];
            }else if([self isKindOfClass:[NSString class]]){
                [self setHighlightedTextColor:[self colorWithHexString:textColor alpha:1]];
            }
        return self;
    };
}
@end
