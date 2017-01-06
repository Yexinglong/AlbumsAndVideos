//
//  NYBaseTableViewCell.h
//  DDNM-NY
//
//  Created by 叶星龙 on 2016/11/27.
//  Copyright © 2016年 北京叮咚柠檬科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

//用户一个Cell多个地方重用时，通过枚举来分辩一些identifier控制重用样式中的不需要的控件！
typedef NS_ENUM(NSInteger, NYCellType){
    NYNome,//默认===无用
    NYCommunityVideo,
    NYCommunityPhotoText,
    NYCommunityText,
    NYCommunityUserVideo,
    NYCommunityUserPhotoText,
    NYCommunityUserText
};

@interface NYBaseTableViewCell : UITableViewCell

-(void)initSubviews;

+ (instancetype)cellWithTableView:(UITableView *)tableView identifier:(NSString*)identifier;

@property (nonatomic ,weak) UIViewController *viewController;

-(UITableView *)tableView;

@end


