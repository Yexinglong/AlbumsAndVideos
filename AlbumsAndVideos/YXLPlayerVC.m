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
#import "NYVideoPalayerControlLayer.h"
@interface YXLPlayerVC (){
    NYPlayerView *playerView;
    BOOL isAppearPlayer;
    NYVideoPalayerControlLayer*controlLayer;
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
  

    
  
    controlLayer=[NYVideoPalayerControlLayer new];
    controlLayer.playerView=playerView;
    controlLayer.hasPreviewView=YES;
    playerView.delegate=(id)controlLayer;
    [playerView addSubview:controlLayer];
    [controlLayer mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsZero);
    }];
    
    [playerView addSubview:self.backBtn];
    [self.backBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(@(20+12-5));
        make.left.equalTo(@(20-5));
        make.size.mas_equalTo(CGSizeMake(self.backBtn.frame.size.width,self.backBtn.frame.size.width));
    }];
    
    UILabel *label =[UILabel new];
    label.kText(@"我的代码借鉴ZFPlayer，手势有左右横向快进快退  双击播放暂停  视频左右两边垂直上下滑动调整亮度和音量");
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
    
    
    UIButton *btn =[UIButton new];
    btn.kNormalText(@"跳转下一个控制器");
    btn.kBackgroundColor([UIColor blackColor]);
    btn.kAddTouchUpInside(self,@selector(click));
    [self.view addSubview:btn];
    [btn sizeToFit];
    [btn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(label.mas_top).offset(-20);
        make.centerX.equalTo(self.view);
    }];
    
}

-(void)click{
    NYBaseVC *vc =[NYBaseVC new];
    [self.navigationController pushViewController:vc animated:YES];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if (playerView) {
        if (isAppearPlayer==YES) {
            isAppearPlayer=NO;
            if (playerView.state ==NYPlayerStatePause ||playerView.state == NYPlayerStateBuffering) {
                if (NYPlayerStateBuffering !=playerView.state) {
                    [playerView play];
                }
            }
        }
    }
}

-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    if (playerView) {
        if (playerView.isPauseByUser) {
            return;
        }
        if (playerView.state ==NYPlayerStatePlaying ||playerView.state == NYPlayerStateBuffering ) {
            [playerView pause];
            isAppearPlayer=YES;
        }
        
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
