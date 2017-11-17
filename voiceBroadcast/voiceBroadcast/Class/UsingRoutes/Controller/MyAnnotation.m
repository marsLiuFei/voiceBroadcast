//
//  MyAnnotation.m
//  CoachClient
//
//  Created by apple on 2017/10/19.
//  Copyright © 2017年 baixinxueche. All rights reserved.
//

#import "MyAnnotation.h"

@implementation MyAnnotation
-(id)initWithCoordinates:(CLLocationCoordinate2D)paramCoordinates title:(NSString *)paramTitle
                subTitle:(NSString *)paramSubitle
{
    self = [super init];
    if(self != nil)
    {
        _coordinate = paramCoordinates;
        _title = paramTitle;
        _subtitle = paramSubitle;
    }
    return self;
}
@end
