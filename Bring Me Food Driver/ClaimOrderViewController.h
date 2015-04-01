//
//  ClaimOrderViewController.h
//  Bring Me Food Driver
//
//  Created by Ryan D'souza on 3/31/15.
//  Copyright (c) 2015 Ryan D'souza. All rights reserved.
//

#import "ViewController.h"
#import "Order.h"
#import <Parse/Parse.h>

@interface ClaimOrderViewController : ViewController <UITextFieldDelegate>

- (instancetype) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil order:(Order*)order myLocation:(PFGeoPoint*)myLocation;

- (void) showInView:(UIView*)view shouldAnimate:(BOOL)shouldAnimate;

@end
