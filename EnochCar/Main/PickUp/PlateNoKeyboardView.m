//
//  PlateNoKeyboardView.m
//  EnochCar
//
//  Created by 王海燕 on 2021/5/26.
//

#import "PlateNoKeyboardView.h"


#define kWidth  self.frame.size.width

#define kHeight self.frame.size.height


@interface PlateNoKeyboardView()<UIGestureRecognizerDelegate>
@property (nonatomic, strong) UIView *provinceView;//省市
@property (nonatomic, strong) UIView *abcView;//字母数字
@property (nonatomic, strong) NSArray *array1; //省市简写数组
@property (nonatomic, strong) NSArray *array2; //车牌号码字母数字数组
@property (nonatomic, assign) KeyboardType type;
@end

@implementation PlateNoKeyboardView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        self.backgroundColor = [UIColor colorWithRed:204/255.0 green:206/255.0 blue:211/255.0 alpha:0.76];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFAction:) name:@"abc" object:nil];
        [self setupUI];
        
    }
    return self;
}

- (NSArray *)array1
{
    if (!_array1)
    {
        _array1 = @[@"京",@"津",@"渝",@"沪",@"冀",@"晋",@"辽",@"吉",@"黑",@"苏",@"浙",@"皖",@"闽",@"赣",@"鲁",@"豫",@"鄂",@"湘",@"粤",@"琼",@"川",@"贵",@"云",@"陕",@"甘",@"青",@"蒙",@"桂",@"宁",@"新",@"ABC",@"藏",@"使",@"领",@"警",@"学",@"港",@"澳",@""];
    }
    return _array1;
}

- (NSArray *)array2
{
    if (!_array2)
    {
        _array2 = @[@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9",@"0",@"Q",@"W",@"E",@"R",@"T",@"Y",@"U",@"I",@"O",@"P",@"A",@"S",@"D",@"F",@"G",@"H",@"J",@"K",@"L",@"省",@"Z",@"X",@"C",@"V",@"B",@"N",@"M",@""];
    }
    return _array2;
}

- (void)setupUI
{
    CGSize size = self.frame.size;
    _provinceView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
    _provinceView.backgroundColor = [UIColor clearColor];
    _provinceView.hidden = NO;
    
    _abcView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
    _abcView.hidden = YES;
    _abcView.backgroundColor = [UIColor clearColor];
    
    [self addSubview:_provinceView];
    [self addSubview:_abcView];
    
    int row = 4;
    int column = 10;
    CGFloat btnY = 12;
    CGFloat btnX = 3;
    CGFloat maginR = 5;
    CGFloat maginC = 12;
    CGFloat btnW = (size.width - maginR * (column -1) - 2 * btnX)/column;
//    CGFloat btnH = (_provinceView.frame.size.height - maginC * (row - 1) - 6) / row;
    CGFloat btnH = (_provinceView.frame.size.height - maginC * row - 24) / row;
    CGFloat m = 12;
    
    CGFloat w = (size.width - 24 - 7 * btnW - 6 * maginR - 2 * btnX)/2;
    CGFloat mw = (size.width - 8 * maginR - 9 * btnW - 2 * btnX) / 2;
//    NSLog(@"LY >> count - %zd", self.array1.count);
    for (int i = 0; i < self.array1.count; i++)
    {
        UIButton *btn = [[UIButton alloc] init];
        if (i / column == 3)
        {
            if (i == 30)
            {
                btn.frame = CGRectMake(btnX, btnY + 3 * (btnH + maginC), w, btnH);
                [btn setBackgroundColor:[UIColor colorWithRed:173/255.0 green:179/255.0 blue:188/255.0 alpha:1]];
                
            }else if (i == 38)
            {
                btn.frame = CGRectMake(6 * (btnW + maginR) + btnW + w + m + m, btnY + 3 * (btnH + maginC), w, btnH);
                [btn setBackgroundColor:[UIColor colorWithRed:173/255.0 green:179/255.0 blue:188/255.0 alpha:1]];
                [btn setImage:[UIImage imageNamed:@"delete"] forState:UIControlStateNormal];
                
            }else {
                btn.frame = CGRectMake((i % column - 1)*(btnW + maginR) + w + m + btnX, btnY + 3 * (btnH + maginC), btnW, btnH);
                [btn setBackgroundColor:[UIColor whiteColor]];
            }
    
        }else {
            btn.frame = CGRectMake(btnW * (i % column) + i % column * maginR + btnX, btnY + i/column * (btnH + maginC), btnW, btnH);
            [btn setBackgroundColor:[UIColor whiteColor]];
        }
        
        [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        
        [btn setTitle:self.array1[i] forState:UIControlStateNormal];
        btn.layer.cornerRadius = 4.6;
        btn.layer.masksToBounds = YES;
        btn.tag = i;
        [btn addTarget:self action:@selector(btn1Click:) forControlEvents:UIControlEventTouchUpInside];
        [_provinceView addSubview:btn];
    }
    
    for (int i = 0; i < self.array2.count; i++)
    {
//        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        UIButton *btn = [[UIButton alloc] init];
        if (i >= 20 && i < 29)
        {
            btn.frame = CGRectMake(btnX + mw + (btnW + maginR) * (i % column), btnY + 2 * (btnH + maginC), btnW, btnH);
            [btn setBackgroundColor:[UIColor whiteColor]];
        }else if (i >= 29)
        {
            if (i == 29)
            {
                btn.frame = CGRectMake(btnX, btnY + 3 * (btnH + maginC), w, btnH);
                [btn setBackgroundColor:[UIColor colorWithRed:173/255.0 green:179/255.0 blue:188/255.0 alpha:1]];
            }else if (i == 37)
            {
                
                btn.frame = CGRectMake(6 * (btnW + maginR) + btnW + w + m + m + btnX, btnY + 3 * (btnH + maginC), w, btnH);
                [btn setBackgroundColor:[UIColor colorWithRed:173/255.0 green:179/255.0 blue:188/255.0 alpha:1]];
                [btn setImage:[UIImage imageNamed:@"delete"] forState:UIControlStateNormal];
            }else
            {
                btn.frame = CGRectMake((i % column)*(btnW + maginR) + w + m + btnX, btnY + 3 * (btnH + maginC), btnW, btnH);
                [btn setBackgroundColor:[UIColor whiteColor]];
            }
        }else
        {
            
            btn.frame = CGRectMake(btnW * (i % column) + i % column * maginR + btnX, btnY + i/column * (btnH + maginC), btnW, btnH);
            [btn setBackgroundColor:[UIColor whiteColor]];
        }
            
            [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [btn setTitle:self.array2[i] forState:UIControlStateNormal];
            btn.layer.cornerRadius = 3;
            btn.layer.masksToBounds = YES;
            btn.tag = i;
            [btn addTarget:self action:@selector(btn2Click:) forControlEvents:UIControlEventTouchUpInside];
            [_abcView addSubview:btn];
        }
        
    
    //    [UIView animateWithDuration:0.3 animations:^{
    //        CGRect frame = _backView1.frame;
    //        frame.origin.y = size.height - size.height * 0.33;
    //        _backView1.frame = frame;
    //    }];
    //
    //    [UIView animateWithDuration:0.3 animations:^{
    //        CGRect frame = _backView2.frame;
    //        frame.origin.y = size.height - size.height * 0.33;
    //        _backView2.frame = frame;
    //    }];
}
    
-(void)setType:(KeyboardType)type
{
    switch (type) {
        case KeyboardTypeProvince:
        {
            _provinceView.hidden = NO;
            _abcView.hidden = YES;
        }
            break;
        case KeyboardTypeABC:
        {
            _provinceView.hidden = YES;
            _abcView.hidden = NO;
        }
            break;
        default:
            break;
    }
    
}


- (void)btn1Click:(UIButton *)sender {
    
    if (sender.tag == 30){
        
//        NSLog(@"点击了abc键");
        if (_abcView.hidden) {
            _provinceView.hidden = YES;
            _abcView.hidden = NO;
        }else {
            
//            sender.enabled = NO;
            
        }
    }else if(sender.tag == 38){
//        NSLog(@"点击了删除键");
        if (_abcView.hidden){
            
            if (self.delegate && [self.delegate respondsToSelector:@selector(deleteBtnClick)]) {
                [self.delegate deleteBtnClick];
            }
            
        }
    }else {
        _provinceView.hidden = YES;
        _abcView.hidden = NO;
        if (self.delegate && [self.delegate respondsToSelector:@selector(clickWithString:)]) {
            [self.delegate clickWithString:self.array1[sender.tag]];
            
        }
    }
    
}

- (void)btn2Click:(UIButton *)sender{
    
    if (sender.tag == 29){
//        NSLog(@"点击了abc键");
        _provinceView.hidden = NO;
        _abcView.hidden = YES;
    }else if(sender.tag == 37){
        
//        NSLog(@"点击了删除键");
        if (self.delegate && [self.delegate respondsToSelector:@selector(deleteBtnClick)]) {
            
            [self.delegate deleteBtnClick];
        }
        
    }else {
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(clickWithString:)]){
            [self.delegate clickWithString:self.array2[sender.tag]];
            
        }
    }
}



- (void)deleteEnd
{
    _provinceView.hidden = NO;
    _abcView.hidden = YES;
}

//通知的监听方法
- (void)textFAction:(NSNotification *)notification{

    NSString *str = notification.userInfo[@"text"];
    if (str.length == 0) {

    }else if (str.length == 7) {
        [self hiddenView];
    }else{
        _provinceView.hidden = YES;
        _abcView.hidden = NO;
    }    
}


//初次弹出键盘时
- (void)showWithString:(NSString *)string {
//    NSLog(@"LY >> string -- %@", string);
    _provinceView.hidden = YES;
    _abcView.hidden = NO;
    
}

//收回键盘
- (void)hiddenView
{
    CGSize size = [UIScreen mainScreen].bounds.size;
    
    [UIView animateWithDuration:0.3 animations:^{
        
        CGRect frame = _provinceView.frame;
        frame.origin.y = size.height;
        _provinceView.frame = frame;
        
    }completion:^(BOOL finished){
        [self removeFromSuperview];
        
    }];
    
    [UIView animateWithDuration:0.3 animations:^{
        
        CGRect frame = _abcView.frame;
        frame.origin.y = size.height;
        _abcView.frame = frame;
        
    }completion:^(BOOL finished){
        [self removeFromSuperview];
        
    }];
    
}

//- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
//{
//    if ([touch.view isDescendantOfView:_provinceView] ||[touch.view isDescendantOfView:_abcView] )
//    {
//        return NO;
//
//    }
//    return YES;
//}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
        
}


@end
