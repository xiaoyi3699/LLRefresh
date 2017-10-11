//
//  ViewController.m
//  LLRefresh
//
//  Created by zhaomengWang on 17/3/29.
//  Copyright © 2017年 MaoChao Network Co. Ltd. All rights reserved.
//

#import "ViewController.h"
#import "LLRefresh.h"

#define SCREEN_HEIGHT  [UIScreen mainScreen].bounds.size.height
#define iPhoneX        (SCREEN_HEIGHT==812) //是否是iPhoneX
@interface ViewController ()<UITableViewDelegate,UITableViewDataSource>{
    UITableView *tableView;
    NSInteger   _page;
    NSInteger   _rows;
    NSMutableArray *_testDatas;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _testDatas = [NSMutableArray arrayWithCapacity:10];
    
    CGRect rect = self.view.bounds;
    rect.origin.y = CGRectGetMaxY(self.navigationController.navigationBar.frame);
    if (iPhoneX) {
        rect.size.height -= (88+83);
    }
    else {
        rect.size.height -= (64+49);
    }
    
    tableView = [[UITableView alloc] initWithFrame:rect];
    tableView.delegate = self;
    tableView.dataSource = self;
    if (@available(iOS 11.0, *)) {
        tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    } else {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    
    tableView.tableFooterView = [UIView new];
    tableView.LLRefreshHeader = [LLRefreshHeaderView headerWithRefreshingTarget:self refreshingAction:@selector(refreshHeader)];
    tableView.LLRefreshFooter = [LLRefreshFooterView footerWithRefreshingTarget:self refreshingAction:@selector(refreshFooter)];
    [self.view addSubview:tableView];
    
    [tableView.LLRefreshHeader LL_BeginRefresh];
}

- (void)refreshHeader {
    _page = 0;
    [_testDatas removeAllObjects];
    [self reloadData];
}

- (void)refreshFooter {
    [self reloadData];
}

- (void)endRefresh {
    [tableView reloadData];
    [tableView.LLRefreshHeader LL_EndRefresh];
    [tableView.LLRefreshFooter LL_EndRefresh];
}

//模拟加载数据
- (void)reloadData {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (_page < 3) {//模拟加载数据,设置只能加载3页
            for (NSInteger i = 0; i < 20; i ++) {
                NSString *testStr = [NSString stringWithFormat:@"第%ld页数据",(long)_page];
                [_testDatas addObject:testStr];
            }
            _page ++;
        }
        [self endRefresh];
    });
}

#pragma mark - UITableViewDelegate,UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _testDatas.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"cell"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    if (_testDatas.count > indexPath.row) {
        cell.textLabel.text = _testDatas[indexPath.row];
    }
    return cell;
}

@end
