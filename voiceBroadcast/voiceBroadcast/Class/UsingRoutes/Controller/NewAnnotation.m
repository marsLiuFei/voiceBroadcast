//
//  NewAnnotation.m
//  CoachClient
//
//  Created by apple on 2017/11/7.
//  Copyright © 2017年 baixinxueche. All rights reserved.
//

#import "NewAnnotation.h"

@implementation NewAnnotation

- (instancetype)initWithAnnotation:(id<MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
    if (self) {

        //        在大头针旁边加一个label
        self.label = [[UILabel alloc]initWithFrame:CGRectMake(-40,-40,80, 20)];
        self.label.text = annotation.title;
        self.label.font = [UIFont systemFontOfSize:11];
        self.label.textColor = [UIColor orangeColor];
        self.label.backgroundColor = [UIColor whiteColor];
        self.label.textAlignment = NSTextAlignmentCenter;
        [self addSubview:self.label];

        UIImageView *myImageView = [[UIImageView alloc] initWithFrame:CGRectMake(-10,-20, 20, 26)];
        myImageView.image = [UIImage imageNamed:@"bubble_icon"];
        [self addSubview:myImageView];
    }
    return self;

}


@end
