//
//  ProfileViewController.m
//  Capsl
//
//  Created by CHRISTINA GUNARTO on 11/25/14.
//  Copyright (c) 2014 Christina Gunarto. All rights reserved.
//

#import "ProfileViewController.h"
#import <Parse/Parse.h>
#import "Contact.h"
#define kLeftInitialConstant -16
#define kRightInitialConstant -16
#import "Capslr.h"
#import "EditProfileViewController.h"

//@class Capslr;

@interface ProfileViewController ()
@property PFUser *currentCPSLR;
@property NSArray *contactsArray;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cpslrLeftConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cpslrRightConstraint;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *addressLeftConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *addressRightConstraint;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *dismissButton;

//Added by jonno
@property (strong, nonatomic) IBOutlet UIImageView *profilePictureImageView;
@property NSArray *currentCapslrInfo;

@end


//Retrieve PFUser CurrentUser
//SHOW current user profile information

//SHOW current user CAPSLR friends
///Check if any CPSLR in Parse against Contact's Phone Number
///Set Data array with CPSLR with the same phone number
///Display the name

@implementation ProfileViewController


#pragma mark View Controller Life Cycle

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [Capslr returnCapslrFromPFUser:[PFUser currentUser] withCompletion:^(Capslr *currentCapslr, NSError *error) {

        self.currentCapslrInfo = @[currentCapslr.name, currentCapslr.username, currentCapslr.email];

        [currentCapslr.profilePhoto getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {

            self.profilePictureImageView.layer.cornerRadius = self.profilePictureImageView.frame.size.width/2;
            self.profilePictureImageView.clipsToBounds = YES;

            self.profilePictureImageView.image = [UIImage imageWithData:data];
        }];
    }];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.segmentedControl.selectedSegmentIndex = 0;

    [self showCapslViewCenter];

}

//Segmented control toggles between CAPSLR and ADDRESS BOOK contact
- (IBAction)onSegmentedControlTapped:(UISegmentedControl *)sender
{
    NSInteger selectedSegment = sender.selectedSegmentIndex;

    if (selectedSegment == 0)
    {
        //SHOW CAPSLR CONTACT VIEW CONTROLLER
        [self showCapslViewCenter];
    }
    else
    {
        [self showAddressViewCenter];
    }
}

#pragma mark Actions

- (IBAction)onDismissButtonPressed:(UIBarButtonItem *)sender
{

    [self dismissViewControllerAnimated:YES completion:nil];

}


#pragma mark Helper Method
//User sees that CPSLR friend list by default
- (void)showCapslViewCenter
{
    self.cpslrLeftConstraint.constant = kLeftInitialConstant;
    self.cpslrRightConstraint.constant = kRightInitialConstant;

    CGFloat screenwidth = [UIScreen mainScreen].bounds.size.width;

    self.addressLeftConstraint.constant = self.addressLeftConstraint.constant + screenwidth;
    self.addressRightConstraint.constant = self.addressRightConstraint.constant - screenwidth;

    [self.view layoutIfNeeded];
}

//User sees Address at center - move CPSLR friend to left and Bring Address Book into center
- (void)showAddressViewCenter
{
    self.addressLeftConstraint.constant = kLeftInitialConstant;
    self.addressRightConstraint.constant = kRightInitialConstant;

    CGFloat screenwidth = [UIScreen mainScreen].bounds.size.width;

    self.cpslrLeftConstraint.constant = self.cpslrLeftConstraint.constant - screenwidth;
    self.cpslrRightConstraint.constant = self.cpslrRightConstraint.constant + screenwidth;

    [self.view layoutIfNeeded];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqual:@"editProfileSegue"])
    {
        EditProfileViewController *editProfileVC = segue.destinationViewController;
        editProfileVC.currenCapslrInfo = self.currentCapslrInfo;
        editProfileVC.currentProfilePicture = self.profilePictureImageView.image;
    }
}


@end
