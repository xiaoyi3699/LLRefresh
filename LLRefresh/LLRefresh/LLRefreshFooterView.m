//
//  LLRefreshFooterView.m
//  refresh
//
//  Created by zhaomengWang on 17/3/16.
//  Copyright © 2017年 MaoChao Network Co. Ltd. All rights reserved.
//

#import "LLRefreshFooterView.h"

@implementation LLRefreshFooterView{
    UILabel *_messageLabel;
    CGFloat _contentOffsetY;
}

+ (instancetype)footerWithRefreshingTarget:(id)target refreshingAction:(SEL)action {
    LLRefreshFooterView *refreshFooter = [[self alloc] init];
    refreshFooter.refreshingTarget = target;
    refreshFooter.refreshingAction = action;
    return refreshFooter;
}

- (void)createViews {
    [super createViews];
    _messageLabel = [[UILabel alloc] initWithFrame:self.bounds];
    _messageLabel.text = @"上拉可以加载更多";
    _messageLabel.textAlignment = NSTextAlignmentCenter;
    _messageLabel.textColor = [UIColor colorWithRed:100/255. green:100/255. blue:100/255. alpha:1];
    [self addSubview:_messageLabel];
}

- (void)setRefreshState:(LLRefreshState)refreshState {
    if (refreshState == self.refreshState) return;
    if (refreshState == LLRefreshStateNormal) {
        _messageLabel.text = @"上拉可以加载更多";
    }
    else if (refreshState == LLRefreshStateWillRefresh) {
        _messageLabel.text = @"松开立即加载更多";
    }
    else if (refreshState == LLRefreshStateRefreshing) {
        _messageLabel.text = @"正在加载数据中...";
    }
    else {
        _messageLabel.text = @"没有更多数据了";
    }
    [super setRefreshState:refreshState];
}

- (void)scrollViewContentOffsetDidChange:(NSDictionary *)change{
    [super scrollViewContentOffsetDidChange:change];
    if (self.scrollView.contentOffset.y <= 0) return;
    
    if (self.scrollView.contentOffset.y < LLRefreshFooterHeight+_contentOffsetY) {
        [self LL_RefreshNormal];
    }
    else {
        [self LL_WillRefresh];
    }
}

- (void)scrollViewContentSizeDidChange:(NSDictionary *)change {
    [super scrollViewContentSizeDidChange:change];
    
    if (self.scrollView.contentSize.height > self.scrollView.bounds.size.height) {
        _contentOffsetY = self.scrollView.contentSize.height-self.scrollView.bounds.size.height;
    }
    else {
        _contentOffsetY = 0.0;
    }
    CGRect frame = self.frame;
    frame.origin.y = self.scrollView.bounds.size.height+_contentOffsetY;
    self.frame = frame;
}

- (void)scrollViewPanStateDidChange:(NSDictionary *)change{
    [super scrollViewPanStateDidChange:change];
    if (self.scrollView.panGestureRecognizer.state == UIGestureRecognizerStateEnded) {
        if (self.scrollView.contentOffset.y >= LLRefreshFooterHeight+_contentOffsetY) {
            [self LL_BeginRefresh];
        }
    }
}

- (void)LL_BeginRefresh {
    if (self.isRefreshing == NO) {
        [super LL_BeginRefresh];
        dispatch_async(dispatch_get_main_queue(), ^{
            [UIView animateWithDuration:.35 animations:^{
                self.scrollView.contentInset = UIEdgeInsetsMake(-LLRefreshFooterHeight-_contentOffsetY, 0, 0, 0);
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
        if (_contentOffsetY == 0) {
            [UIView animateWithDuration:.35 animations:^{
                self.scrollView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
            }];
        }
        else {
            [UIView animateWithDuration:.35 animations:^{
                self.scrollView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
                [self.scrollView setContentOffset:CGPointMake(0, LLRefreshFooterHeight+_contentOffsetY) animated:NO];
            }];
        }
    }
}

@end
