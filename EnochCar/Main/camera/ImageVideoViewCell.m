//
//  ImageVideoViewCell.m
//  EnochCar
//
//  Created by 王海燕 on 2021/6/30.
//

#import "ImageVideoViewCell.h"
#import "VideoPlayer.h"
#import <SDWebImage/SDWebImage.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <Photos/Photos.h>

@interface ImageVideoViewCell()
@property(nonatomic, readwrite, strong) UIImageView * coverView;
@property(nonatomic, readwrite, strong) UIImageView * playBtn;
@property(nonatomic, readwrite, strong) UIButton * deleteBtn;
@property(nonatomic, readwrite, strong) ImageVideoItem * item;
@end

@implementation ImageVideoViewCell

-(instancetype)initWithFrame:(CGRect)frame item:(ImageVideoItem*)item
{
    self = [super initWithFrame:frame];
    if (self) {
        self.item = item;
        self.coverView = [[UIImageView   alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        self.coverView.contentMode = UIViewContentModeScaleAspectFill;
        self.coverView.layer.cornerRadius = 4;
        self.coverView.layer.masksToBounds = YES;
        self.layer.masksToBounds = YES;
        [self addSubview:self.coverView];
        [self setCoverImage];

        self.deleteBtn = [[UIButton alloc] initWithFrame:CGRectMake(frame.size.width - 16, 0, 16, 16)];
        [self.deleteBtn setImage:[UIImage imageNamed:@"deleteBtnx"] forState:UIControlStateNormal];
        [self.deleteBtn addTarget:self action:@selector(deleteBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.deleteBtn];
        
        if ([self isVideo]) {
            self.playBtn = [[UIImageView   alloc] initWithFrame:CGRectMake((frame.size.width - 63)/2, (frame.size.height - 63)/2, 63, 63)];
            [self.playBtn setImage:[UIImage imageNamed:@"playBtn"]];
            [self.coverView addSubview:self.playBtn];
            
            UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapToPlay)];
            [self addGestureRecognizer:tap];
        }
    }
    return self;
}

-(void)deleteBtnClick:(id)sender
{
    if (self.deleteBlock) {
        self.deleteBlock();
    }
}

-(void)tapToPlay
{
    VideoPlayer * player = [VideoPlayer player];
    [player layoutVideoPlayerwithurl:self.item.url.absoluteString onView:self.coverView];
    [player setVideoGravity:AVLayerVideoGravityResizeAspectFill];
}

-(BOOL)isVideo
{
    BOOL isVideo = NO;
    if (self.item.url && ([self.item.url.absoluteString hasSuffix:@"mov"]||[self.item.url.absoluteString hasSuffix:@"mp4"])) {
        isVideo = YES;
    }
    return isVideo;
}

-(void)setCoverImage
{
    if ([self isVideo]) {
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
           UIImage * image = [self thumbnailImageForVideo:self.item.url atTime:1];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                self.coverView.image = image;
            });
        });
    }else {
        [self.coverView sd_setImageWithURL:self.item.url];
    }
}

-(UIImage*)thumbnailImageForVideo:(NSURL *)videoURL atTime:(NSTimeInterval)time {

    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:videoURL options:nil];
    NSParameterAssert(asset);
    AVAssetImageGenerator *assetImageGenerator =[[AVAssetImageGenerator alloc] initWithAsset:asset];
    assetImageGenerator.appliesPreferredTrackTransform = YES;
    assetImageGenerator.apertureMode = AVAssetImageGeneratorApertureModeEncodedPixels;
    CGImageRef thumbnailImageRef = NULL;
    CFTimeInterval thumbnailImageTime = time;
    NSError *thumbnailImageGenerationError = nil;
    thumbnailImageRef = [assetImageGenerator copyCGImageAtTime:CMTimeMake(thumbnailImageTime, 60)actualTime:NULL error:&thumbnailImageGenerationError];
    if(!thumbnailImageRef)
        NSLog(@"thumbnailImageGenerationError %@",thumbnailImageGenerationError);
    UIImage*thumbnailImage = thumbnailImageRef ? [[UIImage alloc]initWithCGImage: thumbnailImageRef] : nil;
    return thumbnailImage;
}


@end
