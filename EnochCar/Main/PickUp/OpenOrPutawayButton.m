//
//  OpenOrPutawayButton.m
//  EnochCar
//
//  Created by 王海燕 on 2021/9/1.
//

#import "OpenOrPutawayButton.h"


@interface OpenOrPutawayButton()
@property(nonatomic,strong)UILabel * lable;
@property(nonatomic,strong)UIImageView * imageview;
@property(nonatomic,assign) BOOL isOpen;
@end

@implementation OpenOrPutawayButton

-(instancetype)initWithFrame:(CGRect)frame needOpen:(BOOL)open
{
    self = [super initWithFrame:frame];
    if (self) {
        self.lable = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, frame.size.width-32, 32)];
        self.lable.textColor = [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1];
        self.lable.font = [UIFont systemFontOfSize:14];
        [self addSubview:self.lable];
        
        self.imageview = [[UIImageView alloc] initWithFrame:CGRectMake(frame.size.width-32, 0, 32, 32)];
        [self addSubview:self.imageview];
        
        UIButton * button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        [button addTarget:self action:@selector(buttonClicked) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:button];
        self.isOpen = open;
    }
    return self;
}

-(void)setIsOpen:(BOOL)isOpen
{
    _isOpen = isOpen;
    if (_isOpen) {
        self.lable.text = @"收起";
        [self.imageview setImage:[UIImage imageNamed:@"up"]];
    }else {
        self.lable.text = @"查看更多";
        [self.imageview setImage:[UIImage imageNamed:@"down"]];
    }
    
    NSMutableAttributedString * attrStr = [[NSMutableAttributedString alloc] initWithString:self.lable.text attributes:@{NSFontAttributeName:self.lable.font}];
    CGRect strRect = [attrStr boundingRectWithSize:CGSizeMake(200, 32) options:NSStringDrawingUsesLineFragmentOrigin context:nil];
    self.lable.frame = CGRectMake((self.frame.size.width - strRect.size.width-self.imageview.frame.size.width)/2, (self.imageview.frame.size.height-strRect.size.height)/2, strRect.size.width, strRect.size.height);
    self.imageview.frame = CGRectMake(self.lable.frame.origin.x + self.lable.frame.size.width, 0, self.imageview.frame.size.width, self.imageview.frame.size.height);
    if ([self.delegate respondsToSelector:@selector(OpenOrPutawayStatusChanged:)] ) {
        [self.delegate OpenOrPutawayStatusChanged:_isOpen];
    }
}

-(void)buttonClicked
{
    self.isOpen = !_isOpen;
}

@end
