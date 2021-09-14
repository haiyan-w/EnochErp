//
//  PopMenuCell.h
//  PopMenu
//
//  Created by 王海燕 on 2021/5/20.
//

#import <UIKit/UIKit.h>

@interface PopMenuCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *labText;


+ (instancetype)cellWithTableView:(UITableView *)tableView;

@end
