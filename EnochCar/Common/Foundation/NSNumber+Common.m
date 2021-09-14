//
//  NSNumber+Common.m
//  EnochCar
//
//  Created by 王海燕 on 2021/7/1.
//

#import "NSNumber+Common.h"

@implementation NSNumber (Common)

- (NSString *)DoubleStringValueWithDigits:(NSUInteger)digits
{
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    formatter.numberStyle = NSNumberFormatterDecimalStyle;
    formatter.maximumFractionDigits = digits;
    [formatter setGroupingSeparator:@""];
    
    NSString *retString = [formatter stringFromNumber:self];
    return retString;
}

@end
