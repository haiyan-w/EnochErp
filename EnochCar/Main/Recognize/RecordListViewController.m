//
//  RecordListViewController.m
//  EnochCar
//
//  Created by 王海燕 on 2021/6/11.
//

#import "RecordListViewController.h"
#import "CommonTabView.h"
#import "RecordListTableViewCell.h"
#import "DataBase.h"
#import "CommonTool.h"


typedef enum
{
    FilterAll,
    FilterPlateNo,
    FilterDriverLicense,
    FilterVIN
}FilterType;

@interface RecordListViewController ()<UITableViewDelegate,UITableViewDataSource,CommonTabViewDelegate>
@property(nonatomic,readwrite,strong)UIButton * backBtn;
@property(nonatomic,readwrite,strong)UITableView * tableview;
@property(nonatomic,readwrite,strong)NSMutableArray * allDatas;
@property(nonatomic,readwrite,strong)NSMutableArray * datasource;
@property(nonatomic,readwrite,assign)FilterType filterType;
@end

@implementation RecordListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor blackColor];
    
    [self initDatasources];
    self.filterType = FilterAll;
    
    NSInteger statusbarH = [CommonTool statusbarH];
    NSInteger Width = self.view.bounds.size.width;
    NSInteger Height = self.view.bounds.size.height;
    
    UIButton * backBtn = [[UIButton alloc] initWithFrame:CGRectMake(8, statusbarH, 48, 44)];
    backBtn.backgroundColor = [UIColor clearColor];
    [backBtn setImage:[UIImage imageNamed:@"back_white"] forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backBtn];
    
    UILabel * titleLab = [[UILabel alloc] initWithFrame:CGRectMake((self.view.bounds.size.width - 120)/2, 52, 120, 24)];
    titleLab.text = @"扫码历史记录";
    titleLab.font = [UIFont fontWithName:@"PingFang SC" size:18];
    titleLab.textColor = [UIColor whiteColor];
    titleLab.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:titleLab];
    
    NSInteger top  = 20;
    NSInteger left = 20;
    NSInteger right = 20;
    CommonTabView * tabView = [[CommonTabView alloc] initWithFrame:CGRectMake(12, 100, 200, 32) target:self];
    [tabView setNormalColor:[UIColor whiteColor]];
    [tabView setSelectedColor:[UIColor colorWithRed:252/255.0 green:215/255.0 blue:139/255.0 alpha:1]];
    CommonTabItem * item1 = [[CommonTabItem alloc] initWithTitle:@"全部"];
    CommonTabItem * item2 = [[CommonTabItem alloc] initWithTitle:@"车牌"];
    CommonTabItem * item3 = [[CommonTabItem alloc] initWithTitle:@"行驶证"];
    CommonTabItem * item4 = [[CommonTabItem alloc] initWithTitle:@"VIN码"];
    [tabView setItems:@[item1, item2, item3, item4]];
    [tabView setIndex:0];
    [self.view addSubview:tabView];

    _tableview = [[UITableView alloc] initWithFrame:CGRectMake(left, tabView.frame.origin.y +tabView.frame.size.height + 12 , self.view.frame.size.width-2*left, self.view.frame.size.height - 128)];
    _tableview.backgroundColor = [UIColor clearColor];
    _tableview.delegate = self;
    _tableview.dataSource = self;
    _tableview.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableview.showsVerticalScrollIndicator = NO;
    _tableview.layer.cornerRadius = 4;
    [_tableview registerNib:[UINib nibWithNibName:@"RecordListTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"RecordListTableViewCell"];
    [self.view addSubview:_tableview];
    
    //右滑返回上级页面
    UISwipeGestureRecognizer * swipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipe:)];
    swipe.direction = UISwipeGestureRecognizerDirectionRight;
    [self.view addGestureRecognizer:swipe];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self closeDatasources];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    //检查是否在tableview 和 button 区域，否则table选中无效
    if ([touch.view isKindOfClass:[UIButton class]]){
        return NO;
    }else if ([NSStringFromClass([touch.view class]) isEqual:@"UITableViewCellContentView"]) {
        return NO;
    }else {
        return YES;
    }
}

-(void)swipe:(UIGestureRecognizer *)gesture
{
    [self.navigationController popViewControllerAnimated:YES];

}

-(void)setFilterType:(FilterType)filterType
{
    [self.datasource removeAllObjects];
    _filterType = filterType;
    switch (_filterType) {
        case FilterAll:
        {
            for (NSDictionary * dic in self.allDatas) {
                NSInteger type = [[dic objectForKey:@"type"] integerValue];
                [self.datasource addObject:dic];
            }
            
        }
            break;
        case FilterPlateNo:
        {
            for (NSDictionary * dic in self.allDatas) {
                NSInteger type = [[dic objectForKey:@"type"] integerValue];
                if (RecognizeTypePlateNO == type) {
                    [self.datasource addObject:dic];
                }
            }
        }
            break;
        case FilterDriverLicense:
        {
            for (NSDictionary * dic in self.allDatas) {
                NSInteger type = [[dic objectForKey:@"type"] integerValue];
                if (RecognizeTypeDrivingLicence == type) {
                    [self.datasource addObject:dic];
                }
            }
        }
            break;
        case FilterVIN:
        {
            for (NSDictionary * dic in self.allDatas) {
                NSInteger type = [[dic objectForKey:@"type"] integerValue];
                if (RecognizeTypeVIN == type) {
                    [self.datasource addObject:dic];
                }
            }
        }
            break;
            
        default:
            break;
    }
    
    [self.tableview reloadData];
    
}

-(void)initDatasources
{
    [[DataBase defaultDataBase] openRecognizeList];
    self.allDatas = [NSMutableArray arrayWithArray:[[DataBase defaultDataBase] getAll]];
    self.datasource = [NSMutableArray arrayWithArray:self.allDatas];
}

-(void)closeDatasources
{
    [[DataBase defaultDataBase] close];
}

-(void)back
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 75;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.datasource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    RecordListTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"RecordListTableViewCell"];
    if (!cell) {
        [tableView registerNib:[UINib nibWithNibName:@"RecordListTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"RecordListTableViewCell"];
        cell = [tableView dequeueReusableCellWithIdentifier:@"RecordListTableViewCell"];
    }

    [cell configData:[self.datasource objectAtIndex:indexPath.row]];
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (NSArray*)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath
{

    UITableViewRowAction *deleteAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:@"删除" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {

        NSDictionary * adata = [self.datasource objectAtIndex:indexPath.row];
        NSInteger ID = [[adata objectForKey:@"id"] integerValue];
        
        NSDictionary * deleteDic = nil;
        if([[DataBase defaultDataBase] deleteARecognize:ID])
        {
            [self.datasource removeObjectAtIndex:indexPath.row];
            for (NSDictionary * dic in self.allDatas) {
                if (ID == [[dic objectForKey:@"id"] integerValue]) {
                    deleteDic = dic;
                }
            }
            [self.allDatas removeObject:deleteDic];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableview reloadData];
            
        });
}];
    return @[deleteAction];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    editingStyle = UITableViewCellEditingStyleDelete;

}

-(void)tabview:(CommonTabView *)tabview indexChanged:(NSInteger )index
{
    switch (index) {
        case 0:
        {
            self.filterType = FilterAll;
        }
            break;
        case 1:
        {
            self.filterType = FilterPlateNo;
        }
            break;
        case 2:
        {
            self.filterType = FilterDriverLicense;
        }
            break;
        case 3:
        {
            self.filterType = FilterVIN;
        }
            break;
            
        default:
            break;
    }
    
}

@end
