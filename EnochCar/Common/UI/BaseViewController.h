//
//  BaseViewController.h
//  EnochCar
//
//  Created by 王海燕 on 2021/7/28.
//

#import <UIKit/UIKit.h>
#import <AFNetworking/AFNetworking.h>


NS_ASSUME_NONNULL_BEGIN

@interface BaseViewController : UIViewController
@property(nonatomic,readwrite,assign) AFNetworkReachabilityStatus netStatus;
@property(nonatomic,readwrite,assign) BOOL isNetworkOn;
-(void)networkStatusChanged:(AFNetworkReachabilityStatus)status;
@end

NS_ASSUME_NONNULL_END
