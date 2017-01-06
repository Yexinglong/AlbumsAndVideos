//
//  NYPhotoPreviewView.m
//  DDNM-NY
//
//  Created by 叶星龙 on 2016/12/29.
//  Copyright © 2016年 北京叮咚柠檬科技有限公司. All rights reserved.
//

#import "NYPhotoPreviewView.h"
#import "NYPhotoPreviewCell.h"

@interface NYPhotoPreviewView ()<UICollectionViewDelegate,UICollectionViewDataSource>{
    UICollectionView *collPhotoPreviewView;
    UIView *navTool;
    NSInteger _currentIndex;
}

@end

@implementation NYPhotoPreviewView

-(instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    self =[super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.hiddenNavigationBarWhenViewWillAppear=YES;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.backBtn setImage:[UIImage imageNamed:@"fanhuibai"] forState:UIControlStateNormal];

    [self initUI];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    if (_assetModel) {
        _currentIndex =[self.albumAssetArray indexOfObject:_assetModel];
        [collPhotoPreviewView setContentOffset:CGPointMake((self.view.frame.size.width + 20) * _currentIndex, 0) animated:NO];
    }
}

-(void)back:(id)sender{
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)initUI{
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    layout.itemSize = CGSizeMake(self.view.frame.size.width + 20, self.view.frame.size.height);
    layout.minimumInteritemSpacing = 0;
    layout.minimumLineSpacing = 0;
    collPhotoPreviewView = [[UICollectionView alloc] initWithFrame:CGRectMake(-10, 0, self.view.frame.size.width + 20, self.view.frame.size.height) collectionViewLayout:layout];
    collPhotoPreviewView.backgroundColor = [UIColor blackColor];
    collPhotoPreviewView.dataSource = self;
    collPhotoPreviewView.delegate = self;
    collPhotoPreviewView.pagingEnabled = YES;
    collPhotoPreviewView.scrollsToTop = NO;
    collPhotoPreviewView.showsHorizontalScrollIndicator = NO;
    collPhotoPreviewView.contentOffset = CGPointMake(0, 0);
    collPhotoPreviewView.contentSize = CGSizeMake(self.albumAssetArray.count * (self.view.frame.size.width + 20), 0);
    [self.view addSubview:collPhotoPreviewView];
    /*
    [collPhotoPreviewView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@(-10));
        make.right.equalTo(@0);
        make.width.equalTo(@(self.view.frame.size.width+20));
        make.height.equalTo(@(self.view.frame.size.height));
    }];
     */
    [collPhotoPreviewView registerClass:[NYPhotoPreviewCell class] forCellWithReuseIdentifier:@"NYPhotoPreviewView-NYPhotoPreviewCell"];
    
    navTool =[UIView new];
    navTool.backgroundColor=UIColorRGBA(0, 0, 0, 0.3);
    [self.view addSubview:navTool];
    [navTool addSubview:self.backBtn];
    [navTool mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(@0);
        make.height.equalTo(@64);
    }];
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    if ([cell isKindOfClass:[NYPhotoPreviewCell class]]) {
        NYPhotoPreviewCell *photoCell =(NYPhotoPreviewCell *)cell;
        [photoCell.photoScrollView restoreZoom];
    }
}

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    if ([cell isKindOfClass:[NYPhotoPreviewCell class]]) {
        NYPhotoPreviewCell *photoCell =(NYPhotoPreviewCell *)cell;
        [photoCell.photoScrollView restoreZoom];
    }
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.albumAssetArray.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    NYPhotoPreviewCell *cell =[collectionView dequeueReusableCellWithReuseIdentifier:@"NYPhotoPreviewView-NYPhotoPreviewCell" forIndexPath:indexPath];
    cell.model=self.albumAssetArray[indexPath.row];
    return cell;
}
@end
