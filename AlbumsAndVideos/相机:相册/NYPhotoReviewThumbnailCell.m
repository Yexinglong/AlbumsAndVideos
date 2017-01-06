//
//  NYPhotoReviewThumbnailCell.m
//  DDNM-NY
//
//  Created by 叶星龙 on 2016/12/29.
//  Copyright © 2016年 北京叮咚柠檬科技有限公司. All rights reserved.
//

#import "NYPhotoReviewThumbnailCell.h"
#import "NYImageManager.h"

@interface NYPhotoReviewThumbnailCell (){
    UIImageView *previewThumbnailImage;
    UIView *bottomView;
    UILabel *gifLabel;
    UILabel *videoLabel;
}

@end
@implementation NYPhotoReviewThumbnailCell

-(instancetype)initWithFrame:(CGRect)frame{
    self =[super initWithFrame:frame];
    if (self) {
        previewThumbnailImage =[UIImageView new];
        previewThumbnailImage.contentMode = UIViewContentModeScaleAspectFill;
        previewThumbnailImage.clipsToBounds = YES;
        [self.contentView addSubview:previewThumbnailImage];
        [previewThumbnailImage mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(UIEdgeInsetsMake(0, 0, 0, 0));
            
        }];
        
        bottomView =[UIView new];
        [self.contentView addSubview:bottomView];
        [bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.bottom.equalTo(@0);
            make.height.equalTo(@20);
        }];
        
        gifLabel =[UILabel new];
        gifLabel.kFont(boldFont(12));
        gifLabel.kText(@"GIF");
        gifLabel.kTextColor([UIColor whiteColor]);
        gifLabel.hidden=YES;
        [gifLabel sizeToFit];
        [bottomView addSubview:gifLabel];
        [gifLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(bottomView);
            make.right.equalTo(@(-5));
            make.size.mas_equalTo(gifLabel.frame.size);
        }];
        
        videoLabel =[UILabel new];
        videoLabel.kFont(boldFont(12));
        videoLabel.kTextColor([UIColor whiteColor]);
        videoLabel.hidden=YES;
        [bottomView addSubview:videoLabel];
        [videoLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(bottomView);
            make.right.equalTo(@(-5));
            make.width.greaterThanOrEqualTo(@0);
            make.height.equalTo(@13);
        }];
        
        
    }
    return self;
}

-(void)setModel:(NYAssetModel *)model{
    _model=model;
    if (model.type == NYAssetModelMediaTypePhotoGif) {
        if (_isShowGIFIcon) {
            bottomView.hidden=YES;
            gifLabel.hidden=YES;
            videoLabel.hidden=YES;
        }else{
            bottomView.hidden=NO;
            gifLabel.hidden=NO;
            videoLabel.hidden=YES;
        }
    }else if (model.type == NYAssetModelMediaTypeVideo){
        bottomView.hidden=NO;
        gifLabel.hidden=YES;
        videoLabel.hidden=NO;
        videoLabel.kText(model.timeLength);
    }else{
        bottomView.hidden=YES;
        gifLabel.hidden=YES;
        videoLabel.hidden=YES;
    }
    CGFloat scale = [UIScreen mainScreen].scale;
    [[NYImageManager manager] getPhotoWithAsset:model.asset photoWidth:self.frame.size.width*scale completion:^(UIImage *photo, NSDictionary *info, BOOL isDegraded) {
        previewThumbnailImage.image = photo;
    } progressHandler:nil networkAccessAllowed:NO];
    
}

@end
