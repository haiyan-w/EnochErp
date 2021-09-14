//
//  MaintanceTableViewCell.m
//  EnochCar
//
//  Created by 王海燕 on 2021/6/1.
//

#import "MaintanceTableViewCell.h"
#import "DetailTableViewCell.h"
#import "PopViewController.h"
#import "MaintanceViewController.h"
#import "AccessoryViewController.h"
#import "NSNumber+Common.h"
#import "ComplexBox.h"
#import "AddMaintanceViewController.h"


#define TAG_TEXTFIELD_HOUR     31
#define TAG_TEXTFIELD_PRICE    32
//#define TAG_TEXTFIELD_DISCOUNT 33
#define TAG_TEXTFIELD_WORKINGTEAM 34
#define TAG_TEXTFIELD_ENGINEER 35
#define TAG_TEXTFIELD_CATEGORY 36

#define TAG_POPVIEW_CHARGEMETHOD  51
#define TAG_POPVIEW_MAINTANCENAME  52
#define TAG_POPVIEW_WORKINGTEAM  53
#define TAG_POPVIEW_ENGINEER  54

@interface MaintanceTableViewCell()<UITextFieldDelegate,UITableViewDelegate,UITableViewDataSource,MaintanceDelegate,PopViewDelagate,AccessoryViewControllerDelegate,DetailTableViewCellDelegate,EditMaintanceDelegate>
@property (strong, nonatomic) IBOutlet UIView *bgview;
@property (strong, nonatomic) IBOutlet UILabel *nameLabel;

@property (weak, nonatomic) IBOutlet UIButton *nameBtn;
@property (strong, nonatomic) IBOutlet ComplexBox *categoryBox;
@property (strong, nonatomic) IBOutlet ComplexBox *workingteamBox;
@property (strong, nonatomic) IBOutlet ComplexBox *engineerBox;

@property (strong, nonatomic) IBOutlet UIButton *goodsBtn;
@property (strong, nonatomic) IBOutlet UILabel *goodsLable;

@property (weak, nonatomic) IBOutlet UITextField *hourTF;
@property (weak, nonatomic) IBOutlet UITextField *priceTF;
//@property (weak, nonatomic) IBOutlet UITextField *discountTF;

@property (strong, nonatomic) IBOutlet UITableView *detailTable;

@property (assign, nonatomic,getter=isExtend)BOOL isExtend;
@property (strong, nonatomic)NSMutableDictionary * curMaintance;//当前维修项目
@property(nonatomic, readwrite, strong) NSMutableArray * engineers;//先选择班组才有技师列表
@property(nonatomic, readwrite, strong) NSMutableArray * curAssignees;//当前已选择技师，可多选

@end

@implementation MaintanceTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.bgview.layer.cornerRadius = 4;
    
    [_detailTable registerNib:[UINib nibWithNibName:@"DetailTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"DetailTableViewCell"];
    _detailTable.delegate = self;
    _detailTable.dataSource = self;
    _detailTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    _hourTF.delegate= self;
    _hourTF.tag = TAG_TEXTFIELD_HOUR;
    _priceTF.delegate= self;
    _priceTF.tag = TAG_TEXTFIELD_PRICE;
//    _discountTF.delegate= self;
//    _discountTF.tag = TAG_TEXTFIELD_DISCOUNT;

    __weak  MaintanceTableViewCell * weakself = self;
    
    [_categoryBox setMode:ComplexBoxSelect];
    _categoryBox.placeHolder = @"请选择收费类别";
    _categoryBox.delegate= self;
    _categoryBox.tag = TAG_TEXTFIELD_CATEGORY;
    [_categoryBox setBorder:YES];
    _categoryBox.selectBlock= ^{
        [weakself selectChargeMethod:weakself.categoryBox];
    };
    
    [_workingteamBox setMode:ComplexBoxSelect];
    _workingteamBox.placeHolder = @"班组";
    _workingteamBox.delegate= self;
    _workingteamBox.tag = TAG_TEXTFIELD_WORKINGTEAM;
    [_workingteamBox setBorder:YES];
    _workingteamBox.selectBlock= ^{
        [weakself selectWorkingTeam:weakself.workingteamBox];
    };
    
    [_engineerBox setMode:ComplexBoxSelect];
    _engineerBox.placeHolder = @"技师";
    _engineerBox.delegate= self;
    _engineerBox.tag = TAG_TEXTFIELD_ENGINEER;
    [_engineerBox setBorder:YES];
    _engineerBox.selectBlock= ^{
        [weakself selectEngineers:weakself.engineerBox];
    };

    _hourTF.keyboardType = UIKeyboardTypeDecimalPad;
    _priceTF.keyboardType = UIKeyboardTypeDecimalPad;
//    _discountTF.keyboardType = UIKeyboardTypeDecimalPad;
    
    [self.nameBtn addTarget:self action:@selector(nameBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textChange:) name:UITextFieldTextDidChangeNotification object:_hourTF];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textChange:) name:UITextFieldTextDidChangeNotification object:_priceTF];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textChange:) name:UITextFieldTextDidChangeNotification object:_discountTF];
    
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    
    [self.contentView setNeedsLayout];
    [self.contentView layoutIfNeeded];
    
    [self.categoryBox layoutSubviews];
    NSLog(@"self.categoryBox.frame = %f , %f",self.categoryBox.frame.size.width, self.categoryBox.frame.size.height);
}

-(NSMutableArray *)engineers
{
    if (!_engineers) {
        _engineers = [NSMutableArray array];
    }
    return _engineers;
    
}

-(NSMutableArray *)curAssignees
{
    if (!_curAssignees) {
        _curAssignees = [NSMutableArray array];
    }
    return _curAssignees;
}

-(void)textChange:(NSNotification*)notice
{
    UITextField * textfield = notice.object;
    
    switch (textfield.tag) {
        case TAG_TEXTFIELD_HOUR:
        {
            [self.curMaintance setValue:[NSNumber numberWithFloat:[_hourTF.text floatValue]] forKey:@"laborHour"];

        }
            break;
        case TAG_TEXTFIELD_PRICE:
        {
            [self.curMaintance setValue:[NSNumber numberWithFloat:[_priceTF.text floatValue]] forKey:@"price"];
        }
            break;
//        case TAG_TEXTFIELD_DISCOUNT:
//        {
//            [self.curMaintance setValue:[NSNumber numberWithFloat:[_discountTF.text floatValue]/100] forKey:@"discountRate"];// discountRatePercent
//        }
//            break;
            
        default:
            break;
    }
    
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)nameBtnClicked:(id)sender
{
    AddMaintanceViewController * addCtrl = [[AddMaintanceViewController alloc] initWithData:[NSMutableDictionary dictionaryWithDictionary:[self.curMaintance objectForKey:@"maintenance"]]];
    addCtrl.delegate = self;
    [self.navigationController pushViewController:addCtrl animated:YES];
}

- (IBAction)deleteBtnClick:(id)sender {
    [self resign];
    [self.delagate tableviewcell:self didDeleteAtIndex:_index];
}


- (IBAction)extendBtnClick:(id)sender {
    [self resign];
    self.isExtend = !_isExtend;
    [self.delagate tableviewcell:self needExtend:_isExtend];
}

- (void)selectEngineers:(id)sender {
    [self resign];
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

- (void)selectWorkingTeam:(id)sender {
    [self resign];
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

- (void)selectChargeMethod:(id)sender {
    [self resign];
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

- (IBAction)addAccessory:(id)sender {
    [self resign];
    AccessoryViewController * accessoryCtrl = [[AccessoryViewController alloc] initWithData:[self.curMaintance objectForKey:@"maintenanceGoods"]];
    accessoryCtrl.delegate = self;
    accessoryCtrl.chargeMethods = self.chargeMethods;
    
    [self.navigationController pushViewController:accessoryCtrl animated:YES];
}

-(void)setGoodsCount:(NSInteger)count
{
    NSString * numStr = [NSString stringWithFormat:@"配件信息（%@）", [NSNumber numberWithInteger:count]];
    NSMutableAttributedString * attrStr = [[NSMutableAttributedString alloc] initWithString:numStr];
    NSRange range = [numStr rangeOfString:[NSString stringWithFormat:@"（%@）", [NSNumber numberWithInteger:count]]];
    [attrStr addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:range];
    
    _goodsLable.attributedText = attrStr;
    
}

-(void)setIsExtend:(BOOL)isExtend
{
    _isExtend = isExtend;
    
    NSArray * goodsArray = [self.curMaintance objectForKey:@"maintanceGoods"];
    NSInteger height = 35 *goodsArray.count;
    CGRect frame = _detailTable.frame;
    
    if (_isExtend) {
        frame = CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, height);
    }else {
        frame = CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, 0);
    }
    _detailTable.frame = frame;
    [self.tableview reloadData];
}

-(void)setCurMaintance:(NSMutableDictionary *)curMaintance
{
    _curMaintance = curMaintance;
    
    NSArray * array = [_curMaintance objectForKey:@"maintenanceGoods"];
    NSMutableArray * goods = [NSMutableArray array];
    for (NSDictionary * good in array) {
        NSMutableDictionary * agood = [NSMutableDictionary dictionaryWithDictionary:good];
        [goods addObject:agood];
    }
    [_curMaintance setObject:goods forKey:@"maintenanceGoods"];
    [self setGoodsCount:array.count];
    
    NSDictionary * maintance = [curMaintance objectForKey:@"maintenance"];
    self.nameLabel.text = [maintance objectForKey:@"name"];
    NSDictionary * chargeMethod = [curMaintance objectForKey:@"chargingMethod"];
    if (!chargeMethod) {
        chargeMethod = [self.chargeMethods firstObject];
    }
    [self setChargeMethod:chargeMethod];
    NSNumber * hour = [_curMaintance objectForKey:@"laborHour"];
    NSNumber * price = [_curMaintance objectForKey:@"price"];
//    NSNumber * discount = [_curMaintance objectForKey:@"discountRate"];
    if (hour) {
//        self.hourTF.text = [NSString stringWithFormat:@"%@",hour];
        self.hourTF.text = [hour DoubleStringValueWithDigits:2];
    }
    if (price) {
        self.priceTF.text = [price DoubleStringValueWithDigits:2];
//        self.priceTF.text = [NSString stringWithFormat:@"%@",price];
    }
//    if (discount) {
//        self.discountTF.text = [NSString stringWithFormat:@"%@",[NSNumber numberWithFloat:discount.floatValue*100]];
//    }
    
    self.workingteamBox.text = [[_curMaintance objectForKey:@"workingTeam"] objectForKey:@"name"];
    
    NSArray * assignees = [_curMaintance objectForKey:@"assignees"];
    if (assignees) {
        self.curAssignees = [NSMutableArray arrayWithArray:assignees];
        NSString * string = @"";
        for (int i = 0;i<self.curAssignees.count;i++)
        {
            NSDictionary * aengineer = [[self.curAssignees objectAtIndex:i] objectForKey:@"assignee"];
            NSString * appendStr = @"";
            if (i == 0) {
                appendStr = [NSString stringWithFormat:@"%@",[aengineer objectForKey:@"name"]];
            }else {
                appendStr = [NSString stringWithFormat:@",%@",[aengineer objectForKey:@"name"]];
            }
            string = [string stringByAppendingString:appendStr];
        }
        
        self.engineerBox.text = string;
    }
    
 
}

-(void)setChargeMethod:(NSDictionary *)chargeMethod
{
    if (chargeMethod) {
        [self.categoryBox setText:[chargeMethod objectForKey:@"message"]];
        [_curMaintance setObject:chargeMethod forKey:@"chargingMethod"];
    }
}

#pragma mark - DetailCellDelagate

-(void)detailCell:(DetailTableViewCell *)cell deleteAtIndex:(NSInteger)index
{
    NSArray * goodsArray = [self.curMaintance objectForKey:@"maintenanceGoods"];
    NSMutableArray * array = [NSMutableArray arrayWithArray:goodsArray];
    [array removeObjectAtIndex:index];
    [self.curMaintance setObject:array forKey:@"maintenanceGoods"];
    [self.detailTable reloadData];
    [self.tableview reloadData];
    
}
#pragma mark - UITableViewDelagate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray * goodsArray = [self.curMaintance objectForKey:@"maintenanceGoods"];
    return goodsArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 35;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DetailTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"DetailTableViewCell"];
    if (!cell) {
        [tableView registerNib:[UINib nibWithNibName:@"DetailTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"DetailTableViewCell"];
        cell = [tableView dequeueReusableCellWithIdentifier:@"DetailTableViewCell"];
    }
    [cell config:[[self.curMaintance objectForKey:@"maintenanceGoods"] objectAtIndex:indexPath.row] withIndex:indexPath.row];
    cell.delegate = self;
    return cell;
}


-(void)popview:(UIViewController *)popview disSelectRowAtIndex:(NSInteger)index
{
    switch (popview.view.tag) {
        case TAG_POPVIEW_CHARGEMETHOD:
        {
            NSDictionary * chargeMethod = [self.chargeMethods objectAtIndex:index] ;
            [self setChargeMethod:chargeMethod];
        }
            break;
        case TAG_POPVIEW_WORKINGTEAM:
        {
            NSDictionary * team = [self.workingteams objectAtIndex:index];
            NSDictionary * dic = [NSDictionary dictionaryWithDictionary:team];
            [_curMaintance setObject:dic forKey:@"workingTeam"];
            [self.engineers removeAllObjects];
            [self.engineers addObjectsFromArray:[dic objectForKey:@"members"]];
            self.workingteamBox.text = [dic objectForKey:@"name"];
            if (self.curAssignees.count > 0) {
                [self.curAssignees removeAllObjects];
            }
            self.engineerBox.text = @"";
        }
            break;
        case TAG_POPVIEW_ENGINEER:
        {
            NSDictionary * aengineer = [self.engineers objectAtIndex:index];

            BOOL isHave = NO;
            
            //判断该技师是否已添加
            for (int i = 0;i<self.curAssignees.count;i++)
            {
                NSDictionary * dic = [[self.curAssignees objectAtIndex:i] objectForKey:@"assignee"];
                if ([[dic objectForKey:@"id"]integerValue] == [[[aengineer objectForKey:@"user"] objectForKey:@"id"]integerValue]) {
                    isHave = YES;
                    break;
                }
            }
            
            if (!isHave)
            {
                NSDictionary * adic= [NSDictionary dictionaryWithObject:[aengineer objectForKey:@"user"] forKey:@"assignee"];
                [self.curAssignees addObject:adic];
                [_curMaintance setObject:self.curAssignees forKey:@"assignees"];
                NSString * string = @"";
                for (int i = 0;i<self.curAssignees.count;i++)
                {
                    NSDictionary * dic = [self.curAssignees objectAtIndex:i];
                    
                    if (i == 0) {
                        string = [NSString stringWithFormat:@"%@",[[aengineer objectForKey:@"user"] objectForKey:@"name"]];
                    }else {
                        string = [NSString stringWithFormat:@",%@",[[aengineer objectForKey:@"user"] objectForKey:@"name"]];
                    }
                }
                
                self.engineerBox.text = [[self.engineerBox getText] stringByAppendingString:string];
            }
            
        }
            break;
        default:
            break;
    }
   
}

-(void)save:(NSArray *)goods
{
    NSMutableArray * array = [NSMutableArray arrayWithArray:goods];
    for (NSMutableDictionary * agood in array) {
//        [agood setValue:[_curMaintance  objectForKey:@"chargingMethod"] forKey:@"chargingMethod"];
        [agood setValue:[NSDictionary dictionaryWithObject:@"N" forKey:@"code"] forKey:@"inflatedFlag"];//非虚增项目
        [agood setValue:[NSDictionary dictionaryWithObject:@"N" forKey:@"code"] forKey:@"fromQuotation"];//附表
        [agood setValue:[NSDictionary dictionaryWithObject:@"N" forKey:@"code"] forKey:@"returnFinished"];
    }
    [_curMaintance setObject:array forKey:@"maintenanceGoods"];
    [self setGoodsCount:[array count]];
    [self.detailTable reloadData];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    return [self validateNumber:string];
}
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    UIWindow * window=[[[UIApplication sharedApplication] delegate] window];
    CGRect rect = [textField convertRect:textField.bounds toView:window];
    if([self.delagate respondsToSelector:@selector(tableviewcellBecomeFirstResponder:)])
    {
        [self.delagate tableviewcellBecomeFirstResponder:rect];
    }
    return YES;
}


-(void)changeMaintenance:(nonnull NSMutableDictionary *)maintenance
{
    [self.curMaintance setObject:maintenance forKey:@"maintenance"];
    self.nameLabel.text = [maintenance objectForKey:@"name"];
}

#pragma mark - tool
- (BOOL)validateNumber:(NSString*)number {
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

-(void)resign
{
    UIWindow * keyWindow = [[UIApplication sharedApplication] keyWindow];
    UIView * firstResponder = [keyWindow performSelector:@selector(firstResponder)];
    [firstResponder resignFirstResponder];
}

@end
