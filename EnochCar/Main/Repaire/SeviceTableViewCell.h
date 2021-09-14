//
//  SeviceTableViewCell.h
//  EnochCar
//
//  Created by 王海燕 on 2021/5/21.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

//通过该字段判断有没有获取过工单详情
#define SEVICE_DETAIL @"seviceDetail"

@class SeviceTableViewCell;

@protocol SeviceTableViewCellDelagate <NSObject>
@optional
-(void)tableViewCell:(SeviceTableViewCell*)cell update:(BOOL)update;
@end


@interface SeviceTableViewCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UILabel *serialNoLab;
@property (strong, nonatomic) IBOutlet UILabel *enterDateLab;
@property (strong, nonatomic) IBOutlet UILabel *plateNoLab;
@property (strong, nonatomic) IBOutlet UILabel *nameAndCellphoneLab;
@property (strong, nonatomic) IBOutlet UILabel *totalCostLab;
@property (strong, nonatomic) IBOutlet UILabel *serviceStateLab;
@property (strong, nonatomic) IBOutlet UIButton *categoryBtn;

@property (strong, nonatomic) id <SeviceTableViewCellDelagate> delegate;
//@property (strong, nonatomic) UIViewController *viewCtrl;
@property(nonatomic,readwrite,strong) UINavigationController * navCtrl;

//query接口获取数据
-(void)configData:(NSMutableDictionary*)data;

////工单详情
//-(void)setupData:(NSDictionary*)data;

-(void)expand:(BOOL)expand;
@end

NS_ASSUME_NONNULL_END
