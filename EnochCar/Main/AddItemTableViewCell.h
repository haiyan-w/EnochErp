//
//  AddItemTableViewCell.h
//  EnochCar
//
//  Created by 王海燕 on 2021/5/12.
//

#import <UIKit/UIKit.h>
#import "DataItem.h"

NS_ASSUME_NONNULL_BEGIN

@interface AddItemTableViewCell : UITableViewCell

@property(nonatomic,readwrite,strong)UINavigationController * navigationController;

-(void)LayoutWithData:(DataItem*)data;
@end

NS_ASSUME_NONNULL_END
