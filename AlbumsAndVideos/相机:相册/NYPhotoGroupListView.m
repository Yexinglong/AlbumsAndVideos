//
//  NYPhotoGroupListView.m
//  DDNM-NY
//
//  Created by 叶星龙 on 2017/1/6.
//  Copyright © 2017年 北京叮咚柠檬科技有限公司. All rights reserved.
//

#import "NYPhotoGroupListView.h"
#import "NYAssetModel.h"
#import "NYPhotoGroupListViewCell.h"
@interface NYPhotoGroupListView ()<UITableViewDataSource,UITableViewDelegate>
{
    UITableView * tableGroupList;
    UIImageView *imageTableView;
}

@property (nonatomic ,weak) NYAlbumModel *group;
@property (nonatomic ,weak) NSMutableArray *allGroup;

@end

@implementation NYPhotoGroupListView

+ (instancetype)showToView:(UIView *)view title:(NYAlbumModel *)group allGroup:(NSMutableArray *)allGroup block:(NYPhotoGroupListSelectBlock)block{

    NYPhotoGroupListView *listView =[[NYPhotoGroupListView alloc]initWithFrame:view.bounds];
    [view addSubview:listView];
    listView.allGroup=allGroup;
    listView.group=group;
    listView.block=block;
    [listView show];
    return listView;
}

-(void)setDefaultPhotoGroupListView{
    self.backgroundColor=[UIColor clearColor];
    UIView *gesView = [[UIView alloc]initWithFrame:self.bounds];
    [self addSubview:gesView];
    [gesView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsZero);
    }];
    
    UITapGestureRecognizer *tap =[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(dismiss)];
    [gesView addGestureRecognizer:tap];
    
    
    imageTableView=[[UIImageView alloc]initWithImage:[[UIImage imageNamed:@"Gallery"] stretchableImageWithLeftCapWidth:10 topCapHeight:10]];
    imageTableView.userInteractionEnabled=YES;
    imageTableView.layer.masksToBounds=YES;
    imageTableView.frame=(CGRect){0,54,kWindowWidth,0};
    [self addSubview:imageTableView];
    
    tableGroupList =[[UITableView alloc]initWithFrame:CGRectZero style:UITableViewStylePlain];
    tableGroupList.backgroundColor =[UIColor whiteColor];
    tableGroupList.delegate=self;
    tableGroupList.dataSource=self;
    tableGroupList.layer.masksToBounds=YES;
    tableGroupList.layer.cornerRadius=10;
    [imageTableView addSubview:tableGroupList];
    [tableGroupList setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    tableGroupList.tableFooterView=[[UIView alloc]init];
    
}

-(id)initWithFrame:(CGRect)frame{
    self =[super initWithFrame:frame];
    if (self) {
        [self setDefaultPhotoGroupListView];
    }
    return self;
}


-(void)setAllGroup:(NSMutableArray *)allGroup{
    _allGroup=allGroup;
    CGFloat height=0.;

    if (allGroup.count *(80+11) > kWindowHeight/2) {
        height=kWindowHeight*0.8;
    }else{
        height=kWindowHeight/2;
    }
    
    [tableGroupList mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(5);
        make.left.mas_equalTo(0);
        make.right.mas_equalTo(0);
        make.height.mas_equalTo(height-10);
    }];
}

-(void)show{
    CGFloat height=0.;
    if (_allGroup.count *(80+11) > kWindowHeight/2) {
        height=kWindowHeight*0.8;
    }else{
        height=kWindowHeight/2;
    }
    [tableGroupList reloadData];
    [UIView animateWithDuration:0.25 animations:^(){
        imageTableView.frame=(CGRect){0,54,kWindowWidth,height};
        self.backgroundColor = [UIColor colorWithRed:0. green:0. blue:0. alpha:0.3];
    }];
}

- (void)dismiss{
    if (self.block) {
        self.block (nil);
    }
    [self _dismiss];
}

- (void)_dismiss{
    [UIView animateWithDuration:0.25 animations:^(){
        imageTableView.frame=(CGRect){0,54,kWindowWidth,0};
        self.backgroundColor = [UIColor clearColor];
    }completion:^(BOOL finish){
        [self removeFromSuperview];
        self.block = nil;
    }];
}

#pragma -mark
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _allGroup.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NYPhotoGroupListViewCell * cell = [NYPhotoGroupListViewCell cellWithTableView:tableView identifier:@"YXLPhotoGroupListView-YXLPhotoGroupListViewCell"];
    NYAlbumModel *group =_allGroup[indexPath.row];
    cell.asset=group;
    if([self.group isEqual:group]){
        cell.imageCheck.hidden=NO;
    }else{
        cell.imageCheck.hidden=YES;
    }
    return cell;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80+11;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NYAlbumModel *group =_allGroup[indexPath.row];
    if (self.block) {
        self.block (group);
    }
    [self dismiss];
}


@end
