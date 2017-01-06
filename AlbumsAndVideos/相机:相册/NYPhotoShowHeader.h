//
//  NYPhotoShowHeader.h
//  DDNM-NY
//
//  Created by 叶星龙 on 2016/12/30.
//  Copyright © 2016年 北京叮咚柠檬科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NYPhotoShowHeader : UIControl

@property (nonatomic, strong) NSString * title;

@property (nonatomic, getter=isOn) BOOL on;

- (void)setOn:(BOOL)on animated:(BOOL)animated;


@end
