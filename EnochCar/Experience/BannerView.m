//
//  BannerView.m
//  EnochCar
//
//  Created by 王海燕 on 2021/7/26.
//

#import "BannerView.h"
#import <SDWebImage/SDWebImage.h>
#import "BannerItem.h"
#import <AVFoundation/AVFoundation.h>

@interface BannerView()<UIScrollViewDelegate>
@property(nonatomic, strong)UILabel * titleLabel;
@property(nonatomic, strong)UILabel * numLabel;
@property(nonatomic, strong)UIScrollView * scrollview;

//@property(nonatomic, strong)NSMutableArray * dataArray;
@property(nonatomic, strong)NSArray<BannerItem*> * originalDatas;
@property(nonatomic, strong)NSMutableArray<BannerItem*> * dataArray;
@property(nonatomic, strong)NSMutableArray<UIView*> * viewArray;
@property(nonatomic, strong)NSTimer * timer;
@property(nonatomic, assign)NSInteger curPage;//页数从1开始
@property(nonatomic, assign)BOOL isDraging;
@property(nonatomic, assign)CGFloat lastOffsetX;


@end

@implementation BannerView

-(void)awakeFromNib
{
    [super awakeFromNib];
    [self addSubviews];
//    [self addTimer];
}

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.timeInterval = 10;
        [self addSubviews];
//        [self addTimer];
    }
    return self;
}

-(void)addSubviews
{
    [self.scrollview setFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height - 20)];
    self.scrollview.delegate = self;
    [self.numLabel setFrame:CGRectMake(self.frame.size.width - 40, self.frame.size.height - 20, 40, 20)];
    [self.titleLabel setFrame:CGRectMake(0, self.frame.size.height - 20, self.frame.size.width - 60, 20)];
    
    [self addSubview:self.titleLabel];
    [self addSubview:self.numLabel];
    [self addSubview:self.scrollview];
}

-(void)addTimer
{
    self.timer = [NSTimer scheduledTimerWithTimeInterval:self.timeInterval target:self selector:@selector(nextPage) userInfo:nil repeats:YES];
}

-(UILabel *)titleLabel
{
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, self.frame.size.height - 20, self.frame.size.width - 60, 20)];
        _titleLabel.font = [UIFont systemFontOfSize:12];
        _titleLabel.textColor = [UIColor colorWithRed:102/255.0 green:102/255.0 blue:102/255.0 alpha:1];
    }
    return _titleLabel;
}

-(UILabel *)numLabel
{
    if (!_numLabel) {
        _numLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.frame.size.width - 40, self.frame.size.height - 20, 40, 20)];
        _numLabel.font = [UIFont systemFontOfSize:12];
        _numLabel.textColor = [UIColor colorWithRed:102/255.0 green:102/255.0 blue:102/255.0 alpha:1];
    }
    return _numLabel;
}

-(UIScrollView *)scrollview
{
    if (!_scrollview) {
        _scrollview = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
        _scrollview.scrollEnabled = YES;
        _scrollview.showsVerticalScrollIndicator = NO;
        _scrollview.showsHorizontalScrollIndicator = NO;
        _scrollview.pagingEnabled = YES;
        _scrollview.delegate = self;
        _scrollview.layer.cornerRadius = 4;
        _scrollview.layer.masksToBounds = YES;
    }
    return _scrollview;
}


-(void)setDataArray:(NSMutableArray <BannerItem*>*)dataArray
{
    if (!dataArray || dataArray.count == 0) {
        return;
    }
    
    [self clear];
    _originalDatas = dataArray;
    _dataArray = [NSMutableArray arrayWithArray:dataArray];
    BannerItem * item1 = [dataArray firstObject];
    BannerItem * item2 = [dataArray lastObject];
    //多项才可滑动可轮播
    if (dataArray.count > 1) {
        [_dataArray  addObject:item1];
        [_dataArray  insertObject:item2 atIndex:0];
    }

    for (int i = 0; i < _dataArray.count; i++) {
        BannerItem * item = [_dataArray objectAtIndex:i];
        UIImageView * imageview = [[UIImageView alloc] initWithFrame:CGRectMake(self.scrollview.bounds.size.width * i, 0, self.scrollview.bounds.size.width, self.scrollview.bounds.size.height)];
        imageview.layer.cornerRadius = 4;
        imageview.layer.masksToBounds = YES;
        imageview.userInteractionEnabled = YES;
        
        if (item.type == BannerItemImage) {
            if([item imageName]) {
                [imageview setImage:[UIImage imageNamed:[item imageName]]];
            }else if([item imageURL]){
                [imageview sd_setImageWithURL:[NSURL URLWithString:[item imageURL]] placeholderImage:[UIImage imageNamed:@"banner_placeholder_image"]];
            }
        }else {// BannerItemVideo
            NSString * videoCoverImage = [NSString stringWithFormat:@"%@?x-oss-process=video/snapshot,t_500,f_jpg",[item videoURL]];
            [imageview sd_setImageWithURL:[NSURL URLWithString:videoCoverImage] placeholderImage:[UIImage imageNamed:@"banner_placeholder_image"]];
            //播放图标
            UIImageView * iconImage = [[UIImageView alloc] initWithFrame:CGRectMake((imageview.frame.size.width - 48)/2, (imageview.frame.size.height - 48)/2, 48, 48)];
            [iconImage setImage:[UIImage imageNamed:@"banner_play"]];
            [imageview addSubview:iconImage];
        }
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tap:)];
        [imageview addGestureRecognizer:tap];
        [self.scrollview addSubview:imageview];
    }
    
    self.scrollview.contentSize = CGSizeMake(self.scrollview.bounds.size.width * _dataArray.count, self.scrollview.bounds.size.height);
    self.curPage = 0;
    if (dataArray.count > 1) {
        [self.scrollview setContentOffset:CGPointMake(self.scrollview.bounds.size.width, 0) animated:NO];
        [self addTimer];
    }
}

-(void)setCurPage:(NSInteger)curPage
{
//    NSLog(@"banner set page:%d", curPage);
    if (curPage < _originalDatas.count) {
        _curPage = curPage;
        //显示页数从1 开始
        
        self.numLabel.text = [NSString stringWithFormat:@"%d / %d",_curPage+1,_originalDatas.count];
        self.titleLabel.text = [_originalDatas objectAtIndex:_curPage].title;
        
        if ([self.delegate respondsToSelector:@selector(bannerView:pageChanged:)]) {
            [self.delegate bannerView:self pageChanged:_curPage];
        }
    }
    
}

-(void)setViews:(NSArray <UIView*>* )views
{
    if (!views || views.count == 0) {
        return;
    }

    //循环轮播，在首页前插入最后一页，左后插入第一页
    _viewArray = [NSMutableArray arrayWithArray:views];
    [_viewArray addObject:[views firstObject]];
    [_viewArray insertObject:[views lastObject] atIndex:0];

    for (int index = 0; index < _viewArray.count; index ++) {
        UIView * view = [_viewArray objectAtIndex:index];
        [view setFrame:CGRectMake(self.scrollview.bounds.size.width * index, 0, self.scrollview.bounds.size.width, self.scrollview.bounds.size.height)];
        [self.scrollview addSubview:view];
    }
    self.scrollview.contentSize = CGSizeMake(self.scrollview.bounds.size.width * _viewArray.count, self.scrollview.bounds.size.height);
    [self.scrollview setContentOffset:CGPointMake(self.scrollview.bounds.size.width, 0) animated:NO];
}

-(void)clear
{
    [self.timer setFireDate:[NSDate distantFuture]];
    for (UIView * view in self.scrollview.subviews) {
        [view removeFromSuperview];
    }
    self.scrollview.contentSize = CGSizeMake(self.scrollview.bounds.size.width, self.scrollview.bounds.size.height);
    self.scrollview.contentOffset = CGPointMake(0, 0);
}

-(void)nextPage
{
//    NSLog(@"banner nextPage");
    __weak BannerView * weakself = self;
    CGPoint pt = self.scrollview.contentOffset;
    CGPoint offset = CGPointMake(0, pt.y);
    if (pt.x >= self.scrollview.bounds.size.width * (self.dataArray.count - 2)) {
        offset.x = pt.x + self.scrollview.bounds.size.width;
        [UIView animateWithDuration:0.5 animations:^{
            weakself.scrollview.contentOffset = offset;
        } completion:^(BOOL finished) {
            weakself.scrollview.contentOffset = CGPointMake(self.scrollview.bounds.size.width, self.scrollview.contentOffset.y);
            [weakself getPage];
        }];
    }else {
        offset.x = pt.x + self.scrollview.bounds.size.width;
        [UIView animateWithDuration:0.5 animations:^{
            weakself.scrollview.contentOffset = offset;
            [weakself getPage];
        }];
    }
}

-(void)tap:(UITapGestureRecognizer *)tap{
    if(_delegate&&[_delegate respondsToSelector:@selector(bannerView: TapOnPage:)]){
      [_delegate bannerView:self TapOnPage:_curPage];
  }
}


- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self.timer setFireDate:[NSDate distantFuture]];
    self.isDraging = YES;
    self.lastOffsetX = scrollView.contentOffset.x;
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [self.timer setFireDate:[NSDate dateWithTimeIntervalSinceNow:self.timeInterval]];
    
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self getPage];
    self.isDraging = NO;
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (self.isDraging) {
        CGPoint point = scrollView.contentOffset;
        CGFloat width = self.scrollview.frame.size.width;
        CGFloat offsetX = point.x;
        
        __weak  BannerView * weakself = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakself getPage];
        });
        
        if (offsetX >= (self.dataArray.count-1)*width)
        {
            offsetX = width;
            scrollView.contentOffset = CGPointMake(offsetX, 0);

        }else if (offsetX <= 0)
        {
            offsetX = (self.dataArray.count-2)*width;
            scrollView.contentOffset = CGPointMake(offsetX, 0);
        }
    }
}

-(NSInteger)getPage
{
    //取页码数
    if (_originalDatas.count > 1) {
        if (self.isDraging) {
            CGPoint endPoint = self.scrollview.contentOffset;
            CGFloat offsetX = endPoint.x;
            CGFloat width = self.scrollview.bounds.size.width;
            NSInteger index = roundf(offsetX/width);
            if(index == 0)
            {
                self.curPage = self.originalDatas.count - 1;
            }else if(index == self.dataArray.count-1)
            {
                self.curPage = 0;
            }else {
                self.curPage = index-1;
            }
//            NSLog(@"%.0f banner offset:%.0f ,%.0f , index: %d, page:%d",width, endPoint.x, endPoint.y,index,self.curPage);
        }else {
            CGPoint endPoint = self.scrollview.contentOffset;
            NSInteger offsetX = endPoint.x;
            NSInteger width = self.scrollview.frame.size.width;
            self.curPage = offsetX/width - 1;
        }
        
    }else {
        self.curPage = 0;
    }
    
    return self.curPage;
}

@end
