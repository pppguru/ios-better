//
//  BTRestClient.m
//  BetterIt
//
//  Created by devMac on 09/03/15.
//  Copyright (c) 2015 Maikel. All rights reserved.
//

#import "BTRestClient.h"
#import "AppDelegate.h"
#import "NSArray+Plist.h"
#import "Common.h"
#import "BTModel.h"
#import "BTConfig.h"
#import "IAPShare.h"
#import "NSData+Base64.h"

NSString * const cacheFileName = @"request_cache";

NSString * const RestClientDidAuthenticateNotification = @"restClientDidAuthenticate";



@interface BTRestClient ()
@property (strong, nonatomic) NSMutableArray *requestCache;

@property (assign, nonatomic) bool isAuthenticating;
@property (copy, nonatomic) NSString *sessionToken;
@end




@implementation BTRestClient
SYNTHESIZE_SINGLETON_FOR_CLASS(BTRestClient)

- (id)init {
    self = [super init];
    if (self) {
        [self rc_authenticateDevice];
    }
    return self;
}




#pragma mark - PRIVATE
#pragma mark Cache

- (NSMutableArray *)requestCache {
    if (!_requestCache) {
        _requestCache = [NSArray bt_readFromPlistFile:cacheFileName].mutableCopy;
        
        if (!_requestCache) {
            _requestCache = [NSMutableArray new];
        }
    }
    
    return _requestCache;
}

- (void)saveRequestCache {
    [_requestCache bt_writeToPlistFile:cacheFileName];
}

#pragma mark MIME

-(NSString*)rc_getMimeType:(NSString*)imageName{
    NSArray* strArray = [imageName componentsSeparatedByString:@"."];
    NSString* extention = [strArray objectAtIndex:strArray.count -1];
    NSString* type = [extention lowercaseString];
    NSString* mime  = @"image/jpeg";
    if ([type isEqualToString:@"png"]) {
        mime = @"image/png";
    }else if([type isEqualToString:@"jpe"] || [type isEqualToString:@"jpeg"] || [type isEqualToString:@"jpg"]){
        mime = @"image/jpeg";
    }else if([type isEqualToString:@"gif"]){
        mime = @"image/gif";
    }else if([type isEqualToString:@"bmp"]){
        mime = @"image/bmp";
    }else if([type isEqualToString:@"ico"]){
        mime = @"image/vnd.microsoft.icon";
    }else if([type isEqualToString:@"tiff"] || [type isEqualToString:@"tif"] ){
        mime = @"image/tiff";
    }else if([type isEqualToString:@"svg"] || [type isEqualToString:@"svgz"] ){
        mime = @"image/svg+xml";
    }else{
        mime = @"image/jpeg";
    }
    
    return mime;
}

#pragma mark Authentication

- (void)rc_authenticateDevice {
    if (_isAuthenticating) {
        return;
    }
    _isAuthenticating = YES;
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/html", nil];
    
    NSString *URL = [API_BASE_URL stringByAppendingString:@"/api/user/auth"];
    NSDictionary *params = @{@"device_token" : DEVICE_TOKEN, @"device_type" : DEVICE_TYPE};
    [manager POST:URL parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {

        if ([@"" isEqualToString:responseObject[@"code"]]) {
            _sessionToken = responseObject[@"token"];
     
            [Model setInitialData:responseObject];
            
            // notify successful authentication
            [[NSNotificationCenter defaultCenter] postNotificationName:RestClientDidAuthenticateNotification object:responseObject];
            
            // flush request queue if not empty
            [self flushRequestCache];
            
            [self updateUserAPNSTokenWithCompletion:nil];
        }
        
        NSLog(@"AUTH SUCCESS %@\nRequest - %@\nResponse - %@", URL, params, responseObject);
        _isAuthenticating = NO;
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        NSLog(@"AUTH FAILURE %@\nRequest - %@\nError - %@", URL, params, error);
        _isAuthenticating = NO;
    }];
}


#pragma mark Operation

- (AFHTTPRequestOperationManager *)rc_get:(NSString *)URL Parameters:(NSDictionary *)params Completion:(BTRestClientCallback)completionBlock {
    if (!_sessionToken) {
        return nil;
    }
    
    NSMutableDictionary *paramsDictionary = [NSMutableDictionary dictionaryWithObjectsAndKeys:_sessionToken, @"token", nil];
    [paramsDictionary addEntriesFromDictionary:params];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/html", nil];
    
    [manager GET:[API_BASE_URL stringByAppendingPathComponent:URL] parameters:paramsDictionary success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        if (completionBlock) {
            NSString *code = responseObject[@"code"];
            completionBlock(code.length == 0, code, responseObject);
        }
        
        //NSLog(@"GET SUCCESS %@\nRequest - %@\nResponse - %@", URL, paramsDictionary, responseObject);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        //NSLog(@"GET FAILURE %@\nRequest - %@\nError - %@", URL, paramsDictionary, error);
    }];
    
    return manager;
}

- (void)rc_send:(BTHTTPMethod)HTTPMethod URL:(NSString *)URL Parameters:(NSDictionary *)params CachePolicy:(BTRestClientCachePolicy)cachePolicy Completion:(BTRestClientCallback)completionBlock {
    if (self.requestCache.count) {
        [self flushRequestCache];
    }
    
    if (!URL) {
        return;
    }
    
    if (!_sessionToken) {
        if (!_isAuthenticating) {
            [self rc_authenticateDevice];
        }
        
        if (cachePolicy != BTRestClientCachePolicyNoCache) {
            NSMutableDictionary *requestObject = @{@"_URL" : URL}.mutableCopy;
            [requestObject addEntriesFromDictionary:params];
            
            // queue it
            [self.requestCache addObject:requestObject];
        }
        
        return;
    }
    
    NSString* method;
    switch (HTTPMethod) {
        case POSTRequest:
            method = @"POST";
            break;
        case GETRequest:
            method = @"GET";
            break;
        case DELETERequest:
            method = @"DELETE";
            break;
        case PUTRequest:
            method = @"PUT";
            break;
        case PATCHRequest:
            method = @"PATCH";
            break;
            
        default:
            method = @"POST";
            break;
    }
    
    NSMutableDictionary *paramsDictionary = [NSMutableDictionary dictionaryWithObjectsAndKeys:_sessionToken, @"token", nil];
    [paramsDictionary addEntriesFromDictionary:params];

    AFHTTPRequestSerializer *serializer = [AFHTTPRequestSerializer serializer];
    NSMutableURLRequest *request;
    
    NSString *imageFilename = paramsDictionary[@"image_local"];
    [paramsDictionary removeObjectForKey:@"image_local"];

    NSError *error = nil;
    
    if (imageFilename.length) {
        
        request = [serializer multipartFormRequestWithMethod:method
                                                   URLString:[API_BASE_URL stringByAppendingPathComponent:URL]
                                                  parameters:paramsDictionary
                                   constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {

                                       NSString *imageFilePath = [appDelegate.applicationDocumentDirectory stringByAppendingPathComponent:imageFilename];
                                       NSData *imageData = [NSData dataWithContentsOfFile:imageFilePath];
                                       NSString *mimeType = [self rc_getMimeType:imageFilename];

                                       [formData appendPartWithFileData:imageData
                                                                   name:@"image"
                                                               fileName:imageFilename
                                                               mimeType:mimeType];
                                       
                                   } error:&error];
    }else{
        
        request = [[AFJSONRequestSerializer serializer] requestWithMethod:method
                                                                URLString:[API_BASE_URL stringByAppendingPathComponent:URL]
                                                               parameters:paramsDictionary
                                                                    error:&error];
    }

    if (error) {
        //NSLog(@"Error while serializing request - %@\nError - %@", paramsDictionary, error);
    }
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/html", nil];

    request.timeoutInterval = 10.f;

    [[manager HTTPRequestOperationWithRequest:request success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"%@ SUCCESS %@\nRequest - %@\nResponse - %@", method, URL, paramsDictionary, responseObject);
        
        if (completionBlock) {
            NSString *code = responseObject[@"code"];
            completionBlock(code.length == 0, code, responseObject);
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
       
        NSLog(@"%@ FAILURE %@\nRequest - %@\nError - %@", method, URL, paramsDictionary, error);
        
        if (cachePolicy != BTRestClientCachePolicyNoCache) {
            NSMutableDictionary *requestObject = @{@"_URL" : URL}.mutableCopy;
            
            [requestObject addEntriesFromDictionary:params];
            
            // queue it
            [self.requestCache addObject:requestObject];
            
            NSLog(@"Will try again later");
        }
        
        if (completionBlock) {
            completionBlock(NO, nil, error);
        }
        
    }] start];
}

- (void)rc_post:(NSString *)URL Parameters:(NSDictionary *)params CachePolicy:(BTRestClientCachePolicy)cachePolicy Completion:(BTRestClientCallback)completionBlock {
    [self rc_send:POSTRequest URL:URL Parameters:params CachePolicy:cachePolicy Completion:completionBlock];
}

- (void)rc_delete:(NSString *)URL Parameters:(NSDictionary *)params CachePolicy:(BTRestClientCachePolicy)cachePolicy Completion:(BTRestClientCallback)completionBlock {
    [self rc_send:DELETERequest URL:URL Parameters:params CachePolicy:cachePolicy Completion:completionBlock];
}

- (void)rc_put:(NSString *)URL Parameters:(NSDictionary *)params CachePolicy:(BTRestClientCachePolicy)cachePolicy Completion:(BTRestClientCallback)completionBlock {
    [self rc_send:PUTRequest URL:URL Parameters:params CachePolicy:cachePolicy Completion:completionBlock];
}

- (void)flushRequestCache {
//    if (!_sessionToken) {
//        return;
//    }
//    
//    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
//    manager.requestSerializer = [AFJSONRequestSerializer serializer];
//    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
//    manager.responseSerializer = [AFJSONResponseSerializer serializer];
//    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/html", nil];
//    
//    for (NSDictionary *requestObject in self.requestCache) {
//        NSString *URL = requestObject[@"_URL"];
//        NSMutableDictionary *params = requestObject.mutableCopy;
//        [params removeObjectForKey:@"_URL"];
//        
//        [params setObject:_sessionToken forKey:@"token"];
//        
//        [manager POST:[API_BASE_URL stringByAppendingPathComponent:URL] parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
//            
//            [self.requestCache removeObject:requestObject];
//            
//            //NSLog(@"FLUSH SUCCESS %@\nRequest - %@\nResponse - %@", URL, params, responseObject);
//            
//        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//            
//            //NSLog(@"FLUSH FAILURE %@\nRequest - %@\nError - %@", URL, params, error);
//        }];
//    }
}


#pragma mark - PUBLIC
#pragma mark Business

- (AFHTTPRequestOperationManager *)getBrandWithSearchTerm:(NSString *)searchTerm Completion:(BTRestClientCallback)completionBlock {
    return [self rc_get:@"/api/brand"
             Parameters:@{@"search" : searchTerm}
             Completion:completionBlock];
}

- (AFHTTPRequestOperationManager *)getBusinessesWithSearchTerm:(NSString *)searchTerm NearLocation:(NSDictionary *)location WithIn:(NSNumber *)radius Completion:(BTRestClientCallback)completionBlock {
    return [self rc_get:@"/api/business"
             Parameters:@{@"search" : searchTerm,
                          @"geo_lat" : location[@"latitude"],
                          @"geo_lng" : location[@"longitude"],
                          @"radius" : radius}
             Completion:completionBlock];
}

- (AFHTTPRequestOperationManager *)getBusinessesWithSearchTerm:(NSString *)searchTerm NearAddress:(NSString *)address WithIn:(NSNumber *)radius Completion:(BTRestClientCallback)completionBlock {
    return [self rc_get:@"/api/business"
             Parameters:@{@"search" : searchTerm,
                          @"address": address,
                          @"radius" : radius}
             Completion:completionBlock];
}

- (AFHTTPRequestOperationManager *)getBusinessDetailById:(NSString *)businessId Completion:(BTRestClientCallback)completionBlock {
    return [self rc_get:[NSString stringWithFormat:@"/api/business/%@", businessId]
             Parameters:nil Completion:completionBlock];
}

- (void)getRegisteredBusinessesWithSearchTerm:(NSString *)searchTerm NearLocation:(NSDictionary *)location WithIn:(NSNumber *)radius Completion:(BTRestClientCallback)completionBlock {
    [self rc_get:@"/api/business/local"
      Parameters:@{@"search" : searchTerm,
                   @"geo_lat" : location[@"latitude"],
                   @"geo_lng" : location[@"longitude"],
                   @"radius" : radius}
      Completion:completionBlock];
}

- (void)registerBusinessWithPlaceId:(NSString *)placeId Completion:(BTRestClientCallback)completionBlock {
    [self rc_put:@"/api/business" Parameters:@{@"place_id" : placeId} CachePolicy:BTRestClientCachePolicyAlways Completion:completionBlock];
}

#pragma mark Business Verification

- (void)getBusinessVerificationCode:(NSUInteger)businessId Completion:(BTRestClientCallback)completionBlock {
    [self rc_post:@"/api/user/business"
       Parameters:@{@"business_id" : @(businessId)}
      CachePolicy:BTRestClientCachePolicyNoCache
       Completion:completionBlock];
}

- (void)initiateBusinessVerificationProcess:(NSUInteger)businessId Completion:(BTRestClientCallback)completionBlock {
    [self rc_post:@"/api/user/business/call"
      Parameters:@{@"business_id" : @(businessId)}
     CachePolicy:BTRestClientCachePolicyNoCache
      Completion:completionBlock];
}

- (void)checkBusinessVerificationStatus:(NSUInteger)businessId Completion:(BTRestClientCallback)completionBlock{
    [self rc_get:@"/api/user/business"
      Parameters:@{@"business_id" : @(businessId)}
      Completion:completionBlock];
}

#pragma mark User

- (void)setUserEmail:(NSString *)email Completion:(BTRestClientCallback)completionBlock {
    [self rc_post:@"/api/user/email"
       Parameters:@{@"email" : email}
      CachePolicy:BTRestClientCachePolicyAuthenticatedOnly
       Completion:completionBlock];
}

- (void)updateUserAPNSTokenWithCompletion:(BTRestClientCallback)completionBlock {
    NSString *apnsToken = [BTConfig objectForKey:kAPNSTokenKey];
    
    if (apnsToken) {
        [self rc_put:@"/api/user/apns"
          Parameters:@{@"apns_token" : apnsToken}
         CachePolicy:BTRestClientCachePolicyNoCache
          Completion:completionBlock];
    }
}

/**
 * Set user/business user profile
 *
 * userType : "user"/"business"
 * params   : 
 *   - user
 *      "name", "email"
 *   - business
 *      "email", "pincode"
 */
- (void)updateUser:(NSString *)userType Profile:(NSDictionary *)params Completion:(BTRestClientCallback)completionBlock {
    NSString *URL = @"/api/user";
    if ([@"business" isEqualToString:userType]) {
        URL = @"/api/user/business";
    }
    
    [self rc_put:URL Parameters:params CachePolicy:BTRestClientCachePolicyAuthenticatedOnly Completion:completionBlock];
}

- (void)getUserSubscriptionWithCompletion:(BTRestClientCallback)completionBlock {
    [self rc_get:@"/api/user/iap" Parameters:nil Completion:completionBlock];
}

- (void)enableDemoModeWithCompletion:(BTRestClientCallback)completionBlock {
    [self rc_post:@"/api/demo/mode" Parameters:@{@"action" : @YES} CachePolicy:BTRestClientCachePolicyNoCache Completion:completionBlock];
}

- (void)linkDemoBusiness:(NSInteger)businessId Completion:(BTRestClientCallback)completionBlock {
    [self rc_post:@"api/demo/link" Parameters:@{@"business_id" : @(businessId)} CachePolicy:BTRestClientCachePolicyNoCache Completion:completionBlock];
}


#pragma mark Message

/**
 * Get all message sessions for current user
 *
 * currentUserType : user/business
 */
- (void)getAllMessageSessionsAs:(NSString *)currentUserType Completion:(BTRestClientCallback)completionBlock {
    NSString *URL = [NSString stringWithFormat:@"/api/session/%@", currentUserType].lowercaseString;
    [self rc_get:URL Parameters:nil Completion:completionBlock];
}

/**
 * Get all messages in session for current user
 *
 * sessionId : session id
 * currentUserType : user/business
 */
- (void)getAllMessagesInSession:(NSUInteger)sessionId As:(NSString *)currentUserType Completion:(BTRestClientCallback)completionBlock {
    NSString *URL = [NSString stringWithFormat:@"/api/session/%@/%ld", currentUserType, (unsigned long)sessionId].lowercaseString;
    [self rc_get:URL Parameters:nil Completion:completionBlock];
}

/**
 * Post message to a user/business
 *
 * message : message to send
 * opponentId : user/business id
 * currentUserType : user/business
 */
- (void)postMessage:(NSDictionary *)message To:(NSUInteger)sessionId As:(NSString *)currentUserType Completion:(BTRestClientCallback)completionBlock {
    NSString *URL = [NSString stringWithFormat:@"/api/session/%@/%ld", currentUserType, (unsigned long)sessionId].lowercaseString;
    [self rc_post:URL Parameters:message CachePolicy:BTRestClientCachePolicyAlways Completion:completionBlock];
}

/**
 * Post feedback to a business
 *
 * feedback : message to send
 * businessId : business id
 * currentUserType : user/business
 */
- (void)postFeedback:(NSDictionary *)feedback To:(NSUInteger)businessId Completion:(BTRestClientCallback)completionBlock {
    NSString *URL = [NSString stringWithFormat:@"/api/session/user/create/%ld", (unsigned long)businessId].lowercaseString;
    [self rc_post:URL Parameters:feedback CachePolicy:BTRestClientCachePolicyAlways Completion:completionBlock];
}

/**
 * Archive message session
 *
 * sessionId : session id to archive
 * currentUserType : user/business
 */
- (void)sendAction:(NSString *)action SessionId:(NSUInteger)sessionId As:(NSString *)currentUserType Completion:(BTRestClientCallback)completionBlock {
    NSString *URL = [NSString stringWithFormat:@"/api/session/%@/%ld/action", currentUserType, (unsigned long)sessionId].lowercaseString;
    [self rc_post:URL Parameters:@{@"action" : action} CachePolicy:BTRestClientCachePolicyAuthenticatedOnly Completion:completionBlock];
}


/**
 * Send action on a particular message
 *
 * action : read/report
 * messageId : message id
 * sessionId : session id
 * currentUserType : user/business
 */
- (void)sendAction:(NSString *)action MessageId:(NSUInteger)messageId SessionId:(NSUInteger)sessionId As:(NSString *)currentUserType Completion:(BTRestClientCallback)completionBlock {
    NSString *URL = [NSString stringWithFormat:@"/api/session/%@/%ld/message/%ld/action", currentUserType, (unsigned long)sessionId, (unsigned long)messageId].lowercaseString;
    [self rc_post:URL Parameters:@{@"action" : action} CachePolicy:BTRestClientCachePolicyNoCache Completion:completionBlock];
}

/**
 * Mark incentive as Used/Unused
 *
 * message id
 */
- (void)markIncentive:(NSUInteger)messageId Used:(BOOL)used Completion:(BTRestClientCallback)completionBlock {
    [self rc_put:[NSString stringWithFormat:@"/api/incentive/%d", (int)messageId]
      Parameters:@{@"used" : @(used)}
     CachePolicy:BTRestClientCachePolicyAlways
      Completion:completionBlock];
}

#pragma mark - Recent Places

/**
 * Ping web service with recent locations
 *
 * locations
 */
- (void)updateLocations:(NSArray *)locations Completion:(BTRestClientCallback)completionBlock {
    [self rc_post:@"/api/user/recent"
       Parameters:@{@"places":locations}
      CachePolicy:BTRestClientCachePolicyAlways
       Completion:completionBlock];
}

/**
 * Get recent places
 */
- (void)getRecentPlacesWithCompletion:(BTRestClientCallback)completionBlock {
    [self rc_get:@"/api/user/recent"
      Parameters:nil
      Completion:completionBlock];
}


#pragma mark - Survey

- (void)getAllSurveysForBusiness:(NSUInteger)businessId Completion:(BTRestClientCallback)completionBlock {
    [self rc_get:@"/api/survey"
      Parameters:@{@"business_id" : @(businessId)}
      Completion:completionBlock];
}

- (void)getSurveyWithId:(NSUInteger)surveyId Completion:(BTRestClientCallback)completionBlock {
    [self rc_get:[NSString stringWithFormat:@"/api/survey/%d", (int)surveyId]
      Parameters:nil
      Completion:completionBlock];
}

- (void)createSurveyWithQuestion:(NSString *)question Options:(NSArray *)options Type:(NSString *)type Status:(NSString *)status Completion:(BTRestClientCallback)completionBlock {
    [self rc_post:@"/api/survey"
       Parameters:@{@"question" : question,
                    @"options" : options,
                    @"type" : type,
                    @"status" : status}
      CachePolicy:BTRestClientCachePolicyAuthenticatedOnly
       Completion:completionBlock];
}

- (void)updateSurveyWithId:(NSUInteger)surveyId Type:(NSString *)type Status:(NSString *)status Completion:(BTRestClientCallback)completionBlock {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    if (type)   [params setObject:type forKey:@"type"];
    if (status) [params setObject:status forKey:@"status"];
    
    [self rc_put:[NSString stringWithFormat:@"/api/survey/%d", (int)surveyId]
      Parameters:params
     CachePolicy:BTRestClientCachePolicyAuthenticatedOnly
      Completion:completionBlock];
}

- (void)deleteSurveyWithId:(NSUInteger)surveyId Completion:(BTRestClientCallback)completionBlock {
    [self rc_delete:[NSString stringWithFormat:@"/api/survey/%d", (int)surveyId]
         Parameters:nil
        CachePolicy:BTRestClientCachePolicyAuthenticatedOnly
         Completion:completionBlock];
}

- (void)getAllSurveysAnsweredByUserWithCompletion:(BTRestClientCallback)completionBlock {
    [self rc_get:@"/api/user/survey"
      Parameters:nil
      Completion:completionBlock];
}

- (void)answerSurveyWithId:(NSUInteger)surveyId Answers:(NSArray *)answers Completion:(BTRestClientCallback)completionBlock {
    [self rc_post:[NSString stringWithFormat:@"/api/user/survey/%d", (int)surveyId]
       Parameters:@{@"answers" : answers}
      CachePolicy:BTRestClientCachePolicyAuthenticatedOnly
       Completion:completionBlock];
}


#pragma mark - Subscription

/**
 * Business subscription with IAP identifier
 *
 * IAP ID : in app purchase dientifier
 * plan : "BASIC", "PRO"
 */
- (void)subscribeBusinessWithTransactionData:(SKPaymentTransaction *)transactionData Completion:(BTRestClientCallback)completionBlock {
//    NSAssert([@"BASIC" isEqualToString:plan] || [@"PRO" isEqualToString:plan],
//             @"Subscription plan must be BASIC | PRO");
    NSPropertyListFormat plistFormat;

    NSDictionary *jsonObject = [NSPropertyListSerialization propertyListWithData:transactionData.transactionReceipt
                                                                         options:NSPropertyListImmutable
                                                                          format:&plistFormat
                                                                           error:nil];
    
    NSData *receiptData = [NSData dataFromBase64String:[jsonObject objectForKey:@"purchase-info"]];
    
    NSDictionary *receiptDict = [NSPropertyListSerialization propertyListWithData:receiptData
                                                                          options:NSPropertyListImmutable
                                                                           format:&plistFormat
                                                                            error:nil];
    
    NSTimeInterval expiresDate = [[receiptDict objectForKey:@"expires-date"] doubleValue];
    
    SKPaymentTransaction *originalTransaction = transactionData.originalTransaction;
    if (!originalTransaction) {
        originalTransaction = transactionData;
    }
    
    [self rc_post:@"/api/user/iap"
       Parameters:@{@"product_id" : transactionData.payment.productIdentifier,
                    @"transaction_id" : transactionData.transactionIdentifier,
                    @"original_transaction_id" : originalTransaction.transactionIdentifier,
                    @"purchase_date" : @([transactionData.transactionDate timeIntervalSince1970] * 1000),
                    @"original_purchase_date" : @([originalTransaction.transactionDate timeIntervalSince1970] * 1000),
                    @"expires_date" : @(expiresDate),
//                    @"cancellation_date" : @(expiresDate)
                    }
      CachePolicy:BTRestClientCachePolicyNoCache
       Completion:completionBlock];
}

#pragma GCC diagnostic pop

/**
 * Business subscription with Stripe Token
 *
 * stripe token : stripe card token
 * stripe plan : "BASIC", "PRO"
 */
- (void)subscribeBusinessWithStripeToken:(NSString *)stripeToken plan:(NSString *)plan Completion:(BTRestClientCallback)completionBlock {
    NSAssert([@"BASIC" isEqualToString:plan] || [@"PRO" isEqualToString:plan],
             @"Subscription plan must be BASIC | PRO");
    [self rc_post:@"/api/user/subscription"
       Parameters:@{@"stripe_card_token" : stripeToken,
                    @"stripe_plan" : plan}
      CachePolicy:BTRestClientCachePolicyNoCache
       Completion:completionBlock];
}

/**
 * Update business subscription plan
 *
 * stripe plan : "BASIC", "PRO"
 */
- (void)updateSubscriptionPlan:(NSString *)plan Completion:(BTRestClientCallback)completionBlock {
    NSAssert([@"BASIC" isEqualToString:plan] || [@"PRO" isEqualToString:plan],
             @"Subscription plan must be BASIC | PRO");
    [self rc_put:@"/api/user/subscription"
       Parameters:@{@"stripe_plan" : plan}
      CachePolicy:BTRestClientCachePolicyNoCache
       Completion:completionBlock];
}

@end
