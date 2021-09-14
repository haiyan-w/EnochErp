//
//  GoodsTableViewCell.h
//  EnochCar
//
//  Created by 王海燕 on 2021/5/18.
//

#import <UIKit/UIKit.h>

@class GoodsTableViewCell;

@protocol GoodsTableViewCellDelagate <NSObject>
@optional
-(void)tableviewCellBecomeFirstResponder:(CGRect)rect;
-(void)tableViewCell:(GoodsTableViewCell*)cell select:(BOOL)select;
@end

NS_ASSUME_NONNULL_BEGIN

@interface GoodsTableViewCell : UITableViewCell
@property(nonatomic,readwrite,strong)UINavigationController * navigationController;
@property (weak, nonatomic)id <GoodsTableViewCellDelagate>delagate;
@property(nonatomic, readwrite, copy) NSMutableArray * chargeMethods;
-(void)setNeedExtand:(BOOL)needExtand;
-(void)config:(NSDictionary *)data;

@end

NS_ASSUME_NONNULL_END
