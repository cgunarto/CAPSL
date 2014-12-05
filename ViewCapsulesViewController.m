//
//  ViewCapsulesViewController.m
//  Capsl
//
//  Created by Mobile Making on 12/1/14.
//  Copyright (c) 2014 Christina Gunarto. All rights reserved.
//

#import "ViewCapsulesViewController.h"
#import "CapsuleListViewController.h"
#import "JCATimelineRootViewController.h"
#import "JKCountDownTimer.h"
#import "Capslr.h"
#import "Capsl.h"
#import "SVProgressHUD.h"

@interface ViewCapsulesViewController ()

@property (strong, nonatomic) IBOutlet UIView *timelineContainer;
@property (strong, nonatomic) IBOutlet UIView *capslListContainer;
@property JCATimelineRootViewController *timelineRootVC;
@property CapsuleListViewController *capslListVC;
@property (strong, nonatomic) IBOutlet UISegmentedControl *sentReceivedSegmentedControl;
@property NSTimer *timer;


@property Capslr *capslr;

@end

@implementation ViewCapsulesViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    [SVProgressHUD show];

    self.view.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.75];
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"wallpaperReceived"]];

    self.capslListVC.availableCapslsArray = [@[] mutableCopy];

    [Capslr returnCapslrFromPFUser:[PFUser currentUser] withCompletion:^(Capslr *currentCapslr, NSError *error) {
        Capslr *capslr = [Capslr object];
        capslr.objectId = currentCapslr.objectId;

        //calling class method to get capsls for current user only
        [Capsl searchCapslByKey:@"recipient" orderByAscending:@"deliveryTime" equalTo:capslr completion:^(NSArray *objects, NSError *error) {
            if (!error)
            {
                self.timelineRootVC.capslsArray = objects;
                self.capslListVC.capslsArray = objects;

                [SVProgressHUD dismiss];

                NSInteger availableCapslsCount = 0;

                for (NSDate *date in [objects valueForKey:@"deliveryTime"])
                {
                    if ([date timeIntervalSinceNow] < 0)
                    {
                        availableCapslsCount++;
                    }
                }

                self.timelineRootVC.shouldShowSent = NO;
                self.capslListVC.shouldShowSent = NO;
                
            }
            else
            {
                [SVProgressHUD showErrorWithStatus:@"Connection Error"];
                NSLog(@"%@", error.localizedDescription);
            }
        }];

        // get data for capsls sent
        [Capsl searchCapslByKey:@"sender" orderByAscending:@"deliveryTime" equalTo:capslr completion:^(NSArray *objects, NSError *error) {
            if (!error)
            {
                self.capslListVC.sentCapslsArray = objects;
                self.timelineRootVC.sentCapslsArray = objects;

                [SVProgressHUD dismiss];
            }
            else
            {
                NSLog(@"%@", error.localizedDescription);
            }
        }];

    }];

//    [self.view addSubview:self.sentReceivedSegmentedControl];
//    [self.view bringSubviewToFront:self.sentReceivedSegmentedControl];
//
//    self.sentReceivedSegmentedControl.translatesAutoresizingMaskIntoConstraints = NO;
//
//    NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:self.sentReceivedSegmentedControl attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0];
//    [self.view addConstraint:constraint];
//    self.sentReceivedSegmentedControl.frame = CGRectMake(50, 200, self.sentReceivedSegmentedControl.frame.size.width, self.sentReceivedSegmentedControl.frame.size.height);

}


- (void)viewWillAppear:(BOOL)animated
{
    // put timer here

    self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateUIInSubviews) userInfo:nil repeats:YES];

}

- (void)viewWillDisappear:(BOOL)animated
{
    // invalidate timer here

    [self.timer invalidate];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidLayoutSubviews
{

    if (UIInterfaceOrientationIsLandscape([UIDevice currentDevice].orientation))
    {

        [self.view addSubview:self.timelineContainer];
        [self.view bringSubviewToFront:self.timelineContainer];
        [self.timelineContainer setHidden:NO];
        [self.capslListContainer removeFromSuperview];
        [self.timelineContainer setNeedsDisplay];
        [self.view bringSubviewToFront:self.sentReceivedSegmentedControl];

    }
    else
    {

        //        [self.timelineViewControllerContainer setHidden:YES];
        //        [self.view sendSubviewToBack:self.timelineViewControllerContainer];
        [self.view addSubview:self.capslListContainer];
        [self.view bringSubviewToFront:self.capslListContainer];
        [self.capslListContainer setHidden:NO];
        [self.timelineContainer removeFromSuperview];
        [self.view bringSubviewToFront:self.sentReceivedSegmentedControl];
    }
    
}

#pragma mark - helper methods

- (void)updateUIInSubviews
{

    [self.capslListVC updateClocks];
    [self.timelineRootVC updateClocks];

}


#pragma mark - actions

- (IBAction)onSegmentedControlValueChanged:(UISegmentedControl *)sender
{
    switch (sender.selectedSegmentIndex)
    {
        case 0:
        {
            self.timelineRootVC.shouldShowSent = NO;
            self.capslListVC.shouldShowSent = NO;
            break;
        }
        case 1:
        {
            self.timelineRootVC.shouldShowSent = YES;
            self.capslListVC.shouldShowSent = YES;
            break;
        }
        default:
            break;
    }

}


#pragma mark - segue life cycle

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"capslListSegue"])
    {
        UINavigationController *navVC = segue.destinationViewController;
        self.capslListVC = navVC.childViewControllers.firstObject;
//        self.capslListVC = segue.destinationViewController;
    }
    else
    {
        self.timelineRootVC = segue.destinationViewController;
    }

}


@end
