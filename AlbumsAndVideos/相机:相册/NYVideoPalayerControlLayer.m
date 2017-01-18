//
//  NYVideoPalayerControlLayer.m
//  DDNM-NY
//
//  Created by 叶星龙 on 2017/1/10.
//  Copyright © 2017年 北京叮咚柠檬科技有限公司. All rights reserved.
//

#import "NYVideoPalayerControlLayer.h"
#import "ASValueTrackingSlider.h"
#import "MMMaterialDesignSpinner.h"
@interface NYVideoPalayerControlLayer ()<UIGestureRecognizerDelegate,NYPlayerViewDelegate,ASValueTrackingSliderDelegate>{
    UIImageView *bottomView;//底部View
    UIButton *startBtn;//开始播放按钮
    UILabel *currentTimeLabel;//当前播放时长label
    UIButton *fullScreenBtn;//全屏按钮
    UILabel *totalTimeLabel;//视频总时长label
    UIProgressView *progressView;//缓冲进度条
    ASValueTrackingSlider *videoSlider;//滑杆
    MMMaterialDesignSpinner *activity;//加载菊花
    UIButton *repeatBtn;//重播按钮
    UIButton *failBtn;//加载失败按钮
    UIView *fastView;//快进快退View
    UIProgressView *fastProgressView;//快进快退进度progress
    UILabel *fastTimeLabel;//快进快退时间
    UIImageView *fastImageView;//快进快退ImageView
    UIProgressView *bottomProgressView;//控制层消失时候在底部显示的播放进度progress
    UIImage *thumbImg;
    NYPlayerState playerState;
    CGFloat sliderLastValue;
    
}

/**
 显示控制层
 */
@property (nonatomic, assign) BOOL showing;
/**
 是否拖拽slider控制播放进度
 */
@property (nonatomic, assign) BOOL dragged;

@end

@implementation NYVideoPalayerControlLayer

-(instancetype)initWithFrame:(CGRect)frame{
    self =[super initWithFrame:frame];
    if (self) {
        [self initUI];
    }
    return self;
}

-(void)initUI{
    
    bottomView =[UIImageView new];
    bottomView.image=[UIImage imageNamed:@"bottom_shadow"];
    bottomView.userInteractionEnabled=YES;
    [self addSubview:bottomView];
    [bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(@0);
        make.bottom.equalTo(@0);
        make.height.equalTo(@50);
    }];
    
    activity = [[MMMaterialDesignSpinner alloc] init];
    activity.lineWidth = 2;
    activity.tintColor = HEX_COLOR_THEME;
    [self addSubview:activity];
    [activity mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self);
        make.size.mas_equalTo(CGSizeMake(45, 45));
    }];
    
    repeatBtn =[UIButton new];
    repeatBtn.kNormalImage(@"repeat_video");
    repeatBtn.kAddTouchUpInside(self,@selector(replayBtnClick));
    [repeatBtn sizeToFit];
    [self addSubview:repeatBtn];
    [repeatBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self);
        make.size.mas_equalTo(repeatBtn.frame.size);
    }];
    
    failBtn =[UIButton new];
    failBtn.kNormalText(@"加载失败，请点击重试");
    failBtn.kTextColor([UIColor whiteColor]);
    failBtn.kFont(@14);
    failBtn.kAddTouchUpInside(self,@selector(failBtnClick));
    [failBtn sizeToFit];
    [self addSubview:failBtn];
    [failBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self);
        make.size.mas_equalTo(failBtn.frame.size);
    }];
    
    fastView =[UIView new];
    fastView.backgroundColor = UIColorRGBA(0, 0, 0, 0.8);
    fastView.kLayerCornerRadiusToMasks(4,YES);
    [self addSubview:fastView];
    [fastView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@125);
        make.height.equalTo(@80);
        make.center.equalTo(self);
    }];
    
    fastImageView =[UIImageView new];
    [fastView addSubview:fastImageView];
    [fastImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@32);
        make.height.equalTo(@32);
        make.top.equalTo(@5);
        make.centerX.equalTo(fastView.mas_centerX);
    }];
    
    fastTimeLabel =[UILabel new];
    fastTimeLabel.textColor =[UIColor whiteColor];
    fastTimeLabel.textAlignment =NSTextAlignmentCenter;
    fastTimeLabel.font =Font(14);
    [fastView addSubview:fastTimeLabel];
    [fastTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(@0);
        make.top.equalTo(fastImageView.mas_bottom).offset(2);
        make.height.equalTo(@15);
    }];
    
    fastProgressView = [[UIProgressView alloc] init];
    fastProgressView.progressTintColor = [UIColor whiteColor];
    fastProgressView.trackTintColor    = [[UIColor lightGrayColor] colorWithAlphaComponent:0.4];
    [fastView addSubview:fastProgressView];
    [fastProgressView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@12);
        make.right.equalTo(@(-12));
        make.top.equalTo(fastTimeLabel.mas_bottom).offset(10);
    }];
    
    
    
    startBtn =[UIButton new];
    startBtn.kNormalImage(@"play");
    startBtn.kAddTouchUpInside(self,@selector(startBtnClick));
    [bottomView addSubview:startBtn];
    [startBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(bottomView.mas_left).offset(5);
        make.centerY.equalTo(bottomView);
        make.width.height.equalTo(@30);
    }];
    
    currentTimeLabel =[UILabel new];
    currentTimeLabel.kTextColor([UIColor whiteColor]).kFont(@12);
    currentTimeLabel.textAlignment=NSTextAlignmentCenter;
    [bottomView addSubview:currentTimeLabel];
    [currentTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(bottomView);
        make.left.equalTo(startBtn.mas_right).offset(5);
        make.height.equalTo(@13);
        make.width.greaterThanOrEqualTo(@45);
    }];
    
    fullScreenBtn =[UIButton new];
    fullScreenBtn.kNormalImage(@"fullscreen");
    fullScreenBtn.kSelectedImage(@"shrinkscreen");
    fullScreenBtn.kAddTouchUpInside(self,@selector(fullScreenBtnClick));
    [bottomView addSubview:fullScreenBtn];
    [fullScreenBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(@(-5));
        make.centerY.equalTo(bottomView);
        make.width.height.equalTo(@30);
    }];
    
    totalTimeLabel =[UILabel new];
    totalTimeLabel.kTextColor([UIColor whiteColor]).kFont(@12);
    totalTimeLabel.textAlignment=NSTextAlignmentCenter;
    [bottomView addSubview:totalTimeLabel];
    [totalTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(fullScreenBtn.mas_left).offset(-5);
        make.centerY.equalTo(bottomView);
        make.height.equalTo(@13);
        make.width.greaterThanOrEqualTo(@45);
    }];
    
    progressView =[[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
    progressView.progressTintColor =UIColorRGBA(255, 255, 255, 0.5);
    progressView.trackTintColor =[UIColor clearColor];
    [bottomView addSubview:progressView];
    [progressView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(currentTimeLabel.mas_right).offset(5);
        make.right.equalTo(totalTimeLabel.mas_left).offset(-5);
        make.centerY.equalTo(bottomView).centerOffset(CGPointMake(0, 1));
    }];
    
    
    videoSlider =[[ASValueTrackingSlider alloc] init];
    videoSlider.popUpViewCornerRadius = 0.0;
    videoSlider.popUpViewColor = UIColorRGBA(19, 19, 9, 1);
    videoSlider.popUpViewArrowLength = 8;
    [videoSlider setThumbImage:[UIImage imageNamed:@"slider"] forState:UIControlStateNormal];
    videoSlider.maximumValue =1;
    videoSlider.minimumTrackTintColor =[UIColor whiteColor];
    videoSlider.maximumTrackTintColor =[UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:0.5];
    // slider开始滑动事件
    [videoSlider addTarget:self action:@selector(progressSliderTouchBegan:) forControlEvents:UIControlEventTouchDown];
    // slider滑动中事件
    [videoSlider addTarget:self action:@selector(progressSliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    // slider结束滑动事件
    [videoSlider addTarget:self action:@selector(progressSliderTouchEnded:) forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchCancel | UIControlEventTouchUpOutside];
    UITapGestureRecognizer *sliderTap =[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapSliderAction:)];
    [videoSlider addGestureRecognizer:sliderTap];
    UIPanGestureRecognizer *panRecognizer =[[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(panRecognizer:)];
    panRecognizer.delegate = self;
    [panRecognizer setMaximumNumberOfTouches:1];
    [panRecognizer setDelaysTouchesBegan:YES];
    [panRecognizer setDelaysTouchesEnded:YES];
    [panRecognizer setCancelsTouchesInView:YES];
    [videoSlider addGestureRecognizer:panRecognizer];
    [bottomView addSubview:videoSlider];
    [videoSlider mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(currentTimeLabel.mas_right).offset(5);
        make.right.equalTo(totalTimeLabel.mas_left).offset(-5);
        make.centerY.equalTo(bottomView);
        make.height.mas_equalTo(30);
    }];

    
    bottomProgressView =[[UIProgressView alloc] init];
    bottomProgressView.progressTintColor =[UIColor whiteColor];
    bottomProgressView.trackTintColor =[[UIColor lightGrayColor] colorWithAlphaComponent:0.4];
    [self addSubview:bottomProgressView];
    [bottomProgressView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(@0);
    }];
    
    [self playerResetControlView];
    // app退到后台
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidEnterBackground) name:UIApplicationWillResignActiveNotification object:nil];
    // app进入前台
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidEnterPlayground) name:UIApplicationDidBecomeActiveNotification object:nil];

    
    
}

-(void)layoutSubviews{
    [super layoutSubviews];
    [self layoutIfNeeded];
    [self playerCancelAutoFadeOutControlView];
    if (playerState !=NYPlayerStateStopped) {
        [self playerShowControlView];
    }

}

/**
 *  取消延时隐藏控制层的方法
 */
- (void)playerCancelAutoFadeOutControlView
{
    self.showing = NO;
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
}

/**
 添加定时器
 */
- (void)autoFadeOutControlView
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(playerHideControlView) object:nil];
    [self performSelector:@selector(playerHideControlView) withObject:nil afterDelay:7];
}

/**
 *  显示控制层
 */
- (void)playerShowControlView{
    if (self.showing) {
        [self playerHideControlView];
        return;
    }
    [self playerCancelAutoFadeOutControlView];
    [UIView animateWithDuration:0.25 animations:^{
        [self showControlView];
    } completion:^(BOOL finished) {
        self.showing = YES;
        [self autoFadeOutControlView];
    }];
    
}

/**
 *  隐藏控制层
 */
- (void)playerHideControlView{
    if (!self.showing) {
        return;
    }
    [self playerCancelAutoFadeOutControlView];
    [UIView animateWithDuration:0.25 animations:^{
        [self hideControlView];
    }completion:^(BOOL finished) {
        self.showing = NO;
    }];
}


-(void)showControlView{
    self.backgroundColor           = UIColorRGBA(0, 0, 0, 0.3);
    bottomProgressView.alpha = 0;
    bottomView.alpha=1;
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
}
-(void)hideControlView{
    self.backgroundColor          = UIColorRGBA(0, 0, 0, 0);
    bottomProgressView.alpha = 1;
    bottomView.alpha=0;
    if (fullScreenBtn.selected && playerState!=NYPlayerStateStopped) {
        [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
    }
}

-(void)playerResetControlView{
    activity.hidden=NO;
    self.showing = NO;
    [activity stopAnimating];
    videoSlider.value = 0;
    bottomProgressView.progress = 0;
    progressView.progress = 0;
    currentTimeLabel.text = @"00:00";
    totalTimeLabel.text = @"00:00";
    fastView.hidden = YES;
    repeatBtn.hidden = YES;
    failBtn.hidden = YES;
    self.backgroundColor = [UIColor clearColor];
    startBtn.kNormalImage(@"play");
}

#pragma -mark 点击
-(void)replayBtnClick{
    [self playerResetControlView];
    [_playerView replay];
}

-(void)failBtnClick{
    [_playerView replay];
}

-(void)startBtnClick{
    if (playerState==NYPlayerStateFailed) {
        [_playerView replay];
    }else if (playerState==NYPlayerStateBuffering) {
        [_playerView pause];
    }else if (playerState==NYPlayerStatePlaying) {
        [_playerView pause];
    }else if (playerState==NYPlayerStateStopped) {
        [self playerResetControlView];
        [_playerView replay];
    }else if (playerState==NYPlayerStatePause) {
        [_playerView play];
    }
}

-(void)fullScreenBtnClick{
    if (fullScreenBtn.selected) {
        fullScreenBtn.selected=NO;
    }else{
        fullScreenBtn.selected=YES;
    }
    [_playerView onDeviceOrientationChange];
}

#pragma -mark set
-(void)setPlayerView:(NYPlayerView *)playerView{
    _playerView=playerView;
}

#pragma -mark slider

/**
 slider滑块的bounds
 */
- (CGRect)thumbRect{
    return [videoSlider thumbRectForBounds:videoSlider.bounds
                                 trackRect:[videoSlider trackRectForBounds:videoSlider.bounds]
                                     value:videoSlider.value];
}

- (void)progressSliderTouchBegan:(ASValueTrackingSlider *)sender{
    [self playerCancelAutoFadeOutControlView];
    _dragged=YES;
    videoSlider.popUpView.hidden = YES;
}

- (void)progressSliderValueChanged:(ASValueTrackingSlider *)sender
{
    if (_playerView.player.currentItem.status == AVPlayerItemStatusReadyToPlay) {
        BOOL style = false;
        CGFloat value   = sender.value - sliderLastValue;
        if (value > 0) { style = YES; }
        if (value < 0) { style = NO; }
        if (value == 0) { return; }
        
        sliderLastValue  = sender.value;
        CGFloat totalTime     = (CGFloat)_playerView.playerItem.duration.value / _playerView.playerItem.duration.timescale;
        //计算出拖动的当前秒数
        CGFloat dragedSeconds = floorf(totalTime * sender.value);
        //转换成CMTime才能给player来控制播放进度
        CMTime dragedCMTime   = CMTimeMake(dragedSeconds, 1);
        
        [self sliderPlayerDraggedTime:dragedSeconds totalTime:totalTime hasPreview:self.hasPreviewView isForward:style];
        
        if (totalTime > 0) { // 当总时长 > 0时候才能拖动slider
            [self playerDraggedTime:dragedSeconds sliderImage:nil];
            if (self.hasPreviewView) {
                [_playerView.imageGenerator cancelAllCGImageGeneration];
                _playerView.imageGenerator.appliesPreferredTrackTransform = YES;
                _playerView.imageGenerator.maximumSize = CGSizeMake(100, 56);
                AVAssetImageGeneratorCompletionHandler handler = ^(CMTime requestedTime, CGImageRef im, CMTime actualTime, AVAssetImageGeneratorResult result, NSError *error){
                    if (result != AVAssetImageGeneratorSucceeded) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            if (thumbImg) {
                                [self playerDraggedTime:dragedSeconds sliderImage:nil];
                            }else{
                                [self playerDraggedTime:dragedSeconds sliderImage:thumbImg];
                            }
                        });
                    } else {
                        thumbImg = [UIImage imageWithCGImage:im];
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self playerDraggedTime:dragedSeconds sliderImage:thumbImg];
                        });
                    }
                };
                [_playerView.imageGenerator generateCGImagesAsynchronouslyForTimes:[NSArray arrayWithObject:[NSValue valueWithCMTime:dragedCMTime]] completionHandler:handler];
            }
        } else {
            // 此时设置slider值为0
            sender.value = 0;
        }
    }else { // player状态加载失败
        // 此时设置slider值为0
        sender.value = 0;
    }
}

- (void)progressSliderTouchEnded:(ASValueTrackingSlider *)sender{
    activity.hidden=NO;
    fastView.hidden =YES;
    self.showing = YES;
    [self autoFadeOutControlView];
    if (_playerView.player.currentItem.status == AVPlayerItemStatusReadyToPlay) {
        _playerView.isPauseByUser = NO;
        _dragged = NO;
        // 视频总时间长度
        CGFloat total =(CGFloat)_playerView.playerItem.duration.value / _playerView.playerItem.duration.timescale;
        //计算出拖动的当前秒数
        NSInteger dragedSeconds =floorf(total * sender.value);
        [_playerView seekToTime:dragedSeconds completionHandler:nil];
    }
}

- (void)playerDraggedTime:(NSInteger)draggedTime sliderImage:(UIImage *)image{
    if (image) {
        [videoSlider setImage:image];
    }
    [videoSlider setText:[self durationStringWithTime:draggedTime]];
}

- (void)sliderPlayerDraggedTime:(NSInteger)draggedTime totalTime:(NSInteger)totalTime hasPreview:(BOOL)preview isForward:(BOOL)forawrd{
    // 快进快退时候停止菊花
    activity.hidden=YES;
    CGFloat  draggedValue    = (CGFloat)draggedTime/(CGFloat)totalTime;
    // 显示、隐藏预览窗
    videoSlider.popUpView.hidden = !preview;
    // 更新slider的值
    videoSlider.value = draggedValue;
    // 更新bottomProgressView的值
    bottomProgressView.progress =draggedValue;
    // 更新当前时间
    currentTimeLabel.text =[self durationStringWithTime:draggedTime];
    // 正在拖动控制播放进度
    self.dragged = YES;
    if (forawrd) {
        fastImageView.kImage(@"fast_forward");
    } else {
        fastImageView.kImage(@"fast_backward");
    }
    if (fullScreenBtn.selected) {
        fastView.hidden =NO;
    }else{
        fastView.hidden =preview;

    }
    fastTimeLabel.text =[NSString stringWithFormat:@"%@ / %@",[self durationStringWithTime:draggedTime],[self durationStringWithTime:totalTime]];
    fastProgressView.progress =draggedValue;
}


- (void)tapSliderAction:(UITapGestureRecognizer *)tap
{
    if ([tap.view isKindOfClass:[UISlider class]]) {
        UISlider *slider = (UISlider *)tap.view;
        CGPoint point = [tap locationInView:slider];
        CGFloat length = slider.frame.size.width;
        // 视频跳转的value
        CGFloat tapValue = point.x / length;
        CGFloat total = (CGFloat)_playerView.playerItem.duration.value / _playerView.playerItem.duration.timescale;
        //计算出拖动的当前秒数
        NSInteger dragedSeconds = floorf(total * tapValue);
        [_playerView seekToTime:dragedSeconds completionHandler:nil];
    }
}
// 不做处理，只是为了滑动slider其他地方不响应其他手势
- (void)panRecognizer:(UIPanGestureRecognizer *)sender {}


#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch{
    CGRect rect = [self thumbRect];
    CGPoint point = [touch locationInView:videoSlider];
    if ([touch.view isKindOfClass:[UISlider class]]) { // 如果在滑块上点击就不响应pan手势
        if (point.x <= rect.origin.x + rect.size.width && point.x >= rect.origin.x) {
            if (playerState == NYPlayerStateFailed || playerState == NYPlayerStateStopped){
                return YES;
            }
            return NO;
        }
    }
    return YES;
}


#pragma -mark NYPlayerViewDelegate

-(void)playerCurrentTime:(NSInteger)currentTime totalTime:(NSInteger)totalTime sliderValue:(CGFloat)value{
    if (_dragged==NO) {
        activity.hidden=NO;
        videoSlider.value =value;
        bottomProgressView.progress =value;
        // 更新当前播放时间
        currentTimeLabel.text =[self durationStringWithTime:currentTime];
    }
    // 更新总时间
    totalTimeLabel.text =[self durationStringWithTime:totalTime];
}

-(void)playerStateChanged:(NYPlayerState )state error:(NSError *)error{
    repeatBtn.hidden=YES;
    failBtn.hidden=YES;
    if (state==NYPlayerStateFailed) {
        if([activity isAnimating]){
            [activity stopAnimating];
        }
        startBtn.kNormalImage(@"play");
        failBtn.hidden=NO;
        NSLog(@"NYPlayerStateFailed");
    }else if (state==NYPlayerStateBuffering) {
        if(![activity isAnimating]){
            [activity startAnimating];
        }
        startBtn.kNormalImage(@"pause");
        NSLog(@"NYPlayerStateBuffering");
    }else if (state==NYPlayerStatePlaying) {
        if([activity isAnimating]){
            [activity stopAnimating];
        }
        startBtn.kNormalImage(@"pause");
        NSLog(@"NYPlayerStatePlaying");
    }else if (state==NYPlayerStateStopped) {
        if([activity isAnimating]){
            [activity stopAnimating];
        }
        startBtn.kNormalImage(@"home_more");
        repeatBtn.hidden=NO;
        NSLog(@"NYPlayerStateStopped");
    }else if (state==NYPlayerStatePause) {
        NSLog(@"NYPlayerStatePause");
        if([activity isAnimating]){
            [activity stopAnimating];
        }
        startBtn.kNormalImage(@"play");
    }
    playerState=state;
}

-(void)playerSetProgress:(CGFloat)progress{
    [progressView setProgress:progress animated:NO];
}

-(void)playerDraggedTime:(NSInteger)draggedTime totalTime:(NSInteger)totalTime isForward:(BOOL)forawrd{    [self sliderPlayerDraggedTime:draggedTime totalTime:totalTime hasPreview:NO isForward:forawrd];
}

-(void)playerDraggedEnd{
    _dragged=NO;
    fastView.hidden =YES;
    self.backgroundColor  = UIColorRGBA(0, 0, 0, 0.3);
    self.showing = NO;
    [self playerShowControlView];
}


-(void)playerIsFullScreen:(BOOL)isFullScreen{
    fullScreenBtn.selected=isFullScreen;
}

-(void)playerScreenClick{
    if (!self.dragged) {
        [self playerShowControlView];
    }
}

#pragma -mark 通知
/**
 *  应用退到后台
 */
- (void)appDidEnterBackground{
    [self playerCancelAutoFadeOutControlView];
}

/**
 *  应用进入前台
 */
- (void)appDidEnterPlayground
{
    [self playerShowControlView];
}

#pragma -mark 公用

- (NSString *)durationStringWithTime:(NSInteger)time{
    // 获取分钟
    NSString *min = [NSString stringWithFormat:@"%02ld",time / 60];
    // 获取秒数
    NSString *sec = [NSString stringWithFormat:@"%02ld",time % 60];
    NSString *hour =@"";
    if([min integerValue] >60){
        hour =[NSString stringWithFormat:@"%02ld",[min integerValue] / 60];
        return [NSString stringWithFormat:@"%@:%@:%@",hour, [NSString stringWithFormat:@"%02ld",[min integerValue] % 60], sec];
    }
    
    return [NSString stringWithFormat:@"%@:%@", min, sec];
}
@end
