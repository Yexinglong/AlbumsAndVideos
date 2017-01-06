//
//  NYBrightnessView.m
//  testVideo
//
//  Created by 叶星龙 on 2017/1/5.
//  Copyright © 2017年 北京叮咚柠檬科技有限公司. All rights reserved.
//

#import "NYBrightnessView.h"
#import "UIView+NYTransform.h"
@interface NYBrightnessView ()
@property (nonatomic, strong) UIImageView		*backImage;
@property (nonatomic, strong) UILabel			*title;
@property (nonatomic, strong) UIView			*longView;
@property (nonatomic, strong) NSMutableArray	*tipArray;
@end

@implementation NYBrightnessView

- (instancetype)init {
    if (self = [super init]) {
        self.frame = CGRectMake(0,0, 155, 155);
        self.layer.cornerRadius = 10;
        self.layer.masksToBounds = YES;
        
        UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:self.bounds];
        toolbar.alpha = 0.97;
        [self addSubview:toolbar];
        
        self.backImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 79, 76)];
        self.backImage.image = [UIImage imageNamed:@"player_brightness"];
        [self addSubview:self.backImage];
        self.backImage.center = CGPointMake(155 * 0.5, 155 * 0.5);
        
        self.title = [[UILabel alloc] initWithFrame:CGRectMake(0, 5, self.bounds.size.width, 30)];
        self.title.font = [UIFont boldSystemFontOfSize:16];
        self.title.textColor = [UIColor colorWithRed:0.25f green:0.22f blue:0.21f alpha:1.00f];
        self.title.textAlignment = NSTextAlignmentCenter;
        self.title.text = @"亮度";
        [self addSubview:self.title];
        
        self.longView = [[UIView alloc]initWithFrame:CGRectMake(13, 132, self.bounds.size.width - 26, 7)];
        self.longView.backgroundColor = [UIColor colorWithRed:0.25f green:0.22f blue:0.21f alpha:1.00f];
        [self addSubview:self.longView];
        
        [self createTips];
        [self addObserver];
        self.alpha = 0.0;
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(onStatusBarOrientationChange)
                                                     name:UIApplicationDidChangeStatusBarOrientationNotification
                                                   object:nil];
        [self onStatusBarOrientationChange];
    }
    return self;
}

-(void)onStatusBarOrientationChange{
    UIInterfaceOrientation currentOrientation = [UIApplication sharedApplication].statusBarOrientation;
    UIView *view =[UIApplication sharedApplication].windows.lastObject;
    if (currentOrientation == UIInterfaceOrientationPortrait) {
        self.center=CGPointMake([view bounds].size.width*0.5, [view bounds].size.height*0.5-5);
    }else{
        self.center=CGPointMake([view bounds].size.width*0.5, [view bounds].size.height*0.5);
    }
    [UIView animateWithDuration:0.3 animations:^{
        self.transform = [UIView getTransformRotationAngle];
    }];
}


- (void)createTips {
    self.tipArray = [NSMutableArray arrayWithCapacity:16];
    CGFloat tipW = (self.longView.bounds.size.width - 17) / 16;
    CGFloat tipH = 5;
    CGFloat tipY = 1;
    for (int i = 0; i < 16; i++) {
        CGFloat tipX          = i * (tipW + 1) + 1;
        UIImageView *image    = [[UIImageView alloc] init];
        image.backgroundColor = [UIColor whiteColor];
        image.frame           = CGRectMake(tipX, tipY, tipW, tipH);
        [self.longView addSubview:image];
        [self.tipArray addObject:image];
    }
    [self updateLongView:[UIScreen mainScreen].brightness];
}

- (void)addObserver {
    [[UIScreen mainScreen] addObserver:self
                            forKeyPath:@"brightness"
                               options:NSKeyValueObservingOptionNew context:NULL];
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    CGFloat sound = [change[@"new"] floatValue];
    [self appearSoundView];
    [self updateLongView:sound];
    [[UIApplication sharedApplication].windows.lastObject addSubview:self];
    
}

- (void)appearSoundView {
    if (self.alpha == 0) {
        self.alpha = 1;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self disAppearSoundView];
        });
    }
}

- (void)disAppearSoundView {
    if (self.alpha == 1) {
        [UIView animateWithDuration:0.8 animations:^{
            self.alpha = 0;
        }];
    }
}

- (void)updateLongView:(CGFloat)sound {
    CGFloat stage = 1 / 15.0;
    NSInteger level = sound / stage;
    for (int i = 0; i < self.tipArray.count; i++) {
        UIImageView *img = self.tipArray[i];
        if (i <= level) {
            img.hidden = NO;
        } else {
            img.hidden = YES;
        }
    }
}

- (void)dealloc {
    [[UIScreen mainScreen] removeObserver:self forKeyPath:@"brightness"];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
