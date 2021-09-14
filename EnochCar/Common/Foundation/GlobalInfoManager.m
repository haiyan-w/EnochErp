//
//  GlobalInfoManager.m
//  EnochCar
//
//  Created by 王海燕 on 2021/6/18.
//

#import "GlobalInfoManager.h"
#import "NetWorkAPIManager.h"



static GlobalInfoManager * infoManager;

@interface GlobalInfoManager()
@property(nonatomic,strong) NSDictionary * userInfo;
@property(nonatomic,strong) NSArray * branchAttributes;//系统配置
//
@property(nonatomic,assign) BOOL needEngenee;

@end

@implementation GlobalInfoManager

+(instancetype)infoManager
{
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        infoManager = [[GlobalInfoManager alloc] init];
    });
    
    return infoManager;
}

-(NSDictionary *)userInfo
{
    if (_userInfo) {
        _userInfo = [NSDictionary dictionary];
    }
    return _userInfo;
    
}

-(NSArray*)branchAttributes
{
    if (_branchAttributes) {
        _branchAttributes = [NSArray array];
    }
    return _branchAttributes;
}

-(void)getALL
{
    [self queryUserInfo];
    [self getBranchAttributes];
}

-(void)queryUserInfo
{
    __weak  GlobalInfoManager * weakself = self;
    [[NetWorkAPIManager defaultManager] queryUserInfosuccess:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary * resultDic = responseObject;
        NSArray * array = [resultDic objectForKey:@"data"];
        NSDictionary * dic = [array firstObject];
        
        NSNumber * userId = [dic objectForKey:USER_ID];
        NSString * name = [dic objectForKey:USER_NAME];
        NSString * cellphone = [dic objectForKey:USER_CELLPHONE];
        NSString * ssoUserId = [dic objectForKey:USER_SSOUSER_ID];//微信登陆的id不一样
        NSArray * accessRights = [dic objectForKey:USER_ACCESSRIGHTS];//权限
        NSString * nameHint = [dic objectForKey:USER_NAMEHINT];//

        NSDictionary * branch = [dic objectForKey:USER_BRANCH];
        NSNumber * branchId = [branch objectForKey:BRANCH_ID];
        NSString *branchName = [branch objectForKey:BRANCH_NAME];
        //  微信登陆
        NSDictionary * wechatUser = [[dic objectForKey:@"ssoUser"] objectForKey:@"wechatUser"];
        if (wechatUser) {
            NSString * headUrl = [wechatUser objectForKey:@"headUrl"];
            [infoManager.userInfo setValue:headUrl forKey:@"headUrl"];
        }else {

        }
        
        infoManager.userInfo = [NSDictionary dictionaryWithDictionary:dic];
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
    }];
}

-(NSString *)getUserName
{
    return [self.userInfo objectForKey:USER_NAME];
}

-(NSInteger )getUserID
{
    return [[self.userInfo objectForKey:USER_ID] integerValue];
}

-(NSString *)getBranchName
{
    return [[self.userInfo objectForKey:USER_BRANCH] objectForKey:BRANCH_NAME];
}

-(NSInteger )getBranchID
{
    return [[[self.userInfo objectForKey:USER_BRANCH] objectForKey:BRANCH_ID] integerValue];
}

//目前只有微信绑定用户有头像
-(NSString *)getHeadUrl
{
    NSDictionary * wechatUser = [[self.userInfo objectForKey:@"ssoUser"] objectForKey:@"wechatUser"];
    if (wechatUser) {
        NSString * headUrl = [wechatUser objectForKey:@"headUrl"];
        return headUrl;
    }
    return @"";
}


-(void)getBranchAttributes
{
    __weak GlobalInfoManager * weakself = self;
    
    [[NetWorkAPIManager defaultManager] getBranchAttributeSuccess:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSDictionary * resp = responseObject;
        NSArray * data = [resp objectForKey:@"data"];
        weakself.branchAttributes = [NSArray arrayWithArray:data];
        NSLog(@"branchAttributes %@",weakself.branchAttributes);
    } Failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
    }];
   
}



-(BOOL)needEngenee
{
    for (NSDictionary * dic in self.branchAttributes) {
        NSDictionary * idDic = [dic objectForKey:@"id"];
        if ([[idDic objectForKey:@"code"] isEqualToString:@"FRCASN"]) {
            if ([[dic objectForKey:@"value"] isEqualToString:@"Y"]) {
                return YES;
            }
        }
    }
    return NO;
}

@end
