//
//  CustomIAPProcessor.h
//  CustomIAP
//
//  Created by LoveStar_PC on 3/9/15.
//  Copyright (c) 2015 IT. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>

UIKIT_EXTERN NSString *const IAPHelperProductPurchasedNotification;

@interface CustomIAPProcessor : NSObject<SKProductsRequestDelegate, SKPaymentTransactionObserver>
{
    SKProductsRequest *_productsRequest;

}
+ (CustomIAPProcessor *)sharedInstance;
- (void) buyWithProductIdentifiers:(NSString *)productIdentifier;
- (void)restoreCompletedTransactions;

@end
