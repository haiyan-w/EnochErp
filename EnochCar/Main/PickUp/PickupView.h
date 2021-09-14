//
//  PickupView.h
//  EnochCar
//
//  Created by 王海燕 on 2021/5/19.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN


typedef enum{
    PickupInitialMode,//初始化模式

    PickupCreateMode,//新建客户车辆模式（新建车辆和未绑定车主车辆都需要新建）
        
    PickupEditMode,//编辑模式(用于老客户信息更新)

    PickupSeviceMode,//开单模式

}PickupViewMode;


@class PickupView;

@protocol PickupViewDelegate <UIScrollViewDelegate>

-(void)CustomerChanged:(BOOL)isOldCustomer;
-(void)PickUpViewModeChanged:(PickupViewMode)viewMode;
@end

@interface PickupView : UIScrollView
@property(nonatomic,readwrite,strong) UINavigationController * navCtrl;
@property(nonatomic,readwrite,weak) id <PickupViewDelegate>delegate;
@property(nonatomic,readwrite,strong)UIView * firstResponderView;
@property(nonatomic,readwrite,assign)  CGPoint originOffset;
-(void)configData:(NSDictionary *)data;
-(void)setViewMode:(PickupViewMode)viewMode;
-(void)queryCustomSuccess:(nullable void (^)(NSURLSessionDataTask *task, id _Nullable responseObject))success
                  Failure:(nullable void (^)(NSURLSessionDataTask * _Nullable task, NSError *error))failure;
-(void)create;
-(void)createCustom;
-(void)createVehicle;
-(void)createService;
-(void)createServicesuccess:(nullable void (^)(NSURLSessionDataTask *task, id _Nullable responseObject))success
                    failure:(nullable void (^)(NSURLSessionDataTask * _Nullable task, NSError *error))failure;

//保存上一次未完成的信息
-(void)saveLastSeviceInfo;

-(void)addNotification;
-(void)removeNotification;
@end

NS_ASSUME_NONNULL_END
