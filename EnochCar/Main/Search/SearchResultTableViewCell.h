//
//  SearchResultTableViewCell.h
//  EnochCar
//
//  Created by 王海燕 on 2021/5/24.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SearchResultTableViewCell : UITableViewCell
@property(nonatomic,readwrite,copy)NSString * searchText;

-(void)configdata:(NSDictionary*)data;
@end

NS_ASSUME_NONNULL_END
