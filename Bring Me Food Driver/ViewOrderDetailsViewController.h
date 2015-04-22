//
//  ViewOrderDetailsViewController.h
//  Bring Me Food
//
//  Created by Ryan D'souza on 4/2/15.
//  Copyright (c) 2015 Ryan D'souza. All rights reserved.
//

#import "ClaimedOrder.h"
#import "RestaurantItemTableViewCell.h"
#import "PQFBouncingBalls.h"

@interface ViewOrderDetailsViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

- (instancetype) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil order:(ClaimedOrder*)order;

@end
