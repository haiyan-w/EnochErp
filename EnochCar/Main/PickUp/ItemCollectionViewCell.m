//
//  ItemCollectionViewCell.m
//  EnochCar
//
//  Created by 王海燕 on 2021/5/18.
//

#import "ItemCollectionViewCell.h"
#import "PopViewController.h"
#import "AccessoryViewController.h"
#import "NetWorkAPIManager.h"
#import "MaintanceViewController.h"


#define TAG_POPVIEW_CHARGEMETHOD  51
#define TAG_POPVIEW_MAINTANCENAME  52
#define TAG_POPVIEW_WORKINGTEAM  53
#define TAG_POPVIEW_ENGINEER  54

@interface ItemCollectionViewCell()<UITextFieldDelegate,PopViewDelagate>
@property(nonatomic, readwrite,strong)UIButton  * nameBtn;
@property(nonatomic, readwrite,strong)UIButton * chargeTypeBtn;
@property(nonatomic, readwrite,strong)UIButton * addAccessoryBtn;//添加配件按钮
@property(nonatomic, readwrite,strong)UITextField * hourTF;
@property(nonatomic, readwrite,strong)UITextField * priceTF;
@property(nonatomic, readwrite,strong)UITextField * discountTF;

//@property(nonatomic,strong)NSMutableDictionary * curMaintance;
@property(nonatomic, readwrite, strong) NSMutableArray * engineers;//先选择班组才有技师列表
@property(nonatomic, readwrite, strong) NSMutableArray * curEngineers;//当前已选择技师，可多选

@property(nonatomic,readwrite,assign)BOOL hideDetail;
@end

@implementation ItemCollectionViewCell

-(void)LayoutWithData:(NSMutableDictionary*)data index:(NSInteger)index
{
    _curMaintance = data;
    
    NSInteger left = 12;
    NSInteger top = 12;
    NSInteger space = 12;
    _nameBtn = [[UIButton alloc] initWithFrame:CGRectMake(left, top, 80, 22)];
    _nameBtn.backgroundColor = [UIColor clearColor];
    [_nameBtn setTitle:[_curMaintance objectForKey:@"name"] forState:UIControlStateNormal];
    
    _nameBtn.titleLabel.font = [UIFont fontWithName:@"PingFang SC" size:16];
    [_nameBtn setTitleColor:[UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1] forState:UIControlStateNormal];
    [_nameBtn addTarget:self action:@selector(addItem:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_nameBtn];
    
    _chargeTypeBtn = [[UIButton alloc] initWithFrame:CGRectMake((_nameBtn.bounds.size.width + left + space), 14, 60, 20)];
    _chargeTypeBtn.backgroundColor = [UIColor colorWithRed:233/255.0 green:236/255.0 blue:241/255.0 alpha:1];
    [_chargeTypeBtn setTitle:[[data objectForKey:@"chargingMethod"] objectForKey:@"message"] forState:UIControlStateNormal];
    [_chargeTypeBtn setTitleColor:[UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1] forState:UIControlStateNormal];
    _chargeTypeBtn.titleLabel.font = [UIFont fontWithName:@"PingFang SC" size:11];
    [_chargeTypeBtn addTarget:self action:@selector(selectChargeMethod) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_chargeTypeBtn];
    
    _addAccessoryBtn = [[UIButton alloc] initWithFrame:CGRectMake((self.bounds.size.width - 60 - space), 14, 60, 20)];
    _addAccessoryBtn.backgroundColor = [UIColor colorWithRed:233/255.0 green:236/255.0 blue:241/255.0 alpha:1];
    [_addAccessoryBtn setTitle:@"添加配件" forState:UIControlStateNormal];
    [_addAccessoryBtn setTitleColor:[UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1] forState:UIControlStateNormal];
    _addAccessoryBtn.titleLabel.font = [UIFont fontWithName:@"PingFang SC" size:11];
    [_addAccessoryBtn addTarget:self action:@selector(addAccessory) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_addAccessoryBtn];
    
    NSInteger width = (self.bounds.size.width - 3*space )/2;
    NSInteger height = 36;
    
    UIView * workingTeamView = [[UIView alloc] initWithFrame:CGRectMake(left, 48, width, height)];
    UILabel * teamLab = [[UILabel alloc] initWithFrame:CGRectMake(space, 0, (width - space - 36), height)];
    teamLab.text = @"班组";
    teamLab.textColor = [UIColor colorWithRed:191/255.0 green:191/255.0 blue:191/255.0 alpha:1];
    teamLab.font = [UIFont fontWithName:@"PingFang SC" size:12];
    [workingTeamView addSubview:teamLab];
    UIImageView * dropImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"dropdown"]];
    [dropImage setFrame:CGRectMake(width - 24-12, 6, 12, 12)];
    [workingTeamView addSubview:dropImage];
    UIButton * teambtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, width, height)];
    [teambtn addTarget:self action:@selector(selectWorkingTeam) forControlEvents:UIControlEventTouchUpInside];
    teambtn.layer.cornerRadius = 4;
    teambtn.layer.borderWidth = 1;
    teambtn.layer.borderColor = [UIColor colorWithRed:191/255.0 green:191/255.0 blue:191/255.0 alpha:1].CGColor;
    [workingTeamView addSubview:teambtn];
    [self addSubview:workingTeamView];
    
    UIView * engineerView = [[UIView alloc] initWithFrame:CGRectMake(2*left+width, 48, width, height)];
    UILabel * engineerLab = [[UILabel alloc] initWithFrame:CGRectMake(space, 0, (width - space - 36), height)];
    engineerLab.text = @"技师";
    engineerLab.textColor = [UIColor colorWithRed:191/255.0 green:191/255.0 blue:191/255.0 alpha:1];
    engineerLab.font = [UIFont fontWithName:@"PingFang SC" size:12];
    [engineerView addSubview:engineerLab];
    UIImageView * dropImage2 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"dropdown"]];
    [dropImage2 setFrame:CGRectMake(width - 24-12, 6, 12, 12)];
    [engineerView addSubview:dropImage2];
    UIButton * engineerbtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, width, height)];
    [engineerbtn addTarget:self action:@selector(selectEngineers) forControlEvents:UIControlEventTouchUpInside];
    engineerbtn.layer.cornerRadius = 4;
    engineerbtn.layer.borderWidth = 1;
    engineerbtn.layer.borderColor = [UIColor colorWithRed:191/255.0 green:191/255.0 blue:191/255.0 alpha:1].CGColor;
    [engineerView addSubview:engineerbtn];
    [self addSubview:engineerView];
    
    width = (self.bounds.size.width - 4*space )/3;
    NSInteger labW = 28;
    UILabel * hourLab = [[UILabel alloc] initWithFrame:CGRectMake(left, 98, labW, 18)];
    hourLab.text = @"工时:";
    hourLab.textColor = [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1];
    hourLab.font = [UIFont fontWithName:@"PingFang SC" size:12];
    [self addSubview:hourLab];
    _hourTF = [[UITextField alloc] initWithFrame:CGRectMake(left+labW, 98, 60, 18)];
    _hourTF.placeholder = @"输入";
    _hourTF.textColor = [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1];
    _hourTF.font = [UIFont fontWithName:@"PingFang SC" size:12];
    [self addSubview:_hourTF];
    
    UILabel * priceLab = [[UILabel alloc] initWithFrame:CGRectMake(2*left+width, 98, labW, 18)];
    priceLab.text = @"单价:";
    priceLab.textColor = [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1];
    priceLab.font = [UIFont fontWithName:@"PingFang SC" size:12];
    [self addSubview:priceLab];
    _priceTF= [[UITextField alloc] initWithFrame:CGRectMake(2*left+width+labW, 98, 60, 18)];
    _priceTF.placeholder = @"输入";
    _priceTF.textColor = [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1];
    _priceTF.font = [UIFont fontWithName:@"PingFang SC" size:12];
    [self addSubview:_priceTF];
    
    UILabel * discountLab = [[UILabel alloc] initWithFrame:CGRectMake(3*left+2*width, 98, labW, 18)];
    discountLab.text = @"折扣:";
    discountLab.textColor = [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1];
    discountLab.font = [UIFont fontWithName:@"PingFang SC" size:12];
    [self addSubview:discountLab];
    _discountTF= [[UITextField alloc] initWithFrame:CGRectMake(3*left+2*width+labW, 98, 60, 18)];
    _discountTF.placeholder = @"输入";
    _discountTF.textColor = [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1];
    _discountTF.font = [UIFont fontWithName:@"PingFang SC" size:12];
    [self addSubview:_discountTF];
    
    
    UIView * extandview = [[UIView alloc] initWithFrame:CGRectMake(left, 127, self.bounds.size.width-2*left, 20)];
    extandview.backgroundColor = [UIColor clearColor];
    [self addSubview:extandview];
    
    UILabel * label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 80, 20 )];
    label.text = @"配件信息";
    label.textColor = [UIColor blackColor];
    label.font = [UIFont fontWithName:@"PingFang SC" size:12];
    [extandview addSubview:label];
    
    UIButton * extandBtn = [[UIButton alloc] initWithFrame:CGRectMake(extandview.bounds.size.width-20-space, 0, 40, 20 )];
    [extandBtn setImage:[UIImage imageNamed:@"dropdown"] forState:UIControlStateNormal];
    [extandBtn addTarget:self action:@selector(extend) forControlEvents:UIControlEventTouchUpInside];
    [extandview addSubview:extandBtn];
    
    UITableView * extandDetailView = [[UITableView alloc] initWithFrame:CGRectMake(0, 158, self.bounds.size.width, 0)];
    extandDetailView.backgroundColor = [UIColor clearColor];
    [self addSubview:extandDetailView];

    _curEngineers = [NSMutableArray array];
    self.hideDetail = YES;
    [self.collectionView.collectionViewLayout invalidateLayout];
}

-(void)extend
{
    self.hideDetail = !_hideDetail;
    
    
}

-(void)setHideDetail:(BOOL)hideDetail
{
    _hideDetail = hideDetail;
    
    
    NSInteger goodH = 34;
    CGRect rect  = self.bounds;
    
    if (!_hideDetail) {
        NSArray * goods = [self.curMaintance objectForKey:@"maintenanceGoods"];
        if (!goods || (goods.count==0)) {
            
        }else {
            
            
        }
        
        rect.size.height = 159+ goodH*2;
        
    }else {
        CGRect rect  = self.bounds;
        rect.size.height = 159;
    }
    
    [self setBounds:rect];
    [self setNeedsLayout];
    [self.collectionView.collectionViewLayout invalidateLayout];
    
//    [self.collectionView performBatchUpdates:^{
//
//    } completion:^(BOOL finished) {
//
//    }];
}

-(void)selectMaintance
{
    NSMutableArray * popStrings = [NSMutableArray array];
    for (NSDictionary * maintance in self.maintances) {
        [popStrings addObject:[maintance objectForKey:@"name"]];
    }
    PopViewController * popCtrl = [[PopViewController alloc] initWithTitle:@"维修名称" Data:popStrings];
    popCtrl.delegate = self;
    popCtrl.view.tag = TAG_POPVIEW_MAINTANCENAME;
    [self.navigationController addChildViewController:popCtrl];
    [self.navigationController.view addSubview:popCtrl.view];
    
}

-(void)selectEngineers
{
    NSMutableArray * popStrings = [NSMutableArray array];
    for (NSDictionary * engineer in self.engineers) {
        [popStrings addObject:[[engineer objectForKey:@"user"] objectForKey:@"name"]];
    }
    PopViewController * popCtrl = [[PopViewController alloc] initWithTitle:@"技师" Data:popStrings];
    popCtrl.delegate = self;
    popCtrl.view.tag = TAG_POPVIEW_ENGINEER;
    [self.navigationController addChildViewController:popCtrl];
    [self.navigationController.view addSubview:popCtrl.view];
    
}


-(void)selectWorkingTeam
{
    NSMutableArray * popStrings = [NSMutableArray array];
    for (NSDictionary * team in self.workingteams) {
        [popStrings addObject:[team objectForKey:@"name"]];
    }
    PopViewController * popCtrl = [[PopViewController alloc] initWithTitle:@"班组" Data:popStrings];
    popCtrl.delegate = self;
    popCtrl.view.tag = TAG_POPVIEW_WORKINGTEAM;
    [self.navigationController addChildViewController:popCtrl];
    [self.navigationController.view addSubview:popCtrl.view];
    
}


-(void)selectChargeMethod
{
    NSMutableArray * popStrings = [NSMutableArray array];
    for (NSDictionary * charge in self.chargeMethods) {
        [popStrings addObject:[charge objectForKey:@"message"]];
    }
    PopViewController * popCtrl = [[PopViewController alloc] initWithTitle:@"收费类别" Data:popStrings];
    popCtrl.delegate = self;
    popCtrl.view.tag = TAG_POPVIEW_CHARGEMETHOD;
    [self.navigationController addChildViewController:popCtrl];
    [self.navigationController.view addSubview:popCtrl.view];
    
}

-(void)addItem:(UIButton *)sender
{
    MaintanceViewController * addCtrl = [[MaintanceViewController alloc] init];
    addCtrl.delegate = self;
    [self.navigationController pushViewController:addCtrl animated:YES];
    
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


-(void)popview:(UIViewController *)popview disSelectRowAtIndex:(NSInteger)index
{
    switch (popview.view.tag) {
        case TAG_POPVIEW_CHARGEMETHOD:
        {
            [_curMaintance setObject:[self.chargeMethods objectAtIndex:index] forKey:@"chargingMethod"];
        }
            break;
        case TAG_POPVIEW_MAINTANCENAME:
        {
            [_curMaintance setObject:[self.maintances objectAtIndex:index] forKey:@"maintenance"];
        }
            break;
        case TAG_POPVIEW_WORKINGTEAM:
        {
            [_curMaintance setObject:[self.workingteams objectAtIndex:index] forKey:@"workingTeam"];
            [self.engineers removeAllObjects];
            [self.engineers addObjectsFromArray:[[self.workingteams objectAtIndex:index] objectForKey:@"members"]];
        }
            break;
        case TAG_POPVIEW_ENGINEER:
        {
            [self.curEngineers addObject:[self.engineers objectAtIndex:index]];
            [_curMaintance setObject:self.curEngineers forKey:@"assignees"];
            
        }
            break;
        default:
            break;
    }
   
}

@end
