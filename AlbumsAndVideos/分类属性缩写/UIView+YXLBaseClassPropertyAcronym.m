//
//  UIView+YXLBaseClassPropertyAcronym.m
//  DDNM
//
//  Created by YXL on 2016/9/12.
//  Copyright © 2016年 叶星龙. All rights reserved.
//

#import "UIView+YXLBaseClassPropertyAcronym.h"

@implementation UIView (YXLBaseClassPropertyAcronym)


- (UIView * (^)(id color))kBackgroundColor{
    return ^id(id color) {
        if ([color isKindOfClass:[UIColor class]]) {
            self.backgroundColor=color;
        }else if([color isKindOfClass:[NSString class]]){
            self.backgroundColor=[self colorWithHexString:color alpha:1];
        }
        return self;
    };
}

- (UIView * (^)(CGRect frame))kFrame{
    [self sizeToFit];
    return ^id(CGRect frame){
        [self setFrame:frame];
        return self;
    };
}

- (UIView * (^)(CGFloat x,CGFloat y,CGFloat w,CGFloat h))kFrameXYWH{
    [self sizeToFit];
    return ^id(CGFloat x,CGFloat y,CGFloat w,CGFloat h){
        [self setFrame:(CGRect){x,y,w,h}];
        return self;
    };
}

- (UIView * (^)(CGPoint center))kCenter{
    return ^id(CGPoint center) {
        self.center=center;
        return self;
    };
}

- (UIView * (^)(CGFloat x,CGFloat y))kCenterXY{
    return ^id(CGFloat x,CGFloat y) {
        self.center=CGPointMake(x, y);
        return self;
    };
}

- (UIView * (^)(id target ,SEL action ,YXLViewEvents events))kAddTargetAction{
    return ^id(id target ,SEL action ,YXLViewEvents events){
        self.userInteractionEnabled=YES;
        [self addTarget:target action:action forControlEvents:events];
        return self;
    };
}

-(void)addTarget:(id)target action:(SEL)action forControlEvents:(YXLViewEvents)controlEvents{
    @synchronized(self){
        if (controlEvents == YXLTap) {
            UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:target action:action];
            [self addGestureRecognizer:tapGesture];
        }
    }
}


- (UIView * (^)(CGFloat w , id color))kLayerBorderWidthAndBorderColor{
    return ^id(CGFloat w , id color){
        if ([color isKindOfClass:[UIColor class]]) {
            self.layer.borderColor=[color CGColor];
        }else if([color isKindOfClass:[NSString class]]){
            self.layer.borderColor=[[self colorWithHexString:color alpha:1]CGColor];
        }
        if (w!=0) {
            self.layer.borderWidth=w;
        }
        return self;
    };
}

- (UIView * (^)(CGFloat radius , BOOL masks))kLayerCornerRadiusToMasks{
    return ^id(CGFloat radius , BOOL masks){
        self.layer.masksToBounds=masks;
        if (radius!=0) {
            self.layer.cornerRadius=radius;
        }
        return self;
    };
}






/**
 *  字符串转成UIColor
 */
-(UIColor *)colorWithHexString: (NSString *)color alpha:(CGFloat)alpha{
    NSString *cString = [[color stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    if ([cString length] < 6) {
        return [UIColor clearColor];
    }
    if ([cString hasPrefix:@"0X"])
        cString = [cString substringFromIndex:2];
    if ([cString hasPrefix:@"#"])
        cString = [cString substringFromIndex:1];
    if ([cString length] != 6)
        return [UIColor clearColor];
    NSRange range;
    range.location = 0;
    range.length = 2;
    NSString *rString = [cString substringWithRange:range];
    range.location = 2;
    NSString *gString = [cString substringWithRange:range];
    range.location = 4;
    NSString *bString = [cString substringWithRange:range];
    unsigned int r, g, b;
    [[NSScanner scannerWithString:rString] scanHexInt:&r];
    [[NSScanner scannerWithString:gString] scanHexInt:&g];
    [[NSScanner scannerWithString:bString] scanHexInt:&b];
    return [UIColor colorWithRed:((float) r / 255.0f) green:((float) g / 255.0f) blue:((float) b / 255.0f) alpha:alpha];
}
@end


