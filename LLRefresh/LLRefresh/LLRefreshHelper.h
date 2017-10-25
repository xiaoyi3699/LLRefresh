//
//  LLRefreshHelper.h
//  LLFeature
//
//  Created by WangZhaomeng on 2017/10/25.
//  Copyright © 2017年 WangZhaomeng. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LLRefreshHelper : NSObject

/** 获取上次更新时间 */
+ (NSString *)LL_getRefreshTime:(NSString *)key;

/** 重置更新时间 */
+ (void)LL_setRefreshTime:(NSString *)key;

/** 资源路径 */
+ (NSBundle *)LL_RefreshBundle;

/** 箭头 */
+ (UIImage *)LL_ArrowImage;

@end
