//
//  LLRefreshHeaderView.m
//  refresh
//
//  Created by zhaomengWang on 17/3/16.
//  Copyright © 2017年 MaoChao Network Co. Ltd. All rights reserved.
//

#import "LLRefreshHeaderView.h"

@implementation LLRefreshHeaderView {
    UILabel *_messageLabel;
}

+ (instancetype)headerWithRefreshingTarget:(id)target refreshingAction:(SEL)action {
    LLRefreshHeaderView *refreshHeader = [[self alloc] init];
    refreshHeader.refreshingTarget = target;
    refreshHeader.refreshingAction = action;
    return refreshHeader;
}

- (void)createViews {
    [super createViews];
    _messageLabel = [[UILabel alloc] initWithFrame:self.bounds];
    _messageLabel.text = @"下拉可以刷新";
    _messageLabel.textAlignment = NSTextAlignmentCenter;
    _messageLabel.textColor = R_G_B(150, 150, 150);
    [self addSubview:_messageLabel];
}

- (void)setRefreshState:(LLRefreshState)refreshState {
    if (refreshState == self.refreshState) return;
    if (refreshState == LLRefreshStateNormal) {
        _messageLabel.text = @"下拉可以刷新";
    }
    else if (refreshState == LLRefreshStateWillRefresh) {
        _messageLabel.text = @"松开立即刷新";
    }
    else if (refreshState == LLRefreshStateRefreshing) {
        _messageLabel.text = @"正在刷新数据中...";
    }
    else {
        _messageLabel.text = @"没有更多数据了";
    }
    [super setRefreshState:refreshState];
}

- (void)scrollViewContentOffsetDidChange:(NSDictionary *)change{
    [super scrollViewContentOffsetDidChange:change];
    if (self.scrollView.contentOffset.y >= 0) return;
    
    if (self.scrollView.contentOffset.y > -LLRefreshHeaderHeight) {
        [self LL_RefreshNormal];
    }
    else {
        [self LL_WillRefresh];
    }
}

- (void)scrollViewPanStateDidChange:(NSDictionary *)change{
    [super scrollViewPanStateDidChange:change];
    if (self.scrollView.panGestureRecognizer.state == UIGestureRecognizerStateEnded) {
        if (self.scrollView.contentOffset.y <= -LLRefreshHeaderHeight) {
            [self LL_BeginRefresh];
        }
    }
}

- (void)LL_BeginRefresh {
    if (self.isRefreshing == NO) {
        [super LL_BeginRefresh];
        dispatch_async(dispatch_get_main_queue(), ^{
            [UIView animateWithDuration:.35 animations:^{
                self.scrollView.contentInset = UIEdgeInsetsMake(LLRefreshHeaderHeight, 0, 0, 0);
            } completion:^(BOOL finished) {
                if ([self.refreshingTarget respondsToSelector:self.refreshingAction]) {
                    LLRefreshMsgSend(LLRefreshMsgTarget(self.refreshingTarget), self.refreshingAction, self);
                }
            }];
        });
    }
}

- (void)LL_EndRefresh {
    if (self.isRefreshing) {
        [super LL_EndRefresh];
        [UIView animateWithDuration:.35 animations:^{
            self.scrollView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
        }];
    }
}

@end
