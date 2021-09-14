//
//  LineProgressView.m
//  EnochCar
//
//  Created by 王海燕 on 2021/7/23.
//

#import "LineProgressView.h"

@interface LineProgressView()<UIGestureRecognizerDelegate>


@end

@implementation LineProgressView

-(void)awakeFromNib
{
    [super awakeFromNib];
    self.maximumTrackTintColor = [UIColor lightGrayColor];
    self.minimumTrackTintColor = [UIColor whiteColor];
    [self setThumbImage:[UIImage imageNamed:@"thumb"] forState:UIControlStateNormal];
    self.maximumValue = 1;
    self.minimumValue = 0;
}

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
    }
    return self;
}


-(BOOL)isPoint:(CGPoint)pt inRect:(CGRect)rect
{
    if ((pt.x >= rect.origin.x) && (pt.x <= (rect.origin.x + rect.size.width))&&(pt.y >= rect.origin.y) && (pt.y <= (rect.origin.y + rect.size.height))) {
        return YES;
    }
    return NO;
}

@end
