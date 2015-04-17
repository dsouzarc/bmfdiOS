//
//  ClaimedOrder.m
//  Bring Me Food Driver
//
//  Created by Ryan D'souza on 4/16/15.
//  Copyright (c) 2015 Ryan D'souza. All rights reserved.
//

#import "ClaimedOrder.h"

@implementation ClaimedOrder

- (instancetype) initWithEverything:(NSDictionary *)dict
{
    self = [super init];
    
    if(self) {
        
        self.orderID = dict[@"orderID"];
        self.deliveryAddress = dict[@"deliveryAddress"];
        self.deliveryAddressString = dict[@"deliveryAddressString"];
        self.estimatedDeliveryTime = dict[@"estimatedDeliveryTime"];
        self.orderCost = dict[@"orderCost"];
        self.orderStatus = [dict[@"orderStatus"] integerValue];
        self.ordererName = dict[@"ordererName"];
        self.ordererPhoneNumber = dict[@"ordererPhoneNumber"];
        self.restaurantLocation = dict[@"restaurantLocation"];
        self.restaurantName = dict[@"restaurantName"];
        self.timeToBeDeliveredAt = dict[@"timeToBeDeliveredAt"];
        self.additionalDetails = dict[@"additionalDetails"];
        self.chosenItems = [self getChosenMenuItems:(NSArray*)dict[@"chosenItems"]];
    }
    
    return self;
}

- (NSArray*) getChosenMenuItems:(NSArray*)array
{
    NSMutableArray *chosenItems = [[NSMutableArray alloc] initWithCapacity:array.count];
    
    for(NSDictionary *item in array) {
        ChosenMenuItem *chosenItem = [[ChosenMenuItem alloc] initWithEverything:item];
        [chosenItems addObject:chosenItem];
    }
    
    return chosenItems;
}

@end
