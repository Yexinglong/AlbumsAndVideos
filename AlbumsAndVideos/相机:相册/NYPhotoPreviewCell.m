//
//  NYPhotoPreviewCell.m
//  DDNM-NY
//
//  Created by 叶星龙 on 2016/12/29.
//  Copyright © 2016年 北京叮咚柠檬科技有限公司. All rights reserved.
//

#import "NYPhotoPreviewCell.h"
#import "NYImageManager.h"
#import "YLGIFImage.h"
#import "YLImageView.h"
@interface NYPhotoPreviewCell (){
    UIImageView *previewImage;
}

@end

@implementation NYPhotoPreviewCell

-(instancetype)initWithFrame:(CGRect)frame{
    self =[super initWithFrame:frame];
    if (self) {
        previewImage =[YLImageView new];
        previewImage.contentMode = UIViewContentModeScaleAspectFill;
        previewImage.clipsToBounds = YES;
        
        _photoScrollView =[NYPhotoScrollView new];
        _photoScrollView.isViewTop=YES;
        [self addSubview:_photoScrollView];
        [_photoScrollView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(@10);
            make.right.equalTo(@(-10));
            make.height.equalTo(@(kWindowHeight));
            make.centerY.equalTo(self.contentView);
        }];
    }
    return self;
}

-(void)setModel:(NYAssetModel *)model{
    if([model isEqual:_model]){
        return;
    }
    _model=model;
    previewImage.image=nil;
    [[NYImageManager manager] getOriginalPhotoDataWithAsset:model.asset completion:^(NSData *data, NSDictionary *info, BOOL isDegraded) {
        previewImage.image = [YLGIFImage imageWithData:data];
        CGFloat imageScale = kWindowWidth / previewImage.image.size.width;
        previewImage.frame=(CGRectMake(0, 0, kWindowWidth, imageScale *previewImage.image.size.height));
        [_photoScrollView displayView:previewImage];
    }];
}

@end
