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

@property (strong, nonatomic) NSMutableArray *unclaimedOrdersArray;
@property (strong, nonatomic) PQFBouncingBalls *loadingAnimation;
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
    cell.drivingDistance.text = order.deliveryAddressString;
    
    return cell;
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
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    [self.liveOrdersTableView registerNib:[UINib nibWithNibName:@"UnclaimedOrdersTableViewCell"
                                                         bundle:[NSBundle mainBundle]]
                   forCellReuseIdentifier:cellIdentifier];
    [self updateLiveOrders];
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
                NSLog(@"DELIVER ADDRESS: %@", order.deliveryAddressString);
            }
            
            [self.loadingAnimation hide];
            [self.liveOrdersTableView reloadData];
            
            NSLog(@"DONE %ld", (long)self.unclaimedOrdersArray.count);
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
