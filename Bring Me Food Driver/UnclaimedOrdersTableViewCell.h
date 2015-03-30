//
//  UnclaimedOrdersTableViewCell.h
//  Bring Me Food Driver
//
//  Created by Ryan D'souza on 3/29/15.
//  Copyright (c) 2015 Ryan D'souza. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UnclaimedOrdersTableViewCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UILabel *restaurantName;
@property (strong, nonatomic) IBOutlet UILabel *deliveryTime;
@property (strong, nonatomic) IBOutlet UILabel *drivingDistanceAndLabel;
@property (strong, nonatomic) IBOutlet UILabel *orderedForTime;

@end
