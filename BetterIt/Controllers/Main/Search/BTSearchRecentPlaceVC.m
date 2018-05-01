//
//  BTSearchRecentPlaceVC.m
//  BetterIt
//
//  Created by devMac on 09/02/15.
//  Copyright (c) 2015 Maikel. All rights reserved.
//

#import "BTSearchRecentPlaceVC.h"
#import "BTSearchBusinessTVC.h"
#import "BTModel.h"
#import "BTRestClient.h"
#import "AppDelegate.h"
#import "INTULocationManager+CurrentLocation.h"
#import "BTConfig.h"
#import "Common.h"
#import "BTSearchBusinessController.h"
#import "NSArray+Plist.h"
#import <FTGooglePlacesAPI.h>
#import <UIImageView+WebCache.h>
#import <Google/Analytics.h>


@interface BTSearchRecentPlaceVC () <UITableViewDataSource, UITableViewDelegate>
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *dataSource;
@property (strong, nonatomic) NSArray *recentVisits;
@end

@implementation BTSearchRecentPlaceVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self.tableView registerNib:[UINib nibWithNibName:@"BTSearchBusinessTVC" bundle:nil] forCellReuseIdentifier:@"tvcSearchBusiness"];
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 90.f;
    
//    [RestClient getRecentPlacesWithCompletion:^(BOOL success, NSString *code, id response) {
//        if (success) {
//            _dataSource = [BTBusiness objectsWithJSONArray:response[@"places"]];
//            [_tableView reloadData];
//        }
//    }];

    NSArray *visits = [NSArray bt_readFromPlistFile:kLocationQueueKey];
//    NSDate *twoDaysAgo = [NSDate dateWithTimeIntervalSinceNow:-60*60*48];
//    _recentVisits = [visits filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"departureDate > %@", twoDaysAgo]];
    _recentVisits = [visits subarrayWithRange:NSMakeRange(0, MIN(visits.count, 10))];
    
    if (_recentVisits.count) {
        [self loadRecentPlaces];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:NSStringFromClass([self class])];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
}

- (IBAction)backAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}


- (void)loadRecentPlaces {
    _dataSource = [NSMutableArray array];
    
    __weak typeof(self) weakSelf = self;
    
    for (CLVisit *visit in _recentVisits) {
       
        if (!CLLocationCoordinate2DIsValid(visit.coordinate)) {
            continue;
        }
        
        //  Create request searching nearest galleries and museums
        FTGooglePlacesAPINearbySearchRequest *request = [[FTGooglePlacesAPINearbySearchRequest alloc] initWithLocationCoordinate:visit.coordinate];
        request.rankBy = FTGooglePlacesAPIRequestParamRankByDistance;
        request.types = @[@"establishment"];

        //  Execute Google Places API request using FTGooglePlacesAPIService
        [FTGooglePlacesAPIService executeSearchRequest:request
                                 withCompletionHandler:^(FTGooglePlacesAPISearchResponse *response, NSError *error) {
                                     
                                     //  If error is not nil, request failed and you should handle the error
                                     if (error)
                                     {
                                         // Handle error here
                                         //NSLog(@"Request failed. Error: %@", error);
                                         
                                         //  There may be a lot of causes for an error (for example networking error).
                                         //  If the network communication with Google Places API was successful,
                                         //  but the API returned some non-ok status code, NSError will have
                                         //  FTGooglePlacesAPIErrorDomain domain and status code from
                                         //  FTGooglePlacesAPIResponseStatus enum
                                         //  You can inspect error's domain and status code for more detailed info
                                     } else {
                                         
                                         //  Everything went fine, we have response object we can process
                                         //NSLog(@"Request succeeded. Response: %@", response);
                                         
                                         FTGooglePlacesAPISearchResultItem *resultItem = response.results.firstObject;
                                         BTBusiness *business = [BTBusiness businessWithGooglePlacesSearchResultDictionary:resultItem.originalDictionaryRepresentation];
                                         NSPredicate *predicate = [NSPredicate predicateWithFormat:@"googlePlaceId LIKE[cd] %@", business.googlePlaceId];
                                         
                                         @synchronized(weakSelf) {
                                             if ([weakSelf.dataSource filteredArrayUsingPredicate:predicate].count == 0) {
                                                 [weakSelf.dataSource addObject:business];
                                             }
                                             
                                             weakSelf.dataSource = [[BTModel arraySortedByDistance:weakSelf.dataSource
                                                                                     fromLocation:[INTULocationManager sharedInstance].currentLocation] mutableCopy];
                                             
                                             [weakSelf.tableView reloadData];
                                         }
                                     }
                                     
                                 }];

    }
}

#pragma mark - Table View
#pragma mark Delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    BTSearchBusinessTVC *cell = [tableView dequeueReusableCellWithIdentifier:@"tvcSearchBusiness"];
    BTBusiness *business = _dataSource[indexPath.row];
    
    cell.lblBusinessName.text = business.name;
    cell.lblAddress.text = business.address;
    [cell.imgPhoto sd_setImageWithURL:[NSURL URLWithString:business.imageURL]];
    
    INTULocationManager *locMgr = [INTULocationManager sharedInstance];
    if (locMgr.currentLocation) {
        cell.lblDistance.text = [NSString stringWithFormat:@"%.2f miles", [business.geoLocation distanceFromLocation:locMgr.currentLocation] / 1609.34f];
    } else {
        cell.lblDistance.text = @"N/A";
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    BTBusiness *business = _dataSource[indexPath.row];
    
    BTSearchBusinessController *searchController = (BTSearchBusinessController *)self.navigationController;
    if ([searchController.delegate respondsToSelector:@selector(searchBusinessController:didSelectBusiness:)]) {
        [searchController.delegate searchBusinessController:searchController didSelectBusiness:business];
    }
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
