//
//  BXChooseRouteModel.h
//  CoachClient
//
//  Created by apple on 2017/10/19.
//  Copyright © 2017年 baixinxueche. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BXChooseRouteModel : NSObject
/** 经纬度 */
@property (strong,nonatomic) NSString *lat_lon;
/** 该播报点的名称 */
@property (strong,nonatomic) NSString *name;
/** 该点的播报内容 */
@property (strong,nonatomic) NSString *content;
/** 该点对应的图片 */
@property (strong,nonatomic) NSString *pic;

+ (instancetype)initWithDic:(NSDictionary *)dic;
- (instancetype)initWithDic:(NSDictionary *)dic;
@end
