//
//  ImageViewController.h
//  EnochCar
//
//  Created by 王海燕 on 2021/9/1.
//

#import <UIKit/UIKit.h>
#import "CommonViewController.h"

NS_ASSUME_NONNULL_BEGIN

@class ImageViewController;
//@protocol ImageViewControllerDelegate <NSObject>
//-(void)imageViewController:(ImageViewController*)imageCtrl deleteImage:(NSString*)urlstr;
//@end

typedef void(^ImageVideoDeleteBlock)(void);

@interface ImageViewController : CommonViewController
//@property(nonatomic,weak) id <ImageViewControllerDelegate> delegate;
@property(copy,nonatomic)ImageVideoDeleteBlock deleteBlock;
@property(nonatomic,strong) NSString * urlString;
@property(nonatomic,assign) NSUInteger tag;
-(instancetype)initWithUrlString:(NSString*)urlString title:(NSString*)title;
-(void)showOn:(UIViewController*)viewCtrl;
@end

NS_ASSUME_NONNULL_END
