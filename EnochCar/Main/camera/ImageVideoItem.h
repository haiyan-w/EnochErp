//
//  ImageVideoItem.h
//  EnochCar
//
//  Created by 王海燕 on 2021/6/30.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN


@interface ImageVideoItem : NSObject
@property(nonatomic, readwrite, strong) UIImage * image;
@property(nonatomic, readwrite, strong) NSURL * url;
@property(nonatomic, readwrite, strong) NSString * dateTime;
@end

NS_ASSUME_NONNULL_END
