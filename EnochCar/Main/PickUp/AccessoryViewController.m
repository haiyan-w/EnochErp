//
//  AccessoryViewController.m
//  EnochCar
//
//  Created by 王海燕 on 2021/5/12.
//

#import "AccessoryViewController.h"
#import "NetWorkAPIManager.h"
#import "GoodsTableViewCell.h"
#import "GoodsSearchTableViewCell.h"
#import "CreateAccessoryViewController.h"
#import "NotFoundView.h"
#import "LoadingView.h"
#import "NetWorkOffView.h"
#import "CommonTool.h"

#define TAG_TABLEVIEW_SEARCH 1
#define TAG_TABLEVIEW_SELECTED 2


@interface AccessoryViewController ()<UITextFieldDelegate,UITableViewDelegate, UITableViewDataSource,GoodsTableViewCellDelagate>
//@property(nonatomic,readwrite,strong)NSMutableArray * allGoods;
@property(nonatomic,readwrite,strong)NSMutableArray * searchGoods;
@property(nonatomic,readwrite,strong)NSMutableArray * selectGoods;//已选配件
@property(nonatomic,readwrite,strong)UIButton * confirmBtn;
@property(nonatomic,readwrite,strong)UITableView * dropTableView; //下拉选择框
@property(nonatomic,readwrite,strong)UITableView * selectTableView; //已选择配件列表
@property(nonatomic,readwrite,strong)UITextField * searchTF;

@property(nonatomic,readwrite,assign)NSInteger indexRow;//需要展开显示的行
@property(nonatomic,readwrite,assign)BOOL isSearchMode;//搜索模式显示搜索列表隐藏已选择配件列表
@property(nonatomic, readwrite, assign) CGRect  firstResponderRect;
@property(nonatomic,readwrite,assign)CGPoint originOffset;

@property(nonatomic,readwrite,strong)NotFoundView * notfoundView;
@property(nonatomic,readwrite,strong) LoadingView* loadingView;
@property(nonatomic,readwrite,strong) NetWorkOffView* netOffView;
@end

@implementation AccessoryViewController

-(instancetype)initWithData:(NSArray *)goods
{
    self = [super init];
    if (self) {
        _searchGoods = [NSMutableArray array];
        
        _selectGoods = [NSMutableArray array];
        
        for (NSDictionary * good in goods) {
            NSMutableDictionary * agood = [NSMutableDictionary dictionaryWithDictionary:good];
            [_selectGoods addObject:agood];
        }
        _indexRow = -1;
    }
    
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.midTitle = @"添加配件";
    
    [self queryGoodsBy:@""];
    
    _confirmBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 76, 32)];
    _confirmBtn.backgroundColor = [UIColor colorWithRed:233/255.0 green:236/255.0 blue:241/255.0 alpha:1];
    [_confirmBtn setTitle:[NSString stringWithFormat:@"确认(%d)",_selectGoods.count] forState:UIControlStateNormal];
    [_confirmBtn setTitleColor:[UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1] forState:UIControlStateNormal];
    _confirmBtn.titleLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightSemibold];
    [_confirmBtn addTarget:self action:@selector(confirm) forControlEvents:UIControlEventTouchUpInside];
    _confirmBtn.layer.cornerRadius = 2;
    [self setRightBtn:_confirmBtn];
    
    UIButton * addBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, (self.view.bounds.size.height - 74), self.view.bounds.size.width, 74)];
    [addBtn setTitle:@"新增配件" forState:UIControlStateNormal];
    addBtn.titleLabel.font = [UIFont systemFontOfSize:18 weight:UIFontWeightSemibold];
    [addBtn setTitleColor:[UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1] forState:UIControlStateNormal];
    addBtn.backgroundColor = [UIColor whiteColor];
    [addBtn addTarget:self action:@selector(addItem) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:addBtn];

    NSInteger left = 20;
    NSInteger top = 20;
    NSInteger space = 12;
    
    CGFloat searchY = [CommonTool topbarH] + top;
    
    UIView * searchView = [[UIView alloc] initWithFrame:CGRectMake(left, searchY, (self.view.bounds.size.width - 2*left), 36)];
    searchView.backgroundColor = [UIColor whiteColor];    
    searchView.layer.cornerRadius = 3;
    [self.view addSubview:searchView];
    
    UIImageView * searchIcon = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 40, 36)];
    [searchIcon setImage:[UIImage imageNamed:@"search"]];
    [searchView addSubview:searchIcon];
 
    _searchTF = [[UITextField alloc] initWithFrame:CGRectMake(searchIcon.frame.size.width, (searchView.frame.size.height - 26)/2, (searchView.bounds.size.width-searchIcon.frame.size.width-space), 26)];
    _searchTF.backgroundColor = [UIColor clearColor];
    _searchTF.font = [UIFont fontWithName:@"PingFang SC" size:14];
    _searchTF.layer.cornerRadius = 4;
    _searchTF.placeholder = @"请输入配件名称";
    _searchTF.delegate = self;
    _searchTF.returnKeyType = UIReturnKeySearch;
    [searchView addSubview:_searchTF];
    [_searchTF addTarget:self action:@selector(searchChanged:) forControlEvents:UIControlEventEditingChanged];
    
    NSInteger orgY = searchView.frame.origin.y + searchView.frame.size.height;
    
    _selectTableView = [[UITableView alloc] initWithFrame:CGRectMake(searchView.frame.origin.x, orgY + space, searchView.frame.size.width, (self.view.bounds.size.height-orgY - 2*space -addBtn.bounds.size.height))];
    _selectTableView.backgroundColor = [UIColor clearColor];
    _selectTableView.delegate = self;
    _selectTableView.dataSource = self;
    _selectTableView.delegate = self;
    _selectTableView.tag = TAG_TABLEVIEW_SELECTED;
    _selectTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _selectTableView.layer.cornerRadius = 4;
    _selectTableView.layer.masksToBounds = YES;
    _selectTableView.showsVerticalScrollIndicator = NO;
    _selectTableView.showsHorizontalScrollIndicator = NO;
    _selectTableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    [_selectTableView registerNib:[UINib nibWithNibName:@"GoodsTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"GoodsTableViewCell"];
    [self.view addSubview:_selectTableView];
    
    _dropTableView = [[UITableView alloc] initWithFrame:CGRectMake(searchView.frame.origin.x, orgY, searchView.frame.size.width, self.view.bounds.size.height-orgY - space - addBtn.bounds.size.height)];
    _dropTableView.backgroundColor = [UIColor clearColor];
    _dropTableView.delegate = self;
    _dropTableView.dataSource = self;
    _dropTableView.delegate = self;
    _dropTableView.tag = TAG_TABLEVIEW_SEARCH;
    _dropTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _dropTableView.layer.cornerRadius = 4;
    _dropTableView.showsVerticalScrollIndicator = NO;
    _dropTableView.showsHorizontalScrollIndicator = NO;
    _dropTableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    [_dropTableView registerClass:[GoodsSearchTableViewCell class] forCellReuseIdentifier:@"GoodsSearchTableViewCell"];
    [_dropTableView registerNib:[UINib nibWithNibName:@"GoodsSearchTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"GoodsSearchTableViewCell"];
    [self.view addSubview:_dropTableView];

    self.isSearchMode = NO;
}

-(NotFoundView*)notfoundView
{
    if (!_notfoundView) {
        _notfoundView = [[NotFoundView alloc] initWithFrame:CGRectMake(0, 0, self.dropTableView.frame.size.width, self.dropTableView.frame.size.height)];
    }
    return _notfoundView;
}

-(LoadingView*)loadingView
{
    if (!_loadingView) {
        _loadingView = [[LoadingView alloc] initWithFrame:CGRectMake(0, 0, self.dropTableView.frame.size.width, self.dropTableView.frame.size.height)];
    }
    return _loadingView;
}

-(NetWorkOffView*)netOffView
{
    if (!_netOffView) {
        _netOffView = [[NetWorkOffView alloc] initWithFrame:CGRectMake(0, 0, self.dropTableView.frame.size.width, self.dropTableView.frame.size.height) refreshBlock:^{
            [self queryGoodsBy:_searchTF.text];
        }];
    }
    return _netOffView;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self addNotifications];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self removeNotifications];
}

-(void)addNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

-(void)removeNotifications
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)setIsSearchMode:(BOOL)isSearchMode
{
    if (isSearchMode) {
        [self queryGoodsBy:_searchTF.text];
        _dropTableView.hidden = NO;
        _selectTableView.hidden = YES;
    }else{
        _dropTableView.hidden = YES;
        _selectTableView.hidden = NO;
    }
        
}

-(void)addItem
{
    CreateAccessoryViewController * createCtrl = [[CreateAccessoryViewController alloc] init];
    [self.navigationController pushViewController:createCtrl animated:YES];
    
}

-(void)confirm
{
    [self.curmaintance setValue:[NSArray arrayWithArray:_selectGoods] forKey:@"maintenanceGoods"];
    [self.delegate save:_selectGoods];
    [self.navigationController popViewControllerAnimated:YES];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger num = 0;
    if (tableView.tag == TAG_TABLEVIEW_SEARCH) {
        num = self.searchGoods.count;
    }else if (tableView.tag == TAG_TABLEVIEW_SELECTED) {
        num = self.selectGoods.count;
    }
    return num;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = 39;
    if (tableView.tag == TAG_TABLEVIEW_SELECTED){
        if (indexPath.row == _indexRow) {
            height = 149;
        }
    }
    return height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{

    if (tableView.tag == TAG_TABLEVIEW_SEARCH)
    {
        GoodsSearchTableViewCell *  cell= [tableView dequeueReusableCellWithIdentifier:@"GoodsSearchTableViewCell"];
        
        if (!cell)
        {
            [tableView registerNib:[UINib nibWithNibName:@"GoodsSearchTableViewCell" bundle:nil] forCellReuseIdentifier:@"GoodsSearchTableViewCell"];
            cell = [tableView dequeueReusableCellWithIdentifier:@"GoodsSearchTableViewCell"];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        [cell config:[self.searchGoods objectAtIndex:indexPath.row]];
     
        return cell;
        
    }else //if(tableView.tag == 2)
    {
        GoodsTableViewCell * cell= [tableView dequeueReusableCellWithIdentifier:@"GoodsTableViewCell"];
        
        if (!cell)
        {
            [tableView registerNib:[UINib nibWithNibName:@"GoodsTableViewCell" bundle:nil] forCellReuseIdentifier:@"GoodsTableViewCell"];
            cell = [tableView dequeueReusableCellWithIdentifier:@"GoodsTableViewCell"];
        }
        
        cell.delagate = self;
        cell.chargeMethods = self.chargeMethods;
        cell.navigationController = self.navigationController;
        [cell config:[self.selectGoods objectAtIndex:indexPath.row]];
        if (indexPath.row == _indexRow) {
            [cell setNeedExtand:YES];
        }else {
            [cell setNeedExtand:NO];
        }
        return cell;
    }
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView.tag == TAG_TABLEVIEW_SEARCH) {
        NSDictionary * aGood = [_searchGoods objectAtIndex:indexPath.row];
        NSMutableDictionary * aMaintanceGood = [NSMutableDictionary dictionary];
        NSMutableDictionary * specifications = [NSMutableDictionary dictionaryWithDictionary:[[aGood objectForKey:@"specifications"]firstObject]];
        [specifications setObject:aGood forKey:@"goods"];
        [aMaintanceGood setObject:specifications forKey:@"goodsSpecification"];
        [aMaintanceGood setObject:[NSNumber numberWithInt:0] forKey:@"planCount"];//默认0
        [aMaintanceGood setObject:[self.chargeMethods firstObject] forKey:@"chargingMethod"];
        [_selectGoods addObject:aMaintanceGood];
        [_selectTableView reloadData];
        self.isSearchMode = NO;
        [self selectChanged];
        _searchTF.text = @"";
        [_searchTF resignFirstResponder];
    }else if (tableView.tag == TAG_TABLEVIEW_SELECTED)
    {
        if (_indexRow == indexPath.row) {
            _indexRow = -1;
        }else {
            _indexRow = indexPath.row;
        }
        
        [_selectTableView reloadData];
    }
}

-(void)selectChanged
{
    [_confirmBtn setTitle:[NSString stringWithFormat:@"确认(%d)",_selectGoods.count] forState:UIControlStateNormal];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    self.isSearchMode = YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    self.isSearchMode = NO;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    self.isSearchMode = NO;
    return YES;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (tableView.tag) {
        case TAG_TABLEVIEW_SEARCH:
        {
            
        }
            break;
        case TAG_TABLEVIEW_SELECTED:
        {
            return YES;
        }
            break;
        default:
            break;
    }
    
    return NO;
}

- (NSArray*)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath
{

    UITableViewRowAction *deleteAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:@"删除" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {

        [_selectGoods removeObjectAtIndex:indexPath.row];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [_selectTableView reloadData];
            
        });
        [self selectChanged];
}];
    return @[deleteAction];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    editingStyle = UITableViewCellEditingStyleDelete;

}

-(void)searchChanged:(UITextField *)textfield
{
    [self queryGoodsBy:textfield.text];
}

-(void)queryGoodsBy:(NSString*)string
{
    __weak AccessoryViewController * weakself = self;
    [[NetWorkAPIManager defaultManager] queryGoods:string success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary * resp = responseObject;
        NSArray * array = [resp objectForKey:@"data"];
        [_searchGoods removeAllObjects];
        [_searchGoods addObjectsFromArray:array];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (weakself.searchGoods.count == 0) {
                [weakself.dropTableView addSubview:weakself.notfoundView];
            }else {
                if (_notfoundView) {
                    [_notfoundView removeFromSuperview];
                    _notfoundView = nil;
                }
                if (_netOffView) {
                    [_netOffView removeFromSuperview];
                    _netOffView = nil;
                }
                if (_loadingView) {
                    [_loadingView removeFromSuperview];
                    _loadingView = nil;
                }
                [weakself.dropTableView reloadData];
            }
        });

    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [weakself.dropTableView addSubview:weakself.netOffView];
    }];
    
    [self.dropTableView addSubview:self.loadingView];
}

-(void)tableviewCellBecomeFirstResponder:(CGRect)rect
{
    _firstResponderRect = rect;
}

#pragma --NSNotification
//键盘弹出后将视图向上移动
-(void)keyboardWillShow:(NSNotification *)notification
{
    NSDictionary *userInfo = [notification userInfo];
    CGRect KeyboardRect = [[userInfo objectForKey:@"UIKeyboardFrameEndUserInfoKey"]CGRectValue];
    NSInteger offset =  (_firstResponderRect.origin.y + _firstResponderRect.size.height) - KeyboardRect.origin.y + 12;
    if (offset > 0) {
        [UIView animateWithDuration:2 animations:^{
            _originOffset = self.selectTableView.contentOffset;
            [self.selectTableView setContentOffset:CGPointMake(_originOffset.x,_originOffset.y + offset)];
            
        }];
    }
  
}

//键盘退出后将视图恢复
-(void)keyboardWillHide:(NSNotification *)notification
{
    [self.selectTableView setContentOffset:_originOffset];
}


@end
