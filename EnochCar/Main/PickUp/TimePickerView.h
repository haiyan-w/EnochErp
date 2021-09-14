//
//  TimePickerView.h
//  EnochCar
//
//  Created by 王海燕 on 2021/8/30.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class TimePickerViewController;

@protocol TimePickerDelegate <NSObject>

-(void)timePicker:(TimePickerViewController*)picker selectTime:(NSString*)timeString;

@end

@interface TimePickerViewController : UIViewController
@property (nonatomic,weak) id<TimePickerDelegate> delegate;
@property (nonatomic,assign) NSUInteger tag;
-(void)showIn:(UIViewController *)viewCtrl;

@end

NS_ASSUME_NONNULL_END
