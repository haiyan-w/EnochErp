//
//  VehicleBrandViewController.m
//  EnochCar
//
//  Created by HAIYAN on 2021/6/2.
//

#import "VehicleBrandViewController.h"
#import "VehicleBrandTableViewCell.h"
#import "NetWorkAPIManager.h"

@interface VehicleBrandViewController ()<UITableViewDelegate,UITableViewDataSource>
@property(strong,nonatomic)NSMutableArray * allBrands;
@property(strong,nonatomic)NSMutableArray * datasource;
@property(strong,nonatomic)UITableView * tableview;
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
        _datasource = _allBrands;
        _depth = 2;
        _curdepth = 1;
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
//    NSInteger maxH = self.view.bounds.size.height - 88-44 -titleH;
    NSInteger maxH = [UIScreen mainScreen].bounds.size.height*2/3 -titleH - 44;
    NSInteger cellH = 33;
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

////直接返回上一级页面，上级页面的输入保持不变
//-(void)back
//{
//    [self.navigationController popViewControllerAnimated:YES];
//}

//返回上一级选择
-(void)backToLast
{
    _curdepth -=1;
    _backBtn.hidden = YES;
    self.datasource = self.allBrands;
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

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    return self.datasource.count;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    VehicleBrandTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"VehicleBrandTableViewCell"];
    if (!cell) {
        [tableView registerNib:[UINib nibWithNibName:@"VehicleBrandTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"VehicleBrandTableViewCell"];
        cell = [tableView dequeueReusableCellWithIdentifier:@"VehicleBrandTableViewCell"];
    }
    cell.namelab.text = [[self.datasource objectAtIndex:indexPath.row] objectForKey:@"name"];
    NSArray * models = [[self.datasource objectAtIndex:indexPath.row] objectForKey:@"models"];
    if (models.count > 0) {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{

    return 33;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary * data = [self.datasource objectAtIndex:indexPath.row];
    if(_curdepth == _depth){
//        [self.delegate disSelectModel:[NSString stringWithFormat:@"%@/%@",_titleLab.text, [data objectForKey:@"name"]]];
        [self.delegate disSelectModel:[NSArray arrayWithObjects:_titleLab.text, [data objectForKey:@"name"], nil]];
        [self dismiss];
        
    }else {
        
        NSArray * models = [data objectForKey:@"models"];
        _curdepth +=1;
        _titleLab.text = [data objectForKey:@"name"];
        self.datasource = models;
        _backBtn.hidden = NO;
        [self.tableview reloadData];
    }
    
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


@end
