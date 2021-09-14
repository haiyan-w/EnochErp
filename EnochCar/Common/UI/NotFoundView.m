//
//  NotFoundView.m
//  EnochCar
//
//  Created by 王海燕 on 2021/8/3.
//

#import "NotFoundView.h"

@implementation NotFoundView

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithRed:242/255.0 green:242/255.0 blue:242/255.0 alpha:1];
        
//        UIButton * closehBtn = [[UIButton alloc] initWithFrame:CGRectMake(frame.size.width - 40 - 20, 20, 40, 20)];
//        [closehBtn setTitle:@"关闭" forState:UIControlStateNormal];
//        closehBtn.titleLabel.font = [UIFont fontWithName:@"PingFang SC" size:11];
//        [closehBtn setTitleColor:[UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1] forState:UIControlStateNormal];
//        closehBtn.layer.cornerRadius = 4;
//        closehBtn.backgroundColor = [UIColor whiteColor];
//        [closehBtn addTarget:self action:@selector(closehBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
//        [self addSubview:closehBtn];
        
        UIImage * image = [UIImage imageNamed:@"notfound"];
        CGSize size = image.size;
        UIImageView * imageView = [[UIImageView alloc] initWithFrame:CGRectMake((frame.size.width - size.width)/2, (frame.size.height - size.height)/3, size.width, size.height)];
        imageView.image = image;
        [self addSubview:imageView];
    }
    return self;
}

-(void)closehBtnClicked:(id)sender
{
    [self removeFromSuperview];
}

@end
