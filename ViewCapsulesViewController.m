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

@interface ViewCapsulesViewController ()

@property (strong, nonatomic) IBOutlet UIView *timelineContainer;
@property (strong, nonatomic) IBOutlet UIView *capslListContainer;
@property JCATimelineRootViewController *timelineRootVC;
@property CapsuleListViewController *capslListVC;
@property NSTimer *timer;


@property Capslr *capslr;
@property (nonatomic)  NSArray *capslsArray;

@end

@implementation ViewCapsulesViewController

- (void)viewDidLoad {
    [super viewDidLoad];


    [Capslr returnCapslrFromPFUser:[PFUser currentUser] withCompletion:^(Capslr *currentCapslr, NSError *error) {
        Capslr *capslr = [Capslr object];
        capslr.objectId = currentCapslr.objectId;

        //calling class method to get capsls for current user only
        [Capsl searchCapslByKey:@"recipient" orderByAscending:@"deliveryTime" equalTo:capslr completion:^(NSArray *objects, NSError *error) {
            if (!error)
            {
                self.timelineRootVC.capslsArray = objects;
                self.capslListVC.capslsArray = objects;
                self.capslListVC.capslCount = objects.count;
            }
            else
            {
                NSLog(@"%@", error.localizedDescription);
            }
        }];
    }];

}

- (void)viewWillAppear:(BOOL)animated
{
    // put timer here

    self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateUIInSubviews) userInfo:nil repeats:YES];

}

- (void)viewWillDisappear:(BOOL)animated
{
    // invalidate timer here
}

- (BOOL)prefersStatusBarHidden {
    return YES;
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

    }
    else
    {

        //        [self.timelineViewControllerContainer setHidden:YES];
        //        [self.view sendSubviewToBack:self.timelineViewControllerContainer];
        [self.view addSubview:self.capslListContainer];
        [self.view bringSubviewToFront:self.capslListContainer];
        [self.capslListContainer setHidden:NO];
        [self.timelineContainer removeFromSuperview];
        
    }
    
}

#pragma mark - helper methods

- (void)updateUIInSubviews
{

    [self.capslListVC updateClocks];
//    [self.timelineRootVC updateClocks];

}


#pragma mark - segue life cycle

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"capslListSegue"])
    {
        UINavigationController *navVC = segue.destinationViewController;
        self.capslListVC = navVC.childViewControllers.firstObject;
    }
    else
    {
        self.timelineRootVC = segue.destinationViewController;
    }
    
}


@end
