//
//  CommonDefine.h
//  EnochCar
//
//  Created by 王海燕 on 2021/5/25.
//

#ifndef CommonDefine_h
#define CommonDefine_h


typedef NS_ENUM(NSInteger, RecognizeType) {
    RecognizeTypePlateNO                = 0,
    RecognizeTypeDrivingLicence         = 1,
    RecognizeTypeVIN                    = 2,
};


//color
#define TINTCOLOR [UIColor colorWithRed:59/255.0 green:66/255.0 blue:80/255.0 alpha:1]
#define TEXT_COLOR [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1]
#define PLACEHOLDER_COLOR [UIColor colorWithRed:191/255.0 green:191/255.0 blue:191/255.0 alpha:1]


//Notification name
#define NOTIFICATION_LOGIN_SUCCESS @"loginSuccessNotification"
#define NOTIFICATION_LOGIN_FAILURE @"loginFailureNotification"
#define NOTIFICATION_LOGIN_SKIP    @"loginSkipNotification"
#define NOTIFICATION_LOGOUT_SUCCESS @"logoutSuccessNotification"
#define NOTIFICATION_SHOWLOGIN    @"showLoginNotification"


//#define NOTIFICATION_NETWORK_OFF    @"networkOffNotification"
//#define NOTIFICATION_NETWORK_ON    @"networkOnNotification"



//text
#define TEXT_NETWORKOFF @"(无网络)"
#define TEXT_NETWORKOFF_HINT @"当前网络异常"


#endif /* CommonDefine_h */
