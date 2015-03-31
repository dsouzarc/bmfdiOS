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
#import "PQFBouncingBalls.h"
#import "Order.h"

@interface LiveOrdersViewController ()

@property (strong, nonatomic) IBOutlet UITableView *liveOrdersTableView;

@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) NSMutableArray *unclaimedOrdersArray;
@property (strong, nonatomic) PQFBouncingBalls *loadingAnimation;

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
        double distance = [self.currentLocation distanceInMilesTo:order.deliveryAddress];
        NSString *niceDistance = [NSString stringWithFormat:@"%.2f", distance];
        
        cell.drivingDistance.text = [NSString stringWithFormat:@"%@ miles from %@", niceDistance, order.deliveryAddressString];
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
    [self.locationManager requestAlwaysAuthorization];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    [self.liveOrdersTableView registerNib:[UINib nibWithNibName:@"UnclaimedOrdersTableViewCell"
                                                         bundle:[NSBundle mainBundle]]
                   forCellReuseIdentifier:cellIdentifier];
    [self updateLiveOrders];
    
    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
    if (status == kCLAuthorizationStatusAuthorizedWhenInUse || status == kCLAuthorizationStatusDenied || status == kCLAuthorizationStatusRestricted) {
        NSString *title;
        title = (status == kCLAuthorizationStatusDenied) ? @"Location services are off" : @"Background location is not enabled";
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
}

- (void) updateLiveOrders
{
    [self.loadingAnimation show];
    
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
                    double distance = [geoPoint distanceInMilesTo:order.deliveryAddress];
                    
                    NSString *result = [NSString stringWithFormat:@"%.2f", distance];
                    
                    cell.drivingDistance.text = [NSString stringWithFormat:@"%@ miles away from %@", result, order.deliveryAddressString];
                }
                
            }];
        }
        
        else {
            NSLog(@"Problem");
            NSLog(problem.description);
        }
    }];
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
