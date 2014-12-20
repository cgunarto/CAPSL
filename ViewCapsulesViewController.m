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
#import "JCALocalNotification.h"
#import "IndexConverter.h"

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


//
//#pragma mark Lock Orientation
//
//- (BOOL) shouldAutorotate
//{
//    return YES;
//}
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
//    return UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskLandscapeLeft | UIInterfaceOrientationMaskLandscapeRight;
//}


- (void)viewDidLoad
{
    [super viewDidLoad];

//    self.view.backgroundColor = [UIColor colorWithPatternImage:kViewCapsulesWallpaper];

    self.capslListVC.availableCapslsArray = [@[] mutableCopy];

    self.capslListVC.capslsArray = self.capslsArray;
    self.capslListVC.sentCapslsArray = self.sentCapslsArray;
    self.timelineRootVC.capslsArray = self.capslsArray;
    self.timelineRootVC.sentCapslsArray = self.sentCapslsArray;

    self.timelineRootVC.shouldShowSent = NO;
    self.capslListVC.shouldShowSent = NO;
    [self clearAndcreateLocalNotificationsFromCapslObjects:self.capslsArray];

//    [Capslr returnCapslrFromPFUser:[PFUser currentUser] withCompletion:^(Capslr *currentCapslr, NSError *error) {
//
//        Capslr *capslr = [Capslr object];
//        capslr.objectId = currentCapslr.objectId;
//
//        //calling class method to get capsls for current user only
//        //TODO: Add Local Notification - clear first and then schedule 64 max
//        //Todo: maybe add 2 nofication for stretch goal
//        //Order by opening date
//        [Capsl searchCapslByKey:@"recipient" orderByAscending:@"deliveryTime" equalTo:capslr completion:^(NSArray *objects, NSError *error) {
//            if (!error)
//            {
//                self.timelineRootVC.capslsArray = objects;
//                self.capslListVC.capslsArray = objects;
//                [SVProgressHUD dismiss];
//
//                NSInteger availableCapslsCount = 0;
//
//                for (NSDate *date in [objects valueForKey:@"deliveryTime"])
//                {
//                    if ([date timeIntervalSinceNow] < 0)
//                    {
//                        availableCapslsCount++;
//                    }
//                }
//
//                self.timelineRootVC.shouldShowSent = NO;
//                self.capslListVC.shouldShowSent = NO;
//                [self clearAndcreateLocalNotificationsFromCapslObjects:objects];
//            }
//
//            else
//            {
//                [SVProgressHUD showErrorWithStatus:@"Connection Error"];
//                NSLog(@"%@", error.localizedDescription);
//            }
//        }];
//
//        // get data for capsls sent
//        [Capsl searchCapslByKey:@"sender" orderByAscending:@"deliveryTime" equalTo:capslr completion:^(NSArray *objects, NSError *error) {
//            if (!error)
//            {
//                self.capslListVC.sentCapslsArray = objects;
//                self.timelineRootVC.sentCapslsArray = objects;
//            }
//            else
//            {
//                NSLog(@"%@", error.localizedDescription);
//            }
//        }];
//
//    }];

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
    [super viewWillAppear:animated];
    // put timer here
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateClocksInSubviews) userInfo:nil repeats:YES];

}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
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

        [self.timelineRootVC updateTimelines];

//        self.view.backgroundColor = [UIColor colorWithPatternImage:kTimelineWallpaper];

    }
    else
    {

        //        [self.timelineViewControllerContainer setHidden:YES];
        //        [self.view sendSubviewToBack:self.timelineViewControllerContainer];
        [self.view addSubview:self.capslListContainer];

        CGRect capslListContainerFrame = self.capslListContainer.frame;
        capslListContainerFrame.size = CGSizeMake(self.capslListContainer.frame.size.height, self.capslListContainer.frame.size.width);
        self.capslListContainer.frame = capslListContainerFrame;
        
        [self.view bringSubviewToFront:self.capslListContainer];
        [self.capslListContainer setHidden:NO];
        [self.timelineContainer removeFromSuperview];
        [self.view bringSubviewToFront:self.sentReceivedSegmentedControl];

        self.view.backgroundColor = [UIColor clearColor];

//        self.view.backgroundColor = [UIColor colorWithPatternImage:kViewCapsulesWallpaper];

    }
    
}


#pragma mark - override Setters

-(void)setCapslsArray:(NSArray *)capslsArray
{

    _capslsArray = capslsArray;
    //tell the two new view controllers to update
    self.capslListVC.capslsArray = _capslsArray;
    self.capslListVC.shouldShowSent = NO;
    [self.capslListVC updateUserInterface];
    self.timelineRootVC.capslsArray = _capslsArray;

}

- (void)setSentCapslsArray:(NSArray *)sentCapslsArray
{
    _sentCapslsArray = sentCapslsArray;
    self.capslListVC.sentCapslsArray = _sentCapslsArray;
    [self.capslListVC updateUserInterface];
    self.timelineRootVC.sentCapslsArray = _sentCapslsArray;

}

#pragma mark - helper methods

- (void)updateClocksInSubviews
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

#pragma mark - Helper Method

- (void)clearAndcreateLocalNotificationsFromCapslObjects:(NSArray *)objects
{
    //Cancel all notifications before creating new ones
    [[UIApplication sharedApplication] cancelAllLocalNotifications];

    //IF application is active, create notifications but CONSOLIDATE all that is about to be shown NOW
    UIApplication *application = [UIApplication sharedApplication];
    if (application.applicationState == UIApplicationStateActive)
    {
        [JCALocalNotification consolidateNowLocalNotificationsFromCapslObjectsArray:objects];
    }

    //ELSE Create and store local notifications for unViewedCapsl from an array of Capsl Objects
    else
    {
        [JCALocalNotification createLocalNotificationForUnviewedCapslFromCapslObjectsArray:objects];
    }
    
}


@end
