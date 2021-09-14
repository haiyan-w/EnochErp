//
//  ApplyViewController.m
//  EnochCar
//
//  Created by 王海燕 on 2021/7/22.
//

#import "ApplyViewController.h"
#import "ComplexBox.h"
#import "NetWorkAPIManager.h"
#import "CommonTool.h"
#import "UIView+Hint.h"
#import "PopViewController.h"
#import "CommonTextView.h"

@interface ApplyViewController ()<PopViewDelagate,UITextFieldDelegate,UITextViewDelegate>
@property (strong, nonatomic) IBOutlet ComplexBox *nameBox;
@property (strong, nonatomic) IBOutlet ComplexBox *cellphoneBox;
@property (strong, nonatomic) IBOutlet ComplexBox *companyNameBox;
@property (strong, nonatomic) IBOutlet ComplexBox *areaBox;
@property (strong, nonatomic) IBOutlet ComplexBox *turnOverBox;
@property (strong, nonatomic) IBOutlet CommonTextView *commentBox;
@property (strong, nonatomic) NSArray * turnOverArray;
@property (strong, nonatomic) UIView * focusView;
@property(nonatomic,readwrite,strong)UIView * firstResponderView;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *topConst;
@property (assign, nonatomic) CGFloat orgTopConst;
@end

@implementation ApplyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.midTitle = @"申请开通";
    
    UIButton * commitBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 56, 32)];
    [commitBtn setTitle:@"提交" forState:UIControlStateNormal];
    commitBtn.titleLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightSemibold];
    [commitBtn setTitleColor:[UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1] forState:UIControlStateNormal];
    commitBtn.layer.cornerRadius = 2;
    commitBtn.backgroundColor = [UIColor colorWithRed:252/255.0 green:215/255.0 blue:139/255.0 alpha:1];
    [commitBtn addTarget:self action:@selector(commit) forControlEvents:UIControlEventTouchUpInside];
    [self setRightBtn:commitBtn];
    
    self.nameBox.placeHolder = @"请输入姓名";
    self.cellphoneBox.placeHolder = @"请输入电话号码";
    self.companyNameBox.placeHolder = @"请输入企业名称";
    self.areaBox.placeHolder = @"请输入地区";
    self.turnOverBox.placeHolder = @"请选择营业额";
    self.commentBox.placeHolder = @"还需要什么？";
 
    [self.nameBox setMode:ComplexBoxEdit];
    [self.cellphoneBox setMode:ComplexBoxEdit];
    [self.companyNameBox setMode:ComplexBoxEdit];
    [self.areaBox setMode:ComplexBoxEdit];
    [self.turnOverBox setMode:ComplexBoxSelect];
    
    self.nameBox.delegate = self;
    self.cellphoneBox.delegate = self;
    self.companyNameBox.delegate = self;
    self.areaBox.delegate = self;
    self.turnOverBox.delegate = self;
    self.commentBox.delegate = self;
    
    self.orgTopConst = self.topConst.constant;
    
    __weak ApplyViewController * weakself = self;
    self.turnOverBox.selectBlock = ^{
        [weakself resign];
        PopViewController * popCtrl = [[PopViewController alloc] initWithTitle:@"选择营业额" Data:weakself.turnOverArray];
        popCtrl.delegate = weakself;
        [popCtrl showIn:weakself.navigationController];
    };
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(NSArray*)turnOverArray
{
    _turnOverArray = [NSArray arrayWithObjects:@"50万元以下", @"50-100万元间", @"100-500万间", @"500万以上", nil];
    return _turnOverArray;
}

-(void)commit
{
    if ([self check]) {
        NSMutableDictionary * info = [NSMutableDictionary dictionary];
        [info setValue:[_nameBox getText] forKey:@"name"];
        [info setValue:[_companyNameBox getText] forKey:@"companyName"];
        [info setValue:[_cellphoneBox getText] forKey:@"cellphone"];
        [info setValue:[_areaBox getText] forKey:@"area"];
        [info setValue:[_turnOverBox getText] forKey:@"turnOver"];
        [info setValue:[_commentBox getText] forKey:@"comment"];
        
        //游客身份提交 category id: 5 source code: AD;
        NSMutableDictionary * category = [NSMutableDictionary dictionary];
        [category setValue:[NSNumber numberWithInt:5] forKey:@"id"];
        [info setValue:category forKey:@"category"];
        
        NSMutableDictionary * source = [NSMutableDictionary dictionary];
        [source setValue:@"AD" forKey:@"code"];
        [info setValue:source forKey:@"source"];
        
        __weak  ApplyViewController * weakself = self;
        [[NetWorkAPIManager defaultManager] application:info Success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            [weakself clearData];
            [weakself.view showHint:@"您已申请成功，稍后我们会电话联系您"];
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1.0*NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                [weakself back];
            });
            
            
        } Failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            [self.view showHint:@"申请失败，服务器异常或网络异常"];
        }];
    }
}

-(BOOL)check
{
    NSString * name = [self.nameBox getText];
    if (!name || name.length <= 0) {
        [self.view showHint:@"请输入姓名"];
        return NO;
    }

    NSString *cellphone = [self.cellphoneBox getText];
    if (![CommonTool isCellphoneValid:cellphone])
    {
        [self.view showHint:@"请输入正确的手机号码"];
        return NO;
    }
    
    NSString * companyName = [self.companyNameBox getText];
    if (!companyName || companyName.length <= 0)
    {
        [self.view showHint:@"请输入企业名称"];
        return NO;
    }
    
    NSString * area = [self.areaBox getText];
    if (!area || area.length <= 0)
    {
        [self.view showHint:@"请输入地区"];
        return NO;
    }

    return YES;
}

-(void)clearData
{
    [self.nameBox setText:@""];
    [self.cellphoneBox setText:@""];
    [self.companyNameBox setText:@""];
    [self.areaBox setText:@""];
    [self.turnOverBox setText:@""];
    [self.commentBox setText:@""];
}

-(void)popview:(UIViewController *)popview disSelectRowAtIndex:(NSInteger)index
{
    [self.turnOverBox setText:[self.turnOverArray objectAtIndex:index]];
    
}

-(void)keyboardWillShow:(NSNotification*)notification
{
    NSDictionary *userInfo = [notification userInfo];
    CGRect KeyboardRect = [[userInfo objectForKey:@"UIKeyboardFrameEndUserInfoKey"]CGRectValue];

    UIWindow * window=[[[UIApplication sharedApplication] delegate] window];
    CGRect viewRect = [self.view convertRect: self.firstResponderView.frame toView:window];
    CGFloat offset =  (viewRect.origin.y + viewRect.size.height) - KeyboardRect.origin.y + 12;

    if (offset > 0) {
        
//        self.topConst.constant = self.orgTopConst - offset;
        [UIView animateWithDuration:1 animations:^{
            self.topConst.constant = self.orgTopConst - offset;
            [self.view layoutIfNeeded];
        }];
    }
}

-(void)keyboardWillHide:(NSNotification*)notification
{
    if (_firstResponderView) {
        [UIView animateWithDuration:1 animations:^{
            self.topConst.constant = self.orgTopConst;
            [self.view layoutIfNeeded];
        }];
    }
    _firstResponderView = nil;
}

#pragma delegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    self.firstResponderView = textField;
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];//收起键盘
    return  YES;
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    self.firstResponderView = self.commentBox;
    [self.commentBox beginEditing];
    return YES;
}


- (BOOL)textViewShouldEndEditing:(UITextView *)textView
{
    [self.commentBox endEditing];
    return YES;
}

@end
