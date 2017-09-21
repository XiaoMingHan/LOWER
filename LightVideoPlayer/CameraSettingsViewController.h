//
//  CameraSettingsViewController.h
//  LightVideoPlayer
//
//  Created by My Star on 7/27/17.
//  Copyright © 2017 My Star. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CameraSettingsViewController : UIViewController
@property (weak, nonatomic) IBOutlet UISwitch *microPhone_ctrl;

@property (weak, nonatomic) IBOutlet UILabel *recordingQuality;

@property (weak, nonatomic) IBOutlet UILabel *purchase_label1;
@property (weak, nonatomic) IBOutlet UILabel *purchase_label2;
@property (weak, nonatomic) IBOutlet UILabel *purchase_label3;
@property (weak, nonatomic) IBOutlet UILabel *purchase_label4;
- (void) gotoViewItunes;
@end
