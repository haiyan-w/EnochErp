//
//  ProgressView.h
//  EnochCar
//
//  Created by HAIYAN on 2021/5/7.

#import <UIKit/UIKit.h>

@interface ProgressView : UIView

@property (assign, nonatomic) NSInteger timeMax;

- (void)clearProgress;

@end
