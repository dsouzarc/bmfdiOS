//
//  ViewOrderDetailsViewController.m
//  Bring Me Food
//
//  Created by Ryan D'souza on 4/2/15.
//  Copyright (c) 2015 Ryan D'souza. All rights reserved.
//

#import "ViewOrderDetailsViewController.h"

@interface ViewOrderDetailsViewController ()

@property (strong, nonatomic) IBOutlet UILabel *currentOrderStatus;
@property (strong, nonatomic) IBOutlet UIButton *updateOrderStatusButton;
@property (strong, nonatomic) IBOutlet UILabel *customerName;
@property (strong, nonatomic) IBOutlet UIButton *customerAddressButton;
@property (strong, nonatomic) IBOutlet UITextView *additionalDetails;
@property (strong, nonatomic) IBOutlet UIButton *customerPhoneButton;
@property (strong, nonatomic) IBOutlet UILabel *customerDeliveryTime;
@property (strong, nonatomic) IBOutlet UILabel *estimatedDeliveryTime;
@property (strong, nonatomic) IBOutlet UIButton *restaurantButton;
@property (strong, nonatomic) IBOutlet UILabel *orderCost;
@property (strong, nonatomic) IBOutlet UITableView *orderItemsTableView;


@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *allUILabels;
@property (nonatomic, strong) ClaimedOrder *order;


- (IBAction)updateOrder:(id)sender;
- (IBAction)showCustomerAddress:(id)sender;
- (IBAction)callCustomer:(id)sender;
- (IBAction)showRestaurant:(id)sender;

@end

@implementation ViewOrderDetailsViewController

static NSString *orderItemIdentifier = @"menuItemCell";

- (instancetype) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil order:(ClaimedOrder*)order
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if(self) {
        self.order = order;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.orderItemsTableView registerNib:[UINib nibWithNibName:@"RestaurantItemTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:orderItemIdentifier];
    self.orderItemsTableView.allowsSelection = NO;
    
    self.currentOrderStatus.text = [NSString stringWithFormat:@"Status: %@", self.order.getOrderStatusAsString];
    self.currentOrderStatus.adjustsFontSizeToFitWidth = YES;
    self.currentOrderStatus.textColor = self.order.getOrderStatusColor;
    
    if(self.order.orderStatus == 4) {
        [self.updateOrderStatusButton setTitle:@"Cannot update status any further" forState:UIControlStateNormal];
        self.updateOrderStatusButton.enabled = NO;
    }
    else {
        [self.updateOrderStatusButton setTitle:[NSString stringWithFormat:@"Update Order Status To: %@", self.order.getNextOrderStatusAsString] forState:UIControlStateNormal];
        self.updateOrderStatusButton.titleLabel.adjustsFontSizeToFitWidth = YES;
    }
    
    self.customerName.text = [NSString stringWithFormat:@"Customer name: %@", self.order.ordererName];
    [self.customerAddressButton setTitle:self.order.deliveryAddressString forState:UIControlStateNormal];

    [self.customerPhoneButton setTitle:[NSString stringWithFormat:@"Customer Phone: %@", self.order.ordererPhoneNumber] forState:UIControlStateNormal];
    
    self.additionalDetails.text = [NSString stringWithFormat:@"Additional Details: %@", self.order.additionalDetails];
    
    self.customerDeliveryTime.text = [NSString stringWithFormat:@"Time To Be Delivered At: %@", [self getNiceDate:self.order.timeToBeDeliveredAt]];
    
    self.estimatedDeliveryTime.text = [NSString stringWithFormat:@"Estimated Delivery Time: %@", [self getNiceDate:self.order.estimatedDeliveryTime]];
    
    [self.restaurantButton setTitle:[NSString stringWithFormat:@"Restaurant: %@", self.order.restaurantName] forState:UIControlStateNormal];

    self.orderCost.text = [NSString stringWithFormat:@"Order Cost: %@", self.order.orderCost];
    
    self.updateOrderStatusButton.titleLabel.adjustsFontSizeToFitWidth = YES;
    self.customerPhoneButton.titleLabel.adjustsFontSizeToFitWidth = YES;
    self.customerDeliveryTime.adjustsFontSizeToFitWidth = YES;
    self.estimatedDeliveryTime.adjustsFontSizeToFitWidth = YES;
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
        [dateFormatter setDateFormat:@"MM/dd"];
        return [NSString stringWithFormat:@"%@ on %@", time, [dateFormatter stringFromDate:date]];
    }
}


/****************************/
//    TABLEVIEW DELEGATES
/****************************/

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    RestaurantItemTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:orderItemIdentifier];
    
    if(!cell) {
        cell = [[RestaurantItemTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                                  reuseIdentifier:orderItemIdentifier];
    }
    
    ChosenMenuItem *item = [self.order.chosenItems objectAtIndex:indexPath.row];
    cell.itemNameAndCost.text = [NSString stringWithFormat:@"%@    $%@", item.itemName, item.itemCost];
    cell.itemNameAndCost.numberOfLines = 1;
    cell.itemNameAndCost.adjustsFontSizeToFitWidth = YES;
    cell.descriptionTextView.text = item.customizedItemDescription;
    
    return cell;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.order.chosenItems.count;
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (IBAction)updateOrder:(id)sender {
    
}

- (IBAction)callCustomer:(id)sender {
    NSURL *callPhone = [NSURL URLWithString:[NSString stringWithFormat:@"telPrompt:%@", self.order.ordererPhoneNumber]];
    
    if([[UIApplication sharedApplication] canOpenURL:callPhone]) {
        [[UIApplication sharedApplication] openURL:callPhone];
    }
    else {
        UIAlertView *errorDialog = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Sorry, but we were unable to open the phone app" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [errorDialog show];
    }
}

- (IBAction)showRestaurant:(id)sender {
    [self openAddressInMaps:self.order.restaurantLocation];
}

- (IBAction)showCustomerAddress:(id)sender {
    [self openAddressInMaps:self.order.deliveryAddress];
}

- (void) openAddressInMaps:(PFGeoPoint*)location
{
    NSURL *openInMaps = [NSURL URLWithString:[NSString stringWithFormat:@"http://maps.apple.com/?q=%f,%f", location.latitude, location.longitude]];
    
    if([[UIApplication sharedApplication] canOpenURL:openInMaps]) {
        [[UIApplication sharedApplication] openURL:openInMaps];
    }
    else {
        UIAlertView *errorDialog = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Sorry, but we were unable to open the phone app" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [errorDialog show];
    }
    
}
@end
