//
//  CreateAccessoryViewController.m
//  EnochCar
//
//  Created by 王海燕 on 2021/5/31.
//

#import "CreateAccessoryViewController.h"
#import "NetWorkAPIManager.h"
#import "PopViewController.h"
#import "UIView+Hint.h"
#import "ComplexBox.h"

#define TAG_POPVIEW_CATEGORY 1
#define TAG_POPVIEW_UNIT     2

#define TEXT_CATEFORY_PLACEHOLDER @"请选择"
#define TEXT_UNIT_PLACEHOLDER @"请选择"

@interface CreateAccessoryViewController ()<UITextFieldDelegate,PopViewDelagate>
@property(nonatomic,readwrite,strong)ComplexBox * nameBox;
@property(nonatomic,readwrite,strong)ComplexBox * categoryBox;
@property(nonatomic,readwrite,strong)ComplexBox * unitBox;
@property(nonatomic,readwrite,strong)NSMutableArray * goodsUnit;
@property(nonatomic,readwrite,strong)NSMutableArray * goodsCategory;

@property(nonatomic,readwrite,strong)NSDictionary * curCategory;
@property(nonatomic,readwrite,strong)NSDictionary * curUnit;
@end

@implementation CreateAccessoryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.midTitle = @"添加配件";
    
    _goodsUnit = [NSMutableArray array];
    _goodsCategory = [NSMutableArray array];
    
    _curCategory = nil;
    _curUnit = nil;
    
    [self queryGoodsCategory];
    [self queryGoodsUnit];
    
    
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
    NSInteger height = 36;
    NSInteger labW = 64;
    CGSize size = self.view.bounds.size;
    
    UILabel * nameLab = [[UILabel alloc] initWithFrame:CGRectMake(left, 112, labW, height)];
    nameLab.text = @"配件名称";
    nameLab.font = [UIFont fontWithName:@"PingFang SC" size:16];
    nameLab.textColor = [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1];
    nameLab.textAlignment = NSTextAlignmentLeft;
    [self.view addSubview:nameLab];
    
    __weak CreateAccessoryViewController * weakself = self;
    _nameBox = [[ComplexBox alloc] initWithFrame:CGRectMake(96, nameLab.frame.origin.y, (size.width - right - 96), height) mode:ComplexBoxEdit];
    _nameBox.delegate = self;
    [self.view addSubview:_nameBox];
    
    UILabel * categoryLab = [[UILabel alloc] initWithFrame:CGRectMake(left, 172, labW, height)];
    categoryLab.text = @"配件类别";
    categoryLab.font = [UIFont fontWithName:@"PingFang SC" size:16];
    categoryLab.textColor = [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1];
    categoryLab.textAlignment = NSTextAlignmentLeft;
    [self.view addSubview:categoryLab];
    
    _categoryBox = [[ComplexBox alloc] initWithFrame:CGRectMake(96, 172, (size.width - right - 96), 36) mode:ComplexBoxSelect];
    _categoryBox.delegate = self;
    _categoryBox.selectBlock = ^{
        [weakself selecCategory];
    };
    [self.view addSubview:_categoryBox];
    
    UILabel * unitLab = [[UILabel alloc] initWithFrame:CGRectMake(left, 232, labW, height)];
    unitLab.text = @"基本单位";
    unitLab.font = [UIFont fontWithName:@"PingFang SC" size:16];
    unitLab.textColor = [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1];
    unitLab.textAlignment = NSTextAlignmentLeft;
    [self.view addSubview:unitLab];
    
    _unitBox = [[ComplexBox alloc] initWithFrame:CGRectMake(96, 232, (size.width - right - 96), 36) mode:ComplexBoxSelect];
    _unitBox.delegate = self;
    _unitBox.selectBlock = ^{
        [weakself selecUnit];
    };
    [self.view addSubview:_unitBox];
    
//
//    _nameTF = [[UITextField alloc] initWithFrame:CGRectMake(96, nameLab.frame.origin.y, (size.width - right - 96), height)];
//    UIView * nameLV = [[UIView alloc] initWithFrame:CGRectMake(0, 0, space, 30)];//设置输入框内容到边框的间距
//    nameLV.backgroundColor = [UIColor whiteColor];
//    nameLV.layer.cornerRadius = 4;
//    UIView * nameRV = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 2*space+24, 34)];//设置输入框内容到边框的间距
//    nameRV.backgroundColor = [UIColor clearColor];
//    nameRV.layer.cornerRadius = 4;
//    _nameTF.rightView= nameRV;
//    _nameTF.leftView= nameLV;
//    _nameTF.rightViewMode = UITextFieldViewModeAlways;
//    _nameTF.leftViewMode = UITextFieldViewModeAlways;
////    _nameTF.placeholder = @"";
//    _nameTF.backgroundColor = [UIColor whiteColor];
//    _nameTF.font = [UIFont fontWithName:@"PingFang SC" size:14];
//    _nameTF.layer.cornerRadius = 4;
//    [_nameTF setDelegate:self];
//    [self.view addSubview:_nameTF];
//
//
    
//
//
//
    
//
//    UIView * categoryView = [[UIView alloc] initWithFrame:CGRectMake(96, 172, (size.width - right - 96), 36)];
//    categoryView.backgroundColor = [UIColor whiteColor];
//    categoryView.layer.cornerRadius = 4;
//    [self.view addSubview:categoryView];
//
//    _categoryLab = [[UILabel alloc] initWithFrame:CGRectMake(space, 0, (categoryView.bounds.size.width - space - 36), height)];
//    _categoryLab.text = TEXT_CATEFORY_PLACEHOLDER;
//    _categoryLab.textColor = [UIColor colorWithRed:191/255.0 green:191/255.0 blue:191/255.0 alpha:1];
//    _categoryLab.font = [UIFont fontWithName:@"PingFang SC" size:14];
//    [categoryView addSubview:_categoryLab];
//    UIImageView * dropImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"dropdown"]];
//    [dropImage setFrame:CGRectMake(categoryView.bounds.size.width- 16-12, 10, 16, 16)];
//    [categoryView addSubview:dropImage];
//    UIButton * selCategoryBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, categoryView.bounds.size.width, height)];
//    [selCategoryBtn addTarget:self action:@selector(selecCategory) forControlEvents:UIControlEventTouchUpInside];
//    selCategoryBtn.layer.cornerRadius = 4;
//    [categoryView addSubview:selCategoryBtn];
//
//    UIView * unitView = [[UIView alloc] initWithFrame:CGRectMake(96, 232, (size.width - right - 96), 36)];
//    unitView.backgroundColor = [UIColor whiteColor];
//    unitView.layer.cornerRadius = 4;
//    [self.view addSubview:unitView];
//
//    _unitLab = [[UILabel alloc] initWithFrame:CGRectMake(space, 0, (unitView.bounds.size.width - space - 36), height)];
//    _unitLab.text = TEXT_UNIT_PLACEHOLDER;
//    _unitLab.textColor = [UIColor colorWithRed:191/255.0 green:191/255.0 blue:191/255.0 alpha:1];
//    _unitLab.font = [UIFont fontWithName:@"PingFang SC" size:14];
//    [unitView addSubview:_unitLab];
//    UIImageView * dropImage2 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"dropdown"]];
//    [dropImage2 setFrame:CGRectMake(categoryView.bounds.size.width- 16-12, 10, 16, 16)];
//    [unitView addSubview:dropImage2];
//    UIButton * selUnitBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, unitView.bounds.size.width, height)];
//    [selUnitBtn addTarget:self action:@selector(selecUnit) forControlEvents:UIControlEventTouchUpInside];
//    selUnitBtn.layer.cornerRadius = 4;
//    [unitView addSubview:selUnitBtn];
    
    
    
    
    
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


-(void)selecCategory
{
    NSMutableArray * popStrings = [NSMutableArray array];
    for (NSDictionary * ainfo in _goodsCategory) {
        NSString * str = [ainfo objectForKey:@"name"];
        [popStrings addObject:str];
    }
    PopViewController * popCtrl = [[PopViewController alloc] initWithTitle:@"配件类别" Data:popStrings];
    popCtrl.delegate = self;
    popCtrl.view.tag = TAG_POPVIEW_CATEGORY;
    [self.navigationController addChildViewController:popCtrl];
    [self.navigationController.view addSubview:popCtrl.view];
}

-(void)selecUnit
{
    NSMutableArray * popStrings = [NSMutableArray array];
    for (NSDictionary * ainfo in _goodsUnit) {
        NSString * str = [ainfo objectForKey:@"name"];
        [popStrings addObject:str];
    }
    PopViewController * popCtrl = [[PopViewController alloc] initWithTitle:@"单价" Data:popStrings];
    popCtrl.delegate = self;
    popCtrl.view.tag = TAG_POPVIEW_UNIT;
    [self.navigationController addChildViewController:popCtrl];
    [self.navigationController.view addSubview:popCtrl.view];
}

-(BOOL)check
{
    if ([self.nameBox getText].length < 1) {
        [self.view showHint:@"请完善信息"];
        return NO;
    }else if (!self.curCategory){
        [self.view showHint:@"请完善信息"];
        return NO;
    }else if (!self.curUnit){
        [self.view showHint:@"请完善信息"];
        return NO;
    }
    return YES;
}

- (void)save
{
    if ([self check]) {
        NSMutableDictionary * info = [NSMutableDictionary dictionary];
        [info setValue:[self.nameBox getText] forKey:@"name"];
        [info setValue:_curCategory forKey:@"category"];
        [info setValue:[_curUnit objectForKey:@"name"] forKey:@"warehouseUnit"];
        [[NetWorkAPIManager defaultManager] createGood:info success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            [self.navigationController popViewControllerAnimated:YES];
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.view showHint:@"创建失败"];
            });
        }];
    }  
}

//查询配件类别
-(void)queryGoodsCategory
{
    [[NetWorkAPIManager defaultManager] queryGoodsCategorysuccess:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary * resp = responseObject;
        NSArray * array = [resp objectForKey:@"data"];
        [_goodsCategory removeAllObjects];
        [_goodsCategory addObjectsFromArray:array];

    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {

    }];
    
    
}

//查询基本单位
-(void)queryGoodsUnit
{
    [[NetWorkAPIManager defaultManager] hint:@"GDSUNT" success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSDictionary * resp = responseObject;
        NSArray * array = [resp objectForKey:@"data"];
        [_goodsUnit removeAllObjects];
        [_goodsUnit addObjectsFromArray:array];
        NSLog(@"queryGoodsUnit success");
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"queryGoodsUnit failure");
    }];
}


-(void)popview:(UIViewController *)popview disSelectRowAtIndex:(NSInteger)index
{
    switch (popview.view.tag) {
        case TAG_POPVIEW_CATEGORY:
        {
            _curCategory = [_goodsCategory objectAtIndex:index];
            _categoryBox.text = [_curCategory objectForKey:@"name"];
        }
            break;
        case TAG_POPVIEW_UNIT:
        {
            _curUnit = [_goodsUnit objectAtIndex:index];
            _unitBox.text = [_curUnit objectForKey:@"name"];
        }
            break;
            
        default:
            break;
    } 
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self resign];
    return YES;
}

@end
