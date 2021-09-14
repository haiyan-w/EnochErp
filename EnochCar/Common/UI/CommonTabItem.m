//
//  commonTabItem.m
//  EnochCar
//
//  Created by 王海燕 on 2021/5/19.
//

#import <UIKit/UIKit.h>
#import "commonTabItem.h"


@interface CommonTabItem()
@property (nonatomic,assign)CommonTabItemStyle style;
@end

@implementation CommonTabItem

- (instancetype)initWithImagename:(NSString *)imagename selectedImage:(NSString *)selectedImagename 
{
    self = [super init];
    if (self) {
        _style = CommonTabItemStyleImage;
        _imageName = imagename;
        _selectedImageName = selectedImagename;
    }
    return self;
}

- (instancetype)initWithTitle:(NSString *)title
{
    self = [super init];
    if (self) {
        _style = CommonTabItemStyleText;
        _title = title;
    }
    return self;
}

//- (instancetype)initWithTitle:(NSString *)title imagename:(NSString *)imagename selectedImage:(NSString *)selectedImagename
//{
//
//    self = [super init];
//    if (self) {
//        _title = title;
//        _imageName = imagename;
//        _selectedImageName = selectedImagename;
//    }
//    return self;
//
//}

-(CommonTabItemStyle)style
{
    return _style;
}

@end
