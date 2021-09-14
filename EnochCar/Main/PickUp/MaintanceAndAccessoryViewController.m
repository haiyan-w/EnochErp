//
//  MaintanceAndAccessoryViewController.m
//  EnochCar
//
//  Created by 王海燕 on 2021/5/31.
//

#import "MaintanceAndAccessoryViewController.h"
#import "ItemCollectionViewCell.h"
#import "NetWorkAPIManager.h"
#import "MaintanceViewController.h"
#import "MaintanceTableViewCell.h"
#import "GlobalInfoManager.h"
#import "CommonTool.h"


@interface MaintanceAndAccessoryViewController ()<UITableViewDelegate,UITableViewDataSource,UICollectionViewDelegate,UICollectionViewDataSource,MaintanceDelegate,MaintanceTableViewCellDelegate>
@property(nonatomic, readwrite, strong) UITableView * tableView;
@property(nonatomic, readwrite, strong) NSMutableArray * chargeMethods;
//@property(nonatomic, readwrite, strong) NSMutableArray * maintances;//查询到的项目列表
@property(nonatomic, readwrite, strong) NSMutableArray * workingteams;
@property(nonatomic, readwrite, strong) NSMutableArray * engineers;//先选择班组才有技师
@property(nonatomic, readwrite, strong) NSMutableArray * curMaintances;//当前要开单的维修项目
@property(nonatomic, readwrite, assign) NSInteger  extendIndex;
@property(nonatomic, readwrite, assign) NSInteger  firstResponderIndex;
@property(nonatomic, readwrite, assign) CGRect  firstResponderRect;
@property(nonatomic, readwrite, assign) CGPoint  tableViewOriginOffset;

@end

@implementation MaintanceAndAccessoryViewController

-(instancetype)initWithData:(NSArray*)maintenances
{
    self = [super init];
    if (self) {
        
        self.extendIndex = -1;
        _workingteams = [NSMutableArray array];
        _chargeMethods = [NSMutableArray array];
        _curMaintances = [NSMutableArray array];
        for (NSDictionary * data in maintenances) {
            [_curMaintances addObject:[NSMutableDictionary dictionaryWithDictionary:data]];
        }
        [self queryWorkingTeam];
        [self queryChargeMethods];
        
        CGFloat tableY = [CommonTool topbarH] + 20;
        
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(20, tableY, self.view.bounds.size.width-2*20, self.view.bounds.size.height-74 - tableY)];
        _tableView.backgroundColor = [UIColor clearColor];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.layer.cornerRadius = 4;
        _tableView.showsVerticalScrollIndicator = NO;
        _tableView.showsHorizontalScrollIndicator = NO;
        _tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
        [_tableView registerNib:[UINib nibWithNibName:@"MaintanceTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"MaintanceTableViewCell"];
        [self.view addSubview:_tableView];
        
        UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(taponbg:)];
        [self.view addGestureRecognizer:tap];
    }
    return self;
}

-(void)taponbg:(UIGestureRecognizer *)gesture
{
    [self resign];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.midTitle = @"项目与配件";
//    [self setTitle:@"项目与配件"];
    
    NSInteger top = 88;
    NSInteger left = 20;
    NSInteger right = 20;
    NSInteger space = 20;

    UIButton * addBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height - 74, self.view.bounds.size.width, 74)];
    [addBtn setTitle:@"添加项目" forState:UIControlStateNormal];
    [addBtn setTitleColor:[UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1] forState:UIControlStateNormal];
    addBtn.titleLabel.font = [UIFont systemFontOfSize:18 weight:UIFontWeightSemibold];
    addBtn.backgroundColor = [UIColor whiteColor];
    addBtn.layer.cornerRadius = 4;
    [addBtn addTarget:self action:@selector(addItem) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:addBtn];
    
    UIButton * saveBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 56, 32)];
    [saveBtn setTitle:@"保存" forState:UIControlStateNormal];
    saveBtn.titleLabel.font = [UIFont systemFontOfSize:15 weight:UIFontWeightSemibold];
    [saveBtn setTitleColor:[UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1] forState:UIControlStateNormal];
    saveBtn.layer.cornerRadius = 2;
    saveBtn.backgroundColor = [UIColor colorWithRed:252/255.0 green:215/255.0 blue:139/255.0 alpha:1];
    [saveBtn addTarget:self action:@selector(save) forControlEvents:UIControlEventTouchUpInside];
    [self setRightBtn:saveBtn];
    
    NSInteger topBarH = [CommonTool topbarH];
    _tableView.frame = CGRectMake(left, topBarH, (self.view.bounds.size.width - 2*left), (self.view.bounds.size.height - topBarH - addBtn.frame.size.height - 2* space));
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self addNotifications];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self removeNotifications];
}

-(void)addNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

-(void)removeNotifications
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)save
{
    if ([self check]) {
        [self.delegate save:self.curMaintances];
        [self.navigationController popViewControllerAnimated:YES];
    }
}

-(BOOL)check
{
    //班组和技师未选导致影响维修界面的下一步操作崩溃
    for (NSDictionary * maintance in self.curMaintances) {
        if (![maintance objectForKey:@"workingTeam"]) {
            [self showHint:@"未选择班组"];
            return NO;
        }
        //技师选项可配置
        if ([[GlobalInfoManager infoManager] needEngenee]) {
            if (![maintance objectForKey:@"assignees"]) {
                [self showHint:@"未选择技师"];
                return NO;
            }
        }
    }
    return  YES;
}

-(void)addItem
{
    MaintanceViewController * addCtrl = [[MaintanceViewController alloc] init];
    addCtrl.delegate = self;
    [self.navigationController pushViewController:addCtrl animated:YES];
}

//根据maintance维修项目类别名称添加项目
-(void)addMaintance:(NSDictionary *)maintance
{
    NSMutableDictionary * amaintance = [NSMutableDictionary dictionaryWithObject:maintance forKey:@"maintenance"];
    [amaintance setValue:[maintance objectForKey:@"valuationMethod"] forKey:@"valuationMethod"];
    [amaintance setValue:[maintance objectForKey:@"name"] forKey:@"name"];
    [amaintance setValue:[NSMutableArray array] forKey:@"maintenanceGoods"];
    [amaintance setValue:[NSDictionary dictionaryWithObject:@"N" forKey:@"code"] forKey:@"inflatedFlag"];
    
    [self.curMaintances addObject:amaintance];
    [self.tableView reloadData];
    
}

//返回上一级页面
-(void)back
{
    [self.navigationController   popViewControllerAnimated:YES];
}

#pragma mark - UITableViewDelagate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    return self.curMaintances.count;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    MaintanceTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"MaintanceTableViewCell"];
    if (!cell) {
        [tableView registerNib:[UINib nibWithNibName:@"MaintanceTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"MaintanceTableViewCell"];
        cell = [tableView dequeueReusableCellWithIdentifier:@"MaintanceTableViewCell"];
    }
    cell.navigationController = self.navigationController;
    cell.tableview = tableView;
    cell.workingteams = self.workingteams;
    cell.chargeMethods = self.chargeMethods;
    cell.index = indexPath.row;
    cell.delagate  = self;
    
    [cell setCurMaintance:[_curMaintances objectAtIndex:indexPath.row]];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
//    MaintanceTableViewCell * cell = [tableView cellForRowAtIndexPath:indexPath];
    NSInteger height = 235;
    if (self.extendIndex == indexPath.row) {
        NSDictionary *  curMaintance = [self.curMaintances objectAtIndex:indexPath.row];
        NSArray * goodsArray = [curMaintance objectForKey:@"maintenanceGoods"];
        NSInteger detailH = 35*goodsArray.count;
        height += detailH;
    }
    return height;
}



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    
}

-(void)resign
{
    UIWindow * keyWindow = [[UIApplication sharedApplication] keyWindow];
    UIView * firstResponder = [keyWindow performSelector:@selector(firstResponder)];
    [firstResponder resignFirstResponder];
}

-(void)queryChargeMethods
{
    __weak MaintanceAndAccessoryViewController * weakself = self;
    [[NetWorkAPIManager defaultManager] lookup:@"CHGMTD?excludes=TNM&excludes=RMN&excludes=OTS" success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSDictionary * resp = responseObject;
        NSArray * array = [resp objectForKey:@"data"];
        
        [self.chargeMethods removeAllObjects];
        for (NSDictionary * method in array) {
            NSString * code = [method objectForKey:@"code"];
            //去掉返修类型，项目中添加收费类别时不可选 返修 。
            if (![code isEqualToString:@"RWK"]) {
                [self.chargeMethods addObject:method];
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakself.tableView reloadData];
        });
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
  
    }];
}

//查询班组，返回的members数组是技师
-(void)queryWorkingTeam
{
    __weak MaintanceAndAccessoryViewController * weakself = self;
    [[NetWorkAPIManager defaultManager] queryWorkingTeamsuccess:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSDictionary * resp = responseObject;
        NSArray * array = [resp objectForKey:@"data"];

        [weakself.workingteams removeAllObjects];
        [weakself.workingteams addObjectsFromArray:array];
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakself.tableView reloadData];
        });
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
    }];
}

-(void)select:(NSDictionary *)maintance
{
    [self addMaintance:[NSMutableDictionary dictionaryWithDictionary:maintance]];
}

-(void)tableviewcell:(MaintanceTableViewCell*)cell needExtend:(BOOL)isExtend
{
    if (self.extendIndex == cell.index) {
        self.extendIndex = -1;
    }else {
        self.extendIndex = cell.index;
    }
    
    [self.tableView reloadData];
    
}

-(void)tableviewcell:(MaintanceTableViewCell*)cell didDeleteAtIndex:(NSInteger)index
{
    [self.curMaintances removeObjectAtIndex:index];
    [self.tableView reloadData];    
}

-(void)tableviewcellBecomeFirstResponder:(CGRect)rect
{
    
    _firstResponderRect = rect;
}

#pragma --NSNotification
//键盘弹出后将视图向上移动
-(void)keyboardWillShow:(NSNotification *)notification
{
    NSDictionary *userInfo = [notification userInfo];
    CGRect KeyboardRect = [[userInfo objectForKey:@"UIKeyboardFrameEndUserInfoKey"]CGRectValue];
    NSInteger offset =  (_firstResponderRect.origin.y + _firstResponderRect.size.height) - KeyboardRect.origin.y + 12;
    if (offset > 0) {
        [UIView animateWithDuration:2 animations:^{
            _tableViewOriginOffset = self.tableView.contentOffset;
            [self.tableView setContentOffset:CGPointMake(_tableViewOriginOffset.x,_tableViewOriginOffset.y + offset)];
            
        }];
    }
  
}

//键盘退出后将视图恢复
-(void)keyboardWillHide:(NSNotification *)notification
{
    [self.tableView setContentOffset:_tableViewOriginOffset];
}


@end
