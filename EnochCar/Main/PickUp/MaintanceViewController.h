//
//  MaintanceViewController.h
//  EnochCar
//
//  Created by 王海燕 on 2021/5/12.
//

#import <UIKit/UIKit.h>
#import "CommonViewController.h"

@protocol MaintanceDelegate <NSObject>

@required
-(void)select:( NSDictionary *)maintance;

@end


NS_ASSUME_NONNULL_BEGIN

@interface MaintanceViewController : CommonViewController
@property(nonatomic, readwrite, strong) id <MaintanceDelegate> delegate;


@end

NS_ASSUME_NONNULL_END
