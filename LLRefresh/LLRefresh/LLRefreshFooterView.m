//
//  LLRefreshFooterView.m
//  refresh
//
//  Created by zhaomengWang on 17/3/16.
//  Copyright © 2017年 MaoChao Network Co. Ltd. All rights reserved.
//

#import "LLRefreshFooterView.h"
#import <objc/message.h>

// 运行时objc_msgSend
#define LLRefreshMsgSend(...)       ((void (*)(void *, SEL, UIView *))objc_msgSend)(__VA_ARGS__)
#define LLRefreshMsgTarget(target)  (__bridge void *)(target)
@implementation LLRefreshFooterView{
    UILabel *_messageLabel;
    CGFloat _contentOffsetY;
    CGFloat _lastContentHeight;
}

+ (instancetype)footerWithRefreshingTarget:(id)target refreshingAction:(SEL)action {
    LLRefreshFooterView *refreshFooter = [[self alloc] init];
    refreshFooter.refreshingTarget = target;
    refreshFooter.refreshingAction = action;
    [[NSNotificationCenter defaultCenter] addObserver:refreshFooter selector:@selector(refreshMoreData:) name:LLRefreshMoreData object:nil];
    return refreshFooter;
}

- (void)refreshMoreData:(NSNotification *)notification {
    BOOL moreData = [notification.object boolValue];
    if (moreData) {
        [self LL_RefreshNormal];
    }
    else {
        [self LL_NoMoreData];
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)createViews {
    [super createViews];
    _messageLabel = [[UILabel alloc] initWithFrame:self.bounds];
    _messageLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    _messageLabel.text = @"上拉可以加载更多";
    _messageLabel.textAlignment = NSTextAlignmentCenter;
    _messageLabel.textColor = [UIColor colorWithRed:100/255. green:100/255. blue:100/255. alpha:1];
    [self addSubview:_messageLabel];
}

- (void)updateRefreshState:(LLRefreshState)refreshState {
    if (refreshState == _refreshState) return;
    
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
    _refreshState = refreshState;
}

- (void)scrollViewContentOffsetDidChange:(NSDictionary *)change{
    [super scrollViewContentOffsetDidChange:change];
    if (self.scrollView.contentOffset.y <= 0) return;
    
    if (_refreshState == LLRefreshStateNoMoreData) {
        return;
    }
    
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
        //dispatch_async(dispatch_get_main_queue(), ^{
            [UIView animateWithDuration:.35 animations:^{
                self.scrollView.contentInset = UIEdgeInsetsMake(-LLRefreshFooterHeight-_contentOffsetY, 0, 0, 0);
                _lastContentHeight = self.scrollView.contentSize.height;
            } completion:^(BOOL finished) {
                if ([self.refreshingTarget respondsToSelector:self.refreshingAction]) {
                    LLRefreshMsgSend(LLRefreshMsgTarget(self.refreshingTarget), self.refreshingAction, self);
                }
            }];
        //});
    }
}

- (void)LL_EndRefresh:(BOOL)more {
    if (self.isRefreshing) {
        [super LL_EndRefresh:more];
        
        if (_contentOffsetY == 0 || more == NO) {
            [UIView animateWithDuration:.35 animations:^{
                self.scrollView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
            }];
        }
        else {
            //[UIView animateWithDuration:.35 animations:^{
                self.scrollView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
                self.scrollView.contentOffset = CGPointMake(0, _lastContentHeight-self.scrollView.bounds.size.height+LLRefreshFooterHeight);
            //}];
        }
    }
}

@end
