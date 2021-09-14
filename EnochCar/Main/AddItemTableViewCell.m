//
//  AddItemTableViewCell.m
//  EnochCar
//
//  Created by 王海燕 on 2021/5/12.
//

#import "AddItemTableViewCell.h"
#import "AccessoryViewController.h"
#import "CommonTextField.h"

@interface AddItemTableViewCell()<UITextFieldDelegate>
@property(nonatomic, readwrite,strong)UILabel * label;
@property(nonatomic, readwrite,strong)UIButton * chargeTypeBtn;
@property(nonatomic, readwrite,strong)UIButton * addAccessoryBtn;//添加配件按钮
@property(nonatomic, readwrite,strong)UITextField * itemnameTF;
@property(nonatomic, readwrite,strong)UITextField * teamTF;
@property(nonatomic, readwrite,strong)UITextField * technicianTF;
@property(nonatomic, readwrite,strong)NSData * data;
@end


@implementation AddItemTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
}

-(instancetype)init
{
    self = [super init];
    if (self) {
        
    }
    
    return self;
}

-(void)LayoutWithData:(DataItem*)data
{
    
    self.backgroundColor = [UIColor colorWithRed:242/255.0 green:242/255.0 blue:242/255.0 alpha:1];
    NSInteger left = 12;
    NSInteger top = 12;
    
    UIView * bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, 207)];
    bgView.backgroundColor = [UIColor lightGrayColor];
    [self addSubview:bgView];
    
    _label = [[UILabel alloc] initWithFrame:CGRectMake(left, top, 42, 22)];
    _label.backgroundColor = [UIColor clearColor];
    _label.text = @"项目1";
    _label.font = [UIFont fontWithName:@"PingFang SC" size:16];
    [bgView addSubview:_label];
    
    _chargeTypeBtn = [[UIButton alloc] initWithFrame:CGRectMake(66, 12, 38, 24)];
    _chargeTypeBtn.backgroundColor = [UIColor clearColor];
    [_chargeTypeBtn setTitle:data.type forState:UIControlStateNormal];
    _chargeTypeBtn.titleLabel.font = [UIFont fontWithName:@"PingFang SC" size:14];
    [bgView addSubview:_chargeTypeBtn];
    
    _addAccessoryBtn = [[UIButton alloc] initWithFrame:CGRectMake(263, 12, 60, 24)];
    _addAccessoryBtn.backgroundColor = [UIColor clearColor];
    [_addAccessoryBtn setTitle:@"添加配件" forState:UIControlStateNormal];
    _addAccessoryBtn.titleLabel.font = [UIFont fontWithName:@"PingFang SC" size:14];
    [_addAccessoryBtn addTarget:self action:@selector(addAccessory) forControlEvents:UIControlEventTouchUpInside];
    [bgView addSubview:_addAccessoryBtn];
    
    _itemnameTF = [[CommonTextField alloc] initWithFrame:CGRectMake(12, 48, 311, 36)];
    _itemnameTF.placeholder = @"输入或选择";
    _itemnameTF.backgroundColor = [UIColor whiteColor];
    _itemnameTF.font = [UIFont fontWithName:@"PingFang SC" size:12];
    _itemnameTF.layer.cornerRadius = 4;
    [_itemnameTF setDelegate:self];
    CGRect rc = CGRectMake(left, 0, (_itemnameTF.frame.size.width - 2*left), _itemnameTF.frame.size.height);
    [_itemnameTF textRectForBounds:rc];
    [_itemnameTF placeholderRectForBounds:rc];
    UIImageView * rightView = [[UIImageView alloc] initWithFrame:CGRectMake(_itemnameTF.bounds.size.width - 24, (_itemnameTF.bounds.size.height-24)/2, 24, 24)];
    [rightView setImage:[UIImage imageNamed:@"dropdown"]];
    _itemnameTF.rightView = rightView;
    [bgView addSubview:_itemnameTF];
    
    _teamTF = [[UITextField alloc] initWithFrame:CGRectMake(12, 96, 149, 36)];
    _teamTF.placeholder = @"班组";
    _teamTF.backgroundColor = [UIColor whiteColor];
    _teamTF.font = [UIFont fontWithName:@"PingFang SC" size:12];
    _teamTF.layer.cornerRadius = 4;
    [_teamTF setDelegate:self];
    [bgView addSubview:_teamTF];
    
    _technicianTF = [[UITextField alloc] initWithFrame:CGRectMake(174, 96, 149, 36)];
    _technicianTF.placeholder = @"技师";
    _technicianTF.backgroundColor = [UIColor whiteColor];
    _technicianTF.font = [UIFont fontWithName:@"PingFang SC" size:12];
    _technicianTF.layer.cornerRadius = 4;
    [_technicianTF setDelegate:self];
    [bgView addSubview:_technicianTF];
    
    _data = data;
    

}

-(void)addAccessory
{
    AccessoryViewController * accessoryCtrl = [[AccessoryViewController alloc] init];
    
    [self.navigationController pushViewController:accessoryCtrl animated:YES];
    
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];//收起键盘
    return  YES;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
