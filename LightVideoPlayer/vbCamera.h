//
//  vbCamera.h
//  LightVideoPlayer
//

#include "opencv2/core.hpp"
#import <UIKit/UIKit.h>
#import <Accelerate/Accelerate.h>
#import <AVFoundation/AVFoundation.h>
#import <ImageIO/ImageIO.h>


//! @addtogroup videoio_ios
//! @{

/////////////////////////////////////// CvAbstractCamera /////////////////////////////////////

@class CvAbstractCamera;

CV_EXPORTS @interface CvAbstractCamera : NSObject
{
    UIDeviceOrientation currentDeviceOrientation;
    
    BOOL cameraAvailable;
}

@property (nonatomic, strong) AVCaptureSession* captureSession;
@property (nonatomic, strong) AVCaptureConnection* videoCaptureConnection;

@property (nonatomic, readonly) BOOL running;
@property (nonatomic, readonly) BOOL captureSessionLoaded;

@property (nonatomic, assign) int defaultFPS;
@property (nonatomic, readonly) AVCaptureVideoPreviewLayer *captureVideoPreviewLayer;
@property (nonatomic, assign) AVCaptureDevicePosition defaultAVCaptureDevicePosition;
@property (nonatomic, assign) AVCaptureVideoOrientation defaultAVCaptureVideoOrientation;
@property (nonatomic, assign) BOOL useAVCaptureVideoPreviewLayer;
@property (nonatomic, strong) NSString *const defaultAVCaptureSessionPreset;

@property (nonatomic, assign) int imageWidth;
@property (nonatomic, assign) int imageHeight;

@property (nonatomic, strong) UIView* parentView;

- (void)start;
- (void)stop;
- (void)switchCameras;

- (id)initWithParentView:(UIView*)parent;

- (void)createCaptureOutput;
- (void)createVideoPreviewLayer;
- (void)updateOrientation;

- (void)lockFocus;
- (void)unlockFocus;
- (void)lockExposure;
- (void)unlockExposure;
- (void)lockBalance;
- (void)unlockBalance;

@end

///////////////////////////////// CvVideoCamera ///////////////////////////////////////////

@class CvVideoCamera;

CV_EXPORTS @protocol vbCameraDelegate <NSObject>

#ifdef __cplusplus
// delegate method for processing image frames
- (void)processImage:(cv::Mat&)image;
#endif

@end

CV_EXPORTS @interface vbCamera : CvAbstractCamera<AVCaptureVideoDataOutputSampleBufferDelegate>
{
    AVCaptureVideoDataOutput *videoDataOutput;
    
    dispatch_queue_t videoDataOutputQueue;
    CALayer *customPreviewLayer;
    
    CMTime lastSampleTime;
    
}

@property (nonatomic, weak) id<vbCameraDelegate> delegate;
@property (nonatomic, assign) BOOL grayscaleMode;

@property (nonatomic, assign) BOOL recordVideo;
@property (nonatomic, assign) BOOL rotateVideo;
@property (nonatomic, strong) AVAssetWriterInput* recordAssetWriterInput;
@property (nonatomic, strong) AVAssetWriterInputPixelBufferAdaptor* recordPixelBufferAdaptor;
@property (nonatomic, strong) AVAssetWriter* recordAssetWriter;

- (void)adjustLayoutToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation;
- (void)layoutPreviewLayer;
- (void)saveVideo;
- (NSURL *)videoFileURL;
- (NSString *)videoFileString;


@end

///////////////////////////////// CvPhotoCamera ///////////////////////////////////////////

