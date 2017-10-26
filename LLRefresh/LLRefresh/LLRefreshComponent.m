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
NSString *const LLRefreshHeaderTime           = @"LLRefreshHeaderTime";
NSString *const LLRefreshMoreData             = @"LLRefreshMoreData";
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
        _refreshState = LLRefreshStateNormal;
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
        
        if ([newSuperview isKindOfClass:[UITableView class]]) {
            //关闭UITableView的高度预估
            ((UITableView *)newSuperview).estimatedRowHeight = 0;
            ((UITableView *)newSuperview).estimatedSectionHeaderHeight = 0;
            ((UITableView *)newSuperview).estimatedSectionFooterHeight = 0;
        }
        
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

- (void)dealloc {
    [self removeObservers];
}

- (UIImageView *)arrowView {
    if (_arrowView == nil) {
        _arrowView = [[UIImageView alloc] init];
        _arrowView.image = [LLRefreshHelper LL_ArrowImage];
        _arrowView.tintColor = LL_REFRESH_COLOR;
        if ([self isKindOfClass:NSClassFromString(@"LLRefreshFooterView")]) {
            _arrowView.layer.transform = LL_TRANS_FORM;
        }
        [self addSubview:_arrowView];
    }
    return _arrowView;
}

- (UIActivityIndicatorView *)loadingView {
    if (_loadingView == nil) {
        _loadingView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        _loadingView.hidesWhenStopped = YES;
        [self addSubview:_loadingView];
    }
    return _loadingView;
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
    if ([keyPath isEqualToString:LLRefreshKeyPathContentSize]) {
        [self scrollViewContentSizeDidChange:change];
    }
    
    if (self.hidden)       return;
    if ([keyPath isEqualToString:LLRefreshKeyPathContentOffset]) {
        [self scrollViewContentOffsetDidChange:change];
    }
    else if ([keyPath isEqualToString:LLRefreshKeyPathPanState]) {
        [self scrollViewPanStateDidChange:change];
    }
}

/** 普通状态 */
- (void)LL_RefreshNormal{
    [self updateRefreshState:LLRefreshStateNormal];
}

/** 松开就刷新的状态 */
- (void)LL_WillRefresh {
    [self updateRefreshState:LLRefreshStateWillRefresh];
}

/** 没有更多的数据 */
- (void)LL_NoMoreData {
    [self updateRefreshState:LLRefreshStateNoMoreData];
}

/** 正在刷新中的状态 */
- (void)LL_BeginRefresh{
    self.isRefreshing = YES;
    [self refreshUI:YES];
    [self updateRefreshState:LLRefreshStateRefreshing];
}

/** 结束刷新 */
- (void)LL_EndRefresh:(BOOL)more{
    self.isRefreshing = NO;
    if (more) {
        [self LL_RefreshNormal];
    }
    else {
        [self LL_NoMoreData];
    }
    [self refreshUI:NO];
}

- (void)refreshUI:(BOOL)begin {
    if (begin) {
        self.arrowView.hidden = YES;
        [self.loadingView startAnimating];
    }
    else {
        if ([self isKindOfClass:NSClassFromString(@"LLRefreshHeaderView")]) {
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                [LLRefreshHelper LL_setRefreshTime:LLRefreshHeaderTime];
                NSString *value = [LLRefreshHelper LL_getRefreshTime:LLRefreshHeaderTime];
                NSInteger w = ceil([value sizeWithAttributes:@{NSFontAttributeName:LL_TIME_FONT}].width);
                dispatch_async(dispatch_get_main_queue(), ^{
                    _laseTimeLabel.text = value;
                    self.arrowView.frame = CGRectMake((self.bounds.size.width-w)/2-35, (LLRefreshHeaderHeight-40)/2.0, 15, 40);
                    self.arrowView.layer.transform = CATransform3DIdentity;
                    [self.loadingView stopAnimating];
                    self.loadingView.center = self.arrowView.center;
                });
            });
        }
        else {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSInteger w = ceil([_messageLabel.text sizeWithAttributes:@{NSFontAttributeName:LL_TIME_FONT}].width);
                self.arrowView.frame = CGRectMake((self.bounds.size.width-w)/2-35, (LLRefreshFooterHeight-40)/2.0, 15, 40);
                self.arrowView.layer.transform = LL_TRANS_FORM;
                [self.loadingView stopAnimating];
                self.loadingView.center = self.arrowView.center;
            });
            
        }
    }
}

- (void)createViews{};
- (void)scrollViewContentOffsetDidChange:(NSDictionary *)change{}
- (void)scrollViewContentSizeDidChange:(NSDictionary *)change{}
- (void)scrollViewPanStateDidChange:(NSDictionary *)change{}
- (void)updateRefreshState:(LLRefreshState)refreshState{}

@end
