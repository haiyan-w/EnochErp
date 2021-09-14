//
//  CommonTool.m
//  EnochCar
//
//  Created by HAIYAN on 2021/5/16.
//

#import "CommonTool.h"
#import <sys/utsname.h>


@implementation CommonTool

+(BOOL)isVinValid:(NSString *)vinString
{
    if (vinString.length == 17) {
        return YES;
    }
    return NO;
}

+(BOOL)isCellphoneValid:(NSString *)phoneString
{
    if (phoneString.length != 11){
        return NO;
    }else {
        
        //移动号段正则表达式
        NSString *CM_NUM = @"^((13[4-9])|(147)|(15[0-2,7-9])|(17[0-9])|(18[2-4,7-8]))\\d{8}$";
  
        //联通号段正则表达式
        NSString *CU_NUM = @"^((13[0-2])|(145)|(15[5-6])|(17[0-9])|(18[5,6]))\\d{8}$";
        
        //电信号段正则表达式
        NSString *CT_NUM = @"^((133)|(153)|(17[0-9])|(18[0,1,9]))\\d{8}$";
        
        NSPredicate *pred1 = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CM_NUM];
        
        BOOL isMatch1 = [pred1 evaluateWithObject:phoneString];
        NSPredicate *pred2 = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CU_NUM];
        BOOL isMatch2 = [pred2 evaluateWithObject:phoneString];
        NSPredicate *pred3 = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CT_NUM];
        BOOL isMatch3 = [pred3 evaluateWithObject:phoneString];
        
        if (isMatch1 || isMatch2 || isMatch3) {
            return YES;
            
        }else {
            return NO;
        }
      
    }
 
    return NO;
}

+(NSString *)getNowTimestamp{
    
    NSDate* dat = [NSDate dateWithTimeIntervalSinceNow:0];
    
    NSTimeInterval a=[dat timeIntervalSince1970];
    
    NSString*timeString = [NSString stringWithFormat:@"%0.f", a];//转为字符型
    
    return timeString;
}

+ (NSString *)getNowDateStr{
    NSDate *currentDate = [NSDate date];//获取当前时间，日期
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    //设定时间格式,这里可以设置成自己需要的格式
    [dateFormatter setDateFormat:@"YYYY-MM-dd"];
    NSString *ymdString = [dateFormatter stringFromDate:currentDate];
    [dateFormatter setDateFormat:@"hh:mm:ss"];
    NSString *hmsString = [dateFormatter stringFromDate:currentDate];
    NSString * dateString = [NSString stringWithFormat:@"%@T%@",ymdString,hmsString];
    return dateString;
}


//tool
+(NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString {
   if (jsonString == nil) {
       return nil;
   }
   NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
   NSError *err;
   NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                       options:NSJSONReadingMutableContainers
                                                         error:&err];
   if(err) {
       NSLog(@"json解析失败：%@",err);
       return nil;
   }
   return dic;
}

//从带空格车牌获取不带空格的车牌
+(NSString *)getPlateNoString:(NSString *)plateNo
{
    NSString * newstring = [plateNo stringByReplacingOccurrencesOfString:@" " withString:@""];
    return newstring;
}


//获取带空格分隔的车牌号
+(NSString *)getPlateNoSpaceString:(NSString *)plateNo
{
    NSString * substring = plateNo;
    NSString * plateNo2 = @"";
    if (substring.length >= 2) {
        NSString * headstring = [plateNo substringToIndex:2];
        substring = [substring substringFromIndex:2];
        plateNo2 = [NSString stringWithFormat:@"%@ %@",headstring,substring];
    }else {
        plateNo2 = [plateNo2 stringByAppendingString:substring];
    }
    return plateNo2;
}

//从带空格vin获取不带空格的vin码
+(NSString *)getVinString:(NSString *)spaceVin
{
    NSString * newstring = [spaceVin stringByReplacingOccurrencesOfString:@" " withString:@""];
    return newstring;
}

//获取带空格的vin码
+(NSString *)getVinSpaceString:(NSString *)vin
{
    NSString * substring = vin;
    NSString * vin2 = @"";
    if (substring.length > 4) {
        vin2 = [vin2 stringByAppendingString:[substring substringToIndex:4]];
        substring = [substring substringFromIndex:4];
    }else {
        
        vin2 = [vin2 stringByAppendingString:substring];
        return vin2;
    }
    if (substring.length > 4) {
        vin2 = [vin2 stringByAppendingString:[NSString stringWithFormat:@" %@",[substring substringToIndex:4]]];
        substring = [substring substringFromIndex:4];
    }else {
        vin2 = [vin2 stringByAppendingString:[NSString stringWithFormat:@" %@",substring]];
        return vin2;
    }
    if (substring.length > 4) {
        vin2 = [vin2 stringByAppendingString:[NSString stringWithFormat:@" %@",[substring substringToIndex:4]]];
        substring = [substring substringFromIndex:4];
    }else {
        vin2 = [vin2 stringByAppendingString:[NSString stringWithFormat:@" %@",substring]];
        return vin2;
    }
    if (substring.length > 5) {
        vin2 = [vin2 stringByAppendingString:[NSString stringWithFormat:@" %@",[substring substringToIndex:5]]];
        substring = [substring substringFromIndex:5];
    }else {
        vin2 = [vin2 stringByAppendingString:[NSString stringWithFormat:@" %@",substring]];
        return vin2;
    }
    
    return vin2;
}


+ (CGFloat)labelAutoCalculateRectWith:(NSString*)text FontSize:(CGFloat)fontSize MaxSize:(CGSize)maxSize{
    NSMutableParagraphStyle* paragraphStyle = [[NSMutableParagraphStyle alloc]init];
    
    paragraphStyle.lineBreakMode=NSLineBreakByWordWrapping;
    
    NSDictionary* attributes =@{NSFontAttributeName:[UIFont systemFontOfSize:fontSize],NSParagraphStyleAttributeName:paragraphStyle.copy};
    
    CGSize labelSize = [text boundingRectWithSize:maxSize options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading|NSStringDrawingTruncatesLastVisibleLine attributes:attributes context:nil].size;
    
    labelSize.height=ceil(labelSize.height);
    
    labelSize.width=ceil(labelSize.width);
    
    return labelSize.height;
}


+ (void)changeOrientation:(UIInterfaceOrientation)orientation
{
    int val = orientation;
    if ([[UIDevice currentDevice] respondsToSelector:@selector(setOrientation:)]) {
        SEL selector = NSSelectorFromString(@"setOrientation:");
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[UIDevice instanceMethodSignatureForSelector:selector]];
        [invocation setSelector:selector];
        [invocation setTarget:[UIDevice currentDevice]];
        [invocation setArgument:&val atIndex:2];
        [invocation invoke];
    }
}

+(BOOL)isIPad
{
    BOOL isIPad = NO;
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        isIPad = YES;
    }
    return isIPad;
}

+(NSString *)systemVersion
{
    NSString * systemVersion = [UIDevice currentDevice].systemVersion;
    return systemVersion;
}

+(NSString *)terminalString
{
    NSString * string = @"";
    if ([CommonTool isIPad]) {
        string = [string stringByAppendingString:@"IPAD"];
    }else {
        string = [string stringByAppendingString:@"IPHONE"];
    }
    string = [string stringByAppendingString:[NSString stringWithFormat:@"[%@]",[CommonTool systemVersion]]];
    return string;
}

+(BOOL)isIPhoneXBefore
{
    struct utsname systemInfo;
    uname(&systemInfo);
    NSString *model = [NSString stringWithCString: systemInfo.machine encoding:NSASCIIStringEncoding];
    NSArray * iphonexBefore = @[@"iPhone3,1",@"iPhone3,2",@"iPhone4,1",@"iPhone5,1",@"iPhone5,2",@"iPhone5,3",@"iPhone5,4",@"iPhone6,1",@"iPhone6,2",@"iPhone7,1",@"iPhone7,2",@"iPhone8,1",@"iPhone8,2",@"iPhone8,4",@"iPhone9,1",@"iPhone9,2",@"iPhone10,1",@"iPhone10,2",@"iPhone10,3",@"iPhone10,4",@"iPhone10,5"];
    
    BOOL isIPhonexBefore = NO;
    
    for (NSString * iphonemodel in iphonexBefore) {
        if ([model isEqualToString:iphonemodel]) {
            isIPhonexBefore = YES;
        }
    }
    return isIPhonexBefore;
}

+(CGFloat)statusbarH
{
    return [[UIApplication sharedApplication] statusBarFrame].size.height;
}

+(CGFloat)navbarH
{
    return 44.f;
}

+(CGFloat)topbarH
{
    return [[UIApplication sharedApplication] statusBarFrame].size.height + 44.f;
}

@end
