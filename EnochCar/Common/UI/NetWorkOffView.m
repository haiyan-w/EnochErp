//
//  NetWorkOffView.m
//  EnochCar
//
//  Created by 王海燕 on 2021/8/4.
//

#import "NetWorkOffView.h"

@interface NetWorkOffView()
@property(nonatomic,copy) RefreshBlock refreshBlock;
@property(nonatomic,strong) UILabel * msgLable;
@end

@implementation NetWorkOffView

-(instancetype)initWithFrame:(CGRect)frame errorMessage:(NSString*)message refreshBlock:(nullable RefreshBlock)block
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithRed:242/255.0 green:242/255.0 blue:242/255.0 alpha:1];
        self.refreshBlock = block;
        UIImage * image = [UIImage imageNamed:@"netoff"];
        CGSize size = image.size;
        UIImageView * imageView = [[UIImageView alloc] initWithFrame:CGRectMake((frame.size.width - size.width)/2, (frame.size.height - size.height)/3, size.width, size.height)];
        imageView.image = image;
        [self addSubview:imageView];
        
        NSInteger space = 12;
        
        UILabel * lable = [[UILabel alloc] initWithFrame:CGRectMake(20, (imageView.frame.origin.y + imageView.frame.size.height+space), self.frame.size.width-2*20, 25)];
        lable.text = @"加载失败";
        lable.font = [UIFont systemFontOfSize:18 weight:UIFontWeightSemibold];
        lable.textColor = [UIColor colorWithRed:191/255.0 green:191/255.0 blue:191/255.0 alpha:1];
        lable.textAlignment = NSTextAlignmentCenter;
        [self addSubview:lable];
        
        self.msgLable = [[UILabel alloc] initWithFrame:CGRectMake(20, (lable.frame.origin.y + lable.frame.size.height), self.frame.size.width-2*20, 25)];
        self.msgLable.text = message;
        self.msgLable.font = [UIFont systemFontOfSize:18 weight:UIFontWeightSemibold];
        self.msgLable.textColor = [UIColor colorWithRed:191/255.0 green:191/255.0 blue:191/255.0 alpha:1];
        self.msgLable.textAlignment = NSTextAlignmentCenter;
        [self addSubview:self.msgLable];
        
        UIButton * refreshBtn = [[UIButton alloc] initWithFrame:CGRectMake((frame.size.width - 64)/2, self.msgLable.frame.origin.y + self.msgLable.frame.size.height + space, 64, 30)];
        [refreshBtn setTitle:@"刷新" forState:UIControlStateNormal];
        refreshBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        [refreshBtn setTitleColor:[UIColor colorWithRed:191/255.0 green:191/255.0 blue:191/255.0 alpha:1] forState:UIControlStateNormal];
        refreshBtn.layer.cornerRadius = 15;
        refreshBtn.layer.borderWidth = 0.5;
        refreshBtn.layer.borderColor = [UIColor colorWithRed:191/255.0 green:191/255.0 blue:191/255.0 alpha:1].CGColor;
        [refreshBtn addTarget:self action:@selector(refreshBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        
        [self addSubview:refreshBtn];
    }
    return self;
}

-(void)setMessage:(NSString*)message
{
    self.msgLable.text = message;
}

-(void)refreshBtnClicked:(id)sender
{
    if (self.refreshBlock) {
        self.refreshBlock();
    }
}

-(void)closehBtnClicked:(id)sender
{
    [self removeFromSuperview];
}

@end
