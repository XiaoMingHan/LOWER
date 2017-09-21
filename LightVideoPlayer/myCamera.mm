//
//  myCamera.m
//  LightVideoPlayer
//
//  Created by My Star on 8/2/17.
//  Copyright © 2017 My Star. All rights reserved.
//

#import "myCamera.h"
#import <AssetsLibrary/AssetsLibrary.h>


static CGFloat DegreesToRadians(CGFloat degrees) {return degrees * M_PI / 180;};

#pragma mark - Private Interface

@interface myCamera ()<AVCaptureAudioDataOutputSampleBufferDelegate>{
    BOOL recordVideo;
    
    dispatch_queue_t _audio_capture_queue;
    NSDictionary	*audioSettings;
    BOOL start_time;
}

- (void)createVideoDataOutput;
- (void)createVideoFileOutput;

@property (nonatomic, retain) CALayer *customPreviewLayer;
@property (nonatomic, retain) AVCaptureVideoDataOutput *videoDataOutput;
@property (nonatomic) AVCaptureDeviceInput		*audioCaptureInput;
@property (nonatomic) AVAssetWriterInput		*audioInput;
@property (nonatomic) AVCaptureAudioDataOutput	*audioCaptureOutput;
@end


#pragma mark - Implementation

@implementation myCamera


@synthesize delegate;
@synthesize grayscaleMode;

@synthesize customPreviewLayer;
@synthesize videoDataOutput;

@synthesize microphoneMute;
//@synthesize videoFileOutput;
@synthesize recordAssetWriterInput;
@synthesize recordPixelBufferAdaptor;
@synthesize recordAssetWriter;



#pragma mark - Constructors

- (id)initWithParentView:(UIView*)parent;
{
    self = [super initWithParentView:parent];
    if (self) {
        self.useAVCaptureVideoPreviewLayer = NO;
        recordVideo = NO;
    }
    return self;
}



#pragma mark - Public interface


- (void)start;
{
    [super start];
    
}

-(void)startRecord{
        recordVideo =YES;
        [self createVideoFileOutput];
        start_time=NO;
        NSError* error;
        if ([[NSFileManager defaultManager] fileExistsAtPath:[self videoFileString]]) {
            [[NSFileManager defaultManager] removeItemAtPath:[self videoFileString] error:&error];
        }
        if (error == nil) {
            NSLog(@"[Camera] Delete file %@", [self videoFileString]);
        }
    
  
}
-(void)stopRecord{
       recordVideo =NO;
        
        if (self.recordAssetWriter.status == AVAssetWriterStatusWriting) {
            [self.recordAssetWriter finishWriting];
            NSLog(@"[Camera] recording stopped");
        } else {
            NSLog(@"[Camera] Recording Error: asset writer status is not writing");
        }
        
        self.recordAssetWriter = nil;
        self.recordAssetWriterInput = nil;
        self.recordPixelBufferAdaptor = nil;
         [self.delegate completeVideoConverter:[self videoFileURL]];
         //[self saveVideo];
}
- (void)stop;
{
    [super stop];
    
    self.videoDataOutput = nil;
    if (videoDataOutputQueue) {
        // dispatch_release(videoDataOutputQueue);
    }
    
      [self.customPreviewLayer removeFromSuperlayer];
    self.customPreviewLayer = nil;
}

// TODO fix
- (void)adjustLayoutToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation;
{
    
    NSLog(@"layout preview layer");
    

    if (self.parentView != nil) {
        
        CALayer* layer = self.customPreviewLayer;
        CGRect bounds = self.customPreviewLayer.bounds;
        int rotation_angle = 0;
        bool flip_bounds = false;
        
        switch (interfaceOrientation) {
            case UIInterfaceOrientationPortrait:
                NSLog(@"to Portrait");
                rotation_angle = 270;
                break;
            case UIInterfaceOrientationPortraitUpsideDown:
                rotation_angle = 90;
                NSLog(@"to UpsideDown");
                break;
            case UIInterfaceOrientationLandscapeLeft:
                rotation_angle = 0;
                NSLog(@"to LandscapeLeft");
                break;
            case UIInterfaceOrientationLandscapeRight:
                rotation_angle = 180;
                NSLog(@"to LandscapeRight");
                break;
            default:
                break; // leave the layer in its last known orientation
        }
        
        switch (self.defaultAVCaptureVideoOrientation) {
            case AVCaptureVideoOrientationLandscapeRight:
                rotation_angle += 180;
                break;
            case AVCaptureVideoOrientationPortraitUpsideDown:
                rotation_angle += 270;
                break;
            case AVCaptureVideoOrientationPortrait:
                rotation_angle += 90;
            case AVCaptureVideoOrientationLandscapeLeft:
                break;
            default:
                break;
        }
        rotation_angle = rotation_angle % 360;
        
        if (rotation_angle == 90 || rotation_angle == 270) {
            flip_bounds = true;
        }
        
        if (flip_bounds) {
            NSLog(@"flip bounds");
            bounds = CGRectMake(0, 0, bounds.size.height, bounds.size.width);
        }
        
        layer.position = CGPointMake(self.parentView.frame.size.width/2., self.parentView.frame.size.height/2.);
        self.customPreviewLayer.bounds = CGRectMake(0, 0, self.parentView.frame.size.width, self.parentView.frame.size.height);
        
        layer.affineTransform = CGAffineTransformMakeRotation( DegreesToRadians(rotation_angle) );
        layer.bounds = bounds;
    }
    
}

// TODO fix
- (void)layoutPreviewLayer;
{
    NSLog(@"layout preview layer");
    if (self.parentView != nil) {
        
        CALayer* layer = self.customPreviewLayer;
        CGRect bounds = self.customPreviewLayer.bounds;
        int rotation_angle = 0;
        bool flip_bounds = false;

        switch (currentDeviceOrientation) {
            case UIDeviceOrientationPortrait:
                rotation_angle = 0;
                //self.imageHeight=1280;self.imageWidth=720;
                break;
            case UIDeviceOrientationPortraitUpsideDown:
               // self.imageHeight=1280;self.imageWidth=720;
                //rotation_angle = 180;
                break;
            case UIDeviceOrientationLandscapeLeft:
                NSLog(@"left");
               // self.imageHeight=720;self.imageWidth=1280;
               // rotation_angle = 270;
                break;
            case UIDeviceOrientationLandscapeRight:
                NSLog(@"right");
              //  self.imageHeight=720;self.imageWidth=1280;
               // rotation_angle = 90;
                break;
            case UIDeviceOrientationFaceUp:
            case UIDeviceOrientationFaceDown:
            default:
                break; // leave the layer in its last known orientation
        }
        
        switch (self.defaultAVCaptureDevicePosition) {
            case AVCaptureDevicePositionBack:
                rotation_angle += 0;
                break;
            case AVCaptureDevicePositionFront:
                rotation_angle += 0;
                break;
            default:
                break;
        }
        rotation_angle = rotation_angle % 360;
        
        if (rotation_angle == 90 || rotation_angle == 270) {
            flip_bounds = true;
        }
        
        if (flip_bounds) {
            NSLog(@"flip bounds");
            bounds = CGRectMake(0, 0, bounds.size.height, bounds.size.width);
        }
        //self.imageHeight=self.parentView.frame.size.height;
        
        layer.position = CGPointMake(self.parentView.frame.size.width/2., self.parentView.frame.size.height/2.);
        layer.affineTransform = CGAffineTransformMakeRotation( DegreesToRadians(rotation_angle) );
        layer.bounds = bounds;
    }
    
}




#pragma mark - Private Interface



- (void)createVideoDataOutput;
{
    // Make a video data output
    self.videoDataOutput = [AVCaptureVideoDataOutput new];
    
    // In grayscale mode we want YUV (YpCbCr 4:2:0) so we can directly access the graylevel intensity values (Y component)
    // In color mode we, BGRA format is used
    OSType format = self.grayscaleMode ? kCVPixelFormatType_420YpCbCr8BiPlanarFullRange : kCVPixelFormatType_32BGRA;
    
    self.videoDataOutput.videoSettings  = [NSDictionary dictionaryWithObject:[NSNumber numberWithUnsignedInt:format]
                                                                      forKey:(id)kCVPixelBufferPixelFormatTypeKey];
    
    // discard if the data output queue is blocked (as we process the still image)
    [self.videoDataOutput setAlwaysDiscardsLateVideoFrames:YES];
    
    if ( [self.captureSession canAddOutput:self.videoDataOutput] ) {
        [self.captureSession addOutput:self.videoDataOutput];
    }
    [[self.videoDataOutput connectionWithMediaType:AVMediaTypeVideo] setEnabled:YES];
    
    
    // set default FPS
    if ([self.videoDataOutput connectionWithMediaType:AVMediaTypeVideo].supportsVideoMinFrameDuration) {
        [self.videoDataOutput connectionWithMediaType:AVMediaTypeVideo].videoMinFrameDuration = CMTimeMake(1, self.defaultFPS);
    }
    if ([self.videoDataOutput connectionWithMediaType:AVMediaTypeVideo].supportsVideoMaxFrameDuration) {
        [self.videoDataOutput connectionWithMediaType:AVMediaTypeVideo].videoMaxFrameDuration = CMTimeMake(1, self.defaultFPS);
    }
    
    // set video mirroring for front camera (more intuitive)
    if ([self.videoDataOutput connectionWithMediaType:AVMediaTypeVideo].supportsVideoMirroring) {
        if (self.defaultAVCaptureDevicePosition == AVCaptureDevicePositionFront) {
            [self.videoDataOutput connectionWithMediaType:AVMediaTypeVideo].videoMirrored = YES;
        } else {
            [self.videoDataOutput connectionWithMediaType:AVMediaTypeVideo].videoMirrored = NO;
        }
    }
    
    // set default video orientation
    if ([self.videoDataOutput connectionWithMediaType:AVMediaTypeVideo].supportsVideoOrientation) {
        [self.videoDataOutput connectionWithMediaType:AVMediaTypeVideo].videoOrientation = self.defaultAVCaptureVideoOrientation;
    }
    
    
    // create a custom preview layer
    self.customPreviewLayer = [CALayer layer];
    self.customPreviewLayer.bounds = CGRectMake(0, 0, self.parentView.frame.size.width, self.parentView.frame.size.height);
    [self layoutPreviewLayer];
    
    // create a serial dispatch queue used for the sample buffer delegate as well as when a still image is captured
    // a serial dispatch queue must be used to guarantee that video frames will be delivered in order
    // see the header doc for setSampleBufferDelegate:queue: for more information
    videoDataOutputQueue = dispatch_queue_create("VideoDataOutputQueue", DISPATCH_QUEUE_SERIAL);
    [self.videoDataOutput setSampleBufferDelegate:self queue:videoDataOutputQueue];
    
    
    NSLog(@"[Camera] created AVCaptureVideoDataOutput at %d FPS", self.defaultFPS);
    
    
    
}

- (void)setUpAudioCapture
{
    NSError *error;
    
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio];
    if (device && device.connected)
        NSLog(@"Connected Device: %@", device.localizedName);
    else
    {
        NSLog(@"AVCaptureDevice Failed");
        return;
    }
    
    // add device inputs
    _audioCaptureInput = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
    if (!_audioCaptureInput)
    {
        NSLog(@"AVCaptureDeviceInput Failed");
        return;
    }
    if (error)
    {
        NSLog(@"%@", error);
        return;
    }
    
    // add output for audio
    _audioCaptureOutput = [[AVCaptureAudioDataOutput alloc] init];
    if (!_audioCaptureOutput)
    {
        NSLog(@"AVCaptureMovieFileOutput Failed");
        return;
    }
    
    _audio_capture_queue = dispatch_queue_create("AudioCaptureQueue", NULL);
    [_audioCaptureOutput setSampleBufferDelegate:self queue:_audio_capture_queue];
   
    if ([self.captureSession canAddInput:_audioCaptureInput])
        [self.captureSession addInput:_audioCaptureInput];
    else
    {
        NSLog(@"Failed to add input device to capture session");
        return;
    }
    if ([self.captureSession canAddOutput:_audioCaptureOutput])
        [self.captureSession addOutput:_audioCaptureOutput];
    else
    {
        NSLog(@"Failed to add output device to capture session");
        return;
    }
    
    audioSettings = [_audioCaptureOutput recommendedAudioSettingsForAssetWriterWithOutputFileType:AVFileTypeQuickTimeMovie];
    
    NSLog(@"Audio capture session running");
}


- (void)createVideoFileOutput;
{
    /* Video File Output in H.264, via AVAsserWriter */
    NSLog(@"Create Video with dimensions %dx%d", self.imageWidth, self.imageHeight);
    
    NSDictionary *outputSettings
    = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:self.imageWidth], AVVideoWidthKey,
       [NSNumber numberWithInt:self.imageHeight], AVVideoHeightKey,
       AVVideoCodecH264, AVVideoCodecKey,
       nil
       ];
    
    
    self.recordAssetWriterInput = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeVideo outputSettings:outputSettings];
    
    
    int pixelBufferFormat = (self.grayscaleMode == YES) ? kCVPixelFormatType_420YpCbCr8BiPlanarFullRange : kCVPixelFormatType_32BGRA;
    
    self.recordPixelBufferAdaptor =
    [[AVAssetWriterInputPixelBufferAdaptor alloc]
     initWithAssetWriterInput:self.recordAssetWriterInput
     sourcePixelBufferAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:pixelBufferFormat], kCVPixelBufferPixelFormatTypeKey, nil]];
    
    NSError* error = nil;
    NSLog(@"Create AVAssetWriter with url: %@", [self videoFileURL]);
    self.recordAssetWriter = [AVAssetWriter assetWriterWithURL:[self videoFileURL]
                                                      fileType:AVFileTypeMPEG4
                                                         error:&error];
    if (error != nil) {
        NSLog(@"[Camera] Unable to create AVAssetWriter: %@", error);
    }
    
    [self.recordAssetWriter addInput:self.recordAssetWriterInput];
    

    
   // audioSettings = [_audioCaptureOutput recommendedAudioSettingsForAssetWriterWithOutputFileType:AVFileTypeQuickTimeMovie];
    if(microphoneMute==NO){
    
    _audioInput = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeAudio outputSettings:audioSettings];
    _audioInput.expectsMediaDataInRealTime = YES;
    
    NSParameterAssert([self.recordAssetWriter canAddInput:_audioInput]);
    [self.recordAssetWriter  addInput:_audioInput];
    }
    
    self.recordAssetWriterInput.expectsMediaDataInRealTime = YES;
    self.recordAssetWriterInput.transform = [self videoTransformForDeviceOrientation];
    
    NSLog(@"[Camera] created AVAssetWriter");
}

- (CGAffineTransform)videoTransformForDeviceOrientation
{
    CGAffineTransform videoTransform;
    switch ([UIDevice currentDevice].orientation) {
        case UIDeviceOrientationLandscapeLeft:
            videoTransform = CGAffineTransformMakeRotation(-M_PI_2);
            break;
        case UIDeviceOrientationLandscapeRight:
            videoTransform = CGAffineTransformMakeRotation(M_PI_2);
            break;
        case UIDeviceOrientationPortraitUpsideDown:
            videoTransform = CGAffineTransformMakeRotation(M_PI);
            break;
        default:
            videoTransform = CGAffineTransformIdentity;
    }
    return videoTransform;
}

- (void)createCaptureOutput;
{
    [self createVideoDataOutput];
    [self setUpAudioCapture];
    if (recordVideo == YES) {
        [self createVideoFileOutput];
    }
}

- (void)createCustomVideoPreview;
{
    [self.parentView.layer addSublayer:self.customPreviewLayer];
}

-(float)getRecordingTimeStamp{

   CMTime time= CMTimeSubtract(lastSampleTime, startSampleTime);

    
    return CMTimeGetSeconds(time);
}
#pragma mark - Protocol AVCaptureVideoDataOutputSampleBufferDelegate


- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection
{
    if (self.delegate) {
        
        
        
        if(self.videoDataOutput==captureOutput){
        // convert from Core Media to Core Video
        CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
        CVPixelBufferLockBaseAddress(imageBuffer, 0);
        
        void* bufferAddress;
        size_t width;
        size_t height;
        size_t bytesPerRow;
        
        CGColorSpaceRef colorSpace;
        CGContextRef context;
        
        int format_opencv;
        
        OSType format = CVPixelBufferGetPixelFormatType(imageBuffer);
        if (format == kCVPixelFormatType_420YpCbCr8BiPlanarFullRange) {
            
            format_opencv = CV_8UC1;
            
            bufferAddress = CVPixelBufferGetBaseAddressOfPlane(imageBuffer, 0);
            width = CVPixelBufferGetWidthOfPlane(imageBuffer, 0);
            height = CVPixelBufferGetHeightOfPlane(imageBuffer, 0);
            bytesPerRow = CVPixelBufferGetBytesPerRowOfPlane(imageBuffer, 0);
            
        } else { // expect kCVPixelFormatType_32BGRA
            
            format_opencv = CV_8UC4;
            
            bufferAddress = CVPixelBufferGetBaseAddress(imageBuffer);
            width = CVPixelBufferGetWidth(imageBuffer);
            height = CVPixelBufferGetHeight(imageBuffer);
            bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer);
            
        }
        
        // delegate image processing to the delegate
        cv::Mat image(height, width, format_opencv, bufferAddress, bytesPerRow);
        
        cv::Mat* result = NULL;
        CGImage* dstImage;
        
        if ([self.delegate respondsToSelector:@selector(processImage:)]) {
            [self.delegate processImage:image];
        }
        
        // check if matrix data pointer or dimensions were changed by the delegate
        bool iOSimage = false;
        if (height == image.rows && width == image.cols && format_opencv == image.type() && bufferAddress == image.data && bytesPerRow == image.step) {
            iOSimage = true;
        }
        
        
        // (create color space, create graphics context, render buffer)
        CGBitmapInfo bitmapInfo;
        
        // basically we decide if it's a grayscale, rgb or rgba image
        if (image.channels() == 1) {
            colorSpace = CGColorSpaceCreateDeviceGray();
            bitmapInfo = kCGImageAlphaNone;
        } else if (image.channels() == 3) {
            colorSpace = CGColorSpaceCreateDeviceRGB();
            bitmapInfo = kCGImageAlphaNone;
            if (iOSimage) {
                bitmapInfo |= kCGBitmapByteOrder32Little;
            } else {
                bitmapInfo |= kCGBitmapByteOrder32Big;
            }
        } else {
            colorSpace = CGColorSpaceCreateDeviceRGB();
            bitmapInfo = kCGImageAlphaPremultipliedFirst;
            if (iOSimage) {
                bitmapInfo |= kCGBitmapByteOrder32Little;
            } else {
                bitmapInfo |= kCGBitmapByteOrder32Big;
            }
        }
        
        if (iOSimage) {
            context = CGBitmapContextCreate(bufferAddress, width, height, 8, bytesPerRow, colorSpace, bitmapInfo);
            dstImage = CGBitmapContextCreateImage(context);
            CGContextRelease(context);
        } else {
            
            NSData *data = [NSData dataWithBytes:image.data length:image.elemSize()*image.total()];
            CGDataProviderRef provider = CGDataProviderCreateWithCFData((__bridge CFDataRef)data);
            
            // Creating CGImage from cv::Mat
            dstImage = CGImageCreate(image.cols,                                 // width
                                     image.rows,                                 // height
                                     8,                                          // bits per component
                                     8 * image.elemSize(),                       // bits per pixel
                                     image.step,                                 // bytesPerRow
                                     colorSpace,                                 // colorspace
                                     bitmapInfo,                                 // bitmap info
                                     provider,                                   // CGDataProviderRef
                                     NULL,                                       // decode
                                     false,                                      // should interpolate
                                     kCGRenderingIntentDefault                   // intent
                                     );
            
            CGDataProviderRelease(provider);
        }
        
        
        // render buffer
        dispatch_sync(dispatch_get_main_queue(), ^{
            self.customPreviewLayer.contents = (__bridge id)dstImage;
        });
        
        
        if (recordVideo == YES) {
            lastSampleTime = CMSampleBufferGetPresentationTimeStamp(sampleBuffer);
            if(start_time==NO)
            {
                startSampleTime = lastSampleTime;
                start_time=YES;
            }else
            
            
  
            if (self.recordAssetWriter.status != AVAssetWriterStatusWriting) {
                [self.recordAssetWriter startWriting];
                [self.recordAssetWriter startSessionAtSourceTime:lastSampleTime];
                if (self.recordAssetWriter.status != AVAssetWriterStatusWriting) {
                    NSLog(@"[Camera] Recording Error: asset writer status is not writing: %@", self.recordAssetWriter.error);
                    return;
                } else {
                    NSLog(@"[Camera] Video recording started");
                }
            }
            
            if (self.recordAssetWriterInput.readyForMoreMediaData) {
                if (! [self.recordPixelBufferAdaptor appendPixelBuffer:imageBuffer
                                                  withPresentationTime:lastSampleTime] ) {
                    NSLog(@"Video Writing Error");
                }
            }
            
            
            
        }
        
        
        // cleanup
        CGImageRelease(dstImage);
        
        CGColorSpaceRelease(colorSpace);
        
        CVPixelBufferUnlockBaseAddress(imageBuffer, 0);
    }else{
         if (recordVideo == YES)
            if ([_audioInput isReadyForMoreMediaData]) {
               if(microphoneMute==NO)
                [_audioInput appendSampleBuffer:sampleBuffer];
           }
        

    }
    }
}


- (void)updateOrientation;
{
    NSLog(@"rotate..");
    self.customPreviewLayer.bounds = CGRectMake(0, 0, self.parentView.frame.size.width, self.parentView.frame.size.height);
    [self layoutPreviewLayer];
}


- (void)saveVideo;
{
//    if (self.recordVideo == NO) {
//        return;
//    }
    
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    if ([library videoAtPathIsCompatibleWithSavedPhotosAlbum:[self videoFileURL]]) {
        [library writeVideoAtPathToSavedPhotosAlbum:[self videoFileURL]
                                    completionBlock:^(NSURL *assetURL, NSError *error){}];
    }
}


- (NSURL *)videoFileURL;
{
    NSString *outputPath = [[NSString alloc] initWithFormat:@"%@%@", NSTemporaryDirectory(), @"output.mov"];
    NSURL *outputURL = [NSURL fileURLWithPath:outputPath];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:outputPath]) {
        NSLog(@"file exists");
    }
    return outputURL;
}



- (NSString *)videoFileString;
{
    NSString *outputPath = [[NSString alloc] initWithFormat:@"%@%@", NSTemporaryDirectory(), @"output.mov"];
    return outputPath;
}
- (void)removeTempFilePath:(NSString*)filePath
{
    NSFileManager* fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:filePath]) {
        NSError* error;
        if ([fileManager removeItemAtPath:filePath error:&error] == NO) {
            NSLog(@"Could not delete old recording:%@", [error localizedDescription]);
        }
    }
}


- (void)convertVideoToLowQuailtyWithInputURL:(NSURL*)inputURL
                                   outputURL:(NSURL*)outputURL addOutputSize:(CGSize)makeSize
{
    
    
    [self removeTempFilePath:[outputURL absoluteString]];
       //setup video writer
    AVAsset *videoAsset = [[AVURLAsset alloc] initWithURL:inputURL options:nil];
    
    AVAssetTrack *videoTrack = [[videoAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
    
    CGSize videoSize = videoTrack.naturalSize;
    
    NSDictionary *videoWriterCompressionSettings =  [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:1250000], AVVideoAverageBitRateKey, nil];
    
    NSDictionary *videoWriterSettings = [NSDictionary dictionaryWithObjectsAndKeys:AVVideoCodecH264, AVVideoCodecKey, videoWriterCompressionSettings, AVVideoCompressionPropertiesKey, [NSNumber numberWithFloat:makeSize.width], AVVideoWidthKey, [NSNumber numberWithFloat:makeSize.height], AVVideoHeightKey, nil];
    
    AVAssetWriterInput* videoWriterInput = [AVAssetWriterInput
                                            assetWriterInputWithMediaType:AVMediaTypeVideo
                                            outputSettings:videoWriterSettings];
    
    videoWriterInput.expectsMediaDataInRealTime = YES;
    
    videoWriterInput.transform = videoTrack.preferredTransform;
    
    AVAssetWriter *videoWriter = [[AVAssetWriter alloc] initWithURL:outputURL fileType:AVFileTypeQuickTimeMovie error:nil];
    
    [videoWriter addInput:videoWriterInput];
    
    //setup video reader
    NSDictionary *videoReaderSettings = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange] forKey:(id)kCVPixelBufferPixelFormatTypeKey];
    
    AVAssetReaderTrackOutput *videoReaderOutput = [[AVAssetReaderTrackOutput alloc] initWithTrack:videoTrack outputSettings:videoReaderSettings];
    
    AVAssetReader *videoReader = [[AVAssetReader alloc] initWithAsset:videoAsset error:nil];
    
    [videoReader addOutput:videoReaderOutput];
    
    //setup audio writer
    AVAssetWriterInput* audioWriterInput = [AVAssetWriterInput
                                            assetWriterInputWithMediaType:AVMediaTypeAudio
                                            outputSettings:nil];
    
    audioWriterInput.expectsMediaDataInRealTime = NO;
    
    [videoWriter addInput:audioWriterInput];
    
    //setup audio reader
    AVAssetTrack* audioTrack = [[videoAsset tracksWithMediaType:AVMediaTypeAudio] objectAtIndex:0];
    
    AVAssetReaderOutput *audioReaderOutput = [AVAssetReaderTrackOutput assetReaderTrackOutputWithTrack:audioTrack outputSettings:nil];
    
    AVAssetReader *audioReader = [AVAssetReader assetReaderWithAsset:videoAsset error:nil];
    
    [audioReader addOutput:audioReaderOutput];
    
    [videoWriter startWriting];
    
    //start writing from video reader
    [videoReader startReading];
    
    [videoWriter startSessionAtSourceTime:kCMTimeZero];
    
    dispatch_queue_t processingQueue = dispatch_queue_create("processingQueue1", NULL);
    
    __block BOOL videoComplete=NO;
    __block BOOL audioComplete=NO;
    

    [videoWriterInput requestMediaDataWhenReadyOnQueue:processingQueue usingBlock:
     ^{
         
         while ([videoWriterInput isReadyForMoreMediaData]) {
             
             CMSampleBufferRef sampleBuffer;
             
             if ([videoReader status] == AVAssetReaderStatusReading &&
                 (sampleBuffer = [videoReaderOutput copyNextSampleBuffer])) {
//                 
//                 CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
//                 CVPixelBufferLockBaseAddress(imageBuffer, 0);
//                 
//                 void* bufferAddress;
//                 size_t width;
//                 size_t height;
//                 size_t bytesPerRow;
//                 
//                 CGColorSpaceRef colorSpace;
//                 CGContextRef context;
//                 
//                 int format_opencv;
//                 
//                 OSType format = CVPixelBufferGetPixelFormatType(imageBuffer);
//                 if (format == kCVPixelFormatType_420YpCbCr8BiPlanarFullRange) {
//                     
//                     format_opencv = CV_8UC1;
//                     
//                     bufferAddress = CVPixelBufferGetBaseAddressOfPlane(imageBuffer, 0);
//                     width = CVPixelBufferGetWidthOfPlane(imageBuffer, 0);
//                     height = CVPixelBufferGetHeightOfPlane(imageBuffer, 0);
//                     bytesPerRow = CVPixelBufferGetBytesPerRowOfPlane(imageBuffer, 0);
//                     
//                 } else { // expect kCVPixelFormatType_32BGRA
//                     
//                     format_opencv = CV_8UC4;
//                     
//                     bufferAddress = CVPixelBufferGetBaseAddress(imageBuffer);
//                     width = CVPixelBufferGetWidth(imageBuffer);
//                     height = CVPixelBufferGetHeight(imageBuffer);
//                     bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer);
//                     
//                 }
//                 
//                 CGSize realSize;
//                 realSize.width=makeSize.width;
//                 realSize.height=makeSize.width*videoSize.height/videoSize.width;
//                 cv::Mat image(height, width, format_opencv, bufferAddress, bytesPerRow);
//                 cv::resize(image,image,cv::Size(videoSize.width,videoSize.height));
//
//             //    resize(image,image,cv::Size(100,100));
//                 image=image*1.5;
//                 cv::Mat* result = NULL;

                 
                 [videoWriterInput appendSampleBuffer:sampleBuffer];
                 CFRelease(sampleBuffer);
             }
             
             else {
                 
                 [videoWriterInput markAsFinished];
                 videoComplete=YES;
                 //if ([videoReader status] == AVAssetReaderStatusCompleted) {
                     if(audioComplete==YES){
                         [self.delegate completeVideoConverter:outputURL];
                     }
                     
                     break;
                 //}
             }
         }
     }];
    //start writing from audio reader
   //  [audioReader startReading];
                     
   //  [videoWriter startSessionAtSourceTime:kCMTimeZero];
                     
                     dispatch_queue_t processingQueue1 = dispatch_queue_create("processingQueue2", NULL);
                     
                     [audioWriterInput requestMediaDataWhenReadyOnQueue:processingQueue1 usingBlock:^{
                         
                         while (audioWriterInput.readyForMoreMediaData) {
                             
                             CMSampleBufferRef sampleBuffer;
                             
                             if ([audioReader status] == AVAssetReaderStatusReading &&
                                 (sampleBuffer = [audioReaderOutput copyNextSampleBuffer])) {
                                 
                                 [audioWriterInput appendSampleBuffer:sampleBuffer];
                                 CFRelease(sampleBuffer);
                             }
                             
                             else {
                                 
                                [audioWriterInput markAsFinished];
                                 audioComplete = YES;
                                 if(videoComplete==YES){
                                // if ([audioReader status] == AVAssetReaderStatusCompleted) {
                                     
                                     [videoWriter finishWritingWithCompletionHandler:^(){
                                       
                                     }];
                                 
                                     [self.delegate completeVideoConverter:outputURL];
                               // }
                                   

                                }
                                   break;
                             }
                         }
                         
                     }
            ];
    




}

@end
