//
//  ViewController.m
//  LightVideoPlayer
//
//  Created by My Star on 7/27/17.
//  Copyright © 2017 My Star. All rights reserved.
//
#import <AVFoundation/AVFoundation.h>
#import "ViewController.h"
#import "UserSettings.h"
#import "CameraViewController.h"
#import "CameraSettingsViewController.h"
@interface ViewController ()<CameraViewControllerDelegate>{
    CameraViewController *cameraVC;
    CameraSettingsViewController *settingVC;
    float rotationInRadians;
    CGSize overlaySize;
    float toolBarHeight;
    BOOL start_rotate;
    NSTimer* labelTimer;
    UIDeviceOrientation lastOrientation;
    __weak IBOutlet UIView *ToolBarview;
}
@end

@implementation ViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    start_rotate=NO;
      [_light_btn setSelected:YES];
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle: [NSBundle mainBundle]];
    
    cameraVC = (CameraViewController*)[storyboard instantiateViewControllerWithIdentifier:@"CameraViewController"];
    cameraVC.delegate=self;
    settingVC= (CameraSettingsViewController*)[storyboard instantiateViewControllerWithIdentifier:@"CameraSettingsViewController"];
    
    cameraVC.view.frame = self.crop_view.bounds;
    [self.crop_view addSubview:cameraVC.view];
    [self addChildViewController:cameraVC];
    [cameraVC didMoveToParentViewController:self];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(OrientationDidChange:) name:UIDeviceOrientationDidChangeNotification object:nil];
    // Do any additional setup after loading the view, typically from a nib.
   
    toolBarHeight=ToolBarview.frame.size.height;

    
    
    if([[[NSUserDefaults standardUserDefaults] stringForKey:@"MICRO_PHONE_USAGE"] isEqualToString:@"YES"]){
        Settings.microPhone=YES;
    }else{
        Settings.microPhone=NO;
    }
    if([[[NSUserDefaults standardUserDefaults] stringForKey:@"Remove_ads"] isEqualToString:@"YES"]){
        Settings.inapppurchace_level1=YES;
    }else{
        Settings.inapppurchace_level1=NO;
    }
    if([[[NSUserDefaults standardUserDefaults] stringForKey:@"Unlimited_recording"] isEqualToString:@"YES"]){
        Settings.inapppurchace_level2=YES;
    }else{
        Settings.inapppurchace_level2=NO;
    }
    if([[[NSUserDefaults standardUserDefaults] stringForKey:@"Unlock_All_Features"] isEqualToString:@"YES"]){
        Settings.inapppurchace_level4=YES;
        Settings.inapppurchace_level3=YES;
        Settings.inapppurchace_level2=YES;
        Settings.inapppurchace_level1=YES;
    }else{
        Settings.inapppurchace_level3=NO;
    }
    if([[[NSUserDefaults standardUserDefaults] stringForKey:@"unlock_custom_size"] isEqualToString:@"YES"]){
        Settings.inapppurchace_level3=YES;
    }else{
        Settings.inapppurchace_level3=NO;
    }
    
    float width=[[[NSUserDefaults standardUserDefaults] stringForKey:@"VIDEO_WIDTH"] floatValue];
    float height=[[[NSUserDefaults standardUserDefaults] stringForKey:@"VIDEO_HEIGHT"] floatValue];
    if(width==0 || height==0){
        width=720;
        height=1280;
    }
  
    Settings.videoSize=CGSizeMake(width, height);
    Settings.scale=[[[NSUserDefaults standardUserDefaults] stringForKey:@"VIDEO_SCALE"] floatValue];
    
    overlaySize.width=self.view.frame.size.width;
    overlaySize.height=self.view.frame.size.height;
}
-(BOOL)prefersStatusBarHidden{
    return YES;
}
- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    // Only portrait orientation
     // [self changeOrientLayout];
    return UIInterfaceOrientationMaskPortrait;
}

-(void)viewDidAppear:(BOOL)animated{

    //[self makeOrientLayout:UIDeviceOrientationPortrait];
    [self changeOrientLayout];
    [super viewDidAppear:animated];
       cameraVC.time_label=self.time_label;
    if(Settings.videoSize.width==0)
    Settings.videoSize=self.view.frame.size;
    
    
    _camera_size_lbl.text=[NSString stringWithFormat:@"%dx%d",(int)Settings.videoSize.width, (int)Settings.videoSize.height];
    [_light_btn setHidden:![self IsFlash:cameraVC.cameraPosition]];
    
    
}

- (void)viewWillAppear:(BOOL)animated{
//    UIDeviceOrientation Orientation=[[UIDevice currentDevice]orientation];
//    if(Orientation==UIDeviceOrientationLandscapeLeft || Orientation==UIDeviceOrientationLandscapeRight)
//    {
//        [self changeOrientLayout];
//        [self changeOrientLayout];
//    }
}
-(void)viewDidDisappear:(BOOL)animated{
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)OrientationDidChange:(NSNotification*)notification
{
  
   [self changeOrientLayout];
    
}
-(void)changeOrientLayout{
    
    UIDeviceOrientation Orientation=[[UIDevice currentDevice]orientation];
 
    [self makeOrientLayout:Orientation];
    
    
    
}
-(void)makeOrientLayout:(UIDeviceOrientation)Orientation{
   // if(lastOrientation==Orientation)return;
    if(Orientation==UIDeviceOrientationLandscapeLeft || Orientation==UIDeviceOrientationLandscapeRight)
    {
        rotationInRadians = M_PI/2;
        
        [UIView animateWithDuration:0.2 animations:^{
            
            _overlay_view.transform = CGAffineTransformMakeRotation(rotationInRadians);
            _convertVideo_btn.transform=CGAffineTransformMakeRotation(rotationInRadians);
            _switchcamera_btn.transform=CGAffineTransformMakeRotation(rotationInRadians);
            _convert_btn.transform=CGAffineTransformMakeRotation(rotationInRadians);
            _light_btn.transform=CGAffineTransformMakeRotation(rotationInRadians);
            _overlay_view.center=CGPointMake(overlaySize.width/2, overlaySize.height/2);
            [_overlay_view setFrame:CGRectMake(0, 0, overlaySize.width, overlaySize.height)];
            
            
        } completion:^(BOOL finished) {
            [_overlay_view setFrame:CGRectMake(0, 0, overlaySize.width, overlaySize.height)];
            [self autoResizeOverlayView:YES];
        }];
        
    }
    else if(Orientation==UIDeviceOrientationPortrait)
    {
        rotationInRadians = 0;
        //NSLog(@"%f",_overlay_view.frame.size.width);
        [UIView animateWithDuration:0.2 animations:^{
            //
            _overlay_view.transform = CGAffineTransformMakeRotation(rotationInRadians);
            _convertVideo_btn.transform=CGAffineTransformMakeRotation(rotationInRadians);
            _switchcamera_btn.transform=CGAffineTransformMakeRotation(rotationInRadians);
             _convert_btn.transform=CGAffineTransformMakeRotation(rotationInRadians);
            _light_btn.transform=CGAffineTransformMakeRotation(rotationInRadians);
            [_overlay_view setFrame:CGRectMake(0, 0, overlaySize.width, overlaySize.height)];
            
        } completion:^(BOOL finished) {
             [_overlay_view setFrame:CGRectMake(0, 0, overlaySize.width, overlaySize.height)];
            [self autoResizeOverlayView:NO];
        }];
        
    }
    [_overlay_view setNeedsLayout];
    [_overlay_view layoutIfNeeded];

    lastOrientation=Orientation;
 
}
-(void)autoResizeOverlayView:(BOOL)rotate{
    
    
   // [self changeRotateLayout:_overlay_view withSize:CGSizeMake(rotate==YES?self.view.frame.size.height:self.view.frame.size.width, rotate==YES?self.view.frame.size.width:self.view.frame.size.height) withPosition:CGPointMake(0, 0)];
    CGPoint ps=CGPointMake(10, 20);
    if(rotate==NO)
        ps=CGPointMake(10, 15);
    [self changeRotateLayout:ToolBarview withSize:CGSizeMake(rotate==YES?overlaySize.height:overlaySize.width, 30) withPosition:ps];
    
        
    [ToolBarview setNeedsLayout];
    [ToolBarview layoutIfNeeded];
 
    
 }
-(void)changeRotateLayout:(UIView*)view withSize:(CGSize)size withPosition:(CGPoint)point{
    NSLayoutConstraint *heightConstraint;
    NSLayoutConstraint *widthConstraint;
    NSLayoutConstraint *xConstraint;
    NSLayoutConstraint *yConstraint;
    for (NSLayoutConstraint *constraint in view.constraints) {
        if (constraint.firstAttribute == NSLayoutAttributeHeight) {
            heightConstraint = constraint;
            heightConstraint.constant = size.height;
            continue;
        }
        else if (constraint.firstAttribute == NSLayoutAttributeWidth) {
            widthConstraint = constraint;
            widthConstraint.constant = size.width;
            
            continue;
        }else if (constraint.firstAttribute == NSLayoutAttributeLeading) {
            xConstraint = constraint;
            xConstraint.constant = point.x;
            
            continue;
        }else if (constraint.firstAttribute == NSLayoutAttributeTop) {
            yConstraint = constraint;
            yConstraint.constant = point.y;
            
            continue;
        }
        
    }

}
- (IBAction)StopAndRecording:(id)sender {
    if(cameraVC.isRecorder==YES){
    [self startAndStopRecord];
    }else{
        [cameraVC.flashView setAlpha:1.0];
        [NSTimer scheduledTimerWithTimeInterval:0.2
                                         target:self
                                       selector:@selector(flashEffect:)
                                       userInfo:nil
                                        repeats:NO];
        

        if(_light_btn.isSelected==NO){
            [self flashTurnoffon:YES];
            [NSTimer scheduledTimerWithTimeInterval:0.5
                                             target:self
                                           selector:@selector(delayCamera:)
                                           userInfo:nil
                                            repeats:NO];
          
            
        }else
       
        [cameraVC RecordAndStop:YES];
    }
}
-(void)flashEffect:(NSTimer *)timer{
    [cameraVC.flashView setAlpha:0.0];
}
-(void)delayCamera:(NSTimer *)timer{
    [cameraVC RecordAndStop:YES];
    [self flashTurnoffon:NO];
    
}
-(void)startAndStopRecord{
    [self.camera_btn setSelected:!self.camera_btn.isSelected];
    [cameraVC RecordAndStop:self.camera_btn.isSelected];
    
    if(self.camera_btn.isSelected){
     labelTimer=   [NSTimer scheduledTimerWithTimeInterval:0.5
                                         target:self
                                       selector:@selector(showTimeCount:)
                                       userInfo:nil
                                        repeats:YES];
    }
    else{
        [labelTimer invalidate];
        [self recording_time_view:0];
        labelTimer = nil;
    }

}
-(void)Stoped{
    [self.camera_btn setSelected:NO];
    [cameraVC RecordAndStop:NO];
    [labelTimer invalidate];
    [self recording_time_view:0];
    labelTimer = nil;
    
}
-(void)showTimeCount:(NSTimer *)timer{
    static CFTimeInterval lastTime = 0;
    
    
    
    CFTimeInterval currTime = CACurrentMediaTime();
    
    if ( currTime >= lastTime + .1 )
    {
        
     //   float ks=[recorder getRecordingTimeStamp];
        
        [self recording_time_view:cameraVC.timeStamp];
        
        
        lastTime = currTime;
    }

}
-(void)recording_time_view:(float)time{
    

        
        int th=(int)(time*60)/3600/24;
        int tm=(int)(time*60)/3600;
        
        int ts=(int)(((int)(time*60))/60)%60;
        
        
        
        // if(ts%2==1)  [_redImage setHidden:YES];else  [_redImage setHidden:NO];
        NSString *TH=th>9?[NSString stringWithFormat:@"%d",th]:[NSString stringWithFormat:@"0%d",th];
    
        NSString *TM=tm>9?[NSString stringWithFormat:@"%d",tm]:[NSString stringWithFormat:@"0%d",tm];
        
        NSString *TS=ts>9?[NSString stringWithFormat:@"%d",ts]:[NSString stringWithFormat:@"0%d",ts];
        
       self.time_label.text = [NSString stringWithFormat:@"%@:%@:%@",TH, TM,TS];
  

    
}
- (IBAction)LightEnable:(id)sender {

     [_light_btn setSelected:!_light_btn.isSelected];
    
    if(cameraVC.isRecorder==YES){
        [self flashTurnoffon:!_light_btn.isSelected];
    }
}
-(void)gotoCameraSettings{
    
     //
   // [cameraVC previewAdmobopenSettings:settingVC];
    
    if( Settings.inapppurchace_level1==NO)
    {
        if (cameraVC.interstitial.isReady ){
            cameraVC.isImagePicker=NO;
            [cameraVC.interstitial presentFromRootViewController:self];
        } else {
           [self presentViewController:settingVC animated:YES completion:nil];
        }
        
    }else{
        [self presentViewController:settingVC animated:YES completion:nil];
    }

}
-(void)dismissAdsViewcontroller{
    if(cameraVC.isImagePicker==NO){
        __weak UIViewController *weakSelf = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf presentViewController:settingVC animated:YES completion:nil];
        });
    }

}
- (IBAction)CameraSettings:(id)sender {
    
    if(cameraVC.isRecorder==YES && cameraVC.isCapturing){
        [self startAndStopRecord];
    }
    [self gotoCameraSettings];
  
  
}
- (IBAction)convertCamera:(id)sender {
    
    [cameraVC convertCamera];
    [_light_btn setHidden:![self IsFlash:cameraVC.cameraPosition]];
}
- (IBAction)videoGalleryOpen:(id)sender {
    [cameraVC videoGalleryOpen];
}
- (IBAction)convert_capture:(id)sender {
    cameraVC.isRecorder=!cameraVC.isRecorder;
    [_convert_btn setSelected:!_convert_btn.isSelected];
    [self.time_label setHidden:!cameraVC.isRecorder];
    [_timelabel_image setHidden:!cameraVC.isRecorder];
    
    
    if(cameraVC.isRecorder==NO ){
         [self flashTurnoffon:NO];
        [_capture_btn setImage:[UIImage imageNamed:@"btn_shutter.png"] forState:UIControlStateNormal];
        [_capture_btn setImage:[UIImage imageNamed:@""] forState:UIControlStateSelected];
        [_capture_btn setImage:[UIImage imageNamed:@"btn_shutter_tapped.png"] forState:UIControlStateHighlighted];
    }else{
        [_light_btn setSelected:YES];
        [self flashTurnoffon:NO];
        [_capture_btn setImage:[UIImage imageNamed:@"btn_shutter_video.png"] forState:UIControlStateNormal];
        [_capture_btn setImage:[UIImage imageNamed:@"btn_shutter_video_tapped.png"] forState:UIControlStateSelected];
        [_capture_btn setImage:[UIImage imageNamed:@""] forState:UIControlStateHighlighted];
    }
    [self changeOrientLayout];
}
-(void)flashTurnoffon:(BOOL) flg{
    
    
    if( cameraVC.cameraPosition==AVCaptureDevicePositionBack){
        
        AVCaptureDevice *flashLight = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        
        if ([flashLight isTorchAvailable] && [flashLight isTorchModeSupported:AVCaptureTorchModeOn])
        {
            
            BOOL success = [flashLight lockForConfiguration:nil];
            
            if (success)
            {
                if ([flashLight isTorchActive] && flg==NO)
                {
                    
                    [flashLight setTorchMode:AVCaptureTorchModeOff];
                }
                else if( flg==YES)
                {
                    
                    [flashLight setTorchMode:AVCaptureTorchModeOn];
                }
                [flashLight unlockForConfiguration];
            }
        }
    }
}
- (BOOL )IsFlash:(AVCaptureDevicePosition)position
{
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    
    AVCaptureDevice *device = nil;
    
    for ( AVCaptureDevice *dev in devices )
    {
        if ( [dev position] == position )
        {
            device = dev;
            break;
        }
    }
    return device.isFlashAvailable;
}
@end
