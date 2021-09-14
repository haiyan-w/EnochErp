//
//  DataBase.m
//  EnochCar
//
//  Created by 王海燕 on 2021/6/11.
//

#import "DataBase.h"
#import "FMDB.h"



@interface DataBase()
@property(nonatomic,readwrite,strong)FMDatabase * db;
@property(nonatomic,readwrite,weak) DataBase * weakself;
@end

static DataBase * database;

@implementation DataBase

+(instancetype)defaultDataBase
{
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        database =  [[DataBase alloc] init];
    });
    
    return database;
}

-(instancetype)init
{
    self = [super init];
//    if (!self) {
//        return nil;
//    }
    return self;
}

-(void)openRecognizeList
{
    [self.db close];
    // 0.拼接数据库存放的沙盒路径
    NSString *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).lastObject;
    NSString *sqlFilePath = [path stringByAppendingPathComponent:@"recognizelists.sqlite"];
        
    // 1.通过路径创建数据库
    self.db = [FMDatabase databaseWithPath:sqlFilePath];
        
    // 2.打开数据库
    if ([self.db open]) {
        NSLog(@"打开Recognize成功");
            
        BOOL success = [self.db executeUpdate:@"CREATE TABLE IF NOT EXISTS t_recognize (id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, type INTEGER DEFAULT 0,plateNo TEXT, name TEXT ,vin TEXT)"];
            
        if (success) {
            NSLog(@"创建Recognize表成功");
        } else {
            NSLog(@"创建Recognize表失败");
        }
            
    } else {
            NSLog(@"打开Recognize失败");
    }
    
}


-(BOOL)insertARecognize:(NSInteger)type plateNo:(NSString *)plateNo name:(NSString *)name vin:(NSString *)vin
{
    BOOL result = [self.db executeUpdate:@"INSERT INTO t_recognize (type ,plateNo, name,vin) VALUES (?, ?, ?, ?)",[NSNumber numberWithInteger:type], plateNo, name,vin];

    if (result) {
        NSLog(@"插入Recognize成功");
    } else {
        NSLog(@"插入Recognize失败");
    }
    return result;
}

-(BOOL)deleteARecognize:(NSInteger)ID
{
    BOOL result = [self.db executeUpdate:@"delete from t_recognize where id = ?",[NSNumber numberWithInteger:ID]];
    if (!result) {
        NSLog(@"Recognize数据删除失败");
    } else {
        NSLog(@"Recognize数据删除成功");
    }
    return result;
}

-(NSArray*)getAll
{
    NSMutableArray * array = [NSMutableArray array];
    FMResultSet *resultSet = [self.db executeQuery:@"SELECT * FROM t_recognize ORDER BY id DESC;"];
    // 2.遍历结果
        while ([resultSet next]) {
            NSMutableDictionary * data = [NSMutableDictionary dictionary];
            NSString *plateNo = [resultSet stringForColumn:@"plateNo"];
            NSString *name = [resultSet stringForColumn:@"name"];
            NSString *vin = [resultSet stringForColumn:@"vin"];
            NSInteger type = [resultSet intForColumn:@"type"];
            NSInteger ID = [resultSet intForColumn:@"id"];
            [data setValue:plateNo forKey:@"plateNo"];
            [data setValue:name forKey:@"name"];
            [data setValue:vin forKey:@"vin"];
            [data setValue:[NSNumber numberWithInteger:type] forKey:@"type"];
            [data setValue:[NSNumber numberWithInteger:ID]  forKey:@"id"];
            [array addObject:data];
        }
    return array;
}


-(void)openSeviceList
{
    [self.db close];
    // 0.拼接数据库存放的沙盒路径
    NSString *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).lastObject;
    NSString *sqlFilePath = [path stringByAppendingPathComponent:@"sevice.sqlite"];
        
    // 1.通过路径创建数据库
    self.db = [FMDatabase databaseWithPath:sqlFilePath];
        
    // 2.打开数据库
    if ([self.db open]) {
        NSLog(@"打开Sevice成功");
            
//        BOOL success = [self.db executeUpdate:@"CREATE TABLE IF NOT EXISTS t_sevice (id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, currentMileage INTEGER DEFAULT 0,solution TEXT, descriptions BLOB ,serviceVehicleImgUrls BLOB,comment TEXT, chargingMethod TEXT)"];
        BOOL success = [self.db executeUpdate:@"CREATE TABLE IF NOT EXISTS t_sevice (id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,vehicleID INTEGER, seviceInfo BLOB)"];
            
        if (success) {
            NSLog(@"创建Sevice表成功");
        } else {
            NSLog(@"创建Sevice表失败");
        }
            
    } else {
            NSLog(@"打开Sevice失败");
    }
    
}

-(BOOL)insertAService:(NSInteger)vehicleID  seviceInfo:(NSDictionary*)info
{
    NSData * data = [NSKeyedArchiver  archivedDataWithRootObject:info];
    BOOL result = [self.db executeUpdate:@"INSERT INTO t_sevice (vehicleID, seviceInfo) VALUES (?, ?)",[NSNumber numberWithInteger:vehicleID],data];

    if (result) {
        NSLog(@"插入Sevice成功");
    } else {
        NSLog(@"插入Sevice失败");
    }
    return result;
    
}

-(NSDictionary *)getSeviceInfoBy:(NSInteger)vehicleID
{
    FMResultSet * resultSet = [self.db executeQuery:@"SELECT * FROM t_sevice WHERE vehicleID = ?", [NSNumber numberWithInteger:vehicleID]];
    NSDictionary * sevice = nil;
    while ([resultSet next]) {
        NSData * data = [resultSet dataForColumn:@"seviceInfo"];
        sevice = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        }
    return sevice;
}

-(BOOL)updateASevice:(NSInteger)vehicleID  seviceInfo:(NSDictionary*)info
{
    NSData * data = [NSKeyedArchiver  archivedDataWithRootObject:info];
    BOOL result = [self.db executeUpdate:@"UPDATE t_sevice SET seviceInfo = ? WHERE vehicleID = ?",data,[NSNumber numberWithInteger:vehicleID]];

    if (result) {
        NSLog(@"更新Sevice成功");
    } else {
        NSLog(@"更新Sevice失败");
    }
    return result;
}

-(BOOL)deleteASevice:(NSInteger)vehicleID
{
    BOOL result = [self.db executeUpdate:@"DELETE FROM t_sevice WHERE vehicleID = ?",[NSNumber numberWithInteger:vehicleID]];

    if (result) {
        NSLog(@"Sevice数据删除成功");
    } else {
        NSLog(@"Recognize数据删除失败");
    }
    return result;
}


-(void)close
{
    [self.db close];
}

@end
