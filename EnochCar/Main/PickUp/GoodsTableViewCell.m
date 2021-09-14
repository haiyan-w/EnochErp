//
//  GoodsTableViewCell.m
//  EnochCar
//
//  Created by 王海燕 on 2021/5/18.
//

#import "GoodsTableViewCell.h"
#import "NSNumber+Common.h"


@interface GoodsTableViewCell()
@property (strong, nonatomic) IBOutlet UIView *bgView;
@property (strong, nonatomic) IBOutlet UILabel *namelab;
@property (strong, nonatomic) IBOutlet UILabel *priceLab;
@property (strong, nonatomic) IBOutlet UILabel *numLab;
@property (strong, nonatomic) IBOutlet UILabel *OELab;

@property (strong, nonatomic)NSMutableDictionary * curGood;
@end


@implementation GoodsTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.bgView.layer.cornerRadius = 4;
}

-(void)config:(NSDictionary *)data
{
    _curGood = data;
    
    NSNumber * num = [_curGood objectForKey:@"count"];
    if (num) {
        _numLab.text = [NSString stringWithFormat:@"数量：%@",num];
    }else {
        _numLab.text = @"数量：0";
    }
    
    NSNumber * price = [_curGood objectForKey:@"price"];
    NSString * priceStr = @"¥0.00";
    if (price) {
//        _priceLab.text = [NSString stringWithFormat:@"¥%@",[price DoubleStringValueWithDigits:2]];
        priceStr = [NSString stringWithFormat:@"¥%.2f",price.floatValue];
    }
    NSRange priceRange1 = [priceStr rangeOfString:@"¥"];
    NSRange priceRange2 = [priceStr rangeOfString:@"."];
    NSMutableAttributedString * priceAttrString = [[NSMutableAttributedString alloc] initWithString:priceStr];
    [priceAttrString addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:12 weight:UIFontWeightMedium] range:priceRange1];
    [priceAttrString addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:16 weight:UIFontWeightMedium] range:NSMakeRange(priceRange1.location+1, priceRange2.location - priceRange1.location)];
    _priceLab.attributedText = priceAttrString;
    
    NSDictionary * agood = [[_curGood objectForKey:@"goodsSpecification"] objectForKey:@"goods"];
    NSString * nameStr = [agood objectForKey:@"name"];
    NSString * serialNoStr = [agood objectForKey:@"serialNo"];
    NSString * nameSNString = [NSString stringWithFormat:@"%@(%@)",nameStr,serialNoStr];
    NSRange range1 = [nameSNString rangeOfString:nameStr];
    NSRange range2 = [nameSNString rangeOfString:[NSString stringWithFormat:@"(%@)",serialNoStr]];
    
    NSMutableAttributedString * attrString = [[NSMutableAttributedString alloc] initWithString:nameSNString];
    [attrString addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:16 weight:UIFontWeightMedium] range:range1];
    [attrString addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:12] range:range2];
    _namelab.attributedText = attrString;
    NSString * oemStr = [_curGood objectForKey:@"oem"];
    if ((oemStr) && (oemStr.length > 0)) {
        _OELab.text = [NSString stringWithFormat:@"OE号：%@",[_curGood objectForKey:@"oem"]];
    }else {
        _OELab.text = @"";
    }
}



- (BOOL)validateFloatNumber:(NSString*)number {
    BOOL res = YES;
    NSCharacterSet* tmpSet = [NSCharacterSet characterSetWithCharactersInString:@"0123456789."];
    int i = 0;
    while (i < number.length) {
        NSString * string = [number substringWithRange:NSMakeRange(i, 1)];
        NSRange range = [string rangeOfCharacterFromSet:tmpSet];
        if (range.length == 0) {
            res = NO;
            break;
        }
        i++;
    }
    return res;
}


@end
