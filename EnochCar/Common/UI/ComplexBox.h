//
//  ComplexBox.h
//  EnochCar
//
//  Created by 王海燕 on 2021/7/9.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
typedef enum{
    ComplexBoxEdit,
    ComplexBoxSelect,
    ComplexBoxEditAndSelect
}ComplexBoxMode;


typedef void(^ComplexBoxSelectBlock)(void);

@interface ComplexBox : UIView
@property (nonatomic,weak) id<UITextFieldDelegate> delegate;
@property(nonatomic,copy)ComplexBoxSelectBlock selectBlock;
@property (nonatomic,strong) NSString * placeHolder;
@property (nonatomic,assign) BOOL enabled;
@property (nonatomic,assign) BOOL border;
@property (nonatomic,strong) NSString * normalImageName;
@property (nonatomic,strong) NSString * disabledImageName;
@property(nonatomic) UIKeyboardType keyboardType;
@property (nonatomic,strong) UIFont * font;

-(instancetype)initWithFrame:(CGRect)frame mode:(ComplexBoxMode)mode;
-(void)setMode:(ComplexBoxMode)mode;
-(void)setText:(NSString*)text;
-(NSString*)getText;
-(void)setEnable:(BOOL)enable;
- (void)addTarget:(nullable id)target action:(SEL)action forControlEvents:(UIControlEvents)controlEvents;
-(void)setBorder:(BOOL)border;
-(void)setBorderColor:(UIColor*)borderColor;
@end

NS_ASSUME_NONNULL_END
