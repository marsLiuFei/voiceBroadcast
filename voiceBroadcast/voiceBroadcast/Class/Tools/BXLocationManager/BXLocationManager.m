//
//  BXLocationManager.m
//  CoachClient
//
//  Created by apple on 2017/11/10.
//  Copyright © 2017年 baixinxueche. All rights reserved.
//

#import "BXLocationManager.h"
@interface BXLocationManager()

@end
static BXLocationManager *instance = nil;

@implementation BXLocationManager
+ (instancetype)manager{
    static  dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[BXLocationManager alloc] init];
    });
    return instance;
}
@end
