//
//  PickupView.m
//  EnochCar
//
//  Created by 王海燕 on 2021/5/19.
//

#import "PickupView.h"
#import "EditPlateNoViewController.h"
#import "MaintanceAndAccessoryViewController.h"
#import "PopViewController.h"
#import "NetWorkAPIManager.h"
#import "RecognizeViewController.h"
#import <SDWebImage/SDWebImage.h>
#import "QRCodeViewController.h"
#import "VideoViewController.h"
#import <AFNetworking/AFNetworking.h>
#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "VehicleBrandViewController.h"
#import <Photos/Photos.h>
#import "CommonTool.h"
#import "GlobalInfoManager.h"
#import "UIView+Hint.h"
#import "CommonTabView.h"
#import "ImageVideoViewCell.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "ComplexBox.h"
#import "CommonTextView.h"
#import "DataBase.h"
#import "TimePickerView.h"
#import "ImageViewController.h"
#import "OpenOrPutawayButton.h"

#define TAG_NAME 1
#define TAG_TEL 2
#define TAG_VIN 3
#define TAG_TYPE 4
#define TAG_MODEL 5
#define TAG_MILES 6
#define TAG_OILGAUGE 7
#define TAG_DESCRIPTION 8
#define TAG_REASON 9
#define TAG_REMARKS 10
#define TAG_CUSTOMTYPE 11
//settlement
#define TAG_Amount 21
#define TAG_Driver 22
#define TAG_Area 23
#define TAG_RiskTime 24
#define TAG_Certificate 25
#define TAG_Category 26
#define TAG_Company 27
#define TAG_IsDirect 28
#define TAG_LossAssessor 29
#define TAG_ClaimComment 30
#define TAG_LossComment 31
#define TAG_SettleTime 32

#define TAG_POPVIEW_SEVICECATEGORY   21
#define TAG_POPVIEW_VEHICLETYPE  22
#define TAG_POPVIEW_VEHICLEMODEL 23
#define TAG_POPVIEW_OIL          24
#define TAG_POPVIEW_DESCRIPTION  25
#define TAG_POPVIEW_REASON       26
#define TAG_POPVIEW_CUSTOMERTYPE  27
#define TAG_POPVIEW_IMAGEVIDEO  28
#define TAG_POPVIEW_Certificate  29
#define TAG_POPVIEW_Category  30
#define TAG_POPVIEW_Company  31
#define TAG_POPVIEW_IsDirect  32
#define TAG_POPVIEW_LossAssessor  33
#define TAG_POPVIEW_AddAccidentImage  34
#define TAG_POPVIEW_AddLossImage  35

#define TAG_TimePicker_RiskTime  51
#define TAG_TimePicker_SettleTime  52

#define TAG_ImageCtrl_AccidentImage 71
#define TAG_ImageCtrl_LossImage 72

//serviceAccidentSettlement
#define KEY_serviceAccidentSettlement_id @"id"
#define KEY_serviceAccidentSettlement_serialNo @"serialNo"
#define KEY_serviceAccidentSettlement_amount @"amount"
#define KEY_serviceAccidentSettlement_prove @"prove"
#define KEY_serviceAccidentSettlement_type @"type"
#define KEY_serviceAccidentSettlement_direct @"direct"
#define KEY_serviceAccidentSettlement_accidentImage @"accidentBookImgUrl"
#define KEY_serviceAccidentSettlement_damageImage @"damageOrderImgUrl"
#define KEY_serviceAccidentSettlement_claimsCompany @"claimsCompany"
#define KEY_serviceAccidentSettlement_riskSpot @"riskSpot"
#define KEY_serviceAccidentSettlement_riskDriver @"riskDriver"
#define KEY_serviceAccidentSettlement_accidentComment @"accidentComment"
#define KEY_serviceAccidentSettlement_vehicleComment @"vehicleComment"
#define KEY_serviceAccidentSettlement_riskDatetime @"riskDatetime"
#define KEY_serviceAccidentSettlement_settlingDatetime @"settlingDatetime"
#define KEY_serviceAccidentSettlement_settlingPerson @"settlingPerson"
#define KEY_serviceAccidentSettlement_settlingPersonTelephone @"settlingPersonTelephone"

#define BWFileBoundary @"----WebKitFormBoundaryzgyKnIGWKkZVQs0R"
#define BWNewLine @"\r\n"
#define BWEncode(str) [str dataUsingEncoding:NSUTF8StringEncoding]

#define DetailViewH 336  //车辆检查和添加图片页面的原始高度

typedef enum
{
    AddImageVideoToPickUP, //接车检查图片
    AddImageToAccidentBtn, //事故书
    AddImageToLossBtn //定损单
}AddImageVideoType;


@interface PickupView()<UITextFieldDelegate,UITabBarDelegate, PopViewDelagate,MaintanceAndAccessoryDelegate,VehicleBrandViewControllerDelegate,RecognizeViewControllerDelegate,CommonTabViewDelegate,UIImagePickerControllerDelegate,UITextViewDelegate,TimePickerDelegate,OpenOrPutawayButtonDelegate>
@property(nonatomic,readwrite,strong)NSMutableDictionary * ossSignature;
@property(nonatomic,readwrite,assign)PickupViewMode viewMode;

@property(nonatomic,readwrite,strong)UIButton * createVehicleBtn;
@property(nonatomic,readwrite,strong)UIView * platoNoView;
@property(nonatomic,readwrite,strong)UILabel * platoLab;
@property(nonatomic,readwrite,strong)UILabel * isOldLab;
@property(nonatomic,readwrite,strong)UIButton * wechatUnionBtn;
@property(nonatomic,readwrite,strong)UILabel * wechatUnionLab;
@property(nonatomic,readwrite,assign)BOOL isWechatUnion;

@property(nonatomic,readwrite,strong)UIView * centerView;
@property(nonatomic,readwrite,strong)ComplexBox * nameBox;
@property(nonatomic,readwrite,strong)ComplexBox * cellphoneBox;
@property(nonatomic,readwrite,strong)ComplexBox * vinBox;
@property(nonatomic,readwrite,strong)ComplexBox * typeBox;
@property(nonatomic,readwrite,strong)ComplexBox * modelBox;
//@property(nonatomic,readwrite,strong)ComplexBox * customTypeBox;

@property(nonatomic,readwrite,strong)UIButton * repairetypeBtn;
@property(nonatomic,readwrite,strong)UIButton * addMaintanceBtn;

@property(nonatomic,readwrite,strong)UIView * extandView;
@property(nonatomic,readwrite,strong)CommonTabView * tabbar;
@property(nonatomic,readwrite,strong)UIView * extandDetailView;

@property(nonatomic,readwrite,strong)UIView * vehicleView;
@property(nonatomic,readwrite,strong)UITextField * milesTF;
@property(nonatomic,readwrite,strong)UILabel * lastMilesLab;
@property(nonatomic,readwrite,strong)ComplexBox * oilgaugeBox;
@property(nonatomic,readwrite,strong)ComplexBox * descriptionBox;
@property(nonatomic,readwrite,strong)ComplexBox * reasonBox;
@property(nonatomic,readwrite,strong)UITextView *commentTV;
@property(nonatomic,readwrite,strong)UILabel *commentHolderLab;

@property(nonatomic,readwrite,strong)UIView * imagesView;
@property(nonatomic,readwrite,strong)UIView * imagesDetailView;
@property(nonatomic,readwrite,copy)NSMutableArray<ImageVideoItem*> * imageArray;//视频图片列表，保存url等数据

@property(nonatomic,readwrite,strong)UIView * accidentView;
@property(nonatomic,readwrite,strong)ComplexBox * settlementAmoutBox;//定损金额
@property(nonatomic,readwrite,strong)ComplexBox * settlementDriverBox;//出险驾驶员
@property(nonatomic,readwrite,strong)ComplexBox * settlementAreaBox;//出险地点
@property(nonatomic,readwrite,strong)ComplexBox * settlementRiskTimeBox;//出险时间
@property(nonatomic,readwrite,strong)ComplexBox * settlementDateTimeBox;//定损时间
@property(nonatomic,readwrite,strong)ComplexBox * settlementCertificateBox;//定责证明
@property(nonatomic,readwrite,strong)ComplexBox * settlementCategoryBox;//责任类别
@property(nonatomic,readwrite,strong)ComplexBox * settlementClaimsCompanyBox;//理赔公司
@property(nonatomic,readwrite,strong)ComplexBox * settlementIsDirectBox;//是否直赔
@property(nonatomic,readwrite,strong)ComplexBox * settlementLossAssessorBox;//定损员
@property(nonatomic,readwrite,strong)CommonTextView * settlementClaimCommentTV;//理赔备注
@property(nonatomic,readwrite,strong)CommonTextView * settlementLossCommentTV;//定损备注
@property(nonatomic,readwrite,strong)UIButton * addAccidentImageBtn;
@property(nonatomic,readwrite,strong)UIButton * addLossImageBtn;
@property(nonatomic,readwrite,strong)OpenOrPutawayButton * openOrPutawayBtnView; //收起/展开按钮
@property(nonatomic,readwrite,strong)NSMutableDictionary * serviceAccidentSettlement;//理赔信息

//需要向服务器请求查询得到的信息，只获取一次
@property(nonatomic,readwrite,copy)NSMutableArray * seviceCategorys;//维修类别列表
@property(nonatomic,readwrite,copy)NSMutableArray * vehicleTypes;//车型类型列表
@property(nonatomic,readwrite,copy)NSMutableArray * vehicleModels;//车型列表
@property(nonatomic,readwrite,copy)NSMutableArray * customerTypes;//客户类型列表
@property(nonatomic,readwrite,copy)NSMutableArray * remainOils;//剩余油量列表
@property(nonatomic,readwrite,copy)NSMutableArray * breakdownDescriptions;//故障描述列表
@property(nonatomic,readwrite,copy)NSMutableArray * breakdownReasons;//故障原因列表


@property(nonatomic,readwrite,copy)NSMutableDictionary * curCustomer;//当前客户
@property(nonatomic,readwrite,copy)NSMutableDictionary * curVehicle;//当前车辆
@property(nonatomic,readwrite,copy)NSMutableDictionary * curSevice;//当前订单

@property(nonatomic,readwrite,assign)  BOOL isOldCustomer;
@property(nonatomic,readwrite,assign)  BOOL canEditVehicleInfo;


@property(nonatomic,readwrite,assign)  AddImageVideoType addImageVideoType;
@end



@implementation PickupView


-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.bounces = NO;
        self.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
        
        NSInteger left = 20;
        NSInteger top = 25;
        NSInteger space = 12;//控件间隔
        NSInteger height = 36;//输入框高度
        
        [self initCenterView];
        
        _extandView = [[UIView alloc] initWithFrame:CGRectMake(0, (self.centerView.frame.origin.y + _centerView.bounds.size.height + 2*space), (self.bounds.size.width - 2*left), 58)];
        [self addSubview:_extandView];
            
        _extandDetailView = [[UIView alloc] initWithFrame:CGRectMake(left, (_extandView.frame.origin.y + _extandView.bounds.size.height+space), (self.bounds.size.width - 2*left),DetailViewH)];
        _extandDetailView.backgroundColor = [UIColor clearColor];
        _extandDetailView.hidden = YES;
        [self addSubview:_extandDetailView];
        
        [_extandDetailView addSubview:self.vehicleView];

        [_extandDetailView addSubview:self.imagesView];
        self.imagesView.hidden = YES;
        
        [_extandDetailView addSubview:self.accidentView];
        self.accidentView.hidden = YES;
        
        [_extandView addSubview:self.tabbar];
        
        self.contentSize = CGSizeMake(self.frame.size.width, 500);
        self.scrollEnabled = YES;
        self.showsVerticalScrollIndicator = NO;
        self.showsHorizontalScrollIndicator = NO;
        
        self.isOldCustomer = NO;
        
        _seviceCategorys = [NSMutableArray array];
        _vehicleTypes = [NSMutableArray array];
        _vehicleModels = [NSMutableArray array];
        _customerTypes = [NSMutableArray array];
        _remainOils = [NSMutableArray array];
        _breakdownDescriptions = [NSMutableArray array];
        _breakdownReasons = [NSMutableArray array];
        
        [_vinBox addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
        [_commentTV addObserver:self forKeyPath:@"text" options:NSKeyValueObservingOptionNew context:nil];
        
        [self getOSSSignature];
        [self queryVehicleType];
        [self queryVehicleModel];
        [self queryCustomerType];
        self.viewMode = PickupInitialMode;
        //  添加手势
        UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(taponbg:)];
        [self addGestureRecognizer:tap];
    }
    return self;
}

-(void)initCenterView
{
    NSInteger left = 20;
    NSInteger top = 25;
    NSInteger space = 12;//控件间隔
    NSInteger height = 36;//输入框高度
    
    _centerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 322)];
    [self addSubview:self.centerView];
    
    _createVehicleBtn = [[UIButton alloc] initWithFrame:CGRectMake(left, top, 163, height)];
    [_createVehicleBtn setTitle:@"新建车牌" forState:UIControlStateNormal];
    _createVehicleBtn.titleLabel.font = [UIFont fontWithName:@"PingFang SC" size:14];
    _createVehicleBtn.titleLabel.textColor = [UIColor whiteColor];
    _createVehicleBtn.layer.cornerRadius = 4;
    [_createVehicleBtn addTarget:self action:@selector(addVehicleBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    _createVehicleBtn.backgroundColor = [UIColor colorWithRed:59/255.0 green:66/255.0 blue:80/255.0 alpha:1];
    [_centerView addSubview:_createVehicleBtn];
    
    _platoNoView = [[UIView alloc] initWithFrame:CGRectMake(left, top -2 , 163, 57)];
    _platoNoView.hidden = YES;
    UILongPressGestureRecognizer * longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
    [_platoNoView addGestureRecognizer:longPress];
    [_centerView addSubview:_platoNoView];
    _platoLab = [[UILabel alloc] initWithFrame:CGRectMake(0, 4, 163, 25)];
    _platoLab.font = [UIFont systemFontOfSize:18 weight:UIFontWeightSemibold];
    _platoLab.textColor = [UIColor colorWithRed:3/255.0 green:28/255.0 blue:28/255.0 alpha:1];
    _platoLab.layer.cornerRadius = 4;
    _platoLab.backgroundColor = [UIColor clearColor];
    [_platoNoView addSubview:_platoLab];
    UITapGestureRecognizer * tapPlateNo = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapPlateNo:)];
    [_platoNoView addGestureRecognizer:tapPlateNo];
    
    _isOldLab = [[UILabel alloc] initWithFrame:CGRectMake(0, 38, 54, 19)];
    _isOldLab.backgroundColor = [UIColor colorWithRed:252/255.0 green:215/255.0 blue:139/255.0 alpha:1];
    _isOldLab.textColor = [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1];
    _isOldLab.text = @"新客户";
    _isOldLab.font = [UIFont fontWithName:@"PingFang SC" size:11];
    _isOldLab.layer.cornerRadius = 8;
    _isOldLab.layer.masksToBounds = YES;
    _isOldLab.textAlignment = NSTextAlignmentCenter;
    [_platoNoView addSubview:_isOldLab];
    
    UIImageView * wechatIcon = [[UIImageView alloc] initWithFrame:CGRectMake(_isOldLab.frame.origin.x + _isOldLab.frame.size.width + 12, _isOldLab.frame.origin.y + 2, 16, 16)];
    [wechatIcon setImage:[UIImage imageNamed:@"wechat_bind"]];
    [_platoNoView addSubview:wechatIcon];
    
    _wechatUnionLab = [[UILabel alloc] initWithFrame:CGRectMake(wechatIcon.frame.origin.x + wechatIcon.frame.size.width + 4, wechatIcon.frame.origin.y, 32, 16)];
    _wechatUnionLab.font = [UIFont fontWithName:@"PingFang SC" size:11];
    _wechatUnionLab.layer.cornerRadius = 4;
    _wechatUnionLab.backgroundColor = [UIColor clearColor];
    [_platoNoView addSubview:_wechatUnionLab];
    
    _wechatUnionBtn = [[UIButton alloc] initWithFrame:CGRectMake(_isOldLab.frame.origin.x, _isOldLab.frame.origin.y, _isOldLab.frame.size.width+wechatIcon.frame.size.width+_wechatUnionLab.frame.size.width+8, _isOldLab.frame.size.height)];
    [_wechatUnionBtn setBackgroundColor:[UIColor clearColor]];
    [_wechatUnionBtn addTarget:self action:@selector(bindWechat) forControlEvents:UIControlEventTouchUpInside];
    [_platoNoView addSubview:_wechatUnionBtn];

    _addMaintanceBtn = [[UIButton alloc] initWithFrame:CGRectMake((_centerView.bounds.size.width - 96 - left), 33, 96, height)];
    [_addMaintanceBtn setTitle:@"项目与配件" forState:UIControlStateNormal];
    _addMaintanceBtn.titleLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightSemibold];
    _addMaintanceBtn.layer.cornerRadius = 4;
    [_addMaintanceBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [_addMaintanceBtn addTarget:self action:@selector(addMaintance) forControlEvents:UIControlEventTouchUpInside];
    _addMaintanceBtn.backgroundColor = [UIColor whiteColor];
    [_centerView addSubview:_addMaintanceBtn];
     
    _nameBox = [[ComplexBox alloc] initWithFrame:CGRectMake(left, (_platoNoView.frame.origin.y+_platoNoView.frame.size.height + space),_platoNoView.frame.size.width, height) mode:ComplexBoxEdit];
    _nameBox.placeHolder = @"请输入姓名";
    _nameBox.delegate = self;
    _nameBox.tag = TAG_NAME;
    [_centerView addSubview:_nameBox];
    
    _cellphoneBox = [[ComplexBox alloc] initWithFrame:CGRectMake(_nameBox.frame.origin.x, (_nameBox.frame.origin.y+_nameBox.frame.size.height + space), _nameBox.frame.size.width, _nameBox.frame.size.height) mode:ComplexBoxEdit];
    _cellphoneBox.placeHolder = @"请输入手机号码";
    _cellphoneBox.delegate = self;
    _cellphoneBox.tag = TAG_TEL;
    [_centerView addSubview:_cellphoneBox];
    
    _repairetypeBtn = [[UIButton alloc] initWithFrame:CGRectMake((self.bounds.size.width - 148- left), _nameBox.frame.origin.y, 148, (_nameBox.frame.size.height + _cellphoneBox.frame.size.height + space))];
    [_repairetypeBtn setTitle:@"维修类别" forState:UIControlStateNormal];
    _repairetypeBtn.titleLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightSemibold];
    _repairetypeBtn.layer.cornerRadius = 4;
    [_repairetypeBtn setTitleColor:[UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1] forState:UIControlStateNormal];
    [_repairetypeBtn addTarget:self action:@selector(selectSeviceCategory) forControlEvents:UIControlEventTouchUpInside];
    _repairetypeBtn.backgroundColor = [UIColor whiteColor];
    [_centerView addSubview:_repairetypeBtn];
    
    __weak PickupView * weakself = self;
    
    _vinBox = [[ComplexBox alloc] initWithFrame:CGRectMake(_cellphoneBox.frame.origin.x, (_cellphoneBox.frame.origin.y+_cellphoneBox.frame.size.height + space), (self.bounds.size.width - 2*_cellphoneBox.frame.origin.x), _cellphoneBox.frame.size.height) mode:ComplexBoxEditAndSelect];
    _vinBox.placeHolder = @"请输入VIN码";
    _vinBox.delegate = self;
    _vinBox.tag = TAG_VIN;
    _vinBox.normalImageName = @"scanBtn";
    _vinBox.disabledImageName = @"scanBtn";
    _vinBox.selectBlock = ^{
        [weakself scan];
    };
    [_centerView addSubview:_vinBox];
    
    _modelBox = [[ComplexBox alloc] initWithFrame:CGRectMake(_vinBox.frame.origin.x, (_vinBox.frame.origin.y+_vinBox.frame.size.height + space), _vinBox.bounds.size.width, _vinBox.bounds.size.height) mode:ComplexBoxSelect];
    _modelBox.placeHolder = @"车品牌";
    _modelBox.delegate = self;
    _modelBox.tag = TAG_MODEL;
    _modelBox.selectBlock = ^{
        [weakself selectModel];
    };
    [_centerView addSubview:_modelBox];
    
    _typeBox = [[ComplexBox alloc] initWithFrame:CGRectMake(_modelBox.frame.origin.x, (_modelBox.frame.origin.y+_modelBox.frame.size.height + space), (self.bounds.size.width - 2*_modelBox.frame.origin.x), _modelBox.frame.size.height) mode:ComplexBoxSelect];
    _typeBox.placeHolder = @"车型类型选择";
    _typeBox.delegate = self;
    _typeBox.tag = TAG_TYPE;
    _typeBox.selectBlock = ^{
        
        [weakself selectVehicleType];
    };
    [_centerView addSubview:_typeBox];
}

-(CommonTabView *)tabbar
{
    if (!_tabbar) {
        CommonTabItem * item1 = [[CommonTabItem alloc] initWithImagename:@"addvehicle_unsel" selectedImage:@"addvehicle_sel"];
        CommonTabItem * item2 = [[CommonTabItem alloc] initWithImagename:@"addimage_unsel" selectedImage:@"addimage_sel"];
//        CommonTabItem * item3 = [[CommonTabItem alloc] initWithImagename:@"addAccident_unsel" selectedImage:@"addAccident_sel"];
        
        _tabbar = [[CommonTabView alloc] initWithFrame:CGRectMake(0, 0, 224, 58) target:self];
        [_tabbar setItems:@[item1,item2]];
        [_tabbar setIndex:0];
    }
    return _tabbar;
}

-(void)showAccidentSettlement
{
    CommonTabItem * item1 = [[CommonTabItem alloc] initWithImagename:@"addvehicle_unsel" selectedImage:@"addvehicle_sel"];
    CommonTabItem * item2 = [[CommonTabItem alloc] initWithImagename:@"addimage_unsel" selectedImage:@"addimage_sel"];
    CommonTabItem * item3 = [[CommonTabItem alloc] initWithImagename:@"addAccident_unsel" selectedImage:@"addAccident_sel"];
    
    NSInteger lastIndex = _tabbar.index;
//    _tabbar = [[CommonTabView alloc] initWithFrame:CGRectMake(0, 0, 336, 58) target:self];
    _tabbar.frame = CGRectMake(0, 0, 336, 58);
    [_tabbar setItems:@[item1,item2,item3]];
    [_tabbar setIndex:lastIndex];
}

-(void)hideAccidentSettlement
{
    CommonTabItem * item1 = [[CommonTabItem alloc] initWithImagename:@"addvehicle_unsel" selectedImage:@"addvehicle_sel"];
    CommonTabItem * item2 = [[CommonTabItem alloc] initWithImagename:@"addimage_unsel" selectedImage:@"addimage_sel"];
    NSInteger lastIndex = _tabbar.index;
//    _tabbar = [[CommonTabView alloc] initWithFrame:CGRectMake(0, 0, 224, 58) target:self];
    _tabbar.frame = CGRectMake(0, 0, 224, 58);
    [_tabbar setItems:@[item1,item2]];
    [_tabbar setIndex:0];
//    if (lastIndex > 1) {
//        [_tabbar setIndex:0];
//    }else {
//        [_tabbar setIndex:lastIndex];
//    }
}


-(UIView*)vehicleView
{
    if (!_vehicleView) {
        NSInteger left = 20;
        NSInteger top = 25;
        NSInteger space = 12;//控件间隔
        NSInteger height = 36;//输入框高度
        _vehicleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _extandDetailView.bounds.size.width, _extandDetailView.frame.size.height)];
        _vehicleView.backgroundColor = [UIColor clearColor];
        
        
        UIView * mileView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _vehicleView.bounds.size.width, height)];
        mileView.backgroundColor = [UIColor whiteColor];
        mileView.layer.cornerRadius = 4;
        [_vehicleView addSubview:mileView];
        
        _milesTF = [[UITextField alloc] initWithFrame:CGRectMake(space, 0, (mileView.bounds.size.width - 3* space)/2, height)];
        _milesTF.placeholder = @"公里数";
        _milesTF.backgroundColor = [UIColor clearColor];
        _milesTF.font = [UIFont fontWithName:@"PingFang SC" size:14];
        _milesTF.layer.cornerRadius = 4;
        [_milesTF setDelegate:self];
        _milesTF.keyboardType = UIKeyboardTypeNumberPad;
        _milesTF.tag = TAG_MILES;
        [mileView addSubview:_milesTF];
        
        _lastMilesLab = [[UILabel alloc] initWithFrame:CGRectMake((_milesTF.frame.origin.x + _milesTF.frame.size.width + space), _milesTF.frame.origin.y, _milesTF.frame.size.width, _milesTF.frame.size.height)];
        _lastMilesLab.font = [UIFont fontWithName:@"PingFang SC" size:14];
        _lastMilesLab.textColor = TEXT_COLOR;
//        _lastMilesLab.text = @"0km(上次)";//
        _lastMilesLab.backgroundColor = [UIColor clearColor];
        _lastMilesLab.textAlignment = NSTextAlignmentRight;
        _lastMilesLab.layer.cornerRadius = 4;
        [mileView addSubview:_lastMilesLab];
        
        _oilgaugeBox = [[ComplexBox alloc] initWithFrame:CGRectMake(mileView.frame.origin.x, (mileView.frame.origin.y+mileView.frame.size.height + space), mileView.bounds.size.width, mileView.bounds.size.height) mode:ComplexBoxSelect];
        _oilgaugeBox.placeHolder = @"油表";
        _oilgaugeBox.delegate = self;
        _oilgaugeBox.tag = TAG_OILGAUGE;
        __weak PickupView * weakself = self;
        _oilgaugeBox.selectBlock = ^{

            [weakself selectOilgauge];
        };
        [_vehicleView addSubview:_oilgaugeBox];
        
        _descriptionBox = [[ComplexBox alloc] initWithFrame:CGRectMake(_oilgaugeBox.frame.origin.x, (_oilgaugeBox.frame.origin.y+_oilgaugeBox.frame.size.height + space), _oilgaugeBox.bounds.size.width, _oilgaugeBox.bounds.size.height) mode:ComplexBoxEditAndSelect];
        _descriptionBox.placeHolder = @"故障描述";
        _descriptionBox.delegate = self;
        _descriptionBox.tag = TAG_DESCRIPTION;
        _descriptionBox.selectBlock = ^{

            [weakself selectDescription];
        };
        [_vehicleView addSubview:_descriptionBox];
        
        _reasonBox = [[ComplexBox alloc] initWithFrame:CGRectMake(_descriptionBox.frame.origin.x, (_descriptionBox.frame.origin.y+_descriptionBox.frame.size.height + space), _descriptionBox.bounds.size.width, _descriptionBox.bounds.size.height) mode:ComplexBoxEditAndSelect];
        _reasonBox.placeHolder = @"故障原因";
        _reasonBox.delegate = self;
        _reasonBox.tag = TAG_REASON;
        _reasonBox.selectBlock = ^{

            [weakself selectReason];
        };
        [_vehicleView addSubview:_reasonBox];
        
        UIView * commentView = [[UIView alloc] initWithFrame:CGRectMake(0, (_reasonBox.frame.origin.y + _reasonBox.bounds.size.height + space), _reasonBox.bounds.size.width, 144)];
        commentView.backgroundColor = [UIColor whiteColor];
        commentView.layer.cornerRadius = 4;
        [_vehicleView addSubview:commentView];
        
        UILabel * commentLab = [[UILabel alloc] initWithFrame:CGRectMake(12, 12, 100, 20)];
        commentLab.text = @"接车备注";
        commentLab.textColor = [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1];
        commentLab.font = [UIFont systemFontOfSize:14 weight:UIFontWeightMedium];
        [commentView addSubview:commentLab];
        
        _commentHolderLab = [[UILabel alloc] initWithFrame:CGRectMake(12, 40, 100, 17)];
        _commentHolderLab.text = @"输入内容...";
        _commentHolderLab.textColor = [UIColor colorWithRed:191/255.0 green:191/255.0 blue:191/255.0 alpha:1];
        _commentHolderLab.font = [UIFont systemFontOfSize:12];
        [commentView addSubview:_commentHolderLab];
        
        _commentTV = [[UITextView alloc] initWithFrame:CGRectMake(12, 36, commentView.bounds.size.width-24, 96)];
        _commentTV.backgroundColor = [UIColor clearColor];
        _commentTV.font = [UIFont systemFontOfSize:12];
        _commentTV.textColor = [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1];
        _commentTV.delegate = self;
        _commentTV.showsVerticalScrollIndicator = NO;
        [commentView addSubview:_commentTV];
    }
    return _vehicleView;
}

-(UIView*)imagesView
{
    if (!_imagesView) {
        
        NSInteger left = 20;
        NSInteger top = 25;
        NSInteger space = 12;//控件间隔
        NSInteger height = 36;//输入框高度
        
        _imagesView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _extandDetailView.bounds.size.width, _extandDetailView.frame.size.height)];
        UIButton * addImageBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 84, 84)];
        [addImageBtn addTarget:self action:@selector(addImageBtnClicked) forControlEvents:UIControlEventTouchUpInside];
        [addImageBtn setImage:[UIImage imageNamed:@"add2"] forState:UIControlStateNormal];
        addImageBtn.backgroundColor = [UIColor whiteColor];
        addImageBtn.layer.cornerRadius = 4;
        [_imagesView addSubview:addImageBtn];
        
        NSInteger imgDetailY = addImageBtn.frame.origin.y + addImageBtn.frame.size.height + space;
        
        _imagesDetailView = [[UIView alloc] initWithFrame:CGRectMake(0,imgDetailY, _imagesView.frame.size.width, _imagesView.frame.size.height - imgDetailY)];
        _imagesDetailView.backgroundColor = [UIColor clearColor];
        [_imagesView addSubview:_imagesDetailView];
    }
    return _imagesView;
}

-(UIView*)accidentView
{
    if (!_accidentView) {
        NSInteger left = 20;
        NSInteger top = 25;
        NSInteger space = 12;//控件间隔
        NSInteger height = 36;//输入框高度
        _accidentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _extandDetailView.bounds.size.width, 365)];

        __weak PickupView * weakself = self;
        
        _settlementAmoutBox = [[ComplexBox alloc] initWithFrame:CGRectMake(0, 0,_accidentView.frame.size.width, height) mode:ComplexBoxEdit];
        _settlementAmoutBox.placeHolder = @"定损金额";
        _settlementAmoutBox.delegate = self;
        _settlementAmoutBox.tag = TAG_Amount;
        _settlementAmoutBox.keyboardType = UIKeyboardTypeDecimalPad;
        [_accidentView addSubview:_settlementAmoutBox];
        
        _settlementClaimsCompanyBox = [[ComplexBox alloc] initWithFrame:CGRectMake(_settlementAmoutBox.frame.origin.x, (_settlementAmoutBox.frame.origin.y+_settlementAmoutBox.frame.size.height + space),_settlementAmoutBox.frame.size.width, height) mode:ComplexBoxSelect hint:@"SASCMC" popTitle:@"理赔公司"];
        _settlementClaimsCompanyBox.placeHolder = @"理赔公司";
        _settlementClaimsCompanyBox.delegate = self;
        _settlementClaimsCompanyBox.tag = TAG_Company;
//        _settlementClaimsCompanyBox.selectBlock = ^{
//            [weakself selectCompany];
//        };
        [_accidentView addSubview:_settlementClaimsCompanyBox];
        
        _settlementIsDirectBox = [[ComplexBox alloc] initWithFrame:CGRectMake(_settlementClaimsCompanyBox.frame.origin.x, (_settlementClaimsCompanyBox.frame.origin.y+_settlementClaimsCompanyBox.frame.size.height + space),_settlementClaimsCompanyBox.frame.size.width, height) mode:ComplexBoxSelect lookup:@"FLAG" popTitle:@"是否直赔"];
        _settlementIsDirectBox.placeHolder = @"是否直赔";
        _settlementIsDirectBox.delegate = self;
        _settlementIsDirectBox.tag = TAG_IsDirect;
        [_accidentView addSubview:_settlementIsDirectBox];
        
        _settlementLossAssessorBox = [[ComplexBox alloc] initWithFrame:CGRectMake(_settlementIsDirectBox.frame.origin.x, (_settlementIsDirectBox.frame.origin.y+_settlementIsDirectBox.frame.size.height + space),_settlementIsDirectBox.frame.size.width, height) mode:ComplexBoxSelect hint:@"SASSTP" popTitle:@"定损员"];
        _settlementLossAssessorBox.placeHolder = @"定损员";
        _settlementLossAssessorBox.delegate = self;
        _settlementLossAssessorBox.tag = TAG_LossAssessor;
        [_accidentView addSubview:_settlementLossAssessorBox];
        
        _settlementCertificateBox = [[ComplexBox alloc] initWithFrame:CGRectMake(_settlementLossAssessorBox.frame.origin.x, (_settlementLossAssessorBox.frame.origin.y+_settlementLossAssessorBox.frame.size.height + space),_settlementLossAssessorBox.frame.size.width, height) mode:ComplexBoxSelect lookup:@"ACSTPRV" popTitle:@"定责证明"];
        _settlementCertificateBox.placeHolder = @"定责证明";
        _settlementCertificateBox.delegate = self;
        _settlementCertificateBox.tag = TAG_Certificate;

        [_accidentView addSubview:_settlementCertificateBox];
        
        _settlementCategoryBox = [[ComplexBox alloc] initWithFrame:CGRectMake(_settlementCertificateBox.frame.origin.x, (_settlementCertificateBox.frame.origin.y+_settlementCertificateBox.frame.size.height + space),_settlementCertificateBox.frame.size.width, height) mode:ComplexBoxSelect lookup:@"ACSTDTTP" popTitle:@"责任类别"];
        _settlementCategoryBox.placeHolder = @"责任类别";
        _settlementCategoryBox.delegate = self;
        _settlementCategoryBox.tag = TAG_Category;
        [_accidentView addSubview:_settlementCategoryBox];
        
        _settlementRiskTimeBox = [[ComplexBox alloc] initWithFrame:CGRectMake(_settlementCategoryBox.frame.origin.x, (_settlementCategoryBox.frame.origin.y+_settlementCategoryBox.frame.size.height + space),_settlementCategoryBox.frame.size.width, height) mode:ComplexBoxSelect];
        _settlementRiskTimeBox.placeHolder = @"出险时间";
        _settlementRiskTimeBox.delegate = self;
        _settlementRiskTimeBox.tag = TAG_RiskTime;
        _settlementRiskTimeBox.selectBlock = ^{
            [weakself selectRiskTime];
        };
        [_accidentView addSubview:_settlementRiskTimeBox];
        
        _settlementDateTimeBox = [[ComplexBox alloc] initWithFrame:CGRectMake(_settlementRiskTimeBox.frame.origin.x, (_settlementRiskTimeBox.frame.origin.y+_settlementRiskTimeBox.frame.size.height + space),_settlementRiskTimeBox.frame.size.width, height) mode:ComplexBoxSelect];
        _settlementDateTimeBox.placeHolder = @"定损时间";
        _settlementDateTimeBox.delegate = self;
        _settlementDateTimeBox.tag = TAG_SettleTime;
        _settlementDateTimeBox.selectBlock = ^{
            [weakself selectSettleTime];
        };
        [_accidentView addSubview:_settlementDateTimeBox];

        _settlementDriverBox = [[ComplexBox alloc] initWithFrame:CGRectMake(_settlementDateTimeBox.frame.origin.x, (_settlementDateTimeBox.frame.origin.y+_settlementDateTimeBox.frame.size.height + space),_settlementDateTimeBox.frame.size.width, height) mode:ComplexBoxEdit];
        _settlementDriverBox.placeHolder = @"出险驾驶员";
        _settlementDriverBox.delegate = self;
        _settlementDriverBox.tag = TAG_Driver;
        [_accidentView addSubview:_settlementDriverBox];
        
        _settlementAreaBox = [[ComplexBox alloc] initWithFrame:CGRectMake(_settlementDriverBox.frame.origin.x, (_settlementDriverBox.frame.origin.y+_settlementDriverBox.frame.size.height + space),_settlementDriverBox.frame.size.width, height) mode:ComplexBoxEdit];
        _settlementAreaBox.placeHolder = @"出险地点";
        _settlementAreaBox.delegate = self;
        _settlementAreaBox.tag = TAG_Area;
        [_accidentView addSubview:_settlementAreaBox];
        
        _settlementClaimCommentTV= [[CommonTextView alloc] initWithFrame:CGRectMake(_settlementAreaBox.frame.origin.x, (_settlementAreaBox.frame.origin.y+_settlementAreaBox.frame.size.height + space),_settlementAreaBox.frame.size.width, 144) title:@"理赔备注" placeHolder:@"输入内容..."];
        _settlementClaimCommentTV.delegate = self;
        [_settlementClaimCommentTV setTextViewTag:TAG_ClaimComment];
        [_accidentView addSubview:_settlementClaimCommentTV];
        
        _settlementLossCommentTV = [[CommonTextView alloc] initWithFrame:CGRectMake(_settlementClaimCommentTV.frame.origin.x, (_settlementClaimCommentTV.frame.origin.y+_settlementClaimCommentTV.frame.size.height + space),_settlementClaimCommentTV.frame.size.width, 144) title:@"定损备注" placeHolder:@"输入内容..."];
        _settlementLossCommentTV.delegate = self;
        [_settlementLossCommentTV setTextViewTag:TAG_LossComment];
        [_accidentView addSubview:_settlementLossCommentTV];
        
        _addAccidentImageBtn = [[UIButton alloc] initWithFrame:CGRectMake(_settlementLossCommentTV.frame.origin.x, (_settlementLossCommentTV.frame.origin.y+_settlementLossCommentTV.frame.size.height + space), 84, 84)];
        [_addAccidentImageBtn addTarget:self action:@selector(addAccidentImageBtnClicked) forControlEvents:UIControlEventTouchUpInside];
        [_addAccidentImageBtn setImage:[UIImage imageNamed:@"accidentImage"] forState:UIControlStateNormal];
        _addAccidentImageBtn.layer.cornerRadius = 4;
        _addAccidentImageBtn.layer.masksToBounds = YES;
        [_accidentView addSubview:_addAccidentImageBtn];
        
        _addLossImageBtn = [[UIButton alloc] initWithFrame:CGRectMake(_addAccidentImageBtn.frame.origin.x + _addAccidentImageBtn.frame.size.width + space, _addAccidentImageBtn.frame.origin.y, _addAccidentImageBtn.frame.size.width, _addAccidentImageBtn.frame.size.height)];
        [_addLossImageBtn addTarget:self action:@selector(addLossImageBtnClicked) forControlEvents:UIControlEventTouchUpInside];
        [_addLossImageBtn setImage:[UIImage imageNamed:@"lossImage"] forState:UIControlStateNormal];
        _addLossImageBtn.layer.cornerRadius = 4;
        [_accidentView addSubview:_addLossImageBtn];
        _addLossImageBtn.layer.masksToBounds = YES;
        
        _openOrPutawayBtnView = [[OpenOrPutawayButton alloc] initWithFrame:CGRectMake(0, _accidentView.frame.size.height - 32 - 45, _accidentView.frame.size.width, 77) needOpen:NO];
        _openOrPutawayBtnView.backgroundColor = [UIColor colorWithRed:242/255.0 green:242/255.0 blue:242/255.0 alpha:1];
        _openOrPutawayBtnView.delegate = self;
        [_accidentView addSubview:_openOrPutawayBtnView];

    }
    return _accidentView;
}

-(void)addAccidentImageBtnClicked
{
    if (![self.serviceAccidentSettlement objectForKey:KEY_serviceAccidentSettlement_accidentImage]) {
        PopViewController * popCtrl = [[PopViewController alloc] initWithTitle:@"图片" Data:@[@"拍摄", @"从相册选择"]];
        popCtrl.delegate = self;
        popCtrl.view.tag = TAG_POPVIEW_AddAccidentImage;
        [popCtrl showIn:self.navCtrl];
    }else {
        //图片全屏显示
        ImageViewController * imageCtrl = [[ImageViewController  alloc] initWithUrlString:[self.serviceAccidentSettlement objectForKey:KEY_serviceAccidentSettlement_accidentImage] title:@"事故书"];
        imageCtrl.tag = TAG_ImageCtrl_AccidentImage;
//        imageCtrl.delegate = self;
        imageCtrl.deleteBlock = ^{
            [self.serviceAccidentSettlement removeObjectForKey:KEY_serviceAccidentSettlement_accidentImage];
            [self.addAccidentImageBtn setImage:[UIImage imageNamed:@"accidentImage"] forState:UIControlStateNormal];
        };
        [imageCtrl showOn:self.navCtrl];
    }
}

-(void)addLossImageBtnClicked
{
    if (![self.serviceAccidentSettlement objectForKey:KEY_serviceAccidentSettlement_damageImage]) {
        PopViewController * popCtrl = [[PopViewController alloc] initWithTitle:@"图片" Data:@[@"拍摄", @"从相册选择"]];
        popCtrl.delegate = self;
        popCtrl.view.tag = TAG_POPVIEW_AddLossImage;
        [popCtrl showIn:self.navCtrl];
    }else {
        //图片全屏显示
        ImageViewController * imageCtrl = [[ImageViewController  alloc] initWithUrlString:[self.serviceAccidentSettlement objectForKey:KEY_serviceAccidentSettlement_damageImage] title:@"定损单"];
        imageCtrl.tag = TAG_ImageCtrl_LossImage;
//        imageCtrl.delegate = self;
        imageCtrl.deleteBlock = ^{
            [self.serviceAccidentSettlement removeObjectForKey:KEY_serviceAccidentSettlement_damageImage];
            [self.addLossImageBtn setImage:[UIImage imageNamed:@"lossImage"] forState:UIControlStateNormal];
        };
        [imageCtrl showOn:self.navCtrl];
    }
    
}

-(NSMutableDictionary*)serviceAccidentSettlement
{
    if (!_serviceAccidentSettlement) {
        _serviceAccidentSettlement = [NSMutableDictionary dictionary];
    }
    return _serviceAccidentSettlement;
}


-(void)addNotification
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}
-(void)removeNotification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)keyboardWillShow:(NSNotification*)notification
{
    NSDictionary *userInfo = [notification userInfo];
    CGRect KeyboardRect = [[userInfo objectForKey:@"UIKeyboardFrameEndUserInfoKey"]CGRectValue];

    UIWindow * window=[[[UIApplication sharedApplication] delegate] window];
    CGRect rect = [self.firstResponderView convertRect: self.firstResponderView.bounds toView:window];
    NSInteger offset =  (rect.origin.y + rect.size.height) - KeyboardRect.origin.y + 12;
    _originOffset = self.contentOffset;
    if (offset > 0) {
        [UIView animateWithDuration:2 animations:^{
            [self setContentOffset:CGPointMake(_originOffset.x, _originOffset.y + offset)];
        }];
    }
}

-(void)keyboardWillHide:(NSNotification*)notification
{
    if (_firstResponderView) {
        [UIView animateWithDuration:2 animations:^{
            [self setContentOffset:_originOffset];
        }];
    }
    _firstResponderView = nil;
}

- (NSMutableDictionary *)curCustomer
{
    if (!_curCustomer) {
        _curCustomer = [NSMutableDictionary dictionary];
    }
    return _curCustomer;
}

- (NSMutableDictionary *)curVehicle
{
    if (!_curVehicle) {
        _curVehicle = [NSMutableDictionary dictionary];
    }
    return _curVehicle;
}

-(NSMutableDictionary *)curSevice 
{
    if (!_curSevice) {
        _curSevice = [NSMutableDictionary dictionary];
        NSDictionary * vehicle = [NSDictionary dictionaryWithObject:[self.curVehicle objectForKey:@"id"] forKey:@"id"];
        [_curSevice setValue:vehicle forKey:@"vehicle"];
        NSDictionary * owner = [self.curVehicle objectForKey:@"owner"];
        if (owner) {
            NSDictionary * customer = [NSDictionary dictionaryWithObject:[owner objectForKey:@"id"] forKey:@"id"];
            [_curSevice setValue:customer forKey:@"customer"];
        }
        NSDictionary * advisor = [NSDictionary dictionaryWithObject:[NSNumber numberWithInteger:[[GlobalInfoManager infoManager] getUserID]] forKey:@"id"];
        [_curSevice setValue:advisor forKey:@"advisor"];
        [_curSevice setValue:@"" forKey:@"settlementMethod"];//必需
        
        [_curSevice setValue:[NSMutableArray array] forKey:@"maintenances"];
        [_curSevice setValue:[NSDictionary dictionaryWithObject:@"IM" forKey:@"code"] forKey:@"nextStep"];
    }
    return _curSevice;
}

-(void)taponbg:(UIGestureRecognizer *)gesture
{
    [self resign];
}

-(void)resign
{
    UIWindow * keyWindow = [[UIApplication sharedApplication] keyWindow];
    UIView * firstResponder = [keyWindow performSelector:@selector(firstResponder)];
    [firstResponder resignFirstResponder];
}


-(void)tapPlateNo:(UIGestureRecognizer *)gesture
{
    if (self.isOldCustomer) {
        self.viewMode = PickupEditMode;
    }
}

-(void)setIsWechatUnion:(BOOL)isWechatUnion
{
    _isWechatUnion = isWechatUnion;
    if (_isWechatUnion) {
        self.wechatUnionLab.text = @"已绑";
    }else{
        self.wechatUnionLab.text = @"未绑";
    }
}

-(NSMutableArray *)imageArray
{
    if (!_imageArray) {
        _imageArray = [NSMutableArray array];
    }
    return _imageArray;
}

-(void)setViewMode:(PickupViewMode)viewMode
{
    _viewMode = viewMode;
    
    switch (_viewMode) {
        case PickupInitialMode:
        {
            [self clearData];
            _createVehicleBtn.hidden = NO;
            _platoNoView.hidden = YES;
            [self shouldVehicleInfoEnabled:YES];
            [self shouldSeviceInfoHide:YES];
        }
            break;
        case PickupCreateMode:
        {
//            _createVehicleBtn.hidden = YES;
//            _platoNoView.hidden = NO;
            [self shouldVehicleInfoEnabled:YES];
            [self shouldSeviceInfoHide:YES];
        }
            break;
        case PickupEditMode:
        {
//            _createVehicleBtn.hidden = YES;
//            _platoNoView.hidden = NO;
            [self clearSeviceData];
            [self shouldVehicleInfoEnabled:YES];
            [self shouldSeviceInfoHide:YES];
            
        }
            break;
        case PickupSeviceMode:
        {
//            _createVehicleBtn.hidden = YES;
//            _platoNoView.hidden = NO;
            [self shouldVehicleInfoEnabled:NO];
            [self shouldSeviceInfoHide:NO];
        }
            break;
            
        default:
            break;
    }
    
    if ([self.delegate respondsToSelector:@selector(PickUpViewModeChanged:)]) {
        [self.delegate PickUpViewModeChanged:_viewMode];
    }
    [self resizeContentView];
}

-(void)shouldVehicleInfoEnabled:(BOOL)enabled
{
    _nameBox.enabled = enabled;
    _cellphoneBox.enabled = enabled;
    _vinBox.enabled = enabled;
    _typeBox.enabled = enabled;
    _modelBox.enabled = enabled;
//    _customTypeBox.enabled = enabled;
}

-(void)shouldSeviceInfoHide:(BOOL)hide
{
    _addMaintanceBtn.hidden = hide;
    _repairetypeBtn.hidden = hide;
    _extandView.hidden = hide;
    _extandDetailView.hidden = hide;
}

-(void)bindWechat
{
    __weak PickupView * weakself = self;
    NSDictionary * owner = [self.curVehicle objectForKey:@"owner"];
    NSString * wechatUnionId = [owner objectForKey:@"wechatUnionId"];
    if (self.isWechatUnion) {
        //已绑定
    }else {
        //未绑定，显示二维码
        [[NetWorkAPIManager defaultManager] queryWechatBindUrl:[[owner objectForKey:@"id"] integerValue] success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            NSDictionary * resp = responseObject;
            NSString * url = [[resp objectForKey:@"data"] firstObject];

            dispatch_async(dispatch_get_main_queue(), ^{
                QRCodeViewController * QRCodeCTrl = [[QRCodeViewController alloc] initWithURL:url];
                [weakself.navCtrl addChildViewController:QRCodeCTrl];
                [weakself.navCtrl.view addSubview:QRCodeCTrl.view];
            });
            
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {

        }];
    }
    
}

-(void)setIsOldCustomer:(BOOL)isOldCustomer
{
    _isOldCustomer = isOldCustomer;
    if (_isOldCustomer) {
        
        _isOldLab.text = @"老客户";
        [_tabbar setIndex:0];
    }else{
        _isOldLab.text = @"新客户";
    }
    
}

-(void)setCanEditVehicleInfo:(BOOL)canEditVehicleInfo
{
    _canEditVehicleInfo = canEditVehicleInfo;
    if (_canEditVehicleInfo)
    {
        _nameBox.enabled = YES;
        _cellphoneBox.enabled = YES;
        _vinBox.enabled = YES;
        _typeBox.enabled = YES;
        _modelBox.enabled = YES;
//        _customTypeBox.enabled = YES;
        
    }else
    {
        _nameBox.enabled = NO;
        _cellphoneBox.enabled = NO;
        _vinBox.enabled = NO;
        _typeBox.enabled = NO;
        _modelBox.enabled = NO;
//        _customTypeBox.enabled = NO;
    }
}

-(void)saveServiceAccidentSettlement
{
    //settlement
    [self.serviceAccidentSettlement setValue:[NSNumber numberWithFloat:[self.settlementAmoutBox getText].floatValue] forKey:KEY_serviceAccidentSettlement_amount];
    [self.serviceAccidentSettlement setValue:[self.settlementDriverBox getText] forKey:KEY_serviceAccidentSettlement_riskDriver];
    [self.serviceAccidentSettlement setValue:[self.settlementAreaBox getText] forKey:KEY_serviceAccidentSettlement_riskSpot];
    [self.serviceAccidentSettlement setValue:[self.settlementClaimCommentTV getText] forKey:KEY_serviceAccidentSettlement_accidentComment];
    [self.serviceAccidentSettlement setValue:[self.settlementLossCommentTV getText] forKey:KEY_serviceAccidentSettlement_vehicleComment];
    [self.serviceAccidentSettlement setValue:[self.settlementCertificateBox getSelectedItem] forKey:KEY_serviceAccidentSettlement_prove];
    [self.serviceAccidentSettlement setValue:[self.settlementCategoryBox getSelectedItem] forKey:KEY_serviceAccidentSettlement_type];
    [self.serviceAccidentSettlement setValue:[self.settlementIsDirectBox getSelectedItem] forKey:KEY_serviceAccidentSettlement_direct];
    [self.serviceAccidentSettlement setValue:[self.settlementClaimsCompanyBox getText] forKey:KEY_serviceAccidentSettlement_claimsCompany];
    [self.serviceAccidentSettlement setValue:[self.settlementLossAssessorBox getText] forKey:KEY_serviceAccidentSettlement_settlingPerson];
}

//保存上一次未完成的信息
-(void)saveLastSeviceInfo
{
    if (_curSevice) {
        NSInteger mileage = [_milesTF.text integerValue];
        [self.curSevice setValue:[NSNumber numberWithInteger:mileage] forKey:@"currentMileage"];
        NSString * description = @"";
        if ([self.descriptionBox getText]) {
            description = [self.descriptionBox getText];
        }
        [self.curSevice setValue:[NSArray arrayWithObject:description] forKey:@"descriptions"];
        NSString * solution = @"";
        if ([self.reasonBox getText]) {
            solution = [self.reasonBox getText];
        }
        [self.curSevice setValue:solution forKey:@"solution"];
        [self.curSevice setValue:_commentTV.text forKey:@"comment"];
        
        [self saveServiceAccidentSettlement];
        [self.curSevice setValue:self.serviceAccidentSettlement forKey:@"serviceAccidentSettlement"];
        
        [[DataBase defaultDataBase] openSeviceList];
        
        if([[DataBase defaultDataBase] getSeviceInfoBy:[[self.curVehicle objectForKey:@"id"] integerValue]]){
            [[DataBase defaultDataBase] updateASevice:[[self.curVehicle objectForKey:@"id"] integerValue]  seviceInfo:self.curSevice];
        }else {
            [[DataBase defaultDataBase] insertAService:[[self.curVehicle objectForKey:@"id"] integerValue] seviceInfo:self.curSevice];
        }
    }
}

//查询上一次未完成的信息
-(NSDictionary *)getLastSeviceInfo:(NSInteger)vehicleID
{
    [[DataBase defaultDataBase] openSeviceList];
    return [[DataBase defaultDataBase] getSeviceInfoBy:vehicleID];
}

//清除上一次的信息
-(void)clearData
{
    [self clearVehicleData];
    [self clearSeviceData];
    [self hideAccidentSettlement];
}

//清除客户和车辆信息
-(void)clearVehicleData
{
    self.curVehicle = nil;
    self.curCustomer = nil;
    _platoLab.text = @"";
    _nameBox.text = @"";
    _cellphoneBox.text = @"";
    _vinBox.text = @"";
//    _customTypeBox.text = @"";
    _modelBox.text = @"";
    _typeBox.text = @"";
}

//清除要创建的工单信息
-(void)clearSeviceData
{
    self.curSevice = nil;
    self.serviceAccidentSettlement = nil;
    [_repairetypeBtn setTitle:@"维修类别" forState:UIControlStateNormal];
    _milesTF.text = @"";
    _oilgaugeBox.text = @"";
    _descriptionBox.text = @"";
    _reasonBox.text = @"";
    _commentTV.text = @"";
    
    
    [_imageArray removeAllObjects];
    for (UIView * view in self.imagesDetailView.subviews) {
        [view removeFromSuperview];
    }
    
    [_settlementAmoutBox setText:@""];
    [_settlementDriverBox setText:@""];
    [_settlementAreaBox setText:@""];
    [_settlementRiskTimeBox setText:@""];
    [_settlementDateTimeBox setText:@""];
    [_settlementCertificateBox setText:@""];
    [_settlementCategoryBox setText:@""];
    [_settlementClaimsCompanyBox setText:@""];
    [_settlementIsDirectBox setText:@""];
    [_settlementLossAssessorBox setText:@""];
    [_settlementLossCommentTV setText:@""];
    [_settlementClaimCommentTV setText:@""];
    [_addAccidentImageBtn setImage:[UIImage imageNamed:@"accidentImage"] forState:UIControlStateNormal];
    [_addLossImageBtn setImage:[UIImage imageNamed:@"lossImage"] forState:UIControlStateNormal];
    
}



//(快速搜索，扫描，修改车牌号)传进来的用户信息，需要查询是否老用户（这里与查询的用户详情信息字段不同，分开处理）
-(void)configData:(NSDictionary *)data
{
    if (self.curVehicle && [self.curVehicle objectForKey:@"id"]) {
        [self saveLastSeviceInfo];
    }
    
    [self clearData];
    
    self.viewMode = PickupCreateMode;
    
    NSString * plateNo = [data objectForKey:@"plateNo"];
    NSString * vin = [data objectForKey:@"vin"];
    NSString * name= [data objectForKey:@"ownerName"];
    NSString * cellphone = [data objectForKey:@"cellphone"];
    NSString * vehicleTypeStr = [data objectForKey:@"type"];
    NSString * wechatUnionId = [data objectForKey:@"wechatUnionId"];
    NSString * vehicleSpec = [data objectForKey:@"vehicleSpec"];
    
    //各字段与搜索结果数据字段一致
    if (plateNo) {
        _createVehicleBtn.hidden = YES;
        _platoNoView.hidden = NO;
        NSString * spacePlateNo = [CommonTool getPlateNoSpaceString:plateNo];
        _platoLab.text = spacePlateNo;
    }else{
        _createVehicleBtn.hidden = NO;
        _platoNoView.hidden = YES;
    }
    if (vin) {
        vin = [CommonTool getVinSpaceString:vin];
    }
    
    NSDictionary * vehicleType = [self getVehicleTypeByString:vehicleTypeStr];
    if (vehicleType ) {
        vehicleTypeStr = [vehicleType objectForKey:@"name"];
    }else {
        vehicleTypeStr = @"";
    }

    if (!wechatUnionId || wechatUnionId.length < 1) {
        self.isWechatUnion = FALSE;
    }else {
        self.isWechatUnion = TRUE;
    }
    _nameBox.text = name;
    
    _vinBox.text = vin;
    _cellphoneBox.text = cellphone;
    _typeBox.text = vehicleTypeStr;
    _modelBox.text = vehicleSpec;
//    _customTypeBox.text = @"";
    
    if (vehicleSpec) {
        [self.curVehicle setValue:[NSArray arrayWithObject:vehicleSpec] forKey:@"vehicleSpec"];
    }
    
    //扫描行驶证结果
    [self.curVehicle setValue:[data objectForKey:@"driverLicenceFirstUrls"] forKey:@"driverLicenceFirstUrls"];
    [self.curVehicle setValue:[data objectForKey:@"engineNumber"] forKey:@"engineNumber"];
    [self.curVehicle setValue:[data objectForKey:@"purchasingDate"] forKey:@"purchasingDate"];
//    [parm setValue:[data objectForKey:@"address"] forKey:@"address"];
    [self.curCustomer setValue:[data objectForKey:@"address"] forKey:@"address"];
    
    for (NSDictionary * dic in _customerTypes) {
        if ([[dic objectForKey:@"message"] isEqualToString:@"顾客"]) {
//            _customTypeBox.text = [dic objectForKey:@"message"];
            [self.curCustomer setValue:dic forKey:@"type"];
        }
    }
   
    [self queryInfoWithPlateNo:plateNo];
}

//查询后的用户详情信息显示
-(void)setupData:(NSDictionary*)data
{
    [self clearData];
    _curVehicle = [NSMutableDictionary  dictionaryWithDictionary:data];
    
    NSString * plateNo = [data objectForKey:@"plateNo"];
    if (plateNo) {
        _platoLab.text = [CommonTool getPlateNoSpaceString:plateNo];
    }else{
        _platoLab.text = @"";
    }
    
    NSString * vin = [data objectForKey:@"vin"];
    if (vin) {
        vin = [CommonTool getVinSpaceString:vin];
    }
    _vinBox.text = vin;
    
    _typeBox.text = [[data objectForKey:@"type"] objectForKey:@"name"];
    NSArray * vehicleSpec = [data objectForKey:@"vehicleSpec"];
    NSString * modelStr = @"";
    for (int i = 0;i <vehicleSpec.count;i++) {
        modelStr = [modelStr stringByAppendingString:[vehicleSpec objectAtIndex:i]];
        if (0 == i) {
            modelStr = [modelStr stringByAppendingString:@"/"];
        }
    }
    _modelBox.text = modelStr;
    
    NSDictionary * owner = [data objectForKey:@"owner"];
    if (owner) {
        _curCustomer = [NSMutableDictionary dictionaryWithDictionary:owner];
//        _customTypeBox.text = [[owner objectForKey:@"type"] objectForKey:@"message"];
        _nameBox.text = [owner objectForKey:@"name"];
        _cellphoneBox.text = [owner objectForKey:@"cellphone"];
        NSString * wechatUnionId = [owner objectForKey:@"wechatUnionId"];
        if (!wechatUnionId || wechatUnionId.length < 1) {
            self.isWechatUnion = FALSE;
        }else {
            self.isWechatUnion = TRUE;
        }
        //绑定车主算老用户
        self.isOldCustomer  = YES;
        self.viewMode = PickupSeviceMode;
    }else {
        //未绑定车主算新用户
        self.isOldCustomer  = NO;
        self.viewMode = PickupCreateMode;
    }
    
    //上一次输入信息展示
    [self curSevice];
    NSDictionary * sevice = [self getLastSeviceInfo:[[_curVehicle objectForKey:@"id"] integerValue]];
    if (sevice) {
        NSNumber * currentMileage = [sevice objectForKey:@"currentMileage"];
        if (currentMileage) {
            self.milesTF.text = [NSString stringWithFormat:@"%@",currentMileage];
        }
        
        NSDictionary * remainingOil = [sevice objectForKey:@"remainingOil"];
        if (remainingOil) {
            _oilgaugeBox.text = [remainingOil objectForKey:@"message"];
            [self.curSevice setValue:remainingOil forKey:@"remainingOil"];
        }
        
        NSString * solution = [sevice objectForKey:@"solution"];
        if (solution) {
            [self.reasonBox setText:solution];
        }

        NSArray * descriptions = [sevice objectForKey:@"descriptions"];
        if (descriptions) {
            [self.descriptionBox setText:[descriptions firstObject]];
        }
        
        NSString * comment = [sevice objectForKey:@"comment"];
        if (comment) {
            [self.commentTV setText:comment];
        }
        
        NSArray * maintenances = [sevice objectForKey:@"maintenances"];
        if (maintenances) {
            [self.curSevice setValue:[NSMutableArray arrayWithArray:maintenances] forKey:@"maintenances"];
        }
        
        NSDictionary * serviceCategory = [sevice objectForKey:@"serviceCategory"];
        if (serviceCategory) {
            [_repairetypeBtn setTitle:[serviceCategory objectForKey:@"name"] forState:UIControlStateNormal];
            [self.curSevice setValue:[NSMutableDictionary dictionaryWithDictionary:serviceCategory] forKey:@"serviceCategory"];
            
            if ([[serviceCategory objectForKey:@"name"] isEqualToString:@"事故维修"]) {
                self.serviceAccidentSettlement = [NSMutableDictionary dictionaryWithDictionary:[sevice objectForKey:@"serviceAccidentSettlement"]];
                [self showAccidentSettlement];
                [self setupServiceAccidentSettlementInfo:self.serviceAccidentSettlement];
                
            }else {
                [self hideAccidentSettlement];
            }
        }
        
        NSArray * serviceVehicleImgUrls = [sevice objectForKey:@"serviceVehicleImgUrls"];
        if (serviceVehicleImgUrls) {
            [self.curSevice setValue:[NSMutableArray arrayWithArray:serviceVehicleImgUrls] forKey:@"serviceVehicleImgUrls"];
            [self layoutImageView];
        }

    }
}

-(void)setupServiceAccidentSettlementInfo:(NSMutableDictionary *)serviceAccidentSettlement
{
    NSNumber * amount = [serviceAccidentSettlement objectForKey:KEY_serviceAccidentSettlement_amount];
    if(amount){
        [self.settlementAmoutBox setText:[NSString stringWithFormat:@"%@",amount]];
    }
    
    NSString * riskDriver = [serviceAccidentSettlement objectForKey:KEY_serviceAccidentSettlement_riskDriver];
    if(riskDriver){
        [self.settlementDriverBox setText:riskDriver];
    }
    
    NSString * riskSpot = [serviceAccidentSettlement objectForKey:KEY_serviceAccidentSettlement_riskSpot];
    if(riskSpot){
        [self.settlementAreaBox setText:riskSpot];
    }
    
    NSString * riskDatetime = [serviceAccidentSettlement objectForKey:KEY_serviceAccidentSettlement_riskDatetime];
    if(riskDatetime){
        [self.settlementRiskTimeBox setText:riskDatetime];
    }
    
    NSString * settlingDatetime = [serviceAccidentSettlement objectForKey:KEY_serviceAccidentSettlement_settlingDatetime];
    if(settlingDatetime){
        [self.settlementDateTimeBox setText:settlingDatetime];
    }
    
    NSDictionary * prove = [serviceAccidentSettlement objectForKey:KEY_serviceAccidentSettlement_prove];
    if(prove){
        [self.settlementCertificateBox setText:[prove objectForKey:@"message"]];
    }
    
    NSDictionary * type = [serviceAccidentSettlement objectForKey:KEY_serviceAccidentSettlement_type];
    if(type){
        [self.settlementCategoryBox setText:[type objectForKey:@"message"]];
    }
    
    NSString * claimsCompany = [serviceAccidentSettlement objectForKey:KEY_serviceAccidentSettlement_claimsCompany];
    if(claimsCompany){
        [self.settlementClaimsCompanyBox setText:claimsCompany];
    }
    
    NSDictionary * direct = [serviceAccidentSettlement objectForKey:KEY_serviceAccidentSettlement_direct];
    if(direct){
        [self.settlementIsDirectBox setText:[direct objectForKey:@"message"]];
    }
    
    NSString * settlingPerson = [serviceAccidentSettlement objectForKey:KEY_serviceAccidentSettlement_settlingPerson];
    if(settlingPerson){
        [self.settlementLossAssessorBox setText:settlingPerson];
    }
    
    NSString * accidentComment = [serviceAccidentSettlement objectForKey:KEY_serviceAccidentSettlement_accidentComment];
    if(accidentComment){
        [self.settlementClaimCommentTV setText:accidentComment];
    }
    
    NSString * vehicleComment = [serviceAccidentSettlement objectForKey:KEY_serviceAccidentSettlement_vehicleComment];
    if(vehicleComment){
        [self.settlementLossCommentTV setText:vehicleComment];
    }
    
    NSString * accidentBookImgUrl = [serviceAccidentSettlement objectForKey:KEY_serviceAccidentSettlement_accidentImage];
    if(accidentBookImgUrl){
        [self.addAccidentImageBtn sd_setImageWithURL:[NSURL URLWithString:accidentBookImgUrl] forState:UIControlStateNormal];
    }
    
    NSString * damageOrderImgUrl = [serviceAccidentSettlement objectForKey:KEY_serviceAccidentSettlement_damageImage];
    if(damageOrderImgUrl){
        [self.addLossImageBtn sd_setImageWithURL:[NSURL URLWithString:damageOrderImgUrl] forState:UIControlStateNormal];
    }
    
}


- (void)scan
{
    RecognizeViewController * recognizeCtrl = [[RecognizeViewController alloc] initWithType:RecognizeTypeVIN];
    recognizeCtrl.delegate = self;
    [self.navCtrl pushViewController:recognizeCtrl animated:YES];
}

-(void)longPress:(UIGestureRecognizer*)gesture
{
    if (gesture.state == UIGestureRecognizerStateEnded )
    {
        [self showEditPlateNoView];
    }
}
-(void)addVehicleBtnClicked
{
    [self showEditPlateNoView];
}

- (void)showEditPlateNoView
{
    EditPlateNoViewController * editNoVC = [[EditPlateNoViewController alloc] init];
    [self.navCtrl pushViewController:editNoVC animated:YES];
}

-(void)selectSeviceCategory
{
    [self resign];
    [[NetWorkAPIManager defaultManager] querySeviceCategorysuccess:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSDictionary * resp = responseObject;
        NSArray * array = [resp objectForKey:@"data"];
        
        [self.seviceCategorys removeAllObjects];
        [self.seviceCategorys addObjectsFromArray:array];
        
        NSMutableArray * popStrings = [NSMutableArray array];
        for (NSDictionary * dic in array) {
            [popStrings addObject:[dic objectForKey:@"name"]];
        }
        PopViewController * popCtrl = [[PopViewController alloc] initWithTitle:@"维修类别" Data:popStrings];
        popCtrl.delegate = self;
        popCtrl.view.tag = TAG_POPVIEW_SEVICECATEGORY;
        [self.navCtrl addChildViewController:popCtrl];
        [self.navCtrl.view addSubview:popCtrl.view];
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {

    }];
    
}

-(void)selectModel
{
    [self resign];
    VehicleBrandViewController * brandCtrl = [[VehicleBrandViewController alloc] initWithBrands:_vehicleModels];
    brandCtrl.delegate = self;
    [self.navCtrl addChildViewController:brandCtrl];
    [self.navCtrl.view addSubview:brandCtrl.view];
}

-(void)queryVehicleModel
{
    __weak PickupView * weakself = self;
    
    [[NetWorkAPIManager defaultManager] queryVehicleBrandsuccess:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary * resp = responseObject;
        NSArray * array = [resp objectForKey:@"data"];
        [_vehicleModels removeAllObjects];
        [_vehicleModels addObjectsFromArray:array];

    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
    }];
}

//
-(void)queryCustomerType
{
    __weak PickupView * weakself = self;
    
    [[NetWorkAPIManager defaultManager] lookup:@"CUSTTYPE" success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSDictionary * resp = responseObject;
        NSArray * array = [resp objectForKey:@"data"];
        [_customerTypes removeAllObjects];
        [_customerTypes addObjectsFromArray:array];
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
    }];
}

-(void)selectVehicleType
{
    [self resign];
    NSMutableArray * popStrings = [NSMutableArray array];
    
    for (NSDictionary * ainfo in _vehicleTypes) {
        NSString * str = [ainfo objectForKey:@"name"];
        [popStrings addObject:str];
    }
    
    PopViewController * popCtrl = [[PopViewController alloc] initWithTitle:@"车型类型" Data:popStrings];
    popCtrl.delegate = self;
    popCtrl.view.tag = TAG_POPVIEW_VEHICLETYPE;
    [self.navCtrl addChildViewController:popCtrl];
    [self.navCtrl.view addSubview:popCtrl.view];
}

-(void)selectCustomType
{
    [self resign];
    NSMutableArray * popStrings = [NSMutableArray array];
    
    for (NSDictionary * ainfo in _customerTypes) {
        NSString * str = [ainfo objectForKey:@"message"];
        [popStrings addObject:str];
    }
    
    PopViewController * popCtrl = [[PopViewController alloc] initWithTitle:@"客户类型" Data:popStrings];
    popCtrl.delegate = self;
    popCtrl.view.tag = TAG_POPVIEW_CUSTOMERTYPE;
    [self.navCtrl addChildViewController:popCtrl];
    [self.navCtrl.view addSubview:popCtrl.view];
}

-(void)queryVehicleType
{
    [[NetWorkAPIManager defaultManager] queryVehicleTypesuccess:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary * dic = responseObject;
        NSArray * array = [dic objectForKey:@"data"];
        [_vehicleTypes removeAllObjects];
        [_vehicleTypes addObjectsFromArray:array];
     
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
    }];
    
}

-(void)selectOilgauge
{
    [self resign];
    [[NetWorkAPIManager defaultManager] lookup:@"RMGOIL" success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary * dic = responseObject;
        NSArray * array = [dic objectForKey:@"data"];
        [self.remainOils removeAllObjects];
        [self.remainOils addObjectsFromArray:array];
        NSMutableArray * popStrings = [NSMutableArray array];
        for (NSDictionary * ainfo in array) {
            NSString * str = [ainfo objectForKey:@"message"];
            [popStrings addObject:str];
        }
        PopViewController * popCtrl = [[PopViewController alloc] initWithTitle:@"剩余油量" Data:popStrings];
        popCtrl.delegate = self;
        popCtrl.view.tag = TAG_POPVIEW_OIL;
        [self.navCtrl addChildViewController:popCtrl];
        [self.navCtrl.view addSubview:popCtrl.view];
    
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
    }];
}

-(void)selectDescription
{
    [self resign];
    [[NetWorkAPIManager defaultManager]  hint:@"SERVDESC" success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary * dic = responseObject;
        NSArray * array = [dic objectForKey:@"data"];
        [self.breakdownDescriptions removeAllObjects];
        [self.breakdownDescriptions addObjectsFromArray:array];
        NSMutableArray * popStrings = [NSMutableArray array];
        for (NSDictionary * ainfo in array) {
            NSString * str = [ainfo objectForKey:@"name"];
            [popStrings addObject:str];
        }
        PopViewController * popCtrl = [[PopViewController alloc] initWithTitle:@"故障描述" Data:popStrings];
        popCtrl.delegate = self;
        popCtrl.view.tag = TAG_POPVIEW_DESCRIPTION;
        [self.navCtrl addChildViewController:popCtrl];
        [self.navCtrl.view addSubview:popCtrl.view];
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
    }];
    
}

-(void)selectReason
{
    [self resign];
    [[NetWorkAPIManager defaultManager]  hint:@"SERVSOLU" success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary * dic = responseObject;
        NSArray * array = [dic objectForKey:@"data"];
        [self.breakdownReasons removeAllObjects];
        [self.breakdownReasons addObjectsFromArray:array];
        NSMutableArray * popStrings = [NSMutableArray array];
        for (NSDictionary * ainfo in array) {
            NSString * str = [ainfo objectForKey:@"name"];
            [popStrings addObject:str];
        }
        PopViewController * popCtrl = [[PopViewController alloc] initWithTitle:@"故障原因" Data:popStrings];
        popCtrl.delegate = self;
        popCtrl.view.tag = TAG_POPVIEW_REASON;
        [self.navCtrl addChildViewController:popCtrl];
        [self.navCtrl.view addSubview:popCtrl.view];

    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {

        
    }];
}


-(void)selectCertificate
{
    [self resign];
    [[NetWorkAPIManager defaultManager]  hint:@"ACSTPRV" success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary * dic = responseObject;
        NSArray * array = [dic objectForKey:@"data"];
        [self.breakdownDescriptions removeAllObjects];
        [self.breakdownDescriptions addObjectsFromArray:array];
        NSMutableArray * popStrings = [NSMutableArray array];
        for (NSDictionary * ainfo in array) {
            NSString * str = [ainfo objectForKey:@"name"];
            [popStrings addObject:str];
        }
        PopViewController * popCtrl = [[PopViewController alloc] initWithTitle:@"定责证明 " Data:popStrings];
        popCtrl.delegate = self;
        popCtrl.view.tag = TAG_POPVIEW_Certificate;
        [self.navCtrl addChildViewController:popCtrl];
        [self.navCtrl.view addSubview:popCtrl.view];
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
    }];
}


-(void)selectCompany
{
    [self resign];
    [[NetWorkAPIManager defaultManager]  hint:@"SASCMC" success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary * dic = responseObject;
        NSArray * array = [dic objectForKey:@"data"];
        [self.breakdownDescriptions removeAllObjects];
        [self.breakdownDescriptions addObjectsFromArray:array];
        NSMutableArray * popStrings = [NSMutableArray array];
        for (NSDictionary * ainfo in array) {
            NSString * str = [ainfo objectForKey:@"name"];
            [popStrings addObject:str];
        }
        PopViewController * popCtrl = [[PopViewController alloc] initWithTitle:@"责任类别" Data:popStrings];
        popCtrl.delegate = self;
        popCtrl.view.tag = TAG_POPVIEW_Company;
        [self.navCtrl addChildViewController:popCtrl];
        [self.navCtrl.view addSubview:popCtrl.view];
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
    }];
}

-(void)selectCategory
{
    [self resign];
    [[NetWorkAPIManager defaultManager]  hint:@"ACSTDTTP" success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary * dic = responseObject;
        NSArray * array = [dic objectForKey:@"data"];
        [self.breakdownDescriptions removeAllObjects];
        [self.breakdownDescriptions addObjectsFromArray:array];
        NSMutableArray * popStrings = [NSMutableArray array];
        for (NSDictionary * ainfo in array) {
            NSString * str = [ainfo objectForKey:@"name"];
            [popStrings addObject:str];
        }
        PopViewController * popCtrl = [[PopViewController alloc] initWithTitle:@"责任类别" Data:popStrings];
        popCtrl.delegate = self;
        popCtrl.view.tag = TAG_POPVIEW_Category;
        [self.navCtrl addChildViewController:popCtrl];
        [self.navCtrl.view addSubview:popCtrl.view];
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
    }];
    
}

-(void)selectLossAssessor
{
    [self resign];
    [[NetWorkAPIManager defaultManager]  hint:@"SASSTP" success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary * dic = responseObject;
        NSArray * array = [dic objectForKey:@"data"];
        [self.breakdownDescriptions removeAllObjects];
        [self.breakdownDescriptions addObjectsFromArray:array];
        NSMutableArray * popStrings = [NSMutableArray array];
        for (NSDictionary * ainfo in array) {
            NSString * str = [ainfo objectForKey:@"name"];
            [popStrings addObject:str];
        }
        PopViewController * popCtrl = [[PopViewController alloc] initWithTitle:@"定损员" Data:popStrings];
        popCtrl.delegate = self;
        popCtrl.view.tag = TAG_POPVIEW_LossAssessor;
        [self.navCtrl addChildViewController:popCtrl];
        [self.navCtrl.view addSubview:popCtrl.view];
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
    }];
    
}

-(void)selectIsDirect
{
    [self resign];
    [[NetWorkAPIManager defaultManager]  hint:@"FLAG" success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary * dic = responseObject;
        NSArray * array = [dic objectForKey:@"data"];
        [self.breakdownDescriptions removeAllObjects];
        [self.breakdownDescriptions addObjectsFromArray:array];
        NSMutableArray * popStrings = [NSMutableArray array];
        for (NSDictionary * ainfo in array) {
            NSString * str = [ainfo objectForKey:@"name"];
            [popStrings addObject:str];
        }
        PopViewController * popCtrl = [[PopViewController alloc] initWithTitle:@"是否直赔" Data:popStrings];
        popCtrl.delegate = self;
        popCtrl.view.tag = TAG_POPVIEW_IsDirect;
        [self.navCtrl addChildViewController:popCtrl];
        [self.navCtrl.view addSubview:popCtrl.view];
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
    }];
    
}

-(void)selectRiskTime
{
    TimePickerViewController * timePick = [[TimePickerViewController alloc] init];
    timePick.modalPresentationStyle = UIModalPresentationFullScreen;
    timePick.delegate = self;
    timePick.tag = TAG_TimePicker_RiskTime;
    [timePick showIn:self.navCtrl];
    
//    UIDatePicker * datePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, self.frame.size.height - 300, self.frame.size.width, 300)];
//    datePicker.backgroundColor = [UIColor whiteColor];
//    datePicker.datePickerMode = UIDatePickerModeDateAndTime;
//    [self addSubview:datePicker];
}

-(void)selectSettleTime
{
    TimePickerViewController * timePick = [[TimePickerViewController alloc] init];
    timePick.modalPresentationStyle = UIModalPresentationFullScreen;
    timePick.delegate = self;
    timePick.tag = TAG_TimePicker_SettleTime;
    [timePick showIn:self.navCtrl];
    
}

- (void)addMaintance
{
    NSArray * array = [self.curSevice objectForKey:@"maintenances"];
    if (!array) {
        array = [NSArray array];
    }
    MaintanceAndAccessoryViewController * maintanceCtrl = [[MaintanceAndAccessoryViewController alloc] initWithData:array goods:[NSArray array] vehicleType:[self.curVehicle objectForKey:@"type"]];
    maintanceCtrl.delegate = self;
    [self.navCtrl pushViewController:maintanceCtrl animated:YES];
    
}

-(void)resizeContentView
{
    NSInteger viewH = self.frame.size.height;
    NSInteger orgH = 500;
    CGSize contentsize = self.contentSize;
    
    NSInteger height = self.extandDetailView.frame.origin.y+self.extandDetailView.frame.size.height;
    if (self.extandDetailView.hidden) {
        height = 500;
    }
    if (height < viewH) {
        height = 500;
    }
    
    self.contentSize = CGSizeMake(contentsize.width,height);
}

-(void)addImageBtnClicked
{
    [self resign];
    //最多上传10张图片或视频
    if (self.imageArray.count >= 10) {
        return;
    }
    PopViewController * popCtrl = [[PopViewController alloc] initWithTitle:@"图片与视频" Data:@[@"拍摄", @"从相册选择"]];
    popCtrl.delegate = self;
    popCtrl.view.tag = TAG_POPVIEW_IMAGEVIDEO;
    [self.navCtrl addChildViewController:popCtrl];
    [self.navCtrl.view addSubview:popCtrl.view];
}

-(void)layoutImageView
{
    NSInteger imageW = _imagesView.frame.size.width;
    NSInteger imageH = imageW*0.56;
    NSInteger itemH = imageH+20;
    NSInteger space = 12;
    NSInteger headerH = 84;//添加按钮的高度
    for (UIView * view in self.imagesDetailView.subviews) {
        [view removeFromSuperview];
    }
    
    NSArray * array = [self.curSevice objectForKey:@"serviceVehicleImgUrls"];
    [self.imageArray removeAllObjects];
    for (NSDictionary * dic in array) {
        ImageVideoItem * item = [[ImageVideoItem alloc] init];
        item.url = [NSURL URLWithString:[dic objectForKey:@"vehicleImgUrl"]];
        [self.imageArray addObject:item];
    }
    
    self.imagesDetailView.frame = CGRectMake(0, self.imagesDetailView.frame.origin.y, imageW, self.imageArray.count*(imageH+space));
    for (int i = 0; i<self.imageArray.count; i++) {
        ImageVideoViewCell * cell = [[ImageVideoViewCell alloc] initWithFrame:CGRectMake(0, i*(imageH+space), imageW, imageH) item:[self.imageArray objectAtIndex:i]];
        
        __weak PickupView * weakself = self;
        cell.deleteBlock = ^(void){
            NSMutableArray * array = [NSMutableArray arrayWithArray:[self.curSevice objectForKey:@"serviceVehicleImgUrls"]];
            [array removeObjectAtIndex:i];
            [weakself.curSevice setValue:[NSMutableArray arrayWithArray:array] forKey:@"serviceVehicleImgUrls"];
            dispatch_async(dispatch_get_main_queue(), ^{                
                [weakself layoutImageView];
            });
        };
        [self.imagesDetailView addSubview:cell];
    }
    CGPoint pt = _imagesView.frame.origin;
    CGSize size = _imagesView.frame.size;
    NSInteger newH = headerH+space+itemH*(self.imageArray.count);
    if (newH < DetailViewH) {
        newH = DetailViewH;
    }
    _imagesView.frame = CGRectMake(pt.x, pt.y, size.width,newH);
    _extandDetailView.frame = CGRectMake(_extandDetailView.frame.origin.x, _extandDetailView.frame.origin.y, _extandDetailView.frame.size.width,_imagesView.frame.size.height);
    [self resizeContentView];
}

//拍摄照片和视频
- (void)takePhotos
{
    __weak PickupView * weakself = self;
    VideoViewController *ctrl = [[NSBundle mainBundle] loadNibNamed:@"VideoViewController" owner:nil options:nil].lastObject;
    ctrl.HSeconds = 30;//设置可录制最长时间
    ctrl.takeBlock = ^(id item) {
        if ([item isKindOfClass:[NSURL class]]) {
            NSURL *url = item;
            //视频url
            
            [self uploadVideo:url];

        } else {
            //图片
            UIImage * image = item;
            if (image){
                [self uploadImage:image];
            }
        }
    };
    [self.navCtrl pushViewController:ctrl animated:YES];
    
}

//选择照片和视频
- (void)selectPhotos
{
    UIImagePickerController * imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.delegate = self;
    imagePicker.allowsEditing = YES;
    imagePicker.mediaTypes = @[(NSString *)kUTTypeMovie, (NSString *)kUTTypeImage];
    imagePicker.modalPresentationStyle =  UIModalPresentationFullScreen;
    [self.navCtrl presentViewController:imagePicker animated:YES completion:nil];
    
}

-(void)uploadImage:(UIImage *)image
{
    __weak PickupView * weakself = self;
    
    NSData *imgData = UIImageJPEGRepresentation(image, 1);
    NSString * key = [NSString stringWithFormat:@"%@/%@.jpeg",[self.ossSignature objectForKey:@"dir"],[CommonTool getNowTimestamp]];
    NSMutableDictionary * parm = [NSMutableDictionary dictionaryWithDictionary:self.ossSignature];
    [parm setValue:key forKey:@"key"];
    [[NetWorkAPIManager defaultManager] uploadData:imgData signature:parm success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        //成功无返回数据
        NSArray * imgurls = [weakself.curSevice objectForKey:@"serviceVehicleImgUrls"];
        if (!imgurls) {
            imgurls = [NSArray array];
        }
        NSMutableArray * newUrls = [NSMutableArray arrayWithArray:imgurls];
          
        switch (weakself.addImageVideoType) {
            case AddImageVideoToPickUP:
            {
                //带水印图片路径
                NSString * timeStr = [[CommonTool getNowDateStr] stringByReplacingOccurrencesOfString:@"T" withString:@" "];
                NSData *data = [timeStr dataUsingEncoding:NSUTF8StringEncoding];
                NSString * base64TimeStr = [data base64EncodedStringWithOptions:0];
                NSString * path = [NSString stringWithFormat:@"%@/%@?x-oss-process=image/watermark,type_d3F5LXplbmhlaQ,size_36,text_%@,color_FFFFFF,shadow_50,t_100,g_se,x_10,y_10",[self.ossSignature objectForKey:@"host"],key,base64TimeStr];
                
                [newUrls addObject:[NSDictionary dictionaryWithObject:path forKey:@"vehicleImgUrl"]];
                [weakself.curSevice setValue:newUrls forKey:@"serviceVehicleImgUrls"];

                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakself layoutImageView];
                });
            }
                break;
            case AddImageToAccidentBtn:
            {
                NSString * path = [NSString stringWithFormat:@"%@/%@",[self.ossSignature objectForKey:@"host"],key];
                [self.addAccidentImageBtn sd_setImageWithURL:[NSURL URLWithString:path] forState:UIControlStateNormal];
                [self.serviceAccidentSettlement setValue:path forKey:@"accidentBookImgUrl"];
            }
                break;
            case AddImageToLossBtn:
            {
                NSString * path = [NSString stringWithFormat:@"%@/%@",[self.ossSignature objectForKey:@"host"],key];
                [self.addLossImageBtn sd_setImageWithURL:[NSURL URLWithString:path] forState:UIControlStateNormal];
                [self.serviceAccidentSettlement setValue:path forKey:@"damageOrderImgUrl"];
            }
                break;
                
            default:
                break;
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
           
    }];
    
}



-(void)uploadVideo:(NSURL *)url
{
    __weak PickupView * weakself = self;
    
    NSString * videoPath = [NSString stringWithFormat:@"%@/tempVideo.mov",NSTemporaryDirectory()];
    __block NSData * videoData = nil;
    
    ALAssetsLibrary *assetLibrary=[[ALAssetsLibrary alloc] init];
    [assetLibrary assetForURL:url resultBlock:^(ALAsset *asset) // substitute YOURURL with your url of video
    {
        ALAssetRepresentation *rep = [asset defaultRepresentation];
        Byte *buffer = (Byte*)malloc(rep.size);
        NSUInteger buffered = [rep getBytes:buffer fromOffset:0.0 length:rep.size error:nil];
        videoData = [NSData dataWithBytesNoCopy:buffer length:buffered freeWhenDone:YES];
//        [videoData writeToFile:videoPath atomically:NO]; //you can remove this if only nsdata needed

        NSString * key = [NSString stringWithFormat:@"%@/%@.mov",[self.ossSignature objectForKey:@"dir"],[CommonTool getNowTimestamp]];
        NSMutableDictionary * parm = [NSMutableDictionary dictionaryWithDictionary:self.ossSignature];
        [parm setValue:key forKey:@"key"];

        [[NetWorkAPIManager defaultManager] uploadVideo:videoData signature:parm success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject)
        {
            //成功无返回数据
            NSArray * imgurls = [weakself.curSevice objectForKey:@"serviceVehicleImgUrls"];
            if (!imgurls) {
                imgurls = [NSArray array];
            }
            
            NSMutableArray * newUrls = [NSMutableArray arrayWithArray:imgurls];
            NSString * path = [NSString stringWithFormat:@"%@/%@",[self.ossSignature objectForKey:@"host"],key];
            NSLog(@"vehicleImgUrl: %@",path);
            [newUrls addObject:[NSDictionary dictionaryWithObject:path forKey:@"vehicleImgUrl"]];
            [weakself.curSevice setValue:newUrls forKey:@"serviceVehicleImgUrls"];

            dispatch_async(dispatch_get_main_queue(), ^{
                    [weakself layoutImageView];
                });
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                      
                }];
            
        }
        failureBlock:^(NSError *err) {
//         NSLog(@"Error: %@",[err localizedDescription]);
        }];
    
}

//查询车辆详情
-(void)queryInfoWithPlateNo:(NSString *)plateNo
{
    __weak PickupView * weakself = self;
    NetWorkAPIManager * manager = [NetWorkAPIManager defaultManager];
    [manager getVehicleInfoWithPlateNo:plateNo success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSError*err;
        NSDictionary * resultDic = responseObject;
        NSString * text = @"";
        NSArray * array = [resultDic objectForKey:@"data"];
     
        if ([array count] > 0) {
            
            NSDictionary * data = [array firstObject];
            NSString * name = [data objectForKey:@"driver"];
            NSString * plateno = [data objectForKey:@"plateNo"];
            NSString * vin = [data objectForKey:@"vin"];
            
            if (name) {
                name = @"";
            }
            if (plateno) {
                plateno = @"";
            }
            if (vin) {
                vin = @"";
            }
            
            text = [NSString stringWithFormat:@"%@ %@\r%@\r%@",name,plateno,vin,@"老客户"];
//            self.isOldCustomer  = YES;
            [self setupData:data];
            
        }else {
            self.isOldCustomer  = NO;
        }
        
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
    }];

}

-(BOOL)check
{
    if (!_platoLab.text || _platoLab.text.length <= 0){
        [self showHint:@"请输入车牌号"];
        return NO;
    }
    if (![self.nameBox getText] || [self.nameBox getText].length <= 0){
        [self showHint:@"请输入姓名"];
        return NO;
    }
    if (![CommonTool isCellphoneValid:[self.cellphoneBox getText]]){
        [self showHint:@"请输入正确的手机号码"];
        return NO;
    }
    if (![CommonTool isVinValid:[CommonTool getVinString:[self.vinBox getText]]]){
        [self showHint:@"请输入正确的VIN码"];
        return NO;
    }
    if (![self.typeBox getText]|| [self.typeBox getText].length <= 0){
        [self showHint:@"请选择车型类型"];
        return NO;
    }
    if (![self.modelBox getText]|| [self.modelBox getText].length <= 0){
        [self showHint:@"请选择车品牌"];
        return NO;
    }
//    if (![self.customTypeBox getText]|| [self.customTypeBox getText].length <= 0){
//        [self showHint:@"请选择客户类型"];
//        return NO;
//    }

    
    return YES;
}

-(void)queryCustom
{
    //查询客户信息
    __weak  PickupView * weakself = self;
    [[NetWorkAPIManager defaultManager] queryCustomWithName:[self.nameBox getText] Cellphone:[self.cellphoneBox getText] Success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject){
            
        NSDictionary * resp = responseObject;
        NSArray * dataArray = [resp objectForKey:@"data"];
        if (dataArray.count == 0) {//用户不存在直接去创建/更新
            if (weakself.isOldCustomer) {
                //更新
                [weakself updateCustom];
            }else {
                //创建
                [weakself createCustom];
            }
        }else{//用户已存在
            
            NSDictionary * data = [dataArray firstObject];
            NSString * name = [data objectForKey:@"name"];
            NSString * cellphone = [data objectForKey:@"cellphone"];
            NSInteger customerID = [[data objectForKey:@"id"] integerValue];
    
            if (weakself.isOldCustomer) {
                //更新,更改的用户名手机号已存在时，后端会返回错误信息，此处不再检查
                [weakself updateCustom];
                
            }else {
                //创建
                dispatch_async(dispatch_get_main_queue(), ^{
                    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"用户已存在"
                                                                                       message:[NSString stringWithFormat:@"是否使用%@ %@去创建",name,cellphone]
                                                                                preferredStyle:UIAlertControllerStyleAlert];
                        
                        UIAlertAction* yesAction = [UIAlertAction actionWithTitle:@"是" style:UIAlertActionStyleDefault
                                                                              handler:^(UIAlertAction * action) {
                                                                                  //响应事件
                            [weakself createVehicleWith:customerID];

                                                                                  NSLog(@"action = %@", action);
                                                                              }];
                    UIAlertAction* noAction = [UIAlertAction actionWithTitle:@"否" style:UIAlertActionStyleDefault
                                                                          handler:^(UIAlertAction * action) {
                                                                              //响应事件
                        
                        
                                                                              NSLog(@"action = %@", action);
                                                                          }];

                    [alert addAction:yesAction];
                    [alert addAction:noAction];
                    [self.navCtrl presentViewController:alert animated:YES completion:nil];
                });
                
            }
            
        }
    }
                                                    
    Failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
    }];
        
}

//创建/更新用户和车辆,分四步 0.查询客户是否已存在 1.创建/更新客户 2.创建/更新车辆 3.查询详情
-(void)create
{
    if ([self check]) {
        [self queryCustom];
    }
}

-(void)createCustom
{
    [self.curCustomer setValue:[self.nameBox getText] forKey:@"name"];
    [self.curCustomer setValue:[self.cellphoneBox getText] forKey:@"cellphone"];
    NSDictionary * status = [NSDictionary dictionaryWithObject:@"A" forKey:@"code"];
    [self.curCustomer setValue:status forKey:@"status"];
    
    __weak  PickupView * weakself = self;
    [[NetWorkAPIManager defaultManager] createCustomer:self.curCustomer success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            NSDictionary * resp = responseObject;
            NSInteger customerID = [[[resp objectForKey:@"data"] firstObject]integerValue];
            [weakself createVehicleWith:customerID];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSString * info = [error.userInfo objectForKey:@"body"];
        NSDictionary * dic = [CommonTool dictionaryWithJsonString:info];
        NSDictionary * msgDic = [[dic objectForKey:@"errors"] firstObject];
        NSString * message = [msgDic objectForKey:@"message"];
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakself showAlertWithTitle:@"创建失败" message:message];
        });
    }];
}

-(void)updateCustom
{
    [self.curCustomer setValue:[self.nameBox getText] forKey:@"name"];
    [self.curCustomer setValue:[self.cellphoneBox getText] forKey:@"cellphone"];
    
    __weak  PickupView * weakself = self;
    [[NetWorkAPIManager defaultManager] updateCustomer:self.curCustomer success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            NSDictionary * resp = responseObject;
            NSInteger customerID = [[[resp objectForKey:@"data"] firstObject]integerValue];
            [weakself updateVehicle];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSString * info = [error.userInfo objectForKey:@"body"];
        NSDictionary * dic = [CommonTool dictionaryWithJsonString:info];
        NSDictionary * msgDic = [[dic objectForKey:@"errors"] firstObject];
        NSString * message = [msgDic objectForKey:@"message"];
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakself showAlertWithTitle:@"更新失败" message:message];
        });
    }];
}

-(void)createVehicleWith:(NSInteger)ownerID
{
    [self.curVehicle setValue:[CommonTool getPlateNoString:_platoLab.text] forKey:@"plateNo"];
    NSString * vin = [CommonTool getVinString:[self.vinBox getText]];
    [self.curVehicle setValue:vin forKey:@"vin"];
    NSMutableDictionary * owner = [NSMutableDictionary  dictionary];
    [owner setValue:[NSNumber numberWithInteger:ownerID] forKey:@"id"];
    [self.curVehicle setValue:owner forKey:@"owner"];
    __weak  PickupView * weakself = self;
    
    [[NetWorkAPIManager defaultManager] createVehicle:self.curVehicle success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary * resp = responseObject;
        NSInteger VehicleID = [[[resp objectForKey:@"data"] firstObject]integerValue];
        [self queryInfoWithPlateNo:[CommonTool getPlateNoString:_platoLab.text]];
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSString * info = [error.userInfo objectForKey:@"body"];
        NSDictionary * dic = [CommonTool dictionaryWithJsonString:info];
        NSDictionary * msgDic = [[dic objectForKey:@"errors"] firstObject];
        NSString * message = [msgDic objectForKey:@"message"];
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakself showAlertWithTitle:@"创建失败" message:message];
        });
    }];
}

-(void)updateVehicle
{
    NSString * vin = [CommonTool getVinString:[self.vinBox getText]];
    [self.curVehicle setValue:vin forKey:@"vin"];
    
    __weak  PickupView * weakself = self;
    
    [[NetWorkAPIManager defaultManager] updateVehicle:self.curVehicle success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary * resp = responseObject;
        NSInteger VehicleID = [[[resp objectForKey:@"data"] firstObject]integerValue];
        [self queryInfoWithPlateNo:[CommonTool getPlateNoString:_platoLab.text]];
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSString * info = [error.userInfo objectForKey:@"body"];
        NSDictionary * dic = [CommonTool dictionaryWithJsonString:info];
        NSDictionary * msgDic = [[dic objectForKey:@"errors"] firstObject];
        NSString * message = [msgDic objectForKey:@"message"];
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakself showAlertWithTitle:@"更新失败" message:message];
        });
    }];
}

-(void)createServiceWith:(NSDictionary * )advisor success:(nullable void (^)(NSURLSessionDataTask *task, id _Nullable responseObject))success
                    failure:(nullable void (^)(NSURLSessionDataTask * _Nullable task, NSError *error))failure
{
    __weak PickupView * weakself = self;

    //savedata
    [self.curSevice setValue:self.curVehicle forKey:@"vehicle"];
    NSDictionary * owner = [self.curVehicle objectForKey:@"owner"];
    if (owner) {
        NSDictionary * customer = [NSDictionary dictionaryWithObject:[owner objectForKey:@"id"] forKey:@"id"];
        [self.curSevice setValue:customer forKey:@"customer"];
    }
    if (!advisor){
        advisor = [NSDictionary dictionaryWithObject:[NSNumber numberWithInteger:[NetWorkAPIManager defaultManager].userID] forKey:@"id"];
    }
    [self.curSevice setValue:advisor forKey:@"advisor"];
    [self.curSevice setValue:@"" forKey:@"settlementMethod"];//必需
    NSInteger mileage = [_milesTF.text integerValue];
    [self.curSevice setValue:[NSNumber numberWithInteger:mileage] forKey:@"currentMileage"];
    NSString * description = @"";
    if ([self.descriptionBox getText]) {
        description = [self.descriptionBox getText];
    }
    [self.curSevice setValue:[NSArray arrayWithObject:description] forKey:@"descriptions"];
    NSString * solution = @"";
    if ([self.reasonBox getText]) {
        solution = [self.reasonBox getText];
    }
    [self.curSevice setValue:solution forKey:@"solution"];
    [self.curSevice setValue:_commentTV.text forKey:@"comment"];
    [self.curSevice setValue:[NSDictionary dictionaryWithObject:@"IM" forKey:@"code"] forKey:@"nextStep"];
    [self.curSevice setValue:[self currentDateStr] forKey:@"enterDatetime"];
    [self.curSevice setValue:[NSNumber numberWithBool:TRUE] forKey:@"ignoreCheck"];
    
    //settlement
    [self saveServiceAccidentSettlement];
    [self.curSevice setValue:self.serviceAccidentSettlement forKey:@"serviceAccidentSettlement"];
    
    [[NetWorkAPIManager defaultManager] createService:self.curSevice success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [[DataBase defaultDataBase] deleteASevice:[[weakself.curVehicle objectForKey:@"id"] integerValue]];

        NSDictionary * resp = responseObject;
//        NSMutableDictionary * asevice = [NSMutableDictionary dictionaryWithDictionary:info];
        [[NetWorkAPIManager defaultManager] queryService:[[[resp objectForKey:@"data"] firstObject] integerValue] success:^(NSURLSessionDataTask *task, id  _Nullable responseObject) {
            NSDictionary * dic = responseObject;
//            NSMutableDictionary * parm = [NSMutableDictionary dictionaryWithObject:[dic objectForKey:@"data"] forKey:@"data"];
            NSMutableDictionary * seviceDic = [NSMutableDictionary dictionaryWithDictionary:[[dic objectForKey:@"data"] firstObject]];
            if(![seviceDic objectForKey:@"serviceAccidentSettlement"]){
                [seviceDic setValue:[NSDictionary dictionary] forKey:@"serviceAccidentSettlement"];
            }else {
                [self.serviceAccidentSettlement setValue:[[seviceDic objectForKey:@"serviceAccidentSettlement"] objectForKey:@"id"] forKey:@"id"];
                [seviceDic setValue:self.serviceAccidentSettlement forKey:@"serviceAccidentSettlement"];
            }
            [seviceDic setValue:[NSNumber numberWithBool:TRUE] forKey:@"ignoreCheck"];
            
            [seviceDic setValue:[NSDictionary dictionary] forKey:@"qualityInspector"];
            [seviceDic setValue:[NSDictionary dictionaryWithObject:@"IM" forKey:@"code"] forKey:@"nextStep"];

            [[NetWorkAPIManager defaultManager] updateService:seviceDic success:success failure:failure];
            
        } failure:failure];
        
    } failure:failure];
}


#pragma delegate

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    self.firstResponderView = textView;
    if (textView.tag == TAG_ClaimComment) {
        self.firstResponderView = _settlementClaimCommentTV;
        [_settlementClaimCommentTV beginEditing];
    }else if (textView.tag == TAG_LossComment) {
        self.firstResponderView = _settlementLossCommentTV;
        [_settlementLossCommentTV beginEditing];
    }
    return YES;
}

-(BOOL)textViewShouldEndEditing:(UITextView *)textView
{
    if (textView.tag == TAG_ClaimComment) {
        [_settlementClaimCommentTV endEditing];
    }else if (textView.tag == TAG_LossComment) {
        [_settlementLossCommentTV endEditing];
    }
    return YES;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    self.firstResponderView = textField;
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];//收起键盘
    return  YES;
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    switch (textField.tag) {
        case TAG_VIN:
        {
            NSString *text = [textField text];
            NSCharacterSet *characterSet = [NSCharacterSet characterSetWithCharactersInString:@"0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz\b"];
            string = [string stringByReplacingOccurrencesOfString:@" " withString:@""];
            if ([string rangeOfCharacterFromSet:[characterSet invertedSet]].location != NSNotFound){
                return NO;
            }
            text = [text stringByReplacingCharactersInRange:range withString:string];
            text = [text stringByReplacingOccurrencesOfString:@" " withString:@""];
            NSString *newString = @"";

            newString = [CommonTool getVinSpaceString:text];
            
            newString = [newString stringByTrimmingCharactersInSet:[characterSet invertedSet]];
            if (newString.length >= 21){  //vin码17位+3空格 = 20;
                return NO;
            }
            [textField setText:newString];
            
            return NO;
        }
            break;
            
        default:
            break;
    }
    return YES;
}

-(void)popview:(UIViewController *)popview disSelectRowAtIndex:(NSInteger)index
{
    switch (popview.view.tag) {
        case TAG_POPVIEW_SEVICECATEGORY:
            {
                NSDictionary * dic = [_seviceCategorys objectAtIndex:index];
                
                NSString * lastTypeCode = [[[self.curSevice objectForKey:@"serviceCategory"] objectForKey:@"type"] objectForKey:@"code"];
                NSString * curTypeCode = [[dic objectForKey:@"type"] objectForKey:@"code"];
        
                [_repairetypeBtn setTitle:[dic objectForKey:@"name"] forState:UIControlStateNormal];
                [self.curSevice setValue:dic forKey:@"serviceCategory"];
                
                if ([lastTypeCode isEqualToString:@"ACCIDENT"] && (![curTypeCode isEqualToString:@"ACCIDENT"])) {
                    [self hideAccidentSettlement];
                }else if ((![lastTypeCode isEqualToString:@"ACCIDENT"]) && [curTypeCode isEqualToString:@"ACCIDENT"]) {
                    [self showAccidentSettlement];
                }
                
            }
            break;
        case TAG_POPVIEW_VEHICLETYPE:
            {
                NSDictionary * dic = [_vehicleTypes objectAtIndex:index];
                _typeBox.text = [dic objectForKey:@"name"];
                [self.curVehicle setValue:dic forKey:@"type"];
            }
            break;
        case TAG_POPVIEW_OIL:
            {
                NSDictionary * dic = [_remainOils objectAtIndex:index];
                _oilgaugeBox.text = [dic objectForKey:@"message"];
                [self.curSevice setValue:dic forKey:@"remainingOil"];

            }
            break;
        case TAG_POPVIEW_DESCRIPTION:
            {
                _descriptionBox.text = [[_breakdownDescriptions objectAtIndex:index] objectForKey:@"name"];
            }
            break;
        case TAG_POPVIEW_REASON:
        {
            _reasonBox.text = [[_breakdownReasons objectAtIndex:index] objectForKey:@"solution"];
            
        }
            break;
        case TAG_POPVIEW_IMAGEVIDEO:
        {
            self.addImageVideoType = AddImageVideoToPickUP;
            if (index == 0) {
                [self takePhotos];
            }else if (index == 1){
                [self selectPhotos];
            }
        }
            break;
        case TAG_POPVIEW_Certificate:
        {
            [self.serviceAccidentSettlement setValue:[_settlementCertificateBox getSelectedItem] forKey:@"prove"];
        }
            break;
        case TAG_POPVIEW_Category:
        {
            [self.serviceAccidentSettlement setValue:[_settlementCategoryBox getSelectedItem] forKey:@"type"];
        }
            break;
        case TAG_POPVIEW_Company:
        {
            [self.serviceAccidentSettlement setValue:[[_settlementClaimsCompanyBox getSelectedItem] objectForKey:@"name"] forKey:@"claimsCompany"];
        }
            break;
        case TAG_POPVIEW_IsDirect:
        {
            [self.serviceAccidentSettlement setValue:[_settlementIsDirectBox getSelectedItem] forKey:@"direct"];
        }
            break;
        case TAG_POPVIEW_LossAssessor:
        {
            [self.serviceAccidentSettlement setValue:[[_settlementIsDirectBox getSelectedItem] objectForKey:@"name"] forKey:@"settlingPerson"];
        }
            break;
        case TAG_POPVIEW_AddAccidentImage:
        {
            self.addImageVideoType = AddImageToAccidentBtn;
            if (index == 0) {
                [self takePhotos];
            }else if (index == 1){
                [self selectPhotos];
            }
        }
            break;
        case TAG_POPVIEW_AddLossImage:
        {
            self.addImageVideoType = AddImageToLossBtn;
            if (index == 0) {
                [self takePhotos];
            }else if (index == 1){
                [self selectPhotos];
            }
        }
            break;
            
        default:
            break;
    }
    
}

//-(void)imageViewController:(ImageViewController *)imageCtrl deleteImage:(NSString *)urlstr
//{
//    switch (imageCtrl.tag) {
//        case TAG_ImageCtrl_AccidentImage:
//        {
//            [self.serviceAccidentSettlement removeObjectForKey:KEY_serviceAccidentSettlement_accidentImage];
//            [self.addAccidentImageBtn setImage:[UIImage imageNamed:@"accidentImage"] forState:UIControlStateNormal];
//        }
//            break;
//        case TAG_ImageCtrl_LossImage:
//        {
//            [self.serviceAccidentSettlement removeObjectForKey:KEY_serviceAccidentSettlement_damageImage];
//            [self.addLossImageBtn setImage:[UIImage imageNamed:@"lossImage"] forState:UIControlStateNormal];
//        }
//            break;
//
//        default:
//            break;
//    }
//}

-(void)tabview:(CommonTabView *)tabview indexChanged:(NSInteger )index
{
    switch (index) {
        case 0:
        {
            _vehicleView.hidden = NO;
            _imagesView.hidden = YES;
            _accidentView.hidden = YES;
            //扩展页面重新布局
            CGRect frame = self.extandDetailView.frame;
            self.extandDetailView.frame = CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, _vehicleView.frame.size.height);
        }
            break;
        case 1:
        {
            _vehicleView.hidden = YES;
            _imagesView.hidden = NO;
            _accidentView.hidden = YES;
            //扩展页面重新布局
            CGRect frame = self.extandDetailView.frame;
            self.extandDetailView.frame = CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, _imagesView.frame.size.height);
        }
            break;
        case 2:
        {
            _vehicleView.hidden = YES;
            _imagesView.hidden = YES;
            _accidentView.hidden = NO;
            //扩展页面重新布局
            CGRect frame = self.extandDetailView.frame;
            self.extandDetailView.frame = CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, _accidentView.frame.size.height);
        }
            break;
            
        default:
            break;
    }
    [self resizeContentView];
}


-(void)save:(NSArray *)maintenances
{
    [self.curSevice setObject:[NSMutableArray arrayWithArray:maintenances] forKey:@"maintenances"];
    [self showHint:@"保存成功"];
}

- (NSString *)currentDateStr{
    NSDate *currentDate = [NSDate date];//获取当前时间，日期
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    //设定时间格式,这里可以设置成自己需要的格式
    [dateFormatter setDateFormat:@"YYYY-MM-dd"];
    NSString *ymdString = [dateFormatter stringFromDate:currentDate];
    [dateFormatter setDateFormat:@"hh:mm:ss"];
    NSString *hmsString = [dateFormatter stringFromDate:currentDate];
    NSString * dateString = [NSString stringWithFormat:@"%@T%@",ymdString,hmsString];
    return dateString;
}


-(void)disSelectModel:(NSArray *)model
{
    _modelBox.text = [NSString stringWithFormat:@"%@/%@",[model firstObject],[model lastObject]];
    
    [self.curVehicle setValue:model forKey:@"vehicleSpec"];
    
}

-(void)recognize:(RecognizeViewController*)recognizeCtrl withResult:(NSDictionary*)data
{
    NSString * vin = [data objectForKey:@"vin"];
    _vinBox.text = [CommonTool getVinSpaceString:vin];
    
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<UIImagePickerControllerInfoKey, id> *)info
{
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    NSString *type = [info objectForKey:UIImagePickerControllerMediaType];
    //当选择的类型是图片
    if ([type isEqualToString:@"public.image"]) {
        if (image){
            [self uploadImage:image];
        }
    }else if ([type isEqualToString:@"public.movie"]){
        //当选择的类型是视频
        NSURL *mediaUrl = [info objectForKey:UIImagePickerControllerReferenceURL];
        [self uploadVideo:mediaUrl];
    }
    
    [self.navCtrl dismissViewControllerAnimated:picker completion:^{
        
    }];
}

-(void)getOSSSignature
{
    __weak PickupView * weakself = self;
    [[NetWorkAPIManager defaultManager] getOSSSignatureSuccess:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary * resp = responseObject;
        NSDictionary * data = [[resp objectForKey:@"data"] firstObject];
        
        NSString * dir = [data objectForKey:@"dir"];
        NSNumber *  expire = [data objectForKey:@"expire"];
        NSString * accessId = [data objectForKey:@"accessId"];
        NSString * host = [data objectForKey:@"host"];
        NSString * signature = [data objectForKey:@"signature"];
        NSString * policy = [data objectForKey:@"policy"];
        
        NSMutableDictionary * ossSignature = [NSMutableDictionary dictionary];
        [ossSignature setValue:accessId forKey:@"OSSAccessKeyId"];
        [ossSignature setValue:signature forKey:@"Signature"];
        [ossSignature setValue:dir forKey:@"dir"];
        [ossSignature setValue:[NSString stringWithFormat:@"%@",expire] forKey:@"expire"];
        [ossSignature setValue:policy forKey:@"policy"];
        [ossSignature setValue:host forKey:@"host"];
        
        weakself.ossSignature = ossSignature;
        [ossSignature setValue:accessId forKey:@"accessId"];
        [ossSignature setValue:signature forKey:@"signature"];
        NSLog(@"getOSSSignature Success");
        
    } Failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
    }];
    
}


#pragma --UITextView delegate

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    self.commentHolderLab.text = @"";
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    if (self.commentTV.text.length <= 0) {
        self.commentHolderLab.text = @"输入内容...";
    }else {
        self.commentHolderLab.text = @"";
    }
}
- (void)textViewDidChange:(UITextView *)textView
{
    if (self.commentTV.text.length <= 0) {
        self.commentHolderLab.text = @"输入内容...";
    }else {
        self.commentHolderLab.text = @"";
    }
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"text"]) {
        if (self.commentTV.text.length <= 0) {
            self.commentHolderLab.text = @"输入内容...";
        }else {
            self.commentHolderLab.text = @"";
        }
    }
}

//tool
-(NSDictionary *)getVehicleTypeByString:(NSString *)typeString
{
    NSDictionary * curType = nil;
    for (NSDictionary * type in self.vehicleTypes) {
        if ([[type objectForKey:@"name"] isEqualToString:@"typeString"]) {
            curType = type;
        }
    }
    return curType;
}

#pragma TimePickerDelegate

-(void)timePicker:(TimePickerViewController*)picker selectTime:(NSString*)timeString
{
    if (picker.tag == TAG_TimePicker_RiskTime) {
        [self.settlementRiskTimeBox setText:timeString];
        NSString * string = [timeString stringByReplacingOccurrencesOfString:@" " withString:@"T"];
        [self.serviceAccidentSettlement setValue:string forKey:@"riskDatetime"];
    }else if (picker.tag == TAG_TimePicker_SettleTime){
        [self.settlementDateTimeBox setText:timeString];
        NSString * string = [timeString stringByReplacingOccurrencesOfString:@" " withString:@"T"];
        [self.serviceAccidentSettlement setValue:string forKey:@"settlingDatetime"];
    }
}


-(void)OpenOrPutawayStatusChanged:(BOOL)isopen
{
    CGRect frame = _accidentView.frame;
    if (isopen) {
        _accidentView.frame = CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, 960);
    }else {
        _accidentView.frame = CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, 365);
    }
    _openOrPutawayBtnView.frame = CGRectMake(0, _accidentView.frame.size.height-77, _accidentView.frame.size.width, 77);
    
    _extandDetailView.frame = CGRectMake(_extandDetailView.frame.origin.x, _extandDetailView.frame.origin.y, _extandDetailView.frame.size.width,_accidentView.frame.size.height);
    [self resizeContentView];
}

@end
