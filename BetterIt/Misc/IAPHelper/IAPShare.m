//
//  IAPShare.m
//  inappPurchasesTest
//
//  Created by Htain Lin Shwe on 10/7/12.
//  Copyright (c) 2012 Edenpod. All rights reserved.
//

#import "IAPShare.h"
#import "Common.h"


#if ! __has_feature(objc_arc)
#error You need to either convert your project to ARC or add the -fobjc-arc compiler flag to IAPShare.m.
#endif

@implementation IAPShare
@synthesize iap= _iap;
static IAPShare * _sharedHelper;

+ (IAPShare *) sharedHelper {
    
    if (_sharedHelper != nil) {
        return _sharedHelper;
    }
    _sharedHelper = [[IAPShare alloc] init];
    
    IAPHelper *iap = [[IAPHelper alloc] initWithProductIdentifiers:[NSSet setWithObjects:kBetterItProductIdentifier, kBetterItSurveyProductIdentifier, kBetterItAndSurveyProductIdentifier, nil]];
    iap.production = PRODUCTION_BUILD;
    _sharedHelper.iap = iap;
    
    return _sharedHelper;
}

+(id)toJSON:(NSString *)json
{
    NSError* e = nil;
    id jsonObject = [NSJSONSerialization JSONObjectWithData: [json dataUsingEncoding:NSUTF8StringEncoding]
                                    options: NSJSONReadingMutableContainers
                                      error: &e];
    
    if(e==nil) {
        return jsonObject;
    }
    else {
        NSLog(@"%@",[e localizedDescription]);
        return nil;
    }
    
}

- (void)restoreOrBuyProductWithID:(NSString *)productId
                  completionBlock:(void(^)(BOOL, SKPaymentTransaction *))completionBlock
{
    __weak typeof(self) weakSelf = self;
//    [self.iap restoreProductsWithCompletion:^(SKPaymentQueue *payment, NSError *error) {
//        if (error) {
//            NSLog(@"Error restoring transactions - %@", error);
//            if (completionBlock) {
//                completionBlock(NO, nil);
//            }
//            return;
//        }
//        
//        NSLog(@"Transactions restored - %@", payment.transactions);
//        SKPaymentTransaction *transaction = nil;
//        for (SKPaymentTransaction *trans in payment.transactions) {
//            if ([trans.payment.productIdentifier isEqualToString:productId]) {
//                transaction = trans;
//                break;
//            }
//        }
//        
//        if (transaction) {
//            if (completionBlock) {
//                completionBlock(YES, transaction);
//            }
//            return;
//        }
//
//        [weakSelf.iap requestProductsWithCompletion:^(SKProductsRequest* request,SKProductsResponse* response) {
//            NSLog(@"Products retrieved - %@", response.products);
//            
//            SKProduct *product = nil;
//            for (SKProduct *prod in response.products) {
//                if ([prod.productIdentifier isEqualToString:productId]) {
//                    product = prod;
//                    break;
//                }
//            }
//            
//            if (product) {
//                [weakSelf.iap buyProduct:product onCompletion:^(SKPaymentTransaction *transaction) {
//                    if (completionBlock) {
//                        completionBlock(transaction.transactionState == SKPaymentTransactionStateRestored, transaction);
//                    }
//                }];
//            } else {
//                if (completionBlock) {
//                    completionBlock(NO, nil);
//                }
//            }
//        }];
//
//    }];
//    
    [self.iap requestProductsWithCompletion:^(SKProductsRequest* request,SKProductsResponse* response) {
        NSLog(@"Products retrieved - %@", response.products);
        
        SKProduct *product = nil;
        for (SKProduct *prod in response.products) {
            if ([prod.productIdentifier isEqualToString:productId]) {
                product = prod;
                break;
            }
        }
        
        if (product) {
            [weakSelf.iap buyProduct:product onCompletion:^(SKPaymentTransaction *transaction) {
                if (completionBlock) {
                    completionBlock(transaction.transactionState == SKPaymentTransactionStateRestored, transaction);
                }
            }];
        } else {
            if (completionBlock) {
                completionBlock(NO, nil);
            }
        }
    }];

}

@end
