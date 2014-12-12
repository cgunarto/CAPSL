//
//  LoginViewController.m
//  Capsl
//
//  Created by Jonathan Kim on 11/27/14.
//  Copyright (c) 2014 Christina Gunarto. All rights reserved.
//

#import "LoginViewController.h"

@interface LoginViewController ()

@property UIImageView *fieldsBackground;


@end

@implementation LoginViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self.logInView setBackgroundColor:[UIColor colorWithPatternImage:kProfileBackground]];
    [self.logInView setLogo:[[UIImageView alloc] initWithImage:kLoginLogoImage]];

    // Set buttons appearance
    [self.logInView.dismissButton setImage:[UIImage imageNamed:@"cancel-50"] forState:UIControlStateNormal];
    [self processDismissButton];
//    [self.logInView.dismissButton setImage:[UIImage imageNamed:@"exit_down.png"] forState:UIControlStateHighlighted];

//
    [self.logInView.signUpButton setBackgroundImage:nil forState:UIControlStateNormal];
    [self.logInView.signUpButton setBackgroundImage:nil forState:UIControlStateHighlighted];
//    [self.logInView.signUpButton setTitle:@"Sign Up" forState:UIControlStateNormal];
//    [self.logInView.signUpButton setTitle:@"Sign Up" forState:UIControlStateHighlighted];
    self.logInView.signUpButton.backgroundColor = kReceivedViewedCapsuleColor;
    self.logInView.signUpButton.layer.cornerRadius = self.logInView.signUpButton.frame.size.height/2;
    self.logInView.signUpButton.clipsToBounds = YES;

    self.logInView.logInButton.backgroundColor = [UIColor colorWithWhite:0.4 alpha:0.5];
    [self.logInView.logInButton setBackgroundImage:nil forState:UIControlStateNormal];
    [self.logInView.logInButton setBackgroundImage:nil forState:UIControlStateHighlighted];

    [self.logInView.passwordForgottenButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.logInView.passwordForgottenButton setTitleColor:[UIColor colorWithWhite:1.0 alpha:0.5] forState:UIControlStateHighlighted];


    // Add login field background
//    self.fieldsBackground = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"background.png"]];
//    [self.logInView insertSubview:self.fieldsBackground atIndex:1];
//    self.fieldsBackground.backgroundColor = [UIColor colorWithWhite:0.5 alpha:0.5];

    // Remove text shadow
//    CALayer *layer = self.logInView.usernameField.layer;
//    layer.shadowOpacity = 0.0;
//    layer = self.logInView.passwordField.layer;
//    layer.shadowOpacity = 0.0;
//
//    // Set field text color
    [self.logInView.usernameField setTextColor:[UIColor whiteColor]];
    [self.logInView.passwordField setTextColor:[UIColor whiteColor]];
    self.logInView.usernameField.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.35];
    self.logInView.passwordField.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.35];
    self.logInView.usernameField.borderStyle = UITextBorderStyleNone;

}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];

    // Set frame for elements
//    [self.logInView.dismissButton setFrame:CGRectMake(10.0f, 10.0f, 87.5f, 45.5f)];
//    [self.logInView.logo setFrame:CGRectMake(66.5f, 70.0f, 187.0f, 58.5f)];

//    CGRect logoFrame = self.logInView.logo.frame;
//    logoFrame.size = CGSizeMake([[UIScreen mainScreen] bounds].size.width * 0.5, [[UIScreen mainScreen] bounds].size.width * 0.3);
//    self.logInView.logo.frame = logoFrame;

    self.logInView.logo.contentMode = UIViewContentModeScaleAspectFit;

//    [self.logInView.facebookButton setFrame:CGRectMake(35.0f, 287.0f, 120.0f, 40.0f)];
//    [self.logInView.twitterButton setFrame:CGRectMake(35.0f+130.0f, 287.0f, 120.0f, 40.0f)];
//    [self.logInView.signUpButton setFrame:CGRectMake(35.0f, 385.0f, 250.0f, 40.0f)];
//    [self.logInView.usernameField setFrame:CGRectMake(35.0f, 145.0f, 250.0f, 50.0f)];
//    [self.logInView.passwordField setFrame:CGRectMake(35.0f, 195.0f, 250.0f, 50.0f)];
//    [self.fieldsBackground setFrame:CGRectMake(35.0f, 145.0f, 250.0f, 100.0f)];
}

- (void)processDismissButton
{

    UIImage *image = [[UIImage imageNamed:@"cancel-50"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [self.logInView.dismissButton setImage:image forState:UIControlStateNormal];

    self.logInView.dismissButton.tintColor = [UIColor whiteColor];
    self.logInView.dismissButton.layer.shadowColor = [UIColor blackColor].CGColor;
    self.logInView.dismissButton.layer.shadowOpacity = 0.3;
    self.logInView.dismissButton.layer.shadowRadius = 1;
    self.logInView.dismissButton.layer.shadowOffset = CGSizeMake(0, 1.5f);
    
}

@end
