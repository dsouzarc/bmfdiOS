//
//  LiveOrdersViewController.m
//  Bring Me Food Driver
//
//  Created by Ryan D'souza on 3/26/15.
//  Copyright (c) 2015 Ryan D'souza. All rights reserved.
//

#import "LiveOrdersViewController.h"
#import "UnclaimedOrdersTableViewCell.h"

@interface LiveOrdersViewController ()

@property (strong, nonatomic) IBOutlet UITableView *liveOrdersTableView;
@property (strong, nonatomic) NSMutableArray *unclaimedOrdersArray;

- (IBAction)refreshLiveOrders:(id)sender;

@end

@implementation LiveOrdersViewController

static NSString *cellIdentifier = @"UnclaimedOrdersCell";

- (instancetype) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if(self) {
        self.unclaimedOrdersArray = [[NSMutableArray alloc] init];
    }
    return self;
}

- (UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UnclaimedOrdersTableViewCell *cell = [self.liveOrdersTableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if(!cell) {
        cell = [[UnclaimedOrdersTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    return cell;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.liveOrdersTableView registerNib:[UINib nibWithNibName:@"UnclaimedOrdersTableViewCell"
                                                         bundle:[NSBundle mainBundle]]
                   forCellReuseIdentifier:cellIdentifier];
    [self updateLiveOrders];
}

- (void) updateLiveOrders
{
    
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.unclaimedOrdersArray.count;
}

- (IBAction)refreshLiveOrders:(id)sender {
    [self updateLiveOrders];
}
@end
