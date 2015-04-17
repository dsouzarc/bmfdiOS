//
//  ClaimedOrderTableViewCell.h
//  Bring Me Food Driver
//
//  Created by Ryan D'souza on 4/16/15.
//  Copyright (c) 2015 Ryan D'souza. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ClaimedOrderTableViewCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UILabel *restaurantName;
@property (strong, nonatomic) IBOutlet UILabel *deliveryAddress;
@property (strong, nonatomic) IBOutlet UILabel *timeToBeDeliveredAt;
@property (strong, nonatomic) IBOutlet UILabel *orderStatus;

@end
