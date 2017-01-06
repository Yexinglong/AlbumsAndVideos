//
//  NYPhotoGroupListViewCell.m
//  DDNM-NY
//
//  Created by 叶星龙 on 2017/1/6.
//  Copyright © 2017年 北京叮咚柠檬科技有限公司. All rights reserved.
//

#import "NYPhotoGroupListViewCell.h"
#import "NYAssetModel.h"
#import "NYImageManager.h"
@interface NYPhotoGroupListViewCell ()
{
    UIImageView *imagePhotoView;
    UILabel *labelTitle;
    UILabel *labelDetailText;
    UILabel *labelGroupCount;
}
@end
@implementation NYPhotoGroupListViewCell

-(void)initSubviews{
    self.backgroundColor=[UIColor clearColor];
    
    
    imagePhotoView =[UIImageView new];
    imagePhotoView.layer.masksToBounds=YES;
    imagePhotoView.backgroundColor=UIColorFromRGB_HEX(0xefeff4);
    imagePhotoView.contentMode=UIViewContentModeScaleAspectFill;
    [self.contentView addSubview:imagePhotoView];
    [imagePhotoView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(@11);
        make.left.equalTo(@11);
        make.size.mas_equalTo(CGSizeMake(80, 80));
    }];
    
    labelTitle =[UILabel new];
    labelTitle.kTextColor([UIColor blackColor]);
    labelTitle.kFont(@15);
    [self.contentView addSubview:labelTitle];
    [labelTitle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(imagePhotoView).offset(-(15/2));
        make.left.equalTo(imagePhotoView.mas_right).offset(16);
        make.width.greaterThanOrEqualTo(@20);
        make.height.equalTo(@16);
    }];
    
    labelDetailText =[UILabel new];
    labelDetailText.kFont(@12);
    labelDetailText.kTextColor(UIColorFromRGB_HEX(0x494949));
    [self.contentView addSubview:labelDetailText];
    [labelDetailText mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(labelTitle.mas_bottom).offset(13/2);
        make.left.equalTo(imagePhotoView.mas_right).offset(16);
        make.width.greaterThanOrEqualTo(@20);
        make.height.equalTo(@13);
    }];
    
    labelGroupCount =[UILabel new];
    labelGroupCount.kFont(@12);
    labelGroupCount.kTextColor([UIColor whiteColor]);
    labelGroupCount.kBackgroundColor([UIColor redColor]);
    labelGroupCount.hidden=YES;
    labelGroupCount.textAlignment=NSTextAlignmentCenter;
    labelGroupCount.kLayerCornerRadiusToMasks(20/2,YES);
    [self.contentView addSubview:labelGroupCount];
    [labelGroupCount mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(imagePhotoView);
        make.left.equalTo(labelTitle.mas_right).offset(20);
        make.size.mas_equalTo(CGSizeMake(20, 20));
    }];
    
    _imageCheck =[UIImageView new];
    _imageCheck.kImage(@"Check");
    _imageCheck.contentMode=UIViewContentModeScaleAspectFit;
    [_imageCheck sizeToFit];
    [self.contentView addSubview:_imageCheck];
    [_imageCheck mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(imagePhotoView);
        make.right.equalTo(@(-40));
        make.size.mas_equalTo(CGSizeMake(CGWidth(_imageCheck.frame), CGHeight(_imageCheck.frame)));
    }];
    
}


-(void)setAsset:(NYAlbumModel *)asset{
    _asset=asset;
    labelTitle.text=asset.name;
    labelDetailText.text=[NSString stringWithFormat:@"%ld",asset.count];
    if(asset.selectedModels.count==0){
        labelGroupCount.hidden=YES;
    }else{
        labelGroupCount.hidden=NO;
    }
    labelGroupCount.kText([NSString stringWithFormat:@"%ld",asset.selectedModels.count]);

    
    [[NYImageManager manager] getPostImageWithAlbumModel:asset completion:^(UIImage *postImage) {
        imagePhotoView.image = postImage;
    }];
    
}
@end
