//
//  NetWorkAPIManager.m
//  EnochCar
//
//  Created by 王海燕 on 2021/5/10.
//

#import "NetWorkAPIManager.h"
#import <AFNetworking/AFNetworking.h>
#import "CommonJSONResponseSerializer.h"
#import "GlobalInfoManager.h"
#import "CommonTool.h"
#import "CommonTool.h"

//用户详情字段
#define USER_NAME @"name"
#define USER_ID   @"id"
#define USER_CELLPHONE @"cellphone"
#define USER_SSOUSER_ID @"ssoUserId"
#define USER_ACCESSRIGHTS @"accessRights"
#define USER_NAMEHINT @"nameHint"
#define USER_BRANCH @"branch"
#define BRANCH_NAME @"name"
#define BRANCH_ID @"id"

//#define RESOURCEURL  @"https://resource.enoch-car.com/"

#define BWFileBoundary @"----WebKitFormBoundaryrXactNAchUCaIzMy"

#define BWNewLine @"\r\n"
#define BWEncode(str) [str dataUsingEncoding:NSUTF8StringEncoding]

@interface NetWorkAPIManager()
@property(nonatomic,readwrite,strong)AFHTTPSessionManager * manager;
//@property(nonatomic,readwrite,strong)NSString * token;
@property(nonatomic,readwrite,weak) NetWorkAPIManager * weakself;
@property(nonatomic,readwrite,strong) NSMutableDictionary * cookie;

@end


@implementation NetWorkAPIManager


static NetWorkAPIManager * apiManager;


+(instancetype)defaultManager
{
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        apiManager = [[NetWorkAPIManager alloc] init];
    });
    
    return apiManager;
}

-(instancetype)init
{
    self = [super init];
    if (!self) {
        return nil;
    }
    _manager = [[AFHTTPSessionManager alloc] init];
    _weakself = self;
    _manager.securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone];
    _manager.responseSerializer = [CommonJSONResponseSerializer serializer];
    _manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [_manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [_manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [_manager.requestSerializer setValue:[CommonTool terminalString] forHTTPHeaderField:@"ENOCH_TERMINAL"];
    return self;
}

-(void)resetManager
{
    _manager.securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone];
    _manager.responseSerializer = [CommonJSONResponseSerializer serializer];
    _manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [_manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [_manager.requestSerializer setValue:[self DataTOjsonString:self.cookie] forHTTPHeaderField:@"Cookie"];
    [_manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [_manager.requestSerializer setValue:[CommonTool terminalString] forHTTPHeaderField:@"ENOCH_TERMINAL"];
}

-(void)application:(NSDictionary *)info Success:(nullable void (^)(NSURLSessionDataTask *task, id _Nullable responseObject))success
           Failure:(nullable void (^)(NSURLSessionDataTask * _Nullable task, NSError *error))failure
{
    NSString * urlString = [NSString stringWithFormat:@"%@",APPLICATIONURL];
    NSMutableDictionary * parmdic = [[NSMutableDictionary alloc] init];
    NSMutableArray * dataarray = [NSMutableArray arrayWithObject:info];
    [parmdic setValue:dataarray forKey:@"data"];
    
    [_manager POST:urlString parameters:parmdic headers:NULL progress:^(NSProgress * _Nonnull uploadProgress) {

    } success:success failure:failure];
    
}

-(void)loginWithUsername:(NSString *)name Password:(NSString *)password success:(nullable void (^)(NSURLSessionDataTask *task, id _Nullable responseObject))success
                 failure:(nullable void (^)(NSURLSessionDataTask * _Nullable task, NSError *error))failure
{
    __weak NetWorkAPIManager * weakself = self;

    NSString * appendStr = @"/enocloud/security/authenticate";
    NSString * urlString = [NSString stringWithFormat:@"%@%@",BASEURL,appendStr];
    urlString = [urlString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    NSMutableDictionary * parmdic = [[NSMutableDictionary alloc] init];
    NSMutableDictionary * datadic = [[NSMutableDictionary alloc] init];
    [datadic setValue:[NSNumber numberWithBool:true]forKey:@"keepSignedIn"];
//    [datadic setValue:@"" forKey:@"wechatUnionId"];
    [datadic setValue:name forKey:@"username"];
    [datadic setValue:password forKey:@"password"];
    
    NSMutableArray * dataarray = [NSMutableArray arrayWithObject:datadic];
    [parmdic setValue:dataarray forKey:@"data"];

    _manager.securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone];
    _manager.responseSerializer = [CommonJSONResponseSerializer serializer];
    _manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [_manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [_manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [_manager.requestSerializer setValue:[CommonTool terminalString] forHTTPHeaderField:@"ENOCH_TERMINAL"];
    [_manager.requestSerializer setValue:@"" forHTTPHeaderField:@"Cookie"];

    [_manager POST:urlString parameters:parmdic headers:NULL progress:^(NSProgress * _Nonnull uploadProgress) {

    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject){

        NSHTTPURLResponse * response = (NSHTTPURLResponse *)task.response;
        NSDictionary * headDic = [response allHeaderFields];

        NSArray * cookies = [NSHTTPCookie cookiesWithResponseHeaderFields:headDic forURL:[NSURL URLWithString:BASEURL]];

        NSMutableDictionary * cookieDic= [NSMutableDictionary dictionary];

        for(NSHTTPCookie *cookie in cookies)
        {
            [cookieDic setValue:cookie.value forKey:cookie.name];

        }
        self.cookie = cookieDic;
        [_manager.requestSerializer setValue:[self DataTOjsonString:self.cookie] forHTTPHeaderField:@"Cookie"];

        success(task, responseObject);
        
    } failure:failure];
}



//查询当前用户信息
-(void)queryUserInfosuccess:(nullable void (^)(NSURLSessionDataTask *task, id _Nullable responseObject))success
                    failure:(nullable void (^)(NSURLSessionDataTask * _Nullable task, NSError *error))failure
{
    NSString * appendStr = @"/enocloud/security/user";
    NSString * urlString = [NSString stringWithFormat:@"%@%@",BASEURL,appendStr];

    [self resetManager];
    __weak  NetWorkAPIManager * weakself = self;
    [_manager GET:urlString parameters:NULL headers:NULL progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject){
        
        NSDictionary * resultDic = responseObject;
        NSArray * array = [resultDic objectForKey:@"data"];
        NSDictionary * dic = [array firstObject];
        
        weakself.userID = [[dic objectForKey:USER_ID] integerValue];
        weakself.userName = [dic objectForKey:USER_NAME];
        NSString * cellphone = [dic objectForKey:USER_CELLPHONE];
        NSString * ssoUserId = [dic objectForKey:USER_SSOUSER_ID];//微信登陆的id不一样
        NSArray * accessRights = [dic objectForKey:USER_ACCESSRIGHTS];//权限
        NSString * nameHint = [dic objectForKey:USER_NAMEHINT];//

        NSDictionary * branch = [dic objectForKey:USER_BRANCH];
        weakself.branchID = [[branch objectForKey:BRANCH_ID] integerValue];
        weakself.branchName = [branch objectForKey:BRANCH_NAME];
        //  微信登陆
        NSDictionary * wechatUser = [[dic objectForKey:@"ssoUser"] objectForKey:@"wechatUser"];
        if (wechatUser) {
            weakself.headUrl = [wechatUser objectForKey:@"headUrl"];
        }
        
        success(task,responseObject);
        
    } failure:failure];
  
}

-(void)logoutsuccess:(nullable void (^)(NSURLSessionDataTask *task, id _Nullable responseObject))success
             failure:(nullable void (^)(NSURLSessionDataTask * _Nullable task, NSError *error))failure
{
    NSString * appendStr = @"/enocloud/security/logout";
    NSString * urlString = [NSString stringWithFormat:@"%@%@",BASEURL,appendStr];
    
    [self resetManager];
    
    [_manager POST:urlString parameters:NULL headers:NULL progress:^(NSProgress * _Nonnull uploadProgress) {
        NSLog(@"==== logout uploadProgress");
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        self.branchID = 0;
        self.userID = 0;
        self.userName = @"";
        self.branchName = @"";
        self.headUrl = @"";
       success(task, responseObject);
    }  failure:failure];
}


-(void)modifyPassword:(NSString*)oldPassword newPwd:(NSString *)newPassword success:(nullable void (^)(NSURLSessionDataTask *task, id _Nullable responseObject))success
              failure:(nullable void (^)(NSURLSessionDataTask * _Nullable task, NSError *error))failure
{
    NSString * appendStr = @"/enocloud/security/password";
    NSString * urlString = [NSString stringWithFormat:@"%@%@",BASEURL,appendStr];
    
    NSMutableDictionary * data = [NSMutableDictionary dictionary];
    [data setValue:oldPassword forKey:@"originalPassword"];
    [data setValue:newPassword forKey:@"newPassword"];
    NSArray * array = [NSArray arrayWithObject:data];
    NSMutableDictionary * parm = [NSMutableDictionary dictionary];
    [parm setValue:array forKey:@"data"];
    
    [self resetManager];
    
    [_manager POST:urlString parameters:parm headers:NULL progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:success failure:failure];
    
}

//获取系统配置
-(void)getBranchAttributeSuccess:(nullable void (^)(NSURLSessionDataTask *task, id _Nullable responseObject))success
                      Failure:(nullable void (^)(NSURLSessionDataTask * _Nullable task, NSError *error))failure
{
    NSString * appendStr = @"/enocloud/common/branch/attribute";
    NSString * urlString = [NSString stringWithFormat:@"%@%@",BASEURL,appendStr];
    urlString = [urlString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    [self resetManager];
    
    [_manager GET:urlString parameters:NULL headers:NULL progress:^(NSProgress * _Nonnull downloadProgress) {
    }success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary * resultDic = responseObject;
        NSArray * array = [resultDic objectForKey:@"data"];
        
        for (NSDictionary * dic in array) {
            NSString * code = [[dic objectForKey:@"id"] objectForKey:@"code"];
            if ([code isEqualToString:@"SVMTVLM"]) {
                self.chargeMethodCode = [dic objectForKey:@"value"];
            }
            if ([code isEqualToString:@"SVMLBHPRC"]) {
                self.price = [dic objectForKey:@"value"];
            }
            if ([code isEqualToString:@"FRCASN"]) {
                NSString * needEngineer = [dic objectForKey:@"value"];
                if ([needEngineer isEqualToString:@"Y"]) {
                    self.needEngineer = YES;
                }else {
                    self.needEngineer = NO;
                }
            }
            
        }
        
        success(task,responseObject);
    } failure:failure];
    
//    [_manager GET:urlString parameters:NULL headers:NULL progress:^(NSProgress * _Nonnull downloadProgress) {
//
//    } success:success failure:failure];
    
}


//获取oss签名
-(void)getOSSSignatureSuccess:(nullable void (^)(NSURLSessionDataTask *task, id _Nullable responseObject))success
                      Failure:(nullable void (^)(NSURLSessionDataTask * _Nullable task, NSError *error))failure
{
    NSString * appendStr = @"/enocloud/common/oss/signature";
    NSString * urlString = [NSString stringWithFormat:@"%@%@",BASEURL,appendStr];
    urlString = [urlString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    [self resetManager];
    
    
    [_manager POST:urlString parameters:NULL headers:NULL progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:success failure:failure];
   
}

-(NSURLSessionDataTask *)imageRecognizeWithData:(NSData *)data Type:(RecognizeType)type success:(nullable void (^)(NSURLSessionDataTask *task, id _Nullable responseObject))success
                      failure:(nullable void (^)(NSURLSessionDataTask * _Nullable task, NSError *error))failure
{
    NSString * appendStr = @"/enocloud/common/scan/plateno";

    switch (type) {
        case RecognizeTypePlateNO:        //车牌号识别
            appendStr = @"/enocloud/common/scan/plateno";
            
            break;
        case RecognizeTypeDrivingLicence: //行驶证识别
            appendStr = @"/enocloud/common/scan/drivinglicence";
            break;
        case RecognizeTypeVIN:            //VIN码识别
            appendStr = @"/enocloud/common/scan/vin";
            break;
            
        default:
            break;
    }
    
    NSString * urlString = [NSString stringWithFormat:@"%@%@",BASEURL,appendStr];
    
//    CommonJSONResponseSerializer * orgResponse = (CommonJSONResponseSerializer * )_manager.responseSerializer;
//    AFJSONRequestSerializer * orgRequest = (AFJSONRequestSerializer *)_manager.requestSerializer;
    
    _manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    _manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@",BWFileBoundary];
    [_manager.requestSerializer setValue:contentType forHTTPHeaderField:@"Content-Type"];
    _manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/plain", @"multipart/form-data", @"application/json", @"text/html", @"image/jpeg", @"image/png", @"application/octet-stream", @"text/json", nil];
    [_manager.requestSerializer setValue:[CommonTool terminalString] forHTTPHeaderField:@"ENOCH_TERMINAL"];
    
   NSURLSessionDataTask * task = [_manager POST:urlString parameters:NULL headers:NULL constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        [formData appendPartWithFileData:data name:@"file" fileName:@"123.jpeg" mimeType:@"image/jpeg"];
        
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:success failure:failure];
    
    return task;
}

//快速查询车辆信
-(void)queryVehicleInfo:(NSString *)name plateNo:(NSString *)plateNo vin:(NSString *)vin success:(nullable void (^)(NSURLSessionDataTask *task, id _Nullable responseObject))success
                failure:(nullable void (^)(NSURLSessionDataTask * _Nullable task, NSError *error))failure
{
    __weak NetWorkAPIManager * weakself = self;

    NSString * appendStr = [NSString stringWithFormat:@"/enocloud/common/vehicle/query?"];
    if (plateNo) {
        appendStr = [appendStr stringByAppendingString:[NSString stringWithFormat:@"plateNo=%@",plateNo]];
    }
    if (name) {
        appendStr = [appendStr stringByAppendingString:[NSString stringWithFormat:@"&customerName=%@",name]];
    }
    if (vin) {
        appendStr = [appendStr stringByAppendingString:[NSString stringWithFormat:@"&vin=%@",vin]];
    }

    if ([name isEqualToString:plateNo] & [plateNo isEqualToString:vin]) {
        appendStr = [NSString stringWithFormat:@"/enocloud/common/vehicle/query?QuickSearch=%@",plateNo];
    }
    NSString * urlString = [NSString stringWithFormat:@"%@%@",BASEURL,appendStr];
    urlString = [urlString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    
    [self resetManager];
    
    [_manager GET:urlString parameters:NULL headers:NULL progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:success failure:failure];
}

//获取车辆详情
-(void)getVehicleInfoWithPlateNo:(NSString *)plateNo success:(nullable void (^)(NSURLSessionDataTask *task, id _Nullable responseObject))success
                failure:(nullable void (^)(NSURLSessionDataTask * _Nullable task, NSError *error))failure
{
    __weak NetWorkAPIManager * weakself = self;
    NSString * appendStr = [NSString stringWithFormat:@"/enocloud/common/vehicle?plateNo=%@",plateNo];
    NSString * urlString = [NSString stringWithFormat:@"%@%@",BASEURL,appendStr];
    urlString = [urlString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    
    [self resetManager];
    
    [_manager GET:urlString parameters:NULL headers:NULL progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:success failure:failure];
}

-(void)queryCustomWithName:(NSString *)name Cellphone:(NSString *)cellphone Success:(nullable void (^)(NSURLSessionDataTask *task, id _Nullable responseObject))success
                   Failure:(nullable void (^)(NSURLSessionDataTask * _Nullable task, NSError *error))failure
{
//    __weak NetWorkAPIManager * weakself = self;
    NSString * appendStr = [NSString stringWithFormat:@"/enocloud/common/customer?name=%@&cellphone=%@",name, cellphone];
    NSString * urlString = [NSString stringWithFormat:@"%@%@",BASEURL,appendStr];
    urlString = [urlString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    
    [self resetManager];
    
    [_manager GET:urlString parameters:NULL headers:NULL progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:success failure:failure];
    
}

-(void)createCustomer:(NSDictionary*)customInfo success:(nullable void (^)(NSURLSessionDataTask *task, id _Nullable responseObject))success
            failure:(nullable void (^)(NSURLSessionDataTask * _Nullable task, NSError *error))failure
{
    NSString * appendStr = @"/enocloud/common/customer";
    NSString * urlString = [NSString stringWithFormat:@"%@%@",BASEURL,appendStr];
    //过滤必填项
    [customInfo setValue:[NSNumber numberWithBool:TRUE] forKey:@"ignoreCheck"];
    //默认设置
    [customInfo setValue:[NSNumber numberWithFloat:1] forKey:@"serviceGoodsDiscountRate"];
    [customInfo setValue:[NSNumber numberWithFloat:1] forKey:@"serviceMaintenanceDiscountRate"];
    
    NSMutableDictionary * parm = [NSMutableDictionary dictionary];
    NSMutableArray * array = [NSMutableArray array];
    [parm setValue:array forKey:@"data"];
    [array addObject:customInfo];

    [self resetManager];
    
    [_manager POST:urlString parameters:parm headers:NULL progress:^(NSProgress * _Nonnull uploadProgress) {

    } success:success failure:failure];
}

-(void)updateCustomer:(NSDictionary *)customInfo success:(nullable void (^)(NSURLSessionDataTask *task, id _Nullable responseObject))success
            failure:(nullable void (^)(NSURLSessionDataTask * _Nullable task, NSError *error))failure
{
    NSString * appendStr = @"/enocloud/common/customer";
    NSString * urlString = [NSString stringWithFormat:@"%@%@",BASEURL,appendStr];
    //过滤必填项
    [customInfo setValue:[NSNumber numberWithBool:TRUE] forKey:@"ignoreCheck"];
    
    NSMutableDictionary * parm = [NSMutableDictionary dictionary];
    NSMutableArray * array = [NSMutableArray array];
    [parm setValue:array forKey:@"data"];
    [array addObject:customInfo];

    [self resetManager];
    
    [_manager PUT:urlString parameters:parm headers:NULL success:success failure:failure];
    
}



-(void)createVehicle:(NSDictionary *)vehicleInfo success:(nullable void (^)(NSURLSessionDataTask *task, id _Nullable responseObject))success
             failure:(nullable void (^)(NSURLSessionDataTask * _Nullable task, NSError *error))failure
{
    NSString * appendStr = @"/enocloud/common/vehicle";
    NSString * urlString = [NSString stringWithFormat:@"%@%@",BASEURL,appendStr];
    
    //过滤必填项
    [vehicleInfo setValue:[NSNumber numberWithBool:TRUE] forKey:@"ignoreCheck"];
    
    NSMutableDictionary * parm = [NSMutableDictionary  dictionary];
    NSMutableArray* array = [NSMutableArray array];
    [array addObject:vehicleInfo];
    [parm setValue:array forKey:@"data"];
        
    [self resetManager];
    
    [_manager POST:urlString parameters:parm headers:NULL progress:^(NSProgress * _Nonnull uploadProgress) {
    } success:success failure:failure];
}

-(void)updateVehicle:(NSDictionary *)vehicleInfo success:(nullable void (^)(NSURLSessionDataTask *task, id _Nullable responseObject))success
             failure:(nullable void (^)(NSURLSessionDataTask * _Nullable task, NSError *error))failure

{
    NSString * appendStr = @"/enocloud/common/vehicle";
    NSString * urlString = [NSString stringWithFormat:@"%@%@",BASEURL,appendStr];
    
    //过滤必填项
    [vehicleInfo setValue:[NSNumber numberWithBool:TRUE] forKey:@"ignoreCheck"];
    
    NSMutableDictionary * parm = [NSMutableDictionary  dictionary];
    NSMutableArray* array = [NSMutableArray array];
    [array addObject:vehicleInfo];
    [parm setValue:array forKey:@"data"];
        
    [self resetManager];
    
    [_manager PUT:urlString parameters:parm headers:NULL success:success failure:failure];
    
}

//创建工单
-(void)createService:(NSDictionary *)info success:(nullable void (^)(NSURLSessionDataTask *task, id _Nullable responseObject))success
             failure:(nullable void (^)(NSURLSessionDataTask * _Nullable task, NSError *error))failure;
{
    NSString * appendStr = @"/enocloud/service";
    NSString * urlString = [NSString stringWithFormat:@"%@%@",BASEURL,appendStr];

    //过滤必填项
    [info setValue:[NSNumber numberWithBool:TRUE] forKey:@"ignoreCheck"];
    
    NSMutableDictionary * parm = [NSMutableDictionary  dictionary];
    NSMutableArray* array = [NSMutableArray array];
    [parm setValue:array forKey:@"data"];
    [array addObject:info];
    
    [self resetManager];
    
    [_manager POST:urlString parameters:parm headers:NULL progress:^(NSProgress * _Nonnull uploadProgress) {
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary * resp = responseObject;
        NSMutableDictionary * asevice = [NSMutableDictionary dictionaryWithDictionary:info];
        [self queryService:[[[resp objectForKey:@"data"] firstObject] integerValue] success:^(NSURLSessionDataTask *task, id  _Nullable responseObject) {
            NSDictionary * dic = responseObject;
//            NSMutableDictionary * parm = [NSMutableDictionary dictionaryWithObject:[dic objectForKey:@"data"] forKey:@"data"];
            NSMutableDictionary * seviceDic = [NSMutableDictionary dictionaryWithDictionary:[[dic objectForKey:@"data"] firstObject]];
            [seviceDic setValue:[NSDictionary dictionary] forKey:@"serviceAccidentSettlement"];
            [seviceDic setValue:[NSDictionary dictionary] forKey:@"qualityInspector"];
            [seviceDic setValue:[NSDictionary dictionaryWithObject:@"IM" forKey:@"code"] forKey:@"nextStep"];
            [self updateService:seviceDic success:success failure:failure];
            
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError *error) {

        }];

    } failure:failure];
    
}

//查询工单信息
-(void)queryService:(NSInteger)seviceID success:(nullable void (^)(NSURLSessionDataTask *task, id _Nullable responseObject))success
             failure:(nullable void (^)(NSURLSessionDataTask * _Nullable task, NSError *error))failure
{
    NSString * appendStr = [NSString stringWithFormat:@"/enocloud/service/%d",seviceID];
    NSString * urlString = [NSString stringWithFormat:@"%@%@",BASEURL,appendStr];
    
    [self resetManager];
    
    [_manager GET:urlString parameters:NULL headers:NULL progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:success failure:failure];
}

//更新工单状态
-(void)updateService:(NSDictionary *)asevice success:(nullable void (^)(NSURLSessionDataTask *task, id _Nullable responseObject))success
             failure:(nullable void (^)(NSURLSessionDataTask * _Nullable task, NSError *error))failure
{
    NSString * appendStr = @"/enocloud/service";
    NSString * urlString = [NSString stringWithFormat:@"%@%@",BASEURL,appendStr];
    NSMutableDictionary * seviceDic = [NSMutableDictionary dictionaryWithDictionary:asevice];
    //过滤必填项
    [seviceDic setValue:[NSNumber numberWithBool:TRUE] forKey:@"ignoreCheck"];
    
    [seviceDic setValue:[NSDictionary dictionary] forKey:@"serviceAccidentSettlement"];
    [seviceDic setValue:[NSDictionary dictionary] forKey:@"qualityInspector"];

    NSMutableDictionary * updateParm = [NSMutableDictionary  dictionary];
    [updateParm setValue:[NSArray arrayWithObject:seviceDic] forKey:@"data"];
    
    [self resetManager];
    
    [_manager PUT:urlString parameters:updateParm headers:NULL success:success failure:failure];
}


//获取车辆品牌(奥迪、宝马等)
-(void)queryVehicleBrandsuccess:(nullable void (^)(NSURLSessionDataTask *task, id _Nullable responseObject))success
                        failure:(nullable void (^)(NSURLSessionDataTask * _Nullable task, NSError *error))failure
{
    NSString * appendStr = @"/enocloud/common/vehicle/brand";
    NSString * urlString = [NSString stringWithFormat:@"%@%@",BASEURL,appendStr];
    NSMutableDictionary * parm = [NSMutableDictionary dictionary];
    NSInteger dep = 2;
    [parm setValue:[NSString stringWithFormat:@"%d",dep] forKey:@"depth"];
    
    [self resetManager];
    
    [_manager GET:urlString parameters:parm headers:NULL progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:success failure:failure];
    
}
//获取车型类型（小型轿车、大型客车等）
-(void)queryVehicleTypesuccess:(nullable void (^)(NSURLSessionDataTask *task, id _Nullable responseObject))success
                       failure:(nullable void (^)(NSURLSessionDataTask * _Nullable task, NSError *error))failure
{
    NSString * appendStr = @"/enocloud/common/vehicle/type";
    NSString * urlString = [NSString stringWithFormat:@"%@%@",BASEURL,appendStr];
    
    NSMutableDictionary * parm = [NSMutableDictionary dictionary];
    [parm setValue:[NSNumber numberWithBool:FALSE] forKey:@"pagingEnabled"];
    
    [self resetManager];
   
    [_manager GET:urlString parameters:parm headers:NULL progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:success failure:failure];
}


//queryCustomerType
-(void)queryCustomerTypeSuccess:(nullable void (^)(NSURLSessionDataTask *task, id _Nullable responseObject))success
                        Failure:(nullable void (^)(NSURLSessionDataTask * _Nullable task, NSError *error))failure
{
    
}

//待接车：PR   维修中：IM 待检测：MC 带结算 ：AA
-(void)queryOrder
{
    NSString * appendStr = @"/enocloud/service/query";
    NSString * urlString = [NSString stringWithFormat:@"%@%@",BASEURL,appendStr];
    
    NSMutableDictionary * parm = [NSMutableDictionary dictionary];
    [parm setValue:@"MC"forKey:@"statusCode"];
    
    [self resetManager];
    
    [_manager GET:urlString parameters:NULL headers:parm progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary * resp = responseObject;
//        NSArray * array = [resp objectForKey:@"data"];
        
        NSLog(@"==== queryVehicleType success");
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
    }];

}

-(void)queryRepairServiceInfosuccess:(nullable void (^)(NSURLSessionDataTask *task, id _Nullable responseObject))success
                    failure:(nullable void (^)(NSURLSessionDataTask * _Nullable task, NSError *error))failure
{
    NSString * appendStr = @"/enocloud/service/query?extraStatus=&preparedStartDate=&preparedEndDate=&statusCode=PD";
    NSString * urlString = [NSString stringWithFormat:@"%@%@",BASEURL,appendStr];
    
    [self resetManager];
    
    [_manager GET:urlString parameters:NULL headers:NULL progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary * resp = responseObject;
//        NSArray * array = [resp objectForKey:@"data"];
        
       
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
    }];
    
    
}
//https://enocloudd.enoch-car.com/enocloud/common/maintenance?quickSearch= 搜索项目名称
-(void)queryMaintenance:(NSString*)searchStr success:(nullable void (^)(NSURLSessionDataTask *task, id _Nullable responseObject))success
           failure:(nullable void (^)(NSURLSessionDataTask * _Nullable task, NSError *error))failure
{
    NSString * appendStr = @"/enocloud/common/maintenance";
    NSString * urlString = [NSString stringWithFormat:@"%@%@",BASEURL,appendStr];
    
    urlString = [urlString stringByAppendingString:[NSString stringWithFormat:@"?quickSearch=%@",searchStr]];
    urlString = [urlString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    
    [self resetManager];
    
    [_manager GET:urlString parameters:NULL headers:NULL progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:success failure:failure];
    
}

-(void)queryAdvisorSuccess:(nullable void (^)(NSURLSessionDataTask *task, id _Nullable responseObject))success
           Failure:(nullable void (^)(NSURLSessionDataTask * _Nullable task, NSError *error))failure
{
    NSString * appendStr = [NSString stringWithFormat:@"/enocloud/common/advisorteam/advisor?branchId=%d",self.branchID];
    NSString * urlString = [NSString stringWithFormat:@"%@%@",BASEURL,appendStr];

    urlString = [urlString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    
    [self resetManager];
    
    [_manager GET:urlString parameters:NULL headers:NULL progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:success failure:failure];
    
}



-(void)queryWorkingTeamsuccess:(nullable void (^)(NSURLSessionDataTask *task, id _Nullable responseObject))success
                    failure:(nullable void (^)(NSURLSessionDataTask * _Nullable task, NSError *error))failure
{
    
    NSString * appendStr = @"/enocloud/common/workingteam";
    NSString * urlString = [NSString stringWithFormat:@"%@%@",BASEURL,appendStr];
    
    [self resetManager];
    
    [_manager GET:urlString parameters:NULL headers:NULL progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:success failure:failure];
    
    
}

-(void)queryGoodssuccess:(nullable void (^)(NSURLSessionDataTask *task, id _Nullable responseObject))success
                    failure:(nullable void (^)(NSURLSessionDataTask * _Nullable task, NSError *error))failure
{
    //https://enocloudd.enoch-car.com/enocloud/common/goods?quickSearch=&branchId=1&statusCode=A
//    NSInteger branchId = [[[NSUserDefaults standardUserDefaults] objectForKey:@"curBranchId"] integerValue];
//    NSInteger branchId = [[GlobalInfoManager infoManager] getBranchID];
    NSString * appendStr = [NSString stringWithFormat:@"/enocloud/common/goods?quickSearch=&branchId=%dstatusCode=A",self.branchID];
    NSString * urlString = [NSString stringWithFormat:@"%@%@",BASEURL,appendStr];
    urlString = [urlString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    
    [self resetManager];
    
    [_manager GET:urlString parameters:NULL headers:NULL progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:success failure:failure];
    
}
-(void)queryGoods:(NSString *)searchtext success:(nullable void (^)(NSURLSessionDataTask *task, id _Nullable responseObject))success
                    failure:(nullable void (^)(NSURLSessionDataTask * _Nullable task, NSError *error))failure
{
    //https://enocloud.enoch-car.com/enocloud/common/goods?quickSearch=&branchId=1&statusCode=A
    NSInteger branchId = [[GlobalInfoManager infoManager] getBranchID];
    NSString * appendStr = [NSString stringWithFormat:@"/enocloud/common/goods?quickSearch=%@&branchId=%d&statusCode=A",searchtext,self.branchID];
    NSString * urlString = [NSString stringWithFormat:@"%@%@",BASEURL,appendStr];
    urlString = [urlString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    
    [self resetManager];
    
    [_manager GET:urlString parameters:NULL headers:NULL progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:success failure:failure];
    
}

//查询维修结算中工单（mobileStatus=M&A）
-(void)queryRepaireSevice:(NSString*)parmstr success:(nullable void (^)(NSURLSessionDataTask *task, id _Nullable responseObject))success
                    failure:(nullable void (^)(NSURLSessionDataTask * _Nullable task, NSError *error))failure
{
    NSString * appendStr = [NSString stringWithFormat:@"/enocloud/service/query?advisorIds=%@&%@",[NSNumber numberWithInteger:self.userID],parmstr];
    NSString * urlString = [NSString stringWithFormat:@"%@%@",BASEURL,appendStr];
    urlString = [urlString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    
    [self resetManager];
    
    [_manager GET:urlString parameters:NULL headers:NULL progress:^(NSProgress * _Nonnull downloadProgress) {
    
    } success:success failure:failure];
}

-(void)querySeviceCategorysuccess:(nullable void (^)(NSURLSessionDataTask *task, id _Nullable responseObject))success
                          failure:(nullable void (^)(NSURLSessionDataTask * _Nullable task, NSError *error))failure
{
    NSString * appendStr = @"/enocloud/common/service/category?status=A";
    NSString * urlString = [NSString stringWithFormat:@"%@%@",BASEURL,appendStr];
    urlString = [urlString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    
    [self resetManager];
    
    [_manager GET:urlString parameters:NULL headers:NULL progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:success failure:failure];
}


//https://enocloudd.enoch-car.com/enocloud/common/maintenance?quickSearch=
-(void)queryMaintanceWith:(NSString *)string success:(nullable void (^)(NSURLSessionDataTask *task, id _Nullable responseObject))success
                  failure:(nullable void (^)(NSURLSessionDataTask * _Nullable task, NSError *error))failure
{
    NSString * appendStr = [NSString stringWithFormat:@"/enocloud/common/maintenance?quickSearch=%@",string];
    NSString * urlString = [NSString stringWithFormat:@"%@%@",BASEURL,appendStr];
    urlString = [urlString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    
    [self resetManager];
    
    [_manager GET:urlString parameters:NULL headers:NULL progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:success failure:failure];
    
}

//查询维修项目类别
//https://enocloudd.enoch-car.com/enocloud/common/maintenance/category?pagingEnabled=false

-(void)queryMaintanceCategorysuccess:(nullable void (^)(NSURLSessionDataTask *task, id _Nullable responseObject))success
                          failure:(nullable void (^)(NSURLSessionDataTask * _Nullable task, NSError *error))failure
{
    NSString * appendStr = @"/enocloud/common/maintenance/category?pagingEnabled=false";
    NSString * urlString = [NSString stringWithFormat:@"%@%@",BASEURL,appendStr];
    urlString = [urlString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    
    [self resetManager];
    
    [_manager GET:urlString parameters:NULL headers:NULL progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:success failure:failure];
}

-(void)queryMaintanceCategoryWith:(NSString *)searchStr success:(nullable void (^)(NSURLSessionDataTask *task, id _Nullable responseObject))success
                          failure:(nullable void (^)(NSURLSessionDataTask * _Nullable task, NSError *error))failure
{
    NSString * appendStr = @"/enocloud/common/maintenance/category?pagingEnabled=false";
    NSString * urlString = [NSString stringWithFormat:@"%@%@",BASEURL,appendStr];
    urlString = [urlString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    
    [self resetManager];
    
    [_manager GET:urlString parameters:NULL headers:NULL progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:success failure:failure];
}

-(void)createMaintanceCategory:(NSDictionary * )ainfo success:(nullable void (^)(NSURLSessionDataTask *task, id _Nullable responseObject))success
                             failure:(nullable void (^)(NSURLSessionDataTask * _Nullable task, NSError *error))failure
{
    NSString * appendStr = @"/enocloud/common/maintenance";
    NSString * urlString = [NSString stringWithFormat:@"%@%@",BASEURL,appendStr];
    urlString = [urlString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];

    NSDictionary * parm = [NSDictionary dictionaryWithObject:[NSArray arrayWithObject:ainfo] forKey:@"data"];
    
    [self resetManager];
    
    [_manager POST:urlString parameters:parm headers:NULL progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:success failure:failure];
    
}


-(void)queryGoodsCategorysuccess:(nullable void (^)(NSURLSessionDataTask *task, id _Nullable responseObject))success
                          failure:(nullable void (^)(NSURLSessionDataTask * _Nullable task, NSError *error))failure
{
    NSString * appendStr = @"/enocloud/common/goods/category?name=";
    NSString * urlString = [NSString stringWithFormat:@"%@%@",BASEURL,appendStr];
    urlString = [urlString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    
    [self resetManager];
    
    [_manager GET:urlString parameters:NULL headers:NULL progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:success failure:failure];
    
}
//https://enocloudd.enoch-car.com/enocloud/common/goods
-(void)createGood:(NSDictionary *)info success:(nullable void (^)(NSURLSessionDataTask *task, id _Nullable responseObject))success
    failure:(nullable void (^)(NSURLSessionDataTask * _Nullable task, NSError *error))failure
{
    
    NSString * appendStr = @"/enocloud/common/goods";
    NSString * urlString = [NSString stringWithFormat:@"%@%@",BASEURL,appendStr];
//    NSDictionary * info = [NSDictionary dictionaryWithObjects:@[@"",@[@2]] forKeys:@[@"name", @"categoryIds"]];
    NSDictionary * parm = [NSDictionary dictionaryWithObject:[NSArray arrayWithObject:info] forKey:@"data"];
    
    [self resetManager];
    
    [_manager POST:urlString parameters:parm headers:NULL progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:success failure:failure];
    
    
}


//获取客户类型（顾客、供应商、物流公司、保险公司等）ios端一律顾客
-(void)lookupRole
{
    NSString * appendStr = @"/enocloud/common/lookup/CUSTTYPE";
    NSString * urlString = [NSString stringWithFormat:@"%@%@",BASEURL,appendStr];
//    lookupType CUSTTYPE
    NSMutableDictionary * parm = [NSMutableDictionary dictionary];
    [parm setValue:@"CUSTTYPE" forKey:@"lookupType"];
    
    [self resetManager];
    
    [_manager GET:urlString parameters:NULL headers:NULL progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary * resp = responseObject;
        NSLog(@"==== lookupRole success");
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"==== lookupRole fail");
    }];
}

-(void)lookup:(NSString *)type success:(nullable void (^)(NSURLSessionDataTask *task, id _Nullable responseObject))success
      failure:(nullable void (^)(NSURLSessionDataTask * _Nullable task, NSError *error))failure
{
    NSString * appendStr = [NSString stringWithFormat:@"/enocloud/common/lookup/%@",type];
    NSString * urlString = [NSString stringWithFormat:@"%@%@",BASEURL,appendStr];
    urlString = [urlString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];

    [self resetManager];
    
    [_manager GET:urlString parameters:NULL headers:NULL progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:success failure:failure];
    
    
}

///SERVDESC  故障描述  /SERVSOLU。故障原因

-(void)hint:(NSString *)type success:(nullable void (^)(NSURLSessionDataTask *task, id _Nullable responseObject))success
      failure:(nullable void (^)(NSURLSessionDataTask * _Nullable task, NSError *error))failure
{
    NSString * appendStr = [NSString stringWithFormat:@"/enocloud/common/hint/%@",type];
    NSString * urlString = [NSString stringWithFormat:@"%@%@",BASEURL,appendStr];
    urlString = [urlString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    
    [self resetManager];
    
    [_manager GET:urlString parameters:NULL headers:NULL progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:success failure:failure];
       
}


-(void)feedbackWithContent:(NSString*)contentStr success:(nullable void (^)(NSURLSessionDataTask *task, id _Nullable responseObject))success
                   failure:(nullable void (^)(NSURLSessionDataTask * _Nullable task, NSError *error))failure
{
    
    
    NSString * appendStr = @"/enocloud/common/feedback";
    NSString * urlString = [NSString stringWithFormat:@"%@%@",BASEURL,appendStr];
    urlString = [urlString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
 
    NSMutableDictionary * data = [NSMutableDictionary dictionary];
    [data setValue:@"" forKey:@"title"];
    [data setValue:contentStr forKey:@"content"];
    [data setValue:[CommonTool getNowDateStr] forKey:@"feedbackDate"];
    [data setValue:[NSDictionary dictionaryWithObject:[NSNumber numberWithInteger:self.userID] forKey:@"id"] forKey:@"feedbackBy"];
    NSArray * array = [NSArray arrayWithObject:data];
    NSMutableDictionary * parm = [NSMutableDictionary dictionary];
    [parm setValue:array forKey:@"data"];

    [self resetManager];
    
    [_manager POST:urlString parameters:parm headers:NULL progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:success failure:failure];
    
}

//获取客户绑定微信的二维码URL。 https://enocloudd.enoch-car.com/enocloud/common/customer/805/wechat/bind/url
-(void)queryWechatBindUrl:(NSInteger)customerID success:(nullable void (^)(NSURLSessionDataTask *task, id _Nullable responseObject))success
          failure:(nullable void (^)(NSURLSessionDataTask * _Nullable task, NSError *error))failure
{
    NSString * appendStr = [NSString stringWithFormat:@"/enocloud/common/customer/%d/wechat/bind/url",customerID];
    NSString * urlString = [NSString stringWithFormat:@"%@%@",BASEURL,appendStr];
    urlString = [urlString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    
    [self resetManager];
    
    [_manager GET:urlString parameters:NULL headers:NULL progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:success failure:failure];
    
}

//查询报表
-(void)queryStatement:(NSString*)parmStr Success:(nullable void (^)(NSURLSessionDataTask *task, id _Nullable responseObject))success
                      Failure:(nullable void (^)(NSURLSessionDataTask * _Nullable task, NSError *error))failure
{
//    NSInteger branchId = [[GlobalInfoManager infoManager] getBranchID];
//    NSString * appendStr = [NSString stringWithFormat:@"/enocloud/statement/advisor?userId=%d&extraStatus=RP",self.userID];
    NSString * appendStr = [NSString stringWithFormat:@"/enocloud/statement/advisor?userId=%d&%@",self.userID,parmStr];
    NSString * urlString = [NSString stringWithFormat:@"%@%@",BASEURL,appendStr];
    urlString = [urlString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    
    [self resetManager];
    
    [_manager GET:urlString parameters:NULL headers:NULL progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:success failure:failure];
    
}


//上传图片和视频获取url
-(void)uploadData:(NSData *)data signature:(NSDictionary*)parm success:(nullable void (^)(NSURLSessionDataTask *task, id _Nullable responseObject))success
                      failure:(nullable void (^)(NSURLSessionDataTask * _Nullable task, NSError *error))failure
{
    NSString * urlString = [NSString stringWithFormat:@"%@",[parm objectForKey:@"host"]];
    urlString = [urlString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    
    
    CommonJSONResponseSerializer * orgResponse = (CommonJSONResponseSerializer * )_manager.responseSerializer;
    AFJSONRequestSerializer * orgRequest = (AFJSONRequestSerializer *)_manager.requestSerializer;
    
    _manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    _manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@",BWFileBoundary];
    [_manager.requestSerializer setValue:contentType forHTTPHeaderField:@"Content-Type"];
    _manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/plain", @"multipart/form-data", @"application/xml", @"application/json", @"text/html", @"image/jpeg", @"image/png", @"application/octet-stream", @"text/json", nil];
    [_manager.requestSerializer setValue:[CommonTool terminalString] forHTTPHeaderField:@"ENOCH_TERMINAL"];
//    NSDictionary * heads = _manager.requestSerializer.HTTPRequestHeaders;
    
    [_manager POST:urlString parameters:parm headers:NULL constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        NSString * filepath = [parm objectForKey:@"key"];
        NSString * filename = [filepath lastPathComponent];
        NSString *fileExtension = [filepath pathExtension];
        NSString * mimeType = @"image/jpeg";
        if([fileExtension isEqualToString:@"jpg"]||[fileExtension isEqualToString:@"gif"]||[fileExtension isEqualToString:@"png"]||[fileExtension isEqualToString:@"jpeg"]||[fileExtension isEqualToString:@"bmp"])
        {
            mimeType = [NSString stringWithFormat:@"image/%@",fileExtension];
            
        }else if([fileExtension isEqualToString:@"mp4"]||[fileExtension isEqualToString:@"mov"]){
            
            mimeType = [NSString stringWithFormat:@"video/%@",fileExtension];
        }
        
        [formData appendPartWithFileData:data name:@"file" fileName:filename mimeType:mimeType];
        
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:success failure:failure];
}

//上传视频
-(void)uploadVideo:(NSData *)data signature:(NSDictionary*)parm success:(nullable void (^)(NSURLSessionDataTask *task, id _Nullable responseObject))success
                      failure:(nullable void (^)(NSURLSessionDataTask * _Nullable task, NSError *error))failure
{
    NSString * urlString = [NSString stringWithFormat:@"%@",[parm objectForKey:@"host"]];
    urlString = [urlString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    
    
    CommonJSONResponseSerializer * orgResponse = (CommonJSONResponseSerializer * )_manager.responseSerializer;
    AFJSONRequestSerializer * orgRequest = (AFJSONRequestSerializer *)_manager.requestSerializer;
    
    _manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    _manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@",BWFileBoundary];
    [_manager.requestSerializer setValue:contentType forHTTPHeaderField:@"Content-Type"];
    _manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/plain", @"multipart/form-data", @"application/xml", @"application/json", @"text/html", @"image/jpeg", @"image/png", @"application/octet-stream", @"text/json", nil];
    [_manager.requestSerializer setValue:[CommonTool terminalString] forHTTPHeaderField:@"ENOCH_TERMINAL"];
//    NSDictionary * heads = _manager.requestSerializer.HTTPRequestHeaders;
    [_manager POST:urlString parameters:parm headers:NULL constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        NSString * filepath = [parm objectForKey:@"key"];
        NSString * filename = [filepath lastPathComponent];
        NSString *fileExtension = [filepath pathExtension];
        NSString * mimeType = @"video/mov";
        if([fileExtension isEqualToString:@"mp4"]||[fileExtension isEqualToString:@"mov"]){
            
            mimeType = [NSString stringWithFormat:@"video/%@",fileExtension];
        }
        
        [formData appendPartWithFileData:data name:@"file" fileName:filename mimeType:mimeType];
        
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:success failure:failure];
}

- (void)cancelRequest
{
    if ([_manager.tasks count] > 0) {
        [_manager.tasks makeObjectsPerformSelector:@selector(cancel)];
    }
}


-(void)cancelAllTask
{
    [_manager.operationQueue cancelAllOperations];    
}

//tool
-(NSString*)DataTOjsonString:(id)object
{
    NSString *jsonString = nil;
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:object
    options:NSJSONWritingPrettyPrinted // Pass 0 if you don't care about the readability of the generated string
    error:&error];
    if (! jsonData)
    {
        NSLog(@"Got an error: %@", error);
    } else {
        jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    return jsonString;
}

//获取宣传视频
-(void)getVideoResourceSuccess:(nullable void (^)(NSURLSessionDataTask *task, id _Nullable responseObject))success
                       Failure:(nullable void (^)(NSURLSessionDataTask * _Nullable task, NSError *error))failure
{
    NSString * urlString = @"https://api.enoch-car.com/api/open/official/resource";
//    urlString = [urlString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    
//    [self resetManager];
    
    [_manager GET:urlString parameters:NULL headers:NULL progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:success failure:failure];
}

@end
