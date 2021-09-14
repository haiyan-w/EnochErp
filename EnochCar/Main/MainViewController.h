//
//  MainViewController.h
//  EnochCar
//
//  Created by HAIYAN on 2021/5/7.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface MainViewController : BaseViewController

-(void)configData:(NSDictionary *)data;
-(void)saveLastSeviceInfo;
@end

NS_ASSUME_NONNULL_END
