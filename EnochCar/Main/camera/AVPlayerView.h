//
//  AVPlayerView.h
//  EnochCar
//
//  Created by HAIYAN on 2021/5/7.

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@class AVPlayerView;

@protocol AVPlayerViewDelegate <NSObject>
-(void)playerView:(AVPlayerView*)view playerStatusChanged:(AVPlayerStatus)status;
-(void)playerView:(AVPlayerView*)view controlStatusChanged:(AVPlayerTimeControlStatus)status;

@end


@interface AVPlayerView : UIView
@property(nonatomic,weak) id <AVPlayerViewDelegate>delegate;

- (instancetype)initWithFrame:(CGRect)frame withShowInView:(UIView *)bgView url:(NSURL *)url;

@property (copy, nonatomic) NSURL *videoUrl;
-(CMTime)getDuration;
- (void)stopPlayer;
- (void)play;
-(void)setProgress:(CGFloat)value;
-(void)setVolume:(CGFloat)volume;
-(void)addTimeObserverForInterval:(CMTime)interval queue:(nullable dispatch_queue_t)queue usingBlock:(void (^)(CMTime time))block;
-(void)removeTimeObserver;
@end
