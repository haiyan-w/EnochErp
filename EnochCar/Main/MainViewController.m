//
//  MainViewController.m
//  EnochCar
//
//  Created by HAIYAN on 2021/5/7.
//

#import "MainViewController.h"
#import "RecognizeViewController.h"
#import "MaintanceViewController.h"
#import "NetWorkAPIManager.h"
#import "EditPlateNoViewController.h"
#import "CommonTabView.h"
#import "PickupView.h"
#import "RepaireView.h"
#import "SettlementView.h"
#import "PopViewController.h"
#import "SearchResultView.h"
#import "GlobalInfoManager.h"
#import "UIView+Hint.h"
#import "LoadingView.h"
#import "NotFoundView.h"
//#import "NetWorkOffView.h"

#define TAG_TF_SEARCH  1111
#define TAG_TF_ADVISOR  1112

#define HEAD_HEIGHT  212
#define SPACE_LEFT  20

@interface MainViewController ()<UITextFieldDelegate, SearchResultDelegate, PickupViewDelegate, PopViewDelagate,RecognizeViewControllerDelegate>

@property(nonatomic,readwrite,strong) UIImageView * headImg;
@property(nonatomic,readwrite,strong) UILabel * nameLab;
@property(nonatomic,readwrite,strong) UIView * advisorView;
@property(nonatomic,readwrite,strong) UITextField * advisorTF;
@property(nonatomic,readwrite,strong) UIButton * advisorBtn;
@property(nonatomic,readwrite,strong) UITextField * searchTF;

@property(nonatomic,readwrite,strong) CommonTabView * tabView;

@property(nonatomic,readwrite,assign) NSInteger curIndex;
@property(nonatomic,readwrite,strong) UIView * curView;

@property(nonatomic,readwrite,strong) PickupView * pickupView;
@property(nonatomic,readwrite,strong) RepaireView * repaireView;
@property(nonatomic,readwrite,strong) SettlementView * settlementView;
@property(nonatomic,readwrite,strong) SearchResultView * searchResultView;

@property(nonatomic,readwrite,strong) UIView * btnView;
@property(nonatomic,readwrite,strong) UIButton * createBtn;
@property(nonatomic,readwrite,strong) UIButton * orderBtn;

@property(nonatomic,readwrite,strong) NSDictionary * curData;

@property(nonatomic,readwrite,strong) NSMutableArray * advisorArray;
@property(nonatomic,readwrite,strong) NSDictionary * curAdvisor;
@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor colorWithRed:242/255.0 green:242/255.0 blue:242/255.0 alpha:1];
    
    NSInteger left = 20;
    NSInteger top = 56;
    NSInteger space = 12;
    
    _headImg = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, HEAD_HEIGHT)];
    [_headImg setImage:[UIImage imageNamed:@"headImg"]];
    [self.view addSubview:_headImg];
    
    NSString * name = [NetWorkAPIManager defaultManager].userName;
    NSMutableAttributedString * attrname = [[NSMutableAttributedString alloc] initWithString:name];
    [attrname addAttributes:[NSDictionary dictionaryWithObject:[UIFont systemFontOfSize:14 weight:UIFontWeightSemibold] forKey:NSFontAttributeName] range:NSMakeRange(0, name.length)];
    CGRect rect = [attrname boundingRectWithSize:CGSizeMake(60, 22) options:NSStringDrawingUsesLineFragmentOrigin context:nil];
    
    _nameLab = [[UILabel alloc] initWithFrame:CGRectMake(left, top, rect.size.width, rect.size.height)];
    _nameLab.text = [NetWorkAPIManager defaultManager].userName;
    _nameLab.textColor = [UIColor whiteColor];
    _nameLab.font = [UIFont systemFontOfSize:14 weight:UIFontWeightSemibold];
    _nameLab.textAlignment = NSTextAlignmentLeft;
    [_headImg addSubview:_nameLab];
    
    _advisorView = [[UIView alloc] initWithFrame:CGRectMake(_nameLab.frame.origin.x + _nameLab.frame.size.width + 24, _nameLab.frame.origin.y - 2, 108, 24)];
    _advisorView.backgroundColor = [UIColor colorWithRed:106/255.0 green:112/255.0 blue:127/255.0 alpha:1];
    _advisorView.layer.cornerRadius = 2.0;
    [_headImg addSubview:_advisorView];
    UIImageView * advisorIcon = [[UIImageView alloc] initWithFrame:CGRectMake(8, 6, 12, 12)];
    [advisorIcon setImage:[UIImage imageNamed:@"icon_advisor"]];
    [_advisorView addSubview:advisorIcon];
    UIImageView * dropIcon = [[UIImageView alloc] initWithFrame:CGRectMake(_advisorView.frame.size.width-24, 0, 24, 24)];
    [dropIcon setImage:[UIImage imageNamed:@"icon_drop"]];
    [_advisorView addSubview:dropIcon];
    
    NSInteger orgX = advisorIcon.frame.origin.x + advisorIcon.frame.size.width + 8;
    _advisorTF = [[UITextField alloc] initWithFrame:CGRectMake(orgX, 0, _advisorView.frame.size.width - orgX - dropIcon.frame.size.width - 8, _advisorView.frame.size.height)];
    _advisorTF.backgroundColor = [UIColor clearColor];
    _advisorTF.text = @"????????????";
    _advisorTF.font = [UIFont systemFontOfSize:11];
    _advisorTF.tag = TAG_TF_ADVISOR;
    _advisorTF.textColor = [UIColor colorWithRed:208/255.0 green:212/255.0 blue:219/255.0 alpha:1];
    [_advisorView addSubview:_advisorTF];
    
    _advisorBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, _advisorView.frame.size.width, _advisorView.frame.size.height)];
    _advisorBtn.backgroundColor = [UIColor clearColor];
    [_advisorBtn addTarget:self action:@selector(advisorBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [_advisorView addSubview:_advisorBtn];
    
    UIView * searchView = [[UIView alloc] initWithFrame:CGRectMake(left, (_nameLab.frame.origin.y + _nameLab.bounds.size.height + space), (self.view.bounds.size.width - 2*left), 36)];
    searchView.layer.cornerRadius = 3;
    searchView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:searchView];
    
    NSInteger btnH = 36;
    NSInteger btnW = 40;
    UIButton * scanBtn = [[UIButton alloc] initWithFrame:CGRectMake((searchView.bounds.size.width-btnW), (searchView.bounds.size.height - btnH)/2, btnW, btnH)];
    scanBtn.backgroundColor = [UIColor clearColor];
    [scanBtn setImage:[UIImage imageNamed:@"scan_search"] forState:UIControlStateNormal];
    [scanBtn addTarget:self action:@selector(scanBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [searchView addSubview:scanBtn];
    
    _searchTF = [[UITextField alloc] initWithFrame:CGRectMake(space, 0, (searchView.bounds.size.width-scanBtn.bounds.size.width - 2*space), searchView.bounds.size.height)];
    _searchTF.backgroundColor = [UIColor clearColor];
    _searchTF.font = [UIFont fontWithName:@"PingFang SC" size:12];
    _searchTF.layer.cornerRadius = 4;
    _searchTF.placeholder = @"??????/??????/VIN?????????";
    _searchTF.tag = TAG_TF_SEARCH;
    _searchTF.delegate = self;
    _searchTF.returnKeyType = UIReturnKeySearch;
//    [searchTF addObserver:self forKeyPath:@"text" options:NSKeyValueObservingOptionNew context:NULL];
    [searchView addSubview:_searchTF];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textChange:) name:UITextFieldTextDidChangeNotification object:_searchTF];
    
    _tabView = [[CommonTabView alloc] initWithFrame:CGRectMake(left, 148, 180, 28)];
    _tabView.delegate = self;
    [self.view addSubview:_tabView];
    
    CommonTabItem * item1 = [[CommonTabItem alloc] initWithImagename:@"pickup" selectedImage:@"pickupB"];
    CommonTabItem * item2 = [[CommonTabItem alloc] initWithImagename:@"repaire" selectedImage:@"repaireB"];
    CommonTabItem * item3 = [[CommonTabItem alloc] initWithImagename:@"settlement" selectedImage:@"settlementB"];
    [_tabView setItems:@[item1, item2, item3]];
    
    _btnView = [[UIView alloc] initWithFrame:CGRectMake(261,148, 58, 28)];
    [self.view addSubview:_btnView];
    _orderBtn = [[UIButton alloc] initWithFrame:CGRectMake(0,0, _btnView.frame.size.width, _btnView.frame.size.height)];
    _orderBtn.backgroundColor = [UIColor colorWithRed:233/255.0 green:236/255.0 blue:241/255.0 alpha:1];
    [_orderBtn setTitle:@"??????" forState:UIControlStateNormal];
    [_orderBtn setTitleColor:[UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1] forState:UIControlStateNormal];
    _orderBtn.titleLabel.font = [UIFont fontWithName:@"PingFang SC" size:14];
    _orderBtn.layer.cornerRadius = 4;
    [_orderBtn addTarget:self action:@selector(seviceBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    _orderBtn.hidden = YES;
    [_btnView addSubview:_orderBtn];
    
    _createBtn = [[UIButton alloc] initWithFrame:CGRectMake(0,0, _btnView.frame.size.width, _btnView.frame.size.height)];
    _createBtn.backgroundColor = [UIColor colorWithRed:233/255.0 green:236/255.0 blue:241/255.0 alpha:1];
    [_createBtn setTitle:@"??????" forState:UIControlStateNormal];
    [_createBtn setTitleColor:[UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1] forState:UIControlStateNormal];
    _createBtn.titleLabel.font = [UIFont fontWithName:@"PingFang SC" size:14];
    _createBtn.layer.cornerRadius = 4;
    [_createBtn addTarget:self action:@selector(createBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    _createBtn.hidden = NO;
    [_btnView addSubview:_createBtn];

    [self addGestureRecognizer];
    
    [self queryAdvisor];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    _pickupView.navCtrl = self.navigationController;
    
    if (self.curIndex == 1) {
        [_repaireView loadData];
    }else  if (self.curIndex == 2){
        [_settlementView loadData];
    }
}

-(void)networkStatusChanged:(AFNetworkReachabilityStatus)status
{
    [super networkStatusChanged:status];
    if ((status == AFNetworkReachabilityStatusUnknown)||(status == AFNetworkReachabilityStatusNotReachable)) {
        _nameLab.text = [NSString stringWithFormat:@"%@%@",[NetWorkAPIManager defaultManager].userName, TEXT_NETWORKOFF];
    }else {
        _nameLab.text = [NetWorkAPIManager defaultManager].userName;
    }
}

-(void)saveLastSeviceInfo
{
    [_pickupView saveLastSeviceInfo];
}

-(void)addGestureRecognizer{
    
    _headImg.userInteractionEnabled = true;
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(taponbg:)];
    [_headImg addGestureRecognizer:tap];
    
    UISwipeGestureRecognizer * swipeRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeRightGesture:)];
    swipeRight.direction = UISwipeGestureRecognizerDirectionRight;
    [self.view addGestureRecognizer:swipeRight];
    
    UISwipeGestureRecognizer * swipeLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeLeftGesture:)];
    swipeLeft.direction = UISwipeGestureRecognizerDirectionLeft;
    [self.view addGestureRecognizer:swipeLeft];
}

-(void)PickUpViewModeChanged:(PickupViewMode)viewMode
{
    switch (viewMode) {
        case PickupInitialMode:
        {
            [_createBtn setTitle:@"??????" forState:UIControlStateNormal];
            _createBtn.hidden = NO;
            _orderBtn.hidden = YES;
        }
            break;
        case PickupCreateMode:
        {
            [_createBtn setTitle:@"??????" forState:UIControlStateNormal];
            _createBtn.hidden = NO;
            _orderBtn.hidden = YES;
        }
            break;
        case PickupEditMode:
        {
            [_createBtn setTitle:@"??????" forState:UIControlStateNormal];
            _createBtn.hidden = NO;
            _orderBtn.hidden = YES;
        }
            break;
        case PickupSeviceMode:
        {
            _createBtn.hidden = YES;
            _orderBtn.hidden = NO;
        }
            break;
            
            
        default:
            break;
    }
    
}

-(void)setCurIndex:(NSInteger)curIndex
{
    _curView.hidden = YES;
    _curIndex = curIndex;
//    NSInteger screenH = [UIScreen mainScreen].bounds.size.height;
    NSInteger screenH = self.view.frame.size.height;
    NSInteger viewW = self.view.bounds.size.width;
    NSInteger tabH = 44;
    NSInteger statusbarH = 20;
    CGRect frame = CGRectMake(0, HEAD_HEIGHT, viewW, (screenH - HEAD_HEIGHT-tabH));
    
    switch (curIndex) {
        case 0:
        {
            if (!_pickupView) {
                _pickupView = [[PickupView alloc] initWithFrame: frame];
                _pickupView.backgroundColor = self.view.backgroundColor;
                _pickupView.scrollEnabled = YES;
                _pickupView.delegate = self;
                _pickupView.contentSize = frame.size;
                _pickupView.hidden = YES;
                _pickupView.navCtrl = self.navigationController;
                _pickupView.delegate = self;
//                [self.view addSubview:_pickupView];
                [self.view insertSubview:_pickupView belowSubview:self.headImg];
            }
            _curView = _pickupView;
            _btnView.hidden = NO;
            [_pickupView addNotification];
        }
            break;
        case 1:
        {
            if (!_repaireView) {
                _repaireView = [[RepaireView alloc] initWithFrame: frame];
                _repaireView.backgroundColor = self.view.backgroundColor;
                _repaireView.hidden = YES;
                _repaireView.navCtrl = self.navigationController;
//                [self.view addSubview:_repaireView];
                [self.view insertSubview:_repaireView belowSubview:self.headImg];
            }
            _curView = _repaireView;
            _btnView.hidden = YES;
            
            [_pickupView removeNotification];
        }
            break;
        case 2:
        {
            if (!_settlementView) {
                _settlementView = [[SettlementView alloc] initWithFrame: frame];
                _settlementView.backgroundColor = self.view.backgroundColor;
                _settlementView.hidden = YES;
                _settlementView.navCtrl = self.navigationController;
//                [self.view addSubview:_settlementView];
                [self.view insertSubview:_settlementView belowSubview:self.headImg];
            }
            _curView = _settlementView;
            _btnView.hidden = YES;
            
            [_pickupView removeNotification];
        }
            break;
            
        default:
            break;
    }
    
    
    _curView.hidden = NO;
    
}


- (void)advisorBtnClicked:(id)sender
{
    [self selectAdvisor];
}

- (void)scanBtnClicked:(id)sender
{
    [self scan];
}

- (void)createBtnClick:(id)sender
{
    if (self.isNetworkOn) {
        [_pickupView create];
    }else {
        [self.view showHint:[NSString stringWithFormat:@"%@",TEXT_NETWORKOFF_HINT]];
    }
    
}

- (void)seviceBtnClick:(id)sender
{
    if (self.isNetworkOn) {
        [self createService];
    }else {
        [self.view showHint:[NSString stringWithFormat:@"%@",TEXT_NETWORKOFF_HINT]];
    }
}

//??????
- (void)createService
{
    __weak MainViewController * weakself = self;

    [_pickupView createServiceWith:self.curAdvisor success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        dispatch_async(dispatch_get_main_queue(), ^{
            UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"?????????????????????????????????"
                                                                               message:@""
                                                                        preferredStyle:UIAlertControllerStyleAlert];
                
                UIAlertAction* yesAction = [UIAlertAction actionWithTitle:@"???" style:UIAlertActionStyleDefault
                                                                      handler:^(UIAlertAction * action) {
                                                                          //????????????
                    [weakself.tabView setIndex:1];
                    [weakself.pickupView setViewMode:PickupInitialMode];
                                                                          NSLog(@"action = %@", action);
                                                                      }];
            UIAlertAction* noAction = [UIAlertAction actionWithTitle:@"???" style:UIAlertActionStyleDefault
                                                                  handler:^(UIAlertAction * action) {
                                                                      //????????????
                [weakself.pickupView setViewMode:PickupInitialMode];
                                                                      
                                                                  }];

            [alert addAction:yesAction];
            [alert addAction:noAction];
            [self presentViewController:alert animated:YES completion:nil];
        });
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSString * info = [error.userInfo objectForKey:@"body"];
        NSDictionary * dic = [self dictionaryWithJsonString:info];
        NSDictionary * msgDic = [[dic objectForKey:@"errors"] firstObject];
        NSString * message = [msgDic objectForKey:@"message"];
        dispatch_async(dispatch_get_main_queue(), ^{
            UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"????????????"
                                                                               message:message
                                                                        preferredStyle:UIAlertControllerStyleAlert];
                
                UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"?????????" style:UIAlertActionStyleDefault
                                                                      handler:^(UIAlertAction * action) {
                                                                          //????????????
                                                                          
                                                                      }];

                [alert addAction:defaultAction];
                    [self presentViewController:alert animated:YES completion:nil];
        });
    }];
}

- (void)addItems
{
    MaintanceViewController * maintanceCtrl = [[MaintanceViewController alloc] init];
    
    [self.navigationController pushViewController:maintanceCtrl animated:YES];
}

- (void)selectAdvisor
{
    [self resign];
    
    if (!self.advisorArray) {
        __weak MainViewController * weakself = self;
        [[NetWorkAPIManager defaultManager] queryAdvisorSuccess:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            
            NSDictionary * resp = responseObject;
            NSArray * array = [resp objectForKey:@"data"];

            if (weakself.advisorArray) {
                [weakself.advisorArray removeAllObjects];
            }else {
                weakself.advisorArray = [NSMutableArray array];
            }
            
            NSInteger userID = [[NetWorkAPIManager defaultManager] userID];
            
            for (NSDictionary * dic in array) {
                NSDictionary * user = [dic objectForKey:@"user"];
                [weakself.advisorArray addObject:user];
                if (userID == [[user objectForKey:@"id"] integerValue]) {
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        weakself.curAdvisor = user;
                    });
                }
            }
            
            [weakself showAdvisorPopView];
            
        } Failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {

        }];
        
    }else {
        [self showAdvisorPopView];
    }
    
    
}

-(void)showAdvisorPopView
{
    NSMutableArray * popStrings = [NSMutableArray array];
    for (NSDictionary * dic in self.advisorArray) {
        [popStrings addObject:[dic objectForKey:@"name"]];
    }
    PopViewController * popCtrl = [[PopViewController alloc] initWithTitle:@"????????????" Data:popStrings];
    popCtrl.delegate = self;
    [popCtrl showIn:self.navigationController];
}

- (void)scan
{
    RecognizeViewController * recognizeCtrl = [[RecognizeViewController alloc] initWithType:RecognizeTypePlateNO];
    recognizeCtrl.delegate = self;
    [self.navigationController pushViewController:recognizeCtrl animated:YES];    
}

-(void)configData:(NSDictionary *)data
{
    [self.tabView setIndex:0];
    [_pickupView configData:data];
}

-(void)queryAdvisor
{
    __weak MainViewController * weakself = self;
    [[NetWorkAPIManager defaultManager] queryAdvisorSuccess:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSDictionary * resp = responseObject;
        NSArray * array = [resp objectForKey:@"data"];

        if (weakself.advisorArray) {
            [weakself.advisorArray removeAllObjects];
        }else {
            weakself.advisorArray = [NSMutableArray array];
        }
        
        NSInteger userID = [[NetWorkAPIManager defaultManager] userID];
        
        for (NSDictionary * dic in array) {
            NSDictionary * user = [dic objectForKey:@"user"];
            [weakself.advisorArray addObject:user];
            if (userID == [[user objectForKey:@"id"] integerValue]) {
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    weakself.curAdvisor = user;
                    weakself.advisorBtn.enabled = NO;
                    weakself.advisorTF.enabled = NO;
                });
            }
        }
        
        
    } Failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {

    }];
    
    
    
}

-(void)setCurAdvisor:(NSDictionary *)curAdvisor
{
    _curAdvisor = curAdvisor;
    self.advisorTF.text = [_curAdvisor objectForKey:@"name"];
}

-(SearchResultView*)searchResultView
{
    if (!_searchResultView) {
        _searchResultView = [[SearchResultView alloc] initWithFrame:_pickupView.frame];
        _searchResultView.delegate = self;
    }
    return _searchResultView;
}

-(void)textChange:(NSNotification*)notice
{
    UITextField * textfield = notice.object;
    [self.searchResultView searchData:textfield.text];    
}

#pragma textField delegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if (TAG_TF_SEARCH == textField.tag) {
        [self.view addSubview:self.searchResultView];
    }
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];//????????????
    return  YES;
}

#pragma tabview delegate

-(void)tabview:(CommonTabView *)tabview indexChanged:(NSInteger )index
{
    self.curIndex = index;
}
#pragma SearchResultView delegate
- (void)searchView:(SearchResultView*)searchView selectData:(NSDictionary*)data
{
    _curData = [NSDictionary dictionaryWithDictionary:data];
    [self configData:_curData];
}

- (void)searchView:(SearchResultView*)searchView viewWillRemove:(NSDictionary*)data
{
    _searchTF.text = @"";
    [_searchTF resignFirstResponder];
    self.searchResultView = nil;
}

-(void)recognize:(RecognizeViewController*)recognizeCtrl withResult:(NSDictionary*)data
{
    [self configData:data];
}

#pragma popview delegate
-(void)popview:(UIViewController *)popview disSelectRowAtIndex:(NSInteger)index
{
    self.curAdvisor = [self.advisorArray objectAtIndex:index];
}

#pragma
-(void)handleSwipeRightGesture:(UIGestureRecognizer*)gestureRecognizer
{
    switch (self.curIndex) {
        case 0:
        {
//            [self.navigationController popViewControllerAnimated:YES];
        }
            break;
        case 1:
        {
            [self.tabView setIndex:0];
//            [self setCurIndex:0];
            [self lightImpactFeedback];
        }
            break;
        case 2:
        {
            [self.tabView setIndex:1];
            [self lightImpactFeedback];
        }
            break;
        default:
            break;
    }
}

-(void)handleSwipeLeftGesture:(UIGestureRecognizer*)gestureRecognizer
{
    switch (self.curIndex) {
        case 0:
        {
            [self.tabView setIndex:1];
            [self lightImpactFeedback];
        }
            break;
        case 1:
        {
            [self.tabView setIndex:2];
            [self lightImpactFeedback];
        }
            break;
        default:
            break;
    }
    
}
-(void)lightImpactFeedback
{
    UIImpactFeedbackGenerator * feed = [[UIImpactFeedbackGenerator alloc] initWithStyle:UIImpactFeedbackStyleLight];
    [feed impactOccurred];
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

//tool
-(NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString {
   if (jsonString == nil) {
       return nil;
   }
   NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
   NSError *err;
   NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                       options:NSJSONReadingMutableContainers
                                                         error:&err];
   if(err) {
       NSLog(@"json???????????????%@",err);
       return nil;
   }
   return dic;
}



@end
