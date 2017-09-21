//
//  UserSettings.h
//  LightVideoPlayer
//
//  Created by My Star on 7/28/17.
//  Copyright © 2017 My Star. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
typedef enum {
   VIDEOSIZE_720P,
   VIDEOSIZE_480P,
   VIDEOSIZE_360P,
   VIDEOSIZE_240P,
   VIDEOSIZE_120P,
}  STANDARD_VIDEOSIZE;
#define Settings  UserSettings.sharedInstance

@interface UserSettings : NSObject{

}
-(void)StopRecordNumber;
- (int)GetRecordNumber;
- (void)CountRecordNumber;
+ (UserSettings *)sharedInstance;
@property BOOL microPhone;
@property CGSize videoSize;
@property float scale;
@property BOOL inapppurchace_level1;
@property BOOL inapppurchace_level2;
@property BOOL inapppurchace_level3;
@property BOOL inapppurchace_level4;

@end
