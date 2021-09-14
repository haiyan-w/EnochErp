//
//  SettlementView.m
//  EnochCar
//
//  Created by 王海燕 on 2021/5/20.
//结算页面

#import "SettlementView.h"
#import "NetWorkAPIManager.h"
#import "SeviceTableViewCell.h"
#import "PopMenu.h"
#import "NotFoundView.h"
#import "LoadingView.h"
#import "NetWorkOffView.h"

#define SETTLEMENT_TABLEVIEWCELL_IDENTIFIER  @"SettlementTableViewCellIdentifier"

#define TAG_TABLE_SETTLEMENT 101
#define TAG_MENU_SORT 102
#define TAG_MENU_STATE 103

typedef enum{
    SettlementSeviceFilterALL,
    SettlementSeviceFilterAA,
    SettlementSeviceFilterPD
}SettlementSeviceFilter;

@interface SettlementView()<UITableViewDelegate,UITableViewDataSource,SeviceTableViewCellDelagate>
@property(nonatomic,readwrite,strong)UITableView * tableview;
@property(nonatomic,readwrite,strong)UIRefreshControl *refreshControl;

@property(nonatomic,readwrite,strong)NSMutableArray * dataArray;//工单列表
@property(nonatomic,readwrite,assign)NSInteger curSelectIndex;//当前展开的行
@property(nonatomic,readwrite,assign)NSInteger pageIndex;//当前页
@property(nonatomic,readwrite,assign)NSInteger pageCount;//总页数

@property(nonatomic,readwrite,assign)BOOL reverseSort;//NO按最新时间排序YES倒序
@property(nonatomic,readwrite,assign)SettlementSeviceFilter filter;//按状态排序

@property(nonatomic,readwrite,strong)PopMenu * menu;
@property(nonatomic,readwrite,strong)NSArray * menuStrings;
@property(nonatomic,readwrite,strong)UILabel * sortLab;
@property(nonatomic,readwrite,strong)UIButton * sortBtn;
@property(nonatomic,readwrite,strong)UILabel * stateLab;
@property(nonatomic,readwrite,strong)UIButton * stateBtn;

@property(nonatomic,readwrite,assign)BOOL isLoading;
@property(nonatomic,readwrite,strong)NotFoundView * notfoundView;
@property(nonatomic,readwrite,strong) LoadingView* loadingView;
@property(nonatomic,readwrite,strong) NetWorkOffView* netOffView;

@end

@implementation SettlementView

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithRed:242/255.0 green:242/255.0 blue:242/255.0 alpha:1];
        
        _dataArray = [NSMutableArray array];
        _curSelectIndex = -1;
        _pageCount = 0;
        _pageIndex = 0;
        _reverseSort = NO;
        _isLoading = NO;
        _filter = SettlementSeviceFilterALL;
        
        [self loadData];
        
        NSInteger left = 20;
        NSInteger top = 20;
        NSInteger space = 12;
        
        _sortLab = [[UILabel alloc] initWithFrame:CGRectMake(left, top, 30, 20)];
        _sortLab.text = @"最新";
        _sortLab.font = [UIFont boldSystemFontOfSize:14];
        _sortLab.textColor = [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1];
        _sortLab.textAlignment = NSTextAlignmentRight;
        [self addSubview:_sortLab];
        
        UIImageView * sortDrop = [[UIImageView alloc] initWithFrame:CGRectMake(_sortLab.frame.origin.x + _sortLab.frame.size.width , 0, 16, 20)];
        [sortDrop setImage:[UIImage  imageNamed:@"triangle"]];
        sortDrop.center = CGPointMake(sortDrop.center.x, _sortLab.center.y);
        [self addSubview:sortDrop];
        
        _sortBtn =[[UIButton alloc] initWithFrame:CGRectMake(_sortLab.frame.origin.x, _sortLab.frame.origin.y - 3, _sortLab.frame.size.width+sortDrop.frame.size.width+4, 26)];//放大点击区域
        _sortLab.backgroundColor = [UIColor clearColor];
        [_sortBtn addTarget:self action:@selector(sortBtnClicked) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_sortBtn];
        
        
        _stateLab = [[UILabel alloc] initWithFrame:CGRectMake(sortDrop.frame.origin.x + sortDrop.frame.size.width + 12, _sortLab.frame.origin.y, 45, 20)];
        _stateLab.text = @"状态";
        _stateLab.font = [UIFont boldSystemFontOfSize:14];
        _stateLab.textColor = [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1];
        _stateLab.textAlignment = NSTextAlignmentRight;
        [self addSubview:_stateLab];
        
        UIImageView * stateDrop = [[UIImageView alloc] initWithFrame:CGRectMake(_stateLab.frame.origin.x + _stateLab.frame.size.width, 0, 16, 20)];
        [stateDrop setImage:[UIImage  imageNamed:@"triangle"]];
        stateDrop.center = CGPointMake(stateDrop.center.x, _stateLab.center.y);
        [self addSubview:stateDrop];
        
        _stateBtn =[[ UIButton alloc] initWithFrame:CGRectMake(_stateLab.frame.origin.x, _sortBtn.frame.origin.y, _stateLab.frame.size.width+stateDrop.frame.size.width+4, _sortBtn.frame.size.height)];
        _stateBtn.backgroundColor = [UIColor clearColor];
        [_stateBtn addTarget:self action:@selector(stateBtnClicked) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_stateBtn];
        
        NSInteger tableY = _sortLab.frame.origin.y + _sortLab.frame.size.height + 20;
        _tableview = [[UITableView alloc] initWithFrame:CGRectMake(left, tableY, frame.size.width-2*left, frame.size.height-tableY)];
        _tableview.delegate = self;
        _tableview.dataSource = self;
        _tableview.tag = TAG_TABLE_SETTLEMENT;
        _tableview.showsVerticalScrollIndicator = NO;
        _tableview.showsHorizontalScrollIndicator = NO;
        [_tableview registerNib:[UINib nibWithNibName:@"SeviceTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:SETTLEMENT_TABLEVIEWCELL_IDENTIFIER];
        _tableview.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableview.backgroundColor = [UIColor clearColor];
        [self addSubview:_tableview];
        
        _refreshControl = [[UIRefreshControl alloc]init];
        //下拉刷新时显示的文字
        _refreshControl.attributedTitle = [[NSAttributedString alloc]initWithString:@"下拉刷新"];
        [_refreshControl addTarget:self action:@selector(refreshTableView) forControlEvents:UIControlEventValueChanged];
        _tableview.refreshControl = _refreshControl;
        
    }
    return self;
}

-(NotFoundView*)notfoundView
{
    if (!_notfoundView) {
        _notfoundView = [[NotFoundView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    }
    return _notfoundView;
}

-(LoadingView*)loadingView
{
    if (!_loadingView) {
        _loadingView = [[LoadingView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    }
    return _loadingView;
}

-(NetWorkOffView*)netOffView
{
    if (!_netOffView) {
        _netOffView = [[NetWorkOffView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height) refreshBlock:^{
            [self refreshTableView];
        }];
    }
    return _netOffView;
}

-(void)setReverseSort:(BOOL)reverseSort
{
    if (_reverseSort != reverseSort) {
        _reverseSort = reverseSort;
        self.dataArray = [[_dataArray reverseObjectEnumerator] allObjects];
        [self.tableview reloadData];
    }
}

-(void)setFilter:(SettlementSeviceFilter)filter
{
    if (_filter != filter) {
        _filter = filter;
        _curSelectIndex = -1;
        _pageCount = 0;
        _pageIndex = 0;
        [self loadData];
    }
}

-(NSString*)getFilterStr
{
    NSString * filterStr = @"mobileStatus=A";
    switch (_filter) {
        case SettlementSeviceFilterALL:
        {
            filterStr = @"mobileStatus=A";
        }
            break;
        case SettlementSeviceFilterAA:
        {
            filterStr = @"statusCode=AA";
        }
            break;
        case SettlementSeviceFilterPD:
        {
            filterStr = @"statusCode=PD";
        }
            break;
            
        default:
            break;
    }
    return filterStr;
}

-(void)sortBtnClicked
{
    _menuStrings = [NSArray arrayWithObjects:@"最新",@"最旧", nil];
    PopMenu * menu = [[PopMenu alloc]initWithArrow:CGPointMake(40, 253) menuSize:CGSizeMake(130, 106) arrowStyle:CWPopMenuArrowTopHeader menuStrings:_menuStrings];
        //代理是UITableView的代理方法
    menu.delegate = self;
        //设置菜单的背景色(默认是白色)
    menu.menuViewBgColor = [UIColor whiteColor];
    
    menu.tag = TAG_MENU_SORT;
        //YES代表使用动画
    [menu showMenu:YES];
    
}

-(void)stateBtnClicked
{
    _menuStrings = [NSArray arrayWithObjects:@"全部",@"待结算", @"已结算",nil];
    PopMenu * menu = [[PopMenu alloc]initWithArrow:CGPointMake(120, 253) menuSize:CGSizeMake(130, 154) arrowStyle:CWPopMenuArrowTopCenter menuStrings:_menuStrings];
        //代理是UITableView的代理方法
    menu.delegate = self;
        //设置菜单的背景色(默认是白色)
    menu.menuViewBgColor = [UIColor whiteColor];
    
    menu.tag = TAG_MENU_STATE;
        //YES代表使用动画
    [menu showMenu:YES];
}

-(void)refreshTableView
{
    _pageCount = 0;
    _pageIndex = 0;
    [self loadData];
}

-(void)loadData
{
    self.isLoading = YES;
    NSString * parmstr = [NSString stringWithFormat:@"%@",[self getFilterStr]];
    __weak SettlementView * weakself = self;
    [[NetWorkAPIManager defaultManager] queryRepaireSevice:parmstr success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary * dic  = responseObject;
        NSArray * data = [dic objectForKey:@"data"];
        NSDictionary * page = [[dic objectForKey:@"meta"] objectForKey:@"paging"];
        weakself.pageIndex = [[page objectForKey:@"pageIndex"] integerValue];
        weakself.pageCount = [[page objectForKey:@"pageCount"] integerValue];
        [weakself.dataArray removeAllObjects];
        
        if (weakself.reverseSort) {
            data = [[data reverseObjectEnumerator] allObjects];
        }
        
        for (NSDictionary * item in data) {
            [_dataArray addObject:[NSMutableDictionary dictionaryWithDictionary:item]];
        }
        weakself.isLoading = NO;
        dispatch_async(dispatch_get_main_queue(), ^{
            if (weakself.dataArray.count == 0) {
                [weakself addSubview:self.notfoundView];
            }else {
                if (_notfoundView) {
                    [_notfoundView removeFromSuperview];
                    _notfoundView = nil;
                }
                if (_netOffView) {
                    [_netOffView removeFromSuperview];
                    _netOffView = nil;
                }
                if (_loadingView) {
                    [_loadingView removeFromSuperview];
                    _loadingView = nil;
                }
            }
            [weakself.tableview.refreshControl endRefreshing];
            [weakself.tableview reloadData];
        });
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        weakself.isLoading = NO;
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakself.tableview.refreshControl endRefreshing];
            [weakself.tableview reloadData];
            [weakself addSubview:self.netOffView];
        });
    }];
}

- (void)loadMore
{
    if((_pageIndex < _pageCount)&(_isLoading == NO)){
        __weak SettlementView * weakself = self;
        NSString * parmstr = [NSString stringWithFormat:@"%@&pageIndex=%d",[self getFilterStr],(_pageIndex+1)];
        weakself.isLoading = YES;
        [[NetWorkAPIManager defaultManager] queryRepaireSevice:parmstr success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            NSDictionary * dic  = responseObject;
            NSArray * data = [dic objectForKey:@"data"];
            NSDictionary * page = [[dic objectForKey:@"meta"] objectForKey:@"paging"];
            weakself.pageIndex = [[page objectForKey:@"pageIndex"] integerValue];
            weakself.pageCount = [[page objectForKey:@"pageCount"] integerValue];
            if (self.reverseSort) {
                data = [[data reverseObjectEnumerator] allObjects];
            }
            for (NSDictionary * item in data) {
                [weakself.dataArray addObject:[NSMutableDictionary dictionaryWithDictionary:item]];
            }
            weakself.isLoading = NO;
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakself.tableview reloadData];
            });
            
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            weakself.isLoading = NO;
            
        }];
    }
 
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SeviceTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:SETTLEMENT_TABLEVIEWCELL_IDENTIFIER];
    NSMutableDictionary * adata = [self.dataArray objectAtIndex:indexPath.row];
//    if (self.reverseSort) {
//        adata = [self.dataArray objectAtIndex:(self.dataArray.count - indexPath.row -1)];
//    }
    if (indexPath.row == _curSelectIndex)
    {
        [cell expand:YES];
    }else {
        
        [cell expand:NO];
    }
    cell.delegate = self;
    cell.navCtrl = self.navCtrl;
    [cell configData:adata];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSMutableDictionary * adata = [self.dataArray objectAtIndex:indexPath.row];
    NSInteger expandH = 0;
    if (_curSelectIndex == indexPath.row) {
        NSArray * maintenances = [[adata objectForKey:SEVICE_DETAIL] objectForKey:@"maintenances"];
        
        if (maintenances) {
            NSInteger cellH = 70;
            expandH = cellH*maintenances.count;
        }
    }
    return 187+expandH;
}

//选中展开再选中收起
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    __weak SettlementView * weakself = self;
    NSMutableDictionary * dic = [self.dataArray objectAtIndex:indexPath.row];
    
    if (indexPath.row == _curSelectIndex) {
        _curSelectIndex = -1;
    }else {
        _curSelectIndex = indexPath.row;
        
        if (![dic objectForKey:SEVICE_DETAIL]) {
            [[NetWorkAPIManager defaultManager] queryService:[[dic objectForKey:@"id"] integerValue] success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                NSDictionary * resp = responseObject;
                NSDictionary * data = [[resp objectForKey:@"data"] firstObject];
                [dic setValue:data forKey:SEVICE_DETAIL];

                dispatch_async(dispatch_get_main_queue(), ^{
                    [tableView reloadData];
                });
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {

            }];
        }else {
            [tableView reloadData];
        }
    }
    [tableView reloadData];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    CGFloat currentOffsetY = scrollView.contentOffset.y;
    /*self.refreshControl.isRefreshing == NO加这个条件是为了防止下面的情况发生：
    每次进入UITableView，表格都会沉降一段距离，这个时候就会导致currentOffsetY + scrollView.frame.size.height   > scrollView.contentSize.height 被触发，从而触发loadMore方法，而不会触发refresh方法。
     */
    if ( (currentOffsetY + scrollView.frame.size.height  > scrollView.contentSize.height)&(self.refreshControl.isRefreshing == NO) ){
//        [self.loadMoreView startAnimation];//开始旋转
        [self loadMore];
    }

}

-(void)popMenu:(PopMenu*)menu didSelectAtIndex:(NSInteger)index
{
    switch (menu.tag) {
        case TAG_MENU_SORT:
        {
            if (0 == index) {
                self.reverseSort = NO;
            }else if (1 == index)
            {
                self.reverseSort = YES;
            }
            _sortLab.text = [_menuStrings objectAtIndex:index];
        }
            break;
        case TAG_MENU_STATE:
        {
            if (0 == index) {
               self.filter = SettlementSeviceFilterALL;
            }else if (1 == index)
            {
                self.filter = SettlementSeviceFilterAA;
            }else if (2 == index){
                self.filter = SettlementSeviceFilterPD;
            }
            _stateLab.text = [_menuStrings objectAtIndex:index];
        }
            break;
            
        default:
            break;
    }
}

-(void)tableViewCell:(SeviceTableViewCell*)cell update:(BOOL)update
{
    [self loadData];
}
@end
