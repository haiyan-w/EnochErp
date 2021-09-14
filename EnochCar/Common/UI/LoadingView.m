//
//  LoadingView.m
//  EnochCar
//
//  Created by 王海燕 on 2021/8/4.
//

#import "LoadingView.h"

@interface LoadingView()
@property(nonatomic,strong)NSTimer * timer;
@end

@implementation LoadingView

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithRed:242/255.0 green:242/255.0 blue:242/255.0 alpha:1];
  
        UIImage * image = [UIImage imageNamed:@"loading"];
        CGSize size = image.size;
        UIImageView * imageView = [[UIImageView alloc] initWithFrame:CGRectMake((frame.size.width - size.width)/2, (frame.size.height - size.height)/3, size.width, size.height)];
        imageView.image = image;
        [self addSubview:imageView];
        
        UILabel * label = [[UILabel alloc] initWithFrame:CGRectMake((frame.size.width - 60)/2, imageView.frame.origin.y + imageView.frame.size.height + 12, 60, 25)];
        label.text = @"加载中";
        label.textAlignment = NSTextAlignmentCenter;
        label.font = [UIFont systemFontOfSize:18 weight:UIFontWeightSemibold];
        label.textColor = [UIColor colorWithRed:191/255.0 green:191/255.0 blue:191/255.0 alpha:1];
        [self addSubview:label];
        
//        UIButton * closehBtn = [[UIButton alloc] initWithFrame:CGRectMake(frame.size.width - 40 - 20, 20, 40, 20)];
//        [closehBtn setTitle:@"关闭" forState:UIControlStateNormal];
//        closehBtn.titleLabel.font = [UIFont fontWithName:@"PingFang SC" size:11];
//        [closehBtn setTitleColor:[UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1] forState:UIControlStateNormal];
//        closehBtn.layer.cornerRadius = 4;
//        closehBtn.backgroundColor = [UIColor whiteColor];
//        [closehBtn addTarget:self action:@selector(closehBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
//        [self addSubview:closehBtn];
        
        self.timer = [NSTimer timerWithTimeInterval:0.05 repeats:YES block:^(NSTimer * _Nonnull timer) {
            imageView.transform = CGAffineTransformRotate(imageView.transform, (M_PI_4) *2/3);
        }];
        [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
        
    }
    return self;
}

-(void)closehBtnClicked:(id)sender
{
    [self.timer invalidate];
    [self removeFromSuperview];
}

@end
