//
//  AgreementViewController.m
//  EnochCar
//
//  Created by 王海燕 on 2021/6/3.
//

#import "AgreementViewController.h"
#import <WebKit/WebKit.h>

@interface AgreementViewController ()

@end

@implementation AgreementViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    
    WKWebView * agreementView = [[WKWebView alloc] initWithFrame:CGRectMake(0, 64, self.view.bounds.size.width, self.view.bounds.size.height-64)];
    NSURL *url = [[NSBundle mainBundle] URLForResource:@"index.html" withExtension:nil];
    [agreementView loadRequest:[NSURLRequest requestWithURL:url]];
    [self.view addSubview:agreementView];
    
    UIButton * closeBtn = [[UIButton alloc] initWithFrame:CGRectMake(20, 44, 20, 20)];
    [closeBtn setImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
    [closeBtn addTarget:self action:@selector(closed) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:closeBtn];
}

-(void)closed
{
    [self.view removeFromSuperview];
    [self removeFromParentViewController];
}

@end
