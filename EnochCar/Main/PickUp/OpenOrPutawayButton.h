//
//  OpenOrPutawayButton.h
//  EnochCar
//
//  Created by 王海燕 on 2021/9/1.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol OpenOrPutawayButtonDelegate <NSObject>

-(void)OpenOrPutawayStatusChanged:(BOOL)isopen;

@end

@interface OpenOrPutawayButton : UIView
@property(nonatomic,weak) id<OpenOrPutawayButtonDelegate>delegate;
-(instancetype)initWithFrame:(CGRect)frame needOpen:(BOOL)open;
@end

NS_ASSUME_NONNULL_END
