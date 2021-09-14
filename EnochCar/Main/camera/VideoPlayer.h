//
//  VideoPlayer.h
//  tableview
//
//  Created by HAIYAN on 2021/3/31.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN

@class VideoPlayer;

@protocol VideoPlayerDelegate <NSObject>
-(void)playerView:(VideoPlayer*)view playerStatusChanged:(AVPlayerStatus)status;
-(void)playerView:(VideoPlayer*)view controlStatusChanged:(AVPlayerTimeControlStatus)status;

@end

@interface VideoPlayer : NSObject
@property(nonatomic, assign) CGFloat aspectRatio;//画面宽高比
@property(nonatomic,weak) id <VideoPlayerDelegate>delegate;
+(VideoPlayer*)player;

-(void)layoutVideoPlayerwithurl:(NSString *)urlString  onView:(UIImageView*)attachView;
-(void)relayout;
-(void)stopPlay;


- (void)play;
-(void)pause;
-(void)stopPlay;
-(CMTime)getDuration;
-(void)setProgress:(CGFloat)value;
-(void)setVolume:(CGFloat)volume;
-(void)setVideoGravity:(AVLayerVideoGravity)videoGravity;
-(void)addTimeObserverForInterval:(CMTime)interval queue:(nullable dispatch_queue_t)queue usingBlock:(void (^)(CMTime time))block;
-(void)removeTimeObserver;



@end

NS_ASSUME_NONNULL_END
