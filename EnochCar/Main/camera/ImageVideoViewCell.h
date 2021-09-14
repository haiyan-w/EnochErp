//
//  ImageVideoViewCell.h
//  EnochCar
//
//  Created by 王海燕 on 2021/6/30.
//

#import <UIKit/UIKit.h>
#import "ImageVideoItem.h"

NS_ASSUME_NONNULL_BEGIN

typedef void(^ImageVideoDeleteBlock)(void);

@interface ImageVideoViewCell : UIView

@property(copy,nonatomic)ImageVideoDeleteBlock deleteBlock;

-(instancetype)initWithFrame:(CGRect)frame item:(ImageVideoItem*)item;
//-(instancetype)initWithFrame:(CGRect)frame item:(ImageVideoItem*)item index:(NSInteger)index;

@end

NS_ASSUME_NONNULL_END
