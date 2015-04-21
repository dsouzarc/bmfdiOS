//
//  RestaurantItemTableViewCell.h
//  Bring Me Food
//
//  Created by Ryan D'souza on 3/18/15.
//  Copyright (c) 2015 Ryan D'souza. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ChosenMenuItem.h"

@interface RestaurantItemTableViewCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UILabel *itemNameAndCost;

@property (strong, nonatomic) IBOutlet UITextView *descriptionTextView;

@end
