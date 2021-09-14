//
//  PlateNoKeyboardView.h
//  EnochCar
//
//  Created by 王海燕 on 2021/5/26.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN


typedef enum{
    KeyboardTypeProvince = 0,
    KeyboardTypeABC  = 1
} KeyboardType;

@protocol PlateNoKeyboardViewDelegate <NSObject>

//点击键盘上的按钮

- (void)clickWithString:(NSString *)string;

//点击删除按钮

- (void)deleteBtnClick;

@end

@interface PlateNoKeyboardView : UIView

@property (nonatomic, weak) id<PlateNoKeyboardViewDelegate> delegate;

-(void)setType:(KeyboardType)type;

//公共方法 - 字符串已经删除完毕
- (void)deleteEnd;

@end

NS_ASSUME_NONNULL_END
