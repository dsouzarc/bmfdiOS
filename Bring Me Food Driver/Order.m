
//
//  Order.m
//  Bring Me Food Driver
//
//  Created by Ryan D'souza on 3/30/15.
//  Copyright (c) 2015 Ryan D'souza. All rights reserved.
//

#import "Order.h"

@implementation Order

- (instancetype) initWithEverything:(NSString *)orderId ordererName:(NSString *)ordererName deliveryAddressString:(NSString *)deliveryAddressString deliveryAddress:(PFGeoPoint *)deliveryAddress orderStatus:(NSInteger)orderStatus timeToDeliverAt:(NSDate *)timeToDeliverAt estimatedDeliveryTime:(NSDate*)estimatedDeliveryTime chosenItems:(NSArray *)chosenItems
{
    self = [super init];
    
    if(self) {
        self.orderId = orderId;
        self.ordererName = ordererName;
        self.deliveryAddressString = deliveryAddressString;
        self.deliveryAddress = deliveryAddress;
        self.orderStatus = orderStatus;
        self.estimatedDeliveryTime = estimatedDeliveryTime;
        self.timeToBeDeliveredAt = timeToDeliverAt;
        self.chosenItems = chosenItems;
    }
    
    return self;
}

@end
