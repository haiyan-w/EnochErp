//
//  EditPlateNoViewController.m
//  EnochCar
//
//  Created by 王海燕 on 2021/5/17.
//

#import "EditPlateNoViewController.h"
#import "PlateNoKeyboardView.h"
#import "RecognizeViewController.h"
#import "UIView+Hint.h"

@interface EditPlateNoViewController ()<PlateNoKeyboardViewDelegate>
@property(nonatomic,readwrite,strong)NSMutableArray * tfArray;
@property(nonatomic,readwrite,strong)UIButton * commitBtn;
@property(nonatomic,readwrite,strong)UITextField * curTF;
@property(nonatomic,readwrite,strong)PlateNoKeyboardView * keyboardView;

@end

@implementation EditPlateNoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.midTitle = @"新建车牌";

    self.view.backgroundColor = [UIColor colorWithRed:242/255.0 green:242/255.0 blue:242/255.0 alpha:1];
    
    UIButton * scanBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    [scanBtn setImage:[UIImage imageNamed:@"scan_black"] forState:UIControlStateNormal];
    [scanBtn addTarget:self action:@selector(scan) forControlEvents:UIControlEventTouchUpInside];
    [self setRightBtn:scanBtn];
    
    CGSize size = self.view.bounds.size;
    NSInteger left = 26;
    UIView * centerView = [[UIView alloc] initWithFrame:CGRectMake(left, 200, (size.width - 2*left), 180)];
    centerView.backgroundColor = [UIColor clearColor];
    centerView.layer.cornerRadius = 4;
    [self.view addSubview:centerView];
    
    NSInteger space = 12;
    NSInteger width = (centerView.frame.size.width - 6*space)/7;
    
    _tfArray = [[NSMutableArray alloc] init];
    
    for (int i = 0; i<7;i++) {
        UITextField * tf = [[UITextField alloc] initWithFrame:CGRectMake((width + space)*i , 30, width, width)];
        tf.borderStyle = UITextBorderStyleRoundedRect;
        tf.tag = i;
        [tf setBackgroundColor:[UIColor whiteColor]];
        tf.layer.cornerRadius = 4;
        tf.inputView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
        tf.tintColor = [UIColor colorWithRed:59/255.0 green:66/255.0 blue:80/255.0 alpha:1];
//        [tf addTarget:self action:@selector(editChange:) forControlEvents:UIControlEventEditingChanged];
        UIButton * btn = [[UIButton alloc] initWithFrame:tf.frame];
        [btn setBackgroundColor:[UIColor clearColor]];
        btn.layer.cornerRadius = 4;
        btn.tag = i;
        [btn addTarget:self action:@selector(click:) forControlEvents:UIControlEventTouchUpInside];

        [centerView addSubview:tf];
        [centerView addSubview:btn];
        
        [_tfArray addObject:tf];
        if (i == 0) {
            self.curTF = tf;
        }
    }
    
    _commitBtn = [[UIButton alloc] initWithFrame:CGRectMake(40, 120,(centerView.frame.size.width - 2*40),43)];
    [_commitBtn setTitle:@"提交" forState:UIControlStateNormal];
    [_commitBtn setBackgroundColor:[UIColor colorWithRed:59/255.0 green:66/255.0 blue:80/255.0 alpha:1]];
    _commitBtn.layer.cornerRadius = 4;
   
    [_commitBtn addTarget:self action:@selector(commit) forControlEvents:UIControlEventTouchUpInside];
//    [_commitBtn setEnabled:NO];
    [centerView addSubview:_commitBtn];
    
    [self ShowKeyboard];
}

- (void)scan
{
    RecognizeViewController * recognizeCtrl = [[RecognizeViewController alloc] initWithType:RecognizeTypePlateNO];
    UINavigationController * navCtrl = (UINavigationController * )[UIApplication sharedApplication].keyWindow.rootViewController;
    for (UIViewController * viewctrl in navCtrl.viewControllers) {
        if ([viewctrl isKindOfClass:[UITabBarController class]]) {
            UITabBarController * tabCtrl = (UITabBarController *)viewctrl;
            for (UIViewController * viewctrl2 in tabCtrl.viewControllers){
                if ([viewctrl2 isKindOfClass:[MainViewController class]]){
                    recognizeCtrl.delegate = (MainViewController *)viewctrl2;
                    [self.navigationController pushViewController:recognizeCtrl animated:YES];
                    return;
                }
            }
            
        }
    }
    
    
}

-(void)click:(UIButton *)sender
{
    for (UITextField * tf in _tfArray) {
        if (tf.tag == sender.tag) {
            self.curTF = tf;
            _curTF.highlighted = YES;
            break;
        }
        
    }
    
}

-(void)ShowKeyboard
{
    _keyboardView = [[PlateNoKeyboardView alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height - 234, self.view.bounds.size.width, 234)];
    self.keyboardView.delegate = self;
    [self.view addSubview:self.keyboardView];
    
}


-(void)commit
{
    if (!self.isNetworkOn) {
        [self.view showHint:[NSString stringWithFormat:@"%@",TEXT_NETWORKOFF_HINT]];
        return;
    }
    
    if ([self check]) {
        NSString * numStr= @"";
        for (NSInteger i = 0; i<_tfArray.count;i++) {
            UITextField * tf = [_tfArray objectAtIndex:i];
            numStr = [numStr stringByAppendingString:tf.text];
        }
//        NSLog(@"edit plateno:%@",numStr);
        [self goBackToMainVCWithData:[NSDictionary dictionaryWithObject:numStr forKey:@"plateNo"]];
    }else {
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@""
                                                                           message:@"请输入完整的车牌号"
                                                                    preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleDefault
                                                                  handler:^(UIAlertAction * action) {
                                                                      //响应事件
                                                                      
                                                                  }];

            [alert addAction:defaultAction];
            [self presentViewController:alert animated:YES completion:nil];
    }
}

//返回上级页面并传值
- (void)goBackToMainVCWithData:(NSDictionary *) data
{
    UITabBarController *tabVC = [self.navigationController.viewControllers objectAtIndex:self.navigationController.viewControllers.count-2];
    MainViewController * mainVC = [tabVC selectedViewController];
    [mainVC configData:data];
    [self.navigationController popToViewController:tabVC animated:true];
}


- (void)clickWithString:(NSString *)string
{
    _curTF.text = string;
    
    if (_curTF.tag == 6) {
        
//        _commitBtn.enabled = YES;
                
    }else {
        
        for (UITextField * tf in _tfArray) {
            if (tf.tag == (_curTF.tag+1)) {
                self.curTF = tf;
                break;
            }
            
        }
//        _commitBtn.enabled = NO;
    }
}

- (void)deleteBtnClick
{
    if (self.curTF.text.length > 0) {
        self.curTF.text = @"";
//        NSLog(@"清除内容");
    }else {
        if (self.curTF.tag == 0)
        {
            //啥也不做

        }else {
            for (UITextField * tf in _tfArray) {
                if (tf.tag == (_curTF.tag-1)) {
                    tf.text = @"";
                    self.curTF = tf;
//                    NSLog(@"清除前一个");
                    break;
                }
            }
        }
    }
    
//    _commitBtn.enabled = NO;
}

-(void)setCurTF:(UITextField *)curTF
{
    _curTF = curTF;
    [_curTF becomeFirstResponder];
    if(0 == _curTF.tag)
    {
        [self.keyboardView setType:KeyboardTypeProvince];
    }else {
        
        [self.keyboardView setType:KeyboardTypeABC];
    }
}

-(BOOL)check
{
    //检查车牌号码是否填写完整
    for (UITextField * tf in _tfArray) {
        if (tf.text.length <= 0) {
            return NO;
        }
    }
    return YES;
}

@end
