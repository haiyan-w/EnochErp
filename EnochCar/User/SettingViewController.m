//
//  SettingViewController.m
//  EnochCar
//
//  Created by 王海燕 on 2021/5/10.
//

#import "SettingViewController.h"
#import "ModifyPwdViewController.h"
#import "NetWorkAPIManager.h"
#import "SettingTableViewCell.h"
#import "UIView+Hint.h"

@interface SettingViewController ()<UITableViewDelegate, UITableViewDataSource>
@property(nonatomic,readwrite,strong)NSMutableArray * datasource;
@end

@implementation SettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.midTitle = @"设置";    
    self.datasource = [[NSMutableArray alloc] initWithObjects:@"密码修改", nil];
    
    NSInteger top  = 48;
    NSInteger left = 68;
    NSInteger bottom = 124;
    NSInteger btnH = 43;
    UIButton * logoutBtn = [[UIButton alloc] initWithFrame:CGRectMake(left, (self.view.frame.size.height - bottom - btnH), (self.view.frame.size.width - 2*left), btnH)];
    [logoutBtn addTarget:self action:@selector(logout) forControlEvents:UIControlEventTouchUpInside];
    [logoutBtn setTitle:@"退出" forState:UIControlStateNormal];
    [logoutBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    logoutBtn.titleLabel.backgroundColor = [UIColor clearColor];
    logoutBtn.titleLabel.font = [UIFont fontWithName:@"PingFang SC" size:16];
    logoutBtn.backgroundColor = [UIColor colorWithRed:59/255.0 green:66/255.0 blue:80/255.0 alpha:1];
    logoutBtn.layer.cornerRadius = 4;
    [self.view addSubview:logoutBtn];
    
    left = 36;
    UITableView * tableview = [[UITableView alloc] initWithFrame:CGRectMake(left, top+88, (self.view.frame.size.width - 2*left), 200)];
    tableview.backgroundColor = [UIColor clearColor];
    tableview.delegate = self;
    tableview.dataSource = self;
    tableview.separatorStyle = UITableViewCellSeparatorStyleNone;
//    [tableview registerClass:[UITableViewCell class] forCellReuseIdentifier:@"SettingTableViewCell"];
    [tableview registerNib:[UINib nibWithNibName:@"SettingTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"SettingTableViewCell"];
    [self.view addSubview:tableview];
}


-(void)logout
{
    if (!self.isNetworkOn) {
        [self.view showHint:[NSString stringWithFormat:@"%@",TEXT_NETWORKOFF_HINT]];
        return;
    }
    __weak SettingViewController * weakself = self;
    NetWorkAPIManager * manager = [NetWorkAPIManager defaultManager];
    [manager logoutsuccess:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:USERDEFAULTS_ACCOUNT];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:USERDEFAULTS_PASSWORD];
        
        NSNotificationCenter * notify = [NSNotificationCenter defaultCenter];
        [notify postNotificationName:NOTIFICATION_LOGOUT_SUCCESS object:NULL userInfo:NULL];
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        //错误提示
        [weakself.view showHint:@"退出失败"];
    }];
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.datasource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SettingTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"SettingTableViewCell"];
    NSString * dataStr = [self.datasource objectAtIndex:indexPath.row];
    cell.label.text = dataStr;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (0 == indexPath.row) {
        
        ModifyPwdViewController * modifyCtrl = [[ModifyPwdViewController alloc] init];
        [self.navigationController pushViewController:modifyCtrl animated:YES];
        
    }

}

@end
