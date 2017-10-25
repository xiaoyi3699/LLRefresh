//
//  LLRefreshComponent.h
//  refresh
//
//  Created by zhaomengWang on 17/3/24.
//  Copyright © 2017年 MaoChao Network Co. Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LLRefreshHelper.h"

#define R_G_B(_r_,_g_,_b_)          \
[UIColor colorWithRed:_r_/255. green:_g_/255. blue:_b_/255. alpha:1.0]

#define LLRefreshHeaderHeight 60
#define LLRefreshFooterHeight 60
#define LL_REFRESH_COLOR      R_G_B(50, 50, 50)
#define LL_TIME_COLOR         R_G_B(50, 50, 50)
#define LL_REFRESH_FONT       [UIFont boldSystemFontOfSize:13]
#define LL_TIME_FONT          [UIFont boldSystemFontOfSize:13]
#define LL_TRANS_FORM CATransform3DConcat(CATransform3DIdentity, CATransform3DMakeRotation(M_PI+0.000001, 0, 0, 1))
extern NSString *const LLRefreshHeaderTime;
extern NSString *const LLRefreshMoreData;
/** 刷新控件的状态 */
typedef NS_ENUM(NSInteger, LLRefreshState) {
    
    LLRefreshStateNormal          = 0, //普通状态
    LLRefreshStateWillRefresh,         //松开就刷新的状态
    LLRefreshStateRefreshing,          //正在刷新中的状态
    LLRefreshStateNoMoreData           //没有更多的数据
};

@interface LLRefreshComponent : UIView{
    LLRefreshState _refreshState;
    UILabel *_messageLabel;
    UILabel *_laseTimeLabel;
}

@property (nonatomic, strong) UIImageView *arrowView;
@property (nonatomic, strong) UIActivityIndicatorView *loadingView;

/** 是否处于刷新状态 */
@property (nonatomic, assign) BOOL isRefreshing;

/** 回调对象 */
@property (nonatomic, weak) id refreshingTarget;

/** 回调方法 */
@property (nonatomic, assign) SEL refreshingAction;

#pragma mark - 交给子类去访问
/** 父控件 */
@property (weak,   nonatomic, readonly) UIScrollView *scrollView;

#pragma mark - 交给子类们去实现
/** 普通状态 */
- (void)LL_RefreshNormal NS_REQUIRES_SUPER;

/** 松开就刷新的状态 */
- (void)LL_WillRefresh NS_REQUIRES_SUPER;

/** 没有更多的数据 */
- (void)LL_NoMoreData NS_REQUIRES_SUPER;

/** 正在刷新中的状态 */
- (void)LL_BeginRefresh NS_REQUIRES_SUPER;

/** 刷新结束 */
- (void)LL_EndRefresh:(BOOL)more NS_REQUIRES_SUPER;

/** 初始化 */
- (void)prepare NS_REQUIRES_SUPER;

/** 创建子视图 */
- (void)createViews;

/** 当scrollView的contentOffset发生改变的时候调用 */
- (void)scrollViewContentOffsetDidChange:(NSDictionary *)change;

/** 当scrollView的contentSize发生改变的时候调用 */
- (void)scrollViewContentSizeDidChange:(NSDictionary *)change;

/** 当scrollView的拖拽状态发生改变的时候调用 */
- (void)scrollViewPanStateDidChange:(NSDictionary *)change;

/** 更新刷新控件的状态 */
- (void)updateRefreshState:(LLRefreshState)refreshState;

/** 移除kvo监听 */
- (void)removeObservers;

@end
