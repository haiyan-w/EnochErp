//
//  PopViewController.m
//  EnochCar
//
//  Created by 王海燕 on 2021/5/20.
//

#import "PopViewController.h"



@interface PopViewController ()<UITableViewDelegate, UITableViewDataSource>
@property(nonatomic,readwrite,copy)NSArray * datasource;
@property(nonatomic,readwrite,copy)NSString * poptitle;

@property(nonatomic,readwrite,strong)UIView * contentView;
@property(nonatomic,readwrite,strong)UILabel * titleLab;
@end

@implementation PopViewController

-(instancetype)initWithTitle:(NSString *)title Data:(NSArray *)dataArray
{
    self = [super init];
    if (self) {
        _poptitle = title;
        _datasource = dataArray;
    }
    return self;
    
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor colorWithRed:55/255.0 green:55/255.0 blue:55/255.0 alpha:0.5];
    
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(taponbg:)];
    tap.delegate = self;
    [self.view addGestureRecognizer:tap];
    
    NSInteger titleH = 10;
    NSInteger bottomH = 20;
//    NSInteger maxH = self.view.bounds.size.height - 100;
    NSInteger maxH = [UIScreen mainScreen].bounds.size.height*2/3 -titleH - 44;
    NSInteger cellH = 57;
    NSInteger tableH = cellH * (self.datasource.count+1);
    if (tableH > maxH) {
        tableH = maxH;
    }
    
    NSInteger contentH = titleH + tableH +44;
    
   _contentView = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height - contentH, self.view.bounds.size.width, contentH)];
    _contentView.backgroundColor = [UIColor whiteColor];
    _contentView.layer.cornerRadius = 12;
    [self.view addSubview:_contentView];

    UITableView * tableview = [[UITableView alloc] initWithFrame:CGRectMake(0, titleH, self.view.bounds.size.width, tableH)];
    tableview.dataSource = self;
    tableview.delegate = self;
    [tableview registerClass:[UITableViewCell class] forCellReuseIdentifier:@"poptableviewcell"];
    tableview.showsVerticalScrollIndicator = NO;
    tableview.showsHorizontalScrollIndicator = NO;
    [_contentView addSubview:tableview];
    
}

-(void)taponbg:(UIGestureRecognizer*)gesture
{
    [self dismiss];
    
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

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 57;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.datasource.count+1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"poptableviewcell"];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"poptableviewcell"];
    }
    cell.textLabel.textAlignment = NSTextAlignmentCenter;
    cell.accessoryType = UITableViewCellAccessoryNone;
    if (indexPath.row > 0) {
        cell.textLabel.text = [self.datasource objectAtIndex:(indexPath.row-1)];
        cell.textLabel.font = [UIFont fontWithName:@"PingFang SC" size:17];
        cell.textLabel.textColor = [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1];
    }else{
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.textLabel.text = self.poptitle;
        cell.textLabel.font = [UIFont fontWithName:@"PingFang SC" size:14];
        cell.textLabel.textColor = [UIColor colorWithRed:191/255.0 green:191/255.0 blue:191/255.0 alpha:1];
        
    }
    
    
    
    return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (0 == indexPath.row) {
        
    }else {
        NSInteger index = indexPath.row -1;
        [self.delegate popview:self disSelectRowAtIndex:index];
        [self dismiss];
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    CGPoint pt = [touch locationInView:self.view];
    
    CGRect rc= self.contentView.frame;
    
    if (CGRectContainsPoint(rc, pt)) {
        
        return NO;
    }
    return YES;
}

@end
