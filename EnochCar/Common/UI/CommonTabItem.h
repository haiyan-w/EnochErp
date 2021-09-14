//
//  commonTabItem.h
//  EnochCar
//
//  Created by 王海燕 on 2021/5/19.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, CommonTabItemStyle){
    CommonTabItemStyleImage  = 0,
    CommonTabItemStyleText  = 1,
    CommonTabItemStyleAttrText  = 2,
};


@interface CommonTabItem : NSObject
@property(nonatomic,readwrite,strong)NSString * imageName;
@property(nonatomic,readwrite,strong)NSString * selectedImageName;
@property(nonatomic,readwrite,strong)NSString * title;
@property(nonatomic,readwrite,strong)NSString * selectedTitle;
@property(nonatomic,readwrite,strong)NSAttributedString * attrTitle;
@property(nonatomic,readwrite,strong)NSAttributedString * selectedAttrTitle;

@property(nonatomic,readwrite,assign)NSInteger tag;


- (instancetype)initWithImagename:(NSString *)imagename selectedImage:(NSString *)selectedImagename;
- (instancetype)initWithTitle:(NSString *)title;
- (instancetype)initWithAttrText:(NSAttributedString *)attrText;
- (instancetype)initWithAttrText:(NSAttributedString *)attrText selectedAttr:(NSAttributedString*)selectedAttrText;

-(CommonTabItemStyle)style;
@end

NS_ASSUME_NONNULL_END
