//
//  NY-Header.h
//  DDNM-NY
//
//  Created by 叶星龙 on 2016/11/26.
//  Copyright © 2016年 北京叮咚柠檬科技有限公司. All rights reserved.
//

#ifndef NY_Header_h
#define NY_Header_h

#import "UIView+YXLBaseClassPropertyAcronym.h"
#import "UIButton+YXLAcronymButton.h"
#import "UIImageView+YXLAcronymImageView.h"
#import "UILabel+YXLAcronymLabel.h"
#import "Masonry.h"
#import "SVProgressHUD.h"
#import "UIImage+YXL.h"

#define kScreenBounds [[UIScreen                          mainScreen]bounds]
#define kWindowWidth  ([[UIScreen mainScreen]             bounds].size.width)
#define kWindowHeight ([[UIScreen mainScreen]             bounds].size.height)

#ifndef CGWidth
#define CGWidth(rect)                   rect.size.width
#endif

#ifndef CGHeight
#define CGHeight(rect)                  rect.size.height
#endif

#ifndef CGOriginX
#define CGOriginX(rect)                 rect.origin.x
#endif

#ifndef CGOriginY
#define CGOriginY(rect)                 rect.origin.y
#endif

#define iOSDevice [[UIDevice currentDevice].systemVersion doubleValue]

#define IS_IPAD (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)

#define UMSYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define _IPHONE80_ 80000

//#define WS(weakSelf)  __weak __typeof(&*self)weakSelf = self;
#define ESWeak(var, weakVar) __weak __typeof(&*var) weakVar = var
#define ESStrong_DoNotCheckNil(weakVar, _var) __typeof(&*weakVar) _var = weakVar
#define ESStrong(weakVar, _var) ESStrong_DoNotCheckNil(weakVar, _var); if (!_var) return;

#define ESWeak_(var) ESWeak(var, weak_##var);
#define ESStrong_(var) ESStrong(weak_##var, _##var);

/** defines a weak `self` named `__weakSelf` */
#define ESWeakSelf      ESWeak(self, __weakSelf);
/** defines a strong `self` named `_self` from `__weakSelf` */
#define ESStrongSelf    ESStrong(__weakSelf, _self);

// 细字体
#define Font(F)                 [UIFont systemFontOfSize:(F)]
// 粗字体
#define boldFont(F)             [UIFont boldSystemFontOfSize:(F)]
// 标准的RGBA设置
#define UIColorRGBA(r, g, b, a) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:(a)]
// 十六进制色值
#define UIColorFromRGB_HEX(rgbValue)        [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]
// 十六进制色值加透明度
#define UIColorFromRGBA_HEX(rgbV,alphaV)    [UIColor colorWithRed:((float)((rgbV & 0xFF0000) >> 16))/255.0 green:((float)((rgbV & 0xFF00) >> 8))/255.0 blue:((float)(rgbV & 0xFF))/255.0 alpha:alphaV]

#define HEX_COLOR_THEME             UIColorFromRGB_HEX(0xf64861)//主题颜色

#define HEX_COLOR_VIEW_BACKGROUND   UIColorRGBA(255, 255, 255, 1) //视图底色

#define Notification [NSNotificationCenter   defaultCenter]

#define SuppressPerformSelectorLeakWarning(Stuff) \
do { \
_Pragma("clang diagnostic push") \
_Pragma("clang diagnostic ignored \"-Warc-performSelector-leaks\"") \
Stuff; \
_Pragma("clang diagnostic pop") \
} while (0)

#ifdef DEBUG
#define NSLog(FORMAT, ...) fprintf(stderr,"%s:%d\t%s\n",[[[NSString stringWithUTF8String:__FILE__] lastPathComponent] UTF8String], __LINE__, [[NSString stringWithFormat:FORMAT, ##__VA_ARGS__] UTF8String]);
#else
#define NSLog(...)
#endif


#endif /* NY_Header_h */
