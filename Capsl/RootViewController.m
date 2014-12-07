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

@interface RootViewController () <PFLogInViewControllerDelegate, PFSignUpViewControllerDelegate, UIAlertViewDelegate>
@property (strong, nonatomic) IBOutlet UIButton *sendCapsuleButton;
@property (strong, nonatomic) IBOutlet UIButton *viewCapsulesButton;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *viewButtonRightConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *sendButtonLeftConstraint;

@property UITextField *verificationCode;

@end

@implementation RootViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
//    [PFUser logOut];

    // Check to see if user quit before entering verification code

//    if ([PFUser currentUser])
//    {
//        [Capslr returnCapslrFromPFUser:[PFUser currentUser] withCompletion:^(Capslr *currentCapslr, NSError *error) {
//            if (!currentCapslr.name)
//            {
//                [currentCapslr deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
//                    if (!error)
//                    {
//                        [[PFUser currentUser] deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
//                            if (!error)
//                            {
//                                [PFUser logOut];
//                                [self manageLogin];
//                            }
//                        }];
//                    }
//                }];
//            }
//        }];
//    }


    self.sendCapsuleButton.alpha = 0;
    self.viewCapsulesButton.alpha = 0;

    self.sendCapsuleButton.layer.cornerRadius = 20;
    self.sendCapsuleButton.layer.borderColor = [[UIColor whiteColor] CGColor];
    self.sendCapsuleButton.layer.borderWidth = 1;

    self.viewCapsulesButton.layer.cornerRadius = 20;
    self.viewCapsulesButton.layer.borderColor = [[UIColor whiteColor] CGColor];
    self.viewCapsulesButton.layer.borderWidth = 1;


    self.sendButtonLeftConstraint.constant = [[UIScreen mainScreen] bounds].size.width * 0.5;
    self.viewButtonRightConstraint.constant = [[UIScreen mainScreen] bounds].size.width * 0.5;

//    self.view.backgroundColor = [UIColor colorWithPatternImage:kSplashWallpaper];

}

//View did appear - for login/signup modal view
-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    [self manageLogin];

}

//- (BOOL)prefersStatusBarHidden
//{
//    
//    return YES;
//}

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
        signUpViewController.signUpView.additionalField.keyboardType = UIKeyboardTypePhonePad;


        //Assign our sign up controller to be displayed from the login controller
        [logInViewController setSignUpController:signUpViewController];

        //Present the log in view controller
        [self presentViewController:logInViewController animated:YES completion:nil];

    }
    else
    {
        [UIView animateWithDuration:0.5 animations:^{

            self.sendCapsuleButton.alpha = 1;
            self.viewCapsulesButton.alpha = 1;

        }];
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
    //TODO: check if user is on a device or not, check if user has logged in from multiple device
    //Initiates the currentInstallation user's cpslr a the Capslr object of the PFUser Current user
    //PFInstallation is also called in AppDelegate, when the user first installs the app
    [Capslr returnCapslrFromPFUser:user withCompletion:^(Capslr *currentCapslr, NSError *error)
    {
        PFInstallation *installation = [PFInstallation currentInstallation];
        installation[@"capslr"]=currentCapslr;
        [installation saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
        {
            if (!error)
            {
                //TODO:clear badge?
            }
            else
            {
                NSLog(@"error %@", error.localizedDescription);
            }
        }];
    }];




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
        if ((!field || field.length == 0) && (signUpController.signUpView.additionalField.text.length != 11 || signUpController.signUpView.additionalField.text.length != 10)) {
            informationComplete = NO;
//            break;
        }

//        int textLength = [signUpController.signUpView.additionalField.text length];

        else if (![signUpController.signUpView.additionalField.text hasPrefix:@"1"] && signUpController.signUpView.additionalField.text.length == 10)
        {
            signUpController.signUpView.additionalField.text = [NSString stringWithFormat:@"1%@", field];
            informationComplete = YES;
        }
    }

    //Display an alert if field wasn't completed
    if (!informationComplete) {

        signUpController.signUpView.additionalField.text = nil;

        [[[UIAlertView alloc] initWithTitle:@"Incorrect Information" message:@"Make sure you fill out all of the information correctly" delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil] show];
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

    [PFCloud callFunctionInBackground:@"sendVerificationCode" withParameters:@{@"phoneNumber":signUpController.signUpView.additionalField.text}];

    UIAlertView * alert =[[UIAlertView alloc ] initWithTitle:@"Phone Number Verification" message:@"Enter your code" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles: nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    [alert addButtonWithTitle:@"Ok"];
    [alert show];



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

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{

    if (buttonIndex == 0)
    {
        [Capslr returnCapslrFromPFUser:[PFUser currentUser] withCompletion:^(Capslr *currentCapslr, NSError *error) {
            if (!error) {
                [currentCapslr deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    if (!error)
                    {
                        [[PFUser currentUser] deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                            if (!error)
                            {
                                [PFUser logOut];
                                [self manageLogin];
                            }
                        }];
                    }
                }];
            }
        }];
    }

    if (buttonIndex == 1)
    {
        UITextField *verificationCode = [alertView textFieldAtIndex:0];

        [PFCloud callFunctionInBackground:@"verifyPhoneNumber" withParameters:@{@"phoneVerificationCode":verificationCode.text} block:^(id object, NSError *error) {
            if ([object isEqualToString:@"Success"])
            {
                NSLog(@"PHONE NUMBER VERIFIED!!!");
                [Capslr returnCapslrFromPFUser:[PFUser currentUser] withCompletion:^(Capslr *currentCapslr, NSError *error) {
                    currentCapslr.name = @"No Name";
                    [currentCapslr save];
                }];
            }
            else
            {
                NSLog(@"WRONG CODE!!");

                [Capslr returnCapslrFromPFUser:[PFUser currentUser] withCompletion:^(Capslr *currentCapslr, NSError *error) {
                    if (!error) {
                        [currentCapslr deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                            if (!error)
                            {
                                [[PFUser currentUser] deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                                    if (!error)
                                    {
                                        [PFUser logOut];
                                        [self manageLogin];
                                    }
                                }];
                            }
                        }];
                    }
                }];
            }
        }];

    }
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





