//
//  ChosenMenuItem.m
//  Bring Me Food Driver
//
//  Created by Ryan D'souza on 4/16/15.
//  Copyright (c) 2015 Ryan D'souza. All rights reserved.
//

#import "ChosenMenuItem.h"

@implementation ChosenMenuItem

- (instancetype) initWithEverything:(NSDictionary *)dictionary
{
    self = [super init];
    
    if(self) {
        self.itemName = dictionary[@"itemName"];
        self.itemCost = dictionary[@"itemCost"];
        
        self.itemDescription = dictionary[@"itemDescription"];
        self.customizedItemDescription = dictionary[@"customDescription"];
    }
    
    return self;
}

@end
