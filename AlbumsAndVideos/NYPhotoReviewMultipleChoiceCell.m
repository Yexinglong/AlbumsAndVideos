//
//  NYPhotoReviewMultipleChoiceCell.m
//  DDNM-NY
//
//  Created by 叶星龙 on 2017/1/6.
//  Copyright © 2017年 北京叮咚柠檬科技有限公司. All rights reserved.
//

#import "NYPhotoReviewMultipleChoiceCell.h"

@interface NYPhotoReviewMultipleChoiceCell (){
    UIView *viewSelected;
    UIImageView *imageSelected;
}

@end

@implementation NYPhotoReviewMultipleChoiceCell

-(instancetype)initWithFrame:(CGRect)frame{
    self =[super initWithFrame:frame];
    if (self) {
        
        
        imageSelected =[UIImageView new];
        imageSelected.kAddTargetAction(self,@selector(imageSelectedClick),YXLTap);
        imageSelected.contentMode=UIViewContentModeScaleAspectFit;
        [self.contentView addSubview:imageSelected];
        [imageSelected mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(@3);
            make.right.equalTo(@(-3));
            make.size.mas_equalTo(CGSizeMake(25, 25));
        }];
    }
    return self;
}

-(void)imageSelectedClick{
    if (_didSelectPhotoBlock) {
        _didSelectPhotoBlock();
    }
}


- (void)setPhotoSelect:(BOOL)photoSelect{

    _photoSelect = photoSelect;
    if (photoSelect) {
        imageSelected.image=[UIImage imageNamed:@"ChooseSelect"];
    }else{
        imageSelected.image=[UIImage imageNamed:@"home_more"];
    }
}

@end
