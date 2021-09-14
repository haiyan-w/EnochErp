//
//  GoodsSearchTableViewCell.m
//  EnochCar
//
//  Created by 王海燕 on 2021/5/31.
//

#import "GoodsSearchTableViewCell.h"


@interface GoodsSearchTableViewCell()
@property (strong, nonatomic) IBOutlet UILabel *nameLab;
@property (strong, nonatomic) IBOutlet UILabel *detailLab;

@end


@implementation GoodsSearchTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)config:(NSDictionary *)data
{
    _nameLab.text = [data objectForKey:@"name"];
    _detailLab.text = [data objectForKey:@"serialNo"];
    //@"serialNo" : @"SPC20222929292"    @"oem" : @"OE23244242424"
    
}
@end
