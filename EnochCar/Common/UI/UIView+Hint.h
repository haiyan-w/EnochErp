//
//  UIView+Hint.h
//  EnochCar
//
//  Created by 王海燕 on 2021/6/21.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIView (Hint)

-(void)showHint:(NSString *)message;

-(void)showAlertWithTitle:(NSString*)title message:(NSString*)message;

@end

NS_ASSUME_NONNULL_END
