//
//  NYVideoPalayerControlLayer.h
//  DDNM-NY
//
//  Created by 叶星龙 on 2017/1/10.
//  Copyright © 2017年 北京叮咚柠檬科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NYPlayerView.h"

@interface NYVideoPalayerControlLayer : UIView

@property (nonatomic ,weak) NYPlayerView *playerView;

@property (nonatomic ,assign) BOOL hasPreviewView;

@end
