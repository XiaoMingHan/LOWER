//
//  ASScreenRecorder.h
//  ScreenRecorder
//
//  Created by Alan Skipp on 23/04/2014.
//  Copyright (c) 2014 Alan Skipp. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
typedef void (^VideoCompletionBlock)(NSURL *url);
@protocol ASScreenRecorderDelegate;

@interface ASScreenRecorder : NSObject
@property (nonatomic, readonly) BOOL isRecording;
@property  BOOL microphoneMute;

// delegate is only required when implementing ASScreenRecorderDelegate - see below
@property (nonatomic, weak) id <ASScreenRecorderDelegate> delegate;

// if saveURL is nil, video will be saved into camera roll
// this property can not be changed whilst recording is in progress
@property (strong, nonatomic) NSURL *videoURL;
@property (strong, nonatomic) UIImage *saveImage;
@property (weak, nonatomic) UIView *viewToCapture;
@property (nonatomic)   CGFloat scale;
+ (instancetype)sharedInstance;
- (BOOL)startRecording;
- (void)tearDown;
-(UIImage*)captureOneFrame;
-(void)saveUIView:(UIView*)view;
- (float)getRecordingTimeStamp;
- (void)stopRecordingWithCompletion:(VideoCompletionBlock)completionBlock;
@end


// If your view contains an AVCaptureVideoPreviewLayer or an openGL view
// you'll need to write that data into the CGContextRef yourself.
// In the viewcontroller responsible for the AVCaptureVideoPreviewLayer / openGL view
// set yourself as the delegate for ASScreenRecorder.
// [ASScreenRecorder sharedInstance].delegate = self
// Then implement 'writeBackgroundFrameInContext:(CGContextRef*)contextRef'
// use 'CGContextDrawImage' to draw your view into the provided CGContextRef
@protocol ASScreenRecorderDelegate <NSObject>
- (void)writeBackgroundFrameInContext:(CGContextRef*)contextRef;
- (void)completeVideoConverter:(NSURL*)filePath;
@end
