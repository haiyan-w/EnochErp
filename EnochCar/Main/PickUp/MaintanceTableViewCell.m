//
//  MaintanceTableViewCell.m
//  EnochCar
//
//  Created by 王海燕 on 2021/6/1.
//

#import "MaintanceTableViewCell.h"
#import "PopViewController.h"
#import "MaintanceViewController.h"
#import "NSNumber+Common.h"
#import "ComplexBox.h"
#import "AddMaintanceViewController.h"


#define TAG_TEXTFIELD_HOUR     31
#define TAG_TEXTFIELD_PRICE    32
#define TAG_TEXTFIELD_NAME     33
#define TAG_TEXTFIELD_WORKINGTEAM 34
#define TAG_TEXTFIELD_ENGINEER 35
#define TAG_TEXTFIELD_CATEGORY 36

#define TAG_POPVIEW_CHARGEMETHOD  51
#define TAG_POPVIEW_MAINTANCENAME  52
#define TAG_POPVIEW_WORKINGTEAM  53
#define TAG_POPVIEW_ENGINEER  54

@interface MaintanceTableViewCell()<UITextFieldDelegate,UITableViewDelegate,UITableViewDataSource,MaintanceDelegate,PopViewDelagate,EditMaintanceDelegate>
@property (strong, nonatomic) IBOutlet UIView *bgview;
@property (strong, nonatomic) IBOutlet UITextField *nameTF;

@property (strong, nonatomic) IBOutlet ComplexBox *categoryBox;
@property (strong, nonatomic) IBOutlet ComplexBox *workingteamBox;
@property (strong, nonatomic) IBOutlet ComplexBox *engineerBox;


@property (weak, nonatomic) IBOutlet UITextField *hourTF;
@property (weak, nonatomic) IBOutlet UITextField *priceTF;

//@property (strong, nonatomic) IBOutlet UITableView *detailTable;

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
    
    _nameTF.delegate = self;
    _nameTF.tag = TAG_TEXTFIELD_NAME;
    _hourTF.delegate= self;
    _hourTF.tag = TAG_TEXTFIELD_HOUR;
    _priceTF.delegate= self;
    _priceTF.tag = TAG_TEXTFIELD_PRICE;
    
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
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textChange:) name:UITextFieldTextDidChangeNotification object:_hourTF];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textChange:) name:UITextFieldTextDidChangeNotification object:_priceTF];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textChange:) name:UITextFieldTextDidChangeNotification object:_nameTF];
    
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
        case TAG_TEXTFIELD_NAME:
        {
            [self.curMaintance setValue:_nameTF.text forKey:@"name"];
        }
            break;
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
            
        default:
            break;
    }
    
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


- (IBAction)deleteBtnClick:(id)sender {
    [self resign];
    [self.delagate tableviewcell:self didDeleteAtIndex:_index];
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
        if ([[charge objectForKey:@"forServiceMaintenance"] boolValue]) {
            [popStrings addObject:[charge objectForKey:@"message"]];
        }
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

-(void)setCurMaintance:(NSMutableDictionary *)curMaintance
{
    _curMaintance = curMaintance;

    self.nameTF.text = [curMaintance objectForKey:@"name"];
    NSDictionary * maintance = [curMaintance objectForKey:@"maintenance"];
    if ([maintance objectForKey:@"id"]) {
        self.nameTF.enabled = NO;
    }else {
        self.nameTF.enabled = YES;
    }
    NSDictionary * chargeMethod = [curMaintance objectForKey:@"chargingMethod"];
    if (!chargeMethod) {
        chargeMethod = [self.chargeMethods firstObject];
    }
    [self setChargeMethod:chargeMethod];
    NSNumber * hour = [_curMaintance objectForKey:@"laborHour"];
    NSNumber * price = [_curMaintance objectForKey:@"price"];

    if (hour) {

        self.hourTF.text = [hour DoubleStringValueWithDigits:2];
    }
    if (price) {
        self.priceTF.text = [price DoubleStringValueWithDigits:2];
    }
    
    self.workingteamBox.text = [[_curMaintance objectForKey:@"workingTeam"] objectForKey:@"name"];
    
    NSArray * assignees = [_curMaintance objectForKey:@"assignees"];
    if (assignees) {
        self.curAssignees = [NSMutableArray arrayWithArray:assignees];
        NSString * string = @"";
        for (int i = 0;i<self.curAssignees.count;i++)
        {
//            NSDictionary * aengineer = [[self.curAssignees objectAtIndex:i] objectForKey:@"assignee"];
            NSDictionary * aengineer = [self.curAssignees objectAtIndex:i];
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
    
    NSDictionary * valuationMethod = [curMaintance objectForKey:@"valuationMethod"];
    if ([[valuationMethod objectForKey:@"code"] isEqualToString:@"H"]) {
        //工时计价
        self.hourTF.enabled = YES;
    }else if ([[valuationMethod objectForKey:@"code"] isEqualToString:@"P"]){
        //金额计价
        self.hourTF.enabled = NO;
    }
}

-(void)setChargeMethod:(NSDictionary *)chargeMethod
{
    if (chargeMethod) {
        [self.categoryBox setText:[chargeMethod objectForKey:@"message"]];
        [_curMaintance setObject:chargeMethod forKey:@"chargingMethod"];
    }
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

//-(void)save:(NSArray *)goods
//{
//    NSMutableArray * array = [NSMutableArray arrayWithArray:goods];
//    for (NSMutableDictionary * agood in array) {
////        [agood setValue:[_curMaintance  objectForKey:@"chargingMethod"] forKey:@"chargingMethod"];
//        [agood setValue:[NSDictionary dictionaryWithObject:@"N" forKey:@"code"] forKey:@"inflatedFlag"];//非虚增项目
//        [agood setValue:[NSDictionary dictionaryWithObject:@"N" forKey:@"code"] forKey:@"fromQuotation"];//附表
//        [agood setValue:[NSDictionary dictionaryWithObject:@"N" forKey:@"code"] forKey:@"returnFinished"];
//    }
//    [_curMaintance setObject:array forKey:@"maintenanceGoods"];
////    [self setGoodsCount:[array count]];
//    [self.detailTable reloadData];
//}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if ((textField.tag == TAG_TEXTFIELD_HOUR) ||((textField.tag == TAG_TEXTFIELD_PRICE) )) {
        return [self validateNumber:string];
    }else {
        return YES;
    }
   
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
