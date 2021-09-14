//
//  AddMaintanceViewController.m
//  EnochCar
//
//  Created by 王海燕 on 2021/5/31.
//

#import "AddMaintanceViewController.h"
#import "PopViewController.h"
#import "NetWorkAPIManager.h"
#import "ComplexBox.h"
#import "CommonTool.h"

@interface AddMaintanceViewController ()<UITextFieldDelegate,PopViewDelagate>
@property(nonatomic,readwrite,strong)ComplexBox * nameBox;
@property(nonatomic,readwrite,strong)ComplexBox * categoryBox;
//@property(nonatomic,readwrite,strong)UITextField * nameTF;
//@property(nonatomic,readwrite,strong)UITextField * categoryTF;
@property(nonatomic,readwrite,strong)NSMutableArray * categorys;
@property(nonatomic,readwrite,strong)NSDictionary * curCategory;

@property(nonatomic,strong)NSMutableDictionary * maintenance;
@end

@implementation AddMaintanceViewController

-(instancetype)init
{
    self = [super init];
    if (self) {
        _maintenance = nil;
    }
    return self;
}

-(instancetype)initWithData:(NSMutableDictionary *)data
{
    self = [super init];
    if (self) {
        _maintenance = [NSMutableDictionary dictionaryWithDictionary:data];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    if (self.maintenance) {
        self.midTitle = @"编辑项目";
    }else {
        self.midTitle = @"创建项目";
    }
 
    UIButton * saveBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height - 74, self.view.bounds.size.width, 74)];
    [saveBtn setTitle:@"保存" forState:UIControlStateNormal];
    [saveBtn setTitleColor:[UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1] forState:UIControlStateNormal];
    saveBtn.titleLabel.font = [UIFont fontWithName:@"PingFang SC" size:18];
    saveBtn.backgroundColor = [UIColor whiteColor];
    saveBtn.layer.cornerRadius = 4;
    [saveBtn addTarget:self action:@selector(save) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:saveBtn];
    
    NSInteger left = 20;
    NSInteger right = 20;
    NSInteger space = 12;
    CGSize size = self.view.bounds.size;
    //项目类别，项目名称
    __weak AddMaintanceViewController * weakself = self;
    
    UILabel * categoryLab = [[UILabel alloc] initWithFrame:CGRectMake(left, 108, 64, 36)];
    categoryLab.text = @"项目类别";
    categoryLab.font = [UIFont fontWithName:@"PingFang SC" size:16];
    categoryLab.textColor = [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1];
    categoryLab.textAlignment = NSTextAlignmentLeft;
    [self.view addSubview:categoryLab];
    
    _categoryBox = [[ComplexBox alloc] initWithFrame:CGRectMake(96, 108, (size.width - right - 96), 36) mode:ComplexBoxSelect];
    _categoryBox.delegate = self;
    _categoryBox.selectBlock = ^{
        [weakself selecCategory];
    };
    [self.view addSubview:_categoryBox];
    
    UILabel * nameLab = [[UILabel alloc] initWithFrame:CGRectMake(left, (108 + 36 + 12), 64, 36)];
    nameLab.text = @"项目名称";
    nameLab.font = [UIFont fontWithName:@"PingFang SC" size:16];
    nameLab.textColor = [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1];
    nameLab.textAlignment = NSTextAlignmentLeft;
    [self.view addSubview:nameLab];
    
    _nameBox = [[ComplexBox alloc] initWithFrame:CGRectMake(96, nameLab.frame.origin.y, (size.width - right - 96), 36) mode:ComplexBoxEdit];
    _nameBox.delegate = self;
    [self.view addSubview:_nameBox];
    
    _categorys = [NSMutableArray array];
    [self queryMaintanceCategory];
    
    if (self.maintenance) {
        [_nameBox setText:[self.maintenance objectForKey:@"name"]];
        [_categoryBox setText:[[self.maintenance objectForKey:@"category"] objectForKey:@"name"]];
    }
        
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(taponbg:)];
    [self.view addGestureRecognizer:tap];
    
}

-(void)taponbg:(UIGestureRecognizer *)gesture
{
    [self resign];
}

-(void)resign
{
    UIWindow * keyWindow = [[UIApplication sharedApplication] keyWindow];
    UIView * firstResponder = [keyWindow performSelector:@selector(firstResponder)];
    [firstResponder resignFirstResponder];
}

- (void)selecCategory
{
    NSMutableArray * popStrings = [NSMutableArray array];
    for (NSDictionary * ainfo in _categorys) {
        NSString * str = [ainfo objectForKey:@"name"];
        [popStrings addObject:str];
    }
    PopViewController * popCtrl = [[PopViewController alloc] initWithTitle:@"维修类别" Data:popStrings];
    popCtrl.delegate = self;
    popCtrl.view.tag = 1;
    [self.navigationController addChildViewController:popCtrl];
    [self.navigationController.view addSubview:popCtrl.view];
}

-(BOOL)check
{
    if (![self.categoryBox getText] || [self.categoryBox getText].length < 1) {
        
        return NO;
    }
    if (![self.nameBox getText] || [self.nameBox getText].length < 1) {
        
        return NO;
    }
    return YES;
}

- (void)save
{
    if ([self check]) {
        
        if (self.maintenance) {
            [self.maintenance setValue:[self.nameBox getText] forKey:@"name"];
//            [self.maintenance setValue:_curCategory forKey:@"category"];
            if ([self.delegate respondsToSelector:@selector(changeMaintenance:)]) {
                [self.delegate changeMaintenance:self.maintenance];
            }
            [self.navigationController popViewControllerAnimated:YES];
            
        }else {
            NSMutableDictionary * info = [NSMutableDictionary dictionary];
            [info setValue:[self.nameBox getText] forKey:@"name"];
            [info setValue:[NSArray arrayWithObject:[_curCategory objectForKey:@"id"]] forKey:@"categoryIds"];
            [[NetWorkAPIManager defaultManager] createMaintanceCategory:info success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                
                [self.navigationController popViewControllerAnimated:YES];
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                
            }];
        }
        
    }else {
        
        [self showHint:@"请完善信息"];
    }
    
}

-(void)queryMaintanceCategory
{
    __weak AddMaintanceViewController * weakself = self;
    
    [[NetWorkAPIManager defaultManager] queryMaintanceCategorysuccess:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary * dic = responseObject;
        NSArray * array = [dic objectForKey:@"data"];
        [_categorys removeAllObjects];
        [_categorys addObjectsFromArray:array];

    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        [weakself showHint:@"创建失败"];
    }];
    
}

-(void)popview:(UIViewController *)popview disSelectRowAtIndex:(NSInteger)index
{
    _curCategory = [_categorys objectAtIndex:index];
    _categoryBox.text = [_curCategory objectForKey:@"name"];
    if (_maintenance) {
        [_maintenance setObject:_curCategory forKey:@"category"];
    }
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];//收起键盘
    return YES;
}

@end
