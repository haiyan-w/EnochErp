//
//  VideoPlayer.m
//  tableview
//
//  Created by HAIYAN on 2021/3/31.
//

#import "VideoPlayer.h"


@interface VideoPlayer()
@property(nonatomic, readwrite, strong) AVPlayerItem * playerItem;
@property(nonatomic, readwrite, strong) AVPlayer * player;
@property(nonatomic, readwrite, strong) AVPlayerLayer * playerLayer;
@property (nonatomic,strong) id timeObserve;
@end

@implementation VideoPlayer

+(VideoPlayer*)player
{
    static VideoPlayer * player;
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        //NSLog(@"~~~~~~中~~~~~~~%@",token);
        player = [[VideoPlayer alloc] init];
    });
    
    return player;
}

-(void)layoutVideoPlayerwithurl:(NSString *)urlString  onView:(UIImageView*)attachView
{
    [self stopPlay];
    
    AVAsset * asset = [AVAsset assetWithURL:[NSURL URLWithString:urlString]];
    self.playerItem = [[AVPlayerItem alloc] initWithAsset:asset];
    self.player = [AVPlayer playerWithPlayerItem:self.playerItem];
    self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
    self.playerLayer.frame = CGRectMake(0, 0, attachView.layer.frame.size.width, attachView.layer.frame.size.height);
    self.playerLayer.videoGravity = AVLayerVideoGravityResizeAspect;
    [attachView.layer addSublayer:self.playerLayer];

    //计算画面宽高比
    NSArray * tracks = [asset tracksWithMediaType:AVMediaTypeVideo];
    if (tracks.count > 0) {
        AVAssetTrack * videoTrack = [tracks objectAtIndex:0];
        self.aspectRatio = videoTrack.naturalSize.width/videoTrack.naturalSize.height;
    }
    
    [self addObserver];

    [self relayout];
}

-(void)addObserver
{
    [self.playerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
    [self.playerItem addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];
    [self.player addObserver:self forKeyPath:@"timeControlStatus" options:NSKeyValueObservingOptionNew context:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playEnd) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
//    [attachView addObserver:self forKeyPath:@"frame" options:NSKeyValueObservingOptionNew context:nil];
}

-(void)removeObserver
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.playerItem removeObserver:self forKeyPath:@"status" context:nil];
    [self.playerItem removeObserver:self forKeyPath:@"loadedTimeRanges" context:nil];
    [self.player removeObserver:self forKeyPath:@"timeControlStatus" context:nil];
}


-(void)relayout
{
    CALayer * layer = self.playerLayer.superlayer;
    self.playerLayer.frame = CGRectMake(0, 0, layer.frame.size.width, layer.frame.size.height);
    [self.playerLayer setNeedsLayout];
    [self.playerLayer setNeedsDisplay];
}


-(void)setVideoGravity:(AVLayerVideoGravity)videoGravity
{
    self.playerLayer.videoGravity = videoGravity;
}

-(void)playEnd
{
    [self.player seekToTime:CMTimeMake(0, 1)];
    
    //test
//    [self stopPlay];
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    AVPlayerItem *playerItem = object;
    if ([keyPath isEqualToString:@"status"]) {
        AVPlayerStatus status= [[change objectForKey:@"new"] intValue];
        if(status==AVPlayerStatusReadyToPlay){
            NSLog(@"正在播放...，视频总长度:%.2f",CMTimeGetSeconds(playerItem.duration));
            [self.player play];
            if (_delegate && [_delegate respondsToSelector:@selector(playerView: playerStatusChanged:)]) {
                [self.delegate playerView:self playerStatusChanged:status];
            }
        }
    }else if([keyPath isEqualToString:@"loadedTimeRanges"]){
        NSArray *array=playerItem.loadedTimeRanges;
        CMTimeRange timeRange = [array.firstObject CMTimeRangeValue];//本次缓冲时间范围
        float startSeconds = CMTimeGetSeconds(timeRange.start);
        float durationSeconds = CMTimeGetSeconds(timeRange.duration);
        NSTimeInterval totalBuffer = startSeconds + durationSeconds;//缓冲总长度
        NSLog(@"共缓冲：%.2f",totalBuffer);
    }else if([keyPath isEqualToString:@"timeControlStatus"]){
        AVPlayerTimeControlStatus status= [[change objectForKey:@"new"] intValue];
        if (_delegate && [_delegate respondsToSelector:@selector(playerView: controlStatusChanged:)]) {
            [self.delegate playerView:self controlStatusChanged:status];
        }
        
    }
}

-(void)play
{
    if (self.player.rate == 0) {
        [self.player play];//如果在停止状态就播放
    }
}

-(void)pause
{
    if (self.player.rate == 1) {
        [self.player pause];//如果在播放状态就停止
    }
}

-(void)stopPlay
{
    [self removeObserver];
    [self.playerLayer removeFromSuperlayer];
    self.playerItem = nil;
    self.player = nil;
    self.playerLayer = nil;
}


-(void)addTimeObserverForInterval:(CMTime)interval queue:(nullable dispatch_queue_t)queue usingBlock:(void (^)(CMTime time))block
{
   _timeObserve = [self.player addPeriodicTimeObserverForInterval:interval queue:queue usingBlock:block];
}

-(void)removeTimeObserver
{
    [self.player removeTimeObserver:_timeObserve];
    _timeObserve = nil;
}

-(CMTime)getDuration
{
    return self.player.currentItem.duration;
}
//value: 0~1
-(void)setProgress:(CGFloat)value
{
    CGFloat totalseconds = CMTimeGetSeconds([self getDuration]);
    CGFloat curSeconds = totalseconds * value;
    
    [self.player seekToTime:CMTimeMakeWithSeconds(curSeconds, 1)];
    [self.player play];
}

-(void)setVolume:(CGFloat)volume
{
    self.player.volume = volume;
}



@end
