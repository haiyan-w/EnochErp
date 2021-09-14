//
//  UserViewController.m
//  EnochCar
//
//  Created by 王海燕 on 2021/6/4.
//

#import "UserViewController.h"
#import "SettingViewController.h"
#import "NetWorkAPIManager.h"
#import <SDWebImage/SDWebImage.h>
#import "GlobalInfoManager.h"
#import "UIView+Hint.h"
#import "CommonTool.h"


@interface UserViewController ()<UITextViewDelegate>
@property (strong, nonatomic) IBOutlet UIImageView *userHeadimg;
@property (strong, nonatomic) IBOutlet UILabel *titleLabel;


@property (weak, nonatomic) IBOutlet UIView *summerView;

@property (weak, nonatomic) IBOutlet UIView *adviceView;

@property (weak, nonatomic) IBOutlet UIView *yellowView;
@property (strong, nonatomic) IBOutlet UILabel *branchlab;
@property (strong, nonatomic) IBOutlet UILabel *nameLab;
@property (strong, nonatomic) IBOutlet UILabel *totalLab;
@property (strong, nonatomic) IBOutlet UILabel *completedLab;
@property (strong, nonatomic) IBOutlet UILabel *repairingLab;
@property (strong, nonatomic) IBOutlet UILabel *amountLab;
//@property (strong, nonatomic) IBOutlet UITextField *adviceTF;
@property (weak, nonatomic) IBOutlet UITextView *adviceTV;
@property (weak, nonatomic) IBOutlet UILabel *placeholderLab;

@property (strong, nonatomic) IBOutlet UIButton *sendBtn;
@property (assign, nonatomic) NSInteger STCount;
@property (assign, nonatomic) NSInteger RPCount;
@property (assign, nonatomic) NSInteger total;

@property (strong, nonatomic) IBOutlet NSLayoutConstraint * titleTopConstraint;

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *headImgTopConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *summerViewTopConstraint;

@end

@implementation UserViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.view.backgroundColor = [UIColor colorWithRed:242/255.0 green:242/255.0 blue:242/255.0 alpha:1];
    self.sendBtn.layer.cornerRadius = 4;

    NSString * headurl = [NetWorkAPIManager defaultManager].headUrl;
    if (headurl.length>0) {
        [_userHeadimg sd_setImageWithURL:[NSURL URLWithString:headurl]];
    }else {
        [_userHeadimg setImage:[UIImage imageNamed:@"headImage"]];
    }

    _userHeadimg.layer.cornerRadius = 25;
    _adviceTV.delegate = self;
    _adviceTV.returnKeyType = UIReturnKeyDefault;
    _branchlab.text = [NetWorkAPIManager defaultManager].branchName;
    _nameLab.text = [NetWorkAPIManager defaultManager].userName;
    
    _summerView.layer.cornerRadius = 4;
    _summerView.layer.masksToBounds = YES;
    _adviceView.layer.cornerRadius = 4;
    
    
    CGFloat statusbarH = [CommonTool statusbarH];
    self.titleTopConstraint.constant = statusbarH;
//    self.headImgTopConstraint.constant = -statusbarH;
    
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(taponbg:)];
    [self.view addGestureRecognizer:tap];
    
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self clearData];
    [self queryStatement];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillChangeFrame:) name:UIKeyboardWillChangeFrameNotification object:nil];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear: animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)keyboardWillShow:(NSNotification*)notification
{
    NSDictionary *userInfo = [notification userInfo];
    CGRect KeyboardRect = [[userInfo objectForKey:@"UIKeyboardFrameEndUserInfoKey"]CGRectValue];

    UIWindow * window=[[[UIApplication sharedApplication] delegate] window];
    CGRect adviceViewRect = [self.view convertRect: self.adviceView.frame toView:window];
    NSInteger offset =  (adviceViewRect.origin.y + adviceViewRect.size.height) - KeyboardRect.origin.y + 12;

    if (offset > 0) {
        [UIView animateWithDuration:2 animations:^{
            NSInteger origin = self.summerViewTopConstraint.constant;
            self.summerViewTopConstraint.constant = origin - offset;
//            CGRect frame = self.summerView.frame;
//            self.summerView.frame = CGRectMake(0, frame.origin.y - offset, frame.size.width, frame.size.height);
        }];
    }
}

-(void)keyboardWillHide:(NSNotification*)notification
{
    [UIView animateWithDuration:2 animations:^{
        self.summerViewTopConstraint.constant = 25;
//        self.summerView.frame = CGRectMake(0, 237, self.summerView.frame.size.width, self.summerView.frame.size.height);
    }];
  
}
    
-(void)clearData
{
    self.STCount = 0;
    self.RPCount = 0;
    self.total = 0;
}

-(void)taponbg:(UIGestureRecognizer *)gesture
{
    [self.adviceTV resignFirstResponder];
}

- (IBAction)send:(id)sender {
    if (!self.adviceTV.text || self.adviceTV.text.length <= 0 ) {
        [self.adviceTV showHint:@"内容不能为空"];
        return;
    }
    [[NetWorkAPIManager defaultManager] feedbackWithContent:self.adviceTV.text success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        self.adviceTV.text = nil;
        self.placeholderLab.text = @"输入...";
        [self.adviceTV resignFirstResponder];
        [self.adviceTV showHint:@"发送成功"];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [self.adviceTV showHint:@"发送失败"];
    }];
    
}

- (IBAction)setting:(id)sender {
    SettingViewController * setingCtrl = [[SettingViewController alloc] init];
    [self.navigationController pushViewController:setingCtrl animated:YES];
}

-(void)queryStatement
{
    [self querySettlementStatement];
    [self queryRepaireStatement];
}

-(void)querySettlementStatement
{
    __weak  UserViewController * weakself = self;
    [[NetWorkAPIManager defaultManager] queryStatement:@"extraStatus=ST" Success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary * resp = responseObject;
        NSDictionary * data = [[resp objectForKey:@"data"] firstObject];
        NSNumber * amout = [data objectForKey:@"serviceReceivableAmount"];
        if (amout) {
            weakself.amountLab.text = [NSString stringWithFormat:@"%@",amout];
        }
        weakself.STCount = [[data objectForKey:@"count"] integerValue];
        weakself.completedLab.text = [NSString stringWithFormat:@"%@",[NSNumber numberWithInteger:weakself.STCount]];
        weakself.total += weakself.STCount;
        weakself.totalLab.text = [NSString stringWithFormat:@"%@",[NSNumber numberWithInteger:weakself.total]];
    } Failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
    }];
}

-(void)queryRepaireStatement
{
    __weak  UserViewController * weakself = self;
    [[NetWorkAPIManager defaultManager] queryStatement:@"extraStatus=RP" Success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary * resp = responseObject;
        NSDictionary * data = [[resp objectForKey:@"data"] firstObject];
        
        weakself.RPCount = [[data objectForKey:@"count"] integerValue];
        weakself.repairingLab.text = [NSString stringWithFormat:@"%@",[NSNumber numberWithInteger:self.RPCount]];
        weakself.total += weakself.RPCount;
        weakself.totalLab.text = [NSString stringWithFormat:@"%@",[NSNumber numberWithInteger:weakself.total]];
    } Failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
    }];
}

-(void)networkStatusChanged:(AFNetworkReachabilityStatus)status
{
    if (self.isNetworkOn) {
        self.titleLabel.text = @"用户中心";
    }else {
        self.titleLabel.text = [NSString stringWithFormat:@"用户中心%@",TEXT_NETWORKOFF];
    }
}

#pragma --UITextView delegate

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    self.placeholderLab.text = @"";
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    if (self.adviceTV.text.length <= 0) {
        self.placeholderLab.text = @"输入...";
    }
}

@end
