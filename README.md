[我的博客：iOS轻量级下拉刷新，上拉加载](http://www.jianshu.com/p/314c942cab9e)

![Image text](https://github.com/wangzhaomeng/LLRefresh/blob/master/LLRefresh.png?raw=true)

```
_tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 20, self.view.bounds.size.width, self.view.bounds.size.height-20)];
_tableView.delegate = self;
_tableView.dataSource = self;
_tableView.tableFooterView = [UIView new];
_tableView.LLRefreshHeader = [LLRefreshHeaderView headerWithRefreshingTarget:self refreshingAction:@selector(headerRefresh)];
_tableView.LLRefreshFooter = [LLRefreshFooterView footerWithRefreshingTarget:self refreshingAction:@selector(footerRefresh)];
[self.view addSubview:_tableView];
    
[_tableView.LLRefreshHeader LL_BeginRefresh];
```

