//
//  MaintanceAndAccessoryViewController.h
//  EnochCar
//
//  Created by 王海燕 on 2021/5/31.
//

#import <UIKit/UIKit.h>
#import "CommonViewController.h"

@protocol MaintanceAndAccessoryDelegate <NSObject>

@required
-(void)save:(nonnull NSArray *)maintenances;

@end


NS_ASSUME_NONNULL_BEGIN

@interface MaintanceAndAccessoryViewController : CommonViewController
@property(nonatomic, readwrite, strong) id <MaintanceAndAccessoryDelegate> delegate;
-(instancetype)initWithData:(NSArray*)maintenances;
@end

NS_ASSUME_NONNULL_END
