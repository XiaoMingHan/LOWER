//
//  VideoFileConverter.m
//  LightVideoPlayer
//
//  Created by My Star on 8/6/17.
//  Copyright © 2017 My Star. All rights reserved.
//

#import "VideoFileConverter.h"
#import <Photos/Photos.h>
#import "UserSettings.h"
#import "CustomIAPProcessor.h"
#import "MBProgressHUD.h"
@implementation VideoFileConverter

@synthesize videoSize;
- (void)removeFileAtURL:(NSURL *)url {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager removeItemAtURL:url error:nil];
}


-(void)resizeVideo:(NSURL*)inputURL outputURL:(NSURL*)outputURL addOutputSize:(CGSize)makeSize{
    [self removeFileAtURL:outputURL];
    
    NSError *error = nil;
    AVAssetWriter *videoWriter = [[AVAssetWriter alloc] initWithURL:outputURL fileType:AVFileTypeQuickTimeMovie error:&error];
    NSParameterAssert(videoWriter);
    AVAsset *avAsset = [[AVURLAsset alloc] initWithURL:inputURL options:nil] ;
    NSDictionary *videoCleanApertureSettings = [NSDictionary dictionaryWithObjectsAndKeys:
                                                [NSNumber numberWithInt:makeSize.width], AVVideoCleanApertureWidthKey,
                                                [NSNumber numberWithInt:makeSize.height], AVVideoCleanApertureHeightKey,
                                                [NSNumber numberWithInt:10], AVVideoCleanApertureHorizontalOffsetKey,
                                                [NSNumber numberWithInt:10], AVVideoCleanApertureVerticalOffsetKey,
                                                nil];
    NSDictionary *codecSettings = [NSDictionary dictionaryWithObjectsAndKeys:
                                   [NSNumber numberWithInt:1960000], AVVideoAverageBitRateKey,
                                   [NSNumber numberWithInt:24],AVVideoMaxKeyFrameIntervalKey,
                                   videoCleanApertureSettings, AVVideoCleanApertureKey,
                                   nil];
    NSDictionary *videoCompressionSettings = [NSDictionary dictionaryWithObjectsAndKeys:
                                              AVVideoCodecH264, AVVideoCodecKey,
                                              codecSettings,AVVideoCompressionPropertiesKey,
                                              [NSNumber numberWithInt:makeSize.width], AVVideoWidthKey,
                                              [NSNumber numberWithInt:makeSize.height], AVVideoHeightKey,
                                              AVVideoScalingModeResizeAspectFill,AVVideoScalingModeKey,
                                              nil];
    AVAssetWriterInput* videoWriterInput = [AVAssetWriterInput
                                            assetWriterInputWithMediaType:AVMediaTypeVideo
                                            outputSettings:videoCompressionSettings];
    NSParameterAssert(videoWriterInput);
    NSParameterAssert([videoWriter canAddInput:videoWriterInput]);
    videoWriterInput.expectsMediaDataInRealTime = YES;
    [videoWriter addInput:videoWriterInput];
    NSError *aerror = nil;
    AVAssetReader *reader = [[AVAssetReader alloc] initWithAsset:avAsset error:&aerror];
    AVAssetTrack *videoTrack = [[avAsset tracksWithMediaType:AVMediaTypeVideo]objectAtIndex:0];
    videoWriterInput.transform = videoTrack.preferredTransform;
    NSDictionary *videoOptions = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange] forKey:(id)kCVPixelBufferPixelFormatTypeKey];
    AVAssetReaderTrackOutput *asset_reader_output = [[AVAssetReaderTrackOutput alloc] initWithTrack:videoTrack outputSettings:videoOptions];
    [reader addOutput:asset_reader_output];
    //audio setup
    AVAssetWriterInput* audioWriterInput = [AVAssetWriterInput
                                            assetWriterInputWithMediaType:AVMediaTypeAudio
                                            outputSettings:nil];
    AVAssetReader *audioReader = [AVAssetReader assetReaderWithAsset:avAsset error:&error];
    NSArray *audioArray=[avAsset tracksWithMediaType:AVMediaTypeAudio];
      __block BOOL audioComplete=NO;
    AVAssetReaderOutput *readerOutput=nil;
    if([audioArray count]!=0){
    AVAssetTrack* audioTrack = [[avAsset tracksWithMediaType:AVMediaTypeAudio] objectAtIndex:0];
    readerOutput = [AVAssetReaderTrackOutput assetReaderTrackOutputWithTrack:audioTrack outputSettings:nil];
    [audioReader addOutput:readerOutput];
    NSParameterAssert(audioWriterInput);
    NSParameterAssert([videoWriter canAddInput:audioWriterInput]);
    audioWriterInput.expectsMediaDataInRealTime = NO;
    [videoWriter addInput:audioWriterInput];
        audioComplete=YES;
    }
    [videoWriter startWriting];
    [videoWriter startSessionAtSourceTime:kCMTimeZero];
    [reader startReading];
  

    dispatch_queue_t _processingQueue = dispatch_queue_create("assetAudioWriterQueue", NULL);
    [videoWriterInput requestMediaDataWhenReadyOnQueue:_processingQueue usingBlock:
     ^{
         while ([videoWriterInput isReadyForMoreMediaData]) {
             
     
             CMSampleBufferRef sampleBuffer;
             if ([reader status] == AVAssetReaderStatusReading &&
                 (sampleBuffer = [asset_reader_output copyNextSampleBuffer])) {
                 
                 
                 
                 
                 BOOL result = [videoWriterInput appendSampleBuffer:sampleBuffer];
                 CFRelease(sampleBuffer);
                 if (!result) {
                     // PROBLEM SEEMS TO BE HERE... result is getting false value....
                     //  [reader cancelReading];
                     //  NSLog(@"NO RESULT");
                     //NSLog(@"videoWriter.error: %@", videoWriter.error);
                     // break;
                 }
             } else {
                 [videoWriterInput markAsFinished];
                 if(readerOutput==nil){
                     [videoWriter finishWriting];
                     [self.delegate completeVideoConverter:outputURL];
                    break;

                 }
                 switch ([reader status]) {
                     case AVAssetReaderStatusReading:
                         // the reader has more for other tracks, even if this one is done
                         break;
                     case AVAssetReaderStatusCompleted:
                         // your method for when the conversion is done
                         // should call finishWriting on the writer
                         //hook up audio track
                         [audioReader startReading];
                         [videoWriter startSessionAtSourceTime:kCMTimeZero];
                         // dispatch_queue_t mediaInputQueue = dispatch_queue_create("mediaInputQueue", NULL);
                         // [audioWriterInput requestMediaDataWhenReadyOnQueue:mediaInputQueue usingBlock:^
                         //{
                         NSLog(@"Request");
                         NSLog(@"Asset Writer ready :%d",audioWriterInput.readyForMoreMediaData);
                         while (audioWriterInput.readyForMoreMediaData) {
                             CMSampleBufferRef nextBuffer;
                             if ([audioReader status] == AVAssetReaderStatusReading &&
                                 (nextBuffer = [readerOutput copyNextSampleBuffer])) {
                                // NSLog(@"Ready");
                                 if (nextBuffer) {
                                     //NSLog(@"NextBuffer");
                                     [audioWriterInput appendSampleBuffer:nextBuffer];
                                 }
                             }else{
                                 [audioWriterInput markAsFinished];
                                 if([audioReader status]==AVAssetReaderStatusCompleted)
                                 {
                                     [videoWriter finishWriting];
                                     [self.delegate completeVideoConverter:outputURL];
                                     break;
                                 }
                                 
                             }
                         }
                         break;
                     case AVAssetReaderStatusFailed:
                         [videoWriter cancelWriting];
                         break;
                 }
                 break;
             }
         }
     }
     ];
}
-(void)finishVideoConvert:(NSURL*)url{
    [self writeMovieToLibraryWithPath:url];
    
}
- (void)writeMovieToLibraryWithPath:(NSURL *)path
{
    NSLog(@"writing %@ to library", path);
    
    __block PHObjectPlaceholder *placeholder;
    
    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
        PHAssetChangeRequest* createAssetRequest = [PHAssetChangeRequest creationRequestForAssetFromVideoAtFileURL:path];
        placeholder = [createAssetRequest placeholderForCreatedAsset];
        
    } completionHandler:^(BOOL success, NSError *error) {
        if (success)
        {
            NSLog(@"didFinishRecordingToOutputFileAtURL - success for ios9");
            
        }
        else
        {
            NSLog(@"%@", error);
        }
    }];
}
-(void)selectVideo:(NSURL*)inputURL outputURL:(NSURL*)outputURL parent:(UIViewController*)mainview{
 
    main_view=mainview;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(productPurchased:) name:IAPHelperProductPurchasedNotification object:nil];
    inputVideo=inputURL;
    outputVideo=outputURL;
    
    
    NSString *emoji1 = @"\\ud83d\\udd12";//\uD83D\uDD13
    NSData *emojiData1 = [emoji1 dataUsingEncoding:NSUTF8StringEncoding];
    NSString *lockemoji = [[NSString alloc] initWithData:emojiData1 encoding:NSNonLossyASCIIStringEncoding];

    NSString *lockEnable;
    if(Settings.inapppurchace_level3==YES){
        lockEnable=@"" ;
    }else{
        lockEnable=lockemoji ;
    }

UIAlertController * alert=   [UIAlertController
                              alertControllerWithTitle:@"Recording Quality"
                              message:@""
                              preferredStyle:UIAlertControllerStyleAlert];

UIAlertAction* action1 = [UIAlertAction
                          actionWithTitle:@"720p"
                          style:UIAlertActionStyleDefault
                          handler:^(UIAlertAction * action)
                          {
                              [alert dismissViewControllerAnimated:YES completion:nil];
                              [self cameraRecordingSizeAlert:0 addView:mainview];
                          }];
UIAlertAction* action2 = [UIAlertAction
                          actionWithTitle:@"480p"
                          style:UIAlertActionStyleDefault
                          handler:^(UIAlertAction * action)
                          {
                              [alert dismissViewControllerAnimated:YES completion:nil];
                              [self cameraRecordingSizeAlert:1 addView:mainview];
                          }];
UIAlertAction* action3 = [UIAlertAction
                          actionWithTitle:@"360p"
                          style:UIAlertActionStyleDefault
                          handler:^(UIAlertAction * action)
                          {
                              [alert dismissViewControllerAnimated:YES completion:nil];
                              [self cameraRecordingSizeAlert:2 addView:mainview];
                          }];
UIAlertAction* action4 = [UIAlertAction
                          actionWithTitle:@"240p"
                          style:UIAlertActionStyleDefault
                          handler:^(UIAlertAction * action)
                          {
                              [alert dismissViewControllerAnimated:YES completion:nil];
                              [self cameraRecordingSizeAlert:3 addView:mainview];
                          }];

UIAlertAction* action5 = [UIAlertAction
                          actionWithTitle:@"120p"
                          style:UIAlertActionStyleDefault
                          handler:^(UIAlertAction * action)
                          {
                              [alert dismissViewControllerAnimated:YES completion:nil];
                              [self cameraRecordingSizeAlert:4 addView:mainview];
                          }];
UIAlertAction* action6 = [UIAlertAction
                              actionWithTitle:[NSString stringWithFormat:@"%@ %@",lockEnable,@" Custome size"]
                              style:UIAlertActionStyleDefault
                              handler:^(UIAlertAction * action)
                              {
                          
                              
                              
                              [alert dismissViewControllerAnimated:YES completion:nil];
                              
                              
                              [self cameraRecordingSizeAlert:5 addView:mainview];
                          }];
UIAlertAction* action7 = [UIAlertAction
                          actionWithTitle:@"Cancel"
                          style:UIAlertActionStyleDefault
                          handler:^(UIAlertAction * action)
                          {
                              [alert dismissViewControllerAnimated:YES completion:nil];
                              [self cameraRecordingSizeAlert:6 addView:mainview];
                              
                          }];
[alert addAction:action1];
[alert addAction:action2];
[alert addAction:action3];
[alert addAction:action4];
[alert addAction:action5];
[alert addAction:action6];
[alert addAction:action7];
    [mainview presentViewController:alert animated:YES completion:nil];

}

#pragma mark IN APP PURCHASE
- (void)productPurchased:(NSNotification *)notification
{
    NSString *productIdentifier = notification.object;
    NSLog(@"%@", productIdentifier);
   if ([productIdentifier isEqualToString:@"com.vweeter.lower.record3"]) {
       
       waitCancel=YES;
        [[NSUserDefaults standardUserDefaults] setObject:@"YES" forKey:@"Unlimited_recording"];
        Settings.inapppurchace_level3=YES;
      // [self cameraRecordingSizeAlert:5 addView:main_view];
       // [self resizeVideo:inputVideo outputURL:outputVideo  addOutputSize:videoSize];
       
    }
    [main_view dismissViewControllerAnimated:YES completion:NULL];
}
#pragma mark - user define functions

-(void)cameraRecordingSizeAlert:(int)index addView:(UIViewController*)mainview{
    

    switch (index) {
        case 0:
            //_recordingQuality.text=@"Recording Quality (720p)";
            videoSize=CGSizeMake(720, 1280);
            
            break;
        case 1:
           // _recordingQuality.text=@"Recording Quality (480p)";
            videoSize=CGSizeMake(480, 640);
            break;
        case 2:
           // _recordingQuality.text=@"Recording Quality (360p)";
            videoSize=CGSizeMake(360, 480);
            break;
        case 3:
           // _recordingQuality.text=@"Recording Quality (240p)";
            videoSize=CGSizeMake(240, 360);
            
            break;
        case 4:
           // _recordingQuality.text=@"Recording Quality (120p)";
            videoSize=CGSizeMake(120, 240);
            break;
        case 5:
        {
            
            if(Settings.inapppurchace_level3==YES){
           // _recordingQuality.text=@"Recording Quality (custom)";
            NSString * msg=[NSString stringWithFormat:@"current size= %dx%d",(int)videoSize.width,(int)videoSize.height];
            UIAlertController * alertController = [UIAlertController alertControllerWithTitle: @"Input video size"
                                                                                      message: msg
                                                                               preferredStyle:UIAlertControllerStyleAlert];
            [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
                textField.placeholder = @"width";
                textField.textColor = [UIColor blueColor];
                textField.clearButtonMode = UITextFieldViewModeWhileEditing;
                textField.borderStyle = UITextBorderStyleRoundedRect;
                textField.keyboardType = UIKeyboardTypeDecimalPad;
            }];
            [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
                textField.placeholder = @"height";
                textField.textColor = [UIColor blueColor];
                textField.clearButtonMode = UITextFieldViewModeWhileEditing;
                textField.borderStyle = UITextBorderStyleRoundedRect;
                textField.keyboardType = UIKeyboardTypeDecimalPad;
            }];
            [alertController addAction:[UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                NSArray * textfields = alertController.textFields;
                float width = [((UITextField *)textfields[0]).text floatValue];
                float height = [((UITextField *)textfields[1]).text floatValue];
                
                if(width<20 || height<20){
                    UIAlertController * alertController1 = [UIAlertController alertControllerWithTitle: @"Warning!"
                                                                                               message: @"You can't set the Width or height to lower 20 pixel!\n please set again "
                                                                                        preferredStyle:UIAlertControllerStyleAlert];
                    [alertController1 addAction:[UIAlertAction actionWithTitle:@"Confirm" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                        
                        [mainview dismissViewControllerAnimated:YES completion:NULL];
                    }]];
                    [mainview presentViewController:alertController1 animated:YES completion:nil];
                    
                }else{
                    videoSize=CGSizeMake(width,height);
                    [mainview dismissViewControllerAnimated:YES completion:NULL];
                    
                    [self resizeVideo:inputVideo outputURL:outputVideo  addOutputSize:videoSize];
                }
            }]];
            [alertController addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                
                
            }]];
            
            [mainview presentViewController:alertController animated:YES completion:nil];
            }else{
                UIAlertController * alertController = [UIAlertController alertControllerWithTitle: @"Custom Size"
                                                                                          message: @"Dp you want to unlock custom size?"
                                                                                   preferredStyle:UIAlertControllerStyleAlert];
                [alertController addAction:[UIAlertAction actionWithTitle:@"No" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                    [mainview dismissViewControllerAnimated:YES completion:NULL];
                    
                }]];
                [alertController addAction:[UIAlertAction actionWithTitle:@"Yes" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                    [self waitProgresss];
                    [[CustomIAPProcessor sharedInstance] buyWithProductIdentifiers:@"com.vweeter.lower.record3"];
                    
                    
                }]];

                [mainview presentViewController:alertController animated:YES completion:nil];
            }

            
        }
            break;
        case 6:
            //_recordingQuality.text=@"Recording Quality (720p)";
            break;
        default:
            break;
    }
    //720x1280
    //480x640
    //360x480
    //240x360
    //120x240
    if(index!=5){
    [mainview dismissViewControllerAnimated:YES completion:NULL];
    
    if(index!=6)[self resizeVideo:inputVideo outputURL:outputVideo  addOutputSize:videoSize];
    }
}
- (void)doSomeWorkWithProgress{
    waitCancel = NO;
    // This just increases the progress indicator in a loop.
    float progress = 0.0f;
    while (progress < 10.0f) {
        if (waitCancel) break;
        progress += 0.01f;
        dispatch_async(dispatch_get_main_queue(), ^{
            // Instead we could have also passed a reference to the HUD
            // to the HUD to myProgressTask as a method parameter.
            [MBProgressHUD HUDForView:main_view.view].progress = progress;
        });
        usleep(50000);
    }
}

-(void)waitProgresss{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:main_view.view animated:YES];
    
    // Set some text to show the initial status.
    hud.label.text = NSLocalizedString(@"Preparing...", @"HUD preparing title");
    // Will look best, if we set a minimum size.
    hud.minSize = CGSizeMake(150.f, 100.f);
    
    dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), ^{
        // Do something useful in the background and update the HUD periodically.
        [self doSomeWorkWithProgress];
        dispatch_async(dispatch_get_main_queue(), ^{
            [hud hideAnimated:YES];
        });
    });
}

@end
