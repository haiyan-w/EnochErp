//
//  GlobalInfoManager.h
//  EnochCar
//
//  Created by 王海燕 on 2021/6/18.
//

#import <Foundation/Foundation.h>

//自定义字段
#define USER_NAME @"name"
#define USER_ID   @"id"
#define USER_CELLPHONE @"cellphone"
#define USER_SSOUSER_ID @"ssoUserId"
#define USER_ACCESSRIGHTS @"accessRights"
#define USER_NAMEHINT @"nameHint"
#define USER_BRANCH @"branch"
#define BRANCH_NAME @"name"
#define BRANCH_ID @"id"

NS_ASSUME_NONNULL_BEGIN

@interface GlobalInfoManager : NSObject

+(instancetype)infoManager;

-(void)getALL;

-(void)queryUserInfo;
-(NSString *)getUserName;
-(NSInteger )getUserID;
-(NSString *)getBranchName;
-(NSInteger )getBranchID;
-(NSString *)getHeadUrl;
//
-(void)getBranchAttributes;

-(BOOL)needEngenee;

@end

NS_ASSUME_NONNULL_END
