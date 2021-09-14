//
//  VehicleBrandViewController.m
//  EnochCar
//
//  Created by HAIYAN on 2021/6/2.
//

#import "VehicleBrandViewController.h"
#import "VehicleBrandTableViewCell.h"
#import "NetWorkAPIManager.h"
#import "IndexView.h"

@interface VehicleBrandViewController ()<UITableViewDelegate,UITableViewDataSource,IndexViewDelegate,IndexViewDataSource>
@property(strong,nonatomic)NSMutableArray * allBrands;
@property(strong,nonatomic)NSMutableArray * indexArray;
@property(strong,nonatomic)NSArray * letterArray;
@property(strong,nonatomic)NSMutableArray * datasource;
@property(strong,nonatomic)UITableView * tableview;
@property(nonatomic,readwrite,strong)IndexView * indexView;
@property(nonatomic,readwrite,strong)UIView * contentView;
@property(nonatomic,readwrite,strong)UIButton * backBtn;
@property(nonatomic,readwrite,strong)UILabel * titleLab;
@property(assign,nonatomic)NSInteger depth;
@property(assign,nonatomic)NSInteger curdepth;
@end

@implementation VehicleBrandViewController


-(instancetype)initWithBrands:(NSArray *)brands
{
    self = [super init];
    if (self) {
        _allBrands = [NSMutableArray arrayWithArray:brands];
//        _datasource = _allBrands;
        _indexArray = [self arrayWithFirstLetterFormat:brands];
        _datasource = _indexArray;
        _depth = 2;
        self.curdepth = 1;
    }
    return self;
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor colorWithRed:55/255.0 green:55/255.0 blue:55/255.0 alpha:0.5];
    
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(taponbg:)];
    tap.delegate = self;
    [self.view addGestureRecognizer:tap];
    
    NSInteger titleH = 40;
    NSInteger bottomH = 20;
    NSInteger maxH = [UIScreen mainScreen].bounds.size.height*0.73 -titleH - 44;
    NSInteger cellH = 40;
    NSInteger tableH = cellH * (self.datasource.count);
    if (tableH > maxH) {
        tableH = maxH;
    }
    
    NSInteger contentH = titleH + tableH +44;
    
   _contentView = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height - contentH, self.view.bounds.size.width, contentH)];
    _contentView.backgroundColor = [UIColor whiteColor];
    _contentView.layer.cornerRadius = 12;
    [self.view addSubview:_contentView];
    
    _backBtn = [[UIButton alloc] initWithFrame:CGRectMake(12, 12, 24, 24)];
    _backBtn.backgroundColor = [UIColor clearColor];
    [_backBtn setImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
    [_backBtn addTarget:self action:@selector(backToLast) forControlEvents:UIControlEventTouchUpInside];
    _backBtn.hidden = YES;
    [_contentView addSubview:_backBtn];
    
    _titleLab = [[UILabel alloc] initWithFrame:CGRectMake(48, 12, (self.view.bounds.size.width - 2*48), 24)];
    _titleLab.text = @"选择车型";
    _titleLab.font = [UIFont fontWithName:@"PingFang SC" size:14];
    _titleLab.textColor = [UIColor colorWithRed:191/255.0 green:191/255.0 blue:191/255.0 alpha:1];
    _titleLab.textAlignment = NSTextAlignmentCenter;
    [_contentView addSubview:_titleLab];
    
    _tableview = [[UITableView alloc] initWithFrame:CGRectMake(0, titleH, self.view.bounds.size.width, tableH)];
    _tableview.dataSource = self;
    _tableview.delegate = self;
    _tableview.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableview.showsVerticalScrollIndicator = NO;
    _tableview.showsHorizontalScrollIndicator = NO;
    [_tableview registerNib:[UINib nibWithNibName:@"VehicleBrandTableViewCell" bundle:NULL] forCellReuseIdentifier:@"VehicleBrandTableViewCell"];
    
    [_contentView addSubview:_tableview];
    
    [_tableview reloadData];
    
    [self initIndexView];
}

-(void)initIndexView
{
    NSInteger indexH = 19*self.letterArray.count;
    NSInteger maxH = self.tableview.frame.size.height;
    NSInteger orgY = self.tableview.frame.origin.y + (maxH - indexH)/2;
    
    self.indexView = [[IndexView alloc] initWithFrame:CGRectMake(self.contentView.frame.size.width - 32, orgY, 32, 19*self.letterArray.count)];
    self.indexView.delegate = self;
    self.indexView.dataSource = self;
    [self.contentView addSubview:self.indexView];
    [self.indexView reload];
    [self.indexView setSelectionIndex:0];
}

-(void)setCurdepth:(NSInteger)curdepth
{
    _curdepth = curdepth;
    if (curdepth == 1) {
        self.indexView.hidden = NO;
        [self.indexView setSelectionIndex:0];
    }else {
        self.indexView.hidden = YES;
    }
    
}

-(void)taponbg:(UIGestureRecognizer*)gesture
{
    [self dismiss];
    
}

-(void)dismiss{
//    [self dismissViewControllerAnimated:YES completion:NULL];
    [self.view removeFromSuperview];
    [self removeFromParentViewController];
}

//返回上一级选择
-(void)backToLast
{
    self.curdepth -=1;
    _backBtn.hidden = YES;
    self.datasource = self.indexArray;
    _titleLab.text = @"选择车型";
    [self.tableview reloadData];
}

-(void)queryVehicleBrand
{
    __weak VehicleBrandViewController * weakself = self;
    
    [[NetWorkAPIManager defaultManager] queryVehicleBrandsuccess:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary * resp = responseObject;
        NSArray * array = [resp objectForKey:@"data"];
        [_allBrands removeAllObjects];
        [_allBrands addObjectsFromArray:array];
        
        
        _datasource = _allBrands;
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakself.tableview reloadData];
        });
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
    }];  
}

#pragma mark - UITableViewDelagate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (_curdepth == 1) {
        return self.datasource.count;
    }else {
        return 1;
    }
}

- (nullable NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (_curdepth == 1) {
        NSString * title = [self.letterArray objectAtIndex:section];
        return title;
    }else {
        return nil;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (_curdepth == 1) {
        return [[self.datasource objectAtIndex:section] count];
    }else {
        return self.datasource.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
   
    NSDictionary * celldata =nil;
    
    if (_curdepth == 1) {
        NSArray * array = [self.datasource objectAtIndex:indexPath.section];
        celldata = [array objectAtIndex:indexPath.row];
    }else {
        celldata = [self.datasource objectAtIndex:indexPath.row];
    }
    
    VehicleBrandTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"VehicleBrandTableViewCell"];
    if (!cell) {
        [tableView registerNib:[UINib nibWithNibName:@"VehicleBrandTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"VehicleBrandTableViewCell"];
        cell = [tableView dequeueReusableCellWithIdentifier:@"VehicleBrandTableViewCell"];
    }
    cell.namelab.text = [celldata objectForKey:@"name"];
    NSArray * models = [celldata objectForKey:@"models"];
    cell.accessoryType = UITableViewCellAccessoryNone;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 40;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(_curdepth == _depth){
        NSDictionary * data = [self.datasource objectAtIndex:indexPath.row];
        [self.delegate disSelectModel:[NSArray arrayWithObjects:_titleLab.text, [data objectForKey:@"name"], nil]];
        [self dismiss];
        
    }else {
        NSDictionary * data = [[self.datasource objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
        NSArray * models = [data objectForKey:@"models"];
        self.curdepth +=1;
        _titleLab.text = [data objectForKey:@"name"];
        self.datasource = [NSMutableArray arrayWithArray:models];
        _backBtn.hidden = NO;
        [self.tableview reloadData];
    }
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section {
    [self.indexView tableView:tableView willDisplayHeaderView:view forSection:section];
}

- (void)tableView:(UITableView *)tableView didEndDisplayingHeaderView:(UIView *)view forSection:(NSInteger)section {
    [self.indexView tableView:tableView didEndDisplayingHeaderView:view forSection:section];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self.indexView scrollViewDidScroll:scrollView];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    CGPoint pt = [touch locationInView:self.view];
    
    CGRect rc= self.contentView.frame;
    
    if (CGRectContainsPoint(rc, pt)) {
        
        return NO;
    }
    return YES;
}

-(NSMutableArray *)arrayWithFirstLetterFormat:(NSArray *)dataArray
{
    NSMutableDictionary * indexDic = [[NSMutableDictionary alloc] init];
    for (NSDictionary * adata in dataArray) {
        NSString * nameHint = [[[adata objectForKey:@"nameHint"] substringToIndex:1] capitalizedString];
        NSMutableArray * indexData = [indexDic objectForKey:nameHint];
        if (indexData) {
            [indexData addObject:adata];
        }else {
            [indexDic setObject:[NSMutableArray array] forKey:nameHint];
        }
    }

    //首字母排序
    self.letterArray = [indexDic keysSortedByValueUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        NSString *letter1 = [[[obj1 firstObject] objectForKey:@"nameHint"] substringToIndex:1];
        NSString *letter2 = [[[obj2 firstObject] objectForKey:@"nameHint"] substringToIndex:1];
        if ([letter1 characterAtIndex:0] < [letter2 characterAtIndex:0]) {
             return NSOrderedAscending;
         }
         return NSOrderedDescending;
    }];
    
    NSMutableArray * arr = [NSMutableArray array];
    for (NSString * key in self.letterArray) {
        [arr addObject:[indexDic objectForKey:key]];
    }
    
    return arr;
}


-(NSArray<NSString*>*)sectionIndexTitles
{
    return self.letterArray;
}

//当前选中组
- (void)selectedSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
    [self.tableview scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:index] atScrollPosition:UITableViewScrollPositionTop animated:NO];
}

////将指示器视图添加到当前视图上
//- (void)addIndicatorView:(UIView *)view {
//    [self.view addSubview:view];
//}

@end
