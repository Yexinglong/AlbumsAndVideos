//
//  NYPhotoShowInheritVC.m
//  DDNM-NY
//
//  Created by 叶星龙 on 2016/12/30.
//  Copyright © 2016年 北京叮咚柠檬科技有限公司. All rights reserved.
//

#import "NYPhotoShowInheritVC.h"
#import "NYPhotoReviewThumbnailCell.h"
#import "NYPhotoReviewMultipleChoiceCell.h"
@interface NYPhotoShowInheritVC (){
    UIButton *rightBtn;
}

@end

@implementation NYPhotoShowInheritVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (_isMultipleChoice) {
        rightBtn =[UIButton new];
        rightBtn.kNormalText(@"下一步");
        rightBtn.kFont(@15);
        rightBtn.kTextColor(UIColorFromRGB_HEX(0x969696));
        rightBtn.kAddTouchUpInside(self,@selector(rightBtnClick));
        [rightBtn sizeToFit];
        self.navigationItem.rightBarButtonItem=[[UIBarButtonItem alloc]initWithCustomView:rightBtn];
    }
    
    if (self.allowPickingVideo) {
        self.titleHeader.hidden=YES;
        self.navigationItem.titleView=nil;
        self.title=@"视频";
    }
    
    [self.photoCollectionView registerClass:[NYPhotoReviewMultipleChoiceCell class] forCellWithReuseIdentifier:@"NYPhotoShowInheritVC-NYPhotoReviewMultipleChoiceCell"];
    
    
}



-(void)rightBtnClick{
    if (self.selectArray.count>0) {
        
    }else{
        if(self.allowPickingVideo){
            [SVProgressHUD showInfoWithStatus:@"请选择视频"];
        }else{
            [SVProgressHUD showInfoWithStatus:@"请选择图片"];
        }
    }
}

-(__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    if (_isMultipleChoice) {
        NYPhotoReviewMultipleChoiceCell *cell =[collectionView dequeueReusableCellWithReuseIdentifier:@"NYPhotoShowInheritVC-NYPhotoReviewMultipleChoiceCell" forIndexPath:indexPath];
        cell.isShowGIFIcon=self.isShowGIFIcon;
        cell.model =self.dataArray[indexPath.row];
        if ([self.selectArray containsObject:self.dataArray[indexPath.row]]) {
            cell.photoSelect=YES;
        }else{
            cell.photoSelect=NO;
        }
        ESWeak_(cell);
        ESWeakSelf;
        cell.didSelectPhotoBlock=^{
            if (_isMultipleChoice) {
                if (self.allowPickingVideo) {
                    if ([__weakSelf.selectArray containsObject:weak_cell.model]) {
                        [__weakSelf.selectArray removeObject:weak_cell.model];
                        [__weakSelf.albumModel.selectedModels removeObject:weak_cell.model];
                        weak_cell.photoSelect=NO;
                    }else{
                        if(__weakSelf.selectArray.count<1){
                            weak_cell.photoSelect=YES;
                            [__weakSelf.selectArray addObject:weak_cell.model];
                            [__weakSelf.albumModel.selectedModels addObject:weak_cell.model];

                        }else{
                            [SVProgressHUD showInfoWithStatus:@"视频只能选择1个"];
                        }
                    }
                }else{
                    if ([__weakSelf.selectArray containsObject:weak_cell.model]) {
                        [__weakSelf.selectArray removeObject:weak_cell.model];
                        [__weakSelf.albumModel.selectedModels removeObject:weak_cell.model];
                        weak_cell.photoSelect=NO;
                    }else{
                        if(__weakSelf.selectArray.count<9){
                            weak_cell.photoSelect=YES;
                            [__weakSelf.selectArray addObject:weak_cell.model];
                            [__weakSelf.albumModel.selectedModels addObject:weak_cell.model];
                        }else{
                            [SVProgressHUD showInfoWithStatus:@"最多只能9张图"];
                        }
                    }
                }
                if (__weakSelf.selectArray.count!=0) {
                    rightBtn.kTextColor([UIColor blackColor]);
                }else{
                    rightBtn.kTextColor(UIColorFromRGB_HEX(0x969696));
                }
            }

        };
        return cell;
    }else{
        return [super collectionView:collectionView cellForItemAtIndexPath:indexPath];
    }
}



@end
