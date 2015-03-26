//
//  LogInViewController.m
//  Bring Me Food Driver
//
//  Created by Ryan D'souza on 3/26/15.
//  Copyright (c) 2015 Ryan D'souza. All rights reserved.
//

#import "LogInViewController.h"
#import <Parse/Parse.h>
#import "UICKeyChainStore.h"
#import "PQFBarsInCircle.h"
#import "MainViewController.h"

@interface LogInViewController ()

@property (strong, nonatomic) IBOutlet UITextField *usernameTextField;
@property (strong, nonatomic) IBOutlet UITextField *passwordTextField;

- (IBAction)loginButton:(id)sender;

@property (strong, nonatomic) UICKeyChainStore *keychain;
@property (strong, nonatomic) PQFBarsInCircle *loadingIcon;

@end

@implementation LogInViewController

- (IBAction)loginButton:(id)sender {
    if(self.usernameTextField.text.length <= 4) {
        [self showAlert:@"Invalid Username" alertMessage:@"Please enter a valid username" buttonTitle:@"Try again"];
        return;
    }
    
    if(self.passwordTextField.text.length <= 4) {
        [self showAlert:@"Invalid Password" alertMessage:@"Please enter a valid password" buttonTitle:@"Try again"];
        return;
    }
    
    [self.loadingIcon show];
    
    //Log into BMF
    [PFUser logInWithUsernameInBackground:self.usernameTextField.text
                                 password:self.passwordTextField.text
                                    block:^(PFUser *user, NSError *error) {
        //If they have a BMF Account
        if(user) {
            
            [PFCloud callFunctionInBackground:@"userHasDriverRole"
                               withParameters:nil
                                        block:^(NSString *result, NSError *error) {
                                            if(!error) {
                                                
                                                //Successful log in
                                                if([result containsString:@"YES"]) {
                                                    
                                                    self.keychain[@"username"] = self.usernameTextField.text;
                                                    self.keychain[@"password"] = self.passwordTextField.text;
                                                    
                                                    MainViewController *mainViewController = [[MainViewController alloc] initWithNibName:@"MainViewController"                                    bundle:[NSBundle mainBundle]];
                                                    [self.loadingIcon hide];
                                                    self.view.window.rootViewController = mainViewController;
                                                }
                                                
                                                else {
                                                    [self showAlert:@"Not a Driver" alertMessage:@"Sorry, it looks like you do not have permission to be a driver" buttonTitle:@"Done"];
                                                    return;
                                                }
                                                
                                            }
                                            
                                            else {
                                                [self showAlert:@"Problem loggin in" alertMessage:@"Sorry, something went wrong while trying to log you in" buttonTitle:@"Try again"];
                                                return;
                                            }
                
            }];
            
        }
        
        //No BMF account
        else {
            [self showAlert:@"Problem logging in" alertMessage:@"No BMF account found for entered username/password"buttonTitle:@"Try again"];
            return;
        }
        
    }];
}

- (instancetype) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if(self) {
        self.keychain = [[UICKeyChainStore alloc] init];
        self.loadingIcon = [[PQFBarsInCircle alloc] initLoaderOnView:self.view];
    }
    
    return self;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [self animateTextField: textField up: YES];
    //Add some glow effect
    textField.layer.cornerRadius=8.0f;
    textField.layer.masksToBounds=YES;
    textField.layer.borderColor=[[UIColor blueColor]CGColor];
    textField.layer.borderWidth= 2.0f;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [self animateTextField: textField up: NO];
    //Remove the flow effect
    textField.layer.borderColor=[[UIColor clearColor]CGColor];
}

- (void) animateTextField: (UITextField*) textField up: (BOOL) up
{
    const int movementDistance = 50; // tweak as needed
    const float movementDuration = 0.3f; // tweak as needed
    
    int movement = (up ? -movementDistance : movementDistance);
    
    [UIView beginAnimations: @"anim" context: nil];
    [UIView setAnimationBeginsFromCurrentState: YES];
    [UIView setAnimationDuration: movementDuration];
    self.view.frame = CGRectOffset(self.view.frame, 0, movement);
    [UIView commitAnimations];
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void) showAlert:(NSString*)alertTitle alertMessage:(NSString*)alertMessage buttonTitle:(NSString*)buttonTitle
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:alertTitle message:alertMessage delegate:nil cancelButtonTitle:buttonTitle otherButtonTitles:nil, nil];
    [alert show];
}

@end
