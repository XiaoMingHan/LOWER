//
//  CameraSettingsViewController.m
//  LightVideoPlayer
//
//  Created by My Star on 7/27/17.
//  Copyright © 2017 My Star. All rights reserved.
//

#import "CameraSettingsViewController.h"
#import "UserSettings.h"
#import "CustomIAPProcessor.h"
#import "ViewController.h"
#import <StoreKit/StoreKit.h>
#import <MessageUI/MFMailComposeViewController.h>
#import <AddressBook/AddressBook.h>
#import "MBProgressHUD.h"
@interface CameraSettingsViewController()<SKPaymentTransactionObserver, SKProductsRequestDelegate,MFMailComposeViewControllerDelegate>{
    CGSize viewSize;
    BOOL waitCancel;
}
@property (strong, nonatomic) SKProduct *product;
@property (strong, nonatomic) NSString *productID;
@end

@implementation CameraSettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];   

    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(OrientationDidChange:) name:UIDeviceOrientationDidChangeNotification object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(productPurchased:) name:IAPHelperProductPurchasedNotification object:nil];
    // Do any additional setup after loading the view.
    
}
-(BOOL)prefersStatusBarHidden{
    return YES;
}
-(void)viewDidAppear:(BOOL)animated{
    
    if(Settings.videoSize.width==720 && Settings.videoSize.height==1280){
        _recordingQuality.text=@"Recording Quality (720p)";
    }else if(Settings.videoSize.width==480 && Settings.videoSize.height==640){
        _recordingQuality.text=@"Recording Quality (480p)";
    }else if(Settings.videoSize.width==360 && Settings.videoSize.height==480){
        _recordingQuality.text=@"Recording Quality (360p)";
    }else if(Settings.videoSize.width==240 && Settings.videoSize.height==360){
        _recordingQuality.text=@"Recording Quality (240p)";
    }else if(Settings.videoSize.width==120 && Settings.videoSize.height==240){
        _recordingQuality.text=@"Recording Quality (120p)";
    }else{
        _recordingQuality.text=@"Recording Quality (custom)";
    }
    
    
     
      if(Settings.microPhone==YES){
        [_microPhone_ctrl setOn:YES];
    }else{
        [_microPhone_ctrl setOn:NO];
    }
    if(Settings.inapppurchace_level1)[_purchase_label1 setHidden:YES]; else [_purchase_label1 setHidden:NO];
    if(Settings.inapppurchace_level2)[_purchase_label2 setHidden:YES]; else [_purchase_label2 setHidden:NO];
    if(Settings.inapppurchace_level3)[_purchase_label3 setHidden:YES]; else [_purchase_label3 setHidden:NO];
    if(Settings.inapppurchace_level1==YES && Settings.inapppurchace_level2==YES && Settings.inapppurchace_level3==YES){
        Settings.inapppurchace_level4=YES;
        [_purchase_label1 setHidden:YES];
        [_purchase_label2 setHidden:YES];
        [_purchase_label3 setHidden:YES];
        [_purchase_label4 setHidden:YES];
    }

    if(Settings.inapppurchace_level4){
        Settings.inapppurchace_level4=YES;
        Settings.inapppurchace_level3=YES;
        Settings.inapppurchace_level2=YES;
        Settings.inapppurchace_level1=YES;
        [_purchase_label1 setHidden:YES];
        [_purchase_label2 setHidden:YES];
        [_purchase_label3 setHidden:YES];
        [_purchase_label4 setHidden:YES];
    } else [_purchase_label4 setHidden:NO];
    
      /// self.diskfreeSize.text=[NSString stringWithFormat:@"%d MByte", (int)(([self getFreeDiskspace]/1024ll)/1024ll)];
    viewSize=CGSizeMake(self.view.frame.size.width, self.view.frame.size.height);
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)OrientationDidChange:(NSNotification*)notification
{
    
   // [self changeOrientLayout];
    
}
-(void)changeOrientLayout{
    
    UIDeviceOrientation Orientation=[[UIDevice currentDevice]orientation];
    
    
    if(Orientation==UIDeviceOrientationLandscapeLeft || Orientation==UIDeviceOrientationLandscapeRight)
    {
   
        float rotationInRadians = M_PI/2;
        if(Orientation==UIDeviceOrientationLandscapeRight)rotationInRadians = -M_PI/2;
        [UIView animateWithDuration:0.2 animations:^{
            
            self.view.transform = CGAffineTransformMakeRotation(rotationInRadians);
            
           // [_overlay_view setFrame:CGRectMake(0, 0, overlaySize.width, overlaySize.height)];
            
            
        } completion:^(BOOL finished) {
            [self.view setFrame:CGRectMake(0, 0,viewSize.width,viewSize.height)];
           // [self autoResizeOverlayView:YES];
        }];
        
    }
    else if(Orientation==UIDeviceOrientationPortrait|| Orientation==UIDeviceOrientationPortraitUpsideDown)
    {
       float rotationInRadians = 0;
        if(Orientation==UIDeviceOrientationPortraitUpsideDown)rotationInRadians = M_PI;
        //NSLog(@"%f",_overlay_view.frame.size.width);
        [UIView animateWithDuration:0.2 animations:^{
            //
             self.view.transform= CGAffineTransformMakeRotation(rotationInRadians);
          //  [_overlay_view setFrame:CGRectMake(0, 0, overlaySize.width, overlaySize.height)];
            
        } completion:^(BOOL finished) {
          [self.view setFrame:CGRectMake(0, 0, viewSize.width, viewSize.height)];
        }];
        
    }
    else{
         [self.view setFrame:CGRectMake(0, 0,self.view.frame.size.width, self.view.frame.size.height )];
    }
    NSLog(@"%d",(int)Orientation);
    [self.view setNeedsLayout];
    [self.view layoutIfNeeded];
}

-(uint64_t)getFreeDiskspace {
    uint64_t totalSpace = 0;
    uint64_t totalFreeSpace = 0;
    NSError *error = nil;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSDictionary *dictionary = [[NSFileManager defaultManager] attributesOfFileSystemForPath:[paths lastObject] error: &error];
    
    if (dictionary) {
        NSNumber *fileSystemSizeInBytes = [dictionary objectForKey: NSFileSystemSize];
        NSNumber *freeFileSystemSizeInBytes = [dictionary objectForKey:NSFileSystemFreeSize];
        totalSpace = [fileSystemSizeInBytes unsignedLongLongValue];
        totalFreeSpace = [freeFileSystemSizeInBytes unsignedLongLongValue];
        NSLog(@"Memory Capacity of %llu MiB with %llu MiB Free memory available.", ((totalSpace/1024ll)/1024ll), ((totalFreeSpace/1024ll)/1024ll));
    } else {
        NSLog(@"Error Obtaining System Memory Info: Domain = %@, Code = %ld", [error domain], (long)[error code]);
    }
    
    return totalFreeSpace;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (IBAction)exitCameraViewController:(id)sender {

        [self dismissViewControllerAnimated:YES completion:nil];
    
    
        Settings.microPhone=[_microPhone_ctrl isOn];
        if([_microPhone_ctrl isOn])[[NSUserDefaults standardUserDefaults] setObject:@"YES" forKey:@"MICRO_PHONE_USAGE"];
        else [[NSUserDefaults standardUserDefaults] setObject:@"NO" forKey:@"MICRO_PHONE_USAGE"];

    
        [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%f",Settings.videoSize.width] forKey:@"VIDEO_WIDTH"];
        [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%f",Settings.videoSize.height] forKey:@"VIDEO_HEIGHT"];
        [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%f",Settings.scale] forKey:@"VIDEO_SCALE"];
    
}
- (IBAction)changeVideoSize:(id)sender {
    NSString *emoji1 = @"\\ud83d\\udd12";//\uD83D\uDD13
    NSData *emojiData1 = [emoji1 dataUsingEncoding:NSUTF8StringEncoding];
    NSString *lockemoji = [[NSString alloc] initWithData:emojiData1 encoding:NSNonLossyASCIIStringEncoding];
    
   // NSString *emoji2 = @"\\ud83d\\udd13";//\uD83D\uDD13
    //NSData *emojiData2 = [emoji2 dataUsingEncoding:NSUTF8StringEncoding];
    //NSString *unlockemoji = [[NSString alloc] initWithData:emojiData2 encoding:NSNonLossyASCIIStringEncoding];
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
                             [self cameraRecordingSizeAlert:0];
                         }];
    UIAlertAction* action2 = [UIAlertAction
                             actionWithTitle:@"480p"
                             style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction * action)
                             {
                                 [alert dismissViewControllerAnimated:YES completion:nil];
                                 [self cameraRecordingSizeAlert:1];
                             }];
    UIAlertAction* action3 = [UIAlertAction
                              actionWithTitle:@"360p"
                              style:UIAlertActionStyleDefault
                              handler:^(UIAlertAction * action)
                              {
                                  [alert dismissViewControllerAnimated:YES completion:nil];
                                  [self cameraRecordingSizeAlert:2];
                              }];
    UIAlertAction* action4 = [UIAlertAction
                              actionWithTitle:@"240p"
                              style:UIAlertActionStyleDefault
                              handler:^(UIAlertAction * action)
                              {
                                  [alert dismissViewControllerAnimated:YES completion:nil];
                                  [self cameraRecordingSizeAlert:3];
                              }];
    
    UIAlertAction* action5 = [UIAlertAction
                              actionWithTitle:@"120p"
                              style:UIAlertActionStyleDefault
                              handler:^(UIAlertAction * action)
                              {
                                  [alert dismissViewControllerAnimated:YES completion:nil];
                                  [self cameraRecordingSizeAlert:4];
                              }];
    UIAlertAction* action6 = [UIAlertAction
                              actionWithTitle:[NSString stringWithFormat:@"%@ %@",lockEnable,@" Custome size"]
                              style:UIAlertActionStyleDefault
                              handler:^(UIAlertAction * action)
                              {
                                  
                                  
                                  [alert dismissViewControllerAnimated:YES completion:nil];
                                  
                                  
                                  [self cameraRecordingSizeAlert:5];
                              }];
    UIAlertAction* action7 = [UIAlertAction
                              actionWithTitle:@"Cancel"
                              style:UIAlertActionStyleDefault
                              handler:^(UIAlertAction * action)
                              {
                                  [alert dismissViewControllerAnimated:YES completion:nil];
                                  
                              }];
    [alert addAction:action1];
    [alert addAction:action2];
    [alert addAction:action3];
    [alert addAction:action4];
    [alert addAction:action5];
    [alert addAction:action6];
    [alert addAction:action7];
    [self presentViewController:alert animated:YES completion:nil];
  

}
#pragma mark - user define functions

-(void)cameraRecordingSizeAlert:(int)index{
    switch (index) {
        case 0:
            _recordingQuality.text=@"Recording Quality (720p)";
            Settings.videoSize=CGSizeMake(720, 1280);
            
            break;
        case 1:
            _recordingQuality.text=@"Recording Quality (480p)";
            Settings.videoSize=CGSizeMake(480, 640);
            break;
        case 2:
            _recordingQuality.text=@"Recording Quality (360p)";
            Settings.videoSize=CGSizeMake(360, 480);
            break;
        case 3:
            _recordingQuality.text=@"Recording Quality (240p)";
            Settings.videoSize=CGSizeMake(240, 360);
           
            break;
        case 4:
            _recordingQuality.text=@"Recording Quality (120p)";
            Settings.videoSize=CGSizeMake(120, 240);
            break;
        case 5:
        {
            if(Settings.inapppurchace_level3==YES){
            _recordingQuality.text=@"Recording Quality (custom)";
            NSString * msg=[NSString stringWithFormat:@"current size= %dx%d",(int)Settings.videoSize.width,(int)Settings.videoSize.height];
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
                        
                        
                    }]];
                    [self presentViewController:alertController1 animated:YES completion:nil];

                }else{
                    Settings.videoSize=CGSizeMake(width,height);
                }
             
                
            }]];
            [alertController addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                
                
            }]];

            [self presentViewController:alertController animated:YES completion:nil];
                
            }else{
                UIAlertController * alertController = [UIAlertController alertControllerWithTitle: @"Custom Size"
                                                                                          message: @"Do you want to unlock custom size?"
                                                                                   preferredStyle:UIAlertControllerStyleAlert];
                [alertController addAction:[UIAlertAction actionWithTitle:@"No" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                    
                    
                }]];
                [alertController addAction:[UIAlertAction actionWithTitle:@"YES" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                    [self waitProgresss];
                     [[CustomIAPProcessor sharedInstance] buyWithProductIdentifiers:@"com.vweeter.lower.record3"];
                    
                }]];
                [self presentViewController:alertController animated:YES completion:nil];
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
}
#pragma mark -
#pragma mark SKProductsRequestDelegate

-(void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
{
    
    NSArray *products = response.products;
    
    if (products.count != 0)
    {
        _product = products[0];
     //   _buyButton.enabled = YES;
     //   _productTitle.text = _product.localizedTitle;
    //    _productDescription.text = _product.localizedDescription;
    } else {
       // _productTitle.text = @"Product not found";
    }
    
    products = response.invalidProductIdentifiers;
    
    for (SKProduct *product in products)
    {
     //   NSLog(@"Product not found: %@", product);
    }
}
#pragma mark -
#pragma mark SKPaymentTransactionObserver

-(void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions
{
    for (SKPaymentTransaction *transaction in transactions)
    {
        switch (transaction.transactionState) {
            case SKPaymentTransactionStatePurchased:
                [self unlockFeature];
                [[SKPaymentQueue defaultQueue]
                 finishTransaction:transaction];
                break;
                
            case SKPaymentTransactionStateFailed:
                NSLog(@"Transaction Failed");
                [[SKPaymentQueue defaultQueue]
                 finishTransaction:transaction];
                break;
                
            default:
                break;
        }
    }
}

#pragma mark IN APP PURCHASE
- (void)productPurchased:(NSNotification *)notification
{
    NSString *productIdentifier = notification.object;
    NSLog(@"%@", productIdentifier);
    if ([productIdentifier isEqualToString:@"com.vweeter.lower.noads"]) {
       
        [[NSUserDefaults standardUserDefaults] setObject:@"YES" forKey:@"Remove_ads"];
        Settings.inapppurchace_level1=YES;
     
        [_purchase_label1 setHidden:YES];

        
    }else if ([productIdentifier isEqualToString:@"com.vweeter.lower.record2"]) {
        
        [[NSUserDefaults standardUserDefaults] setObject:@"YES" forKey:@"Unlimited_recording"];
        Settings.inapppurchace_level2=YES;
        [_purchase_label2 setHidden:YES];
        
    }else if ([productIdentifier isEqualToString:@"com.vweeter.lower.record3"]) {
        
        [[NSUserDefaults standardUserDefaults] setObject:@"YES" forKey:@"unlock_custom_size"];
        Settings.inapppurchace_level3=YES;
        [_purchase_label3 setHidden:YES];
        
    }else if ([productIdentifier isEqualToString:@"com.vweeter.lower.record4"]) {
        
        [[NSUserDefaults standardUserDefaults] setObject:@"YES" forKey:@"Unlock_All_Features"];
        Settings.inapppurchace_level4=YES;
        Settings.inapppurchace_level3=YES;
        Settings.inapppurchace_level2=YES;
        Settings.inapppurchace_level1=YES;
        [_purchase_label1 setHidden:YES];
        [_purchase_label2 setHidden:YES];
        [_purchase_label3 setHidden:YES];
        [_purchase_label4 setHidden:YES];

        
    }
    else {
        UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Failed your purchase."
                                                          message:@"Please try again."
                                                         delegate:nil
                                                cancelButtonTitle:@"OK"
                                                otherButtonTitles:nil];
        [message show];
        //return;
    }
    if(Settings.inapppurchace_level1==YES && Settings.inapppurchace_level2==YES && Settings.inapppurchace_level3==YES){
        Settings.inapppurchace_level4=YES;
        [_purchase_label1 setHidden:YES];
        [_purchase_label2 setHidden:YES];
        [_purchase_label3 setHidden:YES];
        [_purchase_label4 setHidden:YES];
    }
     waitCancel = YES;
}
-(void)unlockFeature
{
//    _buyButton.enabled = NO;
//    [_buyButton setTitle:@"Purchased"
//                forState:UIControlStateDisabled];
//    [_homeViewController enableLevel2];
}

- (IBAction)purchase1_connect:(id)sender {
    if(Settings.inapppurchace_level1==NO){
        [self waitProgresss];
     [[CustomIAPProcessor sharedInstance] buyWithProductIdentifiers:@"com.vweeter.lower.noads"];
     
    }
}
- (IBAction)purchase2_connect:(id)sender {
    if(Settings.inapppurchace_level2==NO){
         [self waitProgresss];
       [[CustomIAPProcessor sharedInstance] buyWithProductIdentifiers:@"com.vweeter.lower.record2"];
   
    }
}
- (IBAction)purchase3_connect:(id)sender {
    if(Settings.inapppurchace_level3==NO){
         [self waitProgresss];
       [[CustomIAPProcessor sharedInstance] buyWithProductIdentifiers:@"com.vweeter.lower.record3"];
     }
}
- (IBAction)purchase4_connect:(id)sender {
    if(Settings.inapppurchace_level4==NO){
         [self waitProgresss];
       [[CustomIAPProcessor sharedInstance] buyWithProductIdentifiers:@"com.vweeter.lower.record4"];
    
    }
}
- (IBAction)restore_connect:(id)sender {

}
- (IBAction)moreAppFormUs:(id)sender {
    NSString *iTunesLink = @"https://itunes.apple.com/us/developer/vweeter-limited/id1238739056";
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:iTunesLink]];
}
- (IBAction)contactUs:(id)sender {
    [self displayComposerSheet];
}
- (IBAction)rateOurApp:(id)sender {
    
    NSString *iTunesLink = @"http://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?id=1265794764&pageNumber=0&sortOrdering=2&type=Purple+Software&mt=8";
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:iTunesLink]];
}

-(void)displayComposerSheet
{
    MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
    picker.mailComposeDelegate = self;
    [picker setSubject:@"LOWER 1.0.1 support"];
    
    // Set up recipients
     NSArray *toRecipients = [NSArray arrayWithObject:@"playreap@ymail.com"];
    
     [picker setToRecipients:toRecipients];
    
    // Fill out the email body text
    NSString *emailBody = @"Hi,";
    [picker setMessageBody:emailBody isHTML:NO];
    
    [self presentModalViewController:picker animated:YES];
    
    
}

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
    // Notifies users about errors associated with the interface
    switch (result)
    {
        case MFMailComposeResultCancelled:
            NSLog(@"Result: canceled");
            break;
        case MFMailComposeResultSaved:
            NSLog(@"Result: saved");
            break;
        case MFMailComposeResultSent:
            NSLog(@"Result: sent");
            break;
        case MFMailComposeResultFailed:
            NSLog(@"Result: failed");
            break;
        default:
            NSLog(@"Result: not sent");
            break;
    }
    [self dismissModalViewControllerAnimated:YES];
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
            [MBProgressHUD HUDForView:self.navigationController.view].progress = progress;
        });
        usleep(50000);
    }
}

-(void)waitProgresss{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
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
