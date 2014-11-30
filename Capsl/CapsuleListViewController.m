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


@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property Capsl *capsl;
@property (nonatomic)  NSString *timerString;

@end

@implementation CapsuleListViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    //need to refactor this code later
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

    [cell startTimerWithDate:deliveryDate withCompletion:^(NSDate *date) {
        JKCountDownTimer *timer = [[JKCountDownTimer alloc] initWithDeliveryDate:date withDelegate:self];
        [timer updateLabel];
    }];

    return cell;
}

#pragma mark - JKTimer Delegate Method
-(void)counterUpdated:(NSString *)dateString
{
    if ([dateString isEqual: @"OPEN!"])
    {
        [self presentCanOpenMeAlert];
    }
    else
    {
//        self.timerString = dateString;
////        NSLog(@"%@", self.timerString);
    }
}

#pragma mark - Alert when timer expires
-(void)presentCanOpenMeAlert
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"CAPSL UNLOCKED!" message:nil preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okButton = [UIAlertAction actionWithTitle:@"" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        // UNLOCK CAPSL!!

    }];

    [alert addAction:okButton];
    [self presentViewController:alert animated:YES completion:nil];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

}


@end
