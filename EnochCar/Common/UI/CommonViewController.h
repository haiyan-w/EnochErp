//
//  CustomViewController.h
//  EnochCar
//
//  Created by 王海燕 on 2021/5/13.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"


NS_ASSUME_NONNULL_BEGIN

@interface CommonViewController : BaseViewController
@property(nonatomic,readwrite,copy)NSString * midTitle;
//-(void)setTitle:(NSString *)title;
-(void)setRightBtn:(UIButton *)rightBtn;
-(void)showHint:(NSString *)message;
-(void)resign;
-(void)back;
@end

NS_ASSUME_NONNULL_END
