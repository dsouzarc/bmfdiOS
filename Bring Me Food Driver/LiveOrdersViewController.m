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
#import "Order.h"

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
        [self.locationManager startUpdatingLocation];
    }
    return self;
}

- (UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UnclaimedOrdersTableViewCell *cell = [self.liveOrdersTableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if(!cell) {
        cell = [[UnclaimedOrdersTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    Order *order = [self.unclaimedOrdersArray objectAtIndex:indexPath.row];
    
    cell.restaurantName.text = order.restaurantName;
    
    cell.orderedForTime.text = [NSString stringWithFormat:@"Ordered for: %@", [self getNiceDate:order.timeToBeDeliveredAt]];
    cell.deliveryCost.text = [NSString stringWithFormat:@"Cost: %@", order.orderCost];
    
    if(!self.currentLocation) {
        cell.drivingDistance.text = order.deliveryAddressString;
    }
    else {
        double distance = [self.currentLocation distanceInMilesTo:order.restaurantGeoPoint] + [order.restaurantGeoPoint distanceInMilesTo:order.deliveryAddress];
        NSString *niceDistance = [NSString stringWithFormat:@"%.2f", distance];
        
        cell.drivingDistance.text = [NSString stringWithFormat:@"%@ Total distance to %@", niceDistance, order.deliveryAddressString];
    }
    return cell;
}

- (void) locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"ERROR GETTING LOCATION: ");
}

- (NSString*) getNiceDate:(NSDate*)date
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"HH:mm"];
    
    NSString *time = [dateFormatter stringFromDate:date];
    
    //If it is today, just say
    BOOL isToday = [[NSCalendar currentCalendar] isDateInToday:date];
    
    
    if(isToday) {
        return [NSString stringWithFormat:@"Today @: %@", time];
    }
    else {
        [dateFormatter setDateFormat:@"dd/MM"];
        
        return [NSString stringWithFormat:@"%@ on %@", time, [dateFormatter stringFromDate:date]];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //LOCATION STUFF
    [self.locationManager requestAlwaysAuthorization];
    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
    if (status == kCLAuthorizationStatusAuthorizedWhenInUse || status == kCLAuthorizationStatusDenied || status == kCLAuthorizationStatusRestricted) {
        NSString *title = (status == kCLAuthorizationStatusDenied) ? @"Location services are off" : @"Background location is not enabled";
        NSString *message = @"To use background location you must turn on 'Always' in the Location Services Settings";
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title
                                                            message:message
                                                           delegate:self
                                                  cancelButtonTitle:@"Cancel"
                                                  otherButtonTitles:@"Settings", nil];
        [alertView show];
    }
    else if (status == kCLAuthorizationStatusNotDetermined) {
        [self.locationManager requestAlwaysAuthorization];
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

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Order *order = [self.unclaimedOrdersArray objectAtIndex:indexPath.row];
    
    self.claimOrderViewController = [[ClaimOrderViewController alloc] initWithNibName:@"ClaimOrderViewController" bundle:[NSBundle mainBundle] order:order myLocation:self.currentLocation];
    
    [self.claimOrderViewController showInView:self.view shouldAnimate:YES];
    
}

- (void) viewDidAppear:(BOOL)animated
{
    [self updateLiveOrders];
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
                Order *order = [[Order alloc] initUsingDictionary:unclaimed];
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
                    Order *order = [self.unclaimedOrdersArray objectAtIndex:i];
                    double distance = [self.currentLocation distanceInMilesTo:order.restaurantGeoPoint] + [order.restaurantGeoPoint distanceInMilesTo:order.deliveryAddress];
                    NSString *niceDistance = [NSString stringWithFormat:@"%.2f", distance];
                    
                    cell.drivingDistance.text = [NSString stringWithFormat:@"%@ Total distance to %@", niceDistance, order.deliveryAddressString];
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

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.unclaimedOrdersArray.count;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 102;
}

- (IBAction)refreshLiveOrders:(id)sender {
    [self updateLiveOrders];
}

@end
