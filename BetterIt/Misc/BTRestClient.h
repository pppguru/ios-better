//
//  BTRestClient.h
//  BetterIt
//
//  Created by devMac on 09/03/15.
//  Copyright (c) 2015 Maikel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SynthesizeSingleton.h"
#import <AFNetworking.h>
#import "IAPHelper.h"
#import "Common.h"

#if PRODUCTION_BUILD
    #define API_BASE_URL @"http://52.35.38.48"
#else
    #define API_BASE_URL @"http://52.10.17.208"
    //#define API_BASE_URL @"http://192.168.1.148:8081"
#endif

#define RestClient ((BTRestClient *)[BTRestClient sharedInstance])

typedef void(^BTRestClientCallback)(BOOL success, NSString *code, id response);

typedef enum {
    
    BTRestClientCachePolicyNoCache,             // do not cache the request
    BTRestClientCachePolicyAuthenticatedOnly,   // do not cache the request if not currently authenticated
    BTRestClientCachePolicyAlways               // always cache the request
    
} BTRestClientCachePolicy;

typedef enum {
    
    POSTRequest,
    GETRequest,
    DELETERequest,
    PUTRequest,
    PATCHRequest
    
}BTHTTPMethod;

extern NSString * const RestClientDidAuthenticateNotification;




@interface BTRestClient : NSObject

SYNTHESIZE_SINGLETON_FOR_CLASS_HEADER(BTRestClient)

- (void)rc_authenticateDevice;

// ***** BUSINESS ***** //
- (AFHTTPRequestOperationManager *)getBrandWithSearchTerm:(NSString *)searchTerm Completion:(BTRestClientCallback)completionBlock;
- (AFHTTPRequestOperationManager *)getBusinessesWithSearchTerm:(NSString *)searchTerm NearLocation:(NSDictionary *)location WithIn:(NSNumber *)radius Completion:(BTRestClientCallback)completionBlock;
- (AFHTTPRequestOperationManager *)getBusinessesWithSearchTerm:(NSString *)searchTerm NearAddress:(NSString *)address WithIn:(NSNumber *)radius Completion:(BTRestClientCallback)completionBlock;
- (AFHTTPRequestOperationManager *)getBusinessDetailById:(NSString *)businessId Completion:(BTRestClientCallback)completionBlock;
- (void)getRegisteredBusinessesWithSearchTerm:(NSString *)searchTerm NearLocation:(NSDictionary *)location WithIn:(NSNumber *)radius Completion:(BTRestClientCallback)completionBlock;
- (void)registerBusinessWithPlaceId:(NSString *)placeId Completion:(BTRestClientCallback)completionBlock;

// Verification
- (void)getBusinessVerificationCode:(NSUInteger)businessId Completion:(BTRestClientCallback)completionBlock;
- (void)initiateBusinessVerificationProcess:(NSUInteger)businessId Completion:(BTRestClientCallback)completionBlock;
- (void)checkBusinessVerificationStatus:(NSUInteger)businessId Completion:(BTRestClientCallback)completionBlock;


// ***** USER ***** //
- (void)setUserEmail:(NSString *)email Completion:(BTRestClientCallback)completionBlock;
- (void)updateUser:(NSString *)userType Profile:(NSDictionary *)params Completion:(BTRestClientCallback)completionBlock;
- (void)updateUserAPNSTokenWithCompletion:(BTRestClientCallback)completionBlock;
- (void)getUserSubscriptionWithCompletion:(BTRestClientCallback)completionBlock;
- (void)enableDemoModeWithCompletion:(BTRestClientCallback)completionBlock;
- (void)linkDemoBusiness:(NSInteger)businessId Completion:(BTRestClientCallback)completionBlock;

// ***** MESSAGE SESSION ***** //
- (void)getAllMessageSessionsAs:(NSString *)currentUserType Completion:(BTRestClientCallback)completionBlock;
- (void)getAllMessagesInSession:(NSUInteger)sessionId As:(NSString *)currentUserType Completion:(BTRestClientCallback)completionBlock;
- (void)postFeedback:(NSDictionary *)feedback To:(NSUInteger)businessId Completion:(BTRestClientCallback)completionBlock;
- (void)postMessage:(NSDictionary *)message To:(NSUInteger)sessionId As:(NSString *)currentUserType Completion:(BTRestClientCallback)completionBlock;
- (void)sendAction:(NSString *)action SessionId:(NSUInteger)sessionId As:(NSString *)currentUserType Completion:(BTRestClientCallback)completionBlock;
- (void)sendAction:(NSString *)action MessageId:(NSUInteger)messageId SessionId:(NSUInteger)sessionId As:(NSString *)currentUserType Completion:(BTRestClientCallback)completionBlock;

// ***** INCENTIVE ***** //
- (void)markIncentive:(NSUInteger)messageId Used:(BOOL)used Completion:(BTRestClientCallback)completionBlock;

// ***** RECENT PLACES ***** //
- (void)updateLocations:(NSArray *)locations Completion:(BTRestClientCallback)completionBlock;
- (void)getRecentPlacesWithCompletion:(BTRestClientCallback)completionBlock;

// ***** SURVEY ***** //
- (void)getAllSurveysForBusiness:(NSUInteger)businessId Completion:(BTRestClientCallback)completionBlock;
- (void)getSurveyWithId:(NSUInteger)surveyId Completion:(BTRestClientCallback)completionBlock;
- (void)createSurveyWithQuestion:(NSString *)question Options:(NSArray *)options Type:(NSString *)type Status:(NSString *)status Completion:(BTRestClientCallback)completionBlock;
- (void)updateSurveyWithId:(NSUInteger)surveyId Type:(NSString *)type Status:(NSString *)status Completion:(BTRestClientCallback)completionBlock;
- (void)deleteSurveyWithId:(NSUInteger)surveyId Completion:(BTRestClientCallback)completionBlock;
- (void)getAllSurveysAnsweredByUserWithCompletion:(BTRestClientCallback)completionBlock;
- (void)answerSurveyWithId:(NSUInteger)surveyId Answers:(NSArray *)answers Completion:(BTRestClientCallback)completionBlock;

// ***** SUBSCRIPTION ***** //
- (void)subscribeBusinessWithTransactionData:(SKPaymentTransaction *)transactionData Completion:(BTRestClientCallback)completionBlock;
- (void)subscribeBusinessWithStripeToken:(NSString *)stripeToken plan:(NSString *)plan Completion:(BTRestClientCallback)completionBlock;
- (void)updateSubscriptionPlan:(NSString *)plan Completion:(BTRestClientCallback)completionBlock;

@end
