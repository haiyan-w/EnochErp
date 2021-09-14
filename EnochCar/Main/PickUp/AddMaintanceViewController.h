//
//  AddMaintanceViewController.h
//  EnochCar
//
//  Created by 王海燕 on 2021/5/31.
//

#import "CommonViewController.h"

NS_ASSUME_NONNULL_BEGIN


@protocol EditMaintanceDelegate <NSObject>

@required
-(void)changeMaintenance:(nonnull NSMutableDictionary *)maintenance;

@end

@interface AddMaintanceViewController : CommonViewController
@property(nonatomic, readwrite, strong) id <EditMaintanceDelegate> delegate;


-(instancetype)initWithData:(NSMutableDictionary *)data;
@end

NS_ASSUME_NONNULL_END
