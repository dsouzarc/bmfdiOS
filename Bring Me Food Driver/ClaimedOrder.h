//
//  ClaimedOrder.h
//  Bring Me Food Driver
//
//  Created by Ryan D'souza on 4/16/15.
//  Copyright (c) 2015 Ryan D'souza. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>

#import "ChosenMenuItem.h"

@interface ClaimedOrder : NSObject

- (instancetype) initWithEverything:(NSDictionary*)dictionary;

@property (strong, nonatomic) NSString *orderID;

@property (strong, nonatomic) PFGeoPoint *deliveryAddress;
@property (strong, nonatomic) NSString *deliveryAddressString;

@property (strong, nonatomic) NSDate *estimatedDeliveryTime;

@property (strong, nonatomic) NSArray *chosenItems;
@property (strong, nonatomic) NSString *orderCost;

@property (nonatomic) NSInteger orderStatus;
@property (strong, nonatomic) NSDate *timeToBeDeliveredAt;
@property (strong, nonatomic) NSString *additionalDetails;

@property (strong, nonatomic) NSString *ordererName;
@property (strong, nonatomic) NSString *ordererPhoneNumber;

@property (strong, nonatomic) PFGeoPoint *restaurantLocation;
@property (strong, nonatomic) PFGeoPoint *restaurantName;

@end
