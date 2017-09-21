//
//  VideoFileConverter.h
//  LightVideoPlayer
//
//  Created by My Star on 8/6/17.
//  Copyright © 2017 My Star. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <Accelerate/Accelerate.h>
#import <AVFoundation/AVFoundation.h>
@protocol VideoFileConverterDelegate <NSObject>
- (void)completeVideoConverter:(NSURL*)filePath;

@end
@interface VideoFileConverter : NSObject{
    NSURL * inputVideo;
    NSURL* outputVideo;
    UIViewController* main_view;
    BOOL waitCancel;
}
-(void)selectVideo:(NSURL*)inputURL outputURL:(NSURL*)outputURL parent:(UIViewController*)mainview;
-(void)resizeVideo:(NSURL*)inputURL outputURL:(NSURL*)outputURL addOutputSize:(CGSize)makeSize;
@property (nonatomic, weak) id<VideoFileConverterDelegate> delegate;
@property (nonatomic)  CGSize videoSize;
@end
