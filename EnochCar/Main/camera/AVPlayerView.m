//
//  AVPlayerView.m
//  EnochCar
//
//  Created by HAIYAN on 2021/5/7.
//

#import "AVPlayerView.h"


@interface AVPlayerView ()

@property (nonatomic,strong) AVPlayer *player;//播放器对象
@property (nonatomic,strong) UIView *loadView;//正在加载
@property (nonatomic,strong) id timeObserve;//正在加载
@end

@implementation AVPlayerView

- (instancetype)initWithFrame:(CGRect)frame withShowInView:(UIView *)bgView url:(NSURL *)url {
    if (self = [self initWithFrame:frame]) {
        //创建播放器层
        AVPlayerLayer *playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
        playerLayer.frame = self.bounds;
        
        [self.layer addSublayer:playerLayer];
        if (url) {
            self.videoUrl = url;
        }
        [bgView addSubview:self];
    }
    return self;
}

- (void)dealloc {
    [self removeAvPlayerNtf];
    [self stopPlayer];
    self.player = nil;
}

- (AVPlayer *)player {
    if (!_player) {
        _player = [AVPlayer playerWithPlayerItem:[self getAVPlayerItem]];
        [self addAVPlayerNtf:_player.currentItem];
        
    }
    
    return _player;
}

- (AVPlayerItem *)getAVPlayerItem {
    AVPlayerItem *playerItem=[AVPlayerItem playerItemWithURL:self.videoUrl];
    return playerItem;
}

- (void)setVideoUrl:(NSURL *)videoUrl {
    _videoUrl = videoUrl;
    [self removeAvPlayerNtf];
    [self nextPlayer];
}

- (void)nextPlayer {
    [self.player seekToTime:CMTimeMakeWithSeconds(0, _player.currentItem.duration.timescale)];
    [self.player replaceCurrentItemWithPlayerItem:[self getAVPlayerItem]];
    [self addAVPlayerNtf:self.player.currentItem];
    if (self.player.rate == 0) {
        [self.player play];
    }
}

- (void)addAVPlayerNtf:(AVPlayerItem *)playerItem {
    //监控状态属性
    [playerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
    //监控网络加载情况属性
    [playerItem addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playbackFinished:) name:AVPlayerItemDidPlayToEndTimeNotification object:self.player.currentItem];
    
    [self.player addObserver:self forKeyPath:@"timeControlStatus" options:NSKeyValueObservingOptionNew context:nil];
    
}

- (void)removeAvPlayerNtf {
    AVPlayerItem *playerItem = self.player.currentItem;
    [playerItem removeObserver:self forKeyPath:@"status"];
    [playerItem removeObserver:self forKeyPath:@"loadedTimeRanges"];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.player removeObserver:self forKeyPath:@"timeControlStatus"];
}

-(void)addTimeObserverForInterval:(CMTime)interval queue:(nullable dispatch_queue_t)queue usingBlock:(void (^)(CMTime time))block
{
   _timeObserve = [self.player addPeriodicTimeObserverForInterval:interval queue:queue usingBlock:block];
}

-(void)removeTimeObserver
{
    [self.player removeTimeObserver:_timeObserve];
}

- (void)play
{
    if (self.player.rate == 0) {
        [self.player play];//如果在停止状态就播放
    }
}

- (void)stopPlayer {
    if (self.player.rate == 1) {
        [self.player pause];//如果在播放状态就停止
    }
}

-(CMTime)getDuration
{
    return self.player.currentItem.duration;
}



/**
 *  通过KVO监控播放器状态
 *
 *  @param keyPath 监控属性
 *  @param object  监视器
 *  @param change  状态改变
 *  @param context 上下文
 */
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    AVPlayerItem *playerItem = object;
    if ([keyPath isEqualToString:@"status"]) {
        AVPlayerStatus status= [[change objectForKey:@"new"] intValue];
        if(status==AVPlayerStatusReadyToPlay){
            NSLog(@"正在播放...，视频总长度:%.2f",CMTimeGetSeconds(playerItem.duration));
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

- (void)playbackFinished:(NSNotification *)ntf {
    NSLog(@"视频播放完成");
    [self.player seekToTime:CMTimeMake(0, 1)];
    [self.player play];
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
