//
//  JCASplashViewController.m
//  Capsl
//
//  Created by Mobile Making on 11/29/14.
//  Copyright (c) 2014 Christina Gunarto. All rights reserved.
//

#import "JCAMainViewController.h"

@interface JCAMainViewController ()

@property (strong, nonatomic) IBOutlet UIView *capsuleListContainerView;
@property (strong, nonatomic) IBOutlet UIView *chooseTypeContainerView;
@property NSMutableArray *toolbarButtons;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *sendCapsuleButton;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *viewCapsulesButton;

@end

@implementation JCAMainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    self.toolbarButtons = [self.toolBar.items mutableCopy];

    [self.view addSubview:self.capsuleListContainerView];
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

    [self.capsuleListContainerView setHidden:YES];
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

    [self.capsuleListContainerView setHidden:NO];
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
    }
    else if ([segue.identifier isEqualToString:@"chooseTypeSegue"])
    {
        [self.capsuleListContainerView setHidden:YES];
        [self.chooseTypeContainerView setHidden:NO];

    }
    else
    {
        
    }
    
}

@end
