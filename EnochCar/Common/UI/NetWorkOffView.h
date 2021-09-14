//
//  NetWorkOffView.h
//  EnochCar
//
//  Created by 王海燕 on 2021/8/4.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef enum{
    Error_NetWorkOff, //网络异常
    Error_server   //服务器异常
} ErrorType;

typedef void(^RefreshBlock)(void);

@interface NetWorkOffView : UIView
//-(instancetype)initWithFrame:(CGRect)frame refreshBlock:(nullable RefreshBlock)block;
-(instancetype)initWithFrame:(CGRect)frame errorMessage:(NSString*)message refreshBlock:(nullable RefreshBlock)block;
-(void)setMessage:(NSString*)message;
@end

NS_ASSUME_NONNULL_END
