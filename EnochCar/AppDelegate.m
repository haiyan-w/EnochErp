//
//  AppDelegate.m
//  EnochCar
//
//  Created by HAIYAN on 2021/5/7.
//

#import "AppDelegate.h"
#import "LoginViewController.h"
#import "MainViewController.h"
#import "UserViewController.h"
#import "GlobalInfoManager.h"
#import "CommonDefine.h"
#import "ExperienceViewController.h"
#import "BaseNavigationViewController.h"
#import "CommonTool.h"


#define WECHAT_APPID @"wx618bde376421e2d4"
#define UNIVERSER_LINK @"https://enocloud.enoch-car.com/app/"

@interface AppDelegate ()
@property(nonatomic,readwrite,strong) MainViewController * mainCtrl;

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    [CommonTool changeOrientation:UIInterfaceOrientationPortrait];
    
    self.shouldLandscapeRight = NO;
    self.window = [[UIWindow alloc] init];
    self.window.backgroundColor = [UIColor whiteColor];
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 13.0) {
        self.window.overrideUserInterfaceStyle = UIUserInterfaceStyleLight;
    }

//    [self CheckVersion];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginSucess) name:NOTIFICATION_LOGIN_SUCCESS object:NULL];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginSkip) name:NOTIFICATION_LOGIN_SKIP object:NULL];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(logoutSucess) name:NOTIFICATION_LOGOUT_SUCCESS object:NULL];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showLoginView) name:NOTIFICATION_SHOWLOGIN object:NULL];
    
    [self showLoginView];
//    [self showMainView];
    
    return YES;
}

-(UIInterfaceOrientationMask)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window
{
    if (!self.shouldLandscapeRight) {

        return UIInterfaceOrientationMaskPortrait;
    }else {
        return UIInterfaceOrientationMaskPortrait|UIInterfaceOrientationMaskLandscapeRight;
    }
}

//-(BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
//{
//
//    return  [WXApi handleOpenURL:url delegate:self];
//}
//
//-(BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
//{
//    return [WXApi handleOpenURL:url delegate:self];
//}

-(void)applicationWillTerminate:(UIApplication *)application
{
    [self saveData];
}

//- (void)onReq:(BaseReq *)req {
//    if ([req isKindOfClass:[ShowMessageFromWXReq class]]) {
//        if (_delegate
//            && [_delegate respondsToSelector:@selector(managerDidRecvShowMessageReq:)]) {
//            ShowMessageFromWXReq *showMessageReq = (ShowMessageFromWXReq *)req;
//            [_delegate managerDidRecvShowMessageReq:showMessageReq];
//        }
//    } else if ([req isKindOfClass:[LaunchFromWXReq class]]) {
//        if (_delegate
//            && [_delegate respondsToSelector:@selector(managerDidRecvLaunchFromWXReq:)]) {
//            LaunchFromWXReq *launchReq = (LaunchFromWXReq *)req;
//            [_delegate managerDidRecvLaunchFromWXReq:launchReq];
//        }
//    }
//}
//
//-(void) onResp:(BaseResp*)resp
//{
//    if ([resp isKindOfClass:[SendAuthResp class]]) //判断是否为授权请求，否则与微信支付等功能发生冲突
//        {
//            SendAuthResp *aresp = (SendAuthResp *)resp;
//            if (aresp.errCode== 0)
//            {
//                NSLog(@"code %@",aresp.code);
//                [[NSNotificationCenter defaultCenter] postNotificationName:@"wechatDidLoginNotification" object:self userInfo:@{@"code":aresp.code}];
//            }
//        }
//}

-(void)loginSucess
{
    [[GlobalInfoManager infoManager] getBranchAttributes];
    [self showMainView];

}

-(void)loginSkip
{
    [self showExperienceView];
}

-(void)logoutSucess
{
    [self saveData];
    _mainCtrl = nil;
    [self showLoginView];
}

-(void)showLoginView
{
    LoginViewController * loginCtrl = [[LoginViewController alloc]init];
    BaseNavigationViewController * navCtrl = [[BaseNavigationViewController alloc] initWithRootViewController:loginCtrl];
    navCtrl.navigationBar.barStyle = UIBarStyleDefault;
    navCtrl.navigationBarHidden = YES;
    self.window.rootViewController = navCtrl;
    [self.window makeKeyAndVisible];
}

-(void)showMainView
{
    _mainCtrl = [[MainViewController alloc]init];
    _mainCtrl.tabBarItem.title = @"接车";
    _mainCtrl.tabBarItem.image = [UIImage imageNamed:@"icon_pickup_sel"];

    UserViewController * userCtrl = [[UserViewController alloc] init];
    userCtrl.tabBarItem.title = @"我的";
    userCtrl.tabBarItem.image = [UIImage imageNamed:@"icon_my_unsel"];

    UITabBarController * tabctrl = [[UITabBarController alloc] init];
    [tabctrl setViewControllers:@[_mainCtrl, userCtrl]];
    tabctrl.tabBar.tintColor = [UIColor colorWithRed:59/255.0 green:66/255.0 blue:80/255.0 alpha:1];

    BaseNavigationViewController * navCtrl = [[BaseNavigationViewController alloc] initWithRootViewController:tabctrl];
    navCtrl.navigationBar.barStyle = UIBarStyleDefault;
    navCtrl.navigationBarHidden = YES;
    self.window.rootViewController = navCtrl;
    [self.window makeKeyAndVisible];
}

//展示体验版
-(void)showExperienceView
{
    ExperienceViewController * experienceCtrl = [[ExperienceViewController alloc] init];
    BaseNavigationViewController * navCtrl = [[BaseNavigationViewController alloc] initWithRootViewController:experienceCtrl];
    navCtrl.navigationBar.barStyle = UIBarStyleDefault;
    navCtrl.navigationBarHidden = YES;
    self.window.rootViewController = navCtrl;
    [self.window makeKeyAndVisible];
}

//退出时保存未完成的开单信息
-(void)saveData
{
    if (_mainCtrl) {
        [_mainCtrl saveLastSeviceInfo];
    }
}


#pragma mark - Core Data Saving support

//- (void)saveContext {
//    NSManagedObjectContext *context = self.persistentContainer.viewContext;
//    NSError *error = nil;
//    if ([context hasChanges] && ![context save:&error]) {
//        // Replace this implementation with code to handle the error appropriately.
//        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
//        NSLog(@"Unresolved error %@, %@", error, error.userInfo);
//        abort();
//    }
//}


#pragma mark - version check & update
//-(void)CheckVersion
//{
//    NSDictionary * dic = [[NSBundle mainBundle] infoDictionary];
//    NSString * verStr = [dic objectForKey:@"CFBundleLongVersionString"];
//
//
//}

@end
