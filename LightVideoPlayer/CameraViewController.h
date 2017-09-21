//
//  CameraViewController.h
//  LightVideoPlayer
//
//  Created by My Star on 7/27/17.
//  Copyright © 2017 My Star. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ASScreenRecorder.h"
#import "GoogleMobileAds/GoogleMobileAds.h"

@protocol CameraViewControllerDelegate <NSObject>

// delegate method for processing image frames
-(void)gotoCameraSettings;
-(void)Stoped;
-(void)dismissAdsViewcontroller;

@end

@interface CameraViewController : UIViewController<GADInterstitialDelegate>{
    
}
-(void)RecordAndStop:(BOOL)flag;
-(void)convertCamera;
-(void)previewAdmobopenSettings:(UIViewController*)settingsView;
@property (nonatomic, weak) id<CameraViewControllerDelegate> delegate;
@property (weak, nonatomic) IBOutlet UILabel *time_label;
@property (weak, nonatomic) IBOutlet UIView *cameraView;
@property (weak, nonatomic) IBOutlet UIView *flashView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cameraView_width;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cameraView_height;
@property (weak, nonatomic) IBOutlet UIView *cropView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cropView_width;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cropView_height;
@property(nonatomic, strong) GADInterstitial *interstitial;
@property  float timeStamp;
@property    BOOL isRecorder;
@property AVCaptureDevicePosition cameraPosition;
@property BOOL appStart;
@property BOOL fullvideo;
@property BOOL isImagePicker;
@property BOOL isCapturing;
-(void)videoGalleryOpen;
@end
