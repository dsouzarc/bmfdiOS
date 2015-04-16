//
//  UnclaimedOrder.h
//  Bring Me Food Driver
//
//  Created by Ryan D'souza on 4/15/15.
//  Copyright (c) 2015 Ryan D'souza. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>

@interface UnclaimedOrder : NSObject

- (instancetype) initWithEverything:(NSDictionary*) dictionary;

@property (strong, nonatomic) NSString *orderID;

@property (strong, nonatomic) NSString *restaurantName;
@property (strong, nonatomic) PFGeoPoint *restaurantGeoPoint;

@property (strong, nonatomic) NSString *deliveryAddressString;
@property (strong, nonatomic) PFGeoPoint *deliveryAddress;
@property (strong, nonatomic) NSDate *timeToBeDeliveredAt;

@property (strong, nonatomic) NSString *orderCost;

@end
