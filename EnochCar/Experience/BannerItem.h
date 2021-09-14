//
//  BannerItem.h
//  EnochCar
//
//  Created by 王海燕 on 2021/7/30.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN


typedef enum
{
    BannerItemImage,
    BannerItemVideo
}BannerItemType;

@interface BannerItem : NSObject
-(instancetype)initWithImageName:(nullable NSString*)imageName imageURL:(nullable NSString *)imageURL title:(nullable NSString *)title;
-(instancetype)initWithVideoURL:(NSString*)videoURL title:(NSString *)title;

-(BannerItemType)type;
-(NSString *)title;
-(NSString *)imageName;
-(NSString *)imageURL;
-(NSString *)videoURL;
@end

NS_ASSUME_NONNULL_END
