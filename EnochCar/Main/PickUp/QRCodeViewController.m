//
//  QRCodeViewController.m
//  EnochCar
//
//  Created by 王海燕 on 2021/6/3.
//

#import "QRCodeViewController.h"
#import "NetWorkAPIManager.h"
#import <SDWebImage/SDWebImage.h>

@interface QRCodeViewController ()<UIGestureRecognizerDelegate>
@property(nonatomic,strong)UIView * centerView;
@property(nonatomic,strong)UIImageView * imgView;
@end

@implementation QRCodeViewController

-(instancetype)initWithURL:(NSString*)urlstring
{
    self = [super init];
    if (self) {
        self.imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 180, 180)];
        [self.imgView sd_setImageWithURL:[NSURL URLWithString:urlstring]];
//        [imgView setCenter:self.view.center];
//        [self.view addSubview:imgView];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor colorWithRed:55/255.0 green:55/255.0 blue:55/255.0 alpha:0.5];
    
    NSInteger space = 12;
    
    self.centerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 240, 240)];
    [self.centerView setCenter:self.view.center];
    self.centerView.backgroundColor = [UIColor whiteColor];
    self.centerView.layer.cornerRadius = 4;
    [self.view addSubview:self.centerView];
    
    [self.centerView addSubview:self.imgView];
    [self.imgView setFrame:CGRectMake(70, 78, 100, 100)];
    
    UILabel * bigLable = [[UILabel alloc] initWithFrame:CGRectMake(space, space, self.centerView.frame.size.width - 2*space, 22)];
    bigLable.text = @"车主微信绑定";
    bigLable.textColor = [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1];
    bigLable.font = [UIFont systemFontOfSize:16 weight:UIFontWeightSemibold];
    [self.centerView addSubview:bigLable];
    
    UILabel * smallLable = [[UILabel alloc] initWithFrame:CGRectMake(space, 38, self.centerView.frame.size.width - 2*space, 16)];
    smallLable.text = @"绑定后，车主可以了解汽车维修状态";
    smallLable.textColor = [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1];
    smallLable.font = [UIFont systemFontOfSize:11];
    [self.centerView addSubview:smallLable];
    
    UILabel * branchNameLable = [[UILabel alloc] initWithFrame:CGRectMake(space, self.centerView.frame.size.height - space - 16 , self.centerView.frame.size.width - 2*space, 16)];
    branchNameLable.text = [NetWorkAPIManager defaultManager].branchName;
    branchNameLable.textColor = [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1];
    branchNameLable.font = [UIFont systemFontOfSize:11];
    [self.centerView addSubview:branchNameLable];
    
    [self addGestures];
}

-(void)addGestures
{
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(taponbg:)];
    tap.delegate = self;
    [self.view addGestureRecognizer:tap];
}

-(void)removeGestures
{
    for (UIGestureRecognizer * gesture in self.view.gestureRecognizers) {
        [self.view removeGestureRecognizer:gesture];
    }
}

-(void)taponbg:(UIGestureRecognizer*)gesture
{
    [self.view removeFromSuperview];
    [self removeFromParentViewController];
}

@end
