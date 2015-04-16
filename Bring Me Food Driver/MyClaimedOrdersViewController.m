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

- (IBAction)refreshClicked:(id)sender;

@end

@implementation MyClaimedOrdersViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [PFCloud callFunctionInBackground:@"getDriversOrders" withParameters:nil block:^(NSArray *results, NSError *error) {
        if(!error) {
            for(NSString *result in results) {
                NSLog(result);
            }
        }
        else {
            NSLog(error.description);
        }
    }];
    
    // Do any additional setup after loading the view from its nib.
}


- (IBAction)refreshClicked:(id)sender {
    
}
@end
