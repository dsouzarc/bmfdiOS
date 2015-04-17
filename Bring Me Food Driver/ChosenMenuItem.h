//
//  ChosenMenuItem.h
//  Bring Me Food Driver
//
//  Created by Ryan D'souza on 4/16/15.
//  Copyright (c) 2015 Ryan D'souza. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ChosenMenuItem : NSObject

@property (strong, nonatomic) NSString *itemName;
@property (strong, nonatomic) NSString *itemCost;

@property (strong, nonatomic) NSString *itemDescription;
@property (strong, nonatomic) NSString *customizedItemDescription;

- (instancetype) initWithEverything:(NSDictionary*)dictionary;

@end
