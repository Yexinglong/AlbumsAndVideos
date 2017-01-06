//
//  NYBaseNavVC.m
//  DDNM-NY
//
//  Created by 叶星龙 on 2016/11/27.
//  Copyright © 2016年 北京叮咚柠檬科技有限公司. All rights reserved.
//

#import "NYBaseNavVC.h"
#import "UIImage+YXL.h"
@interface UINavigationController ()<UIGestureRecognizerDelegate>

@end

@implementation NYBaseNavVC

+ (void)initialize{
    [self setupBarButtonItemTheme];
}

/**
 *  设置导航栏按钮主题
 */
+ (void)setupBarButtonItemTheme{
    UINavigationBar * navBar = [UINavigationBar appearance];
    UIImage *image =[UIImage createImageWithColor:[UIColor whiteColor]];
    [navBar setBackgroundImage:image forBarMetrics:UIBarMetricsDefault];
    NSMutableDictionary * dic = [NSMutableDictionary dictionary];
    [dic setObject:[UIFont systemFontOfSize:15] forKey:NSFontAttributeName];
    [dic setObject:[UIColor blackColor] forKey:NSForegroundColorAttributeName];
    navBar.titleTextAttributes = dic;
    navBar.tintColor=[UIColor blackColor];
    navBar.shadowImage=[UIImage createImageWithColor:UIColorFromRGB_HEX(0xe6e6e6)];
}

- (void)viewDidLoad{
    [super viewDidLoad];
    self.interactivePopGestureRecognizer.delegate = self;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if (gestureRecognizer == self.interactivePopGestureRecognizer) {
        if (self.viewControllers.count != 1) {
            return YES;
        }else
        return NO;
    }
    return [super gestureRecognizer:gestureRecognizer shouldReceiveTouch:touch];
}


@end
