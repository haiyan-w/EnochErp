//
//  CommonTextField.m
//  EnochCar
//
//  Created by 王海燕 on 2021/5/18.
//

#import "CommonTextField.h"

@implementation CommonTextField

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (CGRect)textRectForBounds:(CGRect)bounds {
     return CGRectInset(bounds, 10.0, 2.0);
    
}


@end
