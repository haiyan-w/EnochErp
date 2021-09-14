//
//  SearchResultView.m
//  EnochCar
//
//  Created by 王海燕 on 2021/5/21.
//

#import "SearchResultView.h"
#import "SearchResultTableViewCell.h"
#import "NetWorkAPIManager.h"
#import "CommonTabView.h"
#import "NotFoundView.h"
#import "LoadingView.h"
#import "NetWorkOffView.h"

typedef enum
{
    SearchAll,
    SearchPlateNo,
    SearchName,
    SearchVIN
}SearchType;

@interface SearchResultView()<UITableViewDelegate,UITableViewDataSource,CommonTabViewDelegate>
@property(nonatomic,readwrite,strong)UIButton * closeBtn;
@property(nonatomic,readwrite,strong)UITableView * tableview;
@property(nonatomic,readwrite,strong)NSMutableArray * datasource;
@property(nonatomic,readwrite,copy)NSString * curSearchText;
@property(nonatomic,readwrite,strong)NSDictionary * curData;
@property(nonatomic,readwrite,assign)NSInteger curIndex;//过滤搜索结果s
@property(nonatomic,readwrite,assign)SearchType searchType;

@property(nonatomic,readwrite,strong)UIView * resultView;
@property(nonatomic,readwrite,strong)NotFoundView * notfoundView;
@property(nonatomic,readwrite,strong) LoadingView* loadingView;
@property(nonatomic,readwrite,strong) NetWorkOffView* netOffView;
@end


@implementation SearchResultView

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithRed:242/255.0 green:242/255.0 blue:242/255.0 alpha:1];
        
        _datasource = [NSMutableArray array];
        
        _resultView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        _resultView.backgroundColor = [UIColor clearColor];
        [self addSubview:_resultView];
        
        NSInteger top  = 20;
        NSInteger left = 20;
        NSInteger right = 20;
        CommonTabView * tabView = [[CommonTabView alloc] initWithFrame:CGRectMake(10, top, 180, 20) target:self];
        CommonTabItem * item1 = [[CommonTabItem alloc] initWithTitle:@"全部"];
        CommonTabItem * item2 = [[CommonTabItem alloc] initWithTitle:@"车牌"];
        CommonTabItem * item3 = [[CommonTabItem alloc] initWithTitle:@"姓名"];
        CommonTabItem * item4 = [[CommonTabItem alloc] initWithTitle:@"VIN码"];
        [tabView setItems:@[item1, item2, item3, item4]];
        [tabView setIndex:0];
        [_resultView addSubview:tabView];
        
        _closeBtn = [[UIButton alloc] initWithFrame:CGRectMake(frame.size.width - 40 - right, top, 40, 20)];
        [_closeBtn setTitle:@"关闭" forState:UIControlStateNormal];
        _closeBtn.titleLabel.font = [UIFont fontWithName:@"PingFang SC" size:11];
        [_closeBtn setTitleColor:[UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1] forState:UIControlStateNormal];
        _closeBtn.layer.cornerRadius = 4;
        _closeBtn.backgroundColor = [UIColor whiteColor];
        [_closeBtn addTarget:self action:@selector(close) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_closeBtn];
        
        _tableview = [[UITableView alloc] initWithFrame:CGRectMake(left, 60, frame.size.width-2*left, frame.size.height - 60)];
        _tableview.backgroundColor = [UIColor colorWithRed:242/255.0 green:242/255.0 blue:242/255.0 alpha:1];
        _tableview.delegate = self;
        _tableview.dataSource = self;
        _tableview.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableview.showsVerticalScrollIndicator = NO;
        _tableview.showsHorizontalScrollIndicator = NO;
        [_tableview registerNib:[UINib nibWithNibName:@"SearchResultTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"SearchResultTableViewCell"];
        [_resultView addSubview:_tableview];
    }
    return self;
}

-(void)setCurIndex:(NSInteger)curIndex
{
    _curIndex = curIndex;
    switch (_curIndex) {
        case 0:
        {
            self.searchType = SearchAll;
        }
            break;
        case 1:
        {
            self.searchType = SearchPlateNo;
        }
            break;
        case 2:
        {
            self.searchType = SearchName;
        }
            break;
        case 3:
        {
            self.searchType = SearchVIN;
        }
            break;
        default:
            break;
    }
    [self searchData:_curSearchText];
}

-(void)close
{
    [self.delegate searchView:self viewWillRemove:_curData];
    [self.datasource removeAllObjects];
    [self.tableview reloadData];
    [self removeFromSuperview];
}

-(void)searchData:(NSString*)text
{
    [self.datasource removeAllObjects]; 
    
    if (text.length <= 0) {
        text = @"";
    }
    _curSearchText = text;
    NSString * plateNo = nil;
    NSString * name = nil;
    NSString * vin = nil;
    switch (_searchType) {
        case SearchAll:
        {
            plateNo = text;
            name = text;
            vin = text;
        }
            break;
        case SearchPlateNo:
        {
            plateNo = text;
        }
            break;
        case SearchName:
        {
            name = text;
        }
            break;
        case SearchVIN:
        {
            vin = text;
        }
            break;
            
        default:
            break;
    }
    
    __weak SearchResultView * weakself = self;
    
    [[NetWorkAPIManager defaultManager] queryVehicleInfo:name plateNo:plateNo vin:vin success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary * resp = responseObject;
        NSArray * array = [resp objectForKey:@"data"];
        
        [weakself.datasource removeAllObjects];
        [weakself.datasource addObjectsFromArray:array];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if (weakself.datasource.count == 0) {
                [weakself.resultView addSubview:self.notfoundView];
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
                [weakself.tableview reloadData];
            }
        });

    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakself.resultView addSubview:self.netOffView];
        });
        
    }];
    
    [self.resultView addSubview:self.loadingView];
}

-(NotFoundView*)notfoundView
{
    if (!_notfoundView) {
        _notfoundView = [[NotFoundView alloc] initWithFrame:CGRectMake(0, 0, self.resultView.frame.size.width, self.resultView.frame.size.height)];
    }
    return _notfoundView;
}

-(LoadingView*)loadingView
{
    if (!_loadingView) {
        _loadingView = [[LoadingView alloc] initWithFrame:CGRectMake(0, 0, self.resultView.frame.size.width, self.resultView.frame.size.height)];
    }
    return _loadingView;
}

-(NetWorkOffView*)netOffView
{
    if (!_netOffView) {
        _netOffView = [[NetWorkOffView alloc] initWithFrame:CGRectMake(0, 0, self.resultView.frame.size.width, self.resultView.frame.size.height) refreshBlock:^{
            [self searchData:self.curSearchText];
        }];
    }
    return _netOffView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 84;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.datasource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SearchResultTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"SearchResultTableViewCell"];
    if (!cell) {
        [tableView registerNib:[UINib nibWithNibName:@"SearchResultTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"SearchResultTableViewCell"];
        cell = [tableView dequeueReusableCellWithIdentifier:@"SearchResultTableViewCell"];
    }
    cell.searchText = _curSearchText;
    NSDictionary * data = [self.datasource objectAtIndex:indexPath.row];
    [cell configdata:data];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary * data = [self.datasource objectAtIndex:indexPath.row];
    
    [self.delegate searchView:self selectData:data];
    
    
    [self close];
}


- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
   
    [self resign];
}

-(void)resign
{
    UIWindow * keyWindow = [[UIApplication sharedApplication] keyWindow];
    UIView * firstResponder = [keyWindow performSelector:@selector(firstResponder)];
    [firstResponder resignFirstResponder];
}

-(void)tabview:(CommonTabView *)tabview indexChanged:(NSInteger )index
{
    self.curIndex = index;
    
}



@end
