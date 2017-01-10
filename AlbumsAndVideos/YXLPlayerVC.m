//
//  YXLPlayerVC.m
//  AlbumsAndVideos
//
//  Created by 叶星龙 on 2017/1/6.
//  Copyright © 2017年 北京叮咚柠檬科技有限公司. All rights reserved.
//

#import "YXLPlayerVC.h"
#import "NYPlayerModel.h"
#import "NYPlayerView.h"
#import "UIView+NYTransform.h"
@interface YXLPlayerVC (){
    NYPlayerView *playerView;
}

@end

@implementation YXLPlayerVC


-(instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    self =[super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.hiddenNavigationBarWhenViewWillAppear=YES;
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor=[UIColor whiteColor];
    
    [self.backBtn setImage:[UIImage imageNamed:@"fanhuibai"] forState:UIControlStateNormal];
    
    
    NYPlayerModel *model =[NYPlayerModel new];
    model.videoURL=[NSURL URLWithString:@"http://baobab.wdjcdn.com/1456117847747a_x264.mp4"];
    
    NYPlayerView *view =[NYPlayerView new];
    view.playerModel=model;
    [self.view addSubview:view];
    view.fatherView=self.view;
    view.makeArray =[view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(@0);
        make.height.equalTo(@300);
    }];
    [view autoPlayTheVideo];
    playerView =view;
  

    [playerView addSubview:self.backBtn];
    [self.backBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(@(20+12-5));
        make.left.equalTo(@(20-5));
        make.size.mas_equalTo(CGSizeMake(self.backBtn.frame.size.width,self.backBtn.frame.size.width));
    }];
  
    
    
    
    UILabel *label =[UILabel new];
    label.kText(@"视频的UI层在视频相册里面，把手势添加上去了，我的代码借鉴ZFPlayer，手势有左右横向快进快退  双击播放暂停  视频左右两边垂直上下滑动调整亮度和音量,UI层大家自己去定义吧！");
    label.kFont(@15);
    label.textColor=[UIColor redColor];
    label.numberOfLines=0;
    [self.view addSubview:label];
    [label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(@0);
        make.left.right.equalTo(@0);
        make.height.greaterThanOrEqualTo(@16);
    }];
    
    
    if (_is) {
        UIView *view=[UIView new];
        view.backgroundColor=[UIColor redColor];
        [self.view addSubview:view];
        [view mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(@200);
            make.left.right.equalTo(@0);
            make.height.equalTo(@30);
        }];
        
        
        
    }
}


-(void)back:(id)sender{
    UIInterfaceOrientation currentOrientation = [UIApplication sharedApplication].statusBarOrientation;
    if (currentOrientation == UIInterfaceOrientationPortrait) {
        [playerView pause];
        [self.navigationController popViewControllerAnimated:YES];
    }else{
        [playerView onDeviceOrientationChange];
    }
    
}


@end
