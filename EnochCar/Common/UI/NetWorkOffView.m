//
//  NetWorkOffView.m
//  EnochCar
//
//  Created by 王海燕 on 2021/8/4.
//

#import "NetWorkOffView.h"

@interface NetWorkOffView()
@property(nonatomic,copy) RefreshBlock refreshBlock;
@end

@implementation NetWorkOffView

-(instancetype)initWithFrame:(CGRect)frame refreshBlock:(RefreshBlock)block
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
        
        UIButton * refreshBtn = [[UIButton alloc] initWithFrame:CGRectMake((frame.size.width - 64)/2, imageView.frame.origin.y + imageView.frame.size.height + 12, 64, 30)];
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
