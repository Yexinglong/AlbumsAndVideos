//
//  NYPlayerView.m
//  testVideo
//
//  Created by 叶星龙 on 2017/1/3.
//  Copyright © 2017年 北京叮咚柠檬科技有限公司. All rights reserved.
//

#import "NYPlayerView.h"
#import "NYBrightnessView.h"
#import "MMMaterialDesignSpinner.h"
#import "UIView+NYTransform.h"
// 枚举值，包含水平移动方向和垂直移动方向
typedef NS_ENUM(NSInteger, PanDirection){
    PanDirectionHorizontalMoved, // 横向移动
    PanDirectionVerticalMoved    // 纵向移动
};

@interface NYPlayerView ()<UIGestureRecognizerDelegate>{
    
    id timeObserve;
    UISlider *volumeViewSlider;//滑杆
    CGFloat sumTime;//用来保存快进的总时长
    PanDirection panDirection;//定义一个实例变量，保存枚举值
    BOOL isVolume;//是否在调节音量
    BOOL isLocalVideo;//是否播放本地文件
    BOOL playDidEnd;//播放完了
    BOOL isAutoPlay;//是否自动播放
    BOOL isBuffering;
    UIPanGestureRecognizer *panRecognizer;
    UITapGestureRecognizer *doubleTap;
    UITapGestureRecognizer *singleTap;
    NSInteger layerIndex;
    
}

@property (nonatomic, assign) NYPlayerState state;



@end

@implementation NYPlayerView


-(instancetype)init{
    self =[super init];
    if (self) {

        
        [self addSubview:[NYBrightnessView new]];
        
        _playerLayerGravity=NYPlayerLayerGravityResizeAspect;
        self.backgroundColor = [UIColor blackColor];
        // app退到后台
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidEnterBackground) name:UIApplicationWillResignActiveNotification object:nil];
        // app进入前台
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidEnterPlayground) name:UIApplicationDidBecomeActiveNotification object:nil];
    }
    return self;
}



- (void)layoutSubviews{
    [super layoutSubviews];
    [self layoutIfNeeded];
    _playerLayer.frame = self.bounds;
}


#pragma -mark set
/**
 设置playerLayer的填充模式
 */
- (void)setPlayerLayerGravity:(NYPlayerLayerGravity)playerLayerGravity{
    _playerLayerGravity = playerLayerGravity;
    switch (playerLayerGravity) {
        case NYPlayerLayerGravityResize:
            _playerLayer.videoGravity = AVLayerVideoGravityResize;
            break;
        case NYPlayerLayerGravityResizeAspect:
            _playerLayer.videoGravity = AVLayerVideoGravityResizeAspect;
            break;
        case NYPlayerLayerGravityResizeAspectFill:
            _playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
            break;
        default:
            break;
    }
}


/**
 设置播放的状态
 */
- (void)setState:(NYPlayerState)state{
    _state = state;
//    if (state==NYPlayerStateFailed) {
//        replayBtn.kNormalImage(@"repeat_video");
//        replayBtn.hidden=NO;
//        if([_activity isAnimating]){
//            [_activity stopAnimating];
//        }
//        NSLog(@"NYPlayerStateFailed");
//    }else if (state==NYPlayerStateBuffering) {
//        replayBtn.hidden=YES;
//        
//        if(![_activity isAnimating]){
//            [_activity startAnimating];
//        }
//        NSLog(@"NYPlayerStateBuffering");
//    }else if (state==NYPlayerStatePlaying) {
//        replayBtn.hidden=YES;
//        if([_activity isAnimating]){
//            [_activity stopAnimating];
//        }
//        NSLog(@"NYPlayerStatePlaying");
//    }else if (state==NYPlayerStateStopped) {
//        replayBtn.hidden=NO;
//        replayBtn.kNormalImage(@"repeat_video");
//
//        if([_activity isAnimating]){
//            [_activity stopAnimating];
//        }
//        NSLog(@"NYPlayerStateStopped");
//    }else if (state==NYPlayerStatePause) {
//        replayBtn.hidden=YES;
//        
//        NSLog(@"NYPlayerStatePause");
//        if([_activity isAnimating]){
//            [_activity stopAnimating];
//        }
//    }
    
    NSError *error=nil;
    if (state == NYPlayerStateFailed) {
        error = [self.playerItem error];
    }
    if (_delegate && [_delegate respondsToSelector:@selector(playerStateChanged:error:)]) {
        [_delegate playerStateChanged:state error:error];
    }
}

/**
 添加player通知和kvo
 */
- (void)setPlayerItem:(AVPlayerItem *)playerItem{
    if ([_playerItem isEqual:playerItem]) {
        return;
    }
    _playerItem = playerItem;
    if (playerItem) {
        // 播放完毕
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moviePlayDidEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:playerItem];
        // 播放状态
        [playerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
        // 缓冲进度
        [playerItem addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];
        // 缓冲区空了，需要等待数据
        [playerItem addObserver:self forKeyPath:@"playbackBufferEmpty" options:NSKeyValueObservingOptionNew context:nil];
        // 缓冲区有足够数据可以播放了
        [playerItem addObserver:self forKeyPath:@"playbackLikelyToKeepUp" options:NSKeyValueObservingOptionNew context:nil];
    }
}

#pragma -mark KVO
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    if (object == _player.currentItem) {
        if ([keyPath isEqualToString:@"status"]) {
            if (_player.currentItem.status == AVPlayerItemStatusReadyToPlay) {
                if(self.state==NYPlayerStateStopped ||self.state== NYPlayerStateFailed){
                    return;
                }
                
                [self setNeedsLayout];
                [self layoutIfNeeded];
                // 添加playerLayer到self.layer
                [self.layer insertSublayer:_playerLayer atIndex:0];
                if (!isLocalVideo) {
                    self.state = NYPlayerStateBuffering;
                }else{
                    self.state = NYPlayerStatePlaying;
                }
                // 加载完成后，再添加平移手势
                // 添加平移手势，用来控制音量、亮度、快进快退
                if (panRecognizer) {
                    [self removeGestureRecognizer:panRecognizer];
                    panRecognizer=nil;
                }
                panRecognizer = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(panDirection:)];
                panRecognizer.delegate = self;
                [panRecognizer setMaximumNumberOfTouches:1];
                [panRecognizer setDelaysTouchesBegan:YES];
                [panRecognizer setDelaysTouchesEnded:YES];
                [panRecognizer setCancelsTouchesInView:YES];
                [self addGestureRecognizer:panRecognizer];
                // 跳到xx秒播放视频暂时没用，是用户记录切换分辨率的时间的，或者是手动记录上一次片子的时间
                if (_playerModel.seekTime) {
                    [self seekToTime:_playerModel.seekTime.integerValue completionHandler:nil];
                }
            } else if (_player.currentItem.status == AVPlayerItemStatusFailed) {
                self.state = NYPlayerStateFailed;
            }
        } else if ([keyPath isEqualToString:@"loadedTimeRanges"]) {
            // 计算缓冲进度
            NSTimeInterval timeInterval = [self availableDuration];
            CMTime duration = self.playerItem.duration;
            CGFloat totalDuration = CMTimeGetSeconds(duration);
            if (_delegate && [_delegate respondsToSelector:@selector(playerSetProgress:)]) {
                [_delegate playerSetProgress:timeInterval/totalDuration];
            }
        } else if ([keyPath isEqualToString:@"playbackBufferEmpty"]) {
            // 当缓冲是空的时候
            if(self.state==NYPlayerStateStopped ||self.state== NYPlayerStateFailed){
                return;
            }
            if (self.playerItem.playbackBufferEmpty) {
                self.state = NYPlayerStateBuffering;
                [self bufferingSomeSecond];
            }
        } else if ([keyPath isEqualToString:@"playbackLikelyToKeepUp"]) {
            // 当缓冲好的时候
            if(self.state==NYPlayerStateStopped ||self.state== NYPlayerStateFailed){
                return;
            }
            if(self.state!=NYPlayerStatePause){
                [self bufferingSomeSecond];
            }
            
        }
    }
}

#pragma -mark 播放相关调用
/**
 自动播放，默认不自动播放
 */
- (void)autoPlayTheVideo{
    [self configNYPlayer];
}

/**
 重置player
 */
- (void)resetPlayer{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:_playerItem];
    [_playerItem removeObserver:self forKeyPath:@"status"];
    [_playerItem removeObserver:self forKeyPath:@"loadedTimeRanges"];
    [_playerItem removeObserver:self forKeyPath:@"playbackBufferEmpty"];
    [_playerItem removeObserver:self forKeyPath:@"playbackLikelyToKeepUp"];
    playDidEnd = NO;
    _playerItem = nil;
    isAutoPlay = NO;
    [self removeGesture];
    if (timeObserve) {
        [_player removeTimeObserver:timeObserve];
        timeObserve = nil;
    }
    // 移除通知
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    // 暂停
    [_player pause];
    // 移除原来的layer
    [_playerLayer removeFromSuperlayer];
    // 替换PlayerItem为nil
    [_player replaceCurrentItemWithPlayerItem:nil];
    // 把player置为nil
    _imageGenerator = nil;
    _player = nil;
}


/**
 初始化Player
 */
- (void)configNYPlayer{
    _urlAsset = [AVURLAsset assetWithURL:_playerModel.videoURL];
    _imageGenerator = [AVAssetImageGenerator assetImageGeneratorWithAsset:_urlAsset];
    // 初始化playerItem
    self.playerItem = [AVPlayerItem playerItemWithAsset:_urlAsset];
    // 每次都重新创建Player，替换replaceCurrentItemWithPlayerItem:，该方法阻塞线程
    _player = [AVPlayer playerWithPlayerItem:_playerItem];
    _playerLayer = [AVPlayerLayer playerLayerWithPlayer:_player];
    // 此处为默认视频填充模式
    _playerLayer.videoGravity = [self getVideoGravity:_playerLayerGravity];
    isAutoPlay = YES;
    // 添加播放进度计时器
    [self createTimer];
    // 获取系统音量
    [self configureVolume];
    //添加手势
    [self createGesture];
    // 本地文件不设置NYPlayerStateBuffering状态
    if ([_playerModel.videoURL.scheme isEqualToString:@"file"]) {
        self.state = NYPlayerStatePlaying;
        isLocalVideo = YES;
    } else {
        self.state = NYPlayerStateBuffering;
        isLocalVideo = NO;
    }
    // 开始播放
    _isPauseByUser = NO;
    [_player play];
}


- (NSString *)getVideoGravity:(NYPlayerLayerGravity)playerLayerGravity{
    switch (playerLayerGravity) {
        case NYPlayerLayerGravityResize:
            return  AVLayerVideoGravityResize;
        case NYPlayerLayerGravityResizeAspect:
            return AVLayerVideoGravityResizeAspect;
        case NYPlayerLayerGravityResizeAspectFill:
            return AVLayerVideoGravityResizeAspectFill;
        default:
            return AVLayerVideoGravityResizeAspect;
    }
}

-(void)stop{
    self.state=NYPlayerStateStopped;
    [self resetPlayer];
}

-(void)replay{
    [self resetPlayer];
    [self configNYPlayer];
}

/**
 播放
 */
- (void)play{
    if (!self.playerItem.isPlaybackLikelyToKeepUp &&!isLocalVideo) {
        _isPauseByUser = NO;
        [self bufferingSomeSecond];
    }else{
        self.state = NYPlayerStatePlaying;
        _isPauseByUser = NO;
        [_player play];
    }
}

/**
 暂停
 */
- (void)pause{
    self.state = NYPlayerStatePause;
    _isPauseByUser = YES;
    [_player pause];
}

/**
 回调播放器时间 当前播放时长:currentTime 总时长:totalTime slider的value(0.0~1.0):value
 */
- (void)createTimer{
    __weak typeof(AVPlayerItem *) weak_playerItem = _playerItem;
    __weak typeof(self) weakSelf = self;
    timeObserve = [_player addPeriodicTimeObserverForInterval:CMTimeMakeWithSeconds(1, 1) queue:nil usingBlock:^(CMTime time){
        AVPlayerItem *currentItem = weak_playerItem;
        NSArray *loadedRanges = currentItem.seekableTimeRanges;
        if (loadedRanges.count > 0 && currentItem.duration.timescale != 0) {
            NSInteger currentTime = (NSInteger)CMTimeGetSeconds([currentItem currentTime]);
            CGFloat totalTime     = (CGFloat)currentItem.duration.value / currentItem.duration.timescale;
            CGFloat value         = CMTimeGetSeconds([currentItem currentTime]) / totalTime;
            if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(playerCurrentTime:totalTime:sliderValue:)]) {
                [weakSelf.delegate playerCurrentTime:currentTime totalTime:totalTime sliderValue:value];
            }
        }
    }];
}

/**
 获取系统音量
 */
- (void)configureVolume{
    MPVolumeView *volumeView = [[MPVolumeView alloc] init];
    volumeViewSlider = nil;
    for (UIView *view in [volumeView subviews]){
        if ([view.class.description isEqualToString:@"MPVolumeSlider"]){
            volumeViewSlider = (UISlider *)view;
            
            break;
        }
    }
    // 使用这个category的应用不会随着手机静音键打开而静音，可在手机静音下播放声音
    NSError *setCategoryError = nil;
    BOOL success = [[AVAudioSession sharedInstance]
                    setCategory: AVAudioSessionCategoryPlayback
                    error: &setCategoryError];
    if (!success) { /* handle the error in setCategoryError */ }
    // 监听耳机插入和拔掉通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(audioRouteChangeListenerCallback:) name:AVAudioSessionRouteChangeNotification object:nil];
}

/**
 删除手势
 */
-(void)removeGesture{
    if (doubleTap) {
        [self removeGestureRecognizer:doubleTap];
        doubleTap =nil;
    }
    if (singleTap) {
        [self removeGestureRecognizer:singleTap];
        singleTap =nil;
    }
}

/**
 添加双击(播放/暂停)
 */
- (void)createGesture{
    singleTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(singleTapAction:)];
    singleTap.delegate                = self;
    singleTap.numberOfTouchesRequired = 1; //手指数
    singleTap.numberOfTapsRequired    = 1;
    [self addGestureRecognizer:singleTap];
    // 双击(播放/暂停)
    doubleTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(doubleTapAction:)];
    doubleTap.delegate                = self;
    doubleTap.numberOfTouchesRequired = 1; //手指数
    doubleTap.numberOfTapsRequired    = 2;
    [self addGestureRecognizer:doubleTap];
    // 解决点击当前view时候响应其他控件事件
    [singleTap setDelaysTouchesBegan:YES];
    [doubleTap setDelaysTouchesBegan:YES];
    // 双击失败响应单击事件
    [singleTap requireGestureRecognizerToFail:doubleTap];
}

/**
 计算缓冲进度
 */
- (NSTimeInterval)availableDuration {
    NSArray *loadedTimeRanges = [[_player currentItem] loadedTimeRanges];
    CMTimeRange timeRange     = [loadedTimeRanges.firstObject CMTimeRangeValue];// 获取缓冲区域
    float startSeconds        = CMTimeGetSeconds(timeRange.start);
    float durationSeconds     = CMTimeGetSeconds(timeRange.duration);
    NSTimeInterval result     = startSeconds + durationSeconds;// 计算缓冲总进度
    return result;
}

/**
 缓冲较差时候回调这里
 */
- (void)bufferingSomeSecond{
    if(self.state==NYPlayerStateStopped ||self.state== NYPlayerStateFailed){
        return;
    }
    self.state = NYPlayerStateBuffering;
    // playbackBufferEmpty会反复进入，因此在bufferingOneSecond延时播放执行完之前再调用bufferingSomeSecond都忽略
    if (isBuffering) return;
    isBuffering = YES;
    // 需要先暂停一小会之后再播放，否则网络状况不好的时候时间在走，声音播放不出来
    [_player pause];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if(self.state==NYPlayerStateStopped ||self.state== NYPlayerStateFailed){
            isBuffering = NO;
            return;
        }
        // 如果此时用户已经暂停了，则不再需要开启播放了
        if (_isPauseByUser) {
            isBuffering = NO;
            return;
        }
        // 如果执行了play还是没有播放则说明还没有缓存好，则再次缓存一段时间
        isBuffering = NO;
        if (!self.playerItem.isPlaybackLikelyToKeepUp) {
            [self bufferingSomeSecond];
        }else{
            [self play];
        }
    });
}

/**
 从xx秒开始播放视频跳转
 */
- (void)seekToTime:(NSInteger)dragedSeconds completionHandler:(void (^)(BOOL finished))completionHandler{
    if (_player.currentItem.status == AVPlayerItemStatusReadyToPlay) {
        if(self.state==NYPlayerStateStopped ||self.state== NYPlayerStateFailed){
            return;
        }
        if (!isLocalVideo) {
            self.state = NYPlayerStateBuffering;
        }
        // seekTime:completionHandler:不能精确定位
        // 如果需要精确定位，可以使用seekToTime:toleranceBefore:toleranceAfter:completionHandler:
        // 转换成CMTime才能给player来控制播放进度
        [_player pause];
        CMTime dragedCMTime = CMTimeMake(dragedSeconds, 1); //kCMTimeZero
        __weak typeof(self) weakSelf = self;
        [_player seekToTime:dragedCMTime toleranceBefore:CMTimeMake(1,1) toleranceAfter:CMTimeMake(1,1) completionHandler:^(BOOL finished) {
            // 视频跳转回调
            if (completionHandler) {
                completionHandler(finished);
            }
            if (!weakSelf.playerItem.isPlaybackLikelyToKeepUp && !isLocalVideo) {
                weakSelf.state = NYPlayerStateBuffering;
            }else{
                if (!isLocalVideo) {
                    [self bufferingSomeSecond];
                }else{
                    [self play];
                }
            }
        }];
    }
}

-(void)onDeviceOrientationChange{
    UIInterfaceOrientation currentOrientation = [UIApplication sharedApplication].statusBarOrientation;
    if (currentOrientation == UIInterfaceOrientationPortrait) {
        if(_delegate && [_delegate respondsToSelector:@selector(playerIsFullScreen:)]){
            [_delegate playerIsFullScreen:YES];
        }
        layerIndex=[self.fatherView.subviews indexOfObject:self];
        
        [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationLandscapeRight animated:YES];
        [UIApplication sharedApplication].statusBarHidden = NO;
        [[[UIApplication sharedApplication].windows lastObject] addSubview:self];
        [self mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake([[UIScreen mainScreen]bounds].size.width, [[UIScreen mainScreen]bounds].size.height));
            make.center.equalTo([[UIApplication sharedApplication].windows lastObject]);
        }];

        [UIView animateWithDuration:0.3 animations:^{
            self.transform = [UIView getTransformRotationAngle];
        }];
    }else{
        if(_delegate && [_delegate respondsToSelector:@selector(playerIsFullScreen:)]){
            [_delegate playerIsFullScreen:NO];
        }
        [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationPortrait animated:YES];
        [self.fatherView insertSubview:self atIndex:layerIndex];
        NSArray *installedConstraints = [MASViewConstraint installedConstraintsForView:self];
        for (MASConstraint *constraint in installedConstraints) {
            [constraint uninstall];
        }
        NSArray *constraints = self.makeArray.copy;
        for (MASConstraint *constraint in constraints) {
            [constraint install];
        }
        
        [UIView animateWithDuration:0.3 animations:^{
            self.transform =  [UIView getTransformRotationAngle];
        }];
        
    }
}


#pragma -mark 代理方法
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch{
    if ([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
        if (playDidEnd){
            return NO;
        }
    }
    if ([touch.view isKindOfClass:[UISlider class]]) {
        return NO;
    }
    
    return YES;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    if (isAutoPlay) {
        UITouch *touch = [touches anyObject];
        if(touch.tapCount == 1) {
            [self performSelector:@selector(singleTapAction:) withObject:@(NO) ];
        } else if (touch.tapCount == 2) {
            [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(singleTapAction:) object:nil];
            [self doubleTapAction:touch.gestureRecognizers.lastObject];
        }
    }
}


- (void)singleTapAction:(UIGestureRecognizer *)gesture{
    if ([gesture isKindOfClass:[NSNumber class]] && ![(id)gesture boolValue]) {
        [self onDeviceOrientationChange];
        return;
    }
    if(_delegate && [_delegate respondsToSelector:@selector(playerScreenClickIsPlayEnd:)]){
        [_delegate playerScreenClickIsPlayEnd:playDidEnd];
    }
    
}

/**
 双击播放/暂停
 */
- (void)doubleTapAction:(UIGestureRecognizer *)gesture{
    if (playDidEnd) {
        return;
    }
    if (_isPauseByUser) {
        [self play];
    }else {
        [self pause];
    }
    if (!isAutoPlay) {
        isAutoPlay = YES;
        [self configNYPlayer];
    }
    
}

/**
 pan手势事件
 */
- (void)panDirection:(UIPanGestureRecognizer *)pan{
    //根据在view上Pan的位置，确定是调音量还是亮度
    CGPoint locationPoint = [pan locationInView:self];
    // 我们要响应水平移动和垂直移动
    // 根据上次和本次移动的位置，算出一个速率的point
    CGPoint veloctyPoint = [pan velocityInView:self];
    // 判断是垂直移动还是水平移动
    switch (pan.state) {
        case UIGestureRecognizerStateBegan:{ // 开始移动
            // 使用绝对值来判断移动的方向
            CGFloat x = fabs(veloctyPoint.x);
            CGFloat y = fabs(veloctyPoint.y);
            if (x > y) { // 水平移动
                // 取消隐藏
                panDirection = PanDirectionHorizontalMoved;
                // 给sumTime初值
                CMTime time = _player.currentTime;
                sumTime = time.value/time.timescale;
            }
            else if (x < y){ // 垂直移动
                panDirection = PanDirectionVerticalMoved;
                // 开始滑动的时候,状态改为正在控制音量
                if (locationPoint.x > self.bounds.size.width / 2) {
                    isVolume = YES;
                }else { // 状态改为显示亮度调节
                    isVolume = NO;
                }
            }
            break;
        }
        case UIGestureRecognizerStateChanged:{ // 正在移动
            switch (panDirection) {
                case PanDirectionHorizontalMoved:{
                    [self horizontalMoved:veloctyPoint.x]; // 水平移动的方法只要x方向的值
                    break;
                }
                case PanDirectionVerticalMoved:{
                    [self verticalMoved:veloctyPoint.y]; // 垂直移动方法只要y方向的值
                    break;
                }
                default:
                    break;
            }
            break;
        }
        case UIGestureRecognizerStateEnded:{ // 移动停止
            if(_delegate && [_delegate respondsToSelector:@selector(playerDraggedEnd)]){
                [_delegate playerDraggedEnd];
            }
            // 移动结束也需要判断垂直或者平移
            // 比如水平移动结束时，要快进到指定位置，如果这里没有判断，当我们调节音量完之后，会出现屏幕跳动的bug
            switch (panDirection) {
                case PanDirectionHorizontalMoved:{
                    _isPauseByUser = NO;
                    [self seekToTime:sumTime completionHandler:nil];
                    // 把sumTime滞空，不然会越加越多
                    sumTime = 0;
                    break;
                }
                case PanDirectionVerticalMoved:{
                    // 垂直移动结束后，把状态改为不再控制音量
                    isVolume = NO;
                    break;
                }
                default:
                    break;
            }
            break;
        }
        default:{
            if(_delegate && [_delegate respondsToSelector:@selector(playerDraggedEnd)]){
                [_delegate playerDraggedEnd];
            }
        }
            break;
    }
}

/**
 pan垂直移动    isVolume如果为NO是调用亮度 YES是音量
 */
- (void)verticalMoved:(CGFloat)value{
    isVolume ? (volumeViewSlider.value -= value / 10000) : ([UIScreen mainScreen].brightness -= value / 10000);
}

/**
 pan水平移动 告诉slider滑动快进快退
 */
- (void)horizontalMoved:(CGFloat)value{
    // 每次滑动需要叠加时间
    sumTime += value / 200;
    // 需要限定sumTime的范围
    CMTime totalTime = self.playerItem.duration;
    CGFloat totalMovieDuration = (CGFloat)totalTime.value/totalTime.timescale;
    if (sumTime > totalMovieDuration) {
        sumTime = totalMovieDuration;
    }
    if (sumTime < 0) {
        sumTime= 0;
    }
    
    BOOL style = false;
    if (value > 0) {
        style = YES;
    }
    if (value < 0) {
        style = NO;
    }
    if (value == 0) {
        return;
    }
    if (_delegate && [_delegate respondsToSelector:@selector(playerDraggedTime:totalTime:isForward:)]) {
        [_delegate playerDraggedTime:sumTime totalTime:totalMovieDuration isForward:style];
    }
}

#pragma -mark 通知
/**
 耳机插入、拔出事件
 */
- (void)audioRouteChangeListenerCallback:(NSNotification*)notification{
    NSDictionary *interuptionDict = notification.userInfo;
    NSInteger routeChangeReason = [[interuptionDict valueForKey:AVAudioSessionRouteChangeReasonKey] integerValue];
    switch (routeChangeReason) {
        case AVAudioSessionRouteChangeReasonNewDeviceAvailable:// 耳机插入
            break;
        case AVAudioSessionRouteChangeReasonOldDeviceUnavailable:{//拔掉耳机继续播放
            [self play];
        }
            break;
        case AVAudioSessionRouteChangeReasonCategoryChange:
            // called at start - also when other audio wants to play
            NSLog(@"AVAudioSessionRouteChangeReasonCategoryChange");
            break;
    }
}

/**
 播放完了
 */
- (void)moviePlayDidEnd:(NSNotification *)notification{
    self.state = NYPlayerStateStopped;
    playDidEnd = YES;
}

/**
 *  应用退到后台
 */
- (void)appDidEnterBackground{
    // 退到后台锁定屏幕方向
    if(_player){
        if(self.state==NYPlayerStateStopped ||self.state== NYPlayerStateFailed){
            return;
        }
        [_player pause];
        self.state = NYPlayerStatePause;
    }
}

/**
 *  应用进入前台
 */
- (void)appDidEnterPlayground{
    if(_player){
        if(self.state==NYPlayerStateStopped ||self.state== NYPlayerStateFailed){
            return;
        }
        if (!_isPauseByUser) {
            self.state = NYPlayerStatePlaying;
            _isPauseByUser = NO;
            [self play];
        }
    }
}

- (void)dealloc{
    UIInterfaceOrientation currentOrientation = [UIApplication sharedApplication].statusBarOrientation;
    if (currentOrientation != UIInterfaceOrientationPortrait) {
        [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationPortrait animated:NO];
    }
    [self resetPlayer];
}

@end
