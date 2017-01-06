//
//  NYPhotoShowHeader.m
//  DDNM-NY
//
//  Created by 叶星龙 on 2016/12/30.
//  Copyright © 2016年 北京叮咚柠檬科技有限公司. All rights reserved.
//

#import "NYPhotoShowHeader.h"

@interface NYPhotoShowHeader ()
{
    UILabel *titleLabel;
    UIImageView *imageArrowView;
}
@end

@implementation NYPhotoShowHeader

-(void)initUI{
    titleLabel =[UILabel new];
    titleLabel.font=Font(15);
    titleLabel.textColor=[UIColor blackColor];
    titleLabel.textAlignment=NSTextAlignmentCenter;
    [self addSubview:titleLabel];
    ESWeakSelf
    [titleLabel mas_makeConstraints:^(MASConstraintMaker * make){
        make.center.equalTo(__weakSelf);
        make.size.mas_equalTo(titleLabel.frame.size);
    }];
    
    imageArrowView =[UIImageView new];
    imageArrowView.kImage(@"drop");
    [self addSubview:imageArrowView];
    [imageArrowView sizeToFit];
    [imageArrowView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(__weakSelf);
        make.size.mas_equalTo(imageArrowView.frame.size);
        make.left.equalTo(titleLabel.mas_right).mas_equalTo(5);
    }];
    
    [self addTarget:self action:@selector(touchUpAction) forControlEvents:UIControlEventTouchUpInside];
}


- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self initUI];
    }
    return self;
}

- (void)setOn:(BOOL)on{
    [self setOn:on animated:NO];
}

- (void)setOn:(BOOL)on animated:(BOOL)animated{
    if (_on == on) {
        return;
    }
    _on = on;
    if (animated) {
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.25];
    }
    if (_on) {
        imageArrowView.transform = CGAffineTransformRotate(CGAffineTransformIdentity, M_PI_2 * 2);
    }else{
        imageArrowView.transform = CGAffineTransformIdentity;
    }
    if (animated) {
        [UIView commitAnimations];
    }
}

- (void)touchUpAction{
    [self setOn:!_on animated:YES];
    [self sendActionsForControlEvents:UIControlEventValueChanged];
}

- (void)setTitle:(NSString *)title{
    if ([_title isEqualToString:title]) {
        return;
    }
    _title = title;
    titleLabel.text = _title;
    [titleLabel sizeToFit];
    CGSize size = titleLabel.frame.size;
    [titleLabel mas_updateConstraints:^(MASConstraintMaker * make){
        make.size.mas_equalTo(size);
    }];
}

@end
