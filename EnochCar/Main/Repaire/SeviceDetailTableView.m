//
//  SeviceDetailTableView.m
//  EnochCar
//
//  Created by 王海燕 on 2021/6/8.
//

#import "SeviceDetailTableView.h"

@interface SeviceDetailTableView()
@property (strong, nonatomic) UILabel * nameLab;
@property (strong, nonatomic) UILabel * serialNoLab;
@property (strong, nonatomic) UILabel * priceLab;

@property (strong, nonatomic) UIButton *selectBtn;
@property (assign, nonatomic,readwrite) BOOL haveSelected;
@end

@implementation SeviceDetailTableView
@synthesize haveSelected = _haveSelected;

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame: frame];
    if (self) {
        _nameLab = [[UILabel alloc] initWithFrame:CGRectMake(12, 4, 72, 18)];
        _nameLab.textColor = [UIColor colorWithRed:89/255.0 green:156/255.0 blue:255/255.0 alpha:1];
        _nameLab.font = [UIFont boldSystemFontOfSize:12];
        [self addSubview:_nameLab];
        
        _serialNoLab = [[UILabel alloc] initWithFrame:CGRectMake((_nameLab.frame.origin.x+_nameLab.frame.size.width +12), _nameLab.frame.origin.y,  150, 18)];
        _serialNoLab.textColor = [UIColor colorWithRed:89/255.0 green:156/255.0 blue:255/255.0 alpha:1];
        _serialNoLab.font = [UIFont fontWithName:@"PingFang SC" size:12];
        [self addSubview:_serialNoLab];
        
        _selectBtn = [[UIButton alloc] initWithFrame:CGRectMake((frame.size.width - 40 - 12), (frame.size.height-40)/2, 40, 40)];
        [_selectBtn addTarget:self action:@selector(selectBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        
        [self addSubview:_selectBtn];
        
        _priceLab = [[UILabel alloc] initWithFrame:CGRectMake(_nameLab.frame.origin.x, (_nameLab.frame.origin.y+_nameLab.frame.size.height +12), 200, 18)];
        _priceLab.textColor = [UIColor colorWithRed:2/255.0 green:2/255.0 blue:2/255.0 alpha:1];
        _priceLab.font = [UIFont fontWithName:@"PingFang SC" size:12];
        _priceLab.text = @"199";
        [self addSubview:_priceLab];
        
        self.haveSelected = NO;
    }
    return self;
    
}

-(void)setGreyType:(BOOL)needgrey
{
    if (needgrey) {
        self.haveSelected = YES;
        [_selectBtn setImage:[UIImage imageNamed:@"select_gray"] forState:UIControlStateNormal];
        _selectBtn.enabled = NO;
    }
}


- (void)selectBtnClick:(id)sender {
    self.haveSelected = !_haveSelected;
}

-(void)setHaveSelected:(BOOL)haveSelected
{
    _haveSelected = haveSelected;
    if (_haveSelected) {
        [_selectBtn setImage:[UIImage imageNamed:@"select"] forState:UIControlStateNormal];
    }else {
        [_selectBtn setImage:[UIImage imageNamed:@"deselect"] forState:UIControlStateNormal];
    }
}

-(BOOL)haveSelected
{
    return _haveSelected;
}


-(void)configData:(NSDictionary*)data
{
    _nameLab.text = [data objectForKey:@"name"];
    _serialNoLab.text = [[data objectForKey:@"maintenance"] objectForKey:@"serialNo"];
    _priceLab.text = [NSString stringWithFormat:@"%.2f(含折扣)",[[data objectForKey:@"amount"] floatValue]];
}

@end
