//
//  ExperienceViewController.m
//  EnochCar
//
//  Created by 王海燕 on 2021/7/22.
//

#import "ExperienceViewController.h"
#import "ApplyViewController.h"
#import "CommonDefine.h"
#import "BannerView.h"
#import "UIView+Hint.h"
#import "CommonTool.h"
#import "BlackLabel.h"
#import "PlayerViewController.h"
#import "NetWorkAPIManager.h"
#import <SDWebImage/SDWebImage.h>



#define TAG_BANNER_LEARING 11
#define TAG_BANNER_SEVICE 12

#define TELEPHONE @"400-996-0171"
#define VIDEO_LEARN_URLSTRING  @"https://enocherp-oss01.oss-cn-hangzhou.aliyuncs.com/video/Winter%20Trial%202020%20_%20First%20Class%20Autorepair.mp4"
#define VIDEO_PD_URLSTRING  @"https://resource.enoch-car.com/video/erp_mobile_PD_video.m4v"

#define BANNER_SEVICE_TEXT_1  @"扫描车牌、行驶证、VIN可以快速进行开单、创建客户、查看历史、找到配件信息，我们比同行扫描精准度提高20%，汽修开单效率提高近30%。"
#define BANNER_SEVICE_TEXT_2  @"汽修厂90%的业务营收来源，以诺行车管家APP可以快速移动操作接车整个流程，与系统实时同步，随时随地可以操作维修业务。"
#define BANNER_SEVICE_TEXT_3  @"维修中的配件状态一目了然，保证了每辆维修车辆的配件精确无误，减少退料、领料等环节的复杂操作，仓管能更快的获得配件信息处理。较同行效率提高30%以上。"

@interface ExperienceViewController ()<BannerViewDelegate>
@property (strong, nonatomic) UIScrollView * scrollview;
@property (strong, nonatomic) UIButton * switchToLoginBtn;

@property (strong, nonatomic) UIView * View1;
@property (strong, nonatomic) IBOutlet BannerView *learningBanner;
@property (strong, nonatomic) UIView * View2;
@property (strong, nonatomic) IBOutlet BannerView *serviceBanner;
@property (strong, nonatomic) UILabel * view2Lab;
@property (strong, nonatomic) UIView * View3;
@property (strong, nonatomic) UIView * View4;
@property (strong, nonatomic) UIView * View5;
@property (strong, nonatomic) UIView * View6;

@property (strong, nonatomic) NSArray * videoResources;

@end

@implementation ExperienceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    CGFloat width = self.view.frame.size.width;
    CGFloat height = self.view.frame.size.height;
    CGFloat space = 12;
    CGFloat left = 20;
    CGFloat right = 20;
    CGFloat statusbarH = [CommonTool statusbarH];
    CGFloat titleLabH = 25;
    CGFloat bannerW = width - left - right;
    CGFloat bannerH = bannerW * 180/335.0 + 20;
    
    UIFont * titleFont = [UIFont systemFontOfSize:18 weight:UIFontWeightSemibold];
    UIColor * titleColor = [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1];
    UIFont * longLabFont = [UIFont systemFontOfSize:14];
    
    NSMutableParagraphStyle * paragraphStyle1 = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle1 setLineSpacing:12];
    NSDictionary *attributes = @{NSFontAttributeName: longLabFont,NSParagraphStyleAttributeName: paragraphStyle1};
    
    BannerItem * item1 = [[BannerItem alloc] initWithImageName:@"sevice_banner_1" imageURL:nil title:nil];
    BannerItem * item2 = [[BannerItem alloc] initWithImageName:@"sevice_banner_2" imageURL:nil title:nil];
    BannerItem * item3 = [[BannerItem alloc] initWithImageName:@"sevice_banner_3" imageURL:nil title:nil];
    
    _scrollview = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, width, height)];
    _scrollview.backgroundColor = [UIColor whiteColor];
    _scrollview.showsVerticalScrollIndicator = NO;
    _scrollview.showsHorizontalScrollIndicator = NO;
    [self.view addSubview:_scrollview];
    
    UIButton * switchToLoginBtn = [[UIButton alloc] initWithFrame:CGRectMake(width - 100 - right, 8 , 100, 28)];
    [switchToLoginBtn setImage:[UIImage imageNamed:@"switchlogin"] forState:UIControlStateNormal];
    [switchToLoginBtn addTarget:self action:@selector(toLogin:) forControlEvents:UIControlEventTouchUpInside];
    [_scrollview addSubview:switchToLoginBtn];
    
    _View1 = [[UIView alloc] initWithFrame:CGRectMake(0, switchToLoginBtn.frame.origin.y + switchToLoginBtn.frame.size.height + 22, width, bannerH + titleLabH +2*space)];
    [_scrollview addSubview:_View1];
    UILabel * viewlTitle = [[UILabel alloc] initWithFrame:CGRectMake(left, 0, 100, titleLabH)];
    viewlTitle.text = @"行业学习";
    viewlTitle.font = titleFont;
    viewlTitle.textColor = titleColor;
    viewlTitle.textAlignment = NSTextAlignmentLeft;
    [_View1 addSubview:viewlTitle];
    _learningBanner = [[BannerView alloc] initWithFrame:CGRectMake(left, viewlTitle.frame.origin.y + viewlTitle.frame.size.height + space, bannerW, bannerH)];
    
    
    self.learningBanner.tag = TAG_BANNER_LEARING;
//    [self.learningBanner setDataArray:[NSArray arrayWithObjects:item1,item2,item3,nil]];
    self.learningBanner.delegate = self;
    [_View1 addSubview:_learningBanner];
    
    _View2 = [[UIView alloc] initWithFrame:CGRectMake(0, _View1.frame.origin.y + _View1.frame.size.height + 49, width, bannerH + titleLabH +2*space)];
    [_scrollview addSubview:_View2];
    UILabel * view2Title = [[UILabel alloc] initWithFrame:CGRectMake(left, 0, 100, titleLabH)];
    view2Title.text = @"汽修管家";
    view2Title.font = titleFont;
    view2Title.textColor = titleColor;
    view2Title.textAlignment = NSTextAlignmentLeft;
    [_View2 addSubview:view2Title];
    UIButton * applyBtn = [[UIButton alloc] initWithFrame:CGRectMake(_View2.frame.size.width - right - 80, 0, 80, 28)];
    applyBtn.backgroundColor = [UIColor colorWithRed:252/255.0 green:215/255.0 blue:139/255.0 alpha:1];
    applyBtn.layer.cornerRadius = 2;
    [applyBtn setTitle:@"申请开通" forState:UIControlStateNormal];
    [applyBtn setTitleColor:titleColor forState:UIControlStateNormal];
    applyBtn.titleLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightSemibold];
    [applyBtn addTarget:self action:@selector(apply:) forControlEvents:UIControlEventTouchUpInside];
    
    [_View2 addSubview:applyBtn];
    _serviceBanner = [[BannerView alloc] initWithFrame:CGRectMake(left, view2Title.frame.origin.y + view2Title.frame.size.height + 14, bannerW, bannerH)];
    
    self.serviceBanner.tag = TAG_BANNER_SEVICE;
    [self.serviceBanner setDataArray:[NSArray arrayWithObjects:item1,item2,item3,nil]];
    self.serviceBanner.delegate = self;
    [_View2 addSubview:_serviceBanner];
    
    CGFloat labW = _View2.frame.size.width - left - right;
    NSString * view2labStr = BANNER_SEVICE_TEXT_1;
    NSMutableAttributedString * attributedString1 = [[NSMutableAttributedString alloc] initWithString:view2labStr];
    [attributedString1 addAttributes:attributes range:NSMakeRange(0, [view2labStr length])];
    CGRect labRect = [attributedString1 boundingRectWithSize:CGSizeMake(labW, 200) options:NSStringDrawingUsesLineFragmentOrigin context:nil];
    
    _view2Lab = [[UILabel alloc] initWithFrame:CGRectMake(left, _serviceBanner.frame.origin.y + _serviceBanner.frame.size.height + space, labRect.size.width, labRect.size.height)];
    _view2Lab.font = longLabFont;
    _view2Lab.textColor = titleColor;
    _view2Lab.textAlignment = NSTextAlignmentLeft;
    _view2Lab.numberOfLines = 0;
    
    [_view2Lab setAttributedText:attributedString1];
    [_View2 addSubview:_view2Lab];
    [_View2 setFrame:CGRectMake(0, _View1.frame.origin.y + _View1.frame.size.height + 49, width, _view2Lab.frame.origin.y + _view2Lab.frame.size.height + 2)];
    
    
    _View3 = [[UIView alloc] initWithFrame:CGRectMake(0, _View2.frame.origin.y + _View2.frame.size.height + 49, width, bannerH + titleLabH +2*space)];
    [_scrollview addSubview:_View3];
    UILabel * view3Title = [[UILabel alloc] initWithFrame:CGRectMake(left, 0, 200, titleLabH)];
    view3Title.text = @"智能";
    view3Title.font = titleFont;
    view3Title.textColor = titleColor;
    view3Title.textAlignment = NSTextAlignmentLeft;
    [_View3 addSubview:view3Title];
    
    UIImage * image1 = [UIImage imageNamed:@"model_1"];
    CGFloat imageW = width - left - right;
    CGFloat imageH = imageW * image1.size.height/image1.size.width;
    UIImageView * imageview1 = [[UIImageView alloc] initWithFrame:CGRectMake(left, view3Title.frame.origin.y + view3Title.frame.size.height + space, imageW, imageH)];
    [imageview1 setImage:image1];
    [_View3 addSubview:imageview1];
    
    UIImage * image2 = [UIImage imageNamed:@"model_2"];
    CGFloat image2W = width - left - right;
    CGFloat image2H = imageW * image2.size.height/image2.size.width;
    UIImageView * imageview2 = [[UIImageView alloc] initWithFrame:CGRectMake(left, imageview1.frame.origin.y + imageview1.frame.size.height + space, image2W, image2H)];
    [imageview2 setImage:image2];
    [_View3 addSubview:imageview2];
    
    NSString * view3labStr = @"业务与财务增长模型，是以客户资源为中心的驱动模型，可以处理汽修企业管理漏洞，有效提升整体增长，共有9个模块，28个业务组组成，分为外部与内部环境综合计算的结果。";
    NSMutableAttributedString * view3labAttrStr = [[NSMutableAttributedString alloc] initWithString:view3labStr];
    [view3labAttrStr addAttributes:attributes range:NSMakeRange(0, view3labStr.length)];
    CGRect labRect3 = [view3labAttrStr boundingRectWithSize:CGSizeMake(labW, 200) options:NSStringDrawingUsesLineFragmentOrigin context:nil];
    UILabel * view3Lab = [[UILabel alloc] initWithFrame:CGRectMake(left, imageview2.frame.origin.y + imageview2.frame.size.height + space, labRect3.size.width, labRect3.size.height)];
    view3Lab.font = longLabFont;
    view3Lab.textColor = titleColor;
    view3Lab.textAlignment = NSTextAlignmentLeft;
    view3Lab.numberOfLines = 0;
    view3Lab.attributedText = view3labAttrStr;
    [_View3 addSubview:view3Lab];
    
    [_View3 setFrame:CGRectMake(0, _View2.frame.origin.y + _View2.frame.size.height + 49, width, view3Lab.frame.origin.y + view3Lab.frame.size.height)];
    
    _View4 = [[UIView alloc] initWithFrame:CGRectMake(0, _View3.frame.origin.y + _View3.frame.size.height + 48, width, 102)];
    [_scrollview addSubview:_View4];
    UILabel * view4Title = [[UILabel alloc] initWithFrame:CGRectMake(left, 0, 200, titleLabH)];
    view4Title.text = @"服务";
    view4Title.font = titleFont;
    view4Title.textColor = titleColor;
    [_View4 addSubview:view4Title];
    
    CGFloat seviceImageW = 84.0;
    CGFloat seviceImageH = 52.0;
    CGFloat seviceSpace = (width - left - right - 4*seviceImageW)/3;
    for (int i = 1; i < 5; i++) {
        UIImageView * sevice = [[UIImageView alloc] initWithFrame:CGRectMake(left + (seviceImageW + seviceSpace)*(i-1), view4Title.frame.origin.y + view4Title.frame.size.height + 24, seviceImageW, seviceImageH)];
        sevice.image = [UIImage imageNamed:[NSString stringWithFormat:@"service_%d",i]];
        [_View4 addSubview:sevice];
    }
    
    _View5 = [[UIView alloc] initWithFrame:CGRectMake(0, _View4.frame.origin.y + _View4.frame.size.height + 48, width, 148)];
    [_scrollview addSubview:_View5];
    UILabel * view5Title = [[UILabel alloc] initWithFrame:CGRectMake(left, 0, 200, titleLabH)];
    view5Title.text = @"合作伙伴";
    view5Title.font = titleFont;
    view5Title.textColor = titleColor;
    [_View5 addSubview:view5Title];
    
    CGFloat blacklabW = 148;
    CGFloat blacklabH = 43;
    BlackLabel * blackLab1 = [[BlackLabel alloc] initWithFrame:CGRectMake(left, view5Title.frame.origin.y + view5Title.frame.size.height + 24, blacklabW, blacklabH)];
    blackLab1.text = @"平湖诚信汽修";
    [_View5 addSubview:blackLab1];
    BlackLabel * blackLab2 = [[BlackLabel alloc] initWithFrame:CGRectMake(width - right - blacklabW, blackLab1.frame.origin.y, blacklabW, blacklabH)];
    blackLab2.text = @"通辽鑫东城";
    [_View5 addSubview:blackLab2];
    BlackLabel * blackLab3 = [[BlackLabel alloc] initWithFrame:CGRectMake(left, blackLab1.frame.origin.y + blackLab1.frame.size.height + space, blacklabW, blacklabH)];
    blackLab3.text = @"成都中圆汽修";
    [_View5 addSubview:blackLab3];
    BlackLabel * blackLab4 = [[BlackLabel alloc] initWithFrame:CGRectMake(blackLab2.frame.origin.x, blackLab3.frame.origin.y , blacklabW, blacklabH)];
    blackLab4.text = @"金华名仕行汽修";
    [_View5 addSubview:blackLab4];
    
    _View6 = [[UIView alloc] initWithFrame:CGRectMake(0, _View5.frame.origin.y + _View5.frame.size.height + 48, width, 286)];
    [_scrollview addSubview:_View6];
    UILabel * view6Title = [[UILabel alloc] initWithFrame:CGRectMake(left, 0, 200, titleLabH)];
    view6Title.text = @"联系我们";
    view6Title.font = titleFont;
    view6Title.textColor = titleColor;
    [_View6 addSubview:view6Title];
    UILabel * telephoneLab = [[UILabel alloc] initWithFrame:CGRectMake(left, view6Title.frame.origin.y + view6Title.frame.size.height + 24, _View6.frame.size.width - left - right, 20)];
    NSString * telephoneText = @"电话号码：";
    NSString * telephone = TELEPHONE;
    NSString * telephoneStr = [NSString stringWithFormat:@"%@%@", telephoneText, telephone];
    NSMutableAttributedString * telephoneAttrText = [[NSMutableAttributedString alloc] initWithString:telephoneStr];
    NSDictionary * attributes1 = [NSDictionary dictionaryWithObjects:@[[UIFont systemFontOfSize:14 weight:UIFontWeightSemibold],titleColor] forKeys:@[NSFontAttributeName,NSForegroundColorAttributeName]];
    [telephoneAttrText addAttributes:attributes1 range:[telephoneStr rangeOfString:telephoneText]];
    NSDictionary * attributes2 = [NSDictionary dictionaryWithObjects:@[[UIFont systemFontOfSize:14 weight:UIFontWeightRegular],[UIColor colorWithRed:89/255.0 green:156/255.0 blue:255/255.0 alpha:1] ] forKeys:@[NSFontAttributeName,NSForegroundColorAttributeName]];
    [telephoneAttrText addAttributes:attributes2 range:[telephoneStr rangeOfString:telephone]];
    telephoneLab.attributedText = telephoneAttrText;
    [_View6 addSubview:telephoneLab];
    UIButton * dailBtn = [[UIButton alloc] initWithFrame:telephoneLab.frame];
    [dailBtn addTarget:self action:@selector(dail:) forControlEvents:UIControlEventTouchUpInside];
    [_View6 addSubview:dailBtn];
    
    
    UILabel * emailLab = [[UILabel alloc] initWithFrame:CGRectMake(left, telephoneLab.frame.origin.y + telephoneLab.frame.size.height + 12, _View6.frame.size.width - left - right, 20)];
    NSString * emailText = @"电子邮箱：";
    NSString * email = @"enoch@enoch-car.com";
    NSString * emailStr = [NSString stringWithFormat:@"%@%@", emailText, email];
    NSMutableAttributedString * emailAttrText = [[NSMutableAttributedString alloc] initWithString:emailStr];
    NSDictionary * attributes3 = [NSDictionary dictionaryWithObjects:@[[UIFont systemFontOfSize:14 weight:UIFontWeightSemibold],titleColor] forKeys:@[NSFontAttributeName,NSForegroundColorAttributeName]];
    [emailAttrText addAttributes:attributes3 range:[emailStr rangeOfString:emailText]];
    NSDictionary * attributes4 = [NSDictionary dictionaryWithObjects:@[[UIFont systemFontOfSize:14 weight:UIFontWeightRegular],titleColor] forKeys:@[NSFontAttributeName,NSForegroundColorAttributeName]];
    [emailAttrText addAttributes:attributes4 range:[emailStr rangeOfString:email]];
    emailLab.attributedText = emailAttrText;
    [_View6 addSubview:emailLab];
    
    
    _scrollview.contentSize = CGSizeMake(_scrollview.frame.size.width, _View6.frame.origin.y + _View6.frame.size.height);
    [self getResource];
}

-(void)getResource
{
    __weak ExperienceViewController  * weakself = self;
    [[NetWorkAPIManager defaultManager] getVideoResourceSuccess:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary * dic = responseObject;
        self.videoResources = [dic objectForKey:@"data"];
        NSMutableArray * array = [NSMutableArray array];
        for (NSDictionary * adata in self.videoResources) {
            //根据视频url获取帧截图
            NSString * videoURL = [adata objectForKey:@"url"];
            BannerItem * item = [[BannerItem alloc] initWithVideoURL:videoURL title:[adata objectForKey:@"name"]];
            [array addObject:item];
        }

        dispatch_async(dispatch_get_main_queue(), ^{
            [weakself.learningBanner setDataArray:array];
        });
       
        
    } Failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        NSMutableArray * array = [NSMutableArray array];
        BannerItem * item = [[BannerItem alloc] initWithImageName:@"banner_placeholder_image" imageURL:nil title:nil];
        [array addObject:item];
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakself.learningBanner setDataArray:array];
        });
    }];
    
}

-(void)dail:(id)sender
{
    NSString * string = [NSString stringWithFormat:@"telprompt://%@",TELEPHONE];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:string]];
}

- (IBAction)toLogin:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

//申请开通账号
- (IBAction)apply:(id)sender {
    ApplyViewController * applyCtrl = [[ApplyViewController alloc] init];
    [self.navigationController pushViewController:applyCtrl animated:YES];
}

-(void)bannerView:(BannerView*)banner pageChanged:(NSInteger)curpage
{
    if (TAG_BANNER_SEVICE == banner.tag){
        switch (curpage) {
            case 0:
            {
                _view2Lab.text = [NSString stringWithFormat:@"%@",BANNER_SEVICE_TEXT_1];
            }
                break;
            case 1:
            {
                _view2Lab.text = [NSString stringWithFormat:@"%@",BANNER_SEVICE_TEXT_2];
            }
                break;
            case 2:
            {
                _view2Lab.text = [NSString stringWithFormat:@"%@",BANNER_SEVICE_TEXT_3];
            }
                break;
                
            default:
                break;
        }
    }
}

-(void)bannerView:(BannerView*)banner TapOnPage:(NSInteger)page
{
    if (TAG_BANNER_LEARING == banner.tag) {
        NSDictionary * data = [self.videoResources objectAtIndex:page];
        if (data) {
            PlayerViewController * playerCtrl = [[PlayerViewController alloc] initWithUrl:[NSURL URLWithString:[data objectForKey:@"url"]]];
            [playerCtrl showOn:self.navigationController];
        }
        
    }else if (TAG_BANNER_SEVICE == banner.tag){
        if (0 == page) {
            PlayerViewController * playerCtrl = [[PlayerViewController alloc] initWithUrl:[NSURL URLWithString:VIDEO_PD_URLSTRING]];
            [playerCtrl showOn:self.navigationController];
        }
    }
    
}




@end
