//
//  NYPhotoShowVC.m
//  DDNM-NY
//
//  Created by 叶星龙 on 2016/12/29.
//  Copyright © 2016年 北京叮咚柠檬科技有限公司. All rights reserved.
//

#import "NYPhotoShowVC.h"
#import "NYImageManager.h"
#import "NYPhotoReviewThumbnailCell.h"
#import "NYPhotoPreviewView.h"
#import "NYVideoPlayerVC.h"
#import "NYPhotoGroupListView.h"

@interface NYPhotoShowVC ()<UICollectionViewDelegate,UICollectionViewDataSource>{
    NYPhotoGroupListView *groupListView;
}

@end

@implementation NYPhotoShowVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _dataArray =[NSMutableArray array];
    _albumArray =[NSMutableArray array];
    _selectArray =[NSMutableArray array];
    
    CGFloat columnNumber =4;
    [NYImageManager manager].columnNumber=columnNumber;
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    CGFloat margin = 5;
    CGFloat itemWH = (kWindowWidth - (columnNumber + 1) * margin) / columnNumber;
    layout.itemSize = CGSizeMake(itemWH, itemWH);
    layout.minimumInteritemSpacing = margin;
    layout.minimumLineSpacing = margin;
    _photoCollectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    _photoCollectionView.backgroundColor = [UIColor whiteColor];
    _photoCollectionView.dataSource = self;
    _photoCollectionView.delegate = self;
    _photoCollectionView.alwaysBounceHorizontal = NO;
    _photoCollectionView.contentInset = UIEdgeInsetsMake(margin, margin, margin, margin);
    [self.view addSubview:_photoCollectionView];
    [_photoCollectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsMake(0, 0, 0, 0));
    }];
    [_photoCollectionView registerClass:[NYPhotoReviewThumbnailCell class] forCellWithReuseIdentifier:@"NYPhotoShowVC-NYPhotoReviewThumbnailCell"];
    
    [[NYImageManager manager] getAllAlbums:_allowPickingVideo allowPickingImage:_allowPickingPhoto completion:^(NSArray<NYAlbumModel *> *models) {
        [_albumArray addObjectsFromArray:models];
        if (_albumArray.count>0) {
            _albumModel =[_albumArray firstObject];
            self.titleHeader.title = _albumModel.name;
            [[NYImageManager manager] getAssetsFromFetchResult:_albumModel.result allowPickingVideo:_allowPickingVideo allowPickingImage:_allowPickingPhoto completion:^(NSArray<NYAssetModel *> *models) {
                _albumModel.models=models;
                [_dataArray addObjectsFromArray:models];
                [_photoCollectionView reloadData];
            }];
        }else{
            NSLog(@"没有相册");
        }
    }];
}

-(NYPhotoShowHeader *)titleHeader{
    if(_titleHeader){
        return _titleHeader;
    }
    float width = kWindowWidth / 2;
    _titleHeader = [[NYPhotoShowHeader alloc]initWithFrame:CGRectMake(0, 0, width, 44.)];
    self.navigationItem.titleView = _titleHeader;
    [_titleHeader addTarget:self action:@selector(headerValueChange:) forControlEvents:UIControlEventValueChanged];
    return _titleHeader;
}

- (void)setTitle:(NSString *)title{
    [super setTitle:title];
    _titleHeader.title = title;
}


-(void)headerValueChange:(NYPhotoShowHeader *)header{
    [NYPhotoGroupListView showToView:self.view.window title:_albumModel allGroup:_albumArray block:^(NYAlbumModel * group){
         if (group) {
             _albumModel=group;
             self.title=_albumModel.name;
             if (group.models.count!=0) {
                 [_dataArray removeAllObjects];
                 [_dataArray addObjectsFromArray:group.models];
                 [_photoCollectionView reloadData];
                 [_photoCollectionView setContentOffset:CGPointZero];
             }else{
                 [[NYImageManager manager] getAssetsFromFetchResult:_albumModel.result allowPickingVideo:_allowPickingVideo allowPickingImage:_allowPickingPhoto completion:^(NSArray<NYAssetModel *> *models) {
                     group.models=models;
                     [_dataArray removeAllObjects];
                     [_dataArray addObjectsFromArray:models];
                     [_photoCollectionView reloadData];
                     [_photoCollectionView setContentOffset:CGPointZero];
                 }];
             }
         }
         [header setOn:NO animated:YES];
     }];
}



-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return _dataArray.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    NYPhotoReviewThumbnailCell *cell =[collectionView dequeueReusableCellWithReuseIdentifier:@"NYPhotoShowVC-NYPhotoReviewThumbnailCell" forIndexPath:indexPath];
    cell.isShowGIFIcon=_isShowGIFIcon;
    cell.model =_dataArray[indexPath.row];
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    NYAssetModel *model =_dataArray[indexPath.row];
    if (model.type ==NYAssetModelMediaTypeVideo) {
        NYVideoPlayerVC *vc =[NYVideoPlayerVC new];
        vc.assetModel=model;
        [self.navigationController pushViewController:vc animated:YES];
    }else{
        NYPhotoPreviewView *vc =[NYPhotoPreviewView new];
        vc.albumAssetArray=_dataArray;
        vc.assetModel=model;
        [self.navigationController pushViewController:vc animated:YES];
    }
}

@end
