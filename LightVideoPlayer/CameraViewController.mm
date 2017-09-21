//
//  CameraViewController.m
//  LightVideoPlayer
//
//  Created by My Star on 7/27/17.
//  Copyright © 2017 My Star. All rights reserved.
//
#import <opencv2/opencv.hpp>
#import "myCamera.h"
#import "CameraViewController.h"
#import "WebItunesViewController.h"
#import "VideoFileConverter.h"
#import "UserSettings.h"
#import <Photos/Photos.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import "MBProgressHUD.h"
#import "MediaPlayer/MediaPlayer.h"
#define GOOGLE_ADMOB_UNITID_INTER @"ca-app-pub-7372783568928829/8754721879"
@interface CameraViewController ()<myCameraDelegate,UINavigationControllerDelegate, ASScreenRecorderDelegate ,UIImagePickerControllerDelegate, UINavigationControllerDelegate,VideoFileConverterDelegate>{
    myCamera* videoCamera;
 
    BOOL waitCancel;

    ASScreenRecorder *recorder;
    VideoFileConverter *converter;
    BOOL ads_dismiss;
    
   }

@end

@implementation CameraViewController
@synthesize  time_label, timeStamp,delegate,isRecorder,cameraPosition,appStart,fullvideo,interstitial,isImagePicker,isCapturing;
- (void)viewDidLoad {
    [self loadGoogleAdsFull];
    [super viewDidLoad];
    
    recorder=[ASScreenRecorder sharedInstance];
    converter=[VideoFileConverter new];
    converter.delegate=self;
    isRecorder=YES;
    videoCamera = [[myCamera alloc]
                   initWithParentView:_cameraView];
    videoCamera.delegate = self;
    videoCamera.defaultAVCaptureDevicePosition =
    AVCaptureDevicePositionBack;
    videoCamera.defaultAVCaptureSessionPreset =
    AVCaptureSessionPresetiFrame1280x720;
    videoCamera.defaultAVCaptureSessionPreset =
    AVCaptureSessionPresetHigh;
    
    videoCamera.defaultAVCaptureVideoOrientation =
    AVCaptureVideoOrientationPortrait;
    cameraPosition=AVCaptureDevicePositionBack;
     videoCamera.defaultFPS = 80;
    
    ads_dismiss=NO;

    isCapturing = NO;
    appStart=YES;
    isImagePicker=YES;
  
    // Do any additional setup after loading the view.
}
- (void) loadGoogleAdsFull {
    self.interstitial = [[GADInterstitial alloc] initWithAdUnitID:GOOGLE_ADMOB_UNITID_INTER];
    self.interstitial.delegate = self;
    GADRequest *request = [GADRequest request];
    request.testDevices = @[ kGADSimulatorID ];
    [self.interstitial loadRequest:request];
}

- (void) showAds
{
    if ([self.interstitial isReady]) {
        [self.interstitial presentFromRootViewController:self];
    }
    else
    {
        [self loadGoogleAdsFull];
    }
}
-(void)viewDidAppear:(BOOL)animated{
    [self checkMediaLibraryPermissions];
    
    [self refreshCameraView:Settings.videoSize];
    videoCamera.parentView=_cameraView;
   // recorder.microphoneMute=YES;
    
    if(appStart==YES){
       // [self waitProgresss];
        appStart=NO;
    }
    
    [self initCameraSettings];
    
    [_cameraView setBackgroundColor:[UIColor blackColor]];
   
 
    
    if(Settings.videoSize.width==720 && Settings.videoSize.height==1280)
    {
        fullvideo=YES;
        videoCamera.imageWidth=720;
        videoCamera.imageHeight=1280;
        
    }else{
        fullvideo=NO;
    }

    recorder.microphoneMute=Settings.microPhone;
    videoCamera.microphoneMute=Settings.microPhone;


    [videoCamera start];
    
}
- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    // Only portrait orientation
    return UIInterfaceOrientationMaskPortrait;
}


-(void)viewDidDisappear:(BOOL)animated{
    // videoCamera=nil;
    //recorder=nil;
    

}
- (void)layoutPreviewLayer;
{
}
-(void)refreshCameraView:(CGSize) size{
    
   
    
    CGSize phoneSize=[UIScreen mainScreen].bounds.size;
    _cameraView_width.constant=size.width;
    _cameraView_height.constant=size.height;
    _cropView_width.constant=size.width;
    _cropView_height.constant=size.height;
    
  
    _cropView_width.constant=phoneSize.width;
    _cropView_height.constant=_cropView_width.constant*size.height/size.width;
    
    
    if(_cropView_height.constant>phoneSize.height){
        _cropView_height.constant=phoneSize.height;
        _cropView_width.constant=_cropView_height.constant*size.width/size.height;
    }
    NSLog(@"video size %fx%f",_cropView_width.constant,_cropView_height.constant);
      Settings.scale=size.width/phoneSize.width;
    NSLog(@"%f",Settings.scale);
    recorder.scale=Settings.scale;
    _cameraView_width.constant=_cropView_width.constant;
    _cameraView_height.constant=_cropView_height.constant;
    
    
    
    _cameraView_width.constant=_cropView_width.constant;
    _cameraView_height.constant=_cameraView_width.constant*1280.0/720.0;
//    
    if(_cameraView_height.constant<_cropView_height.constant){
        _cameraView_height.constant=_cropView_height.constant;
        _cameraView_width.constant=_cameraView_height.constant*720.0/1280.0;
    }
    NSLog(@"camera size %fx%f",_cropView_width.constant*Settings.scale,_cropView_height.constant*Settings.scale);
    [_cameraView setNeedsLayout];
    [_cameraView layoutIfNeeded];
    [_cropView setNeedsLayout];
    [_cropView layoutIfNeeded];


}
#pragma mark - user defined functions
-(void)initCameraSettings{
    
    
    
    recorder.viewToCapture=_cropView;
    
    recorder.delegate = self;
    
    recorder.microphoneMute=NO;


}
- (void)processImage:(cv::Mat&)image
{
   // image=image*1.5;
    if(isRecorder==NO) return;
        if(isCapturing){
         if(fullvideo==YES)
            timeStamp=[videoCamera getRecordingTimeStamp];
          else
            timeStamp=[recorder getRecordingTimeStamp];
        }
    if(Settings.inapppurchace_level2==NO){
        if(timeStamp>=300){
            
            dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate Stoped];
            [self requestInAppPurchase1];
            });
        }
    }
    
}
-(void)convertCamera{

    if(isCapturing!=YES){
    [videoCamera switchCameras];
  
    if(cameraPosition==AVCaptureDevicePositionBack){
        cameraPosition=AVCaptureDevicePositionFront;
    }else{
        cameraPosition=AVCaptureDevicePositionBack;
    }
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)writeBackgroundFrameInContext:(CGContextRef *)contextRef{
    
    //
    //    NSString *str =@"SelfieYO";
    //    CGContextSaveGState(*contextRef);
    //   // CGContextTranslateCTM(contextRef, radius, radius);
    //   // CGContextRotateCTM(contextRef, i * 15 * M_PI/180.0);
    //   CGSize sizet=CGSizeMake(_glkView.bounds.size.width/6,_glkView.bounds.size.height/10);
    //    [[UIColor whiteColor] set];
    //    CGSize size = [str sizeWithFont:[UIFont fontWithName:@"Helvetica" size:12.0]
    //                  constrainedToSize:sizet
    //                      lineBreakMode:(NSLineBreakByWordWrapping)];
    //
    //    [str drawAtPoint:CGPointMake(size.width/2, size.height/2) withFont:[UIFont fontWithName:@"Helvetica" size:12.0]];
    //   // [str drawAtPoint:<#(CGPoint)#> withAttributes:<#(nullable NSDictionary<NSString *,id> *)#>]
    //
    //    CGContextRestoreGState(*contextRef);
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
-(void)RecordAndStop:(BOOL)flag{


  
    if (isRecorder==NO){
       if(fullvideo==YES){
        [recorder saveUIView:_cameraView];
       }else
        [recorder captureOneFrame];
    }else{
        isCapturing=flag;
        if(fullvideo==YES){
         if(flag)[videoCamera startRecord];
         else[videoCamera stopRecord];
        timeStamp=0;
        }else{
           if(flag)[recorder startRecording];
           else{
            [recorder stopRecordingWithCompletion:^(NSURL *url) {
            timeStamp=0;
            }];
           }
        }
    }
}
-(void)videoGalleryOpen{
    
    if( Settings.inapppurchace_level1==NO)
    {
    if (self.interstitial.isReady ){
        ads_dismiss=NO;
        isImagePicker=YES;
        [self.interstitial presentFromRootViewController:self];
    } else {
        [self videoFilePicker:self];
    }

    }else{
        [self videoFilePicker:self];
    }
    
    
}
-(void)previewAdmobopenSettings:(UIViewController*)settingsView{
    isImagePicker=NO;
       
}
- (void) videoFilePicker:(UIViewController*)view{
    

    UIImagePickerController *videoPicker = [[UIImagePickerController alloc] init];
    videoPicker.delegate = self;
    videoPicker.modalPresentationStyle = UIModalPresentationCurrentContext;
    
    videoPicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;

    videoPicker.mediaTypes = @[(NSString*)kUTTypeMovie, (NSString*)kUTTypeAVIMovie, (NSString*)kUTTypeVideo, (NSString*)kUTTypeMPEG4];
    videoPicker.videoQuality = UIImagePickerControllerQualityTypeHigh;
 
    [view presentViewController:videoPicker animated:NO completion:nil];

}
- (void) imagePickerController: (UIImagePickerController *) picker didFinishPickingMediaWithInfo: (NSDictionary *) info {
    

    NSURL *movieURL = [info objectForKey:
                       UIImagePickerControllerMediaURL];
    
    NSURL *uploadURL = [NSURL fileURLWithPath:[[NSTemporaryDirectory() stringByAppendingPathComponent:@"k1"] stringByAppendingString:@".mov"]];
    [converter selectVideo:movieURL outputURL:uploadURL parent: picker];

    //   
}

-(void)completeVideoConverter:(NSURL*)filePath{
  
     dispatch_async(dispatch_get_main_queue(), ^{
    [self waitSaveVideoProgresss];
 
    [self writeMovieToLibraryWithPath:filePath];
   
    });
}
-(void) checkMediaLibraryPermissions {
    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {   }];
}
- (void)writeMovieToLibraryWithPath:(NSURL *)path
{
    NSLog(@"writing %@ to library", path);
    
    

    __block PHObjectPlaceholder *placeholder;
    
    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
        PHAssetChangeRequest* createAssetRequest = [PHAssetChangeRequest creationRequestForAssetFromVideoAtFileURL:path];
        placeholder = [createAssetRequest placeholderForCreatedAsset];
        
    } completionHandler:^(BOOL success, NSError *error) {
        NSString *message;
        
        BOOL msgFlag=YES;
        waitCancel=YES;

        
        if (success)
        {
           message=@"The file was converted correctly";
            if([Settings GetRecordNumber]%3==2){
                
                UIAlertController * alertController1 = [UIAlertController alertControllerWithTitle: @"Rate Our App"
                                                                                           message: @"Would you please rate our app?"
                                                                                    preferredStyle:UIAlertControllerStyleAlert];
                [alertController1 addAction:[UIAlertAction actionWithTitle:@"Later" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                    
                    [self dismissViewControllerAnimated:YES completion:NULL];
                }]];
                [alertController1 addAction:[UIAlertAction actionWithTitle:@"YES" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                    [Settings StopRecordNumber];
                    
                    [self gotoItunes];
                 
                    
                    [self dismissViewControllerAnimated:YES completion:NULL];
                  
                }]];
                waitCancel=YES;
                [self presentViewController:alertController1 animated:YES completion:nil];

                msgFlag=NO;
               //[self.delegate gotoCameraSettings];
            }else{
                
            }
            if([Settings GetRecordNumber]!=-1) [Settings CountRecordNumber];
        }
        else
        {
            message=@"Sorry, can't save to Photo library! \n Clean the library!";
            UIAlertController * alertController1 = [UIAlertController alertControllerWithTitle: @""
                                                                                       message: message
                                                                                preferredStyle:UIAlertControllerStyleAlert];
            [alertController1 addAction:[UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                
                [self dismissViewControllerAnimated:YES completion:NULL];
            }]];
           
            [self presentViewController:alertController1 animated:YES completion:nil];

            
        }
        
    }];
 }
-(void)gotoItunes{
    

//        
        UIApplication *application = [UIApplication sharedApplication];
        
        NSString *iTunesLink = @"http://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?id=1265794764&pageNumber=0&sortOrdering=2&type=Purple+Software&mt=8";
        [application openURL:[NSURL URLWithString:iTunesLink] options:@{} completionHandler:nil];
        
        //[[UIApplication sharedApplication] openURL:[NSURL URLWithString:iTunesLink]];


//
}
-(void)requestInAppPurchase1{
    UIAlertController * alert=   [UIAlertController
                                  alertControllerWithTitle:@"Record Limit"
                                  message:@"You can't recode over 5 minutes!\n please Unlock unlimited!"
                                  preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* confrim = [UIAlertAction
                              actionWithTitle:@"YES"
                              style:UIAlertActionStyleDefault
                              handler:^(UIAlertAction * action)
                              {
                                  [alert dismissViewControllerAnimated:YES completion:nil];
                                  [self.delegate gotoCameraSettings];
                                 
                              }];
    UIAlertAction* cancel = [UIAlertAction
                              actionWithTitle:@"NO"
                              style:UIAlertActionStyleDefault
                              handler:^(UIAlertAction * action)
                              {
                                  [alert dismissViewControllerAnimated:YES completion:nil];
                                  
                              }];
    [alert addAction:cancel];
    [alert addAction:confrim];
    
    [self presentViewController:alert animated:YES completion:nil];

}
/// Tells the delegate an ad request succeeded.
- (void)interstitialDidReceiveAd:(GADInterstitial *)ad {
    NSLog(@"interstitialDidReceiveAd");
 
}

/// Tells the delegate an ad request failed.
- (void)interstitial:(GADInterstitial *)ad
didFailToReceiveAdWithError:(GADRequestError *)error {
    NSLog(@"interstitial:didFailToReceiveAdWithError: %@", [error localizedDescription]);
}

/// Tells the delegate that an interstitial will be presented.
- (void)interstitialWillPresentScreen:(GADInterstitial *)ad {
    NSLog(@"interstitialWillPresentScreen");
}

/// Tells the delegate the interstitial is to be animated off the screen.
- (void)interstitialWillDismissScreen:(GADInterstitial *)ad {
  [self loadGoogleAdsFull];
   ads_dismiss=YES;
    NSLog(@"interstitialWillDismissScreen");
}

/// Tells the delegate the interstitial had been animated off the screen.
- (void)interstitialDidDismissScreen:(GADInterstitial *)ad {
    [self.delegate dismissAdsViewcontroller];
    if(isImagePicker==YES){
    __weak UIViewController *weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self videoFilePicker:weakSelf];
    });
    }
    NSLog(@"interstitialDidDismissScreen");
}

/// Tells the delegate that a user click will open another app
/// (such as the App Store), backgrounding the current app.
- (void)interstitialWillLeaveApplication:(GADInterstitial *)ad {
    NSLog(@"interstitialWillLeaveApplication");
}
- (void)doSomeWorkWithProgress{
    waitCancel = NO;
    // This just increases the progress indicator in a loop.
    float progress = 0.0f;
    while (1) {
        if ( self.interstitial.isReady ) {
            
            break;
        }
        progress += 0.01f;
        dispatch_async(dispatch_get_main_queue(), ^{
            // Instead we could have also passed a reference to the HUD
            // to the HUD to myProgressTask as a method parameter.
            [MBProgressHUD HUDForView:self.navigationController.view].progress = progress;
        });
        usleep(50000);
    }
}
- (void)doSomeVideoSvaeProgress{
    waitCancel = NO;
    // This just increases the progress indicator in a loop.
    float progress = 0.0f;
    while (1) {
        if ( waitCancel ) {
            
            break;
        }
        progress += 0.01f;
        dispatch_async(dispatch_get_main_queue(), ^{
            // Instead we could have also passed a reference to the HUD
            // to the HUD to myProgressTask as a method parameter.
            [MBProgressHUD HUDForView:self.navigationController.view].progress = progress;
        });
        usleep(50000);
    }
}

-(void)waitProgresss{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    // Set some text to show the initial status.
    hud.label.text =@"Preparing...";
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
-(void)waitSaveVideoProgresss{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    // Set some text to show the initial status.
    hud.label.text =@"";
    // Will look best, if we set a minimum size.
    hud.minSize = CGSizeMake(80.f, 80.f);
    
    dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), ^{
        // Do something useful in the background and update the HUD periodically.
        [self doSomeVideoSvaeProgress];
        dispatch_async(dispatch_get_main_queue(), ^{
            [hud hideAnimated:YES];
        });
    });
}

@end
