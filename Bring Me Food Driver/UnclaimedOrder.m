//
//  UnclaimedOrder.m
//  Bring Me Food Driver
//
//  Created by Ryan D'souza on 4/15/15.
//  Copyright (c) 2015 Ryan D'souza. All rights reserved.
//

#import "UnclaimedOrder.h"

@implementation UnclaimedOrder

- (instancetype) initWithEverything:(NSDictionary *)dictionary
{
    self = [super init];
    
    if(self) {
        self.orderID = dictionary[@"orderID"];
        self.restaurantName = dictionary[@"restaurantName"];
        self.deliveryAddressString = dictionary[@"deliveryAddressString"];
        self.timeToBeDeliveredAt = dictionary[@"timeToBeDeliveredAt"];
        self.deliveryAddress = dictionary[@"deliveryAddress"];
        self.orderCost = dictionary[@"orderCost"];
        self.restaurantGeoPoint = dictionary[@"restaurantGeoPoint"];
    }
    
    return self;
}


@end
