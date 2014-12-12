//
//  ViewController.m
//  Capsl
//
//  Created by CHRISTINA GUNARTO on 11/25/14.
//  Copyright (c) 2014 Christina Gunarto. All rights reserved.
//

#import "RootViewController.h"
#import "Capslr.h"
#import "Capsl.h"
#import <Parse/Parse.h>
#import <ParseUI/ParseUI.h>
#import "LoginViewController.h"
#import "SignUpViewController.h"
#import "JCAMainViewController.h"
#import "SVProgressHUD.h"
#import "DataFetcher.h"

#define kTwoMinutesInSeconds 120
#define kTwoDaysInSeconds 172800
#define kWeekInSeconds 604800


@interface RootViewController () <PFLogInViewControllerDelegate, PFSignUpViewControllerDelegate, UIAlertViewDelegate>
@property (strong, nonatomic) IBOutlet UIButton *sendCapsuleButton;
@property (strong, nonatomic) IBOutlet UIButton *viewCapsulesButton;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *viewButtonRightConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *sendButtonLeftConstraint;

@property UITextField *verificationCode;

//refactoring
@property (nonatomic) NSArray *capslsArray;
@property (nonatomic) NSArray *sentCapslsArray;
@property (nonatomic) NSMutableArray *availableCapslsArray;
@property UIImage *currentProfileImage;
@property NSArray *onboardingCapsl;

@property (nonatomic) BOOL shouldShowSent;

@property NSObject *observer;
@property JCAMainViewController *JCAMainVC;

@end

@implementation RootViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    // Check to see if user quit before entering verification code
    if ([PFUser currentUser])
    {
        [self showLoadingIndicator];
        [self disableSendViewButton];
        [self queryAndUpdateCurrentUserCapsules];
    }

    [self styleButtons];
    //    self.view.backgroundColor = [UIColor colorWithPatternImage:kSplashWallpaper];    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
//    [PFUser logOut];

    self.observer =  [[NSNotificationCenter defaultCenter]addObserverForName:kRefreshData object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note)
                      {
                          if ([PFUser currentUser])
                          {
                                      [self showLoadingIndicator];
                                      [self disableSendViewButton];
                                      [self queryAndUpdateCurrentUserCapsules];

                          }
                      }];

    //If user is curren but is NOT verified, then delete their capsl and user info
    if ([PFUser currentUser])
    {
        [self showLoadingIndicator];

        [Capslr returnCapslrFromPFUser:[PFUser currentUser] withCompletion:^(Capslr *currentCapslr, NSError *error) \
        {
            [self disableSendViewButton];

            if (!currentCapslr.isVerified)
            {
                [currentCapslr deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    if (!error)
                    {
                        [[PFUser currentUser] deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                            if (!error)
                            {
                                [PFUser logOut];
                                [self manageLogin];

                                [SVProgressHUD dismiss];
                            }
                        }];
                    }
                }];
                
            }
        }];
    }

    // Check to see if user quit before entering verification code
    [self disableSendViewButton];
    [self styleButtons];

    //self.view.backgroundColor = [UIColor colorWithPatternImage:kSplashWallpaper];

}


//View did appear - for login/signup modal view
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self manageLogin];

}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
//    [[NSNotificationCenter defaultCenter] removeObserver:self.observer];
}


//- (BOOL)prefersStatusBarHidden
//{
//    
//    return YES;
//}

#pragma mark Lock Orientation

- (BOOL) shouldAutorotate
{
    return NO;
}

-(NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (UIInterfaceOrientation) preferredInterfaceOrientationForPresentation {
    // Return the orientation you'd prefer - this is what it launches to. The
    // user can still rotate. You don't have to implement this method, in which
    // case it launches in the current orientation
    return UIInterfaceOrientationPortrait;
}

#pragma mark Indicator and initial View set up

- (void)showLoadingIndicator
{
    [SVProgressHUD setBackgroundColor:[UIColor clearColor]];
    [SVProgressHUD setForegroundColor:[UIColor whiteColor]];
    [SVProgressHUD show];
}

- (void)disableSendViewButton
{
    self.viewCapsulesButton.enabled = NO;
    self.sendCapsuleButton.enabled = NO;
}

- (void)enableSendViewButton
{
    self.viewCapsulesButton.enabled = YES;
    self.sendCapsuleButton.enabled = YES;
}

- (void)styleButtons
{
    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"logo_header"]];

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
}

#pragma mark Query

- (void)queryAndUpdateCurrentUserCapsules
{
    [Capslr returnCapslrFromPFUser:[PFUser currentUser] withCompletion:^(Capslr *currentCapslr, NSError *error)
     {
         //getting profile photo for profile page
         [currentCapslr.profilePhoto getDataInBackgroundWithBlock:^(NSData *data, NSError *error)
          {
              self.currentProfileImage = [UIImage imageWithData:data];

          }];

         //Get receiped capsl
         [Capsl searchCapslByKey:@"recipient" orderByAscending:@"deliveryTime" equalTo:currentCapslr completion:^(NSArray *objects, NSError *error)
          {
              if (!error)
              {
                  self.capslsArray = objects;
                  self.JCAMainVC.capslsArray = self.capslsArray;

                  NSInteger availableCapslsCount = 0;

                  for (NSDate *date in [objects valueForKey:@"deliveryTime"])
                  {
                      if ([date timeIntervalSinceNow] < 0)
                      {
                          availableCapslsCount++;
                      }
                  }

                  self.shouldShowSent = NO;
                  [self enableSendViewButton];
              }

              else
              {
                  NSLog(@"%@", error.localizedDescription);
              }
          }];

         // Get sent capsl
         [Capsl searchCapslByKey:@"sender" orderByAscending:@"deliveryTime" equalTo:currentCapslr completion:^(NSArray *objects, NSError *error)
          {
              if (!error)
              {

                  if (objects.count == 2)
                  {
                      Capsl *firstCapsl = objects.firstObject;
                      Capsl *secondCapsl = objects[1];

                      if ([firstCapsl.recipient.objectId isEqualToString:kCapslTeamObjectID])
                      {
                          [firstCapsl deleteInBackground];
                          self.sentCapslsArray = @[secondCapsl];
                      }
                      else if ([secondCapsl.recipient.objectId isEqualToString:kCapslTeamObjectID])
                      {
                          [secondCapsl deleteInBackground];
                          self.sentCapslsArray = @[firstCapsl];
                      }
                      else
                      {
                          self.sentCapslsArray = objects;
                      }

                  }
                  else
                  {
                      self.sentCapslsArray = objects;
                  }

                  self.JCAMainVC.sentCapslsArray = self.sentCapslsArray;

                  // delete dummy capsl sent to team caspl

                  [SVProgressHUD dismiss];

              }
              else
              {
                  NSLog(@"%@", error.localizedDescription);
              }
          }];
     }];
}


#pragma mark Login

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

    [[[UIAlertView alloc] initWithTitle:@"Missing Information" message:@"Please complete all fields" delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil, nil] show];
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
        if (!field || field.length == 0)
        {
            informationComplete = NO;
        }

        else if (![signUpController.signUpView.additionalField.text hasPrefix:@"1"] && signUpController.signUpView.additionalField.text.length <= 11 && signUpController.signUpView.additionalField.text.length != 10)
        {
            informationComplete = NO;

        }

        else if (![signUpController.signUpView.additionalField.text hasPrefix:@"1"] && signUpController.signUpView.additionalField.text.length > 11)
        {
            informationComplete = NO;
        }

        else if ([signUpController.signUpView.additionalField.text hasPrefix:@"1"] && (signUpController.signUpView.additionalField.text.length < 10 || signUpController.signUpView.additionalField.text.length > 11))
        {
            informationComplete = NO;
        }

        else if ([signUpController.signUpView.additionalField.text hasPrefix:@"1"] && (signUpController.signUpView.additionalField.text.length == 11 || signUpController.signUpView.additionalField.text.length == 10))
        {
            informationComplete = YES;
        }

        else if (![signUpController.signUpView.additionalField.text hasPrefix:@"1"] && signUpController.signUpView.additionalField.text.length == 10)
        {
            signUpController.signUpView.additionalField.text = [NSString stringWithFormat:@"1%@", field];
            informationComplete = YES;
        }

    }

    //Display an alert if field wasn't completed
    if (!informationComplete) {

        [[[UIAlertView alloc] initWithTitle:@"Incorrect Information" message:@"Make sure information is entered correctly" delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil] show];
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

    self.sendCapsuleButton.enabled = NO;
    self.viewCapsulesButton.enabled = NO;

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
                NSLog(@"Phone number verified");
                [Capslr returnCapslrFromPFUser:[PFUser currentUser] withCompletion:^(Capslr *currentCapslr, NSError *error) {
                    currentCapslr.isVerified = YES;

                    NSData *imageData = UIImageJPEGRepresentation([UIImage imageNamed:@"default"], 0.5f);
                    PFFile *defaultPhoto = [PFFile fileWithData:imageData];
                    currentCapslr.profilePhoto = defaultPhoto;

                    //TODO: Fix this later
                    currentCapslr.name = @" ";
                    [currentCapslr save];


                    // Setting up onboarding capsules

                    [self createOnboardingCapsls:currentCapslr];
                }];
            }
            else
            {
                NSLog(@"wrong verification");

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

    [alert.view setTintColor:kAlertControllerTintColor];

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
    self.JCAMainVC = segue.destinationViewController;

    if ([sender isEqual:self.sendCapsuleButton])
    {
        vc.showChooseVC = YES;
    }
    else
    {
        vc.showChooseVC = NO;
    }

    vc.capslsArray = self.capslsArray;
    vc.sentCapslsArray = self.sentCapslsArray;
    vc.availableCapslsArray = self.availableCapslsArray;
    vc.shouldShowSent = self.shouldShowSent;
    vc.currentProfileImage = self.currentProfileImage;
}

#pragma mark - helper method
- (void)createOnboardingCapsls:(Capslr *)currentCapslr
{
    Capsl *onboardingCapsl1 = [[Capsl alloc] initWithCurrentCapslr:currentCapslr withIndex:@1 withWelcomeText:@"Welcome To Capsl! Send a capsule to a friend in the future. They'll love it!" withTimeInterval:kTwoMinutesInSeconds];
    [onboardingCapsl1 save];

    Capsl *onboardingCapsl2 = [[Capsl alloc] initWithCurrentCapslr:currentCapslr withIndex:@2 withWelcomeText:@"Have you tried sending a photo or a short audio message? Capture a funny moment or sing someone \"Happy Birthday\"!" withTimeInterval:kTwoDaysInSeconds];
    [onboardingCapsl2 save];

    Capsl *onboardingCapsl3 = [[Capsl alloc] initWithCurrentCapslr:currentCapslr withIndex:@3 withWelcomeText:@"Sometimes waiting can be fun. Invite a friend to send you some capsules!" withTimeInterval:kWeekInSeconds];
    [onboardingCapsl3 save];

    Capsl *onboardingSentCapsl = [[Capsl alloc] initSentWithCurrentCapslr:currentCapslr withTimeInterval:kTwoMinutesInSeconds];
    [onboardingSentCapsl save];

    // go back to rootVC
    [self showRootViewController];
}


- (void)showRootViewController
{
    UINavigationController *rootNav = [self.storyboard instantiateInitialViewController];;

    [self.view.window setRootViewController:rootNav];
}

@end





