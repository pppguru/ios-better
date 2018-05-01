//
//  BTSearchMainVC.m
//  BetterIt
//
//  Created by devMac on 09/02/15.
//  Copyright (c) 2015 Maikel. All rights reserved.
//

#import "BTSearchMainVC.h"
#import "BTSearchBusinessController.h"
#import "Common.h"
#import "SPGooglePlacesAutocomplete.h"
#import "BTRestClient.h"
#import "BTModel.h"
#import "AppDelegate.h"
#import "BTSearchBusinessTVC.h"
#import "MKSearchBar.h"
#import "BTRestClient.h"
#import <FTGooglePlacesAPI.h>
#import <UIImageView+WebCache.h>
#import <CCBottomRefreshControl/UIScrollView+BottomRefreshControl.h>
#import "INTULocationManager+CurrentLocation.h"
#import <Google/Analytics.h>
#import <MBProgressHUD.h>

NSString * const kSearchLocationType = @"type";
NSString * const kSearchLocationName = @"name";
NSString * const kSearchLocationPlaceId = @"place_id";
NSString * const kSearchLocationGeoCode = @"geo_code";

#define SEARCH_LOCATION_TYPE_CURRENT @"type_current_location"
#define SEARCH_LOCATION_TYPE_OTHER @"type_other_location"
#define SEARCH_LOCATION_NAME_CURRENT @"Current Location"

#define SEARCH_LOCATION_Y_CONSTRAINT_SHOW 999.f
#define SEARCH_LOCATION_Y_CONSTRAINT_HIDE 750.f


@interface BTSearchMainVC () <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, UITextFieldDelegate>
@property (weak, nonatomic) BTSearchBusinessController *searchController;

@property (weak, nonatomic) IBOutlet UIButton *btnRecentPlaces;
@property (strong, nonatomic) IBOutlet UILabel *lblLocationName;

@property (weak, nonatomic) IBOutlet UISearchBar *businessSearchBar;
@property (strong, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *searchLocationViewTop_Y;
@property (strong, nonatomic) IBOutlet MKSearchBar *locationSearchBar;
@property (strong, nonatomic) IBOutlet UITableView *locationTableView;

@property (strong, nonatomic) NSArray *locationsDataSource;
@property (strong, nonatomic) NSArray *businessesDataSource;
@property (strong, nonatomic) NSArray *unregisteredBusinesses;  // places from Google Place Search API
@property (strong, nonatomic) NSArray *registeredBusinesses;    // places from Backend Database
@property (strong, nonatomic) BTBusiness *brand;

@property (strong, nonatomic) NSMutableDictionary *searchLocation;
@property (strong, nonatomic) UIRefreshControl *refreshControl;
@property (strong, nonatomic) NSString *nextPageToken;

@property (strong, nonatomic) NSMutableDictionary *unclaimedCounts;
@end




@implementation BTSearchMainVC {
    UIImage *placeholderImage;
    BOOL isLoading;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardFrameChanged:) name:UIKeyboardDidChangeFrameNotification object:nil];
    
    _refreshControl = [[UIRefreshControl alloc] init];
    _refreshControl.triggerVerticalOffset = 100.f;
    [_refreshControl addTarget:self action:@selector(loadMoreResults) forControlEvents:UIControlEventValueChanged];
    _tableView.bottomRefreshControl = _refreshControl;
    
    _searchController = (BTSearchBusinessController *)self.navigationController;
    _btnRecentPlaces.hidden = !_searchController.shouldShowRecentPlaces;
    
    placeholderImage = [UIImage imageNamed:@"nav_biz"];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"BTSearchBusinessTVC" bundle:nil]
         forCellReuseIdentifier:@"tvcSearchBusiness"];
    self.tableView.rowHeight = 70.f;
    self.locationTableView.rowHeight = 54.f;
    
    [self showHUD];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self refreshBusinessesTableView];
    });
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:NSStringFromClass([self class])];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    self.tableView.separatorInset = self.locationTableView.separatorInset = UIEdgeInsetsZero;
    if ([self.tableView respondsToSelector:@selector(setLayoutMargins:)]) {
        self.tableView.layoutMargins = self.locationTableView.layoutMargins = UIEdgeInsetsZero;
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];


}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Actions

- (IBAction)cancelAction:(id)sender {
    BTSearchBusinessController *searchController = (BTSearchBusinessController *)self.navigationController;
    if ([searchController.delegate respondsToSelector:@selector(searchBusinessControllerDidCancel:)]) {
        [searchController.delegate searchBusinessControllerDidCancel:searchController];
    }
    
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)changeLocationAction:(id)sender {
    [self showSearchLocationView:YES];
}

- (IBAction)currentLocationAction:(id)sender {
    if ([INTULocationManager sharedInstance].currentLocation || appDelegate.IPLocation) {
        self.searchLocation = @{kSearchLocationType : SEARCH_LOCATION_TYPE_CURRENT,
                                kSearchLocationName : SEARCH_LOCATION_NAME_CURRENT,
                                kSearchLocationGeoCode : [INTULocationManager sharedInstance].currentLocation ? [INTULocationManager sharedInstance].currentLocation : appDelegate.IPLocation
                                }.mutableCopy;
        
        _businessSearchBar.text = @"";
        [self refreshBusinessesTableView];
    }
    
    _lblLocationName.text = SEARCH_LOCATION_NAME_CURRENT;
    
    [self showSearchLocationView:NO];
}

- (void)loadMoreResults
{
    if (isLoading || !_nextPageToken) {
        [_refreshControl endRefreshing];
        return;
    }
    
    isLoading = YES;
    [Model fetchBusinessesWithLocation:[self currentSearchLocation]
                             pageToken:_nextPageToken
                                   key:nil
                       completionBlock:^(bool completed, NSString *key, NSArray *results, NSString *nextPageToken) {
                           if (!isLoading) {
                               return;
                           }
                           
                           isLoading = NO;
                           [_refreshControl endRefreshing];
                           
                           _unregisteredBusinesses = [_unregisteredBusinesses arrayByAddingObjectsFromArray:results];
                           _nextPageToken = nextPageToken;
                           
                           [self buildBusinessesDataSource];
                           
                           [self.tableView reloadData];
                           
                           dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                               self.tableView.bottomRefreshControl = (nextPageToken != nil) ? _refreshControl : nil;
                           });
                       }];
}


#pragma mark - Search Bar

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    [self refreshBusinessesTableView];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    textField.text = [textField.text stringByReplacingCharactersInRange:range withString:string];
    [self refreshLocationsTableView];
    
    return NO;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    
    return NO;
}




#pragma mark - Table View
#pragma mark Data Source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return (![tableView isEqual:_locationTableView] && _brand) ? 2 : 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([tableView isEqual:_locationTableView]) {
        return _locationsDataSource.count;

    } else {
        if (_brand && section == 0) {
            return 1;
        } else {
            return _businessesDataSource.count;
        }
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([tableView isEqual:_locationTableView]) {
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"tvcLocation"];
        
        UILabel *lblLocation = (UILabel *)[cell viewWithTag:1];
        
        lblLocation.text = ((SPGooglePlacesAutocompletePlace *)_locationsDataSource[indexPath.row]).name;
        
        return cell;
        
    } else if ([tableView isEqual:_tableView]) {
        
        BTSearchBusinessTVC *cell = [tableView dequeueReusableCellWithIdentifier:@"tvcSearchBusiness"];
        BTBusiness *business = (_brand && indexPath.section == 0) ? _brand : _businessesDataSource[indexPath.row];

        [cell.imgPhoto sd_setImageWithURL:[NSURL URLWithString:business.imageURL]
                         placeholderImage:placeholderImage];
        cell.lblBusinessName.text = business.name;
        
        if (business.type == BTBusinessTypeBrand) {
            cell.lblAddress.text = @"Corporate Brand";
            cell.lblDistance.text = @"";
            cell.backgroundColor = DEFAULT_LIGHT_GOLD_COLOR;
            
        } else {
            cell.lblAddress.text = business.address;
            
            CGFloat distance = [business.geoLocation distanceFromLocation:[self currentSearchLocation]];
            if (distance > METER_FOR_MILE / 10) {
                cell.lblDistance.text = [NSString stringWithFormat:@"%.2f mi", distance / METER_FOR_MILE];
            } else {
                cell.lblDistance.text = [NSString stringWithFormat:@"%d ft", (int)(distance / 3.28084f)];
            }
            
            if (_searchController.shouldShowBetterIts &&
                [_unclaimedCounts[business.googlePlaceId] isKindOfClass:[NSNumber class]] &&
                [_unclaimedCounts[business.googlePlaceId] integerValue]) {
                cell.lblUnclaimed.hidden = NO;
                cell.imgAppTile.hidden = NO;
                cell.lblUnclaimed.text = [_unclaimedCounts[business.googlePlaceId] stringValue];
                cell.lblBusinessName_Right.constant = 70.f;
            } else {
                cell.lblUnclaimed.hidden = YES;
                cell.imgAppTile.hidden = YES;
                cell.lblBusinessName_Right.constant = 12.f;
            }
            cell.backgroundColor = [UIColor whiteColor];
            
            [cell layoutIfNeeded];
        }
        
        return cell;
    }
    
    return nil;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if ([tableView isEqual:_tableView] && _brand) {
        UILabel *titleLabel = [[UILabel alloc] init];
        titleLabel.font = [UIFont systemFontOfSize:18.f];
        titleLabel.backgroundColor = RGB(221.f, 221.f, 221.f);
        if (section == 0) {
            titleLabel.text = @"Brands";
        } else {
            titleLabel.text = @"Locations";
        }
        
        return titleLabel;
    }
    
    return nil;
}

#pragma mark Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if ([tableView isEqual:_locationTableView]) {
        
        SPGooglePlacesAutocompletePlace *selectedPlace = (SPGooglePlacesAutocompletePlace *)_locationsDataSource[indexPath.row];
        self.searchLocation = @{kSearchLocationType : SEARCH_LOCATION_TYPE_OTHER,
                                kSearchLocationName : selectedPlace.name,
                                kSearchLocationPlaceId : selectedPlace.dict[@"place_id"]}.mutableCopy;
        
        _lblLocationName.text = selectedPlace.name;
        
//        _businessSearchBar.text = @"";
        _businessesDataSource = nil;
        [_tableView reloadData];
        
        CLGeocoder *geoCoder = [[CLGeocoder alloc] init];
        [geoCoder geocodeAddressString:selectedPlace.name completionHandler:^(NSArray *placemarks, NSError *error) {
            if (!error) {
                CLPlacemark *placemark = placemarks.firstObject;
                self.searchLocation = [NSMutableDictionary dictionaryWithObjectsAndKeys:placemark.location, kSearchLocationGeoCode, nil];
                [self refreshBusinessesTableView];
                
            } else {
                //NSLog(@"Error while geocoding address %@\nError - %@", selectedPlace.name, error);
            }
        }];
        
        [self showSearchLocationView:NO];
        
    } else if ([tableView isEqual:_tableView]) {
        [self.view endEditing:YES];
        
        BTBusiness *selectedBusiness = (_brand && indexPath.section == 0) ? _brand : _businessesDataSource[indexPath.row];
        BTSearchBusinessController *searchController = (BTSearchBusinessController *)self.navigationController;
        
        if ([searchController.delegate respondsToSelector:@selector(searchBusinessController:didSelectBusiness:)]) {
            // business is selected, but not yet registered in the back-end
            if (selectedBusiness.objectId == 0) {

                [self showHUD];
                // register selected business
                [RestClient registerBusinessWithPlaceId:selectedBusiness.googlePlaceId Completion:^(BOOL success, NSString *code, id response) {
                    
                    [self hideHUD];
                    
                    if (success) {
                        BTBusiness *business = [BTBusiness objectWithJSONDictionary:response[@"business"]];
                        business.photoReference = selectedBusiness.photoReference;
                        
                        [searchController.delegate searchBusinessController:searchController
                                                          didSelectBusiness:business];
                    } else {
                        [[[UIAlertView alloc] initWithTitle:@"We're having trouble loading that, please try again" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
                    }
                }];
            } else {
                [searchController.delegate searchBusinessController:searchController didSelectBusiness:selectedBusiness];
            }
        }
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        cell.layoutMargins = UIEdgeInsetsZero;
    }
}


#pragma mark - Location Search

- (void)refreshLocationsTableView {
    SPGooglePlacesAutocompleteQuery *query = [[SPGooglePlacesAutocompleteQuery alloc] initWithApiKey:kGooglePlacesAPIKey];
    query.input = _locationSearchBar.text;
    query.types = SPPlaceTypeGeocode; // Only return region results.
    
    [query fetchPlaces:^(NSArray *places, NSError *error) {
        _locationsDataSource = places;
        
        [self.locationTableView reloadData];
    }];
}



#pragma mark - Business Search

- (void)refreshBusinessesTableView {
    isLoading = YES;
    _nextPageToken = nil;

    [Model fetchBusinessesWithLocation:[self currentSearchLocation]
                             pageToken:nil
                                   key:_businessSearchBar.text
                       completionBlock:^(bool completed, NSString *key, NSArray *results, NSString *nextPageToken) {
                           if (completed) {
                               isLoading = NO;
                           }
                           
                           [self hideHUD];

                           if ([_businessSearchBar.text isEqualToString:key]) {
                               _nextPageToken = nextPageToken;
                               
                               _unregisteredBusinesses = results;
                               [self buildBusinessesDataSource];
                   
                               [self.tableView reloadData];
                               
                               dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                                   self.tableView.bottomRefreshControl = (nextPageToken != nil) ? _refreshControl : nil;
                               });
                           } else {
                               //NSLog(@"Text changed... Aborting...");
                           }
                       }];

    if (_businessSearchBar.text.length >= 3) {
        [RestClient getBrandWithSearchTerm:_businessSearchBar.text Completion:^(BOOL success, NSString *code, id response) {
            if (success) {
                BTBusiness *brand = [BTBusiness objectWithJSONDictionary:response[@"brand"]];
                if (!brand) {
                    _brand = nil;
                } else if ([brand.name.lowercaseString containsString:_businessSearchBar.text.lowercaseString]) {
                    _brand = brand;
                }
                [self.tableView reloadData];
            }
        }];
    } else {
        _brand = nil;
        [self.tableView reloadData];
    }

//    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(refreshRegisteredBusinesses:) object:nil];
//    [self performSelector:@selector(refreshRegisteredBusinesses:) withObject:_businessSearchBar.text afterDelay:3.f];
}

- (void)refreshRegisteredBusinesses:(NSString *)searchKey {
    if (searchKey && ![searchKey isEqualToString:@""]) {
        CLLocation *currentLocation = [self currentSearchLocation];
        
        [RestClient getRegisteredBusinessesWithSearchTerm:searchKey
                                             NearLocation:@{@"latitude" : @(currentLocation.coordinate.latitude),
                                                            @"longitude" : @(currentLocation.coordinate.longitude)}
                                                   WithIn:@(4000)
                                               Completion:^(BOOL success, NSString *code, id response) {
                                                   _registeredBusinesses = [BTBusiness objectsWithJSONArray:response[@"businesses"]];
                                                   [self buildBusinessesDataSource];
                                                   
                                                   [_tableView reloadData];
                                               }];
    } else {
        _registeredBusinesses = nil;
        
        [self buildBusinessesDataSource];
        [_tableView reloadData];
    }
}



#pragma mark - Misc

- (void)keyboardFrameChanged:(NSNotification *)aNotification {
    CGFloat kbStartY = [aNotification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue].origin.y;
    
    UIEdgeInsets tableViewInsets = UIEdgeInsetsMake(0.f, 0.f, self.view.bounds.size.height - kbStartY, 0.f);
    [_tableView setContentInset:tableViewInsets];
    [_tableView setScrollIndicatorInsets:tableViewInsets];
}

// merge registered & unregistered businesses
- (void)buildBusinessesDataSource {
    NSMutableArray *registeredPlaceIds = [NSMutableArray array];
    
    // build registered place ids array
    for (BTBusiness *registeredBusiness in _registeredBusinesses) {
        [registeredPlaceIds addObject:registeredBusiness.googlePlaceId];
    }
    
    // filter out places from unregisteredBusinesses that are in registeredBusinesses
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"NOT (googlePlaceId IN %@)", registeredPlaceIds];
    _businessesDataSource = [_unregisteredBusinesses filteredArrayUsingPredicate:predicate];
    
    if (!_businessesDataSource) {
        _businessesDataSource = [NSArray array];
    }
    
    // add registered businesses
    _businessesDataSource = [_businessesDataSource arrayByAddingObjectsFromArray:_registeredBusinesses];
    
    // sort by distance
    CLLocation *currentLocation = [self currentSearchLocation];
    
    _businessesDataSource = [BTModel arraySortedByDistance:_businessesDataSource fromLocation:currentLocation];
    //[BTModel arraySortedByRelevance:_businessesDataSource forSearchKey:_businessSearchBar.text fromLocation:currentLocation];
    
    if (_searchController.shouldShowBetterIts) {
        [self startLoadingBetterIts];
    }
}


- (void)showSearchLocationView:(BOOL)show {
    self.businessSearchBar.userInteractionEnabled = !show;
    
    // hide keyboard first
    [self.view endEditing:YES];
    
    [self.view layoutIfNeeded];
    [UIView animateWithDuration:.2f animations:^{
        _searchLocationViewTop_Y.priority = show ? SEARCH_LOCATION_Y_CONSTRAINT_SHOW : SEARCH_LOCATION_Y_CONSTRAINT_HIDE;
        [self.view layoutIfNeeded];
    }];
}

- (void)setSearchLocation:(NSMutableDictionary *)searchLocation {
    if (!_searchLocation) {
        _searchLocation = [NSMutableDictionary new];
    }

    [_searchLocation addEntriesFromDictionary:searchLocation];
}

- (CLLocation *)currentSearchLocation {
    CLLocation *currentLocation;
    
    if ([SEARCH_LOCATION_TYPE_OTHER isEqualToString:self.searchLocation[kSearchLocationType]]) {
        currentLocation = self.searchLocation[kSearchLocationGeoCode];
    }
    
    if (!currentLocation) {
        currentLocation = [INTULocationManager sharedInstance].currentLocation;
    }
    
    if (!currentLocation) {
        currentLocation = appDelegate.IPLocation;
    }
    
    return currentLocation;
}

- (void)startLoadingBetterIts {
    if (!_unclaimedCounts) {
        _unclaimedCounts = [NSMutableDictionary dictionary];
    }

    for (BTBusiness *business in _businessesDataSource) {
        if (!_unclaimedCounts[business.googlePlaceId]) {
            AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
            manager.responseSerializer = [AFJSONResponseSerializer serializer];
            manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/html", nil];
            
            AFHTTPRequestOperation *operation = [manager GET:[API_BASE_URL stringByAppendingPathComponent:@"/api/business/unclaimed"] parameters:@{@"place_id" : business.googlePlaceId} success:^(AFHTTPRequestOperation *operation, id responseObject) {
                
                if ([responseObject[@"code"] isEqualToString:@""]) {
                    NSNumber *unclaimed = responseObject[@"business"][@"unclaimed"];
                    [_unclaimedCounts setObject:unclaimed forKey:business.googlePlaceId];
                    
                    [self.tableView reloadData];
                } else {
                    [_unclaimedCounts removeObjectForKey:business.googlePlaceId];
                }
                
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                [_unclaimedCounts removeObjectForKey:business.googlePlaceId];
            }];

            [_unclaimedCounts setObject:operation forKey:business.googlePlaceId];
        }
    }
}

- (void)showHUD {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.color = [UIColor clearColor];
    hud.activityIndicatorColor = [UIColor darkGrayColor];
}

- (void)hideHUD {
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
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
