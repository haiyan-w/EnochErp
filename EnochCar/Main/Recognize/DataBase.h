//
//  DataBase.h
//  EnochCar
//
//  Created by 王海燕 on 2021/6/11.
//

#import <Foundation/Foundation.h>


NS_ASSUME_NONNULL_BEGIN

@interface DataBase : NSObject

+(instancetype)defaultDataBase;

-(void)openRecognizeList;
-(BOOL)insertARecognize:(NSInteger)type plateNo:(NSString *)plateNo name:(NSString *)name vin:(NSString *)vin;
-(BOOL)deleteARecognize:(NSInteger)ID;
-(NSArray*)getAll;

-(void)openSeviceList;
-(BOOL)insertAService:(NSInteger)vehicleID seviceInfo:(NSDictionary*)info;
-(NSDictionary *)getSeviceInfoBy:(NSInteger)vehicleID;
-(BOOL)updateASevice:(NSInteger)vehicleID  seviceInfo:(NSDictionary*)info;
-(BOOL)deleteASevice:(NSInteger)vehicleID;
-(void)close;
@end

NS_ASSUME_NONNULL_END
