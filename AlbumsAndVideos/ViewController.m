//
//  ViewController.m
//  AlbumsAndVideos
//
//  Created by 叶星龙 on 2017/1/6.
//  Copyright © 2017年 北京叮咚柠檬科技有限公司. All rights reserved.
//

#import "ViewController.h"
#import "View+MASAdditions.h"
#import "NYBaseTableViewCell.h"
#import "YXLPlayerVC.h"
#import "NYPhotoShowInheritVC.h"
@interface ViewController ()<UITableViewDelegate,UITableViewDataSource>{
    UITableView *testTableView;
    NSMutableArray *dataArray;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    
    self.isNavLeftDismiss=YES;

    
    [super viewDidLoad];
    
    
    dataArray =@[@"视频播放光溜溜的啥都没有",@"只有图片相册",@"视频相册点击后播放视频、带有UI控制层",@"视频层次在别的控件下面，全屏返回后不改变层次"].mutableCopy;
    
    
    
    testTableView =[UITableView new];
    testTableView.delegate=self;
    testTableView.dataSource=self;
    testTableView.rowHeight=100;
    [self.view addSubview:testTableView];
    [testTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsZero);
    }];
    
    
    // Do any additional setup after loading the view, typically from a nib.
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return dataArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NYBaseTableViewCell *cell =[NYBaseTableViewCell cellWithTableView:tableView identifier:@"NYBaseTableViewCell"];
    cell.textLabel.text=dataArray[indexPath.row];
    cell.textLabel.font=Font(13);
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    switch (indexPath.row) {
        case 0:
        {
            YXLPlayerVC *vc =[YXLPlayerVC new];
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
        case 1:
        {
            NYPhotoShowInheritVC *vc=[NYPhotoShowInheritVC new];
            vc.allowPickingPhoto=YES;
            vc.isMultipleChoice=YES;
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
        case 2:
        {
            NYPhotoShowInheritVC *vc=[NYPhotoShowInheritVC new];
            vc.allowPickingVideo=YES;
            vc.isMultipleChoice=YES;

            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
        case 3:
        {
            YXLPlayerVC *vc =[YXLPlayerVC new];
            vc.is=YES;
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
        default:
            break;
    }
}

@end
