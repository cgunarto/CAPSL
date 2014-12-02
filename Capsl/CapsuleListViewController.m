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
#import "JCATimelineRootViewController.h"
#import "MessageDetailViewController.h"

@interface CapsuleListViewController () <UITableViewDataSource, UITableViewDelegate>

@property JCATimelineRootViewController *timelineRootVC;
@property (strong, nonatomic) IBOutlet UIView *timelineViewControllerContainer;
@property (strong, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic)  NSArray *capslsArray;

@end

@implementation CapsuleListViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    [Capslr returnCapslrFromPFUser:[PFUser currentUser] withCompletion:^(Capslr *currentCapslr, NSError *error) {
        Capslr *capslr = [Capslr object];
        capslr.objectId = currentCapslr.objectId;

        //calling class method to get capsls for current user only
        [Capsl searchCapslByKey:@"recipient" orderByAscending:@"deliveryTime" equalTo:capslr completion:^(NSArray *objects, NSError *error) {
            if (!error)
            {
                self.capslsArray = objects;
                self.timelineRootVC.capslsArray = objects;

                // Navigation Title
                self.navigationItem.title = [NSString stringWithFormat:@"Capsl Count: %lu", (unsigned long)self.capslsArray.count];
            }
            else
            {
                NSLog(@"%@", error.localizedDescription);
            }
        }];
    }];

    self.navigationController.navigationBar.backgroundColor = [UIColor greenColor];
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

    cell.profileImage.layer.cornerRadius = cell.profileImage.frame.size.width/2;
    cell.profileImage.clipsToBounds = YES;

    // querying for sender data (need to refactor later)
    PFQuery *query = [Capslr query];
    [query whereKey:@"objectId" equalTo: capsl.sender.objectId];
    [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {

        cell.fromLabel.text = [NSString stringWithFormat:@"From: %@", object[@"username"]];

        //Sender Profile Image (using categories)
        PFFile *profilePhoto = object[@"profilePhoto"];
        cell.profileImage.image = nil;
        [profilePhoto getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
            cell.profileImage.image = [UIImage imageWithData:data] ;
        }];
    }];

    // Setting the delivery date
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MM-dd-yyyy"];
    NSDate *deliveryDate = capsl.deliveryTime;

    cell.deliveryDateLabel.text = [NSString stringWithFormat:@"D-Day: %@", [dateFormatter stringFromDate:deliveryDate]];

    [cell startTimerWithDate:deliveryDate];

    return cell;
}

#pragma mark - Saving Data for Viewed At
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

    Capsl *capsl = self.capslsArray[indexPath.row];
    long elapsedSeconds = [capsl.deliveryTime timeIntervalSinceDate:[NSDate date]];

    if ((!capsl.viewedAt) && elapsedSeconds <= 0)
    {
        capsl.viewedAt = [NSDate date];
        [capsl saveInBackground];
    }
}

#pragma mark - segue life cycle

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"segueToMessageVC"])
    {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        Capsl *capsl = self.capslsArray[indexPath.row];

        MessageDetailViewController *messageDetailVC = segue.destinationViewController;
        messageDetailVC.chosenCapsl = capsl;

    }
    else
    {
        self.timelineRootVC = segue.destinationViewController;
    }

}

#pragma mark - Alert when timer expires
-(void)presentCanOpenMeAlert
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"CAPSL UNLOCKED!" message:nil preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okButton = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        // UNLOCK CAPSL!!

    }];

    [alert addAction:okButton];
    [self presentViewController:alert animated:YES completion:nil];
}


@end
