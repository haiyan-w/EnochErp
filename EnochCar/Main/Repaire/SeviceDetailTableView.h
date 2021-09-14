//
//  SeviceDetailTableView.h
//  EnochCar
//
//  Created by 王海燕 on 2021/6/8.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SeviceDetailTableView:UIView
-(void)configData:(NSDictionary*)data;
-(BOOL)haveSelected;
-(void)setGreyType:(BOOL)needgrey;
@end

NS_ASSUME_NONNULL_END
