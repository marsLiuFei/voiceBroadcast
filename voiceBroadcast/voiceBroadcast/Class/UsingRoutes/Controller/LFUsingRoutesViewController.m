//
//  LFUsingRoutesViewController.m
//  voiceBroadcast
//
//  Created by apple on 2017/11/13.
//  Copyright © 2017年 baixinxueche. All rights reserved.
//  已有路线展示列表

#import "LFUsingRoutesViewController.h"
#import "BXRoutesModel.h"
#import "LFMakesureUsingViewController.h"

@interface LFUsingRoutesViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic,strong)UITableView *tableView;//创建表格时图
@property (assign,nonatomic) int page;
@property (strong,nonatomic) NSMutableArray *routesArray;

@end

@implementation LFUsingRoutesViewController

- (NSMutableArray *)routesArray{
    if (!_routesArray) {
        _routesArray = [NSMutableArray new];
    }
    return _routesArray;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"已有路线";
    self.view.backgroundColor = [UIColor whiteColor];

    [SVProgressHUD setDefaultStyle:SVProgressHUDStyleCustom];
    [SVProgressHUD setForegroundColor:[UIColor whiteColor]];
    [SVProgressHUD setBackgroundColor:THEMECOLOR];

    [self creatTableView];
    [self addRefresh];
}


#pragma mark -- 创建表格视图
- (void) creatTableView{
    _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"myCellReuseIdentifier"];
    _tableView.delegate   = self;
    _tableView.dataSource = self;
    [self.view addSubview:_tableView];
    _tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.bottom.mas_equalTo(self.view).offset(0);
    }];
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.routesArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [_tableView dequeueReusableCellWithIdentifier:@"myCellReuseIdentifier"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"myCellReuseIdentifier"];
    }
    BXRoutesModel *model = self.routesArray[indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat:@"线路名：%@",model.route_name];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [_tableView deselectRowAtIndexPath:indexPath animated:YES];
    BXRoutesModel *model = self.routesArray[indexPath.row];
    LFMakesureUsingViewController *makesureUsingVC = [LFMakesureUsingViewController new];
    makesureUsingVC.routeID = [NSString stringWithFormat:@"%@",model.myID];
    makesureUsingVC.whichWay = [NSString stringWithFormat:@"%@",model.route_name];
    [self.navigationController pushViewController:makesureUsingVC animated:YES];
}




#pragma mark -- 请求数据
- (void) addRefresh{

    _tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        self.page =1;
        [self getRoutesFromService];
    }];

    _tableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
        self.page++;
        [self getRoutesFromService];
    }];
    [_tableView.mj_header beginRefreshing];
}


- (void)getRoutesFromService{
    __weak typeof (self)weakSelf = self;
    [[BXHttpManager manager] POST:@"http://www.baixinxueche.com/index.php/Home/Apitokenptchoose/listRoute" parameters:[NSString stringWithFormat:@"page=%d",self.page] Success:^(id responseObject) {
        [weakSelf.tableView.mj_header endRefreshing];
        [weakSelf.tableView.mj_footer endRefreshing];
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:nil];
        if ([[NSString stringWithFormat:@"%@",dic[@"code"]] isEqualToString:@"200"]) {
            NSArray *array = dic[@"result"];
            if (weakSelf.page>1) {
                NSMutableArray *arrayM = [NSMutableArray arrayWithArray:weakSelf.routesArray];
                weakSelf.routesArray=nil;

                //作为展示的数组
                NSMutableArray *arrM = [NSMutableArray new];
                for (int i = 0;  i<array.count; i++) {
                    BXRoutesModel *model = [BXRoutesModel initWithDictionary:array[i]];
                    [arrM addObject:model];
                }
                [arrayM addObjectsFromArray:arrM];
                weakSelf.routesArray = arrayM;

            }else{
                weakSelf.routesArray = nil;
                for (int i = 0;  i<array.count; i++) {
                    BXRoutesModel *model = [BXRoutesModel initWithDictionary:array[i]];
                    [weakSelf.routesArray addObject:model];
                }
            }
            [weakSelf.tableView reloadData];
        }else{
            if (weakSelf.page>1) {
                [SVProgressHUD showErrorWithStatus:@"没有更多了!"];
                [weakSelf performSelector:@selector(dismissHUD) withObject:nil afterDelay:2];
            }else{
                [SVProgressHUD showErrorWithStatus:@"加载失败!"];
                [weakSelf performSelector:@selector(dismissHUD) withObject:nil afterDelay:2];
            }
        }

    } andFailure:^(NSError *error) {
        [weakSelf.tableView.mj_header endRefreshing];
        [weakSelf.tableView.mj_footer endRefreshing];

        [SVProgressHUD showErrorWithStatus:@"网络错误!"];
        [weakSelf performSelector:@selector(dismissHUD) withObject:nil afterDelay:2];
    }];
}

- (void)dismissHUD{
    [SVProgressHUD dismiss];
}




- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
