//
//  CommonTool.h
//  EnochCar
//
//  Created by HAIYAN on 2021/5/16.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CommonTool : NSObject

+(BOOL)isVinValid:(NSString *)vinString;

+(BOOL)isCellphoneValid:(NSString *)phoneString;

+(NSString *)getNowTimestamp;

+ (NSString *)getNowDateStr;

+(NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString;

//从带空格车牌获取不带空格的车牌
+(NSString *)getPlateNoString:(NSString *)plateNo;

//获取带空格分隔的车牌号
+(NSString *)getPlateNoSpaceString:(NSString *)plateNo;

//从带空格vin获取不带空格的vin码
+(NSString *)getVinString:(NSString *)spaceVin;

//获取带空格的vin码
+(NSString *)getVinSpaceString:(NSString *)vin;

+ (CGFloat)labelAutoCalculateRectWith:(NSString*)text FontSize:(CGFloat)fontSize MaxSize:(CGSize)maxSize;

+ (void)changeOrientation:(UIInterfaceOrientation)orientation;

+(BOOL)isIPad;

+(NSString *)systemVersion;

+(NSString *)terminalString;

+(BOOL)isIPhoneXBefore;

+(CGFloat)statusbarH;

+(CGFloat)navbarH;

+(CGFloat)topbarH;

+ (UIImage *)imageWithImageSimple:( UIImage *)image scaledToRect:(CGRect)newRect;

+ (UIImage *)cropImage:(UIImage *)image toRect:(CGRect)rect;

+ (BOOL)validateFloatNumber:(NSString*)number;

+(NSDictionary *)getErrorInfo:(NSError *_Nonnull)error;

+(NSString *)getErrorMessage:(NSError *_Nonnull)error;
@end

NS_ASSUME_NONNULL_END
