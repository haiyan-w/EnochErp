//
//  MaintanceViewController.m
//  EnochCar
//
//  Created by 王海燕 on 2021/5/12.
//

#import "MaintanceViewController.h"
#import "AddMaintanceViewController.h"
//#import "ItemCollectionViewCell.h"
#import "CommonTool.h"
#import "NetWorkAPIManager.h"
#import "MaintanceTableViewCell.h"

#import "NotFoundView.h"
#import "LoadingView.h"
#import "NetWorkOffView.h"

#define ROW_HEIGHT 36

@interface MaintanceViewController ()<UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate,UIGestureRecognizerDelegate>
@property(nonatomic, readwrite, strong) UITableView * tableview;
@property(nonatomic, readwrite, strong) NSMutableArray * maintances;
@property(nonatomic,readwrite,strong) UITextField * searchTF;

@property(nonatomic,readwrite,assign) CGFloat tableMaxH;

@property(nonatomic,readwrite,strong)NotFoundView * notfoundView;
@property(nonatomic,readwrite,strong) LoadingView* loadingView;
@property(nonatomic,readwrite,strong) NetWorkOffView* netOffView;
@end

@implementation MaintanceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.midTitle = @"选择项目";
//    [self setTitle:@"项目"];
    
    UIButton * addBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height - 74, self.view.bounds.size.width, 74)];
    [addBtn setTitle:@"新增项目" forState:UIControlStateNormal];
    [addBtn setTitleColor:[UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1] forState:UIControlStateNormal];
    addBtn.titleLabel.font = [UIFont systemFontOfSize:18 weight:UIFontWeightSemibold];
    addBtn.backgroundColor = [UIColor whiteColor];
    addBtn.layer.cornerRadius = 4;
    [addBtn addTarget:self action:@selector(addItem) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:addBtn];
    
    
    NSInteger left = 20;
    NSInteger top = 20;
    NSInteger space = 12;
    
    CGFloat searchY = [CommonTool topbarH] + top;
    
    UIView * searchView = [[UIView alloc] initWithFrame:CGRectMake(left, searchY, (self.view.bounds.size.width - 2*left), 36)];
    searchView.backgroundColor = [UIColor whiteColor];
    searchView.layer.cornerRadius = 4;
    [self.view addSubview:searchView];
    
    UIImageView * searchIcon = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 40, 36)];
    [searchIcon setImage:[UIImage imageNamed:@"search"]];
    [searchView addSubview:searchIcon];
    
    _searchTF = [[UITextField alloc] initWithFrame:CGRectMake(searchIcon.frame.size.width, (searchView.frame.size.height - 26)/2, (searchView.bounds.size.width-searchIcon.frame.size.width-space), 26)];
    _searchTF.backgroundColor = [UIColor clearColor];
    _searchTF.font = [UIFont fontWithName:@"PingFang SC" size:14];
    _searchTF.layer.cornerRadius = 4;
    _searchTF.placeholder = @"请输入项目名称";
    _searchTF.delegate = self;
    _searchTF.returnKeyType = UIReturnKeySearch;
    [_searchTF addTarget:self action:@selector(searchChanged:) forControlEvents:UIControlEventEditingChanged];
    [searchView addSubview:_searchTF];
     
    NSInteger orgY = searchView.frame.origin.y + searchView.frame.size.height + space;
    self.tableMaxH = self.view.bounds.size.height - orgY- 20 - addBtn.frame.size.height;
    _tableview = [[UITableView alloc] initWithFrame:CGRectMake(20, orgY, self.view.bounds.size.width-2*20, self.view.bounds.size.height - orgY- 20 - addBtn.frame.size.height)];
//    _tableview = [[UITableView alloc] initWithFrame:CGRectMake(20, orgY, self.view.bounds.size.width-2*20, 0)];
    _tableview.layer.cornerRadius = 4;
    _tableview.delegate = self;
    _tableview.dataSource = self;
    _tableview.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    _tableview.showsVerticalScrollIndicator = NO;
    _tableview.showsHorizontalScrollIndicator = NO;
    [_tableview registerClass:[UITableViewCell class] forCellReuseIdentifier:@"TableViewCell"];
    [self.view addSubview:_tableview];
    
    _maintances = [NSMutableArray array];
//    [self queryMaintancesBy:@""];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self queryMaintancesBy:self.searchTF.text];
}

-(NotFoundView*)notfoundView
{
    if (!_notfoundView) {
        CGRect frame = self.tableview.frame;
        _notfoundView = [[NotFoundView alloc] initWithFrame:CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, self.tableMaxH)];
    }
    return _notfoundView;
}

-(LoadingView*)loadingView
{
    if (!_loadingView) {
        CGRect frame = self.tableview.frame;
        _loadingView = [[LoadingView alloc] initWithFrame:CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, self.tableMaxH)];
    }
    return _loadingView;
}

-(NetWorkOffView*)netOffView
{
    if (!_netOffView) {
        CGRect frame = self.tableview.frame;
        _netOffView = [[NetWorkOffView alloc] initWithFrame:CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, self.tableMaxH) refreshBlock:^{
            [self queryMaintancesBy:self.searchTF.text];
        }];
    }
    return _netOffView;
}

-(void)addItem
{
    AddMaintanceViewController * addCtrl = [[AddMaintanceViewController alloc] init];
    
    [self.navigationController pushViewController:addCtrl animated:YES];
    
}

-(void)searchChanged:(UITextField *)textfield
{
    [self queryMaintancesBy:textfield.text];
}

-(void)queryMaintancesBy:(NSString*)string
{
    CGRect frame = self.tableview.frame;
    __weak MaintanceViewController * weakself = self;
    [[NetWorkAPIManager defaultManager] queryMaintenance:string success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSDictionary * resp = responseObject;
        
        NSArray * array  = [resp objectForKey:@"data"];
        [weakself.maintances removeAllObjects];
        [weakself.maintances addObjectsFromArray:array];
        
        dispatch_async(dispatch_get_main_queue(), ^{

            if (weakself.maintances.count == 0) {
                [weakself.view addSubview:weakself.notfoundView];
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
                CGFloat height = (ROW_HEIGHT)*weakself.maintances.count;
                weakself.tableview.frame = CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, (height > weakself.tableMaxH)?weakself.tableMaxH:height);
                [weakself.tableview reloadData];
            }
            
        });
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [weakself.view addSubview:weakself.netOffView];
    }];
    
    [self.view addSubview:self.loadingView];
}



//返回上一级页面
-(void)back
{
    [self.navigationController   popViewControllerAnimated:YES];
}


#pragma mark - UITableViewDelagate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return ROW_HEIGHT;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.maintances.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"TableViewCell"];
    cell.textLabel.text = [[self.maintances objectAtIndex:indexPath.row] objectForKey:@"name"];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.delegate select:[self.maintances objectAtIndex:indexPath.row]];
    [self.navigationController popViewControllerAnimated:YES];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];//收起键盘
    return YES;
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

@end
