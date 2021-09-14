//
//  UIView+Hint.m
//  EnochCar
//
//  Created by 王海燕 on 2021/6/21.
//

#import "UIView+Hint.h"

@implementation UIView (Hint)


-(void)showHint:(NSString *)message
{
    CGSize screenSize = [[UIScreen mainScreen] bounds].size;
     
        UIWindow * window = [UIApplication sharedApplication].keyWindow;
        UIView *showview =  [[UIView alloc]init];
        showview.backgroundColor = [UIColor colorWithRed:76/255.0 green:76/255.0 blue:76/255.0 alpha:1];
        showview.frame = CGRectMake(1, 1, 1, 1);
        showview.alpha = 1.0f;
        showview.layer.cornerRadius = 5.0f;
        showview.layer.masksToBounds = YES;
        [window addSubview:showview];
        
        UILabel *label = [[UILabel alloc]init];
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc]init];
        paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
        
        NSDictionary *attributes = @{NSFontAttributeName:[UIFont systemFontOfSize:15.f],
                                       NSParagraphStyleAttributeName:paragraphStyle.copy};
        
        CGSize labelSize = [message boundingRectWithSize:CGSizeMake(207, 999)
                                                 options:NSStringDrawingUsesLineFragmentOrigin
                                                     attributes:attributes context:nil].size;
     
        label.frame = CGRectMake(10, 10, labelSize.width +20, labelSize.height);
        label.text = message;
        label.textColor = [UIColor whiteColor];
        label.textAlignment = 1;
        label.backgroundColor = [UIColor clearColor];
        label.font = [UIFont boldSystemFontOfSize:15];
        [showview addSubview:label];
        
//        showview.frame = CGRectMake((screenSize.width - labelSize.width - 20)/2,
//                                        screenSize.height - 100,
//                                           labelSize.width+40,
//                                               labelSize.height+10);
    showview.frame = CGRectMake((screenSize.width - labelSize.width - 20)/2,
                                    100,
                                       labelSize.width+40,
                                           labelSize.height+20);
        [UIView animateWithDuration:3 animations:^{
            showview.alpha = 0;
        } completion:^(BOOL finished) {
            [showview removeFromSuperview];
        }];
}


-(void)showAlertWithTitle:(NSString*)title message:(NSString*)message
{
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:title
                                                                       message:message
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action) {
                                                                  //响应事件
                                                                  
                                                              }];

        [alert addAction:defaultAction];

    [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alert animated:YES completion:nil];
    
}


@end
