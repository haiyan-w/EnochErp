//
//  CommonTextView.m
//  EnochCar
//
//  Created by 王海燕 on 2021/7/26.
//

#import "CommonTextView.h"

@interface CommonTextView()<UITextViewDelegate>
@property (nonatomic,strong) UILabel * placeLabel;
@property (nonatomic,strong) UITextView * textview;
@end

@implementation CommonTextView

-(void)awakeFromNib
{
    self.layer.cornerRadius = 4;
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
        self.placeLabel = [[UILabel alloc] initWithFrame:CGRectMake(12, 12, frame.size.width - 2*12, 20)];
        self.placeLabel.font = [UIFont systemFontOfSize:14];
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

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    self.placeLabel.text = @"";
    return YES;
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView
{
    if (!textView.text || textView.text.length <= 0) {
        self.placeLabel.text = self.placeHolder;
        
    }else {
        self.placeLabel.text = @"";
    }
    return YES;
}

@end
