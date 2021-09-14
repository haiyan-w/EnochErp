//
//  RecordListTableViewCell.m
//  EnochCar
//
//  Created by 王海燕 on 2021/6/11.
//

#import "RecordListTableViewCell.h"


@interface RecordListTableViewCell()
@property (strong, nonatomic) IBOutlet UILabel *nameLab;
@property (strong, nonatomic) IBOutlet UILabel *plateNoLab;
@property (strong, nonatomic) IBOutlet UILabel *vinLab;
@property (weak, nonatomic) IBOutlet UIView *bgView;

@end

@implementation RecordListTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.backgroundColor = [UIColor clearColor];
    self.selectionStyle = UITableViewCellSeparatorStyleNone;
    self.bgView.layer.cornerRadius = 4;
}



- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setFrame:(CGRect)frame{
    if (self.frame.size.height != frame.size.height) {
        frame.origin.y += 24;
        frame.size.height -= 24;
    }
    [super setFrame:frame];
}

-(void)configData:(NSDictionary*)data
{
    NSInteger type = [[data objectForKey:@"type"] integerValue];
    NSString * name = @"***";
    NSString * plateNo = @"******";
    NSString * vin = @"*****************";
    switch (type) {
        case RecognizeTypePlateNO:
        {
            plateNo = [data objectForKey:@"plateNo"];
        }
            break;
        case RecognizeTypeDrivingLicence:
        {
            name = [data objectForKey:@"name"];
            plateNo = [data objectForKey:@"plateNo"];
            vin = [data objectForKey:@"vin"];
            
        }
            break;
        case RecognizeTypeVIN:
        {
            vin = [data objectForKey:@"vin"];
        }
            break;
            
        default:
            break;
    }
    
    self.nameLab.text = name;
    self.plateNoLab.text = plateNo;
    self.vinLab.text = vin;
}

@end
