//
//  ItemCollectionViewCell.h
//  EnochCar
//
//  Created by 王海燕 on 2021/5/18.
//

#import <UIKit/UIKit.h>


NS_ASSUME_NONNULL_BEGIN

@interface ItemCollectionViewCell : UICollectionViewCell
@property(nonatomic,readwrite,strong)UINavigationController * navigationController;
@property(nonatomic,readwrite,strong)UICollectionView * collectionView;
@property(nonatomic, readwrite, copy) NSMutableArray * maintances;//查询到的项目列表
@property(nonatomic, readwrite, copy) NSMutableArray * workingteams;
@property(nonatomic, readwrite, copy) NSMutableArray * chargeMethods;

@property(nonatomic, readwrite, copy) NSMutableDictionary * curMaintance;//当前维修项目

-(BOOL)hideDetail;
//-(void)LayoutWithData:(DataItem*)data;
-(void)LayoutWithData:(NSMutableDictionary*)data index:(NSInteger)index;
@end

NS_ASSUME_NONNULL_END
