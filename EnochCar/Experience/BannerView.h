//
//  BannerView.h
//  EnochCar
//
//  Created by 王海燕 on 2021/7/26.
//

#import <UIKit/UIKit.h>
#import "BannerItem.h"

NS_ASSUME_NONNULL_BEGIN

@class BannerView;

@protocol BannerViewDelegate <NSObject>


-(void)bannerView:(BannerView*)banner pageChanged:(NSInteger)curpage;

-(void)bannerView:(BannerView*)banner TapOnPage:(NSInteger)page;

@end

@interface BannerView : UIView
@property(nonatomic,weak) id<BannerViewDelegate> delegate;
@property(nonatomic, assign)NSTimeInterval timeInterval;

-(void)setDataArray:(NSMutableArray <BannerItem *> *)dataArray;
//-(void)setViews:(NSArray <UIView*>* )views;
@end

NS_ASSUME_NONNULL_END
