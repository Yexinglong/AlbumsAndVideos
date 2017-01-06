//
//  UIImageView+YXLAcronymImageView.m
//  DDNM
//
//  Created by YXL on 2016/9/12.
//  Copyright © 2016年 叶星龙. All rights reserved.
//

#import "UIImageView+YXLAcronymImageView.h"

@implementation UIImageView (YXLAcronymImageView)

- (UIImageView * (^)(id image))kImage{
    return ^id(id image){
            if ([image isKindOfClass:[NSString class]]) {
                [self setImage:[UIImage imageNamed:image]];
            }else if ([image isKindOfClass:[UIImage class]]){
                [self setImage:image];
            }
        return self;
    };
}

- (UIImageView * (^)(id image))kHighlightedImage{
    return ^id(id image){
            if ([image isKindOfClass:[NSString class]]) {
                [self setHighlightedImage:[UIImage imageNamed:image]];
            }else if ([image isKindOfClass:[UIImage class]]){
                [self setHighlightedImage:image];
            }
        return self;
    };
}




@end
