//
//  NYBaseVC.h
//  DDNM-NY
//
//  Created by 叶星龙 on 2016/11/26.
//  Copyright © 2016年 北京叮咚柠檬科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NYBaseVC : UIViewController


/**
 push返回按钮
 */
@property (nonatomic ,strong )UIButton * backBtn;

/**
 nav返回item
 */
@property (nonatomic, readonly, strong) UIBarButtonItem * backItem;

/**
 如果为 YES  view will apppear的时候会隐藏(YES)/显示(NO)navigationBar
 */
@property (nonatomic) BOOL hiddenNavigationBarWhenViewWillAppear;

/**
 如果不是push界面过来的，需要标记是否显示dismiss按钮   默认加 NO
 */
@property (nonatomic) BOOL isNavLeftDismiss;
/**
 navigationController push一个新的界面
 
 @param className class的name 默认按照  [[class alloc]init]方法进行初始化
 */
- (void)pushViewControllerWithClassName:(NSString *)className;

/**
 隐藏键盘
 */
- (void)hiddenKeyborad;

/**
 回退按钮的事件,默认是navigationController.pop函数
 
 @param sender 可选
 */
- (void)back:(id)sender;

/**
 回退按钮的事件,默认是dismiss函数
 */
-(void)cancel:(id)sender;



@end
