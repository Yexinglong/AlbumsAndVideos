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
/**
 视频地址
 */
@property (nonatomic, strong) NSURL *videoURL;
/**
 视频封面
 */
@property (nonatomic, copy  ) NSString *imageURL;
/**
 从xx秒开始播放视频(默认0)
 */
@property (nonatomic, copy) NSNumber *seekTime;
@end
