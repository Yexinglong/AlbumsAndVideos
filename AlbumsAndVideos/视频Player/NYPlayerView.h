//
//  NYPlayerView.h
//  testVideo
//
//  Created by 叶星龙 on 2017/1/3.
//  Copyright © 2017年 北京叮咚柠檬科技有限公司. All rights reserved.
//
/*
 此视频框架基于https://github.com/renzifeng/ZFPlayer
 */

#import <UIKit/UIKit.h>
#import "NYPlayerModel.h"
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>

// playerLayer的填充模式（默认：等比例填充，直到一个维度到达区域边界）
typedef NS_ENUM(NSInteger, NYPlayerLayerGravity) {
    NYPlayerLayerGravityResize,           // 非均匀模式。两个维度完全填充至整个视图区域
    NYPlayerLayerGravityResizeAspect,     // 等比例填充，直到一个维度到达区域边界
    NYPlayerLayerGravityResizeAspectFill  // 等比例填充，直到填充满整个视图区域，其中一个维度的部分区域会被裁剪
};

// 播放器的几种状态
typedef NS_ENUM(NSInteger, NYPlayerState) {
    NYPlayerStateFailed,     // 播放失败
    NYPlayerStateBuffering,  // 缓冲中
    NYPlayerStatePlaying,    // 播放中
    NYPlayerStateStopped,    // 停止播放
    NYPlayerStatePause       // 暂停播放
};

@protocol NYPlayerViewDelegate <NSObject>

@optional
/**
 更改播放状态
 */
-(void)playerStateChanged:(NYPlayerState )state error:(NSError *)error;

/**
 缓冲进度
 */
-(void)playerSetProgress:(CGFloat)progress;
/**
 播放时间
 currentTime 当前播放时长
 totalTime 视频总时长
 value slider的value(0.0~1.0)
 */
-(void)playerCurrentTime:(NSInteger)currentTime totalTime:(NSInteger)totalTime sliderValue:(CGFloat)value;
/**
 快进 快退
 draggedTime 拖拽的时长
 totalTime 视频总时长
 forawrd 是否是快进
 */
-(void)playerDraggedTime:(NSInteger)draggedTime totalTime:(NSInteger)totalTime isForward:(BOOL)forawrd;
/**
 滑动结束
 */
- (void)playerDraggedEnd;
/**
 屏幕单击
 isPlayEnd 告知单击时视频状态是否已经播放完毕
 */
-(void)playerScreenClickIsPlayEnd:(BOOL)isPlayEnd;
/**
 全屏回调   NO是原样   YES是全屏
 */
-(void)playerIsFullScreen:(BOOL)isFullScreen;

@end

@interface NYPlayerView : UIView

/**
 设置playerLayer的填充模式
 */
@property (nonatomic, assign) NYPlayerLayerGravity playerLayerGravity;
/**
 播发状态
 */
@property (nonatomic, assign, readonly) NYPlayerState state;
/**
 设置播放内容属性
 */
@property (nonatomic, strong) NYPlayerModel *playerModel;
/**
 播放一些属性的回调代理
 */
@property (nonatomic, weak) id<NYPlayerViewDelegate>delegate;

/** 必传属性 */
/***************/
/**
 由于使用了Masonry约束 请将他们的make返回的NSArray数据传递进来
 */
@property (nonatomic, strong) NSArray *makeArray;

/**
 原父视图，由于全屏是add在最顶层的window层 返回需要原来的父视图来add回来
 */
@property (nonatomic, weak) UIView * fatherView;
/***************/

/** 播放属性 */
@property (nonatomic, strong) AVPlayer *player;
@property (nonatomic, strong) AVURLAsset *urlAsset;
/** playerLayer */
@property (nonatomic, strong) AVPlayerLayer *playerLayer;
@property (nonatomic, strong) AVAssetImageGenerator *imageGenerator;
@property (nonatomic, strong) AVPlayerItem *playerItem;

@property (nonatomic, assign) BOOL isPauseByUser;//是否被用户暂停


/**
 *  自动播放，默认不自动播放
 */
- (void)autoPlayTheVideo;
/**
 *  重置player
 */
- (void)resetPlayer;
/**
 *  播放
 */
- (void)play;
/**
 * 暂停
 */
- (void)pause;
/**
 重播
 */
-(void)replay;
/**
 停止
 */
- (void)stop;
/**
 根据屏幕方向改变显示
 */
-(void)onDeviceOrientationChange;
/**
 跳转时间
 */
- (void)seekToTime:(NSInteger)dragedSeconds completionHandler:(void (^)(BOOL finished))completionHandler;
@end
