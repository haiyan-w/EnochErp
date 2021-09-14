//
//  commonTabView.h
//  EnochCar
//
//  Created by 王海燕 on 2021/5/19.
//

#import <UIKit/UIKit.h>
#import "CommonTabItem.h"

NS_ASSUME_NONNULL_BEGIN





@class CommonTabView;

@protocol CommonTabViewDelegate <NSObject>

@optional

-(void)tabview:(CommonTabView *)tabview indexChanged:(NSInteger )index;

@end


@interface CommonTabView : UIView

@property (nonatomic, weak, nullable) id <CommonTabViewDelegate> delegate;
@property(nullable, nonatomic, copy) NSArray<CommonTabItem *> *items;

-(instancetype)initWithFrame:(CGRect)frame target:(id<CommonTabViewDelegate>)delegate;
-(void)setNormalColor:(UIColor *)normalColor;
-(void)setSelectedColor:(UIColor *)selectedColor;
-(void)setFont:(UIFont *)font;
-(void)setIndex:(NSInteger)index;
-(NSInteger)index;
@end

NS_ASSUME_NONNULL_END
