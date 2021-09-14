//
//  FirstModifyPasswordViewController.m
//  EnochCar
//
//  Created by 王海燕 on 2021/8/20.
//

#import "FirstModifyPasswordViewController.h"
#import "ComplexBox.h"
#import "NetWorkAPIManager.h"
#import "UIView+Hint.h"

#define TAG_TEXTFIELD_NEW  91
#define TAG_TEXTFIELD_CONFIRM  92

@interface FirstModifyPasswordViewController ()<UITextFieldDelegate>
@property (strong, nonatomic) IBOutlet UIView *bgview;
@property (strong, nonatomic) IBOutlet ComplexBox *pwdNew;
@property (strong, nonatomic) IBOutlet ComplexBox *pwdconfirm;
@property (strong, nonatomic) IBOutlet UIButton *confirmBtn;
//@property (strong, nonatomic) UIViewController *attachCtrl;
@property (strong, nonatomic) IBOutlet UILabel *ruleTipLab;

@property (strong, nonatomic) IBOutlet UILabel *sameTipLab;

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *ruleTipHeightConst;

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *bottomConstraints;

@property (assign, nonatomic) BOOL isPasswordValid;
@property (assign, nonatomic) BOOL isPasswordSame;
@property (assign, nonatomic) BOOL isModify;
@end

@implementation FirstModifyPasswordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.view.backgroundColor = [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:0.1];
    self.bgview.layer.cornerRadius = 12;
    
    UIBlurEffect * blur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    UIVisualEffectView * effe = [[UIVisualEffectView alloc]initWithEffect:blur];
    effe.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    [self.view insertSubview:effe belowSubview:self.bgview];
    
    self.bgview.layer.cornerRadius = 12;
    self.bgview.backgroundColor = [UIColor whiteColor];
    self.bgview.layer.shadowColor = [UIColor blackColor].CGColor;
    self.bgview.layer.shadowOffset = CGSizeMake(0,-3);
    self.bgview.layer.shadowOpacity = 0.16;
    self.bgview.layer.shadowRadius = 24.0;
    self.bgview.clipsToBounds = NO;
    
    [self.pwdNew setMode:ComplexBoxEdit];
    self.pwdNew.delegate = self;
    self.pwdconfirm.delegate = self;
    self.pwdNew.border = YES;
    [self.pwdconfirm setMode:ComplexBoxEdit];
    self.pwdconfirm.border = YES;
    [self.pwdNew setTag:TAG_TEXTFIELD_NEW];
    [self.pwdconfirm setTag:TAG_TEXTFIELD_CONFIRM];
    
    self.confirmBtn.layer.cornerRadius = 4.0;
    
    self.sameTipLab.hidden = YES;
    CGRect frame = self.bgview.frame;
    self.bottomConstraints.constant = frame.size.height;
    
    self.isModify = NO;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [UIView animateWithDuration:0.3 animations:^{
        self.bottomConstraints.constant = 0;
        [self.view layoutIfNeeded];
    }];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)showViewController:(UIViewController *)vc
{
    [vc.view addSubview:self.view];
    [vc addChildViewController:self];
}



-(void)removeSelf
{
    [self removeFromParentViewController];
    [self.view removeFromSuperview];
    
}

-(void)setIsPasswordValid:(BOOL)isPasswordValid
{
    _isPasswordValid = isPasswordValid;
    if (_isPasswordValid) {
        [self.pwdNew setBorderColor:[UIColor colorWithRed:221/255.0 green:221/255.0 blue:221/255.0 alpha:1]];
        self.ruleTipHeightConst.constant = 0;
    }else {
        [self.pwdNew setBorderColor:[UIColor colorWithRed:244/255.0 green:82/255.0 blue:59/255.0 alpha:1]];
        self.ruleTipHeightConst.constant = 32;
    }
}

-(void)setIsPasswordSame:(BOOL)isPasswordSame
{
    _isPasswordSame = isPasswordSame;
    if (_isPasswordSame) {
        self.sameTipLab.hidden = YES;
        [self.pwdconfirm setBorderColor:[UIColor colorWithRed:221/255.0 green:221/255.0 blue:221/255.0 alpha:1]];
    }else {
        self.sameTipLab.hidden = NO;
        [self.pwdconfirm setBorderColor:[UIColor colorWithRed:244/255.0 green:82/255.0 blue:59/255.0 alpha:1]];
    }
    
}

- (IBAction)confirmBtnClicked:(id)sender {
    
    if (self.isModify) {
        return;
    }

    self.isPasswordValid = [self passwordRuleCheck:[self.pwdNew getText]];
    self.isPasswordSame = [self sameCheck];

    if (self.isPasswordValid && self.isPasswordSame) {
        
        self.isModify = YES;
        
        __weak FirstModifyPasswordViewController * weakself = self;

        [[NetWorkAPIManager defaultManager] modifyPassword:@"123456" newPwd:[self.pwdconfirm getText] success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            weakself.isModify = YES;
            [weakself removeSelf];
    //        NSNotificationCenter * notify = [NSNotificationCenter defaultCenter];
    //        [notify postNotificationName:NOTIFICATION_LOGOUT_SUCCESS object:NULL userInfo:NULL];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.view showHint:@"修改密码成功，请重新登录"];
            });
            
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            weakself.isModify = YES;
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.view showHint:@"修改密码失败"];
            });
    
        }];
    }
}

-(void)keyboardWillShow:(NSNotification*)notification
{
    NSDictionary *userInfo = [notification userInfo];
    CGRect KeyboardRect = [[userInfo objectForKey:@"UIKeyboardFrameEndUserInfoKey"]CGRectValue];
//
//    UIWindow * window=[[[UIApplication sharedApplication] delegate] window];
//    CGRect viewRect = [self.view convertRect: self.bgview.frame toView:window];
//    CGFloat offset =  (viewRect.origin.y + viewRect.size.height) - KeyboardRect.origin.y + 12;

    [UIView animateWithDuration:0.5 animations:^{
        if (self.bottomConstraints.constant == 0) {
            self.bottomConstraints.constant = self.bottomConstraints.constant - KeyboardRect.size.height;
            [self.view layoutIfNeeded];
        }
        
    }];
}

-(void)keyboardWillHide:(NSNotification*)notification
{
    [UIView animateWithDuration:0.5 animations:^{
        self.bottomConstraints.constant = 0;
        [self.view layoutIfNeeded];
    }];
}

-(void)resign
{
    UIWindow * keyWindow = [[UIApplication sharedApplication] keyWindow];
    UIView * firstResponder = [keyWindow performSelector:@selector(firstResponder)];
    [firstResponder resignFirstResponder];
}

//检查新密码是否符合规则
-(BOOL)passwordRuleCheck:(NSString*)password
{
    if (!password) {
        return NO;
    }
    
//    if ((password.length < 6)||(password.length > 12)) {
//        return NO;
//    }
//    NSString *pattern = @"^.*[\\s\\u4e00-\\u9FA5].*$";
//    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", pattern];
//    BOOL isMatch = [pred evaluateWithObject:password];
//    if (isMatch) {
//        return NO;
//    }
    
//    NSInteger totalCheck = 0;
//
//    NSString *pattern1 = @"^[0-9]+$";
//    NSPredicate *pred1 = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", pattern1];
//    BOOL isNumMatch = [pred1 evaluateWithObject:password];
//    if (isNumMatch) {
////        totalCheck = totalCheck + 1;
//        return NO;
//    }
//
//    NSString *pattern2 = @"^[A-Za-z]+$";
//    NSPredicate *pred2 = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", pattern2];
//    BOOL isletterMatch = [pred2 evaluateWithObject:password];
//    if (isletterMatch) {
////        totalCheck = totalCheck + 1;
//        return NO;
//    }
//
////    NSString *pattern3 = @"^(?![0-9]+$)(?![A-Z]+$)(?![a-z]+$)(?![A-Za-z0-9`~!@#\$%^&*\\-_+=;:',.?/\\[\\]~！？，。、|；：’“”]){6,12}$";
//    NSString *pattern3 = @"^[^A-Za-z0-9\\s\\u4e00-\\u9FA5]+$";
//    NSPredicate *pred3 = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", pattern3];
//    BOOL isSpecialMatch = [pred3 evaluateWithObject:password];
//    if (isSpecialMatch) {
////        totalCheck = totalCheck + 1;
//        return NO;
//    }
//
////    if (totalCheck >= 2) {
////        return YES;
////    }else {
////        return NO;
////    }
//    return YES;
//
    
    
    NSString *pattern = @"^(?![0-9]+$)(?![A-Za-z]+$)(?![`~!@#\$%^&*\\-_+=;:',.?/\\[\\]~！？，。、|；：’“”(){}<>]+$)([A-Za-z0-9`~!@#\$%^&*\\-_+=;:',.?/\\[\\]~！？，。、|；：’“”(){}<>]){6,12}$";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", pattern];
    BOOL isMatch = [pred evaluateWithObject:password];
    return isMatch;
}

//检查新密码与确认密码是否一致
-(BOOL)sameCheck
{
    if ([[self.pwdNew getText] isEqualToString:[self.pwdconfirm getText]]) {
        return YES;
    }
    return NO;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}


- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if (textField.tag == TAG_TEXTFIELD_NEW) {
        self.isPasswordValid = [self passwordRuleCheck:textField.text];
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    return YES;
}

@end
