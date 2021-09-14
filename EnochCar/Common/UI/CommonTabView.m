//
//  commonTabView.m
//  EnochCar
//
//  Created by 王海燕 on 2021/5/19.
//

#import "CommonTabView.h"

@interface CommonTabView()
@property(readwrite, nonatomic, strong) NSMutableArray *btnArray;
@property(readwrite, nonatomic, assign) NSInteger index;
@property(nonatomic,readwrite,strong)UIColor * normalColor;
@property(nonatomic,readwrite,strong)UIColor * selectedColor;
@property(nonatomic,readwrite,strong)UIFont * font;

@end



@implementation CommonTabView

@synthesize index = _index;


-(instancetype)initWithFrame:(CGRect)frame target:(id<CommonTabViewDelegate>)delegate{
    self = [super initWithFrame:frame];
    if (self) {
        _delegate = delegate;
        _items = [NSMutableArray array];
        _btnArray = [NSMutableArray array];
        _normalColor = [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1];
        _selectedColor = [UIColor colorWithRed:252/255.0 green:215/255.0 blue:139/255.0 alpha:1];
        self.font = [UIFont boldSystemFontOfSize:14];
        self.index = 0;
    }
    return self;
}

-(void)setNormalColor:(UIColor *)normalColor
{
    _normalColor = normalColor;
}

-(void)setSelectedColor:(UIColor *)selectedColor
{
    _selectedColor = selectedColor;
}

-(void)setFont:(UIFont *)font
{
    _font = font;
}

-(void)setItems:(NSArray<CommonTabItem *> *)items
{
    _items = items;
    _btnArray = [NSMutableArray array];
    
    NSInteger width = self.bounds.size.width/items.count;
    NSInteger height = self.bounds.size.height;
    
    for ( int i = 0; i<items.count;i++) {
        
        CommonTabItem * item = [items objectAtIndex:i];
        UIButton * btn = [[UIButton alloc] initWithFrame:CGRectMake(width*i, 0, width, height)];
        btn.tag = i;
        [btn addTarget:self action:@selector(click:) forControlEvents:UIControlEventTouchUpInside];
        [_btnArray addObject:btn];
        [self addSubview:btn];
    }
    self.index  = 0;
}


-(void)click:(UIButton *)sender
{
    self.index  = sender.tag;
}

-(void)setIndex:(NSInteger)index
{
    _index = index;
    for ( int i = 0; i<_btnArray.count;i++){
        CommonTabItem * item = [_items objectAtIndex:i];
        UIButton * btn = [_btnArray objectAtIndex:i];
        
        if (btn.tag == index) {//选中
            if (item.style == CommonTabItemStyleText) {
                [btn setTitle:item.title  forState:UIControlStateNormal];
                [btn setTitleColor:self.selectedColor forState:UIControlStateNormal];
                btn.titleLabel.font = self.font;
            }else if(item.style == CommonTabItemStyleImage){
                if (item.selectedImageName) {
                    [btn setImage:[UIImage imageNamed:item.selectedImageName] forState:UIControlStateNormal];
                }else {
                    [btn setImage:[UIImage imageNamed:item.imageName] forState:UIControlStateNormal];
                }
            }
        }else {//未选中
            if (item.style == CommonTabItemStyleText) {
                [btn setTitle:item.title  forState:UIControlStateNormal];
                [btn setTitleColor:self.normalColor forState:UIControlStateNormal];
                btn.titleLabel.font = self.font;
            }else if(item.style == CommonTabItemStyleImage){
                [btn setImage:[UIImage imageNamed:item.imageName] forState:UIControlStateNormal];
            }
        }
    }
    
    [self.delegate tabview:self indexChanged:_index];
}

-(NSInteger)index
{
    return _index;
}


@end
