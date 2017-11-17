//
//  BXButton.m
//  CoachClient
//
//  Created by apple on 2017/10/25.
//  Copyright © 2017年 baixinxueche. All rights reserved.
//

#import "BXButton.h"

@implementation BXButton


- (void)drawRect:(CGRect)rect {
    self.layer.masksToBounds = YES;
    self.layer.cornerRadius = rect.size.height*0.5;
}


@end
