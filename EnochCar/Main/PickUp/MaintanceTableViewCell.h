//
//  MaintanceTableViewCell.h
//  EnochCar
//
//  Created by 王海燕 on 2021/6/1.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN


@class MaintanceTableViewCell;
@protocol MaintanceTableViewCellDelegate <UITextFieldDelegate>

@optional
-(void)tableviewcellBecomeFirstResponder:(CGRect)rect;
-(void)tableviewcell:(MaintanceTableViewCell*)cell needExtend:(BOOL)isExtend;
-(void)tableviewcell:(MaintanceTableViewCell*)cell didDeleteAtIndex:(NSInteger)index;
@end

@interface MaintanceTableViewCell : UITableViewCell
@property(nonatomic,readwrite,strong)UINavigationController * navigationController;
@property(nonatomic,readwrite,strong)UITableView * tableview;
//@property(nonatomic, readwrite, copy) NSMutableArray * maintances;//查询到的项目列表
@property(nonatomic, readwrite, copy) NSMutableArray * workingteams;
@property(nonatomic, readwrite, copy) NSMutableArray * chargeMethods;
@property (weak, nonatomic)id <MaintanceTableViewCellDelegate>delagate;
@property (assign, nonatomic)NSInteger index;
-(BOOL)isExtend;

//-(void)config:(NSDictionary*)data;
-(void)setCurMaintance:(NSMutableDictionary *)curMaintance;
@end

NS_ASSUME_NONNULL_END
