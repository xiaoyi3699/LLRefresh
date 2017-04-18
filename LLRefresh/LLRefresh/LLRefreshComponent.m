//
//  LLRefreshComponent.m
//  refresh
//
//  Created by zhaomengWang on 17/3/24.
//  Copyright © 2017年 MaoChao Network Co. Ltd. All rights reserved.
//

#import "LLRefreshComponent.h"

NSString *const LLRefreshKeyPathContentOffset = @"contentOffset";
NSString *const LLRefreshKeyPathContentSize   = @"contentSize";
NSString *const LLRefreshKeyPathPanState      = @"state";
@interface LLRefreshComponent ()

@property (strong, nonatomic) UIPanGestureRecognizer *pan;

@end

@implementation LLRefreshComponent

#pragma mark - 初始化
- (instancetype)init
{
    if (self = [super init]) {
        // 准备工作
        [self prepare];
        
        // 默认是普通状态
        self.refreshState = LLRefreshStateNormal;
    }
    return self;
}

- (void)prepare
{
    // 基本属性
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.backgroundColor  = [UIColor clearColor];
}

- (void)willMoveToSuperview:(UIView *)newSuperview {
    [super willMoveToSuperview:newSuperview];
    
    // 如果不是UIScrollView，不做任何事情
    if ([newSuperview isKindOfClass:[UIScrollView class]]) {
        
        // 旧的父控件移除监听
        [self removeObservers];
        
        // 记录UIScrollView
        _scrollView = (UIScrollView *)newSuperview;
        // 设置永远支持垂直弹簧效果
        _scrollView.alwaysBounceVertical = YES;
        
        // 添加监听
        [self addObservers];
    }
}

#pragma mark - KVO监听
- (void)addObservers
{
    NSKeyValueObservingOptions options = NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld;
    [self.scrollView addObserver:self forKeyPath:LLRefreshKeyPathContentOffset options:options context:nil];
    [self.scrollView addObserver:self forKeyPath:LLRefreshKeyPathContentSize options:options context:nil];
    self.pan = self.scrollView.panGestureRecognizer;
    [self.pan addObserver:self forKeyPath:LLRefreshKeyPathPanState options:options context:nil];
}

- (void)removeObservers
{
    [self.superview removeObserver:self forKeyPath:LLRefreshKeyPathContentOffset];
    [self.superview removeObserver:self forKeyPath:LLRefreshKeyPathContentSize];
    [self.pan removeObserver:self forKeyPath:LLRefreshKeyPathPanState];
    self.pan = nil;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (self.isRefreshing) return;
    if (self.hidden)       return;
    if ([keyPath isEqualToString:LLRefreshKeyPathContentOffset]) {
        [self scrollViewContentOffsetDidChange:change];
    }
    else if ([keyPath isEqualToString:LLRefreshKeyPathContentSize]) {
        [self scrollViewContentSizeDidChange:change];
    }
    else if ([keyPath isEqualToString:LLRefreshKeyPathPanState]) {
        [self scrollViewPanStateDidChange:change];
    }
}

/** 普通状态 */
- (void)LL_RefreshNormal{
    self.refreshState = LLRefreshStateNormal;
}

/** 松开就刷新的状态 */
- (void)LL_WillRefresh {
    self.refreshState = LLRefreshStateWillRefresh;
}

/** 正在刷新中的状态 */
- (void)LL_BeginRefresh{
    self.isRefreshing = YES;
    self.refreshState = LLRefreshStateRefreshing;
}

/** 没有更多的数据 */
- (void)LL_NoMoreData {
    self.isRefreshing = NO;
    self.refreshState = LLRefreshStateNoMoreData;
}

/** 结束刷新 */
- (void)LL_EndRefresh{
    self.isRefreshing = NO;
    if (self.refreshState == LLRefreshStateNoMoreData) {
        self.refreshState = LLRefreshStateNoMoreData;
    }
    else {
        self.refreshState = LLRefreshStateNormal;
    }
}

- (void)createViews{};
- (void)scrollViewContentOffsetDidChange:(NSDictionary *)change{}
- (void)scrollViewContentSizeDidChange:(NSDictionary *)change{}
- (void)scrollViewPanStateDidChange:(NSDictionary *)change{}

@end
