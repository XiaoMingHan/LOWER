#include "opencv2/opencv.hpp"
#include <opencv2/videoio/cap_ios.h>
#import <Foundation/Foundation.h>



#import <UIKit/UIKit.h>
#import <Accelerate/Accelerate.h>
#import <AVFoundation/AVFoundation.h>
#import <ImageIO/ImageIO.h>


@protocol myCameraDelegate <NSObject>

#ifdef __cplusplus
// delegate method for processing image frames
- (void)processImage:(cv::Mat&)image;
- (void)completeVideoConverter:(NSURL*)filePath;
#endif

@end

@interface myCamera : CvAbstractCamera<AVCaptureVideoDataOutputSampleBufferDelegate>
{
    AVCaptureVideoDataOutput *videoDataOutput;
    
    dispatch_queue_t videoDataOutputQueue;
    CALayer *customPreviewLayer;
    CMTime lastSampleTime;
    CMTime startSampleTime;

}

@property (nonatomic, weak) id<myCameraDelegate> delegate;
@property (nonatomic, assign) BOOL grayscaleMode;
@property (nonatomic, readonly) BOOL isRecording;
@property  BOOL microphoneMute;

@property (nonatomic, assign) BOOL rotateVideo;
@property (nonatomic, strong) AVAssetWriterInput* recordAssetWriterInput;
@property (nonatomic, strong) AVAssetWriterInputPixelBufferAdaptor* recordPixelBufferAdaptor;
@property (nonatomic, strong) AVAssetWriter* recordAssetWriter;
- (void)convertVideoToLowQuailtyWithInputURL:(NSURL*)inputURL outputURL:(NSURL*)outputURL addOutputSize:(CGSize)makeSize;

-(void)resizeVideo:(NSURL*)inputURL outputURL:(NSURL*)outputURL addOutputSize:(CGSize)makeSize;
- (void)adjustLayoutToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation;
- (void)layoutPreviewLayer;
- (void)saveVideo;
- (NSURL *)videoFileURL;
- (NSString *)videoFileString;
-(float)getRecordingTimeStamp;
-(void)startRecord;
-(void)stopRecord;

@end

