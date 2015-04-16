//
//  ClaimOrderViewController.m
//  Bring Me Food Driver
//
//  Created by Ryan D'souza on 3/31/15.
//  Copyright (c) 2015 Ryan D'souza. All rights reserved.
//

#import "ClaimOrderViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "PQFBouncingBalls.h"

@interface ClaimOrderViewController ()

@property (strong, nonatomic) IBOutlet UIScrollView *mainView;
@property (strong, nonatomic) IBOutlet UILabel *restaurantName;
@property (strong, nonatomic) IBOutlet UILabel *dropOffAddressString;
@property (strong, nonatomic) IBOutlet UILabel *dropOffTime;
@property (strong, nonatomic) IBOutlet UILabel *orderCost;
@property (strong, nonatomic) IBOutlet UILabel *distance;
@property (strong, nonatomic) IBOutlet UIDatePicker *myDeliveryTimeDatePicker;

@property (strong, nonatomic) UnclaimedOrder *order;
@property (strong, nonatomic) PFGeoPoint *myLocation;
@property (strong, nonatomic) PQFBouncingBalls *bouncingballs;

- (IBAction)claimOrderAction:(id)sender;
- (IBAction)cancelClaimingOrder:(id)sender;

@end

@implementation ClaimOrderViewController

- (instancetype) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil order:(UnclaimedOrder *)order myLocation:(PFGeoPoint *)myLocation
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if(self) {
        self.order = order;
        self.myLocation = myLocation;
    }
    
    return self;
}

- (void) showAlert:(NSString*)alertTitle alertMessage:(NSString*)alertMessage buttonName:(NSString*)buttonName {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:alertTitle
                                                        message:alertMessage
                                                       delegate:nil
                                              cancelButtonTitle:buttonName
                                              otherButtonTitles:nil, nil];
    [alertView show];
}

- (void)viewDidLoad
{
    self.bouncingballs = [[PQFBouncingBalls alloc] initLoaderOnView:self.view];
    self.bouncingballs.loaderColor = [UIColor blueColor];
    
    self.restaurantName.text = [NSString stringWithFormat:@"Restaurant: %@", self.order.restaurantName];
    
    self.dropOffAddressString.text = [NSString stringWithFormat:@"Dropoff Loc: %@",self.order.deliveryAddressString];
    
    self.dropOffTime.text = [NSString stringWithFormat:@"Dropoff Time: %@",[self getNiceDate:self.order.timeToBeDeliveredAt]];
    
    self.orderCost.text = [NSString stringWithFormat:@"Order Cost: %@", self.order.orderCost];
    
    NSMutableString *distanceText = [[NSMutableString alloc] init];
    
    [distanceText appendString:@"To Restaurant: "];
    [distanceText appendString:[self getNiceDistance:self.myLocation
                                         secondPoint:self.order.restaurantGeoPoint]];
    
    [distanceText appendString:@" To drop-off: "];
    [distanceText appendString:[self getNiceDistance:self.order.restaurantGeoPoint
                                         secondPoint:self.order.deliveryAddress]];

    self.distance.text = distanceText;
    self.distance.adjustsFontSizeToFitWidth = YES;
    
    self.myDeliveryTimeDatePicker.date = [NSDate date];
    
    self.dropOffAddressString.adjustsFontSizeToFitWidth = YES;
    self.distance.adjustsFontSizeToFitWidth = YES;
    
    [super viewDidLoad];
}

- (NSString*) getNiceDistance:(PFGeoPoint*)firstPoint secondPoint:(PFGeoPoint*)secondPoint
{
    double distance = [firstPoint distanceInMilesTo:secondPoint];
    return [[NSString alloc] initWithFormat:@"%.2f", distance];
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

- (IBAction)claimOrderAction:(id)sender {
    [self.bouncingballs show];
    NSDictionary *parameters = @{@"estimatedDeliveryTime": self.myDeliveryTimeDatePicker.date,
                                 @"orderId": self.order.orderID,
                                 @"driverLocation": self.myLocation};
    
    [PFCloud callFunctionInBackground:@"claimOrder" withParameters:parameters block:^(NSString *response, NSError *error) {
        
        [PFCloud callFunction:@"setDriverLocation"
               withParameters:@{@"currentLocation": self.myLocation}];
        
        [self.bouncingballs hide];
        
        if(!error) {
            NSLog(@"RESULT: %@", response);
            
            if([response isEqualToString:@"CLAIMED"]) {
                [self showAlert:@"Successfully Claimed" alertMessage:@"Your Order was successfully claimed" buttonName:@"Okay"];
            }
            else if([response isEqualToString:@"ALREADY CLAIMED"]) {
                [self showAlert:@"Already Claimed"
                   alertMessage:@"Sorry, this Order was already claimed"
                     buttonName:@"Okay"];
            }
            else {
                [self showAlert:@"Error"
                   alertMessage:@"Sorry, something went wrong while trying to claim your order"
                     buttonName:@"Try again"];
            }
        }
        else {
            [self showAlert:@"Error"
               alertMessage:@"Sorry, something went wrong while trying to claim your order"
                 buttonName:@"Try again"];
        }
        
        [self dismissViewControllerAnimated:YES completion:nil];
    }];
}

- (IBAction)cancelClaimingOrder:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
