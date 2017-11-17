//
//  BXChooseRouteModel.m
//  CoachClient
//
//  Created by apple on 2017/10/19.
//  Copyright © 2017年 baixinxueche. All rights reserved.
//

#import "BXChooseRouteModel.h"

@implementation BXChooseRouteModel
+ (instancetype)initWithDic:(NSDictionary *)dic{
    return [[BXChooseRouteModel alloc] initWithDic:dic];
}
- (instancetype)initWithDic:(NSDictionary *)dic{
    if (self = [super init]) {
        self.lat_lon = dic[@"lat_lon"];
        self.name    = dic[@"name"];
        self.content = dic[@"content"];
        self.pic     = dic[@"pic"];
    }
    return self;
}
@end
