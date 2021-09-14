//
//  AppDelegate.h
//  EnochCar
//
//  Created by HAIYAN on 2021/5/7.
//

#import <UIKit/UIKit.h>
//#import <CoreData/CoreData.h>
#import <AFNetworking/AFNetworking.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>
@property (strong,readwrite, nonatomic) UIWindow * window;
//@property (readonly, strong) NSPersistentContainer *persistentContainer;
@property(nonatomic,readwrite,assign) BOOL shouldLandscapeRight;

- (void)saveContext;


@end

