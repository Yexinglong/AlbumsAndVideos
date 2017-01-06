//
//  NYBaseVC.m
//  DDNM-NY
//
//  Created by 叶星龙 on 2016/11/26.
//  Copyright © 2016年 北京叮咚柠檬科技有限公司. All rights reserved.
//

#import "NYBaseVC.h"

@interface NYBaseVC ()

@end

@implementation NYBaseVC

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.hiddenNavigationBarWhenViewWillAppear=NO;
    }
    return self;
}

- (void)pushViewControllerWithClassName:(NSString *)className
{
    UIViewController * viewController = [[NSClassFromString(className) alloc]init];
    [self.navigationController pushViewController:viewController animated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    [self addLeftBackItem];
}

/**
 添加push或Modal返回按钮
 */
-(void)addLeftBackItem{
    NSArray *viewcontrollers=self.navigationController.viewControllers;
    UIButton *btn= [UIButton buttonWithType:UIButtonTypeCustom];
    if (viewcontrollers.count>1) {
        if ([viewcontrollers objectAtIndex:viewcontrollers.count-1]==self) {
            [btn setImage:[UIImage imageNamed:@"Return"] forState:UIControlStateNormal];
            [btn addTarget:self action:@selector(back:) forControlEvents:UIControlEventTouchUpInside];
        }
    }
    else{
        [btn setImage:[UIImage imageNamed:@"Camera_Cancel"] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(cancel:) forControlEvents:UIControlEventTouchUpInside];
    }
    _backBtn=btn;
    [btn sizeToFit];
    _backBtn.kFrameXYWH(0,0,30,30);
    _backBtn.imageView.contentMode=UIViewContentModeLeft;

    if(self.hiddenNavigationBarWhenViewWillAppear){
        [self.view addSubview:btn];
        [btn mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(@(20+12-5));
            make.left.equalTo(@(20-5));
            make.size.mas_equalTo(CGSizeMake(self.backBtn.frame.size.width,self.backBtn.frame.size.width));
        }];
     
    }else{
        if(self.isNavLeftDismiss==NO){
            self.navigationItem.leftBarButtonItem=[[UIBarButtonItem alloc]initWithCustomView:_backBtn];
        }
    }
}



- (IBAction)hiddenKeyborad{
    [self.view endEditing:YES];
}

- (void)back:(id)sender{
    if (self.navigationController.interactivePopGestureRecognizer.enabled==NO) {
        self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    }
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)cancel:(id)sender{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:self.hiddenNavigationBarWhenViewWillAppear animated:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    //    [MobClick endLogPageView:[NSString stringWithFormat:@"%@",[self class]]];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    //    [MobClick beginLogPageView:[NSString stringWithFormat:@"%@",[self class]]];
}
@end
