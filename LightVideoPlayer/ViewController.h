//
//  ViewController.h
//  LightVideoPlayer
//
//  Created by My Star on 7/27/17.
//  Copyright © 2017 My Star. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIView *crop_view;
@property (weak, nonatomic) IBOutlet UIView *camera_view;
@property (weak, nonatomic) IBOutlet UIView *overlay_view;
@property (weak, nonatomic) IBOutlet UIButton *settings_btn;
@property (weak, nonatomic) IBOutlet UILabel *time_label;
@property (weak, nonatomic) IBOutlet UIButton *camera_btn;
@property (weak, nonatomic) IBOutlet UIButton *convertVideo_btn;
@property (weak, nonatomic) IBOutlet UIButton *light_btn;
@property (weak, nonatomic) IBOutlet UIButton *switchcamera_btn;
@property (weak, nonatomic) IBOutlet UIButton *convert_btn;
@property (weak, nonatomic) IBOutlet UIButton *capture_btn;
@property (weak, nonatomic) IBOutlet UIImageView *timelabel_image;
@property (weak, nonatomic) IBOutlet UILabel *camera_size_lbl;


@end

