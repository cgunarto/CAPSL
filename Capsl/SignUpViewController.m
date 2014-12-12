//
//  SignUpViewController.m
//  Capsl
//
//  Created by Jonathan Kim on 11/27/14.
//  Copyright (c) 2014 Christina Gunarto. All rights reserved.
//

#import "SignUpViewController.h"

@interface SignUpViewController ()

@end

@implementation SignUpViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.signUpView setBackgroundColor:[UIColor colorWithPatternImage:kUpdateProfileBackground]];
    [self.signUpView setLogo:[[UIImageView alloc] initWithImage:kLoginLogoImage]];

    [self processDismissButton];


    [self.signUpView.usernameField setTextColor:[UIColor whiteColor]];
    [self.signUpView.passwordField setTextColor:[UIColor whiteColor]];
    [self.signUpView.emailField setTextColor:[UIColor whiteColor]];
    [self.signUpView.additionalField setTextColor:[UIColor whiteColor]];

    [self.signUpView.usernameField setBackgroundColor:[UIColor colorWithWhite:0.0 alpha:0.35]];
    [self.signUpView.passwordField setBackgroundColor:[UIColor colorWithWhite:0.0 alpha:0.35]];
    [self.signUpView.emailField setBackgroundColor:[UIColor colorWithWhite:0.0 alpha:0.35]];
    [self.signUpView.additionalField setBackgroundColor:[UIColor colorWithWhite:0.0 alpha:0.35]];

    [self.signUpView.signUpButton setBackgroundImage:nil forState:UIControlStateNormal];
    [self.signUpView.signUpButton setBackgroundImage:nil forState:UIControlStateHighlighted];
    self.signUpView.signUpButton.backgroundColor = kReceivedViewedCapsuleColor;
    self.signUpView.signUpButton.layer.cornerRadius = self.signUpView.signUpButton.frame.size.height/2;
    self.signUpView.signUpButton.clipsToBounds = YES;

}

- (void)viewDidLayoutSubviews
{
    self.signUpView.logo.contentMode = UIViewContentModeScaleAspectFit;

}

- (void)processDismissButton
{

    UIImage *image = [[UIImage imageNamed:@"cancel-50"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [self.signUpView.dismissButton setImage:image forState:UIControlStateNormal];

    self.signUpView.dismissButton.tintColor = [UIColor whiteColor];
    self.signUpView.dismissButton.layer.shadowColor = [UIColor blackColor].CGColor;
    self.signUpView.dismissButton.layer.shadowOpacity = 0.3;
    self.signUpView.dismissButton.layer.shadowRadius = 1;
    self.signUpView.dismissButton.layer.shadowOffset = CGSizeMake(0, 1.5f);
    
}

@end
