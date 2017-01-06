//
//  NYPlayerModel.h
//  testVideo
//
//  Created by 叶星龙 on 2017/1/3.
//  Copyright © 2017年 北京叮咚柠檬科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface NYPlayerModel : NSObject

/** 视频URL */
@property (nonatomic, strong) NSURL *videoURL;
/** 视频封面本地图片 */
@property (nonatomic, strong) UIImage *placeholderImage;
/**
 * 视频封面网络图片url
 * 如果和本地图片同时设置，则忽略本地图片，显示网络图片
 */
@property (nonatomic, copy  ) NSString *placeholderImageURLString;
/** 从xx秒开始播放视频(默认0) */
@property (nonatomic, copy) NSNumber *seekTime;
@end
