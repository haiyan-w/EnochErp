//
//  SearchResultView.h
//  EnochCar
//
//  Created by 王海燕 on 2021/5/21.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class SearchResultView;

@protocol SearchResultDelegate <NSObject>

@required

- (void)searchView:(SearchResultView*)searchView selectData:(NSDictionary*)data;
- (void)searchView:(SearchResultView*)searchView viewWillRemove:(NSDictionary*)data;

@end

@interface SearchResultView : UIView

@property(nonatomic, readwrite,weak) id <SearchResultDelegate>delegate;

-(void)searchData:(NSString*)text;

@end

NS_ASSUME_NONNULL_END
