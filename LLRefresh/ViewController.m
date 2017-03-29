//
//  ViewController.m
//  LLRefresh
//
//  Created by zhaomengWang on 17/3/29.
//  Copyright © 2017年 MaoChao Network Co. Ltd. All rights reserved.
//

#import "ViewController.h"
#import "LLRefresh.h"

@interface ViewController ()<UITableViewDelegate,UITableViewDataSource>{
    UITableView    *_tableView;
    NSMutableArray *_testDatas;
    NSInteger       _page;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self createViews];
}

- (void)createViews {
    
    _testDatas = [NSMutableArray arrayWithCapacity:10];
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 20, self.view.bounds.size.width, self.view.bounds.size.height-20)];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.tableFooterView = [UIView new];
    _tableView.LLRefreshHeader = [LLRefreshHeaderView headerWithRefreshingTarget:self refreshingAction:@selector(headerRefresh)];
    _tableView.LLRefreshFooter = [LLRefreshFooterView footerWithRefreshingTarget:self refreshingAction:@selector(footerRefresh)];
    [self.view addSubview:_tableView];
    
    [_tableView.LLRefreshHeader LL_BeginRefresh];
}

#pragma mark - UITableViewDataSource,UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _testDatas.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
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

#pragma mark - LLRefresh
//下拉刷新
- (void)headerRefresh {
    _page = 0;
    [_testDatas removeAllObjects];
    [self reloadData];
}

//上拉加载
- (void)footerRefresh {
    [self reloadData];
}

- (void)endRefresh {
    [_tableView.LLRefreshHeader LL_EndRefresh];
    [_tableView.LLRefreshFooter LL_EndRefresh];
}

//模拟加载数据
- (void)reloadData {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        for (NSInteger i = 0; i < 20; i ++) {
            NSString *testStr = [NSString stringWithFormat:@"第%ld页数据",(long)_page];
            [_testDatas addObject:testStr];
        }
        _page ++;
        [self endRefresh];
        [_tableView reloadData];
    });
}
#pragma mark -

@end
