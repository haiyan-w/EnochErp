//
//  RecognizeViewController.h
//  tableview
//
//  Created by HAIYAN on 2021/5/7.
//

#import <UIKit/UIKit.h>
#import "NetWorkAPIManager.h"
#import "CommonViewController.h"
#import "CommonDefine.h"
#import "BaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@class RecognizeViewController;
@protocol RecognizeViewControllerDelegate <NSObject>

-(void)recognize:(RecognizeViewController*)recognizeCtrl withResult:(NSDictionary*)data;

@end

@interface RecognizeViewController : BaseViewController

@property(nonatomic, weak) id<RecognizeViewControllerDelegate> delegate;

-(instancetype)initWithType:(RecognizeType)type;
@end

NS_ASSUME_NONNULL_END
