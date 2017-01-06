//
//  NYBaseTableViewCell.m
//  DDNM-NY
//
//  Created by 叶星龙 on 2016/11/27.
//  Copyright © 2016年 北京叮咚柠檬科技有限公司. All rights reserved.
//

#import "NYBaseTableViewCell.h"

@implementation NYBaseTableViewCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self =[super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self initSubviews];
    }
    return self;
}

-(void)initSubviews{
    
}

+ (instancetype)cellWithTableView:(UITableView *)tableView identifier:(NSString*)identifier{
    id cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[[self class] alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        //取消选中状态
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    }
    return cell;
}
- (UITableView *)tableView{
    UIView *tableView = self.superview;
    while (![tableView isKindOfClass:[UITableView class]] && tableView) {
        tableView = tableView.superview;
    }
    return (UITableView *)tableView;
}

@end
