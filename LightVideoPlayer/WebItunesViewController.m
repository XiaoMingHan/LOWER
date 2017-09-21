//
//  WebItunesViewController.m
//  LOWER
//
//  Created by My Star on 8/9/17.
//  Copyright © 2017 My Star. All rights reserved.
//

#import "WebItunesViewController.h"

@interface WebItunesViewController ()
{
    NSString* m_fileURL;
}
@end

@implementation WebItunesViewController
-(void)pathURL:(NSString*)fileURL{
    m_fileURL=fileURL;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    m_fileURL=@"http://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?id= 1265794764&pageNumber=0&sortOrdering=2&type=Purple+Software&mt=8";

        // Do any additional setup after loading the view.
}
-(void)viewDidAppear:(BOOL)animated{
//    NSURL *url = [NSURL URLWithString:m_fileURL];
//    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url];
//    [_webView loadRequest:urlRequest];

}
- (IBAction)connection:(id)sender {
    NSString *iTunesLink = @"http://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?id=1265794764&pageNumber=0&sortOrdering=2&type=Purple+Software&mt=8";
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:iTunesLink]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
