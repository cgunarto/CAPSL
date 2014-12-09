//
//  JCASplashViewController.m
//  Capsl
//
//  Created by Mobile Making on 11/29/14.
//  Copyright (c) 2014 Christina Gunarto. All rights reserved.
//

#import "JCAMainViewController.h"
#import "ViewCapsulesViewController.h"
#import "EditProfileViewController.h"
#import "Capslr.h"

@interface JCAMainViewController ()

@property (strong, nonatomic) IBOutlet UIView *viewCapsulesContainerView;
@property (strong, nonatomic) IBOutlet UIView *chooseTypeContainerView;
@property NSMutableArray *toolbarButtons;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *sendCapsuleButton;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *viewCapsulesButton;

@end

@implementation JCAMainViewController

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [Capslr returnCapslrFromPFUser:[PFUser currentUser] withCompletion:^(Capslr *currentCapslr, NSError *error) {
        if (!error)
        {
            [currentCapslr.profilePhoto getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                self.currentProfileImage = [UIImage imageWithData:data];
            }];
        }
        else
        {
            NSLog(@"%@", error.localizedDescription);
        }
    }];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Do any additional setup after loading the view.

    self.toolbarButtons = [self.toolBar.items mutableCopy];

    [self.view addSubview:self.viewCapsulesContainerView];
    [self.view addSubview:self.chooseTypeContainerView];

    if (self.showChooseVC == YES)
    {

        [self showChooseVCContainer];

    }
    else
    {

        [self showCapsulesVCContainer];

    }

}



- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{

    NSLog(@"FIRE");
//    if (UIInterfaceOrientationIsLandscape([UIDevice currentDevice].orientation))
//    {
//        [self prefersStatusBarHidden];
//    }
//    [self.view layoutIfNeeded];

}
//

- (BOOL)prefersStatusBarHidden
{
    if (UIInterfaceOrientationIsPortrait([UIDevice currentDevice].orientation))
    {
        return NO;
    }

    return YES;


}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Actions

- (IBAction)onSendCapsuleButtonTapped:(UIBarButtonItem *)sender
{

    [self showChooseVCContainer];

}

- (IBAction)onViewCapsulesButtonTapped:(UIBarButtonItem *)sender
{
    [self showCapsulesVCContainer];
    
}

#pragma mark Helper methods

- (void)showChooseVCContainer
{

//    [UIView transitionFromView:self.capsuleListContainerView toView:self.chooseTypeContainerView duration:0.5 options:UIViewAnimationOptionTransitionCrossDissolve completion:^(BOOL finished) {
//        nil;
//    }];

    [self.viewCapsulesContainerView setHidden:YES];
    [self.chooseTypeContainerView setHidden:NO];
    [self.toolbarButtons removeObject:self.sendCapsuleButton];
    [self.toolbarButtons insertObject:self.viewCapsulesButton atIndex:2];
//    [self.view bringSubviewToFront:self.toolBar];

    self.toolBar.items = self.toolbarButtons;
}

- (void)showCapsulesVCContainer
{
//    [UIView transitionFromView:self.chooseTypeContainerView toView:self.capsuleListContainerView duration:0.5 options:UIViewAnimationOptionTransitionCrossDissolve completion:^(BOOL finished) {
//        nil;
//    }];

    [self.viewCapsulesContainerView setHidden:NO];
    [self.chooseTypeContainerView setHidden:YES];
    [self.toolbarButtons removeObject:self.viewCapsulesButton];
    [self.toolbarButtons insertObject:self.sendCapsuleButton atIndex:2];
//    [self.view bringSubviewToFront:self.toolBar];

    self.toolBar.items = self.toolbarButtons;
}

#pragma mark - segue life cycle

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{

    if ([segue.identifier isEqualToString:@"viewCapsulesSegue"])
    {
        ViewCapsulesViewController *vc = segue.destinationViewController;
        vc.capslsArray = self.capslsArray;
        vc.sentCapslsArray = self.sentCapslsArray;
        
        vc.availableCapslsArray = self.availableCapslsArray;
        vc.shouldShowSent = self.shouldShowSent;
    }
    else if ([segue.identifier isEqualToString:@"chooseTypeSegue"])
    {
        [self.viewCapsulesContainerView setHidden:YES];
        [self.chooseTypeContainerView setHidden:NO];

    }
    else if ([segue.identifier isEqualToString:@"contactsSegue"])
    {
        UINavigationController *navVC = segue.destinationViewController;
        EditProfileViewController *editVC = navVC.childViewControllers.firstObject;
        editVC.currentProfilePicture = self.currentProfileImage;
    }
    
}

- (IBAction)unWindSegueToMain:(UIStoryboardSegue *)segue
{

}



@end
