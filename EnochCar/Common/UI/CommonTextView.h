//
//  CommonTextView.h
//  EnochCar
//
//  Created by 王海燕 on 2021/7/26.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CommonTextView : UIView
@property (nonatomic,weak) id<UITextViewDelegate> delegate;
@property (nonatomic,strong) NSString * placeHolder;
-(instancetype)initWithFrame:(CGRect)frame title:(NSString*)titleStr placeHolder:(NSString *)placeHolderStr;
-(NSString*)getText;
-(void)setText:(NSString*)text;
-(void)setTextViewTag:(NSInteger)tag;
-(void)beginEditing;
-(void)endEditing;

@end

NS_ASSUME_NONNULL_END
