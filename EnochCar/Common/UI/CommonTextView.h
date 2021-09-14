//
//  CommonTextView.h
//  EnochCar
//
//  Created by 王海燕 on 2021/7/26.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CommonTextView : UIView
@property (nonatomic,strong) NSString * placeHolder;
-(NSString*)getText;
-(void)setText:(NSString*)text;
@end

NS_ASSUME_NONNULL_END
