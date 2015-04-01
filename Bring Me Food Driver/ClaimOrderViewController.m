//
//  ClaimOrderViewController.m
//  Bring Me Food Driver
//
//  Created by Ryan D'souza on 3/31/15.
//  Copyright (c) 2015 Ryan D'souza. All rights reserved.
//

#import "ClaimOrderViewController.h"

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
- (void)viewDidLoad
{
    self.view.backgroundColor=[[UIColor blackColor] colorWithAlphaComponent:.6];
    self.mainView.layer.cornerRadius = 5;
    self.mainView.layer.shadowOpacity = 0.8;
    self.mainView.layer.shadowOffset = CGSizeMake(0.0f, 0.0f);
    
    self.restaurantName.text = self.order.restaurantName;
    self.dropOffAddressString.text = self.order.deliveryAddressString;
    
    
    [super viewDidLoad];
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

- (IBAction)claimOrderButton:(id)sender {
    
}

@end
