//
//  BlackLabel.m
//  EnochCar
//
//  Created by 王海燕 on 2021/7/27.
//

#import "BlackLabel.h"

@implementation BlackLabel

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1];
        self.layer.cornerRadius = 4;
        self.layer.masksToBounds = YES;
        self.textColor = [UIColor whiteColor];
        self.font = [UIFont systemFontOfSize:16 weight:UIFontWeightSemibold];
        self.textAlignment = NSTextAlignmentCenter;
        
    }
    return self;
}

@end
