//
//  UIButton+YXLAcronymButton.m
//  DDNM
//
//  Created by YXL on 2016/9/12.
//  Copyright © 2016年 叶星龙. All rights reserved.
//

#import "UIButton+YXLAcronymButton.h"

@implementation UIButton (YXLAcronymButton)


- (UIButton * (^)(id image))kNormalImage{
    return ^id(id image){
        [self setImage:image state:UIControlStateNormal];
        return self;
    };
}

- (UIButton * (^)(id image))kHighlightedImage{
    return ^id(id image){
        [self setImage:image state:UIControlStateHighlighted];
        return self;
    };
}

- (UIButton * (^)(id image))kSelectedImage{
    return ^id(id image){
        [self setImage:image state:UIControlStateSelected];
        return self;
    };
}

-(void)setImage:(id)image state:(UIControlState)state{
    if ([image isKindOfClass:[NSString class]]) {
        [self setImage:[UIImage imageNamed:image] forState:state];
    }else if ([image isKindOfClass:[UIImage class]]){
        [self setImage:image forState:state];
    }
}

- (UIButton * (^)(NSString *text))kNormalText{
    return ^id(NSString *text){
        [self setText:text state:UIControlStateNormal];
        return self;
    };
}

- (UIButton * (^)(NSString *text))kHighlightedText{
    return ^id(NSString *text){
        [self setText:text state:UIControlStateHighlighted];
        return self;
    };
}

- (UIButton * (^)(NSString *text))kSelectedText{
    return ^id(NSString *text){
        [self setText:text state:UIControlStateSelected];
        return self;
    };
}

-(void)setText:(NSString *)text state:(UIControlState)state{
    if (text && text.length!=0) {
        [self setTitle:text forState:state];
    }
}

- (UIButton * (^)(id target ,SEL action))kAddTouchUpInside{
    return ^id(id target ,SEL action ){
        if ([self isKindOfClass:[UIButton class]]) {
            UIButton *btn =(UIButton *)self;
            [btn addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
        }
        return self;
    };
}

- (UIButton * (^)(id font))kFont{
    return ^id(id font){
        if ([font isKindOfClass:[UIFont class]]) {
            self.titleLabel.font=font;
        }else if ([font isKindOfClass:[NSNumber class]]){
            self.titleLabel.font=[UIFont systemFontOfSize:[font floatValue]];
        }
        return self;
    };
}

- (UIButton * (^)(id textColor))kTextColor{
    return ^id(id textColor){
        if ([textColor isKindOfClass:[UIColor class]]) {
            [self setTitleColor:textColor forState:UIControlStateNormal];
        }else if([textColor isKindOfClass:[NSString class]]){
            [self setTitleColor:[self colorWithHexString:textColor alpha:1] forState:UIControlStateNormal];
        }
        return self;
    };
}

- (UIButton * (^)(id textColor))kHighlightedTextColor{
    return ^id(id textColor){
        if ([textColor isKindOfClass:[UIColor class]]) {
            [self setTitleColor:textColor forState:UIControlStateHighlighted];
        }else if([self isKindOfClass:[NSString class]]){
            [self setTitleColor:[self colorWithHexString:textColor alpha:1] forState:UIControlStateHighlighted];
        }
        return self;
    };
}

- (UIButton * (^)(id textColor))kSelectedTextColor{
    return ^id(id textColor){
            if ([textColor isKindOfClass:[UIColor class]]) {
                [self setTitleColor:textColor forState:UIControlStateSelected];
            }else if([self isKindOfClass:[NSString class]]){
                [self setTitleColor:[self colorWithHexString:textColor alpha:1] forState:UIControlStateSelected];
            }
        return self;
    };
}
@end
