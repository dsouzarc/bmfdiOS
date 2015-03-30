//
//  Order.h
//  Bring Me Food Driver
//
//  Created by Ryan D'souza on 3/30/15.
//  Copyright (c) 2015 Ryan D'souza. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>

@interface Order : NSObject

@property (nonatomic, strong) NSString *orderId;
@property (nonatomic, strong) NSString *ordererName;

@property (nonatomic, strong) NSString *deliveryAddressString;
@property (nonatomic, strong) PFGeoPoint *deliveryAddress;

@property NSInteger orderStatus;

@property (nonatomic, strong) NSDate *timeToBeDeliveredAt;
@property (nonatomic, strong) NSDate *estimatedDeliveryTime;

@property (nonatomic, strong) NSArray *chosenItems;

@property (nonatomic, strong) NSString *restaurantName;

- (instancetype) initWithEverything:(NSString*)orderId ordererName:(NSString*)ordererName deliveryAddressString:(NSString*)deliveryAddressString deliveryAddress:(PFGeoPoint*)deliveryAddress orderStatus:(NSInteger)orderStatus timeToDeliverAt:(NSDate*)timeToDeliverAt estimatedDeliveryTime:(NSDate*)estimatedDeliveryTime chosenItems:(NSArray*)chosenItems restaurantName:(NSString*)restaurantName;

- (instancetype) initUsingDictionary:(NSDictionary*)dictionary;

@end
