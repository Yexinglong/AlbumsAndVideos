//
//  NYVideoPlayerVC.m
//  DDNM-NY
//
//  Created by 叶星龙 on 2016/12/30.
//  Copyright © 2016年 北京叮咚柠檬科技有限公司. All rights reserved.
//

#import "NYVideoPlayerVC.h"
#import "NYImageManager.h"
#import "NYPlayerView.h"
#import "UIView+NYTransform.h"
@interface NYVideoPlayerVC (){
    NYPlayerView *playerView;
}

@end

@implementation NYVideoPlayerVC


-(instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    self =[super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.hiddenNavigationBarWhenViewWillAppear=YES;
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor=[UIColor blackColor];
    
    [self.backBtn setImage:[UIImage imageNamed:@"fanhuibai"] forState:UIControlStateNormal];
    
    playerView =[NYPlayerView new];
    [self.view addSubview:playerView];
    playerView.fatherView=self.view;
    playerView.makeArray =[playerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.bottom.equalTo(@0);
    }];
    
    
    [[NYImageManager manager] getVideoWithAsset:_assetModel.asset completion:^(AVPlayerItem *playerItem, NSDictionary *info) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NYPlayerModel *model =[NYPlayerModel new];
            model.videoURL=((AVURLAsset *)playerItem.asset).URL;
            playerView.playerModel=model;
            [playerView autoPlayTheVideo];
            
        });
    }];
    
    [playerView addSubview:self.backBtn];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onStatusBarOrientationChange)
                                                 name:UIApplicationDidChangeStatusBarOrientationNotification
                                               object:nil];
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

-(void)onStatusBarOrientationChange{
    [self.backBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(@(20+12-5));
        make.left.equalTo(@(20-5));
        make.size.mas_equalTo(CGSizeMake(self.backBtn.frame.size.width,self.backBtn.frame.size.width));
    }];

}


@end
