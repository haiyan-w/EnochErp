//
//  TimePickerView.m
//  EnochCar
//
//  Created by 王海燕 on 2021/8/30.
//

#import "TimePickerView.h"



@interface TimePickerViewController()<UIPickerViewDataSource,UIPickerViewDelegate>
@property(nonatomic,strong)UIView * contentView;
@property(nonatomic,strong)UIButton * cancelBtn;
@property(nonatomic,strong)UIButton * sureBtn;
@property(nonatomic,strong)UIPickerView * pickerView;
@property(nonatomic,strong)NSCalendar * calendar;
@property(nonatomic,strong)NSDateComponents * component;
@property(nonatomic,strong)NSArray * years;
@property(nonatomic,strong)NSArray * months;
@property(nonatomic,strong)NSArray * days;
@property(nonatomic,strong)NSArray * hours;
@property(nonatomic,strong)NSArray * minites;

@property(nonatomic,strong)NSString * timeString;
@end

@implementation TimePickerViewController

-(void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithRed:55/255.0 green:55/255.0 blue:55/255.0 alpha:0.5];
    
    [self initDataSource];
    
    self.contentView = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height-300, self.view.frame.size.width, 300)];
    self.contentView.backgroundColor = [UIColor whiteColor];
    self.contentView.layer.cornerRadius = 12;
    [self.view addSubview:self.contentView];
    
    UILabel * lab = [[UILabel alloc] initWithFrame:CGRectMake((self.view.frame.size.width - 50)/2, 17, 50, 20)];
    lab.text = @"日期";
    lab.textColor = [UIColor colorWithRed:191/255.0 green:191/255.0 blue:191/255.0 alpha:1];
    lab.font = [UIFont systemFontOfSize:14];
    lab.textAlignment = NSTextAlignmentCenter;
    [self.contentView addSubview:lab];
    
    self.cancelBtn = [[UIButton alloc] initWithFrame:CGRectMake(20, 17, 40, 22)];
    [self.cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
    [self.cancelBtn.titleLabel setFont:[UIFont systemFontOfSize:16]];
    [self.cancelBtn setTitleColor:[UIColor colorWithRed:250/255.0 green:199/255.0 blue:72/255.0 alpha:1] forState:UIControlStateNormal];
    [self.cancelBtn addTarget:self action:@selector(cancelBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:self.cancelBtn];
    
    self.sureBtn = [[UIButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width - 20 - 40, 17, 40, 22)];
    [self.sureBtn setTitle:@"确认" forState:UIControlStateNormal];
    [self.sureBtn.titleLabel setFont:[UIFont systemFontOfSize:16]];
    [self.sureBtn setTitleColor:[UIColor colorWithRed:250/255.0 green:199/255.0 blue:72/255.0 alpha:1] forState:UIControlStateNormal];
    [self.sureBtn addTarget:self action:@selector(sureBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:self.sureBtn];
    
    self.pickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 40, self.contentView.frame.size.width, self.contentView.frame.size.height - 40)];
    self.pickerView.dataSource = self;
    self.pickerView.delegate = self;
    [self.contentView addSubview:self.pickerView];
    
    [self.pickerView reloadAllComponents];
    
    [self setupData];
    
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(taponbg:)];
    [self.view addGestureRecognizer:tap];   
}

-(void)taponbg:(UIGestureRecognizer*)gesture
{
    [self dismiss];
}

-(void)cancelBtnClicked
{
    [self dismiss];
}
-(void)sureBtnClicked
{
    NSNumber * year = [self.years objectAtIndex:[self.pickerView selectedRowInComponent:0]];
    NSNumber * month = [self.months objectAtIndex:[self.pickerView selectedRowInComponent:1]];
    NSNumber * day = [self.days objectAtIndex:[self.pickerView selectedRowInComponent:2]];
    NSNumber * hour = [self.hours objectAtIndex:[self.pickerView selectedRowInComponent:3]];
    NSNumber * minite = [self.minites objectAtIndex:[self.pickerView selectedRowInComponent:4]];
    self.timeString = [NSString stringWithFormat:@"%@-%02d-%02d %02d:%02d:00",year,month.integerValue,day.integerValue,hour.integerValue,minite.integerValue];
    
    if ([self.delegate respondsToSelector:@selector(timePicker:selectTime:)]) {
        [self.delegate timePicker:self selectTime:self.timeString];
    }
    
    [self dismiss];
}

-(void)initDataSource
{
    self.component = [[NSCalendar currentCalendar] components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitHour|NSCalendarUnitMinute fromDate:[NSDate date]];
    self.years = @[[NSNumber numberWithInteger:self.component.year-2],[NSNumber numberWithInteger:self.component.year-1],[NSNumber numberWithInteger:self.component.year]];
    
    NSMutableArray * montharray = [NSMutableArray array];
    for (int i = 1; i <= 12; i++) {
        [montharray addObject:[NSNumber numberWithInteger:i]];
    }
    self.months = [NSArray arrayWithArray:montharray];
    
    NSMutableArray * dayarray = [NSMutableArray array];
    for (int i = 1; i <= 31; i++) {
        [dayarray addObject:[NSNumber numberWithInteger:i]];
    }
    self.days = [NSArray arrayWithArray:dayarray];
    
    NSMutableArray * hourarray = [NSMutableArray array];
    for (int i = 0; i <= 23; i++) {
        [hourarray addObject:[NSNumber numberWithInteger:i]];
    }
    self.hours = [NSArray arrayWithArray:hourarray];
    
    NSMutableArray * minitearray = [NSMutableArray array];
    for (int i = 0; i <= 59; i++) {
        [minitearray addObject:[NSNumber numberWithInteger:i]];
    }
    self.minites = [NSArray arrayWithArray:minitearray];

}

// 默认设置当前时间
-(void)setupData
{
    for (int i = 0; i < self.years.count; i++) {
        if (self.component.year == [[self.years objectAtIndex:i] integerValue]) {
            [self.pickerView selectRow:i inComponent:0 animated:NO];
        }
    }
    
    for (int i = 0; i < self.months.count; i++) {
        if (self.component.month == [[self.months objectAtIndex:i] integerValue]) {
            [self.pickerView selectRow:i inComponent:1 animated:NO];
        }
    }
    
    for (int i = 0; i < self.days.count; i++) {
        if (self.component.day == [[self.days objectAtIndex:i] integerValue]) {
            [self.pickerView selectRow:i inComponent:2 animated:NO];
        }
    }
    
    for (int i = 0; i < self.hours.count; i++) {
        if (self.component.hour == [[self.hours objectAtIndex:i] integerValue]) {
            [self.pickerView selectRow:i inComponent:3 animated:NO];
        }
    }
    
    for (int i = 0; i < self.minites.count; i++) {
        if (self.component.minute == [[self.minites objectAtIndex:i] integerValue]) {
            [self.pickerView selectRow:i inComponent:4 animated:NO];
        }
    }
    
    
}

-(void)showIn:(UIViewController *)viewCtrl
{
    [viewCtrl addChildViewController:self];
    [viewCtrl.view addSubview:self.view];
}

-(void)dismiss{
//    [self dismissViewControllerAnimated:YES completion:NULL];
    [self.view removeFromSuperview];
    [self removeFromParentViewController];
}

#pragma pickview
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 5;
}
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    NSInteger num = 0;
    switch (component) {
        case 0:
            num = self.years.count;
            break;
        case 1:
            num = self.months.count;
            break;
        case 2:
            num = self.days.count;
            break;
        case 3:
            num = self.hours.count;
            break;
        case 4:
            num = self.minites.count;
            break;
            
        default:
            break;
    }
    return num;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component API_UNAVAILABLE(tvos)
{
    return 70;
}
- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component API_UNAVAILABLE(tvos)
{
    return 42;
}
- (nullable NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component API_UNAVAILABLE(tvos)
{
    NSString * title = @"";
    switch (component) {
        case 0:
            title = [NSString stringWithFormat:@"%@年",[self.years objectAtIndex:row]];
            break;
        case 1:
            title = [NSString stringWithFormat:@"%@月",[self.months objectAtIndex:row]];
            break;
        case 2:
            title = [NSString stringWithFormat:@"%@日",[self.days objectAtIndex:row]];
            break;
        case 3:
            title = [NSString stringWithFormat:@"%@时",[self.hours objectAtIndex:row]];
            break;
        case 4:
            title = [NSString stringWithFormat:@"%@分",[self.minites objectAtIndex:row]];
            break;

        default:
            break;
    }
    return nil;
}

- (nullable NSAttributedString *)pickerView:(UIPickerView *)pickerView attributedTitleForRow:(NSInteger)row forComponent:(NSInteger)component API_AVAILABLE(ios(6.0)) API_UNAVAILABLE(tvos)
{
    NSString * title = @"";
    switch (component) {
        case 0:
            title = [NSString stringWithFormat:@"%@",[self.years objectAtIndex:row]];
            break;
        case 1:
            title = [NSString stringWithFormat:@"%@月",[self.months objectAtIndex:row]];
            break;
        case 2:
            title = [NSString stringWithFormat:@"%@日",[self.days objectAtIndex:row]];
            break;
        case 3:
            title = [NSString stringWithFormat:@"%@时",[self.hours objectAtIndex:row]];
            break;
        case 4:
            title = [NSString stringWithFormat:@"%@分",[self.minites objectAtIndex:row]];
            break;
            
        default:
            break;
    }
    
    NSMutableAttributedString * attrTitle = [[NSMutableAttributedString alloc] initWithString:title attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:16],NSForegroundColorAttributeName:[UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1]}];
    return attrTitle;

}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(nullable UIView *)view API_UNAVAILABLE(tvos)
{
    UILabel *pickerLabel = (UILabel*)view;
        if (!pickerLabel){
            pickerLabel = [[UILabel alloc] init];
        }
    [pickerLabel setTextColor:[UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1]];
    pickerLabel.adjustsFontSizeToFitWidth = YES;
    [pickerLabel setTextAlignment:NSTextAlignmentCenter];
    [pickerLabel setBackgroundColor:[UIColor clearColor]];
    [pickerLabel setFont:[UIFont systemFontOfSize:16.0f]];
    pickerLabel.attributedText = [self pickerView:pickerView attributedTitleForRow:row forComponent:component];
    return pickerLabel;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component API_UNAVAILABLE(tvos)
{
    
    switch (component) {
        case 0:
        {
            NSNumber * year = [self.years objectAtIndex:[self.pickerView selectedRowInComponent:0]];
            NSNumber * month = [self.months objectAtIndex:[self.pickerView selectedRowInComponent:1]];
            NSInteger days = [self monthDayWithYear:year.integerValue month:month.integerValue];
            NSMutableArray * dayarray = [NSMutableArray array];
            for (int i = 1; i <= days; i++) {
                [dayarray addObject:[NSNumber numberWithInteger:i]];
            }
            self.days = [NSArray arrayWithArray:dayarray];
            [pickerView selectRow:0 inComponent:2 animated:YES];
            [pickerView reloadComponent:2];
        }
            break;
        case 1:
        {
            NSNumber * year = [self.years objectAtIndex:[self.pickerView selectedRowInComponent:0]];
            NSNumber * month = [self.months objectAtIndex:[self.pickerView selectedRowInComponent:1]];
            NSInteger days = [self monthDayWithYear:year.integerValue month:month.integerValue];
            NSMutableArray * dayarray = [NSMutableArray array];
            for (int i = 1; i <= days; i++) {
                [dayarray addObject:[NSNumber numberWithInteger:i]];
            }
            self.days = [NSArray arrayWithArray:dayarray];
            [pickerView selectRow:0 inComponent:2 animated:YES];
            [pickerView reloadComponent:2];
        }
            break;
            
        default:
            break;
    }
}

-(NSInteger)monthDayWithYear:(NSInteger) year month:(NSInteger) month{

    // 字符串转日期

    NSString *dateStr = [NSString stringWithFormat:@"%ld-%ld-05 00:00:00",year,month];

    NSDateFormatter *format = [[NSDateFormatter alloc] init];

    format.dateFormat = @"yyyy-MM-dd HH:mm:ss";

    NSDate *date = [format dateFromString:dateStr];

    // 当前日历

    NSCalendar *calendar = [NSCalendar currentCalendar];

    NSRange range = [calendar rangeOfUnit:NSCalendarUnitDay inUnit:NSCalendarUnitMonth forDate:date];

    return range.length;

}


@end
