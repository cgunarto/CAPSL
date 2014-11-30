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
@property (strong, nonatomic) IBOutlet UIToolbar *toolBar;
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
    [self.capsuleListContainerView setHidden:YES];
    [self.chooseTypeContainerView setHidden:NO];

}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Actions

- (IBAction)onSendCapsuleButtonTapped:(UIBarButtonItem *)sender
{

    [self.capsuleListContainerView setHidden:YES];
    [self.chooseTypeContainerView setHidden:NO];
    [self.toolbarButtons removeObject:self.sendCapsuleButton];
    [self.toolbarButtons insertObject:self.viewCapsulesButton atIndex:2];

    self.toolBar.items = self.toolbarButtons;

}

- (IBAction)onViewCapsulesButtonTapped:(UIBarButtonItem *)sender
{

    [self.capsuleListContainerView setHidden:NO];
    [self.chooseTypeContainerView setHidden:YES];
    [self.toolbarButtons removeObject:self.viewCapsulesButton];
    [self.toolbarButtons insertObject:self.sendCapsuleButton atIndex:2];

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
