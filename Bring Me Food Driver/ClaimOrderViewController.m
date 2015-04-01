//
//  ClaimOrderViewController.m
//  Bring Me Food Driver
//
//  Created by Ryan D'souza on 3/31/15.
//  Copyright (c) 2015 Ryan D'souza. All rights reserved.
//

#import "ClaimOrderViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface ClaimOrderViewController ()

@property (strong, nonatomic) IBOutlet UIScrollView *mainView;
@property (strong, nonatomic) IBOutlet UILabel *restaurantName;
@property (strong, nonatomic) IBOutlet UILabel *dropOffAddressString;
@property (strong, nonatomic) IBOutlet UILabel *dropOffTime;
@property (strong, nonatomic) IBOutlet UILabel *orderCost;
@property (strong, nonatomic) IBOutlet UILabel *distance;
@property (strong, nonatomic) IBOutlet UIDatePicker *myDeliveryTimeDatePicker;

@property (strong, nonatomic) Order *order;
@property (strong, nonatomic) PFGeoPoint *myLocation;

- (IBAction)claimOrderButton:(id)sender;

@end

@implementation ClaimOrderViewController

- (instancetype) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil order:(Order *)order myLocation:(PFGeoPoint *)myLocation
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if(self) {
        self.order = order;
        self.myLocation = myLocation;
    }
    
    return self;
}

- (IBAction)claimOrderButton:(id)sender {
    
}

- (void)setRoundedBorder:(float) radius borderWidth:(float)borderWidth color:(UIColor*)color
{
    CALayer * l = self.view.layer;
    [l setMasksToBounds:YES];
    [l setCornerRadius:radius];
    [l setBorderWidth:borderWidth];
    [l setBorderColor:[color CGColor]];
}

- (void)viewDidLoad
{
    self.view.backgroundColor = [UIColor clearColor];
    self.view.opaque = YES;
    self.mainView.layer.cornerRadius=8.0f;
    self.mainView.layer.masksToBounds=YES;
    self.mainView.layer.borderColor=[[UIColor blueColor]CGColor];
    self.mainView.layer.borderWidth= 2.0f;
    
    self.restaurantName.text = self.order.restaurantName;
    self.dropOffAddressString.text = self.order.deliveryAddressString;
    self.dropOffTime.text = [self getNiceDate:self.order.timeToBeDeliveredAt];
    self.orderCost.text = self.order.orderCost;
    
    NSMutableString *distanceText = [[NSMutableString alloc] init];
    [distanceText appendString:@"To Restaurant: "];
    [distanceText appendString:[self getNiceDistance:self.myLocation secondPoint:self.order.restaurantGeoPoint]];
    [distanceText appendString:@" To drop-off: "];
    [distanceText appendString:[self getNiceDistance:self.order.restaurantGeoPoint secondPoint:self.order.deliveryAddress]];

    self.distance.text = distanceText;
    self.distance.adjustsFontSizeToFitWidth = YES;
    
    self.myDeliveryTimeDatePicker.date = [NSDate date];
    
    [super viewDidLoad];
}

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self removeAnimate];
}

- (void) showAnimate
{
    self.view.transform = CGAffineTransformMakeScale(1.3, 1.3);
    self.view.alpha = 0;
    
    [UIView animateWithDuration:0.25 animations:^(void) {
        self.view.alpha = 1;
        self.view.transform = CGAffineTransformMakeScale(1, 1);
    }];
}

- (void) removeAnimate
{
    [UIView animateWithDuration:0.25 animations:^(void) {
        self.view.transform = CGAffineTransformMakeScale(1.3, 1.3);
        self.view.alpha = 0;
    } completion:^(BOOL finished) {
        if(finished) {
            [self.view removeFromSuperview];
        }
    }];
}

- (void) showInView:(UIView *)view shouldAnimate:(BOOL)shouldAnimate
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [view addSubview:self.view];
        
        if(shouldAnimate) {
            [self showAnimate];
        }
    });
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

@end
