//
//  NetWorkAPIManager.h
//  EnochCar
//
//  Created by 王海燕 on 2021/5/10.
//

#import <Foundation/Foundation.h>
#import "CommonDefine.h"

#define BASEURL  @"https://enocloud.enoch-car.com"
//#define BASEURL  @"https://enocloudd.enoch-car.com"
#define APPLICATIONURL @"https://h5.enoch-car.com/api/open/application"
NS_ASSUME_NONNULL_BEGIN


@interface NetWorkAPIManager : NSObject

@property(nonatomic,readwrite,assign) NSInteger userID;
@property(nonatomic,readwrite,assign) NSInteger branchID;
@property(nonatomic,readwrite,strong) NSString * branchName;
@property(nonatomic,readwrite,strong) NSString * userName;
@property(nonatomic,readwrite,strong) NSString * headUrl;

//系统设置
@property(nonatomic,readwrite,assign) BOOL needEngineer;//是否必须派工技师
//@property(nonatomic,readwrite,strong) NSNumber * hour;//设置的默认工时
@property(nonatomic,readwrite,strong) NSString * price;//设置的默认单价
//@property(nonatomic,readwrite,strong) NSDictionary * chargeMethod;//设置的默认项目计价方式
@property(nonatomic,readwrite,strong) NSString * chargeMethodCode;//设置的默认项目计价方式
+(instancetype)defaultManager;

-(void)application:(NSDictionary *)info Success:(nullable void (^)(NSURLSessionDataTask *task, id _Nullable responseObject))success
           Failure:(nullable void (^)(NSURLSessionDataTask * _Nullable task, NSError *error))failure;

-(void)loginWithUsername:(NSString *)name Password:(NSString *)password success:(nullable void (^)(NSURLSessionDataTask *task, id _Nullable responseObject))success
                 failure:(nullable void (^)(NSURLSessionDataTask * _Nullable task, NSError *error))failure;

-(void)logoutsuccess:(nullable void (^)(NSURLSessionDataTask *task, id _Nullable responseObject))success
             failure:(nullable void (^)(NSURLSessionDataTask * _Nullable task, NSError *error))failure;

//获取系统配置
-(void)getBranchAttributeSuccess:(nullable void (^)(NSURLSessionDataTask *task, id _Nullable responseObject))success
                         Failure:(nullable void (^)(NSURLSessionDataTask * _Nullable task, NSError *error))failure;
//获取oss签名
-(void)getOSSSignatureSuccess:(nullable void (^)(NSURLSessionDataTask *task, id _Nullable responseObject))success
                      Failure:(nullable void (^)(NSURLSessionDataTask * _Nullable task, NSError *error))failure;

-(void)modifyPassword:(NSString*)oldPwd newPwd:(NSString *)newPassword success:(nullable void (^)(NSURLSessionDataTask *task, id _Nullable responseObject))success
              failure:(nullable void (^)(NSURLSessionDataTask * _Nullable task, NSError *error))failure;

-(NSURLSessionDataTask *)imageRecognizeWithData:(NSData *)data Type:(RecognizeType)type success:(nullable void (^)(NSURLSessionDataTask *task, id _Nullable responseObject))success
                      failure:(nullable void (^)(NSURLSessionDataTask * _Nullable task, NSError *error))failure;

-(void)queryCustomWithName:(NSString *)name Cellphone:(NSString *)cellphone Success:(nullable void (^)(NSURLSessionDataTask *task, id _Nullable responseObject))success
                   Failure:(nullable void (^)(NSURLSessionDataTask * _Nullable task, NSError *error))failure;

-(void)createVehicle:(NSDictionary *)vehicleInfo success:(nullable void (^)(NSURLSessionDataTask *task, id _Nullable responseObject))success
             failure:(nullable void (^)(NSURLSessionDataTask * _Nullable task, NSError *error))failure;
-(void)createCustomer:(NSDictionary *)customInfo success:(nullable void (^)(NSURLSessionDataTask *task, id _Nullable responseObject))success
            failure:(nullable void (^)(NSURLSessionDataTask * _Nullable task, NSError *error))failure;
-(void)createService:(NSDictionary *)info success:(nullable void (^)(NSURLSessionDataTask *task, id _Nullable responseObject))success
             failure:(nullable void (^)(NSURLSessionDataTask * _Nullable task, NSError *error))failure;

-(void)updateCustomer:(NSDictionary *)customInfo success:(nullable void (^)(NSURLSessionDataTask *task, id _Nullable responseObject))success
            failure:(nullable void (^)(NSURLSessionDataTask * _Nullable task, NSError *error))failure;
-(void)updateVehicle:(NSDictionary *)vehicleInfo success:(nullable void (^)(NSURLSessionDataTask *task, id _Nullable responseObject))success
             failure:(nullable void (^)(NSURLSessionDataTask * _Nullable task, NSError *error))failure;

//查询当前用户信息
-(void)queryUserInfosuccess:(nullable void (^)(NSURLSessionDataTask *task, id _Nullable responseObject))success
                    failure:(nullable void (^)(NSURLSessionDataTask * _Nullable task, NSError *error))failure;

//快速查询车辆信息
-(void)queryVehicleInfo:(NSString *)name plateNo:(NSString *)plateNo vin:(NSString *)vin success:(nullable void (^)(NSURLSessionDataTask *task, id _Nullable responseObject))success
                failure:(nullable void (^)(NSURLSessionDataTask * _Nullable task, NSError *error))failure;

//获取车辆详情
-(void)getVehicleInfoWithPlateNo:(NSString *)plateNo success:(nullable void (^)(NSURLSessionDataTask *task, id _Nullable responseObject))success
                         failure:(nullable void (^)(NSURLSessionDataTask * _Nullable task, NSError *error))failure;

//查询维修中订单信息
-(void)queryRepairServiceInfosuccess:(nullable void (^)(NSURLSessionDataTask *task, id _Nullable responseObject))success
                    failure:(nullable void (^)(NSURLSessionDataTask * _Nullable task, NSError *error))failure;

//查询工单详情信息
-(void)queryService:(NSInteger)seviceID success:(nullable void (^)(NSURLSessionDataTask *task, id _Nullable responseObject))success
            failure:(nullable void (^)(NSURLSessionDataTask * _Nullable task, NSError *error))failure;
//查询维修类别
-(void)querySeviceCategorysuccess:(nullable void (^)(NSURLSessionDataTask *task, id _Nullable responseObject))success
                          failure:(nullable void (^)(NSURLSessionDataTask * _Nullable task, NSError *error))failure;
//查询班组
-(void)queryWorkingTeamsuccess:(nullable void (^)(NSURLSessionDataTask *task, id _Nullable responseObject))success
                    failure:(nullable void (^)(NSURLSessionDataTask * _Nullable task, NSError *error))failure;

//查询维修项目
-(void)queryMaintanceWith:(NSString *)string success:(nullable void (^)(NSURLSessionDataTask *task, id _Nullable responseObject))success
                  failure:(nullable void (^)(NSURLSessionDataTask * _Nullable task, NSError *error))failure;
//查询维修项目类别
-(void)queryMaintanceCategorysuccess:(nullable void (^)(NSURLSessionDataTask *task, id _Nullable responseObject))success
                             failure:(nullable void (^)(NSURLSessionDataTask * _Nullable task, NSError *error))failure;

//新增维修项目类别
-(void)createMaintanceCategory:(NSDictionary * )ainfo success:(nullable void (^)(NSURLSessionDataTask *task, id _Nullable responseObject))success
                             failure:(nullable void (^)(NSURLSessionDataTask * _Nullable task, NSError *error))failure;

-(void)createGood:(NSDictionary *)info success:(nullable void (^)(NSURLSessionDataTask *task, id _Nullable responseObject))success
        failure:(nullable void (^)(NSURLSessionDataTask * _Nullable task, NSError *error))failure;
//查询配件
-(void)queryGoodssuccess:(nullable void (^)(NSURLSessionDataTask *task, id _Nullable responseObject))success
                    failure:(nullable void (^)(NSURLSessionDataTask * _Nullable task, NSError *error))failure;


//查询维修中工单
-(void)queryRepaireSevice:(NSString*)parmstr success:(nullable void (^)(NSURLSessionDataTask *task, id _Nullable responseObject))success
                    failure:(nullable void (^)(NSURLSessionDataTask * _Nullable task, NSError *error))failure;


//更新工单
-(void)updateService:(NSDictionary *)asevice success:(nullable void (^)(NSURLSessionDataTask *task, id _Nullable responseObject))success
             failure:(nullable void (^)(NSURLSessionDataTask * _Nullable task, NSError *error))failure;

//获取车辆品牌(奥迪、宝马等)
-(void)queryVehicleBrandsuccess:(nullable void (^)(NSURLSessionDataTask *task, id _Nullable responseObject))success
                        failure:(nullable void (^)(NSURLSessionDataTask * _Nullable task, NSError *error))failure;

//获取车型类型（小型轿车、大型客车等）
-(void)queryVehicleTypesuccess:(nullable void (^)(NSURLSessionDataTask *task, id _Nullable responseObject))success
                       failure:(nullable void (^)(NSURLSessionDataTask * _Nullable task, NSError *error))failure;


-(void)queryMaintenance:(NSString*)searchStr success:(nullable void (^)(NSURLSessionDataTask *task, id _Nullable responseObject))success
           failure:(nullable void (^)(NSURLSessionDataTask * _Nullable task, NSError *error))failure;

-(void)queryAdvisorSuccess:(nullable void (^)(NSURLSessionDataTask *task, id _Nullable responseObject))success
           Failure:(nullable void (^)(NSURLSessionDataTask * _Nullable task, NSError *error))failure;

//获取客户类型
//-(void)lookupRole;
//https://enocloudd.enoch-car.com/enocloud/common/maintenance/category?pagingEnabled=false
-(void)queryMaintanceCategorysuccess:(nullable void (^)(NSURLSessionDataTask *task, id _Nullable responseObject))success
                          failure:(nullable void (^)(NSURLSessionDataTask * _Nullable task, NSError *error))failure;
-(void)queryMaintanceCategoryWith:(NSString *)searchStr success:(nullable void (^)(NSURLSessionDataTask *task, id _Nullable responseObject))success
                          failure:(nullable void (^)(NSURLSessionDataTask * _Nullable task, NSError *error))failure;

//Goods
-(void)queryGoods:(NSString *)searchtext success:(nullable void (^)(NSURLSessionDataTask *task, id _Nullable responseObject))success
          failure:(nullable void (^)(NSURLSessionDataTask * _Nullable task, NSError *error))failure;
-(void)AddGoods:(NSDictionary *)info uccess:(nullable void (^)(NSURLSessionDataTask *task, id _Nullable responseObject))success
        failure:(nullable void (^)(NSURLSessionDataTask * _Nullable task, NSError *error))failure;
-(void)queryGoodsCategorysuccess:(nullable void (^)(NSURLSessionDataTask *task, id _Nullable responseObject))success
                          failure:(nullable void (^)(NSURLSessionDataTask * _Nullable task, NSError *error))failure;


-(void)lookup:(NSString *)type success:(nullable void (^)(NSURLSessionDataTask *task, id _Nullable responseObject))success
      failure:(nullable void (^)(NSURLSessionDataTask * _Nullable task, NSError *error))failure;

-(void)hint:(NSString *)type success:(nullable void (^)(NSURLSessionDataTask *task, id _Nullable responseObject))success
    failure:(nullable void (^)(NSURLSessionDataTask * _Nullable task, NSError *error))failure;

-(void)feedbackWithContent:(NSString*)contentStr success:(nullable void (^)(NSURLSessionDataTask *task, id _Nullable responseObject))success
                   failure:(nullable void (^)(NSURLSessionDataTask * _Nullable task, NSError *error))failure;



//获取客户绑定微信的二维码URL。 https://enocloudd.enoch-car.com/enocloud/common/customer/805/wechat/bind/url
-(void)queryWechatBindUrl:(NSInteger)customerID success:(nullable void (^)(NSURLSessionDataTask *task, id _Nullable responseObject))success
          failure:(nullable void (^)(NSURLSessionDataTask * _Nullable task, NSError *error))failure;


//上传图片
-(void)uploadData:(NSData *)data signature:(NSDictionary*)signature success:(nullable void (^)(NSURLSessionDataTask *task, id _Nullable responseObject))success
                      failure:(nullable void (^)(NSURLSessionDataTask * _Nullable task, NSError *error))failure;

//上传视频
-(void)uploadVideo:(NSData *)data signature:(NSDictionary*)parm success:(nullable void (^)(NSURLSessionDataTask *task, id _Nullable responseObject))success
           failure:(nullable void (^)(NSURLSessionDataTask * _Nullable task, NSError *error))failure;

//报表
-(void)queryStatement:(NSString*)parmStr Success:(nullable void (^)(NSURLSessionDataTask *task, id _Nullable responseObject))success
              Failure:(nullable void (^)(NSURLSessionDataTask * _Nullable task, NSError *error))failure;
//-(void)queryStatementSuccess:(nullable void (^)(NSURLSessionDataTask *task, id _Nullable responseObject))success
//                      Failure:(nullable void (^)(NSURLSessionDataTask * _Nullable task, NSError *error))failure;


//获取宣传视频
-(void)getVideoResourceSuccess:(nullable void (^)(NSURLSessionDataTask *task, id _Nullable responseObject))success
                       Failure:(nullable void (^)(NSURLSessionDataTask * _Nullable task, NSError *error))failure;

//取消当前请求
- (void)cancelRequest;
//取消所有任务
-(void)cancelAllTask;
@end

NS_ASSUME_NONNULL_END
