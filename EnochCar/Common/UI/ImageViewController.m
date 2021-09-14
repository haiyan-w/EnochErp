//
//  ImageViewController.m
//  EnochCar
//
//  Created by 王海燕 on 2021/9/1.
//

#import "ImageViewController.h"
#import "CommonTool.h"
#import <SDWebImage/SDWebImage.h>



@interface ImageViewController ()

@property(nonatomic,strong) UIImageView * imageview;
@property(nonatomic,strong) NSString * title;
@end

@implementation ImageViewController

-(instancetype)initWithUrlString:(NSString*)urlString title:(NSString*)title
{
    self = [super init];
    if (self) {
        CGFloat topH = [CommonTool topbarH];
        CGFloat bottomH = 34;
        NSInteger space = 12;
        self.imageview = [[UIImageView alloc] initWithFrame:CGRectMake(0, topH+space, self.view.frame.size.width, self.view.frame.size.height - space-topH-bottomH)];
        self.imageview.contentMode = UIViewContentModeScaleAspectFit;
        [self.view addSubview:self.imageview];
        
        self.urlString = urlString;
        self.title = title;
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.midTitle = self.title;
    
    UIButton * deleteBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    [deleteBtn setImage:[UIImage imageNamed:@"delete_black"] forState:UIControlStateNormal];
    [deleteBtn addTarget:self action:@selector(deleteBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    [self setRightBtn:deleteBtn];
}

-(void)showOn:(UIViewController*)viewCtrl
{
    [viewCtrl addChildViewController:self];
    [viewCtrl.view addSubview:self.view];
}

-(void)back
{
    [self.view removeFromSuperview];
    [self removeFromParentViewController];
}

-(void)setUrlString:(NSString *)urlString
{
    _urlString = urlString;
    [self.imageview sd_setImageWithURL:[NSURL URLWithString:urlString]];
}

- (void)deleteBtnClicked
{
//    if ([self.delegate respondsToSelector:@selector(imageViewController:deleteImage:)]) {
//        [self.delegate imageViewController:self deleteImage:self.urlString];
//    }
    
    if (self.deleteBlock) {
        self.deleteBlock();
    }
    [self back];
}

@end
