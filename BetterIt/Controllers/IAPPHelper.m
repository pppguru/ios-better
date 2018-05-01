//
//  IAPPHelper.m
//  BetterIt
//
//  Created by Yosemite on 1/21/16.
//  Copyright © 2016 Maikel. All rights reserved.
//

#import "IAPPHelper.h"

#import <StoreKit/StoreKit.h>

#define kBetterItProductIdentifier @"BetterIt"
#define kBetterItAndSurveyProductIdentifier @"BetterItSurvey"

@protocol IAPHelperDelegate <NSObject>

@optional


@end

@interface IAPPHelper() <SKProductsRequestDelegate, SKPaymentTransactionObserver> {
    SKProduct *curProduct;
    BOOL isRestoring;
}

@property (nonatomic, weak) id<IAPHelperDelegate> delegate;

@end

@implementation IAPPHelper

- (void)restore {
    isRestoring = YES;
    
//    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    
    [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
}

- (void)purchase:(SKProduct *)product{
    SKPayment *payment = [SKPayment paymentWithProduct:product];
    
    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    [[SKPaymentQueue defaultQueue] addPayment:payment];
}

#pragma mark - SKProductsRequestDelegate
- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response NS_AVAILABLE_IOS(3_0) {
    
    SKProduct *validProduct = nil;
    int count = [response.products count];
    if(count > 0){
        validProduct = [response.products objectAtIndex:0];
        NSLog(@"Products Available!");
        curProduct = validProduct;
        
        [self purchase:validProduct];
    }
    else if(!validProduct){
//        [Utilities showMsg:@"No products available!"];
        NSLog(@"No products available, %@", response.debugDescription);
        //this is called if your product id is not valid, this shouldn't be called unless that happens.
    }
}

- (void) paymentQueueRestoreCompletedTransactionsFinished:(SKPaymentQueue *)queue
{
    NSLog(@"received restored transactions: %i", queue.transactions.count);
    for(SKPaymentTransaction *transaction in queue.transactions){
        if(transaction.transactionState == SKPaymentTransactionStateRestored || transaction.transactionState == SKPaymentTransactionStatePurchased){
            //called when the user successfully restores a purchase
            
            NSLog(@"Transaction state -> Restored, %@", transaction.payment.productIdentifier);
            if ([transaction.payment.productIdentifier isEqualToString:kBetterItProductIdentifier]) {
                
            }
            else if ([transaction.payment.productIdentifier isEqualToString:kBetterItAndSurveyProductIdentifier]) {
                
            }
            
            [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
        }
    }
    isRestoring = NO;
}

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions{
    for(SKPaymentTransaction *transaction in transactions){
        switch(transaction.transactionState){
            case SKPaymentTransactionStatePurchasing: NSLog(@"Transaction state -> Purchasing");
                //called when the user is in the process of purchasing, do not add any of your own code here.
                break;
            case SKPaymentTransactionStatePurchased:
                //this is called when the user has successfully purchased the package (Cha-Ching!)
                
                //you can add your code for what you want to happen when the user buys the purchase here, for this tutorial we use removing ads
                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                
                NSLog(@"Transaction state -> Purchased");
                
                
                //                [Utilities showMsg:@"Successfully Purchased!"];
                break;
            case SKPaymentTransactionStateRestored:
                NSLog(@"Transaction state -> Restored, %@", transaction.payment.productIdentifier);
                //add the same code as you did from SKPaymentTransactionStatePurchased here
     
                
                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                
                //                [Utilities showMsg:@"Successfully Restored!"];
                break;
            case SKPaymentTransactionStateFailed:
                //called when the transaction does not finish
                NSLog(@"Transaction state -> Cancelled %@", transaction.error.description);
                //                [Utilities showMsg:@"Transaction Failed!"];
                
                if(transaction.error.code == SKErrorPaymentCancelled){
                    NSLog(@"Transaction state -> Cancelled %@", transaction.error.description);
                    //the user cancelled the payment ;(
                }
                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                break;
        }
    }
}


@end
