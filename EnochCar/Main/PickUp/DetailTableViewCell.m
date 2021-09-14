//
//  DetailTableViewCell.m
//  EnochCar
//
//  Created by 王海燕 on 2021/6/1.
//

#import "DetailTableViewCell.h"

@interface DetailTableViewCell()
@property (strong, nonatomic) IBOutlet UILabel *nameLab;
@property (strong, nonatomic) IBOutlet UILabel *numLab;
@property (strong, nonatomic) IBOutlet UILabel *priceLab;
@property (assign, nonatomic) NSInteger index;
@end

@implementation DetailTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.selectionStyle = UITableViewCellSelectionStyleNone;
//    self.backgroundColor = [UIColor yellowColor];
//    self.layer.cornerRadius = 4;
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)deleteBtnClick:(id)sender {
    
    if ([self.delegate respondsToSelector:@selector(detailCell:deleteAtIndex:)]) {
        [self.delegate detailCell:self deleteAtIndex:_index];
    }
}

-(void)config:(NSDictionary*)data  withIndex:(NSInteger)index
{
    _index = index;
    _nameLab.text = [[[data objectForKey:@"goodsSpecification"] objectForKey:@"goods"] objectForKey:@"name"];
    _numLab.text = [NSString stringWithFormat:@"%@",[data objectForKey:@"planCount"]];
    float total = [[data objectForKey:@"planCount"] integerValue]* [[data objectForKey:@"price"] floatValue];
    _priceLab.text = [NSString stringWithFormat:@"%@",[NSNumber numberWithFloat:total]];
    _deleteBtn.tag = index;
}



@end
