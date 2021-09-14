//
//  SeviceTableViewCell.m
//  EnochCar
//
//  Created by 王海燕 on 2021/5/21.
//

#import "SeviceTableViewCell.h"
#import "NetWorkAPIManager.h"
#import "SeviceDetailTableView.h"
#import "CommonTool.h"
#import "PopViewController.h"
#import "MaintanceAndAccessoryViewController.h"

@interface SeviceTableViewCell()<PopViewDelagate,MaintanceAndAccessoryDelegate>
@property (strong, nonatomic) IBOutlet UIView *bgview;
@property (strong, nonatomic) IBOutlet UIButton *extraBtn;

@property (strong, nonatomic) IBOutlet UILabel *countLab;

@property (strong, nonatomic) IBOutlet UIView *detailVIew;
@property (strong, nonatomic)NSMutableArray * detaiCells;

@property (strong, nonatomic)NSMutableDictionary * querySevice;//query接口获取的service数据
@property (strong, nonatomic)NSMutableDictionary * curSevice;//当前工单详情
@end


@implementation SeviceTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.backgroundColor = [UIColor colorWithRed:242/255.0 green:242/255.0 blue:242/255.0 alpha:1];
    self.curSevice = nil;
    self.detaiCells = [NSMutableArray array];
    
    self.bgview.layer.cornerRadius = 4;
    self.detailVIew.layer.cornerRadius = 4;
    
    self.serviceStateLab.layer.cornerRadius = 4;
    self.serviceStateLab.layer.masksToBounds = YES;
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)configData:(NSMutableDictionary*)data
{
    if ([self.querySevice objectForKey:SEVICE_DETAIL])
    {
        NSDictionary * seviceDetail = [data objectForKey:SEVICE_DETAIL];
        if (seviceDetail) {
            _curSevice = [NSMutableDictionary dictionaryWithDictionary:seviceDetail];
        }else {
            _curSevice = nil;
        }
    }
    _querySevice = data;
    
    [_detaiCells removeAllObjects];
    for (UIView * subview in _detailVIew.subviews) {
        [subview removeFromSuperview];
    }

    NSString * serialNo = [data objectForKey:@"serialNo"];
    NSString * enterDatetime = [data objectForKey:@"enterDatetime"];
    NSString * timeStr = [enterDatetime stringByReplacingOccurrencesOfString:@"T" withString:@" "];
    NSString * plateNo = [data objectForKey:@"plateNo"];
    if (plateNo) {
        plateNo = [CommonTool getPlateNoSpaceString:plateNo];
    }
    
    //维修总费用 = 工时费（折前）+配件费（折前）+配件管理费+税金+辅料费+其他费用
    float totalCost = 0;
    float maintenanceAmount = [[data objectForKey:@"maintenanceAmount"] floatValue];
    float goodsAmount = [[data objectForKey:@"goodsAmount"] floatValue];
    float managementFee = [[data objectForKey:@"managementFee"] floatValue];
    float tax = [[data objectForKey:@"tax"] floatValue];
    float accessoryFee = [[data objectForKey:@"accessoryFee"] floatValue];
    float otherFee = [[data objectForKey:@"otherFee"] floatValue];
    totalCost = maintenanceAmount + goodsAmount + managementFee +tax + accessoryFee +otherFee;

    NSString * customerName = [data objectForKey:@"customerName"];
    NSString * cellphone = [data objectForKey:@"cellphone"];//
    NSString * status = [[data objectForKey:@"status"] objectForKey:@"message"];//
    NSString * statusCode = [[data objectForKey:@"status"] objectForKey:@"code"];
    if ([statusCode isEqualToString:@"PD"]) {
        _extraBtn.hidden = YES;
    }else {
        _extraBtn.hidden = NO;
    }
    NSString * serviceCategoryName = [data objectForKey:@"serviceCategoryName"];
    _serialNoLab.text = serialNo;
    _enterDateLab.text = [NSString stringWithFormat:@"%@ 进厂",timeStr];
    _plateNoLab.text = plateNo;
    _nameAndCellphoneLab.text = [NSString stringWithFormat:@"%@",customerName];
    _totalCostLab.text =[NSString stringWithFormat:@"%.2f",totalCost];
    _serviceStateLab.text = status;
    [_categoryBtn setTitle:serviceCategoryName forState:UIControlStateNormal];

    NSInteger maintenanceCount = [[data objectForKey:@"maintenanceCount"] integerValue];
    [self setMaintenanceCount:maintenanceCount];

    NSArray * maintenances = [_curSevice objectForKey:@"maintenances"];
    //detailview行高
    NSInteger detailRowH = 70;
    CGPoint pt = _detailVIew.frame.origin;
    CGSize size = _detailVIew.frame.size;
    _detailVIew.frame = CGRectMake(pt.x, pt.y, size.width, detailRowH*maintenances.count);
    
    BOOL needGrey = NO;
    if ([statusCode isEqualToString:@"AA"]||[statusCode isEqualToString:@"PD"]) {
        needGrey = YES;
    }
    
    for (int i = 0; i<maintenances.count; i++) {
        NSDictionary * maintenance = [maintenances objectAtIndex:i];
        SeviceDetailTableView * cell =  [[SeviceDetailTableView alloc] initWithFrame:CGRectMake(0, detailRowH*i, size.width, detailRowH)];
        [cell configData:maintenance];
        [cell setGreyType:needGrey];
        [_detailVIew addSubview:cell];
        [_detaiCells addObject:cell];
    }
}

-(void)setMaintenanceCount:(NSInteger)count
{
    NSString * countStr = [NSString stringWithFormat:@"项目（%@）",[NSNumber numberWithInteger:count]];
    NSMutableAttributedString * attuStr = [[NSMutableAttributedString alloc] initWithString:countStr];
    NSRange range = [countStr rangeOfString:[NSString stringWithFormat:@"（%@）",[NSNumber numberWithInteger:count]] options:NSCaseInsensitiveSearch];
    [attuStr addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:range];
    
    _countLab.attributedText = attuStr;
}

- (IBAction)extraBtnClicked:(id)sender {
    
    if (!self.curSevice) {
        [self querySeviceDetail];
    }else {
        [self showPopView];
    }
}

- (IBAction)telephoneBtnClicked:(id)sender {
    
    NSString * string = [NSString stringWithFormat:@"telprompt://%@",[_querySevice objectForKey:@"cellphone"]];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:string]];    
}


-(void)querySeviceDetail
{
    __weak SeviceTableViewCell * weakself = self;
    [[NetWorkAPIManager defaultManager] queryService:[[self.querySevice objectForKey:@"id"] integerValue] success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary * resp = responseObject;
        NSDictionary * data = [[resp objectForKey:@"data"] firstObject];
        
        weakself.curSevice = [NSMutableDictionary dictionaryWithDictionary:data];
      
        [weakself.querySevice setValue:data forKey:SEVICE_DETAIL];
        dispatch_async(dispatch_get_main_queue(), ^{
//            [weakself configData:weakself.querySevice];
            [weakself showPopView];
        });

    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {

    }];
}

-(void)showPopView
{
    PopViewController * popCtrl = [[PopViewController alloc] initWithTitle:@"操作" Data:[self getPopStrings]];
    popCtrl.delegate = self;
    [self.navCtrl addChildViewController:popCtrl];
    [self.navCtrl.view addSubview:popCtrl.view];
}



-(void)expand:(BOOL)expand
{
    if (expand) {
        self.bgview.backgroundColor = [UIColor colorWithRed:233/255.0 green:236/255.0 blue:241/255.0 alpha:1];
        self.detailVIew.backgroundColor = [UIColor colorWithRed:233/255.0 green:236/255.0 blue:241/255.0 alpha:1];
    }else {
        self.bgview.backgroundColor = [UIColor whiteColor];
        self.detailVIew.backgroundColor = [UIColor whiteColor];
    }
    _detailVIew.hidden = !expand;
}

-(BOOL)check
{
    BOOL complete = YES;
    for (SeviceDetailTableView * cell in _detaiCells) {
        if (!cell.haveSelected) {
            complete = NO;
            break;
        }
    }
    return complete;
}

-(void)showAlertWithTitle:(NSString*)title message:(NSString*)message
{
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:title
                                                                       message:message
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action) {
                                                                  //响应事件
                                                                
                                                              }];

        [alert addAction:defaultAction];

    [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alert animated:YES completion:nil];
    
}


-(void)nextStep
{
    if ([self check]) {
        
        NSInteger seviceID = [[self.curSevice objectForKey:@"id"] integerValue];
        __weak SeviceTableViewCell * weakself = self;
        
        [[NetWorkAPIManager defaultManager] queryService:seviceID success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {

            NSDictionary * resp = responseObject;
            NSMutableDictionary * seviceDic = [NSMutableDictionary dictionaryWithDictionary:[[resp objectForKey:@"data"] firstObject]];
            [seviceDic setValue:[self getNextStep:[seviceDic objectForKey:@"status"]] forKey:@"nextStep"];
            [seviceDic setValue:@"suggestions" forKey:@"suggestions"];//该项可设置是否必填，ios暂时没有填写项一律在此设置
            [weakself updateSevice:seviceDic];
            
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakself showAlertWithTitle:@"查询工单详情失败" message:@""];
            });
        }];
        
    }else {
        [self showAlertWithTitle:@"请质检" message:@""];
    }
}

-(void)updateSevice:(NSMutableDictionary *)parm
{
    __weak SeviceTableViewCell * weakself = self;
    [[NetWorkAPIManager defaultManager] updateService:parm success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
//            [weakself.delegate tableViewCell:self update:YES];
            [weakself showAlertWithTitle:@"工单更新成功" message:@""];
        });
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSString * info = [error.userInfo objectForKey:@"body"];
        NSDictionary * dic = [CommonTool dictionaryWithJsonString:info];
        NSDictionary * msgDic = [[dic objectForKey:@"errors"] firstObject];
        NSString * message = [msgDic objectForKey:@"message"];
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakself showAlertWithTitle:@"工单更新失败" message:message];
        });
    }];
}


-(NSDictionary*)getNextStep:(NSDictionary *)status
{
    NSMutableDictionary * next = [NSMutableDictionary dictionary];
    NSString * code = [status objectForKey:@"code"];
    if ([code isEqualToString:@"PR"]) {
        [next setValue:@"IM" forKey:@"code"];
    }else if ([code isEqualToString:@"IM"]){//维修中跳转到待结算状态
        [next setValue:@"AA" forKey:@"code"];
    }else if ([code isEqualToString:@"MC"]){
        [next setValue:@"AA" forKey:@"code"];
    }else if ([code isEqualToString:@"AA"]){
        [next setValue:@"PD" forKey:@"code"];
    }else {
        [next setValue:@"" forKey:@"code"];
    }
    return next;
}

-(NSString *)getNextString
{
    NSDictionary * status = [self.curSevice objectForKey:@"status"];
    NSString * title = @"完工";
    NSString * code = [status objectForKey:@"code"];
    if ([code isEqualToString:@"PR"]) {
        title = @"完工";
    }else if ([code isEqualToString:@"IM"]){
        title = @"完工";
    }else if ([code isEqualToString:@"MC"]){
        title = @"完工";
    }else if ([code isEqualToString:@"AA"]){
        title = @"结算";
    }else if ([code isEqualToString:@"PD"]){
        title = @"结算";
    }
    return title;
}

-(NSArray *)getPopStrings
{
    NSMutableArray * strings = [NSMutableArray array];
    NSDictionary * status = [self.curSevice objectForKey:@"status"];
    NSString * code = [status objectForKey:@"code"];
   if ([code isEqualToString:@"IM"]){//"维修中"
        [strings addObject:@"项目与配件"];
        [strings addObject:@"完工"];
    }else if ([code isEqualToString:@"MC"]){//"待检验"
        [strings addObject:@"完工"];
    }else if ([code isEqualToString:@"AA"]){//"待结算"
        [strings addObject:@"结算"];
    }else if ([code isEqualToString:@"PD"]){//"已结算"
        [strings addObject:@"结算"];
    }
    return strings;
    
}

-(void)popview:(UIViewController *)popview disSelectRowAtIndex:(NSInteger)index
{
    NSDictionary * status = [self.curSevice objectForKey:@"status"];
    NSString * code = [status objectForKey:@"code"];
    
    switch (index) {
        case 0:
        {
           if ([code isEqualToString:@"IM"]){//"维修中"
               NSArray * array = [self.curSevice objectForKey:@"maintenances"];
               if (!array) {
                   array = [NSArray array];
               }
               MaintanceAndAccessoryViewController * maintanceCtrl = [[MaintanceAndAccessoryViewController alloc] initWithSevice:self.curSevice];
//               maintanceCtrl.delegate = self;
               [self.navCtrl pushViewController:maintanceCtrl animated:YES];
           }else {
               [self nextStep];
           }
        }
            break;
        case 1:
        {
            if ([code isEqualToString:@"IM"]){//"维修中"
                [self nextStep];
            }
        }
            break;
            
        default:
            break;
    }
}

-(void)save:(NSArray *)maintenances
{
    [self.curSevice setObject:[NSMutableArray arrayWithArray:maintenances] forKey:@"maintenances"];
    [self setMaintenanceCount:maintenances.count];
    [self updateSevice:self.curSevice];
    
}

@end
