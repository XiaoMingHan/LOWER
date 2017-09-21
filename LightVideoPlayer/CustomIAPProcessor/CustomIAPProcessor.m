//
//  CustomIAPProcessor.m
//  CustomIAP
//
//  Created by LoveStar_PC on 3/9/15.
//  Copyright (c) 2015 IT. All rights reserved.
//

#import "CustomIAPProcessor.h"

NSString *const IAPHelperProductPurchasedNotification = @"IAPHelperProductPurchasedNotification";

@implementation CustomIAPProcessor
+ (CustomIAPProcessor *)sharedInstance {
    static CustomIAPProcessor *sharedInstance;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (instancetype) init
{
    self = [super init];
    if (self) {
        [[SKPaymentQueue defaultQueue] addTransactionObserver:self];

    }
    
    return self;
}

- (void) buyWithProductIdentifiers:(NSString *)productIdentifier
{
    _productsRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:[NSSet setWithObjects: productIdentifier, nil]];
    _productsRequest.delegate = self;
    [_productsRequest start];

}
#pragma mark - SKProductsRequestDelegate

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
{
    NSLog(@"Loaded products...");
    _productsRequest = nil;
    
    NSArray *skProducts = response.products;
    for (SKProduct *skProduct in skProducts) {
        NSLog(@"Found product: %@ – Product: %@ – Price: %0.2f", skProduct.productIdentifier, skProduct.localizedTitle, skProduct.price.floatValue);
        SKPayment *payment = [SKPayment paymentWithProduct:skProduct];
        
        //    TODO: issue the SKPayment to the SKPaymentQueue: make the SKPaymentQueue class call the defaultQueue method and add a payment request to the queue (addPayment) for a given payment ("payment"). (hint: 1 LOC)
        [[SKPaymentQueue defaultQueue] addPayment:payment];

    }
    
    // method definition; (BOOL success, NSArray * products) ... success YES, and the array of products is skProducts
//    _completionHandler(YES, skProducts);
//    _completionHandler = nil;
}

- (void)request:(SKRequest *)request didFailWithError:(NSError *)error
{
//    UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Failed to load list of products."
//                                                      message:nil
//                                                     delegate:nil
//                                            cancelButtonTitle:@"OK"
//                                            otherButtonTitles:nil];
//    [message show];
    
    NSLog(@"Failed to load list of products.");
    
    _productsRequest = nil;
    
    // method definition; (BOOL success, NSArray * products) ... success NO, and the array of products is nil
//    _completionHandler(NO, nil);
//    _completionHandler = nil;
}

//- (BOOL)productPurchased:(NSString *)productIdentifier
//{
//    return [_purchasedProductIdentifiers containsObject:productIdentifier];
//}

//- (void)buyProduct:(SKProduct *)product
//{
//    NSLog(@"Buying %@ ... (buyProduct ind IAPHelper)", product.productIdentifier);
//    
//    //    TODO: create a SKPayment object ("payment") and call paymentWithProduct that returns a new payment for the specified product ("product)". (hint: 1 LOC)
//    SKPayment *payment = [SKPayment paymentWithProduct:product];
//    
//    //    TODO: issue the SKPayment to the SKPaymentQueue: make the SKPaymentQueue class call the defaultQueue method and add a payment request to the queue (addPayment) for a given payment ("payment"). (hint: 1 LOC)
//    [[SKPaymentQueue defaultQueue] addPayment:payment];
//}

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions
{
    for (SKPaymentTransaction *transaction in transactions) {
        switch (transaction.transactionState) {
            case SKPaymentTransactionStatePurchased:
                [self completeTransaction:transaction];
                break;
            case SKPaymentTransactionStateFailed:
                [self failedTransaction:transaction];
                break;
            case SKPaymentTransactionStateRestored:
                [self restoreTransaction:transaction];
            default:
                break;
        }
    };
}

// called when the transaction was successful
- (void)completeTransaction:(SKPaymentTransaction *)transaction
{
    NSLog(@"completeTransaction...");
    
//    UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Bought successfully!"
//                                                      message:@"Thank you for your purchase. Enjoy!"
//                                                     delegate:nil
//                                            cancelButtonTitle:@"OK"
//                                            otherButtonTitles:nil];
//    [message show];
    
    [self provideContentForProductIdentifier:transaction.payment.productIdentifier];
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:transaction.payment.productIdentifier];
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
}

// called when a transaction has been restored and successfully completed
- (void)restoreTransaction:(SKPaymentTransaction *)transaction
{
    NSLog(@"restoreTransaction...");
    
//    UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Restored successfully!"
//                                                      message:@"Enjoy!"
//                                                     delegate:nil
//                                            cancelButtonTitle:@"OK"
//                                            otherButtonTitles:nil];
//    [message show];
    
    [self provideContentForProductIdentifier:transaction.originalTransaction.payment.productIdentifier];
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
    [[NSNotificationCenter defaultCenter] postNotificationName:IAPHelperProductPurchasedNotification
                                                        object:nil
                                                      userInfo:nil];
}

// called when a transaction has failed
- (void)failedTransaction:(SKPaymentTransaction *)transaction
{
    NSLog(@"failedTransaction...");
    
    if (transaction.error.code != SKErrorPaymentCancelled) {
        NSLog(@"Transaction error: %@", transaction.error.localizedDescription);
        
//        UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Ups!"
//                                                          message:transaction.error.localizedDescription
//                                                         delegate:nil
//                                                cancelButtonTitle:@"OK"
//                                                otherButtonTitles:nil];
//        [message show];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:IAPHelperProductPurchasedNotification
                                                        object:nil
                                                      userInfo:nil];
    
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
    [self provideContentForProductIdentifier:nil];
}

- (void)provideContentForProductIdentifier:(NSString *)productIdentifier
{
    NSLog(@"provideContentForProductIdentifier");
    
//    [_purchasedProductIdentifiers addObject:productIdentifier];
//    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:productIdentifier];
//    [[NSUserDefaults standardUserDefaults] synchronize];
    [[NSNotificationCenter defaultCenter] postNotificationName:IAPHelperProductPurchasedNotification
                                                        object:productIdentifier
                                                      userInfo:nil];
}

- (void)restoreCompletedTransactions
{
    [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
}

@end
