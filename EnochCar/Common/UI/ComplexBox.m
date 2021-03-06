//
//  ComplexBox.m
//  EnochCar
//
//  Created by 王海燕 on 2021/7/9.
//

#import "ComplexBox.h"
#import "NetWorkAPIManager.h"
#import "PopViewController.h"

@interface ComplexBox()<PopViewDelagate>
@property (nonatomic,strong) UITextField * textField;
@property (nonatomic,strong) UIButton * selectBtn;
@property (nonatomic,assign) ComplexBoxMode mode;
@property (nonatomic,assign) QueryMode queryMode;
@property (nonatomic,strong) NSString * hint;
@property (nonatomic,strong) NSString * lookup;
@property (nonatomic,strong) NSString * popTitle;
@property (nonatomic,strong) UIImageView * rightImage;
@property (nonatomic,strong)CAShapeLayer *borderLayer;
@property (nonatomic,strong) UIColor * borderColor;

@property (nonatomic,strong) NSArray * messages;
@property (nonatomic,strong) NSDictionary * selectedItem;
@end

@implementation ComplexBox

-(void)awakeFromNib
{
    [super awakeFromNib];
    self.enabled = YES;
    self.backgroundColor = [UIColor whiteColor];
    self.layer.cornerRadius = 4;
    self.layer.masksToBounds = YES;
    self.textField.returnKeyType = UIReturnKeyDone;
}

-(instancetype)initWithFrame:(CGRect)frame mode:(ComplexBoxMode)mode
{
    self= [super initWithFrame:frame];
    if (self) {
        self.mode = mode;
        self.enabled = YES;
        self.backgroundColor = [UIColor whiteColor];
        self.layer.cornerRadius = 4;
        self.layer.masksToBounds = YES;
        self.textField.returnKeyType = UIReturnKeyDone;
    }
    return self;
}

-(instancetype)initWithFrame:(CGRect)frame mode:(ComplexBoxMode)mode hint:(NSString *)hint  popTitle:(NSString *)popTitle
{
    self= [super initWithFrame:frame];
    if (self) {
        self.mode = mode;
        self.queryMode = ComplexBoxQueryHint;
        self.enabled = YES;
        self.backgroundColor = [UIColor whiteColor];
        self.layer.cornerRadius = 4;
        self.layer.masksToBounds = YES;
        self.textField.returnKeyType = UIReturnKeyDone;
        self.hint = hint;
        self.popTitle = popTitle;
    }
    return self;
}

-(instancetype)initWithFrame:(CGRect)frame mode:(ComplexBoxMode)mode lookup:(NSString *)lookup  popTitle:(NSString *)popTitle
{
    self= [super initWithFrame:frame];
    if (self) {
        self.mode = mode;
        self.queryMode = ComplexBoxQueryLookup;
        self.enabled = YES;
        self.backgroundColor = [UIColor whiteColor];
        self.layer.cornerRadius = 4;
        self.layer.masksToBounds = YES;
        self.textField.returnKeyType = UIReturnKeyDone;
        self.lookup = lookup;
        self.popTitle = popTitle;
    }
    return self;
}

-(void)setMode:(ComplexBoxMode)mode
{
    _mode = mode;
    switch (mode) {
        case ComplexBoxEdit:
        {
            [self addSubview:self.textField];
        }
            break;
        case ComplexBoxSelect:
        {
            [self addSubview:self.rightImage];
            [self addSubview:self.textField];
            [self addSubview:self.selectBtn];
        }
            break;
        case ComplexBoxEditAndSelect:
        {
            [self addSubview:self.rightImage];
            [self addSubview:self.selectBtn];
            [self addSubview:self.textField];
            
        }
            break;
            
        default:
            break;
    }
    [self layoutSubviews];
}

-(void)setHint:(NSString*)hint
{
    _hint = hint;
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    
    NSInteger space = 12;
    switch (self.mode) {
        case ComplexBoxEdit:
        {
            self.textField.frame = CGRectMake(space, 0, self.frame.size.width - 2*space, self.frame.size.height);
        }
            break;
        case ComplexBoxSelect:
        {            
            self.rightImage.frame = CGRectMake(self.frame.size.width - 40*self.frame.size.height/36, 0, 40*self.frame.size.height/36, self.frame.size.height);
            self.textField.frame = CGRectMake(space, 0, self.rightImage.frame.origin.x - 2*space , self.frame.size.height);
            self.selectBtn.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
        }
            break;
        case ComplexBoxEditAndSelect:
        {
            self.rightImage.frame = CGRectMake(self.frame.size.width - 40, (self.frame.size.height - 36)/2, 40, 36);
            self.textField.frame = CGRectMake(space, 0, self.rightImage.frame.origin.x - 2*space , self.frame.size.height);
            self.selectBtn.frame = CGRectMake(self.frame.size.width-40, 0, 40, self.frame.size.height);
        }
            break;
            
    }
    [self setBorder:_border];
}

-(UITextField *)textField
{
    if (!_textField) {
        _textField = [[UITextField alloc] init];
        _textField.font = [UIFont fontWithName:@"PingFang SC" size:14];
        _textField.backgroundColor = [UIColor clearColor];
        _textField.textColor = [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1];
    }
    return _textField;
}

-(UIImageView *)rightImage
{
    if (!_rightImage) {
        _rightImage = [[UIImageView alloc] init];
        [_rightImage setImage:[UIImage imageNamed:@"dropdown"]];
    }
    return _rightImage;
}
//-(void)setNormalImageName:(NSString *)normalImageName
//{
//    if (self.enabled) {
//        [_rightImage setImage:[UIImage imageNamed:normalImageName]];
//    }
//}

-(UIButton *)selectBtn
{
    if (!_selectBtn) {
        _selectBtn = [[UIButton alloc] init];
        _selectBtn.backgroundColor = [UIColor clearColor];
        [_selectBtn addTarget:self action:@selector(selectBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _selectBtn;
}

-(NSDictionary*)getSelectedItem
{
    return _selectedItem;
}

-(void)setPlaceHolder:(NSString *)placeHolder
{
    if (self.textField) {
        self.textField.placeholder = placeHolder;
    }
}

-(void)setText:(NSString*)text
{
    self.textField.text = text;  
}
-(NSString*)getText
{
    return self.textField.text;
}

-(void)setFont:(UIFont *)font
{
    self.textField.font = font;
}

-(void)setEnabled:(BOOL)enabled
{
    _enabled = enabled;
    if (_enabled) {
        self.backgroundColor = [UIColor whiteColor];
        self.selectBtn.enabled = YES;
        self.textField.enabled = YES;
        if (self.normalImageName) {
            [self.rightImage setImage:[UIImage imageNamed:self.normalImageName]];
        }else {
            [self.rightImage setImage:[UIImage imageNamed:@"dropdown"]];
        }
        
    }else {
        self.backgroundColor = [UIColor colorWithRed:221/255.0 green:221/255.0 blue:221/255.0 alpha:1];
        self.selectBtn.enabled = NO;
        self.textField.enabled = NO;
        if (self.disabledImageName) {
            [self.rightImage setImage:[UIImage imageNamed:self.disabledImageName]];
        }else if (self.normalImageName) {
            [self.rightImage setImage:[UIImage imageNamed:self.normalImageName]];
        }else {
            [self.rightImage setImage:[UIImage imageNamed:@"dropdown"]];
        }
    }
}

-(void)setBorder:(BOOL)border
{
//    _border = border;
//    UIColor * color = [UIColor colorWithRed:240/255.0 green:240/255.0 blue:240/255.0 alpha:1];
    
    if (!self.borderColor) {
        self.borderColor = [UIColor colorWithRed:221/255.0 green:221/255.0 blue:221/255.0 alpha:1];
    }
    
    if (self.borderLayer) {
        [self.borderLayer removeFromSuperlayer];
        self.borderLayer = nil;
    }
    
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:self.bounds byRoundingCorners:UIRectCornerAllCorners cornerRadii:CGSizeMake(4, 4)];
    
    _borderLayer = [CAShapeLayer layer];
    _borderLayer.frame = self.bounds;
    _borderLayer.path = path.CGPath;
    _borderLayer.lineWidth = 1;
    _borderLayer.fillColor = [UIColor clearColor].CGColor;
    _borderLayer.strokeColor = self.borderColor.CGColor;
    [self.layer addSublayer:_borderLayer];
}

-(void)setBorderColor:(UIColor*)borderColor
{
    _borderColor = borderColor;
    
    [self setBorder:YES];
}

-(void)setKeyboardType:(UIKeyboardType)keyboardType
{
    self.textField.keyboardType = keyboardType;
}

-(void)setDelegate:(id)delegate
{
    _delegate = delegate;
    self.textField.delegate = delegate; 
}

-(void)setTag:(NSInteger)tag
{
//    self.tag = tag;
    self.textField.tag = tag;
}

-(void)selectBtnClick:(id)sender
{
    [self resign];
    
    if (self.selectBlock) {
        self.selectBlock();
        return;
    }
    
    if (!self.messages) {
        [self queryMessages];
    }else {
        [self showPopView];
    }
}

- (void)addTarget:(nullable id)target action:(SEL)action forControlEvents:(UIControlEvents)controlEvents
{
    [self.textField addTarget:target action:action forControlEvents:controlEvents];
    
}

-(void)queryMessages
{
    __weak ComplexBox * weakself = self;
    if (self.queryMode == ComplexBoxQueryLookup) {
        [[NetWorkAPIManager defaultManager]  lookup:self.lookup success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            NSDictionary * dic = responseObject;
            NSArray * array = [dic objectForKey:@"data"];
            self.messages = [NSArray arrayWithArray:array];
            [weakself showPopView];
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            
        }];
    }else if (self.queryMode == ComplexBoxQueryHint) {
        [[NetWorkAPIManager defaultManager]  hint:self.hint success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            NSDictionary * dic = responseObject;
            NSArray * array = [dic objectForKey:@"data"];
            self.messages = [NSArray arrayWithArray:array];
            [weakself showPopView];
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            
        }];
    }
}

-(void)showPopView
{
    NSMutableArray * popStrings = [NSMutableArray array];
    if (self.queryMode == ComplexBoxQueryLookup) {
        for (NSDictionary * ainfo in self.messages) {
            NSString * str = [ainfo objectForKey:@"message"];
            [popStrings addObject:str];
        }
    }else if (self.queryMode == ComplexBoxQueryHint)
    {
        for (NSDictionary * ainfo in self.messages) {
            NSString * str = [ainfo objectForKey:@"name"];
            [popStrings addObject:str];
        }
    }
    
    PopViewController * popCtrl = [[PopViewController alloc] initWithTitle:self.popTitle Data:popStrings];
    popCtrl.delegate = self;
    
    [[UIApplication sharedApplication].delegate.window.rootViewController addChildViewController:popCtrl];
    [[UIApplication sharedApplication].delegate.window.rootViewController.view addSubview:popCtrl.view];
    
}

-(void)popview:(UIViewController *)popview disSelectRowAtIndex:(NSInteger)index
{
    self.selectedItem = [self.messages objectAtIndex:index];
    if (self.queryMode == ComplexBoxQueryLookup) {
        self.textField.text = [self.selectedItem objectForKey:@"message"];
    }else if (self.queryMode == ComplexBoxQueryHint) {
        self.textField.text = [self.selectedItem objectForKey:@"name"];
    }
    
}

-(void)resign
{
    UIWindow * keyWindow = [[UIApplication sharedApplication] keyWindow];
    UIView * firstResponder = [keyWindow performSelector:@selector(firstResponder)];
    [firstResponder resignFirstResponder];
}

@end
