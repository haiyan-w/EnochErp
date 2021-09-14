//
//  CustomViewController.m
//  EnochCar
//
//  Created by 王海燕 on 2021/5/13.
//适用普通二级及以上页面

#import "CommonViewController.h"
#import "CommonTool.h"
#import "CommonDefine.h"

@interface CommonViewController ()<UIGestureRecognizerDelegate>
@property(nonatomic, readwrite, strong) UIView * navbarView;
@property(nonatomic, readwrite, strong) UIButton* leftBtn;
@property(nonatomic, readwrite, strong) UILabel * titleLabel;
@property(nonatomic, readwrite, strong) UIButton* rightBtn;

@end

@implementation CommonViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor colorWithRed:242/255.0 green:242/255.0 blue:242/255.0 alpha:1];
    
    CGFloat statusBarH = [CommonTool statusbarH];
    
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    
    _navbarView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width, 44 + statusBarH)];
    _navbarView.backgroundColor = [UIColor whiteColor];
    _leftBtn = [[UIButton alloc] initWithFrame:CGRectMake(8, statusBarH, 48, 44)];
    _leftBtn.backgroundColor = [UIColor clearColor];
    [_leftBtn setImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
    [_leftBtn addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    [_navbarView addSubview:_leftBtn];
    
    _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(88, statusBarH, width-2*88, 44)];
    _titleLabel.text = @"";
    _titleLabel.textAlignment = NSTextAlignmentCenter;
    _titleLabel.font =  [UIFont systemFontOfSize:18 weight:UIFontWeightSemibold];
    _titleLabel.backgroundColor = [UIColor clearColor];
    [_navbarView addSubview:_titleLabel];
    
    UIView * line = [[UIView alloc] initWithFrame:CGRectMake(0, self.navbarView.frame.size.height-0.5, self.navbarView.frame.size.width, 0.5)];
    line.backgroundColor = [UIColor colorWithRed:242/255.0 green:242/255.0 blue:242/255.0 alpha:1];
    [_navbarView addSubview:line];
    [self.view addSubview:_navbarView];
    
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(taponbg:)];
    tap.delegate = self;
    [self.view addGestureRecognizer:tap];
    
    //右滑返回上级页面
    UISwipeGestureRecognizer * swipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeRight:)];
    swipe.direction = UISwipeGestureRecognizerDirectionRight;
    [self.view addGestureRecognizer:swipe];

}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    //检查是否在tableview 和 button 区域，否则table选中无效
    if ([touch.view isKindOfClass:[UIButton class]]){
        return NO;
    }else if ([NSStringFromClass([touch.view class]) isEqual:@"UITableViewCellContentView"]) {
        return NO;
    }else {
        return YES;
    }
}

-(void)taponbg:(UIGestureRecognizer *)gesture
{
    [self resign];
}

-(void)swipeRight:(UIGestureRecognizer *)gesture
{
    [self.navigationController popViewControllerAnimated:YES];

}


-(void)resign
{
    UIWindow * keyWindow = [[UIApplication sharedApplication] keyWindow];
    UIView * firstResponder = [keyWindow performSelector:@selector(firstResponder)];
    [firstResponder resignFirstResponder];
}

-(void)back
{
    [self.navigationController   popViewControllerAnimated:YES];
}

-(void)setMidTitle:(NSString *)midTitle
{
    _midTitle = midTitle;
    _titleLabel.text = _midTitle;
}

-(void)setTitle:(NSString *)title
{
    _titleLabel.text = title;
}

-(void)setRightBtn:(UIButton *)rightBtn
{
    _rightBtn = rightBtn;
    CGSize size = rightBtn.frame.size;
    _rightBtn.frame = CGRectMake((_navbarView.bounds.size.width - size.width - 20), _leftBtn.frame.origin.y + (44-size.height)/2, size.width, size.height);
    [_navbarView addSubview:rightBtn];
    
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

-(void)networkStatusChanged:(AFNetworkReachabilityStatus)status
{
    if (self.isNetworkOn) {
        self.titleLabel.text = self.midTitle;
    }else {
        self.titleLabel.text = [NSString stringWithFormat:@"%@%@",self.midTitle,TEXT_NETWORKOFF];
    }
}

@end
