//
//  BXRoutesModel.h
//  voiceBroadcast
//
//  Created by apple on 2017/11/13.
//  Copyright © 2017年 baixinxueche. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BXRoutesModel : NSObject
@property (strong,nonatomic) NSString *myID;
@property (strong,nonatomic) NSString *name;
@property (strong,nonatomic) NSString *route_name;

/** 字典转模型 */
+(instancetype)initWithDictionary:(NSDictionary*)dic;

-(instancetype)initWithDictionaty:(NSDictionary*)dic;
@end
