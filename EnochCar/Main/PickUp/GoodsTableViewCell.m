//
//  GoodsTableViewCell.m
//  EnochCar
//
//  Created by 王海燕 on 2021/5/18.
//

#import "GoodsTableViewCell.h"
#import "NSNumber+Common.h"
#import "ComplexBox.h"
#import "PopViewController.h"

#define TAG_TEXTFIELD_NUM   11
#define TAG_TEXTFIELD_PRICE   12
#define TAG_TEXTFIELD_CHARGEMETHOD   13

#define TAG_POPVIEW_CHARGEMETHOD 21

@interface GoodsTableViewCell()<UITextFieldDelegate, PopViewDelagate>
@property (strong, nonatomic) IBOutlet UILabel *namelab;
@property (strong, nonatomic) IBOutlet UIButton *selectBtn;
@property (strong, nonatomic) IBOutlet UIView *detailView;

@property (strong, nonatomic) IBOutlet UITextField *numTF;

@property (strong, nonatomic) IBOutlet UITextField *priceTF;

@property (strong, nonatomic) IBOutlet UILabel *serialNoLab;
@property (strong, nonatomic) IBOutlet UILabel *oeLab;

@property (strong, nonatomic) IBOutlet UILabel *categoryLab;
@property (strong, nonatomic) IBOutlet UILabel *inventory;
@property (strong, nonatomic) IBOutlet ComplexBox *chargeMethodBox;

@property (assign, nonatomic)BOOL needExtand;
@property (strong, nonatomic)NSMutableDictionary * curGood;
@end


@implementation GoodsTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    _detailView.hidden = YES;
    _numTF.delegate = self;
    _numTF.tag = TAG_TEXTFIELD_NUM;
    _numTF.layer.cornerRadius = 4;
    _numTF.layer.borderWidth = 0.5;
    _numTF.layer.borderColor = [UIColor colorWithRed:240/255.0 green:240/255.0 blue:240/255.0 alpha:1].CGColor;
    _priceTF.delegate = self;
    _priceTF.tag = TAG_TEXTFIELD_PRICE;
    _priceTF.layer.cornerRadius = 4;
    _priceTF.layer.borderWidth = 0.5;
    _priceTF.layer.borderColor = [UIColor colorWithRed:240/255.0 green:240/255.0 blue:240/255.0 alpha:1].CGColor;
    
    _numTF.keyboardType = UIKeyboardTypeDecimalPad;
    _priceTF.keyboardType = UIKeyboardTypeDecimalPad;
    
    __weak GoodsTableViewCell * weakself = self;
    [_chargeMethodBox setMode:ComplexBoxSelect];
//    _chargeMethodBox.placeHolder = @"请选择收费类别";
    _chargeMethodBox.delegate= self;
    _chargeMethodBox.tag = TAG_TEXTFIELD_CHARGEMETHOD;
    [_chargeMethodBox setBorder:YES];
    _chargeMethodBox.font = [UIFont systemFontOfSize:11];
    _chargeMethodBox.selectBlock= ^{
        [weakself selectChargeMethod:weakself.chargeMethodBox];
    };
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textChange:) name:UITextFieldTextDidChangeNotification object:_numTF];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textChange:) name:UITextFieldTextDidChangeNotification object:_priceTF];
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}



-(void)setNeedExtand:(BOOL)needExtand
{
    self.detailView.hidden = !needExtand;
}

- (void)selectChargeMethod:(id)sender {
    [self resign];
    NSMutableArray * popStrings = [NSMutableArray array];
    for (NSDictionary * charge in self.chargeMethods) {
        [popStrings addObject:[charge objectForKey:@"message"]];
    }
    PopViewController * popCtrl = [[PopViewController alloc] initWithTitle:@"收费类别" Data:popStrings];
    popCtrl.delegate = self;
    popCtrl.view.tag = TAG_POPVIEW_CHARGEMETHOD;
    [self.navigationController addChildViewController:popCtrl];
    [self.navigationController.view addSubview:popCtrl.view];
}

-(void)textChange:(NSNotification*)notice
{

    UITextField * textfield = notice.object;
    
    switch (textfield.tag) {
        case TAG_TEXTFIELD_NUM:
        {
            [_curGood setObject:[NSNumber numberWithInteger:[_numTF.text integerValue]] forKey:@"planCount"];
        }
            break;
        case TAG_TEXTFIELD_PRICE:
        {
            [_curGood setObject:[NSNumber numberWithFloat:[_priceTF.text floatValue]] forKey:@"price"];
        }
            break;
            
        default:
            break;
    }
}

- (IBAction)numReduce:(id)sender {
    NSInteger num = [_numTF.text integerValue];
    if (num>1) {
        _numTF.text = [NSString stringWithFormat:@"%d",(num-1)];
        [_curGood setObject:[NSNumber numberWithInteger:[_numTF.text integerValue]] forKey:@"planCount"];
    }
}

- (IBAction)numPlus:(id)sender {
    NSInteger num = [_numTF.text integerValue];
    _numTF.text = [NSString stringWithFormat:@"%d",(num+1)];
    [_curGood setObject:[NSNumber numberWithInteger:[_numTF.text integerValue]] forKey:@"planCount"];
}

-(void)config:(NSDictionary *)data
{
    _curGood = data;
    
    NSNumber * num = [_curGood objectForKey:@"planCount"];
    if (num) {
        _numTF.text = [NSString stringWithFormat:@"%@",num];
    };
    
    NSNumber * price = [_curGood objectForKey:@"price"];
    if (price) {
        _priceTF.text = [price DoubleStringValueWithDigits:2];
    };
    
    NSDictionary * agood = [[_curGood objectForKey:@"goodsSpecification"] objectForKey:@"goods"];
    _namelab.text = [agood objectForKey:@"name"];
    _serialNoLab.text = [agood objectForKey:@"serialNo"];
    _oeLab.text = [agood objectForKey:@"oem"];
    NSDictionary *type = [agood objectForKey:@"type"];
    _categoryLab.text = [type objectForKey:@"message"];
    [_chargeMethodBox setText:[[_curGood objectForKey:@"chargingMethod"] objectForKey:@"message"]];
    //batches库存
    NSArray * batches = [agood objectForKey:@"batches"];
    CGFloat inventory = 0;
    for (NSDictionary * batch in batches) {
        CGFloat i = [[batch objectForKey:@"count"] floatValue];
        inventory += i;
    }
    _inventory.text = [NSString stringWithFormat:@"%@",[NSNumber numberWithFloat:inventory]];
}


- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    UIWindow * window=[[[UIApplication sharedApplication] delegate] window];
    CGRect rect = [textField convertRect:textField.bounds toView:window];
    if([self.delagate respondsToSelector:@selector(tableviewCellBecomeFirstResponder:)])
    {
        [self.delagate tableviewCellBecomeFirstResponder:rect];
    }
    return YES;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    switch (textField.tag) {
        case TAG_TEXTFIELD_NUM:
        {
            return [self validateIntegerNumber:string];
        }
            break;
        case TAG_TEXTFIELD_PRICE:
        {
            return [self validateFloatNumber:string];
        }
            break;
            
        default:
            break;
    }
    return YES;
}

-(void)popview:(UIViewController *)popview disSelectRowAtIndex:(NSInteger)index
{
    
    switch (popview.view.tag) {
        case TAG_POPVIEW_CHARGEMETHOD:
        {
            NSDictionary * chargeMethod = [self.chargeMethods objectAtIndex:index] ;
            [self setChargeMethod:chargeMethod];
        }
            break;
            
        default:
            break;
    }
}

-(void)setChargeMethod:(NSDictionary *)chargeMethod
{
    [self.chargeMethodBox setText:[chargeMethod objectForKey:@"message"]];
    [_curGood setObject:chargeMethod forKey:@"chargingMethod"];
}

- (BOOL)validateIntegerNumber:(NSString*)number {
    BOOL res = YES;
    NSCharacterSet* tmpSet = [NSCharacterSet characterSetWithCharactersInString:@"0123456789"];
    int i = 0;
    while (i < number.length) {
        NSString * string = [number substringWithRange:NSMakeRange(i, 1)];
        NSRange range = [string rangeOfCharacterFromSet:tmpSet];
        if (range.length == 0) {
            res = NO;
            break;
        }
        i++;
    }
    return res;
}


- (BOOL)validateFloatNumber:(NSString*)number {
    BOOL res = YES;
    NSCharacterSet* tmpSet = [NSCharacterSet characterSetWithCharactersInString:@"0123456789."];
    int i = 0;
    while (i < number.length) {
        NSString * string = [number substringWithRange:NSMakeRange(i, 1)];
        NSRange range = [string rangeOfCharacterFromSet:tmpSet];
        if (range.length == 0) {
            res = NO;
            break;
        }
        i++;
    }
    return res;
}

-(void)resign
{
    UIWindow * keyWindow = [[UIApplication sharedApplication] keyWindow];
    UIView * firstResponder = [keyWindow performSelector:@selector(firstResponder)];
    [firstResponder resignFirstResponder];
}



@end
