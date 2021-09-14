//
//  SearchResultTableViewCell.m
//  EnochCar
//
//  Created by 王海燕 on 2021/5/24.
//

#import "SearchResultTableViewCell.h"
#import "CommonTool.h"

@interface SearchResultTableViewCell()

@property (strong, nonatomic) IBOutlet UILabel *nameLable;

@property (strong, nonatomic) IBOutlet UILabel *plateNoLable;
@property (strong, nonatomic) IBOutlet UILabel *vinLable;

@property (strong, nonatomic) IBOutlet UILabel *isOldLable;
@property (strong, nonatomic) IBOutlet UILabel *idBindlable;//是否绑定微信

@end


@implementation SearchResultTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
//    _isOldLable.backgroundColor = [UIColor colorWithRed:252/255.0 green:215/255.0 blue:139/255.0 alpha:1];
    _isOldLable.layer.cornerRadius = 10;
    _isOldLable.layer.masksToBounds = YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)configdata:(NSDictionary*)data
{
    NSString * plateNo = [data objectForKey:@"plateNo"];
    NSMutableAttributedString * plateNoAStr = [[NSMutableAttributedString alloc] initWithString:plateNo];
    NSRange range = [plateNo rangeOfString:_searchText options:NSCaseInsensitiveSearch];
    [plateNoAStr addAttribute:NSForegroundColorAttributeName value:[UIColor systemRedColor] range:range];
    _plateNoLable.attributedText = plateNoAStr;
    
    
    NSString * vin = [data objectForKey:@"vin"];
    NSMutableAttributedString * vinAStr = [[NSMutableAttributedString alloc] initWithString:vin];
    NSRange rangeVin = [vin rangeOfString:_searchText options:NSCaseInsensitiveSearch];
    [vinAStr addAttribute:NSForegroundColorAttributeName value:[UIColor systemRedColor] range:rangeVin];
    _vinLable.attributedText = vinAStr;
    
    NSString * name = [data objectForKey:@"ownerName"];
    NSMutableAttributedString * nameAStr = [[NSMutableAttributedString alloc] initWithString:name];
    NSRange rangeName = [name rangeOfString:_searchText options:NSCaseInsensitiveSearch];
    [nameAStr addAttribute:NSForegroundColorAttributeName value:[UIColor systemRedColor] range:rangeName];
    _nameLable.attributedText = nameAStr;

    _isOldLable.text = @"老客户";//搜索到的都是老客户
    
    //是否绑定微信
    if ([data objectForKey:@"wechatUnionId"]) {
        _idBindlable.text = @"已绑";
    }else {
        _idBindlable.text = @"未绑";
    }
}

@end
