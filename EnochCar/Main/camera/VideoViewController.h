//
//  VideoViewController.h
//  EnochCar
//
//  Created by HAIYAN on 2021/5/7.

#import <UIKit/UIKit.h>

typedef void(^TakeOperationSureBlock)(id item);

@interface VideoViewController : UIViewController

@property (copy, nonatomic) TakeOperationSureBlock takeBlock;

//可录制最长时间
@property (assign, nonatomic) NSInteger HSeconds;

@end
