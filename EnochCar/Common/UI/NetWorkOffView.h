//
//  NetWorkOffView.h
//  EnochCar
//
//  Created by 王海燕 on 2021/8/4.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^RefreshBlock)(void);

@interface NetWorkOffView : UIView
-(instancetype)initWithFrame:(CGRect)frame refreshBlock:(nullable RefreshBlock)block;
@end

NS_ASSUME_NONNULL_END
