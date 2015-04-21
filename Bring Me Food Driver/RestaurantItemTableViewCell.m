//
//  RestaurantItemTableViewCell.m
//  Bring Me Food
//
//  Created by Ryan D'souza on 3/18/15.
//  Copyright (c) 2015 Ryan D'souza. All rights reserved.
//

#import "RestaurantItemTableViewCell.h"

@implementation RestaurantItemTableViewCell

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)clickedOnItemName:(id)sender {
    NSLog(@"WEVE GOT CLICKED");
}
- (IBAction)clickedOnCost:(id)sender {
    NSLog(@"OK");
}
@end
