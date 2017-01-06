//
//  NYPhotoScrollView.m
//  DDNM-NY
//
//  Created by 叶星龙 on 2016/12/29.
//  Copyright © 2016年 北京叮咚柠檬科技有限公司. All rights reserved.
//

#import "NYPhotoScrollView.h"

@interface NYPhotoScrollView ()<UIScrollViewDelegate>{
    UIView *zoomView;
    CGSize zoomViewSize;
    UIView *tempView;
}

@end

@implementation NYPhotoScrollView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        zoomView =[UIView new];
        zoomView.userInteractionEnabled=YES;
        zoomView.backgroundColor=[UIColor clearColor];
        
        self.delaysContentTouches=NO;
        self.showsVerticalScrollIndicator = NO;
        self.showsHorizontalScrollIndicator = NO;
        self.bouncesZoom = YES;
        self.scrollsToTop = NO;
        self.decelerationRate = UIScrollViewDecelerationRateFast;
        self.delegate = self;
    }
    return self;
}

#pragma mark - UIScrollViewDelegate
- (nullable UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return zoomView;
}

- (void)scrollViewDidZoom:(__unused UIScrollView *)scrollView{
    [self centerZoomView];
}

- (void)centerZoomView{
    CGRect frameToCenter = [zoomView frame];
    if (CGRectGetWidth(frameToCenter) < CGRectGetWidth(self.bounds)) {
        frameToCenter.origin.x = (CGRectGetWidth(self.bounds) - CGRectGetWidth(frameToCenter)) * 0.5f;
    } else {
        frameToCenter.origin.x = 0;
    }
    if (CGRectGetHeight(frameToCenter) < CGRectGetHeight(self.bounds)) {
        frameToCenter.origin.y = (CGRectGetHeight(self.bounds) - CGRectGetHeight(frameToCenter)) * 0.5f;
    } else {
        frameToCenter.origin.y = 0;
    }
    zoomView.frame = frameToCenter;
}


-(void)restoreZoom{
    self.zoomScale = 1.0;
    [tempView setTransform:CGAffineTransformIdentity];
    [zoomView setTransform:CGAffineTransformIdentity];
    [self setContentOffset:CGPointZero];
}

- (void)displayView:(id)view{
    tempView=view;
    [self restoreZoom];
    [zoomView addSubview: tempView];
    zoomView.frame=tempView.frame;
    [self addSubview:zoomView];
    [self configureForSize: CGSizeMake(zoomView.frame.size.width+10, zoomView.frame.size.height+10)];
}

- (void)configureForSize:(CGSize)size{
    zoomViewSize = size;
    self.contentSize = size;
    [self setMaxMinZoomScalesForCurrentBounds];
    self.contentInset = UIEdgeInsetsZero;
}

- (void)setMaxMinZoomScalesForCurrentBounds{
    CGSize boundsSize = self.bounds.size;
    CGFloat xScale = boundsSize.width  / zoomViewSize.width;
    CGFloat yScale = boundsSize.height / zoomViewSize.height;
    if(_isViewTop){
        if (zoomViewSize.height > boundsSize.height) {
            yScale=xScale;
        }
    }
    CGFloat minScale;
    minScale = MIN(xScale, yScale);
    CGFloat maxScale = MAX(xScale, yScale);
    CGFloat xImageScale = maxScale*zoomViewSize.width / boundsSize.width;
    CGFloat yImageScale = maxScale*zoomViewSize.height / boundsSize.width;
    CGFloat maxImageScale = MAX(xImageScale, yImageScale);
    maxImageScale = MAX(minScale, maxImageScale);
    maxScale = MAX(maxScale, maxImageScale);
    if (minScale > maxScale) {
        minScale = maxScale;
    }
    self.maximumZoomScale = maxScale;
    self.minimumZoomScale = minScale;
    self.zoomScale = self.minimumZoomScale;
    
   
}
@end
