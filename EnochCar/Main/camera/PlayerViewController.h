//
//  PlayerViewController.h
//  EnochCar
//
//  Created by 王海燕 on 2021/7/23.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface PlayerViewController : UIViewController
-(instancetype)initWithUrl:(NSURL *)url;
-(void)showOn:(UIViewController*)viewCtrl;
@end

NS_ASSUME_NONNULL_END
