//
//  MyClaimedOrdersViewController.m
//  Bring Me Food Driver
//
//  Created by Ryan D'souza on 3/26/15.
//  Copyright (c) 2015 Ryan D'souza. All rights reserved.
//

#import "MyClaimedOrdersViewController.h"

@interface MyClaimedOrdersViewController ()

@property (strong, nonatomic) IBOutlet UITableView *claimedOrdersTableView;
@property (strong, nonatomic) ViewOrderDetailsViewController *orderDetails;
@property (strong, nonatomic) UILabel *noClaimedOrders;

@property (strong, nonatomic) NSArray *claimedOrders;
@property (strong, nonatomic) PQFBarsInCircle *barsInCircleLoadingAnimation;

@property (strong, nonatomic) UIRefreshControl *refreshControl;

- (IBAction)refreshClicked:(id)sender;

@end

@implementation MyClaimedOrdersViewController

- (instancetype) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if(self) {
        self.barsInCircleLoadingAnimation = [[PQFBarsInCircle alloc] initLoaderOnView:self.view];
        self.barsInCircleLoadingAnimation.loaderColor = [UIColor blueColor];
        self.barsInCircleLoadingAnimation.numberOfBars = 6;
        
        self.claimedOrders = [[NSArray alloc] init];
    }
    
    return self;
}

- (void) viewDidAppear:(BOOL)animated
{
    [self updateClaimedOrders];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(updateClaimedOrders) forControlEvents:UIControlEventValueChanged];
    self.refreshControl.tintColor = [UIColor colorWithRed:(254/255.0) green:(153/255.0) blue:(0/255.0) alpha:1];
    self.refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"Fetching your current orders"];
    
    UITableViewController *viewController = [[UITableViewController alloc] init];
    viewController.tableView = self.claimedOrdersTableView;
    viewController.refreshControl = self.refreshControl;
    
    [self.claimedOrdersTableView registerNib:[UINib nibWithNibName:@"ClaimedOrderTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:cellIdentifier];
    [self updateClaimedOrders];
}

- (IBAction)refreshClicked:(id)sender {
    [self updateClaimedOrders];
}

- (void) updateClaimedOrders
{
    if(!self.refreshControl.isRefreshing) {
        [self.barsInCircleLoadingAnimation show];
    }
    
    [PFCloud callFunctionInBackground:@"getDriversOrders" withParameters:nil block:^(NSArray *results, NSError *error) {
        
        if(!error) {
            NSMutableArray *myOrders = [[NSMutableArray alloc] initWithCapacity:results.count];
            
            for(NSDictionary *order in results) {
                ClaimedOrder *claimedOrder = [[ClaimedOrder alloc] initWithEverything:order];
                [myOrders addObject:claimedOrder];
            }
            
            self.claimedOrders = [NSArray arrayWithArray:myOrders];
            [self.claimedOrdersTableView reloadData];
        }
        
        [self.barsInCircleLoadingAnimation hide];
        [self.refreshControl endRefreshing];
    }];
}


/****************************/
//    TABLEVIEW DELEGATES
/****************************/

static NSString *cellIdentifier = @"ClaimedOrderTableViewCell";

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.orderDetails = [[ViewOrderDetailsViewController alloc] initWithNibName:@"ViewOrderDetailsViewController" bundle:[NSBundle mainBundle] order:self.claimedOrders[indexPath.row]];
    
    [self setModalPresentationStyle:UIModalPresentationFormSheet];
    [self presentViewController:self.orderDetails animated:YES completion:nil];
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ClaimedOrderTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if(!cell) {
        cell = [[ClaimedOrderTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    ClaimedOrder *order = self.claimedOrders[indexPath.row];
    
    cell.orderStatus.text = [order getOrderStatusAsString];
    cell.orderStatus.textColor = [order getOrderStatusColor];
    
    cell.deliveryAddress.text = order.deliveryAddressString;
    cell.restaurantName.text = order.restaurantName;
    cell.timeToBeDeliveredAt.text = [self getNiceDate:order.timeToBeDeliveredAt];
    
    return cell;
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    if(self.claimedOrders.count > 0) {
        self.noClaimedOrders.text = @"";
        self.noClaimedOrders = nil;
        self.claimedOrdersTableView.backgroundView = nil;
        self.claimedOrdersTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        return 1;
    }
    
    else {
        self.noClaimedOrders = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
        
        self.noClaimedOrders.text = @"No claimed orders";
        self.noClaimedOrders.textColor = [UIColor blackColor];
        self.noClaimedOrders.textAlignment = NSTextAlignmentCenter;
        
        self.claimedOrdersTableView.backgroundView = self.noClaimedOrders;
        self.claimedOrdersTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    
    return 0;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.claimedOrders.count;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 136;
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
        [dateFormatter setDateFormat:@"dd/MM"];
        
        return [NSString stringWithFormat:@"%@ on %@", time, [dateFormatter stringFromDate:date]];
    }
}

@end
