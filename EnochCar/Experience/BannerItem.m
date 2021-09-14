//
//  BannerItem.m
//  EnochCar
//
//  Created by 王海燕 on 2021/7/30.
//

#import "BannerItem.h"

@interface BannerItem()
@property (nonatomic,assign) BannerItemType type;
@property (nonatomic,strong) NSString * title;
@property (nonatomic,strong) NSString * imageName;
@property (nonatomic,strong) NSString * imageURL;
@property (nonatomic,strong) NSString * videoURL;
@end

@implementation BannerItem

-(instancetype)initWithImageName:(NSString*)imageName imageURL:(NSString *)imageURL title:(NSString *)title
{
    self = [super init];
    if (self) {
        _type = BannerItemImage;
        _imageName = imageName;
        _imageURL = imageURL;
        _title = title;
    }
    return self;
}

-(instancetype)initWithVideoURL:(NSString*)videoURL title:(NSString *)title
{
    self = [super init];
    if (self) {
        _type = BannerItemVideo;
        _videoURL = videoURL;
        _title = title;
    }
    return self;
}
-(BannerItemType)type
{
    return _type;
}

-(NSString *)title
{
    return _title;
}
-(NSString *)imageName
{
    return _imageName;
}
-(NSString *)imageURL
{
    return _imageURL;
}
-(NSString *)videoURL
{
    return _videoURL;
}
@end
