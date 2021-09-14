//
//  MaintanceAndAccessoryViewController.m
//  EnochCar
//
//  Created by 王海燕 on 2021/5/31.
//

#import "MaintanceAndAccessoryViewController.h"
#import "NetWorkAPIManager.h"
#import "MaintanceViewController.h"
#import "MaintanceTableViewCell.h"
#import "GlobalInfoManager.h"
#import "CommonTool.h"
#import "CommonTabView.h"
#import "GoodsTableViewCell.h"
#import "UIView+Hint.h"

#define TAG_TABLE_MAINTENANCE  11
#define TAG_TABLE_GOODS        12


@interface MaintanceAndAccessoryViewController ()<UITableViewDelegate,UITableViewDataSource,UICollectionViewDelegate,UICollectionViewDataSource,MaintanceDelegate,MaintanceTableViewCellDelegate,CommonTabViewDelegate>
@property(nonatomic, readwrite, strong) CommonTabView * tabView;
@property(nonatomic, readwrite, strong) UIScrollView * midScrollView;
@property(nonatomic, readwrite, strong) UITableView * maintenanceTableView;
@property(nonatomic, readwrite, strong) UITableView * goodsTableView;
@property(nonatomic, readwrite, strong) UIView * bottomBtnView;
@property(nonatomic, readwrite, strong) NSMutableArray * chargeMethods;
@property(nonatomic, readwrite, strong) NSMutableArray * workingteams;
@property(nonatomic, readwrite, strong) NSMutableArray * engineers;//先选择班组才有技师
@property(nonatomic, readwrite, strong) NSMutableArray * curMaintances;//当前要开单的维修项目
@property(nonatomic, readwrite, strong) NSMutableArray * goodsArray;//当前所有配件（项目配件+通用配件）
@property(nonatomic, readwrite, assign) NSInteger  firstResponderIndex;
@property(nonatomic, readwrite, assign) CGRect  firstResponderRect;
@property(nonatomic, readwrite, assign) CGPoint  tableViewOriginOffset;

@property(nonatomic, readwrite, strong) NSMutableDictionary * curSevice;


@end

@implementation MaintanceAndAccessoryViewController

-(instancetype)initWithSevice:(NSDictionary*)sevice
{
    self = [super init];
    if (self) {
        self.curSevice = [NSMutableDictionary dictionaryWithDictionary:sevice];
        
        _workingteams = [NSMutableArray array];
        _chargeMethods = [NSMutableArray array];
        _curMaintances = [NSMutableArray array];
        _goodsArray = [NSMutableArray array];
        for (NSDictionary * amaintenance in [self.curSevice objectForKey:@"maintenances"]) {
            [_curMaintances addObject:[NSMutableDictionary dictionaryWithDictionary:amaintenance]];
            NSArray * maintenanceGoods = [amaintenance objectForKey:@"maintenanceGoods"];
            for (NSDictionary * good in maintenanceGoods) {
                if ([[good objectForKey:@"count"] floatValue] != 0) {
                    [_goodsArray addObject:[NSMutableDictionary dictionaryWithDictionary:good]];
                }
            }
        }
        for (NSDictionary * agood in [self.curSevice objectForKey:@"goods"]) {
            if ([[agood objectForKey:@"count"] floatValue] != 0) {
                [_goodsArray addObject:[NSMutableDictionary dictionaryWithDictionary:agood]];
            }            
        }
        
        [self viewInit];
        [self dataInit];
    }
    return self;
}

-(instancetype)initWithData:(NSArray*)maintenances goods:(NSArray *)goodsArray
{
    self = [super init];
    if (self) {
        _workingteams = [NSMutableArray array];
        _chargeMethods = [NSMutableArray array];
        _curMaintances = [NSMutableArray array];
        _goodsArray = [NSMutableArray array];
        for (NSDictionary * amaintenance in maintenances) {
            [_curMaintances addObject:[NSMutableDictionary dictionaryWithDictionary:amaintenance]];
            NSArray * maintenanceGoods = [amaintenance objectForKey:@"maintenanceGoods"];
            for (NSDictionary * good in maintenanceGoods) {
                [_goodsArray addObject:[NSMutableDictionary dictionaryWithDictionary:good]];
            }
        }
        for (NSDictionary * agood in goodsArray) {
            [_goodsArray addObject:[NSMutableDictionary dictionaryWithDictionary:agood]];
        }
        
        [self viewInit];
        
        [self dataInit];
  
    }
    return self;
}

-(void)viewInit
{
    [self.view addSubview:self.tabView];
    [self.view addSubview:self.midScrollView];
    [self.midScrollView addSubview:self.maintenanceTableView];
    [self.midScrollView addSubview:self.goodsTableView];
    [self.midScrollView addSubview:self.bottomBtnView];
}

-(void)dataInit
{
    [self queryWorkingTeam];
    [self queryChargeMethods];
    
}

-(CommonTabView*)tabView
{
    if (!_tabView) {
        CGFloat orgY = [CommonTool topbarH];
        _tabView = [[CommonTabView alloc] initWithFrame:CGRectMake(0, orgY, self.view.bounds.size.width, 42)];
        _tabView.backgroundColor = [UIColor whiteColor];
        [_tabView setFont:[UIFont systemFontOfSize:16]];
        _tabView.needSeparation = YES;
        [_tabView setNormalColor:[UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1]];
        [_tabView setSelectedColor:[UIColor redColor]];
        _tabView.delegate = self;
        CommonTabItem * item1 = [[CommonTabItem alloc] initWithAttrText:[self getMaintanceAttrTitle] selectedAttr:[self getSelectedMaintanceAttrTitle]];
        CommonTabItem * item2 = [[CommonTabItem alloc] initWithAttrText:[self getGoodsAttrTitle] selectedAttr:[self getSelectedGoodsAttrTitle]];
        [_tabView setItems:@[item1, item2]];
        [_tabView setIndex:0];
    }
    return _tabView;
}

-(UIScrollView*)midScrollView{
    
    if (!_midScrollView) {
        NSInteger space = 20;

        CGFloat tableY = self.tabView.frame.origin.y + self.tabView.frame.size.height + space;
        _midScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, tableY, self.view.bounds.size.width, (self.view.bounds.size.height - tableY))];
        _midScrollView.delegate = self;
        _midScrollView.pagingEnabled = YES;
        _midScrollView.showsVerticalScrollIndicator = NO;
        _midScrollView.showsHorizontalScrollIndicator = NO;
        _midScrollView.backgroundColor = [UIColor clearColor];
    }
    return _midScrollView;
}

-(UITableView*)maintenanceTableView
{
    if (!_maintenanceTableView) {
        _maintenanceTableView = [[UITableView alloc] init];
        _maintenanceTableView.backgroundColor = [UIColor clearColor];
        _maintenanceTableView.delegate = self;
        _maintenanceTableView.dataSource = self;
        _maintenanceTableView.delegate = self;
        _maintenanceTableView.tag = TAG_TABLE_MAINTENANCE;
        _maintenanceTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _maintenanceTableView.layer.cornerRadius = 4;
        _maintenanceTableView.showsVerticalScrollIndicator = NO;
        _maintenanceTableView.showsHorizontalScrollIndicator = NO;
        _maintenanceTableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
        [_maintenanceTableView registerNib:[UINib nibWithNibName:@"MaintanceTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"MaintanceTableViewCell"];
        _maintenanceTableView.backgroundColor = [UIColor clearColor];
    }
    return _maintenanceTableView;
}

-(UITableView*)goodsTableView
{
    if (!_goodsTableView) {
        _goodsTableView = [[UITableView alloc] init];
        _goodsTableView.backgroundColor = [UIColor clearColor];
        _goodsTableView.delegate = self;
        _goodsTableView.dataSource = self;
        _goodsTableView.delegate = self;
        _goodsTableView.tag = TAG_TABLE_GOODS;
        _goodsTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _goodsTableView.layer.cornerRadius = 4;
        _goodsTableView.showsVerticalScrollIndicator = NO;
        _goodsTableView.showsHorizontalScrollIndicator = NO;
        _goodsTableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
        [_goodsTableView registerNib:[UINib nibWithNibName:@"GoodsTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"GoodsTableViewCell"];
        _goodsTableView.backgroundColor = [UIColor clearColor];
    }
    return _goodsTableView;
}

-(UIView*)bottomBtnView
{
    if (!_bottomBtnView) {
        _bottomBtnView = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height - 74, self.view.bounds.size.width, 74)];
        [self.view addSubview:_bottomBtnView];
        
        UIButton * addBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, _bottomBtnView.bounds.size.width/2, _bottomBtnView.bounds.size.height)];
        [addBtn setTitle:@"添加项目" forState:UIControlStateNormal];
        [addBtn setTitleColor:[UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1] forState:UIControlStateNormal];
        addBtn.titleLabel.font = [UIFont systemFontOfSize:18 weight:UIFontWeightSemibold];
        addBtn.backgroundColor = [UIColor whiteColor];
        [addBtn addTarget:self action:@selector(addItem) forControlEvents:UIControlEventTouchUpInside];
        [_bottomBtnView addSubview:addBtn];
        
        UIButton * selectBtn = [[UIButton alloc] initWithFrame:CGRectMake(_bottomBtnView.bounds.size.width/2, 0, _bottomBtnView.bounds.size.width/2, _bottomBtnView.bounds.size.height)];
        [selectBtn setTitle:@"选择项目" forState:UIControlStateNormal];
        [selectBtn setTitleColor:[UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1] forState:UIControlStateNormal];
        selectBtn.titleLabel.font = [UIFont systemFontOfSize:18 weight:UIFontWeightSemibold];
        selectBtn.backgroundColor = [UIColor colorWithRed:252/255.0 green:215/255.0 blue:139/255.0 alpha:1];
        [selectBtn addTarget:self action:@selector(selectItem) forControlEvents:UIControlEventTouchUpInside];
        [_bottomBtnView addSubview:selectBtn];
    }
    return _bottomBtnView;
}

-(void)taponbg:(UIGestureRecognizer *)gesture
{
    [self resign];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.midTitle = @"项目与配件";
    
    UIButton * saveBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 56, 32)];
    [saveBtn setTitle:@"保存" forState:UIControlStateNormal];
    saveBtn.titleLabel.font = [UIFont systemFontOfSize:15 weight:UIFontWeightSemibold];
    [saveBtn setTitleColor:[UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1] forState:UIControlStateNormal];
    saveBtn.layer.cornerRadius = 2;
    saveBtn.backgroundColor = [UIColor colorWithRed:252/255.0 green:215/255.0 blue:139/255.0 alpha:1];
    [saveBtn addTarget:self action:@selector(save) forControlEvents:UIControlEventTouchUpInside];
    [self setRightBtn:saveBtn];
    
    [self layoutSubviews];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self addGestureRecognizer];
    [self addNotifications];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self removeGestureRecognizer];
    [self removeNotifications];
}

-(void)addGestureRecognizer
{
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(taponbg:)];
    [self.view addGestureRecognizer:tap];
}
-(void)removeGestureRecognizer
{
    NSArray *targets = [self.view gestureRecognizers];
    for (UIGestureRecognizer *recognizer in targets){
        [self.view removeGestureRecognizer: recognizer];
    }
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

-(void)layoutSubviews
{
    NSInteger left = 20;
    NSInteger space = 20;
    
    CGFloat tableY = self.tabView.frame.origin.y + self.tabView.frame.size.height + space;
    self.midScrollView.frame = CGRectMake(0, tableY, self.view.bounds.size.width, (self.view.bounds.size.height - tableY));
    self.bottomBtnView.frame = CGRectMake(0, self.midScrollView.frame.size.height - 74, self.midScrollView.frame.size.width, 74);
    self.maintenanceTableView.frame = CGRectMake(0, 0, self.midScrollView.frame.size.width, self.midScrollView.frame.size.height - space - self.bottomBtnView.frame.size.height);
    self.goodsTableView.frame = CGRectMake(self.midScrollView.frame.size.width, 0, self.midScrollView.frame.size.width, self.midScrollView.frame.size.height - space);
    self.midScrollView.contentSize = CGSizeMake(2*self.midScrollView.frame.size.width, self.midScrollView.frame.size.height);
}

-(void)save
{
    if (self.curSevice) {
        [self.curSevice setValue:self.curMaintances forKey:@"maintenances"];
        [self updateSevice];
    }else {
        [self.delegate save:self.curMaintances];
        [self.navigationController popViewControllerAnimated:YES];
    }
}

//暂时不用检查班组和技师
-(BOOL)check
{
    //班组和技师未选导致影响维修界面的下一步操作崩溃
    for (NSDictionary * maintance in self.curMaintances) {
        if (![maintance objectForKey:@"workingTeam"]) {
            [self showHint:@"未选择班组"];
            return NO;
        }
        //技师选项可配置
        if ([NetWorkAPIManager defaultManager].needEngineer) {
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
    [self addMaintance:nil];
}

-(void)selectItem
{
    MaintanceViewController * addCtrl = [[MaintanceViewController alloc] init];
    addCtrl.delegate = self;
    [self.navigationController pushViewController:addCtrl animated:YES];
}

//根据maintance维修项目类别名称添加项目
-(void)addMaintance:(nullable NSDictionary *)maintance
{
    if (!maintance) {
        maintance = [NSMutableDictionary dictionaryWithObject:@"" forKey:@"name"];
    }
    
    NSDictionary * valuationMethod = [maintance objectForKey:@"valuationMethod"];
    NSNumber * laborHour = [maintance objectForKey:@"laborHour"];
    NSNumber * unitPrice = [maintance objectForKey:@"unitPrice"];
    
    if (!valuationMethod) {
        valuationMethod = [NSDictionary dictionaryWithObject:[NetWorkAPIManager defaultManager].chargeMethodCode forKey:@"code"];
    }
    if (!laborHour) {
        laborHour = [NSNumber numberWithFloat:1];
    }
    if (!unitPrice) {
        unitPrice = [NSNumber numberWithFloat:[NetWorkAPIManager defaultManager].price.floatValue];
    }
    
    
    NSMutableDictionary * amaintance = [NSMutableDictionary dictionaryWithObject:maintance forKey:@"maintenance"];
    [amaintance setValue:valuationMethod forKey:@"valuationMethod"];
    [amaintance setValue:laborHour forKey:@"laborHour"];
    if ([[NetWorkAPIManager defaultManager].chargeMethodCode isEqualToString:@"H"]) {
        //工时计价
        [amaintance setValue:unitPrice forKey:@"price"];
    }else if ([[NetWorkAPIManager defaultManager].chargeMethodCode isEqualToString:@"P"]){
        //金额计价
        [amaintance setValue:[NSNumber numberWithFloat:0] forKey:@"price"];
    }

    [amaintance setValue:[maintance objectForKey:@"name"] forKey:@"name"];
    [amaintance setValue:[NSMutableArray array] forKey:@"maintenanceGoods"];
    [amaintance setValue:[NSDictionary dictionaryWithObject:@"N" forKey:@"code"] forKey:@"inflatedFlag"];

    [self.curMaintances addObject:amaintance];
    [self.maintenanceTableView reloadData];
    
    [self setTabViewItems];
}

//返回上一级页面
-(void)back
{
    [self.navigationController   popViewControllerAnimated:YES];
}

#pragma mark - UITableViewDelagate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (TAG_TABLE_MAINTENANCE == tableView.tag)
    {
        return self.curMaintances.count;
    }else {
        return self.goodsArray.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (TAG_TABLE_MAINTENANCE == tableView.tag) {
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
    }else {
        GoodsTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"GoodsTableViewCell"];
        if (!cell) {
            [tableView registerNib:[UINib nibWithNibName:@"GoodsTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"GoodsTableViewCell"];
            cell = [tableView dequeueReusableCellWithIdentifier:@"GoodsTableViewCell"];
        }
        [cell config:[self.goodsArray objectAtIndex:indexPath.row]];
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger height = 174+12;
    
    if (TAG_TABLE_GOODS == tableView.tag) {
        height = 78+12;
    }
    return height;
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
            [weakself.maintenanceTableView reloadData];
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
            [weakself.maintenanceTableView reloadData];
        });
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
    }];
}

-(void)setTabViewItems
{
    CommonTabItem * item1 = [[CommonTabItem alloc] initWithAttrText:[self getMaintanceAttrTitle] selectedAttr:[self getSelectedMaintanceAttrTitle]];
    CommonTabItem * item2 = [[CommonTabItem alloc] initWithAttrText:[self getGoodsAttrTitle] selectedAttr:[self getSelectedGoodsAttrTitle]];
    [_tabView setItems:@[item1, item2]];
    [_tabView setIndex:_tabView.index];
}

-(NSAttributedString*)getMaintanceAttrTitle
{
    NSString * maintanceStr = @"维修项目";
    NSString * numStr = [NSString stringWithFormat:@"（%d）",_curMaintances.count];
    NSString * titleStr = [NSString stringWithFormat:@"%@%@",maintanceStr,numStr];
    NSMutableAttributedString * attrString = [[NSMutableAttributedString alloc] initWithString:titleStr];
    NSRange range1 = [titleStr rangeOfString:maintanceStr];
    NSRange range2 = [titleStr rangeOfString:numStr];
    [attrString addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:16 weight:UIFontWeightRegular] range:[titleStr rangeOfString:titleStr]];
    [attrString addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1] range:range1];
    [attrString addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:244/255.0 green:82/255.0 blue:59/255.0 alpha:1] range:range2];
    return attrString;
}

-(NSAttributedString*)getSelectedMaintanceAttrTitle
{
    NSString * maintanceStr = @"维修项目";
    NSString * numStr = [NSString stringWithFormat:@"（%d）",_curMaintances.count];
    NSString * titleStr = [NSString stringWithFormat:@"%@%@",maintanceStr,numStr];
    NSMutableAttributedString * attrString = [[NSMutableAttributedString alloc] initWithString:titleStr];
    NSRange range1 = [titleStr rangeOfString:maintanceStr];
    NSRange range2 = [titleStr rangeOfString:numStr];
    [attrString addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:16 weight:UIFontWeightMedium] range:[titleStr rangeOfString:titleStr]];
    [attrString addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1] range:range1];
    [attrString addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:244/255.0 green:82/255.0 blue:59/255.0 alpha:1] range:range2];
    return attrString;
}

-(NSAttributedString*)getGoodsAttrTitle
{
    NSString * goodsStr = @"维修配件";
    NSString * numStr = [NSString stringWithFormat:@"（%d）",_goodsArray.count];
    NSString * titleStr = [NSString stringWithFormat:@"%@%@",goodsStr,numStr];
    NSMutableAttributedString * attrString = [[NSMutableAttributedString alloc] initWithString:titleStr];
    NSRange range1 = [titleStr rangeOfString:goodsStr];
    NSRange range2 = [titleStr rangeOfString:numStr];
    [attrString addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:16 weight:UIFontWeightRegular] range:[titleStr rangeOfString:titleStr]];
    [attrString addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1] range:range1];
    [attrString addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:244/255.0 green:82/255.0 blue:59/255.0 alpha:1] range:range2];
    return attrString;
}

-(NSAttributedString*)getSelectedGoodsAttrTitle
{
    NSString * goodsStr = @"维修配件";
    NSString * numStr = [NSString stringWithFormat:@"（%d）",_goodsArray.count];
    NSString * titleStr = [NSString stringWithFormat:@"%@%@",goodsStr,numStr];
    NSMutableAttributedString * attrString = [[NSMutableAttributedString alloc] initWithString:titleStr];
    NSRange range1 = [titleStr rangeOfString:goodsStr];
    NSRange range2 = [titleStr rangeOfString:numStr];
    [attrString addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:16 weight:UIFontWeightMedium] range:[titleStr rangeOfString:titleStr]];
    [attrString addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1] range:range1];
    [attrString addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:244/255.0 green:82/255.0 blue:59/255.0 alpha:1] range:range2];
    return attrString;
}


-(void)updateSevice
{
    __weak MaintanceAndAccessoryViewController * weakself = self;
    [[NetWorkAPIManager defaultManager] updateService:self.curSevice success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakself.view showHint:@"工单更新成功"];
            [self querySevice];
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

-(void)querySevice
{
    __weak MaintanceAndAccessoryViewController * weakself = self;
    [[NetWorkAPIManager defaultManager] queryService:[[self.curSevice objectForKey:@"id"] integerValue] success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary * resp = responseObject;
        NSDictionary * data = [[resp objectForKey:@"data"] firstObject];
        weakself.curSevice = [NSMutableDictionary dictionaryWithDictionary:data];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakself.view showHint:@"获取工单失败"];
            [self querySevice];
        });
    }];
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

-(void)select:(NSDictionary *)maintance
{
    [self addMaintance:[NSMutableDictionary dictionaryWithDictionary:maintance]];
}

-(void)tableviewcell:(MaintanceTableViewCell*)cell needExtend:(BOOL)isExtend
{
    [self.maintenanceTableView reloadData];
}

-(void)tableviewcell:(MaintanceTableViewCell*)cell didDeleteAtIndex:(NSInteger)index
{
    [self.curMaintances removeObjectAtIndex:index];
    [self.maintenanceTableView reloadData];
    [self setTabViewItems];
}

-(void)tableviewcellBecomeFirstResponder:(CGRect)rect
{
    
    _firstResponderRect = rect;
}
-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    CGPoint point = scrollView.contentOffset;
    if (point.x == 0) {
        [self.tabView setIndex:0];
    }else {
        [self.tabView setIndex:1];
    }
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
            _tableViewOriginOffset = self.maintenanceTableView.contentOffset;
            [self.maintenanceTableView setContentOffset:CGPointMake(_tableViewOriginOffset.x,_tableViewOriginOffset.y + offset)];
            
        }];
    }
  
}

//键盘退出后将视图恢复
-(void)keyboardWillHide:(NSNotification *)notification
{
    [self.maintenanceTableView setContentOffset:_tableViewOriginOffset];
}

-(void)tabview:(CommonTabView *)tabview indexChanged:(NSInteger )index
{
    self.midScrollView.contentOffset = CGPointMake(index*self.midScrollView.frame.size.width, 0);
}
@end
