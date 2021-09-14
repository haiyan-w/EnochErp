//
//  PopViewController.h
//  EnochCar
//
//  Created by 王海燕 on 2021/5/20.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol PopViewDelagate <NSObject>
@required

-(void)popview:(UIViewController *)popview disSelectRowAtIndex:(NSInteger)index;

@end

@interface PopViewController : UIViewController

@property(nonatomic,readwrite,strong)id<PopViewDelagate> delegate;

-(instancetype)initWithTitle:(NSString *)title Data:(NSArray *)dataArray;
-(void)showIn:(UIViewController *)viewCtrl;
@end

NS_ASSUME_NONNULL_END
