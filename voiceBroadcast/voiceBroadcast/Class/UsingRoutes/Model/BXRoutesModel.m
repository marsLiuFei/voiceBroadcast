//
//  BXRoutesModel.m
//  voiceBroadcast
//
//  Created by apple on 2017/11/13.
//  Copyright © 2017年 baixinxueche. All rights reserved.
//

#import "BXRoutesModel.h"

@implementation BXRoutesModel
-(instancetype)initWithDictionaty:(NSDictionary *)dic
{
    if (self=[super init]) {
        self.myID           =   dic[@"id"];
        self.name           =   dic[@"name"];
        self.route_name     =   dic[@"route_name"];

    }
    return self;
}
+(instancetype)initWithDictionary:(NSDictionary *)dic
{
    return [[BXRoutesModel alloc]initWithDictionaty:dic];
}
@end
