//
//  MainViewController.m
//  Bring Me Food Driver
//
//  Created by Ryan D'souza on 4/15/15.
//  Copyright (c) 2015 Ryan D'souza. All rights reserved.
//

#import "MainViewController.h"
#import "MyClaimedOrdersViewController.h"
#import "LiveOrdersViewController.h"

@interface MainViewController ()

@property (strong, nonatomic) UITabBarController *tabBarController;

@property (strong, nonatomic) MyClaimedOrdersViewController *claimedOrdersViewController;
@property (strong, nonatomic) LiveOrdersViewController *liveOrdersViewController;

@end

@implementation MainViewController

- (instancetype) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if(self) {
        self.claimedOrdersViewController = [[MyClaimedOrdersViewController alloc] initWithNibName:@"MyClaimedOrdersViewController" bundle:[NSBundle mainBundle]];
        self.claimedOrdersViewController.tabBarItem.title = @"My Claimed Orders";
        
        self.liveOrdersViewController = [[LiveOrdersViewController alloc] initWithNibName:@"LiveOrdersViewController" bundle:[NSBundle mainBundle]];
        self.liveOrdersViewController.tabBarItem.title = @"Live Orders";
        
        self.tabBarController = [[UITabBarController alloc] init];
        NSArray *tabs = [NSArray arrayWithObjects:self.claimedOrdersViewController, self.liveOrdersViewController, nil];
        self.tabBarController.viewControllers = tabs;
    }
    
    return self;
}

- (void) viewDidAppear:(BOOL)animated
{
    self.view.window.rootViewController = self.tabBarController;
}

@end
