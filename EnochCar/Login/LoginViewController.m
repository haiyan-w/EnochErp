//
//  LoginViewController.m
//  EnochCar
//
//  Created by HAIYAN on 2021/5/7.
//

#import "LoginViewController.h"
#import "NetWorkAPIManager.h"
#import "AgreementViewController.h"
#import "GlobalInfoManager.h"
#import "CommonTool.h"
#import "ComplexBox.h"
#import "CommonDefine.h"
#import "LineProgressView.h"
#import "ExperienceViewController.h"
#import "UIView+Hint.h"
//#import "AppDelegate.h"

@interface LoginViewController ()<UITextFieldDelegate>
@property(nonatomic,readwrite,strong)ComplexBox * nameText;
@property(nonatomic,readwrite,strong)ComplexBox * passwordText;
@property(nonatomic,readwrite,strong)UIButton * loginBtn;
@property(nonatomic,readwrite,strong)NSString * name;
@property(nonatomic,readwrite,strong)NSString * password;
@property(nonatomic,readwrite,strong)UIButton * wechatBtn;
@property(nonatomic,readwrite,strong)UIButton * selectBtn;
@property(nonatomic,readwrite,strong)UIButton * agreementBtn;
@property(nonatomic,readwrite,strong)UIButton * privacyBtn;

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor colorWithRed:242/255.0 green:242/255.0 blue:242/255.0 alpha:1];

    UIImageView * headImg = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 212)];
    [headImg setImage:[UIImage imageNamed:@"headImg"]];
    [self.view addSubview:headImg];
    
    UILabel * bigLab = [[UILabel alloc] initWithFrame:CGRectMake(20, 96, 200, 28)];
    bigLab.text = @"以诺行车管家";
    bigLab.textColor = [UIColor whiteColor];
    bigLab.font = [UIFont systemFontOfSize:24 weight:UIFontWeightSemibold];
    bigLab.textAlignment = NSTextAlignmentLeft;
    [headImg addSubview:bigLab];
    
    UILabel * smallLab = [[UILabel alloc] initWithFrame:CGRectMake(20, (bigLab.frame.origin.y+bigLab.frame.size.height)+4, 180, 25)];
    smallLab.text = @"全新的汽修服务系统";
    smallLab.textColor = [UIColor colorWithRed:208/255.0 green:212/255.0 blue:219/255.0 alpha:1];
    smallLab.font = [UIFont fontWithName:@"PingFang SC" size:14];
    smallLab.textAlignment = NSTextAlignmentLeft;
    [headImg addSubview:smallLab];
    
    NSInteger left = 67;
    NSInteger top = 49;
    NSInteger bottom = 24;
    NSInteger space = 12;
    
    NSInteger centerY = headImg.frame.origin.y+headImg.frame.size.height +top;
    UIView * centerView = [[UIView alloc] initWithFrame:CGRectMake(left, centerY, (self.view.bounds.size.width - 2*left), (self.view.bounds.size.height - centerY - bottom) )];
    [self.view addSubview:centerView];
    
    UIView * loginView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, centerView.bounds.size.width, 190 )];
    [centerView addSubview:loginView];
    
    _nameText = [[ComplexBox alloc] initWithFrame:CGRectMake(0, 0, loginView.bounds.size.width, 34) mode:ComplexBoxEdit];
    [_nameText setPlaceHolder:@"手机号码"];
    _nameText.delegate = self;
    _nameText.keyboardType = UIKeyboardTypeDecimalPad;
    
    _passwordText = [[ComplexBox alloc] initWithFrame:CGRectMake(_nameText.frame.origin.x, (_nameText.frame.origin.y+_nameText.frame.size.height + space), _nameText.frame.size.width, _nameText.frame.size.height) mode:ComplexBoxEdit];
    [_passwordText setPlaceHolder:@"密码"];
    _passwordText.delegate = self;
    
    _loginBtn = [[UIButton alloc] initWithFrame:CGRectMake(_passwordText.frame.origin.x, (_passwordText.frame.origin.y+_passwordText.frame.size.height + space), _nameText.frame.size.width, 43)];
    [_loginBtn setTitle:@"登录" forState:UIControlStateNormal];
    [_loginBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    _loginBtn.titleLabel.backgroundColor = [UIColor clearColor];
    _loginBtn.backgroundColor = [UIColor colorWithRed:59/255.0 green:66/255.0 blue:80/255.0 alpha:1];
    _loginBtn.titleLabel.font = [UIFont fontWithName:@"PingFang SC" size:16];
    [_loginBtn addTarget:self action:@selector(loginBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    _loginBtn.layer.cornerRadius = 4;
    
    [loginView addSubview:_nameText];
    [loginView addSubview:_passwordText];
    [loginView addSubview:_loginBtn];
    
    UIButton * skipLoginBtn = [[UIButton alloc] initWithFrame:CGRectMake(_loginBtn.frame.origin.x, (_loginBtn.frame.origin.y+_loginBtn.frame.size.height + space), _loginBtn.frame.size.width, 43)];
    skipLoginBtn.layer.cornerRadius = 4;
    skipLoginBtn.layer.borderWidth = 1;
    skipLoginBtn.layer.borderColor = [UIColor colorWithRed:221/255.0 green:221/255.0 blue:221/255.0 alpha:1].CGColor;
    skipLoginBtn.backgroundColor = [UIColor clearColor];
    [skipLoginBtn setTitle:@"体验版登录" forState:UIControlStateNormal];
    skipLoginBtn.titleLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightSemibold];
    [skipLoginBtn setTitleColor:[UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1] forState:UIControlStateNormal];
    [skipLoginBtn addTarget:self action:@selector(skipLogin) forControlEvents:UIControlEventTouchUpInside];
    [centerView addSubview:skipLoginBtn];
    
//    UIView * thirdloginView = [[UIView alloc] initWithFrame:CGRectMake((centerView.bounds.size.width - 84)/2, loginView.bounds.size.height+(centerView.bounds.size.height - 126 -68)/2, 84, 68)];
//    UILabel * thirdLab = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, thirdloginView.bounds.size.width, 20)];
//    thirdLab.text = @"其他方式登录";
//    thirdLab.textColor = [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1];
//    thirdLab.font = [UIFont fontWithName:@"PingFang SC" size:14];
//    thirdLab.textAlignment = NSTextAlignmentCenter;
//    [thirdloginView addSubview:thirdLab];
//    _wechatBtn = [[UIButton alloc] initWithFrame:CGRectMake((thirdloginView.bounds.size.width - 24)/2, (thirdloginView.bounds.size.height - 24),24,24)];
//    [_wechatBtn setImage:[UIImage imageNamed:@"wechat"] forState:UIControlStateNormal];
//    [_wechatBtn addTarget:self action:@selector(wechatLogin) forControlEvents:UIControlEventTouchUpInside];
//    [thirdloginView addSubview:_wechatBtn];
//    [centerView addSubview:thirdloginView];
//    thirdloginView.hidden = YES;
    
    UIView * bottomView = [[UIView alloc] initWithFrame:CGRectMake((centerView.bounds.size.width-260)/2, centerView.bounds.size.height-40, 260, 40)];
    bottomView.backgroundColor = [UIColor clearColor];
    [centerView addSubview:bottomView];
    
    UILabel * bottomLab = [[UILabel alloc] initWithFrame:CGRectMake((bottomView.frame.size.width-224), 0, 224, bottomView.frame.size.height)];
    bottomLab.font = [UIFont fontWithName:@"PingFang SC" size:14];
    bottomLab.numberOfLines = 0;
    NSString * string = [NSString stringWithFormat:@"我已阅读并同意《以诺行用户协议》\r和《隐私权政策》"];
    NSMutableAttributedString * attrStr = [[NSMutableAttributedString alloc] initWithString:string];
    NSRange range1 = [string rangeOfString:@"《以诺行用户协议》"];
    NSRange range2 = [string rangeOfString:@"《隐私权政策》"];
    [attrStr addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:89/255.0 green:156/255.0 blue:255/255.0 alpha:1] range:range1];
    [attrStr addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:89/255.0 green:156/255.0 blue:255/255.0 alpha:1] range:range2];
    bottomLab.attributedText = attrStr;
    [bottomView addSubview:bottomLab];
    
    _selectBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 36, 36)];
    [_selectBtn setImage:[UIImage imageNamed:@"login_unselect"] forState:UIControlStateNormal];
    [_selectBtn setImage:[UIImage imageNamed:@"login_select"] forState:UIControlStateSelected];
    [_selectBtn addTarget:self action:@selector(agree) forControlEvents:UIControlEventTouchUpInside];
    [bottomView addSubview:_selectBtn];
    
    _agreementBtn = [[UIButton alloc] initWithFrame:CGRectMake(bottomLab.frame.origin.x+bottomLab.frame.size.width/2, bottomLab.frame.origin.y, bottomLab.frame.size.width/2, bottomLab.frame.size.height/2)];
    _agreementBtn.backgroundColor = [UIColor clearColor];
    [_agreementBtn addTarget:self action:@selector(showAgreement) forControlEvents:UIControlEventTouchUpInside];
    [bottomView addSubview:_agreementBtn];
 
    _privacyBtn = [[UIButton alloc] initWithFrame:CGRectMake(bottomLab.frame.origin.x, bottomLab.frame.origin.y+bottomLab.frame.size.height/2, bottomLab.frame.size.width/2, bottomLab.frame.size.height/2)];
    _privacyBtn.backgroundColor = [UIColor clearColor];
    [_privacyBtn addTarget:self action:@selector(showPrivacy) forControlEvents:UIControlEventTouchUpInside];
    [bottomView addSubview:_privacyBtn];

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

-(void)agree
{
    _selectBtn.selected = !_selectBtn.selected;
}

-(void)showAgreement
{
    AgreementViewController * agreementCtrl = [[AgreementViewController alloc] init];
    [self addChildViewController:agreementCtrl];
    [self.view addSubview:agreementCtrl.view];
}

-(void)showPrivacy
{
    AgreementViewController * agreementCtrl = [[AgreementViewController alloc] init];
    [self addChildViewController:agreementCtrl];
    [self.view addSubview:agreementCtrl.view];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];//收起键盘
    return  YES;
}

-(BOOL)check
{
    self.name = [self.nameText getText];
    self.password = [self.passwordText getText];
    if (![CommonTool isCellphoneValid:self.name])
    {
        [self.view showHint:@"请输入正确的手机号码"];
        return NO;
    }
    if (!self.password || self.password.length <= 0)
    {
        [self.view showHint:@"请输入密码"];
        return NO;
    }
    if (!_selectBtn.selected) {
        [self.view showHint:@"请阅读用户协议和隐私权政策"];
        return NO;
    }
    return YES;
}

-(void)loginBtnClicked
{
    if (!self.isNetworkOn) {
        [self.view showHint:[NSString stringWithFormat:@"%@",TEXT_NETWORKOFF_HINT]];
        return;
    }
    
    if ([self check]) {
        
        __weak LoginViewController * weakself = self;
        
        NetWorkAPIManager * manager = [NetWorkAPIManager defaultManager];

        [manager loginWithUsername:self.name Password:self.password success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            
            [self queryUserInfo];
      
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            //错误提示
            NSString * info = [error.userInfo objectForKey:@"body"];
            NSDictionary * dic = [self dictionaryWithJsonString:info];
            NSDictionary * msgDic = [[dic objectForKey:@"errors"] firstObject];
            [weakself loginFailure:[msgDic objectForKey:@"message"]];
        }] ;
    }
}

-(void)skipLogin
{
    ExperienceViewController * experienceCtrl = [[ExperienceViewController alloc] init];
    [self.navigationController pushViewController:experienceCtrl animated:YES];
}

-(void)loginFailure:(NSString * )message
{
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"登录失败"
                                                                       message:message
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action) {
                                                                  //响应事件
                                                                  
                                                              }];

        [alert addAction:defaultAction];
        [self presentViewController:alert animated:YES completion:nil];
}

//-(void)wechatLogin
//{
//    if ([WXApi isWXAppInstalled]) {
//
//        SendAuthReq *req = [[SendAuthReq alloc] init];
//
//        req.scope = @"snsapi_userinfo";
//
//        req.state = @"App";
//
//        [WXApi sendReq:req completion:^(BOOL success) {
//
//            }];
//
//    }else {
//        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"温馨提示"
//                                                                           message:@"请先安装微信客户端"
//                                                                    preferredStyle:UIAlertControllerStyleAlert];
//
//            UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"好的" style:UIAlertActionStyleDefault
//                                                                  handler:^(UIAlertAction * action) {
//                                                                      //响应事件
//                                                                      NSLog(@"action = %@", action);
//                                                                  }];
//
//            [alert addAction:defaultAction];
//            [self presentViewController:alert animated:YES completion:nil];
//
//    }
//}

-(void)queryUserInfo
{
    NetWorkAPIManager * manager = [NetWorkAPIManager defaultManager];
    [manager queryUserInfosuccess:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSNotificationCenter * notify = [NSNotificationCenter defaultCenter];
        [notify postNotificationName:NOTIFICATION_LOGIN_SUCCESS object:NULL userInfo:NULL];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [self.view showHint:@"获取用户信息失败"];

    }];
}

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
       NSLog(@"json解析失败：%@",err);
       return nil;
   }
   return dic;
}


@end
