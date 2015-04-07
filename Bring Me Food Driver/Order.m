
//
//  Order.m
//  Bring Me Food Driver
//
//  Created by Ryan D'souza on 3/30/15.
//  Copyright (c) 2015 Ryan D'souza. All rights reserved.
//

#import "Order.h"

@implementation Order

- (instancetype) initWithEverything:(NSString *)orderId ordererName:(NSString *)ordererName deliveryAddressString:(NSString *)deliveryAddressString deliveryAddress:(PFGeoPoint *)deliveryAddress orderStatus:(NSInteger)orderStatus timeToDeliverAt:(NSDate *)timeToDeliverAt estimatedDeliveryTime:(NSDate*)estimatedDeliveryTime chosenItems:(NSArray *)chosenItems restaurantName:(NSString *)restaurantName orderCost:(NSString *)orderCost restaurantGeo:(PFGeoPoint *)restaurantGeo
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
        self.restaurantName = restaurantName;
        self.orderCost = orderCost;
        self.restaurantGeoPoint = restaurantGeo;
    }
    
    return self;
}

- (instancetype) initUsingDictionary:(NSDictionary *)dictionary
{
    self = [self initWithEverything:dictionary[@"orderId"]
                        ordererName:dictionary[@"ordererName"]
              deliveryAddressString:dictionary[@"deliveryAddressString"]
                    deliveryAddress:dictionary[@"deliveryAddress"]
                        orderStatus:[dictionary[@"orderStatus"] integerValue]
                    timeToDeliverAt:dictionary[@"timeToDeliverAt"] estimatedDeliveryTime:dictionary[@"estimatedDeliveryTime"]
                        chosenItems:dictionary[@"chosenItems"]
            restaurantName:dictionary[@"restaurantName"]
            orderCost:dictionary[@"orderCost"]
            restaurantGeo:dictionary[@"restaurantLocation"]];
    
    return self;
}

@end
