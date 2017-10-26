//
//  LLRefreshHeaderView.m
//  refresh
//
//  Created by zhaomengWang on 17/3/16.
//  Copyright © 2017年 MaoChao Network Co. Ltd. All rights reserved.
//

#import "LLRefreshHeaderView.h"
#import <objc/message.h>

// 运行时objc_msgSend
#define LLRefreshMsgSend(...)       ((void (*)(void *, SEL, UIView *))objc_msgSend)(__VA_ARGS__)
#define LLRefreshMsgTarget(target)  (__bridge void *)(target)
@implementation LLRefreshHeaderView

+ (instancetype)headerWithRefreshingTarget:(id)target refreshingAction:(SEL)action {
    LLRefreshHeaderView *refreshHeader = [[self alloc] init];
    refreshHeader.refreshingTarget = target;
    refreshHeader.refreshingAction = action;
    return refreshHeader;
}

- (void)layoutSubviews {
    
    CGRect rect = self.frame;
    rect.origin.y = -LLRefreshHeaderHeight;
    self.frame = rect;
    
    NSInteger w = ceil([_laseTimeLabel.text sizeWithAttributes:@{NSFontAttributeName:LL_TIME_FONT}].width);
    self.arrowView.frame = CGRectMake((self.bounds.size.width-w)/2-35, (LLRefreshHeaderHeight-40)/2.0, 15, 40);
    
    self.loadingView.center = self.arrowView.center;
    self.loadingView.color = LL_REFRESH_COLOR;
    
    [super layoutSubviews];
}

- (void)createViews {
    [super createViews];
    CGFloat labelH = (LLRefreshHeaderHeight-10)/2;
    _messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 5, self.bounds.size.width, labelH)];
    _messageLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    _messageLabel.font = LL_REFRESH_FONT;
    _messageLabel.text = @"下拉可以刷新";
    _messageLabel.textAlignment = NSTextAlignmentCenter;
    _messageLabel.textColor = LL_REFRESH_COLOR;
    [self addSubview:_messageLabel];
    
    NSString *lastTime = [LLRefreshHelper LL_getRefreshTime:LLRefreshHeaderTime];
    _laseTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_messageLabel.frame), self.bounds.size.width, labelH)];
    _laseTimeLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    _laseTimeLabel.font = LL_TIME_FONT;
    _laseTimeLabel.text = lastTime;
    _laseTimeLabel.textAlignment = NSTextAlignmentCenter;
    _laseTimeLabel.textColor = LL_TIME_COLOR;
    [self addSubview:_laseTimeLabel];
}

- (void)updateRefreshState:(LLRefreshState)refreshState {
    if (refreshState == _refreshState) return;
    
    NSString *refreshText;
    if (refreshState == LLRefreshStateNormal) {
        refreshText = @"下拉可以刷新";
    }
    else if (refreshState == LLRefreshStateWillRefresh) {
        refreshText = @"松开立即刷新";
    }
    else if (refreshState == LLRefreshStateRefreshing) {
        refreshText = @"正在刷新数据...";
    }
    else {
        refreshText = @"没有更多数据了";
    }
    _messageLabel.text = refreshText;
    _refreshState = refreshState;
}

- (void)scrollViewContentOffsetDidChange:(NSDictionary *)change{
    [super scrollViewContentOffsetDidChange:change];
    if (self.scrollView.contentOffset.y >= 0) return;
    
    CATransform3D transform3D = CATransform3DIdentity;
    
    if (self.scrollView.contentOffset.y > -LLRefreshHeaderHeight) {
        [self LL_RefreshNormal];
    }
    else {
        [self LL_WillRefresh];
        transform3D = LL_TRANS_FORM;
    }
    [UIView animateWithDuration:.3 animations:^{
        self.arrowView.layer.transform = transform3D;
    }];
}

- (void)scrollViewPanStateDidChange:(NSDictionary *)change{
    [super scrollViewPanStateDidChange:change];
    if (self.scrollView.panGestureRecognizer.state == UIGestureRecognizerStateEnded) {
        if (self.scrollView.contentOffset.y <= -LLRefreshHeaderHeight) {
            [self LL_BeginRefresh];
        }
    }
    else if (self.scrollView.panGestureRecognizer.state == UIGestureRecognizerStateBegan) {
        self.arrowView.hidden = NO;
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

- (void)LL_EndRefresh:(BOOL)more {
    if (self.isRefreshing) {
        [super LL_EndRefresh:more];
        [[NSNotificationCenter defaultCenter] postNotificationName:LLRefreshMoreData object:@(more)];
        dispatch_async(dispatch_get_main_queue(), ^{
            [UIView animateWithDuration:.35 animations:^{
                self.scrollView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
            }];
        });
    }
}

- (void)LL_EndRefresh {
    if (self.isRefreshing) {
        [super LL_EndRefresh:YES];
        [[NSNotificationCenter defaultCenter] postNotificationName:LLRefreshMoreData object:@(YES)];
        dispatch_async(dispatch_get_main_queue(), ^{
            [UIView animateWithDuration:.35 animations:^{
                self.scrollView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
            }];
        });
        
    }
}

@end
