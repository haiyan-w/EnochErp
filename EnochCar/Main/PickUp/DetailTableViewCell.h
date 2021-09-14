//
//  DetailTableViewCell.h
//  EnochCar
//
//  Created by 王海燕 on 2021/6/1.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class DetailTableViewCell;

@protocol DetailTableViewCellDelegate <NSObject>

-(void)detailCell:(DetailTableViewCell *)cell deleteAtIndex:(NSInteger)index;

@end


@interface DetailTableViewCell : UITableViewCell
@property (nonatomic, weak) id<DetailTableViewCellDelegate>delegate;
@property (weak, nonatomic) IBOutlet UIButton *deleteBtn;
-(void)config:(NSDictionary*)data withIndex:(NSInteger)index;
@end

NS_ASSUME_NONNULL_END
