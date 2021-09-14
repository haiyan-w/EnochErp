//
//  LineProgressView.h
//  EnochCar
//
//  Created by 王海燕 on 2021/7/23.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface LineProgressView : UISlider
//@property (assign, nonatomic) NSInteger timeMax;
@property (nonatomic,assign)CGFloat progressValue;
//@property (nonatomic, assign) CGFloat currentTime;
@end

NS_ASSUME_NONNULL_END
