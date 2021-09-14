//
//  SettlementView.h
//  EnochCar
//
//  Created by 王海燕 on 2021/5/20.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SettlementView : UIView
@property(nonatomic,readwrite,strong) UINavigationController * navCtrl;
-(void)loadData;
@end

NS_ASSUME_NONNULL_END
