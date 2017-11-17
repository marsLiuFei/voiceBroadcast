//
//  LFMainViewController.m
//  voiceBroadcast
//
//  Created by apple on 2017/11/13.
//  Copyright © 2017年 baixinxueche. All rights reserved.
//

#import "LFMainViewController.h"
#import "LFCreatRoutesViewController.h"
#import "LFUsingRoutesViewController.h"

@interface LFMainViewController ()

@end

@implementation LFMainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"语音播报";
}
- (IBAction)alertBtnClick:(UIButton *)sender {
    LFActionSheet *sheet =[LFActionSheet lf_actionSheetViewWithTitle:@"请选择" cancelTitle:@"取消" destructiveTitle:@"" otherTitles:@[@"创建线路",@"已有线路"] otherImages:nil selectSheetBlock:^(LFActionSheet *actionSheet, NSInteger index) {
        switch (index) {
            case 0:
                //创建线路
                [self.navigationController pushViewController:[LFCreatRoutesViewController new] animated:YES];
                break;
            case 1:
                //已有路线
                [self.navigationController pushViewController:[LFUsingRoutesViewController new] animated:YES];
                break;
            default:
                break;
        }
    }];
    [sheet show];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
