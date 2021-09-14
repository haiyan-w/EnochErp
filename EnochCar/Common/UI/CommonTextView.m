//
//  CommonTextView.m
//  EnochCar
//
//  Created by 王海燕 on 2021/7/26.
//

#import "CommonTextView.h"

@interface CommonTextView()<UITextViewDelegate>
@property (nonatomic,strong) UILabel * titleLabel;
@property (nonatomic,strong) UILabel * placeLabel;
@property (nonatomic,strong) UITextView * textview;
@end

@implementation CommonTextView

-(void)awakeFromNib
{
    self.layer.cornerRadius = 2;
    self.placeLabel = [[UILabel alloc] initWithFrame:CGRectMake(12, 12, self.frame.size.width - 2*12, 20)];
    self.placeLabel.font = [UIFont systemFontOfSize:14];
    self.placeLabel.textColor = [UIColor colorWithRed:191/255.0 green:191/255.0 blue:191/255.0 alpha:1];
    [self addSubview:self.placeLabel];
    
    self.textview = [[UITextView alloc] initWithFrame:CGRectMake(12, 12, self.frame.size.width - 2*12, self.frame.size.height - 2*12)];
    self.textview.delegate = self;
    self.textview.font = [UIFont systemFontOfSize:14];
    self.textview.textColor = [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1];
    self.textview.backgroundColor = [UIColor clearColor];
    [self addSubview:self.textview];
}

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        self.layer.cornerRadius = 2;
        self.placeLabel = [[UILabel alloc] initWithFrame:CGRectMake(12, 12, frame.size.width - 2*12, 20)];
        self.placeLabel.font = [UIFont systemFontOfSize:12];
        self.placeLabel.textColor = [UIColor colorWithRed:191/255.0 green:191/255.0 blue:191/255.0 alpha:1];
        [self addSubview:self.placeLabel];
        
        self.textview = [[UITextView alloc] initWithFrame:CGRectMake(12, 12, frame.size.width - 2*12, frame.size.height - 2*12)];
        self.textview.delegate = self;
        self.textview.font = [UIFont systemFontOfSize:14];
        self.textview.textColor = [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1];
        self.textview.backgroundColor = [UIColor clearColor];
        [self addSubview:self.textview];
    }
    return self;
}

-(instancetype)initWithFrame:(CGRect)frame title:(NSString*)titleStr placeHolder:(NSString *)placeHolderStr
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        self.layer.cornerRadius = 2;
        NSInteger space = 12;
        self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(12, 12, frame.size.width - 2*12, 20)];
        self.titleLabel.text = titleStr;
        self.titleLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightMedium];
        self.titleLabel.textColor = [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1];
        [self addSubview:self.titleLabel];
        
        _placeHolder = placeHolderStr;
        self.placeLabel = [[UILabel alloc] initWithFrame:CGRectMake(12, (self.titleLabel.frame.origin.y + self.titleLabel.frame.size.height +space), frame.size.width - 2*12, 13)];
        self.placeLabel.text = placeHolderStr;
        self.placeLabel.font = [UIFont systemFontOfSize:12];
        self.placeLabel.textColor = [UIColor colorWithRed:191/255.0 green:191/255.0 blue:191/255.0 alpha:1];
        [self addSubview:self.placeLabel];
        
        self.textview = [[UITextView alloc] initWithFrame:CGRectMake(12, self.placeLabel.frame.origin.y, frame.size.width - 2*12, frame.size.height - self.placeLabel.frame.origin.y - 2*12)];
        self.textview.delegate = self;
        self.textview.font = [UIFont systemFontOfSize:14];
        self.textview.textColor = [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1];
        self.textview.backgroundColor = [UIColor clearColor];
        [self addSubview:self.textview];
    }
    
    return self;
}

-(NSString*)getText
{
    return self.textview.text;
}

-(void)setText:(NSString*)text
{
    self.textview.text = text;
}

-(void)setPlaceHolder:(NSString *)placeHolder
{
    _placeHolder = placeHolder;
    self.placeLabel.text = placeHolder;
}

-(void)setDelegate:(id)delegate
{
    _delegate = delegate;
    self.textview.delegate = delegate;
}

-(void)setTextViewTag:(NSInteger)tag
{
    self.textview.tag = tag;
}

-(void)beginEditing
{
    self.placeLabel.text = @"";
}

-(void)endEditing
{
    if (!self.textview.text || self.textview.text.length <= 0) {
        self.placeLabel.text = self.placeHolder;
        
    }else {
        self.placeLabel.text = @"";
    }
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    [self beginEditing];
    return YES;
}

-(BOOL)textViewShouldEndEditing:(UITextView *)textView
{
    [self endEditing];
    return YES;
}

@end
