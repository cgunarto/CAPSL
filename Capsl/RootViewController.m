//
//  ViewController.m
//  Capsl
//
//  Created by CHRISTINA GUNARTO on 11/25/14.
//  Copyright (c) 2014 Christina Gunarto. All rights reserved.
//

#import "RootViewController.h"
#import "Capslr.h"
#import <Parse/Parse.h>
#import <ParseUI/ParseUI.h>
#import "LoginViewController.h"
#import "SignUpViewController.h"
#import "JCAMainViewController.h"

@interface RootViewController () <PFLogInViewControllerDelegate, PFSignUpViewControllerDelegate>
@property (strong, nonatomic) IBOutlet UIButton *sendCapsuleButton;
@property (strong, nonatomic) IBOutlet UIButton *viewCapsulesButton;

@end

@implementation RootViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
//    [PFUser logOut];

}

//View did appear - for login/signup modal view
-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    [self manageLogin];

}


-(void)manageLogin
{
    if (![PFUser currentUser]) {

        //Create the log in view controller
        LoginViewController *logInViewController = [[LoginViewController alloc] init];
        [logInViewController setDelegate:self];
        [logInViewController setFields:PFLogInFieldsDefault |PFLogInFieldsDismissButton];


        //Create the sign up view controller
        SignUpViewController *signUpViewController = [[SignUpViewController alloc] init];
        [signUpViewController setDelegate:self];
        [signUpViewController setFields:PFSignUpFieldsDefault | PFSignUpFieldsAdditional];

        UIColor *color = [UIColor lightGrayColor];
        signUpViewController.signUpView.additionalField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Phone Number" attributes:@{NSForegroundColorAttributeName: color}];


        //Assign our sign up controller to be displayed from the login controller
        [logInViewController setSignUpController:signUpViewController];

        //Present the log in view controller
        [self presentViewController:logInViewController animated:YES completion:nil];

    }
    else
    {
//        [self performSegueWithIdentifier:@"toMainViewControllerSegue" sender:self];
    }
}

#pragma mark - PfLoginViewController Delegate Methods

//Sent to the delegate to determine whether the log in request should be submitted to server
- (BOOL)logInViewController:(PFLogInViewController *)logInController shouldBeginLogInWithUsername:(NSString *)username password:(NSString *)password
{
    //Check if both fields are completed
    if (username && password && username.length != 0 && password.length != 0) {
        //Begin login process
        return YES;
    }

    [[[UIAlertView alloc] initWithTitle:@"Missing Information" message:@"Make sure you fill out all of the information!" delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil, nil] show];
    //Interrupt login process
    return NO;
}



//Sent to the delegate when a PFUser is logged in
- (void) logInViewController:(PFLogInViewController *)logInController didLogInUser:(PFUser *)user
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

//Sent to delegate when login attempt fails
- (void)logInViewController:(PFLogInViewController *)logInController didFailToLogInWithError:(NSError *)error
{
    NSLog(@"Failed to log in");
    [self error:error];
}

//Sent to delegate when the log in screen is dismissed
- (void)logInViewControllerDidCancelLogIn:(PFLogInViewController *)logInController
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - PfSignupViewController Delegate Methods

//Sent to the delegate to determine whether signup request should be submitted to server
- (BOOL)signUpViewController:(PFSignUpViewController *)signUpController shouldBeginSignUp:(NSDictionary *)info
{
    BOOL informationComplete = YES;

    //Loop through all submitted data
    for (id key in info) {
        NSString *field = [info objectForKey:key];
        if (!field || field.length == 0) {
            informationComplete = NO;
            break;
        }
    }

    //Display an alert if field wasn't completed
    if (!informationComplete) {
        [[[UIAlertView alloc] initWithTitle:@"Missing Information" message:@"Make sure you fill out all of the information" delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil] show];
    }

    return informationComplete;
}

//Sent the delegate when a PFUser is signed up
- (void)signUpViewController:(PFSignUpViewController *)signUpController didSignUpUser:(PFUser *)user
{
    Capslr *capslr = [Capslr object];
    capslr.username = user.username;
    capslr.email = user.email;
    capslr.phone = signUpController.signUpView.additionalField.text;
    capslr.user = user;

    [capslr saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (error)
        {
            NSLog(@"%@", error.localizedDescription);
            [self error:error];
        }
        else
        {
            //Dismiss PFSignUpViewController;
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    }];
}

//Sent the delegate when the sign up attempt fails
- (void)signUpViewController:(PFSignUpViewController *)signUpController didFailToSignUpWithError:(NSError *)error
{
    NSLog( @"Failed to sign up");
    [self error:error];
}

//Sent the delegate when the sign up screen is dismised
- (void)signUpViewControllerDidCancelSignUp:(PFSignUpViewController *)signUpController
{
    NSLog(@"User dismissed the signupViewController");
}


#pragma mark - Alert

- (void)error:(NSError *)error
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error"
                                                                   message:error.localizedDescription
                                                            preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"OK"
                                                     style:UIAlertActionStyleDefault
                                                   handler:nil];
    [alert addAction:action];
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark Actions

- (IBAction)onDecisionButtonPressed:(UIButton *)sender
{

    [self performSegueWithIdentifier:@"toMainViewControllerSegue" sender:sender];

}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{

    JCAMainViewController *vc = segue.destinationViewController;

    if ([sender isEqual:self.sendCapsuleButton])
    {
        vc.showChooseVC = YES;
    }
    else
    {
        vc.showChooseVC = NO;
    }
}

@end





