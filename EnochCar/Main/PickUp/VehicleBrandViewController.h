//
//  VehicleBrandViewController.h
//  EnochCar
//
//  Created by HAIYAN on 2021/6/2.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN


@protocol VehicleBrandViewControllerDelegate <NSObject>

-(void)disSelectModel:(NSArray *)model;

@end

@interface VehicleBrandViewController : UIViewController
@property(nonatomic, weak)id <VehicleBrandViewControllerDelegate> delegate;

-(instancetype)initWithBrands:(NSArray *)brands;
@end

NS_ASSUME_NONNULL_END
