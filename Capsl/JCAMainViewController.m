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
@property ViewCapsulesViewController *viewCapsulesVC;
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

- (BOOL)prefersStatusBarHidden
{
    if (UIInterfaceOrientationIsPortrait([UIDevice currentDevice].orientation))
    {
        return NO;
    }

    return YES;


}

- (void)setCapslsArray:(NSArray *)capslsArray
{

    _capslsArray = capslsArray;

    self.viewCapsulesVC.capslsArray = _capslsArray;

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark Lock Orientation

- (BOOL) shouldAutorotate
{
    if (self.chooseTypeContainerView.hidden == NO)
    {
        return NO;
    }
    else
    {
        return YES;
    }
}
//
//-(NSUInteger)supportedInterfaceOrientations
//{
//    return UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskLandscapeLeft | UIInterfaceOrientationMaskLandscapeRight;
//}
//
//- (UIInterfaceOrientation) preferredInterfaceOrientationForPresentation {
//    // Return the orientation you'd prefer - this is what it launches to. The
//    // user can still rotate. You don't have to implement this method, in which
//    // case it launches in the current orientation
//    return UIInterfaceOrientationPortrait;
//}



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

    [self.chooseTypeContainerView setHidden:NO];
    self.chooseTypeContainerView.alpha = 0;

    [UIView animateWithDuration:0.5 animations:^{
        self.viewCapsulesContainerView.alpha = 0;
        self.chooseTypeContainerView.alpha = 1;
    } completion:nil];

    [self.viewCapsulesContainerView setHidden:YES];


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
    self.viewCapsulesContainerView.alpha = 0;

    [UIView animateWithDuration:0.5 animations:^{
        self.viewCapsulesContainerView.alpha = 1;
        self.chooseTypeContainerView.alpha = 0;
    } completion:nil];

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
        self.viewCapsulesVC = segue.destinationViewController;
        self.viewCapsulesVC.capslsArray = self.capslsArray;
        self.viewCapsulesVC.sentCapslsArray = self.sentCapslsArray;
        
        self.viewCapsulesVC.availableCapslsArray = self.availableCapslsArray;
        self.viewCapsulesVC.shouldShowSent = self.shouldShowSent;
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
