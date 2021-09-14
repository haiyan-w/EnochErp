//
//  PopMenuCell.m
//  PopMenu
//
//  Created by 王海燕 on 2021/5/20.
//

#import "PopMenuCell.h"

@implementation PopMenuCell

static NSString *ID = @"PopMenuCell";

+ (instancetype)cellWithTableView:(UITableView *)tableView
{
    PopMenuCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (cell == nil) {
        cell = [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass(self) owner:nil options:nil] lastObject];
    }
    return cell;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
