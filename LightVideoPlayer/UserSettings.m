//
//  UserSettings.m
//  LightVideoPlayer
//
//  Created by My Star on 7/28/17.
//  Copyright © 2017 My Star. All rights reserved.
//

#import "UserSettings.h"
static UserSettings *_sharedInstance;
@implementation UserSettings
@synthesize inapppurchace_level1,videoSize,scale,microPhone,inapppurchace_level2,inapppurchace_level3,inapppurchace_level4;
+ (UserSettings *)sharedInstance
{
    
    if ( !_sharedInstance )
    {
        _sharedInstance = [UserSettings new];
    }
    return _sharedInstance;
}
-(int)GetRecordNumber{
  return  [[[NSUserDefaults standardUserDefaults] stringForKey:@"RECORD_NUMBER"] intValue];
}
-(void)StopRecordNumber{
     [[NSUserDefaults standardUserDefaults] setObject:@"-1" forKey:@"RECORD_NUMBER"];
}
-(void)CountRecordNumber{
  int count=[[[NSUserDefaults standardUserDefaults] stringForKey:@"RECORD_NUMBER"] intValue]+1;
  [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%i",count] forKey:@"RECORD_NUMBER"];
}
@end
