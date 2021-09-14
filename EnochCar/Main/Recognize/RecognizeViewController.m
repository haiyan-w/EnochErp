//
//  RecognizeViewController.m
//  tableview
//
//  Created by HAIYAN on 2021/5/7.
//
#import <AVKit/AVKit.h>
#import <AVFoundation/AVFoundation.h>
#import "RecognizeViewController.h"
#import "MainViewController.h"
#import "DataBase.h"
#import "RecordListViewController.h"
#import "CommonTabView.h"
#import "CommonTool.h"
#import "UIImage+FixOritention.h"
#import <sys/utsname.h>

@interface RecognizeViewController ()<UITabBarDelegate,AVCapturePhotoCaptureDelegate,CommonTabViewDelegate>//AVCaptureMetadataOutputObjectsDelegate
@property(nonatomic,readwrite,strong)AVCaptureVideoPreviewLayer * previewLayer;
//@property(nonatomic,readwrite,strong) UIView * previewView;
@property(nonatomic,readwrite,strong)UIImageView * scanBox;
@property(nonatomic,readwrite,strong) AVCaptureSession * session;
@property(nonatomic,readwrite,strong) AVCapturePhotoOutput * photoOutput;
@property(nonatomic,readwrite,assign)  RecognizeType firstType;
@property(nonatomic,readwrite,assign)  RecognizeType curType;
@property(nonatomic,readwrite,assign)  BOOL isOldCustomer;
@property(nonatomic,readwrite,strong) UIView * navBarView;
@property(nonatomic, readwrite, strong) UILabel * titleLabel;
@property(nonatomic,readwrite,strong) UILabel * resultLab;
@property(nonatomic,readwrite,strong)CommonTabView * tabbar;
//@property(nonatomic,readwrite,strong)UITabBar * tabbar;

@property(nonatomic,readwrite,strong) UIImage * curImage;
@property(nonatomic,readwrite,strong) UIImageView * curPhoto;

@property(nonatomic,readwrite,strong) UIButton * captureBtn;
@property(nonatomic,readwrite,strong) UIButton * reCaptureBtn;
@property(nonatomic,readwrite,strong) UIButton * createBtn;


@property(nonatomic,readwrite,strong) NSDictionary * curData;

@property(nonatomic,readwrite,assign)  BOOL onlyVin;

@property(nonatomic,readwrite,strong) DataBase * database;

//@property(nonatomic,readwrite,strong)  NSURLSessionDataTask * curTask;


@end

@implementation RecognizeViewController

-(instancetype)initWithType:(RecognizeType)type
{
    self = [super init];
    if (self) {
        self.curType = type;
        self.firstType = type;
        if (RecognizeTypeVIN == self.firstType) {
            _onlyVin = YES;
        }else {
            _onlyVin = NO;
        }
        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor blackColor];
    
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    NSInteger Width = self.view.bounds.size.width;
    NSInteger Height = self.view.bounds.size.height;
    NSInteger statusbarH = [CommonTool statusbarH];
    
    NSInteger navBtnW = 48;
    NSInteger navBtnH = 44;
    NSInteger space = 12;
    
    _navBarView = [[UIView alloc] initWithFrame:CGRectMake(0, statusbarH, Width, 44)];
    [self.view addSubview:_navBarView];

    UIButton * backBtn = [[UIButton alloc] initWithFrame:CGRectMake(8, 0, navBtnW, navBtnH)];
    backBtn.backgroundColor = [UIColor clearColor];
    [backBtn setImage:[UIImage imageNamed:@"back_white"] forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    [_navBarView addSubview:backBtn];
    
    UIButton * recaptureRightBtn = [[UIButton alloc] initWithFrame:CGRectMake((_navBarView.bounds.size.width - navBtnW - 8), backBtn.frame.origin.y, navBtnW, navBtnH)];
    recaptureRightBtn.backgroundColor = [UIColor clearColor];
    [recaptureRightBtn setImage:[UIImage imageNamed:@"reCapture"] forState:UIControlStateNormal];
    [recaptureRightBtn addTarget:self action:@selector(reCapture) forControlEvents:UIControlEventTouchUpInside];
    [_navBarView addSubview:recaptureRightBtn];

    UIButton * showHistoryBtn = [[UIButton alloc] initWithFrame:CGRectMake((_navBarView.bounds.size.width -navBtnW-recaptureRightBtn.frame.size.width -space - 8), backBtn.frame.origin.y, navBtnW, navBtnH)];
    showHistoryBtn.backgroundColor = [UIColor clearColor];
    [showHistoryBtn setImage:[UIImage imageNamed:@"showHistory"] forState:UIControlStateNormal];
    [showHistoryBtn addTarget:self action:@selector(showHistoryList) forControlEvents:UIControlEventTouchUpInside];
    [_navBarView addSubview:showHistoryBtn];
    
    _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake((_navBarView.frame.size.width - 80)/2, 0, 80, _navBarView.frame.size.height)];
    _titleLabel.text = @"";
    _titleLabel.textColor = [UIColor whiteColor];
    _titleLabel.textAlignment = NSTextAlignmentCenter;
    _titleLabel.font =  [UIFont systemFontOfSize:18 weight:UIFontWeightSemibold];
    _titleLabel.backgroundColor = [UIColor clearColor];
    [_navBarView addSubview:_titleLabel];
    
    CommonTabItem * item1 = [[CommonTabItem alloc] initWithImagename:@"plateNo_unsel" selectedImage:@"plateNo_sel"];
    CommonTabItem * item2 = [[CommonTabItem alloc] initWithImagename:@"drivingLicence_unsel" selectedImage:@"drivingLicence_sel"];
    CommonTabItem * item3 = [[CommonTabItem alloc] initWithImagename:@"VIN_unsel" selectedImage:@"VIN_sel"];
    NSInteger bottomH = 20;
    if (![CommonTool isIPhoneXBefore]) {
        bottomH = 34;
    }
    
    _tabbar = [[CommonTabView alloc] initWithFrame:CGRectMake((Width-320)/2, (Height - 54 - bottomH), 320, 54) target:self];
    [_tabbar setItems:@[item1, item2,item3]];
    [self.view addSubview:_tabbar];
    
    [self customCamera];
    
    if (!_previewLayer) {
        
        _previewLayer.frame = CGRectMake((self.view.bounds.size.width - 336)/2, _navBarView.frame.origin.y + _navBarView.bounds.size.height + screenSize.width*20, 336, 228);
    }
    
    self.scanBox = [[UIImageView alloc] initWithFrame:CGRectMake(_previewLayer.frame.origin.x - 2, _previewLayer.frame.origin.y - 2 , _previewLayer.frame.size.width + 4, _previewLayer.frame.size.height + 4)];
    UIImage * scanImage = [UIImage imageNamed:@"scanBox"];
    UIImage * strenchImage = [scanImage resizableImageWithCapInsets:UIEdgeInsetsMake(40,40,40,40) resizingMode:UIImageResizingModeStretch];
    [self.scanBox setImage:strenchImage];
    [self.view addSubview:self.scanBox];

    self.resultLab = [[UILabel alloc] initWithFrame:CGRectMake(30, _previewLayer.frame.origin.y + _previewLayer.frame.size.height+12, self.view.bounds.size.width - 60, 120)];
    self.resultLab.textColor = [UIColor whiteColor];
    self.resultLab.textAlignment = NSTextAlignmentCenter;
    self.resultLab.font = [UIFont boldSystemFontOfSize:14];
    self.resultLab.numberOfLines = 0;
    [self.view addSubview:self.resultLab];

    NSInteger captureY = ((_previewLayer.frame.origin.y + _previewLayer.frame.size.height) + _tabbar.frame.origin.y)/2;
    _captureBtn = [[UIButton alloc] initWithFrame:CGRectMake((Width-160)/2, screenSize.height - 46 - screenSize.height*0.25, 160, 46)];
    _captureBtn.backgroundColor = [UIColor colorWithRed:252/255.0 green:215/255.0 blue:139/255.0 alpha:1];
    [_captureBtn setTitle:@"开始识别" forState:UIControlStateNormal];
    [_captureBtn setTitleColor:[UIColor colorWithRed:2/255.0 green:2/255.0 blue:2/255.0 alpha:1] forState:UIControlStateNormal];
    _captureBtn.titleLabel.font = [UIFont fontWithName:@"PingFang SC" size:18];
    _captureBtn.layer.cornerRadius = 4;
    [_captureBtn addTarget:self action:@selector(takePicture) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_captureBtn];
   
    NSInteger recaptureH = ((_resultLab.frame.origin.y + _resultLab.frame.size.height) + _tabbar.frame.origin.y)/2;
    _reCaptureBtn = [[UIButton alloc] initWithFrame:_captureBtn.frame];
    _reCaptureBtn.backgroundColor = [UIColor colorWithRed:252/255.0 green:215/255.0 blue:139/255.0 alpha:1];
    [_reCaptureBtn setTitle:@"重新识别" forState:UIControlStateNormal];
    [_reCaptureBtn setTitleColor:[UIColor colorWithRed:2/255.0 green:2/255.0 blue:2/255.0 alpha:1] forState:UIControlStateNormal];
    _reCaptureBtn.titleLabel.font = [UIFont fontWithName:@"PingFang SC" size:18];
    _reCaptureBtn.layer.cornerRadius = 4;
    [_reCaptureBtn addTarget:self action:@selector(reCapture) forControlEvents:UIControlEventTouchUpInside];
    _reCaptureBtn.hidden = YES;
    [self.view addSubview:_reCaptureBtn];
    
    _createBtn = [[UIButton alloc] initWithFrame:_reCaptureBtn.frame];
    _createBtn.backgroundColor = [UIColor colorWithRed:252/255.0 green:215/255.0 blue:139/255.0 alpha:1];
    [_createBtn setTitle:@"去创建" forState:UIControlStateNormal];
    [_createBtn setTitleColor:[UIColor colorWithRed:2/255.0 green:2/255.0 blue:2/255.0 alpha:1] forState:UIControlStateNormal];
    _createBtn.titleLabel.font = [UIFont fontWithName:@"PingFang SC" size:18];
    _createBtn.layer.cornerRadius = 4;
    [_createBtn addTarget:self action:@selector(create) forControlEvents:UIControlEventTouchUpInside];
    _createBtn.hidden = YES;
    [self.view addSubview:_createBtn];

    self.isOldCustomer = NO;
    
    [_tabbar setIndex:self.firstType];

    [self addGestureRecognizer];
}

-(void)addGestureRecognizer
{
    UISwipeGestureRecognizer * swipeRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeRightGesture:)];
    swipeRight.direction = UISwipeGestureRecognizerDirectionRight;
    [self.view addGestureRecognizer:swipeRight];
    
    UISwipeGestureRecognizer * swipeLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeLeftGesture:)];
    swipeLeft.direction = UISwipeGestureRecognizerDirectionLeft;
    [self.view addGestureRecognizer:swipeLeft];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self prefersStatusBarHidden];
    [self.resultLab addObserver:self forKeyPath:@"text" options:NSKeyValueObservingOptionNew context:NULL];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self prefersStatusBarHidden];
    [self.resultLab removeObserver:self forKeyPath:@"text"];
}

-(void)layoutResultLable
{
    NSString * text = self.resultLab.text;
    CGFloat textH = [CommonTool labelAutoCalculateRectWith:text FontSize:14 MaxSize:CGSizeMake(self.view.bounds.size.width - 60, 150)];
    NSInteger Y = (self.previewLayer.frame.origin.y +  self.previewLayer.frame.size.height + self.captureBtn.frame.origin.y)/2 - textH/2;
    self.resultLab.frame = CGRectMake(self.resultLab.frame.origin.x, Y, self.view.bounds.size.width - 60, textH);
}

-(void)handleSwipeRightGesture:(UIGestureRecognizer*)gestureRecognizer
{
    switch (self.tabbar.index) {
        case 0:
        {
            [self.navigationController popViewControllerAnimated:YES];
        }
            break;
        case 1:
        {
            [self.tabbar setIndex:0];
            [self impactFeedback];
        }
            break;
        case 2:
        {
            [self.tabbar setIndex:1];
            [self impactFeedback];
        }
            break;
        default:
            break;
    }
    
}


-(void)handleSwipeLeftGesture:(UIGestureRecognizer*)gestureRecognizer
{
    switch (self.tabbar.index) {
        case 0:
        {
            [self.tabbar setIndex:1];
            [self impactFeedback];
        }
            break;
        case 1:
        {
            [self.tabbar setIndex:2];
            [self impactFeedback];
        }
            break;
        default:
            break;
    }
    
}
-(void)impactFeedback
{
    UIImpactFeedbackGenerator * feed = [[UIImpactFeedbackGenerator alloc] initWithStyle:UIImpactFeedbackStyleMedium];
    [feed impactOccurred];
    
}

-(void)customCamera
{
    AVCaptureDevice * device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    NSError * error = nil;
    AVCaptureDeviceInput * input = [AVCaptureDeviceInput  deviceInputWithDevice:device error:&error ];
    if (error) {
        return;
    }
    AVCaptureMetadataOutput * output = [[AVCaptureMetadataOutput alloc] init];
    [output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
//        output.rectOfInterest = CGRectMake(0.05, 0.2, 0.7, 0.6);
//        output.rectOfInterest = CGRectMake(0.05, 0.2, 0.7, 0.6);
    
    _photoOutput = [[AVCapturePhotoOutput alloc] init];
    self.session = [[AVCaptureSession alloc] init];
    [self.session addInput:input];
    [self.session addOutput:_photoOutput];

    _previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:self.session];
    _previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    _previewLayer.frame = CGRectMake((self.view.bounds.size.width - 336)/2, _navBarView.frame.origin.y + _navBarView.bounds.size.height + 48, 336, 228);
//    _previewLayer.frame = CGRectMake(0, 0, self.previewView.frame.size.width, self.previewView.frame.size.height);
    [self.view.layer insertSublayer:_previewLayer atIndex:0];
    [self.session startRunning];
    self.curPhoto = [[UIImageView alloc] initWithFrame:_previewLayer.frame];
    self.curPhoto.contentMode = UIViewContentModeScaleAspectFill;
    self.curPhoto.layer.masksToBounds = YES;
    self.curPhoto.hidden = YES;
    [self.view addSubview:_curPhoto];

}

-(void)reCapture
{
    [[NetWorkAPIManager defaultManager] cancelRequest];
    _curPhoto.hidden = YES;
    _captureBtn.hidden = NO;
    _createBtn.hidden = YES;
    _reCaptureBtn.hidden = YES;
    _resultLab.text = @"";
    _curPhoto.hidden = YES;
}

-(void)showHistoryList
{
    RecordListViewController * listCtrl = [[RecordListViewController alloc] init];
    [self.navigationController pushViewController:listCtrl animated:YES];
    
}

-(void)setIsOldCustomer:(BOOL)isOldCustomer
{
    if (isOldCustomer) {
        [_createBtn setTitle:@"去开单" forState:UIControlStateNormal];
    }else {
        [_createBtn setTitle:@"去创建" forState:UIControlStateNormal];
    }
}


-(void)setCurType:(RecognizeType)curType
{
    if (_curType != curType) {
        [self reCapture];
    }
    _curType = curType;
    
    CGPoint pt = self.curPhoto.center;
    switch (_curType) {
        case RecognizeTypePlateNO:
        {
            CGRect frame = self.previewLayer.frame;
            self.previewLayer.frame = CGRectMake(frame.origin.x, pt.y - 57, frame.size.width, 114);
            self.curPhoto.frame = self.previewLayer.frame;
            self.scanBox.frame = CGRectMake(_previewLayer.frame.origin.x - 2, _previewLayer.frame.origin.y - 2 , _previewLayer.frame.size.width + 4, _previewLayer.frame.size.height + 4);
        }
            break;
        case RecognizeTypeDrivingLicence:
        {
            CGRect frame = self.previewLayer.frame;
            self.previewLayer.frame = CGRectMake(frame.origin.x, pt.y - 114, frame.size.width, 228);
            self.curPhoto.frame = self.previewLayer.frame;
            self.scanBox.frame = CGRectMake(_previewLayer.frame.origin.x - 2, _previewLayer.frame.origin.y - 2 , _previewLayer.frame.size.width + 4, _previewLayer.frame.size.height + 4);
        }
            break;
        case RecognizeTypeVIN:
        {
            CGRect frame = self.previewLayer.frame;
            self.previewLayer.frame = CGRectMake(frame.origin.x, pt.y - 57, frame.size.width, 114);
            self.curPhoto.frame = self.previewLayer.frame;
            self.scanBox.frame = CGRectMake(_previewLayer.frame.origin.x - 2, _previewLayer.frame.origin.y - 2 , _previewLayer.frame.size.width + 4, _previewLayer.frame.size.height + 4);
        }
            break;
            
        default:
            break;
    }
    
}

    
-(void)create
{
    [self goBackToMainVCWithData:_curData];
}


-(void)tabview:(CommonTabView *)tabview indexChanged:(NSInteger )index
{
    switch (index) {
        case 0:
        {
            self.curType = RecognizeTypePlateNO;
        }
            break;
        case 1:
        {
            self.curType = RecognizeTypeDrivingLicence;
        }
            break;
        case 2:
        {
            self.curType = RecognizeTypeVIN;
        }
            break;
        default:
            break;
    }
}


#pragma camera
-(void)takePicture
{
    _captureBtn.hidden = YES;
    NSDictionary *setDic = @{AVVideoCodecKey:@"jpeg"};//AVVideoQualityKey:[NSNumber numberWithFloat:0.5]
    AVCapturePhotoSettings *set = [AVCapturePhotoSettings photoSettingsWithFormat:setDic];
//    set.previewPhotoFormat = @{kCVPixelBufferWidthKey: [NSNumber numberWithFloat:self.previewLayer.frame.size.width*[UIScreen mainScreen].scale],kCVPixelBufferHeightKey:[NSNumber numberWithFloat:self.previewLayer.frame.size.height*[UIScreen mainScreen].scale]};
    [_photoOutput capturePhotoWithSettings:set delegate:self];
    self.resultLab.text = @"识别中...";
        
}

//拍照识别
//-(void)captureOutput:(AVCapturePhotoOutput *)output didFinishProcessingPhoto:(AVCapturePhoto *)photo error:(NSError *)error  API_AVAILABLE(ios(11.0)) {
//    if (!error) {
//        // 使用该方式获取图片，可能图片会存在旋转问题，在使用的时候调整图片即可
//        NSData *data = [photo fileDataRepresentation];
//        _curImage = [UIImage imageWithData:data];
//        [_curPhoto setImage:_curImage];
//        _curPhoto.hidden = NO;
//        NSData *imgData = UIImageJPEGRepresentation(_curImage, 1);
//        [self recognize:imgData needQuery:!_onlyVin];
//    }
//}
- (void)captureOutput:(AVCapturePhotoOutput *)output didFinishProcessingPhotoSampleBuffer:(nullable CMSampleBufferRef)photoSampleBuffer previewPhotoSampleBuffer:(nullable CMSampleBufferRef)previewPhotoSampleBuffer resolvedSettings:(AVCaptureResolvedPhotoSettings *)resolvedSettings bracketSettings:(nullable AVCaptureBracketedStillImageSettings *)bracketSettings error:(nullable NSError *)error
{
    if (!error) {
        NSData *data = [AVCapturePhotoOutput JPEGPhotoDataRepresentationForJPEGSampleBuffer:photoSampleBuffer previewPhotoSampleBuffer:previewPhotoSampleBuffer];
        UIImage * image = [UIImage imageWithData:data];
        CGFloat scale = [UIScreen mainScreen].scale;
        CGRect rect = self.previewLayer.frame;
        UIImage * clipimage = [self clipImage:image withSize:CGSizeMake(rect.size.width*scale, rect.size.height*scale)];

        _curImage = clipimage;

        [_curPhoto setImage:_curImage];
        _curPhoto.hidden = NO;
//        UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
        NSData *imgData = UIImageJPEGRepresentation(_curImage, 1);
        [self recognize:imgData needQuery:!_onlyVin];
    }
}

//居中裁剪图片
-(UIImage *)clipImage:(UIImage *)image withSize:(CGSize)size
{
    CGFloat width = size.width;
    CGFloat height = size.height;
    
    CGFloat x = (image.size.width - size.width)/2;
    CGFloat y = (image.size.height - size.height)/2;
    
    CGRect croprect = CGRectMake(floor(x), floor(y), round(width), round(height));
    
    UIImage *toCropImage = [image fixOrientation];// 纠正方向

    CGImageRef cgImage = CGImageCreateWithImageInRect(toCropImage.CGImage, croprect);
        
    UIImage *cropped = [UIImage imageWithCGImage:cgImage];
        
    CGImageRelease(cgImage);
        
    return cropped;
    
}

-(UIImage *)imageFromImage:(UIImage *)image inRect:(CGRect)rect
{
    CGFloat x = rect.origin.x;
    CGFloat y = rect.origin.y;
        
    CGFloat width = rect.size.width;
        
    CGFloat height = rect.size.height;
        
    CGRect croprect = CGRectMake(floor(x), floor(y), round(width), round(height));
        
    UIImage *toCropImage = [image fixOrientation];// 纠正方向

    CGImageRef cgImage = CGImageCreateWithImageInRect(toCropImage.CGImage, croprect);
        
    UIImage *cropped = [UIImage imageWithCGImage:cgImage];
        
    CGImageRelease(cgImage);
        
    return cropped;
}

-(void)recognize:(NSData *)imgData needQuery:(BOOL)needquery
{
    __weak RecognizeViewController * weakself = self;
    NetWorkAPIManager * manager = [NetWorkAPIManager defaultManager];
    [manager imageRecognizeWithData:imgData Type:_curType success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSError*err;
        NSDictionary*resultDic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:&err];
        NSString * text = @"";
        NSArray * array = [resultDic objectForKey:@"data"];
        
        NSMutableDictionary * parm = [NSMutableDictionary dictionary];
        NSString * plateno = @"";
        NSString * name = @"";
        NSString * vin = @"";
        
        switch (_curType) {
            case RecognizeTypePlateNO:
            {
                plateno = [array firstObject];
                [parm setValue:plateno forKey:@"plateNo"];
                text = plateno;
            }
                break;
            case RecognizeTypeDrivingLicence:
            {
                NSDictionary * data = [array firstObject];
                name = [data objectForKey:@"owner"];
                plateno = [data objectForKey:@"plate_num"];
                vin = [data objectForKey:@"vin"];
                
                NSString * model = [self getVehicleModelString:[data objectForKey:@"model"]];
                NSString * vehicletype = [data objectForKey:@"vehicle_type"];
                NSString * address = [data objectForKey:@"addr"];
                NSString * driverLicenceFirstUrls = [data objectForKey:@"url"];//识别图片url
                NSString * engineNumber = [data objectForKey:@"engine_num"];
                NSString * purchasingDate = [data objectForKey:@"register_date"];
                NSString * issuedate = [data objectForKey:@"issue_date"];
                
                text = [NSString stringWithFormat:@"%@ %@\r\r%@",name,plateno,vin];
                
                [parm setValue:plateno forKey:@"plateNo"];
                [parm setValue:name forKey:@"ownerName"];
                [parm setValue:vin forKey:@"vin"];
                [parm setValue:vehicletype forKey:@"type"];
                [parm setValue:model forKey:@"vehicleSpec"];
                [parm setValue:@[driverLicenceFirstUrls] forKey:@"driverLicenceFirstUrls"];
                [parm setValue:engineNumber forKey:@"engineNumber"];
                [parm setValue:purchasingDate forKey:@"purchasingDate"];
                [parm setValue:address forKey:@"address"];
            }
                break;
            case RecognizeTypeVIN:
            {
                NSDictionary * vinDic = [array firstObject];
                vin = [vinDic objectForKey:@"vin"];
                [parm setValue:vin forKey:@"vin"];
                text = vin;
                
            }
                break;
                
            default:
                break;
        }
        
        _curData = parm;
        
        [[DataBase defaultDataBase] openRecognizeList];
        [[DataBase defaultDataBase] insertARecognize:weakself.curType plateNo:plateno name:name vin:vin];
        if (needquery) {
            [self queryInfoWithName:name plateNo:plateno vin:vin];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            weakself.resultLab.text = text;
            weakself.curData = parm;
            weakself.createBtn.hidden = NO;
        });
        
//        [self.database insertARecognize:self.curType plateNo:plateno name:name vin:vin];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (error.code != NSURLErrorCancelled) {
            weakself.resultLab.text = @"无法识别";
            weakself.reCaptureBtn.hidden = NO;
        }
        
    }];
}


//直接返回上一级页面，上级页面的输入保持不变
-(void)back
{
    [self.navigationController popViewControllerAnimated:YES];
}

//返回接车页面并传值
- (void)goBackToMainVCWithData:(NSDictionary *) data {
    [self.delegate recognize:self withResult:data];
    [self.navigationController popToRootViewControllerAnimated:YES];
}

//查询车辆信息
-(void)queryInfoWithName:(NSString *)name plateNo:(NSString *)plateNo vin:(NSString *)vin
{
    __weak RecognizeViewController * weakself = self;
    NetWorkAPIManager * manager = [NetWorkAPIManager defaultManager];
    [manager queryVehicleInfo:name plateNo:plateNo vin:vin success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary * resp = responseObject;
        NSArray * array = [resp objectForKey:@"data"];
        NSString * text = @"";

        if ([array count] > 0) {
            
            NSDictionary * data = [array firstObject];
            _curData = data;
            
            NSString * rplateno = [data objectForKey:@"plateNo"];
            NSString * rvin = [data objectForKey:@"vin"];
            NSDictionary * owner = [data objectForKey:@"owner"];
            NSString * rname = [owner objectForKey:@"name"];
            if (!rname) {
                rname = @"";
            }
            if (!rplateno) {
                rplateno = @"";
            }
            text = [NSString stringWithFormat:@"%@ %@",rname,[CommonTool getPlateNoSpaceString:rplateno]];
            if (rvin) {
                text = [text stringByAppendingString:[NSString stringWithFormat:@"\r\r%@",[CommonTool getVinSpaceString:rvin]]];
            }
            text = [text stringByAppendingString:[NSString stringWithFormat:@"\r\r%@",@"老客户"]];
            weakself.isOldCustomer  = YES;
            
        }else {
            NSString * oldText = weakself.resultLab.text;
            text = [oldText stringByAppendingString:[NSString stringWithFormat:@"\r\r%@",@"新客户"]];
            weakself.isOldCustomer  = NO;
        }
        weakself.resultLab.text = text;

    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {

    }];

}

-(void)networkStatusChanged:(AFNetworkReachabilityStatus)status
{
    if (self.isNetworkOn) {
        self.titleLabel.text = @"";
    }else {
        self.titleLabel.text = [NSString stringWithFormat:@"%@",TEXT_NETWORKOFF];
    }
}


//
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    [self layoutResultLable];
    
}

//行驶证车型扫描结果中车型字符串(xx牌xx)转换(xx/xx)
-(NSString *)getVehicleModelString:(NSString*)modelString
{
    NSString * vehicleModelString = [modelString stringByReplacingOccurrencesOfString:@"牌" withString:@"/"];
    return vehicleModelString;
}


@end
