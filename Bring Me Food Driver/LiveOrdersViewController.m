//
//  LiveOrdersViewController.m
//  Bring Me Food Driver
//
//  Created by Ryan D'souza on 3/26/15.
//  Copyright (c) 2015 Ryan D'souza. All rights reserved.
//

#import "LiveOrdersViewController.h"
#import "UnclaimedOrdersTableViewCell.h"
#import <Parse/Parse.h>
#import "ClaimOrderViewController.h"
#import "PQFBouncingBalls.h"

@interface LiveOrdersViewController ()

@property (strong, nonatomic) IBOutlet UITableView *liveOrdersTableView;
@property (strong, nonatomic) UIRefreshControl *refreshControl;

@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) NSMutableArray *unclaimedOrdersArray;
@property (strong, nonatomic) PQFBouncingBalls *loadingAnimation;

@property (strong, nonatomic) ClaimOrderViewController *claimOrderViewController;

@property (strong, nonatomic) PFGeoPoint *currentLocation;

- (IBAction)refreshLiveOrders:(id)sender;

@end

@implementation LiveOrdersViewController

static NSString *cellIdentifier = @"UnclaimedOrdersCell";

- (instancetype) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if(self) {
        self.unclaimedOrdersArray = [[NSMutableArray alloc] init];
        
        self.loadingAnimation = [[PQFBouncingBalls alloc] initLoaderOnView:self.view];
        self.loadingAnimation.loaderColor = [UIColor blueColor];
        
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.delegate = self;
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        //[self.locationManager startUpdatingLocation];
        [self.locationManager startMonitoringSignificantLocationChanges];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    //LOCATION STUFF
    [self.locationManager requestAlwaysAuthorization];
    
    switch ([CLLocationManager authorizationStatus]) {
            
        case kCLAuthorizationStatusAuthorizedAlways:
            NSLog(@"Always");
            break;
            
        case kCLAuthorizationStatusAuthorizedWhenInUse:
            NSLog(@"in use");
            break;
            
        case kCLAuthorizationStatusDenied:
            [self alertViewForLocation];
            NSLog(@"Denied");
            break;
            
        case kCLAuthorizationStatusNotDetermined:
            NSLog(@"not determined");
            break;
            
        case kCLAuthorizationStatusRestricted:
            [self alertViewForLocation];
            break;
            
        default:
            NSLog(@"None");
            break;
    }
    
    //LIVE ORDERS VALUES
    self.edgesForExtendedLayout = UIRectEdgeNone;
    [self.liveOrdersTableView registerNib:[UINib nibWithNibName:@"UnclaimedOrdersTableViewCell"
                                                         bundle:[NSBundle mainBundle]]
                   forCellReuseIdentifier:cellIdentifier];
    [self updateLiveOrders];
    
    //SWIPE TO REFRESH
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(updateLiveOrders) forControlEvents:UIControlEventValueChanged];
    self.refreshControl.tintColor = [UIColor colorWithRed:(254/255.0) green:(153/255.0) blue:(0/255.0) alpha:1];
    self.refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"Fetching Live Orders"];
    
    UITableViewController *tableViewController = [[UITableViewController alloc] init];
    tableViewController.tableView = self.liveOrdersTableView;
    tableViewController.refreshControl = self.refreshControl;
}

/****************************/
//    LOCATION MANAGER DELEGATES
/****************************/

- (void) locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"ERROR GETTING LOCATION: ");
}

- (void) locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    CLLocation *location = [locations lastObject];
    NSDate *eventDate = location.timestamp;
    NSTimeInterval howRecent = [eventDate timeIntervalSinceNow];
    
    if (abs(howRecent) < 15.0) {
        self.currentLocation = [PFGeoPoint geoPointWithLatitude:location.coordinate.latitude longitude:location.coordinate.longitude];
        
        NSDictionary *params = @{@"currentLocation": self.currentLocation};
        
        [PFCloud callFunctionInBackground:@"updateDriverLocation"
                           withParameters:params block:^(NSString *result, NSError *error) {
            NSLog(@"Updated location: %@", result);
        }];
    }
}

/****************************/
//    TABLEVIEW DELEGATES
/****************************/

- (UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UnclaimedOrdersTableViewCell *cell = [self.liveOrdersTableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if(!cell) {
        cell = [[UnclaimedOrdersTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    UnclaimedOrder *order = [self.unclaimedOrdersArray objectAtIndex:indexPath.row];
    
    cell.restaurantName.text = order.restaurantName;
    
    cell.orderedForTime.text = [NSString stringWithFormat:@"Ordered for: %@", [self getNiceDate:order.timeToBeDeliveredAt]];
    cell.deliveryCost.text = [NSString stringWithFormat:@"Cost: %@", order.orderCost];
    cell.deliveryAddress.text = [NSString stringWithFormat:@"Delivery Address: %@", order.deliveryAddressString];
    
    if(!self.currentLocation) {
        cell.drivingDistance.text = @"Calculating the total driving distance...";
    }
    else {
        double distance = [self.currentLocation distanceInMilesTo:order.restaurantGeoPoint] +
        [order.restaurantGeoPoint distanceInMilesTo:order.deliveryAddress];
        NSString *niceDistance = [NSString stringWithFormat:@"%.2f", distance];
        
        cell.drivingDistance.text = [NSString stringWithFormat:@"Approximate total driving distance %@", niceDistance];
    }
    
    cell.restaurantName.adjustsFontSizeToFitWidth = YES;
    cell.orderedForTime.adjustsFontSizeToFitWidth = YES;
    cell.deliveryAddress.adjustsFontSizeToFitWidth = YES;
    cell.drivingDistance.adjustsFontSizeToFitWidth = YES;
    
    return cell;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.unclaimedOrdersArray.count;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 134;
}

- (IBAction)refreshLiveOrders:(id)sender {
    [self updateLiveOrders];
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    //If there is at least 1 order
    if(self.unclaimedOrdersArray && self.unclaimedOrdersArray.count > 0) {
        return 1;
    }
    
    //Otherwise, display no orders
    else {
        UILabel *messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
        messageLabel.text = @"No live orders";
        messageLabel.textColor = [UIColor blackColor];
        messageLabel.numberOfLines = 0;
        messageLabel.textAlignment = NSTextAlignmentCenter;
        self.liveOrdersTableView.backgroundView = messageLabel;
        self.liveOrdersTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    return 0;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UnclaimedOrder *order = [self.unclaimedOrdersArray objectAtIndex:indexPath.row];
    
    self.claimOrderViewController = [[ClaimOrderViewController alloc] initWithNibName:@"ClaimOrderViewController" bundle:[NSBundle mainBundle] order:order myLocation:self.currentLocation];
    
    self.modalPresentationStyle = UIModalPresentationFormSheet;
    //[self.navigationController pushViewController:self.claimOrderViewController animated:YES];
    [self presentViewController:self.claimOrderViewController animated:YES completion:nil];
}

- (NSString*) getNiceDate:(NSDate*)date
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"HH:mm"];
    
    NSString *time = [dateFormatter stringFromDate:date];
    
    //If it is today, just say
    
    if(!date) {
        date = [NSDate date];
    }
    BOOL isToday = [[NSCalendar currentCalendar] isDateInToday:date];
    
    
    if(isToday) {
        return [NSString stringWithFormat:@"Today @ %@", time];
    }
    else {
        [dateFormatter setDateFormat:@"MM/dd"];
        
        return [NSString stringWithFormat:@"%@ on %@", time, [dateFormatter stringFromDate:date]];
    }
}

- (void) showAlert:(NSString*)alertTitle alertMessage:(NSString*)alertMessage buttonName:(NSString*)buttonName {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:alertTitle
                                                        message:alertMessage
                                                       delegate:nil
                                              cancelButtonTitle:buttonName
                                              otherButtonTitles:nil, nil];
    [alertView show];
}

- (void) viewDidAppear:(BOOL)animated
{
    [self updateLiveOrders];
}

- (void) alertViewForLocation
{
    UIAlertView *enableLocation = [[UIAlertView alloc] initWithTitle:@"Location services are off"
                                                             message:@"This app needs your location in the background to autonomously update clients of their order information 20 minutes prior to delivery"
                                                            delegate:self
                                                   cancelButtonTitle:@"Ok"
                                                   otherButtonTitles:@"Settings", nil];
    [enableLocation show];
}

- (void) updateLiveOrders
{
    //Only display the loading animation if we are not swiping to refresh
    if(!self.refreshControl.refreshing) {
        [self.loadingAnimation show];
    }
    
    [PFCloud callFunctionInBackground:@"getUnclaimedOrders" withParameters:nil block:^(NSArray *result, NSError *problem) {
        if(!problem) {
            
            [self.unclaimedOrdersArray removeAllObjects];
            
            for(NSDictionary *unclaimed in result) {
                UnclaimedOrder *order = [[UnclaimedOrder alloc] initWithEverything:unclaimed];
                [self.unclaimedOrdersArray addObject:order];
            }
            
            [self.loadingAnimation hide];
            [self.liveOrdersTableView reloadData];
            
            [PFGeoPoint geoPointForCurrentLocationInBackground:^(PFGeoPoint *geoPoint, NSError *error) {
                [[PFUser currentUser] setObject:geoPoint forKey:@"currentLocation"];
                [[PFUser currentUser] saveInBackground];
                self.currentLocation = geoPoint;
                
                for(int i = 0; i < self.unclaimedOrdersArray.count; i++) {
                    NSIndexPath *path = [NSIndexPath indexPathForRow:i inSection:0];
                    
                    UnclaimedOrdersTableViewCell *cell = [self.liveOrdersTableView cellForRowAtIndexPath:path];
                    UnclaimedOrder *order = [self.unclaimedOrdersArray objectAtIndex:i];
                    
                    double distance = [self.currentLocation distanceInMilesTo:order.restaurantGeoPoint] + [order.restaurantGeoPoint distanceInMilesTo:order.deliveryAddress];
                    NSString *niceDistance = [NSString stringWithFormat:@"%.2f", distance];
                    
                    cell.drivingDistance.text = [NSString stringWithFormat:@"Total driving distance (miles): %@", niceDistance];
                }
                
            }];
        }
        
        else {
            NSLog(@"Problem");
            NSLog(problem.description);
        }
    }];
    
    if(self.refreshControl.refreshing) {
        [self.refreshControl endRefreshing];
    }
}

@end
