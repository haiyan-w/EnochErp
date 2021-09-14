//
//  AccessoryViewController.h
//  EnochCar
//
//  Created by 王海燕 on 2021/5/12.
//

#import <UIKit/UIKit.h>
#import "CommonViewController.h"


@protocol AccessoryViewControllerDelegate <NSObject>

-(void)save:(NSArray *)goods;

@end

NS_ASSUME_NONNULL_BEGIN

@interface AccessoryViewController : CommonViewController
@property (weak, nonatomic)id <AccessoryViewControllerDelegate>delegate;
@property (strong, nonatomic)NSMutableDictionary * curmaintance;
@property(nonatomic, readwrite, copy) NSMutableArray * chargeMethods;

-(instancetype)initWithData:(NSArray *)goods;
//-(void)configData:(NSArray *)goods;
@end

NS_ASSUME_NONNULL_END
