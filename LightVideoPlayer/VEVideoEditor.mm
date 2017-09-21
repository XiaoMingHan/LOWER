//
//  VideoEditor.m
//  VideoEditor2
//
//  Created by Sukrit Sunama on 1/31/56 BE.
//  Copyright (c) 2556 Afternoon Tea Break. All rights reserved.
//
#import "opencv2/opencv.hpp"
#import "VEVideoEditor.h"
#import "VEVideoEditorDelegate.h"
#import "VEVideoComposition.h"
#import "VEAudioComposition.h"
#import "VEUtilities.h"
#import "VEVideoTrack.h"
#import "VEAudioComponent.h"
#import "VETimer.h"

@implementation VEVideoEditor

@synthesize delegate, videoComposition, audioComposition, encode, size, duration, fps, isProcessing, currentFrame, previewTime, assetWriter, decodingTimer, encodingTimer, convertingImageTimer, rotateImageTimer, drawImageTimer, rotateVideoTimer, createImageTimer;

- (id)init {
    self = [super init];
    
    if (self) {
        videoComposition = [[VEVideoComposition alloc] init];
        audioComposition = [[VEAudioComposition alloc] init];

        
        videoComposition.editor = self;
        audioComposition.editor = self;
        
        encodingTimer = [[VETimer alloc] init];
        decodingTimer = [[VETimer alloc] init];
        convertingImageTimer = [[VETimer alloc] init];
        rotateVideoTimer = [[VETimer alloc] init];
        drawImageTimer = [[VETimer alloc] init];
        createImageTimer = [[VETimer alloc] init];
        rotateImageTimer = [[VETimer alloc] init];
    }
    
    return self;
}

- (id)initWithURL:(NSURL *)url {
    self = [self init];
    
    if (self) {
        //Video
        VEVideoTrack *videoTrack = [[VEVideoTrack alloc] initWithURL:url];
        
        [videoComposition addComponent:videoTrack];
        size = videoTrack.size;
        fps = videoTrack.fps;
        
        //Audio
        VEAudioComponent *audioComponent = [[VEAudioComponent alloc] initWithURL:url];
        
        [audioComposition addComponent:audioComponent];
    }
    
    return self;
}

- (id)initWithPath:(NSString *)path {
    return [self initWithURL:[VEUtilities convertURLFromPath:path]];
}

- (id)initWithSize:(CGSize)_size fps:(double)_fps {
    self = [super init];
    
    if (!self) {
        
    }
    
    return self;
}

- (void)exportToURL:(NSURL *)url {
    [self exportStandardMethodToURL:url];
}

- (void)exportStandardMethodToURL:(NSURL *)url {
    [VEUtilities removeFileAtURL:url];
    isProcessing =  YES;
    
    NSError *error = nil;
    assetWriter = [[AVAssetWriter alloc] initWithURL:url fileType:AVFileTypeQuickTimeMovie error:&error];
    NSParameterAssert(assetWriter);
    assetWriter.shouldOptimizeForNetworkUse = NO;
    
    //Video
    if ([encode length] == 0) {
        encode = AVVideoCodecH264;
    }
    
    
    NSDictionary *bufferAttributes = @{(id)kCVPixelBufferPixelFormatTypeKey : @(kCVPixelFormatType_32BGRA),
                                       (id)kCVPixelBufferCGBitmapContextCompatibilityKey : @YES,
                                       (id)kCVPixelBufferWidthKey : @(size.width ),
                                       (id)kCVPixelBufferHeightKey : @(size.height ),
                                       (id)kCVPixelBufferBytesPerRowAlignmentKey : @(size.width * 4)
                                       };
    
    
    NSInteger pixelNumber = size.width * size.height ;
    NSDictionary* videoCompression = @{AVVideoAverageBitRateKey: @(pixelNumber * 11.4)};
    
    NSDictionary* videoSettings = @{AVVideoCodecKey: AVVideoCodecH264,
                                    AVVideoWidthKey: [NSNumber numberWithInt:size.width],
                                    AVVideoHeightKey: [NSNumber numberWithInt:size.height],
                                    AVVideoCompressionPropertiesKey: videoCompression};
//    NSDictionary *videoSettings = [NSDictionary dictionaryWithObjectsAndKeys:
//                                   encode, AVVideoCodecKey,
//                                   [NSNumber numberWithInt:size.width], AVVideoWidthKey,
//                                   [NSNumber numberWithInt:size.height], AVVideoHeightKey,
//                                   nil];
    
    AVAssetWriterInput *assetWriterVideoInput = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeVideo outputSettings:videoSettings];
    assetWriterVideoInput.expectsMediaDataInRealTime = YES;
    
    /*
     if (orientation == UIImageOrientationUp) {
     assetWriterVideoInput.transform = CGAffineTransformMake(0, 1.0, -1.0, 0, size.width, 0);
     }
     else if (orientation == UIImageOrientationDown) {
     assetWriterVideoInput.transform = CGAffineTransformMake(0, -1.0, 1.0, 0, 0, size.width);
     }
     else if (orientation == UIImageOrientationLeft) {
     assetWriterVideoInput.transform = CGAffineTransformMake(1.0, 0, 0, 1.0, 0, 0);
     }
     else if (orientation == UIImageOrientationRight) {
     assetWriterVideoInput.transform = CGAffineTransformMake(-1.0, 0, 0, -1.0, size.width, size.height);
     }
     */
    
//    NSDictionary *bufferAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
//                                      [NSNumber numberWithInt:kCVPixelFormatType_32BGRA], kCVPixelBufferPixelFormatTypeKey, nil];
    
    AVAssetWriterInputPixelBufferAdaptor *adaptor = [AVAssetWriterInputPixelBufferAdaptor assetWriterInputPixelBufferAdaptorWithAssetWriterInput:assetWriterVideoInput sourcePixelBufferAttributes:bufferAttributes];
    NSParameterAssert(assetWriterVideoInput);
    NSParameterAssert([assetWriter canAddInput:assetWriterVideoInput]);
    [assetWriter addInput:assetWriterVideoInput];
    
    //Audio
    AudioChannelLayout channelLayout;
    memset(&channelLayout, 0, sizeof(AudioChannelLayout));
    channelLayout.mChannelLayoutTag = kAudioChannelLayoutTag_Stereo;
    
    NSDictionary *audioSettings = [NSDictionary dictionaryWithObjectsAndKeys:
                                   [NSNumber numberWithInt: kAudioFormatMPEG4AAC], AVFormatIDKey,
                                   [NSNumber numberWithInt:2], AVNumberOfChannelsKey,
                                   [NSNumber numberWithFloat:44100.0], AVSampleRateKey,
                                   [NSData dataWithBytes:&channelLayout length: sizeof(AudioChannelLayout) ], AVChannelLayoutKey,
                                   [NSNumber numberWithInt:64000], AVEncoderBitRateKey,
                                   nil];
    AVAssetWriterInput *assetWriterAudioInput = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeAudio outputSettings:audioSettings];
    NSParameterAssert(assetWriterAudioInput);
    NSParameterAssert([assetWriter canAddInput:assetWriterAudioInput]);
    [assetWriter addInput:assetWriterAudioInput];
    
    if (![assetWriter startWriting]) {
        isProcessing = NO;
        NSMutableDictionary *info = [NSMutableDictionary dictionary];
        [info setValue:[NSString stringWithFormat:@"Cannot to start writing for reason : %@", error.localizedDescription] forKey:NSLocalizedDescriptionKey];
        NSError *error = [[NSError alloc] initWithDomain:@"VideoEditor" code:1 userInfo:info];
        
        [delegate videoEditor:self exportFinishWithError:error];
    }
    [assetWriter startSessionAtSourceTime:kCMTimeZero];
    
    [videoComposition beginExport];
    [audioComposition beginExport];
    
    currentFrame = 0;
    __block BOOL isFinishVideo = NO;
    __block BOOL isFinishAudio = NO;
    
    //Write Video
    dispatch_queue_t videoQueue = dispatch_queue_create("Wite Video", NULL);
    
    [assetWriterVideoInput requestMediaDataWhenReadyOnQueue:videoQueue usingBlock:^{
        
        while ([assetWriterVideoInput isReadyForMoreMediaData]) {
            
            CGImageRef image = [videoComposition nextFrameImage];
       //     cv::Mat cvImage=[self convert2Mat:image];
//            cv::Mat res=cvImage;
//            CGSize videoSize=CGSizeMake(cvImage.cols, cvImage.rows);
//            CGSize realSize;
//            realSize.width=size.width;
//            realSize.height=size.width*videoSize.height/videoSize.width;
//            if(size.height<=realSize.height){
//                cv::Rect rect=cv::Rect(0,(realSize.height-size.height)/2,size.width,size.height);
//                res=res(rect);
//                
//            }else{
//                realSize.height=size.height;
//                realSize.width=size.height*videoSize.width/videoSize.height;
//                cv::Rect rect=cv::Rect((realSize.width-size.width)/20,0,size.width,size.height);
//                res=cvImage(rect);
//            }
       //    CGImageRef imageRes=[self convert2CGRef:cvImage].CGImage;
          
            
            
            
            CVPixelBufferRef buffer = [VEUtilities pixelBufferFromCGImage:image];
            
            [encodingTimer startProcess];
            
            if (![adaptor appendPixelBuffer:buffer withPresentationTime:CMTimeMake(currentFrame, fps)]) {
                isProcessing = NO;
                NSMutableDictionary *info = [NSMutableDictionary dictionary];
                [info setValue:[NSString stringWithFormat:@"Cannon append pixel buffer at frame %ld (%.2fs)", currentFrame, CMTimeGetSeconds(CMTimeMake(currentFrame, fps))] forKey:NSLocalizedDescriptionKey];
                NSError *error = [[NSError alloc] initWithDomain:@"VideoEditor" code:2 userInfo:info];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [delegate videoEditor:self exportFinishWithError:error];
                });
            }
            
            CGImageRelease(image);
            CVPixelBufferRelease(buffer);
            
            [encodingTimer endProcess];
            
         //   dispatch_async(dispatch_get_main_queue(), ^{
                [delegate videoEditor:self progressTo:currentFrame / (duration * fps)];
           // });
            
            currentFrame++;
            NSLog(@"%li",currentFrame);
            NSLog(@"%li",(long)(duration * fps));
            if (currentFrame >= (int)(duration * fps*0.95)) {
                [assetWriterVideoInput markAsFinished];
                
                isFinishVideo = YES;
                
                if (isFinishAudio) {
                    isProcessing = NO;
                    [assetWriter endSessionAtSourceTime:CMTimeMakeWithSeconds(duration, fps)];
                    
                    [assetWriter finishWritingWithCompletionHandler:^ {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [delegate videoEditor:self exportFinishWithError:nil];
                            
                            NSLog(@"Decoding = %.0f, %.0f", decodingTimer.averageTime, decodingTimer.totalTime);
                            NSLog(@"Encoding = %.0f, %.0f", encodingTimer.averageTime, encodingTimer.totalTime);
                            NSLog(@"Converting Image = %.0f, %.0f", convertingImageTimer.averageTime, convertingImageTimer.totalTime);
                            NSLog(@"Rotate Video = %.0f, %.0f", rotateVideoTimer.averageTime, rotateVideoTimer.totalTime);
                            NSLog(@"Draw Image = %.0f, %.0f", drawImageTimer.averageTime, drawImageTimer.totalTime);
                            NSLog(@"Create Image = %.0f, %.0f", createImageTimer.averageTime, createImageTimer.totalTime);
                            NSLog(@"Rotate Image = %.0f, %.0f", rotateImageTimer.averageTime, rotateImageTimer.totalTime);
                        });
                    }];
                }
                
                break;
            }
        }
    }];
//    NSLog(@"%li",currentFrame);
//    NSLog(@"%li",(long)(duration * fps));
    //Write Audio
    dispatch_queue_t audioQueue = dispatch_queue_create("Wite Audio", NULL);
    
    [assetWriterAudioInput requestMediaDataWhenReadyOnQueue:audioQueue usingBlock:^ {
        while(assetWriterAudioInput.readyForMoreMediaData)
        {
            CMSampleBufferRef nextBuffer = [audioComposition nextSampleBuffer];
            if(nextBuffer != NULL) {
                //append buffer
                [assetWriterAudioInput appendSampleBuffer:nextBuffer];
            }
            else {
                [assetWriterAudioInput markAsFinished];
                
                isFinishAudio = YES;
                
                if (isFinishVideo) {
                    isProcessing = NO;
                    [assetWriter endSessionAtSourceTime:CMTimeMakeWithSeconds(duration, fps)];
                    [assetWriter finishWritingWithCompletionHandler:^ {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [delegate videoEditor:self exportFinishWithError:nil];
                        });
                    }];
                 
                }
                break;
             
            }
        }
    }];

}

- (void)exportMultiThreadMethodToURL:(NSURL *)url {
    [VEUtilities removeFileAtURL:url];
    isProcessing =  YES;
    
    NSError *error = nil;
    assetWriter = [[AVAssetWriter alloc] initWithURL:url fileType:AVFileTypeQuickTimeMovie error:&error];
    NSParameterAssert(assetWriter);
    assetWriter.shouldOptimizeForNetworkUse = NO;
    
    //Video
    if ([encode length] == 0) {
        encode = AVVideoCodecH264;
    }
    
    NSDictionary *videoSettings = [NSDictionary dictionaryWithObjectsAndKeys:
                                   encode, AVVideoCodecKey,
                                   [NSNumber numberWithInt:size.width], AVVideoWidthKey,
                                   [NSNumber numberWithInt:size.height], AVVideoHeightKey,
                                   nil];
    
    AVAssetWriterInput *assetWriterVideoInput = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeVideo outputSettings:videoSettings];
    assetWriterVideoInput.expectsMediaDataInRealTime = YES;
    
    /*
     if (orientation == UIImageOrientationUp) {
     assetWriterVideoInput.transform = CGAffineTransformMake(0, 1.0, -1.0, 0, size.width, 0);
     }
     else if (orientation == UIImageOrientationDown) {
     assetWriterVideoInput.transform = CGAffineTransformMake(0, -1.0, 1.0, 0, 0, size.width);
     }
     else if (orientation == UIImageOrientationLeft) {
     assetWriterVideoInput.transform = CGAffineTransformMake(1.0, 0, 0, 1.0, 0, 0);
     }
     else if (orientation == UIImageOrientationRight) {
     assetWriterVideoInput.transform = CGAffineTransformMake(-1.0, 0, 0, -1.0, size.width, size.height);
     }
     */
    
    NSDictionary *bufferAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                      [NSNumber numberWithInt:kCVPixelFormatType_32BGRA], kCVPixelBufferPixelFormatTypeKey, nil];
    
    AVAssetWriterInputPixelBufferAdaptor *adaptor = [AVAssetWriterInputPixelBufferAdaptor assetWriterInputPixelBufferAdaptorWithAssetWriterInput:assetWriterVideoInput sourcePixelBufferAttributes:bufferAttributes];
    
    NSParameterAssert(assetWriterVideoInput);
    NSParameterAssert([assetWriter canAddInput:assetWriterVideoInput]);
    [assetWriter addInput:assetWriterVideoInput];
    
    //Audio
    AudioChannelLayout channelLayout;
    memset(&channelLayout, 0, sizeof(AudioChannelLayout));
    channelLayout.mChannelLayoutTag = kAudioChannelLayoutTag_Stereo;
    
    NSDictionary *audioSettings = [NSDictionary dictionaryWithObjectsAndKeys:
                                   [NSNumber numberWithInt: kAudioFormatMPEG4AAC], AVFormatIDKey,
                                   [NSNumber numberWithInt:2], AVNumberOfChannelsKey,
                                   [NSNumber numberWithFloat:44100.0], AVSampleRateKey,
                                   [NSData dataWithBytes:&channelLayout length: sizeof(AudioChannelLayout) ], AVChannelLayoutKey,
                                   [NSNumber numberWithInt:64000], AVEncoderBitRateKey,
                                   nil];
    AVAssetWriterInput *assetWriterAudioInput = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeAudio outputSettings:audioSettings];
    NSParameterAssert(assetWriterAudioInput);
    NSParameterAssert([assetWriter canAddInput:assetWriterAudioInput]);
    [assetWriter addInput:assetWriterAudioInput];
    
    if (![assetWriter startWriting]) {
        isProcessing = NO;
        NSMutableDictionary *info = [NSMutableDictionary dictionary];
        [info setValue:[NSString stringWithFormat:@"Cannot to start writing for reason : %@", error.localizedDescription] forKey:NSLocalizedDescriptionKey];
        NSError *error = [[NSError alloc] initWithDomain:@"VideoEditor" code:1 userInfo:info];
        
        [delegate videoEditor:self exportFinishWithError:error];
    }
    [assetWriter startSessionAtSourceTime:kCMTimeZero];
    
    [videoComposition beginExport];
    [audioComposition beginExport];
    
    currentFrame = 0;
    __block BOOL isFinishVideo = NO;
    __block BOOL isFinishAudio = NO;
    
    videoEncodingOperationQueue = [[NSOperationQueue alloc] init];
    videoEncodingOperationQueue.name = @"Video Encoding";
    
    __block int decodePointer = 0;
    __block int decodeCurrentFrame = 0;
    __block int encodePointer = 0;
    __block int encodeCurrentFrame = 0;
    
    [videoEncodingOperationQueue addOperationWithBlock:^{
        while (decodeCurrentFrame < duration * fps) {
            while (decodeCurrentFrame - encodeCurrentFrame > 29) {
                usleep(1);
            }
            
            CGImageRef image = [videoComposition nextFrameImage];
            buffers[decodePointer] = [VEUtilities pixelBufferFromCGImage:image];
            
            CGImageRelease(image);
            
            currentFrame++;
            decodeCurrentFrame++;
            decodePointer++;
            if (decodePointer > 29) {
                decodePointer = 0;
            }
        }
    }];
    
    //Write Video
    dispatch_queue_t videoQueue = dispatch_queue_create("Wite Video", NULL);
    
    [assetWriterVideoInput requestMediaDataWhenReadyOnQueue:videoQueue usingBlock:^{
        
        while ([assetWriterVideoInput isReadyForMoreMediaData]) {
            while (encodeCurrentFrame >= decodeCurrentFrame && encodeCurrentFrame < duration * fps) {
                usleep(1);
            }
            
            [encodingTimer startProcess];
            
            CVPixelBufferRef buffer = buffers[encodePointer];
            
            if (![adaptor appendPixelBuffer:buffer withPresentationTime:CMTimeMake(encodeCurrentFrame, fps)]) {
                isProcessing = NO;
                NSMutableDictionary *info = [NSMutableDictionary dictionary];
                [info setValue:[NSString stringWithFormat:@"Cannon append pixel buffer at frame %d (%.2fs)", encodeCurrentFrame, CMTimeGetSeconds(CMTimeMake(encodeCurrentFrame, fps))] forKey:NSLocalizedDescriptionKey];
                NSError *error = [[NSError alloc] initWithDomain:@"VideoEditor" code:2 userInfo:info];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [delegate videoEditor:self exportFinishWithError:error];
                });
            }
            
            
            CVPixelBufferRelease(buffer);
            
            [encodingTimer endProcess];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [delegate videoEditor:self progressTo:encodeCurrentFrame / (duration * fps)];
            });
            
            encodeCurrentFrame++;
            
            encodePointer++;
            if (encodePointer > 29) {
                encodePointer = 0;
            }
            
            if (encodeCurrentFrame >= duration * fps) {
                [assetWriterVideoInput markAsFinished];
                
                isFinishVideo = YES;
                
                if (isFinishAudio) {
                    isProcessing = NO;
                    [assetWriter endSessionAtSourceTime:CMTimeMakeWithSeconds(duration, fps)];
                    
                    [assetWriter finishWritingWithCompletionHandler:^ {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [delegate videoEditor:self exportFinishWithError:nil];
                            
                            NSLog(@"Decoding = %.0f, %.0f", decodingTimer.averageTime, decodingTimer.totalTime);
                            NSLog(@"Encoding = %.0f, %.0f", encodingTimer.averageTime, encodingTimer.totalTime);
                            NSLog(@"Converting Image = %.0f, %.0f", convertingImageTimer.averageTime, convertingImageTimer.totalTime);
                            NSLog(@"Rotate Image = %.0f, %.0f", rotateImageTimer.averageTime, rotateImageTimer.totalTime);
                            NSLog(@"Draw Image = %.0f, %.0f", drawImageTimer.averageTime, drawImageTimer.totalTime);
                        });
                    }];
                    
                    break;
                }
            }
        }
    }];
    
    //Write Audio
    dispatch_queue_t audioQueue = dispatch_queue_create("Wite Audio", NULL);
    
    [assetWriterAudioInput requestMediaDataWhenReadyOnQueue:audioQueue usingBlock:^ {
        while(assetWriterAudioInput.readyForMoreMediaData)
        {
            CMSampleBufferRef nextBuffer = [audioComposition nextSampleBuffer];
            if(nextBuffer != NULL) {
                //append buffer
                [assetWriterAudioInput appendSampleBuffer:nextBuffer];
            }
            else {
                [assetWriterAudioInput markAsFinished];
                
                isFinishAudio = YES;
                
                if (isFinishVideo) {
                    isProcessing = NO;
                    [assetWriter endSessionAtSourceTime:CMTimeMakeWithSeconds(duration, fps)];
                    [assetWriter finishWritingWithCompletionHandler:^ {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [delegate videoEditor:self exportFinishWithError:nil];
                        });
                    }];
                }
                
                break;
            }
        }
    }];
}

- (void)exportToPath:(NSString *)path{
    
}

- (void)setSize:(CGSize)_size {
    size = _size;
    
  //  previewViewController.view.frame = previewViewController.view.frame;
}


- (void)dispose {
    [videoComposition dispose];
}
-(cv::Mat)convert2Mat: (CGImageRef )imageRef
{
  
    CGColorSpaceRef colorSpace = CGImageGetColorSpace(imageRef);

    size_t numberOfComponents = CGColorSpaceGetNumberOfComponents(colorSpace);
    CGFloat cols =CGImageGetWidth(imageRef);
    CGFloat rows = CGImageGetHeight(imageRef);
    
    cv::Mat cvMat(rows, cols, CV_8UC4); // 8 bits per component, 4 channels
    CGBitmapInfo bitmapInfo = kCGImageAlphaNoneSkipLast | kCGBitmapByteOrderDefault;
    
    // check whether the UIImage is greyscale already
    if (numberOfComponents == 1){
        cvMat = cv::Mat(rows, cols, CV_8UC1); // 8 bits per component, 1 channels
        bitmapInfo = kCGImageAlphaNone | kCGBitmapByteOrderDefault;
    }
    
    CGContextRef contextRef = CGBitmapContextCreate(cvMat.data,             // Pointer to backing data
                                                    cols,                       // Width of bitmap
                                                    rows,                       // Height of bitmap
                                                    8,                          // Bits per component
                                                    cvMat.step[0],              // Bytes per row
                                                    colorSpace,                 // Colorspace
                                                    bitmapInfo);              // Bitmap info flags
    
    CGContextDrawImage(contextRef, CGRectMake(0, 0, cols, rows), imageRef);
    CGContextRelease(contextRef);
    return cvMat;
}
-(UIImage*)convert2CGRef:(cv::Mat)cvMat
{
    NSData *data = [NSData dataWithBytes:cvMat.data length:cvMat.elemSize()*cvMat.total()];
    
    CGColorSpaceRef colorSpace;
    CGBitmapInfo bitmapInfo;
    
    if (cvMat.elemSize() == 1) {
        colorSpace = CGColorSpaceCreateDeviceGray();
        bitmapInfo = kCGImageAlphaNone | kCGBitmapByteOrderDefault;
    } else {
        colorSpace = CGColorSpaceCreateDeviceRGB();
        bitmapInfo = kCGBitmapByteOrder32Little | (
                                                   cvMat.elemSize() == 3? kCGImageAlphaNone : kCGImageAlphaNoneSkipFirst
                                                   );
    }
    
    CGDataProviderRef provider = CGDataProviderCreateWithCFData((__bridge CFDataRef)data);
    
    // Creating CGImage from cv::Mat
    CGImageRef imageRef = CGImageCreate(
                                        cvMat.cols,                 //width
                                        cvMat.rows,                 //height
                                        8,                          //bits per component
                                        8 * cvMat.elemSize(),       //bits per pixel
                                        cvMat.step[0],              //bytesPerRow
                                        colorSpace,                 //colorspace
                                        bitmapInfo,                 // bitmap info
                                        provider,                   //CGDataProviderRef
                                        NULL,                       //decode
                                        false,                      //should interpolate
                                        kCGRenderingIntentDefault   //intent
                                        );
    
  
    UIImage *finalImage = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    CGDataProviderRelease(provider);
    CGColorSpaceRelease(colorSpace);
    return finalImage;
}
@end
