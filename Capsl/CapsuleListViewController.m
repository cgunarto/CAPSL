//
//  CapsuleListViewController.m
//  Capsl
//
//  Created by CHRISTINA GUNARTO on 11/25/14.
//  Copyright (c) 2014 Christina Gunarto. All rights reserved.
//

#import "CapsuleListViewController.h"
#import "CapslTableViewCell.h"
#import "Capsl.h"
#import "JKCountDownTimer.h"

@interface CapsuleListViewController () <UITableViewDataSource, UITableViewDelegate, JKCountdownTimerDelegate>

@property (strong, nonatomic) IBOutlet UIView *timelineViewControllerContainer;
@property (nonatomic)  NSArray *capslsArray;
@property NSMutableArray *timerArray;
@property NSMutableArray *dynamicTimerArray;

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property Capsl *capsl;
@property (nonatomic)  NSString *timerString;

@end

@implementation CapsuleListViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

//     need to refactor this code later
    PFQuery *query = [Capslr query];
    [query whereKey:@"user" equalTo:[PFUser currentUser]];
    [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {

        Capslr *capslr = [Capslr object];
        capslr.objectId = object.objectId;

        //calling class method to get capsls for current user only
        [Capsl searchCapslByKey:@"recipient" orderByAscending:@"deliveryTime" equalTo:capslr completion:^(NSArray *objects, NSError *error) {
            if (!error)
            {
                self.capslsArray = objects;

                self.timerArray = [[objects valueForKey:@"deliveryTime"] mutableCopy];
            }
            else
            {
                NSLog(@"%@", error.localizedDescription);
            }
        }];
    }];

}


- (void)viewDidLayoutSubviews
{

    if (UIInterfaceOrientationIsLandscape([UIDevice currentDevice].orientation))
    {

        [self.view addSubview:self.timelineViewControllerContainer];
        [self.view bringSubviewToFront:self.timelineViewControllerContainer];
        [self.timelineViewControllerContainer setHidden:NO];
        [self.timelineViewControllerContainer setNeedsDisplay];

    }
    else
    {

        [self.timelineViewControllerContainer setHidden:YES];
        [self.view sendSubviewToBack:self.timelineViewControllerContainer];
        [self.timelineViewControllerContainer removeFromSuperview];


    }

}


// Automatically reloads the tableview whenever capslsArray is updated..
-(void)setCapslsArray:(NSArray *)capslsArray
{
    _capslsArray = capslsArray;
    [self.tableView reloadData];
}

#pragma mark - Tableview Delegate Methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.capslsArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CapslTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    Capsl *capsl = self.capslsArray[indexPath.row];

    // querying for sender data (need to refactor later)
    PFQuery *query = [Capslr query];
    [query whereKey:@"objectId" equalTo: capsl.sender.objectId];
    [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {

        cell.fromLabel.text = [NSString stringWithFormat:@"From: %@", object[@"username"]];
    }];

    // Setting the delivery date
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MM-dd-yyyy"];
    NSDate *deliveryDate = capsl.deliveryTime;

    cell.deliveryDateLabel.text = [NSString stringWithFormat:@"D-Day: %@", [dateFormatter stringFromDate:deliveryDate]];

    //TODO: make the timer tick in the cell... via setting the custom cell as the delegate for the timer(?)

    JKCountDownTimer *timer = [[JKCountDownTimer alloc] initWithDeliveryDate:deliveryDate withDelegate:self];
    [timer updateLabel];

//    NSString *timeString = self.timerArray[indexPath.row];

//    cell.timerLabel.text = timeString;

    return cell;
}

#pragma mark - JKTimer Delegate Method
-(void)counterUpdated:(NSString *)dateString
{
    if (dateString == nil)
    {
        [self presentCanOpenMeAlert];
    }
    else
    {
//        self.timerString = dateString;
//        NSLog(@"%@", self.timerString);

        self.dynamicTimerArray = [@[] mutableCopy];

        for (NSDate *date in self.timerArray)
        {
            [self.dynamicTimerArray addObject:dateString];

        }


    }
}

#pragma mark - Alert when timer expires
-(void)presentCanOpenMeAlert
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"You can now open your capsl!" message:nil preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okButton = [UIAlertAction actionWithTitle:@"Open capsl" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        // UNLOCK CAPSL!!

    }];

    [alert addAction:okButton];
    [self presentViewController:alert animated:YES completion:nil];
}


@end
