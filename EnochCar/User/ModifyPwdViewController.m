//
//  ModifyPwdViewController.m
//  EnochCar
//
//  Created by 王海燕 on 2021/5/24.
//

#import "ModifyPwdViewController.h"
#import "NetWorkAPIManager.h"


@interface ModifyPwdViewController ()<UITextFieldDelegate>
@property (strong, nonatomic) IBOutlet UIButton *commitBtn;
@property (strong, nonatomic) IBOutlet UITextField *pwdOld;
@property (strong, nonatomic) IBOutlet UITextField *pwdNew;
@property (strong, nonatomic) IBOutlet UITextField *pWdConfirm;

@end

@implementation ModifyPwdViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.midTitle = @"修改密码";

    self.commitBtn.layer.cornerRadius = 4;
    
    self.pwdOld.delegate = self;
    self.pwdNew.delegate = self;
    self.pWdConfirm.delegate = self;
    
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(taponbg:)];
    [self.view addGestureRecognizer:tap];
}

-(void)taponbg:(UIGestureRecognizer *)gesture
{
    [self resign];
}

-(void)resetData
{
    self.pwdOld.text = @"";
    self.pwdNew.text = @"";
    self.pWdConfirm.text = @"";
}

-(void)resign
{
    UIWindow * keyWindow = [[UIApplication sharedApplication] keyWindow];
    UIView * firstResponder = [keyWindow performSelector:@selector(firstResponder)];
    [firstResponder resignFirstResponder];    
}
    

- (IBAction)modify:(id)sender {
    
    if ([self check]) {
        __weak ModifyPwdViewController * weakself = self;

        [[NetWorkAPIManager defaultManager] modifyPassword:[self.pwdOld.text lowercaseString] newPwd:self.pwdNew.text success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            
            [weakself resign];
            [weakself resetData];
            [self showHint:@"修改密码成功"];
            
            NSNotificationCenter * notify = [NSNotificationCenter defaultCenter];
            [notify postNotificationName:NOTIFICATION_LOGOUT_SUCCESS object:NULL userInfo:NULL];
        
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            [self showHint:@"修改密码失败"];
        }];
    }
}

-(BOOL)check
{
    if (self.pwdOld.text.length < 1) {
        [self showHint:@"请输入旧密码"];
        return NO;
    }else if (self.pwdNew.text.length < 1){
        [self showHint:@"请输入新密码"];
        return NO;
    }else if (self.pWdConfirm.text.length < 1){
        [self showHint:@"请输入确认密码"];
        return NO;
    }else if (![self.pWdConfirm.text isEqualToString:self.pwdNew.text]){
        [self showHint:@"两次密码输入不一致"];
        return NO;
    }
    return YES;
}

-(void)showHint:(NSString *)message
{
    CGSize screenSize = [[UIScreen mainScreen] bounds].size;
     
        UIWindow * window = [UIApplication sharedApplication].keyWindow;
        UIView *showview =  [[UIView alloc]init];
        showview.backgroundColor = [UIColor colorWithRed:76/255.0 green:76/255.0 blue:76/255.0 alpha:1];
        showview.frame = CGRectMake(1, 1, 1, 1);
        showview.alpha = 1.0f;
        showview.layer.cornerRadius = 5.0f;
        showview.layer.masksToBounds = YES;
        [window addSubview:showview];
        
        UILabel *label = [[UILabel alloc]init];
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc]init];
        paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
        
        NSDictionary *attributes = @{NSFontAttributeName:[UIFont systemFontOfSize:15.f],
                                       NSParagraphStyleAttributeName:paragraphStyle.copy};
        
        CGSize labelSize = [message boundingRectWithSize:CGSizeMake(207, 999)
                                                 options:NSStringDrawingUsesLineFragmentOrigin
                                                     attributes:attributes context:nil].size;
     
        label.frame = CGRectMake(10, 10, labelSize.width +20, labelSize.height);
        label.text = message;
        label.textColor = [UIColor whiteColor];
        label.textAlignment = 1;
        label.backgroundColor = [UIColor clearColor];
        label.font = [UIFont boldSystemFontOfSize:15];
        [showview addSubview:label];
        
//        showview.frame = CGRectMake((screenSize.width - labelSize.width - 20)/2,
//                                        screenSize.height - 100,
//                                           labelSize.width+40,
//                                               labelSize.height+10);
    showview.frame = CGRectMake((screenSize.width - labelSize.width - 20)/2,
                                    100,
                                       labelSize.width+40,
                                           labelSize.height+20);
        [UIView animateWithDuration:3 animations:^{
            showview.alpha = 0;
        } completion:^(BOOL finished) {
            [showview removeFromSuperview];
        }];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

@end
