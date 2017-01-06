//
//  NYPhotoShowVC.h
//  DDNM-NY
//
//  Created by 叶星龙 on 2016/12/29.
//  Copyright © 2016年 北京叮咚柠檬科技有限公司. All rights reserved.
//
/*
 框架部分代码借鉴于https://github.com/banchichen/TZImagePickerController
 */

#import "NYBaseVC.h"
#import "NYPhotoShowHeader.h"
#import "NYAssetModel.h"

@interface NYPhotoShowVC : NYBaseVC
///相册是否需要带有视频   默认NO
@property (nonatomic ,assign) BOOL allowPickingVideo;
///相册是否需要带有图片   默认NO
@property (nonatomic ,assign) BOOL allowPickingPhoto;
///是否显示GIF图片标识
@property (nonatomic ,assign) BOOL isShowGIFIcon;

///titleView顶部相册栏
@property (nonatomic ,strong) NYPhotoShowHeader * titleHeader;
///选中相册里面的图片数组
@property (nonatomic ,strong) NSMutableArray *dataArray;
///所有相册数组
@property (nonatomic ,strong) NSMutableArray *albumArray;
///选中数组
@property (nonatomic ,strong) NSMutableArray *selectArray;

@property (nonatomic ,strong) UICollectionView *photoCollectionView;
///当前相册Model
@property (nonatomic ,strong) NYAlbumModel *albumModel;


/**
 对点击Cell需要做什么自己重写，默认是跳到该内容详情
 */
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath;

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath;
@end
