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
#import "JCAMainViewController.h"
#import "MessageDetailViewController.h"

@interface CapsuleListViewController () <UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate>

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *capslsBarButtonItem;
@property NSInteger availableCapslsCount;

@end

@implementation CapsuleListViewController


- (void)viewDidLoad
{
    [super viewDidLoad];

    //TODO: fix capslCount!!
    
    self.navigationController.navigationBar.backgroundColor = [UIColor greenColor];
    self.tableView.contentInset = UIEdgeInsetsMake(self.navigationController.navigationBar.frame.size.height, 0, 44, 0);

    self.availableCapslsCount = 0;

//    for (NSDate *date in [self.capslsArray valueForKey:@"deliveryTime"])
//    {
//        if ([date timeIntervalSinceNow] < 0)
//        {
//            availableCapslsCount++;
//        }
//    }


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
    NSInteger arrayCount;

    if ([self.capslsBarButtonItem.title isEqual:@"Sent Capsules"])
    {
        arrayCount =  self.capslsArray.count;
    }
    else if ([self.capslsBarButtonItem.title isEqual:@"Recieved Capsules"])
    {
        arrayCount = self.sentCapslsArray.count;
    }

    return arrayCount;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CapslTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];

    if ([self.capslsBarButtonItem.title isEqual:@"Sent Capsules"])
    {

        Capsl *capsl = self.capslsArray[indexPath.row];

        NSDate *deliveryDate = capsl.deliveryTime;

        cell.deliveryDateLabel.text = [JKCountDownTimer formatDateWithDate:deliveryDate];

        // updating timer string...
        [cell updateTimeLabelForCapsl:capsl];

        cell.profileImage.layer.cornerRadius = cell.profileImage.frame.size.width/2;
        cell.profileImage.clipsToBounds = YES;

        // querying for sender data (need to refactor later)
        PFQuery *query = [Capslr query];
        [query whereKey:@"objectId" equalTo: capsl.sender.objectId];
        [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {

            cell.capslrLabel.text = [NSString stringWithFormat:@"From: %@", object[@"username"]];

            //Sender Profile Image
            PFFile *profilePhoto = object[@"profilePhoto"];
            cell.profileImage.image = nil;

            [profilePhoto getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                cell.profileImage.image = [UIImage imageWithData:data];
            }];
        }];

    }
    else if ([self.capslsBarButtonItem.title isEqual:@"Recieved Capsules"])
    {
        Capsl *capsl = self.sentCapslsArray[indexPath.row];

        //Capsl sent to...
        PFQuery *query = [Capslr query];
        [query whereKey:@"objectId" equalTo: capsl.recipient.objectId];
        [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {

            cell.capslrLabel.text = [NSString stringWithFormat:@"To: %@", object[@"username"]];

            //Reciever Profile Image
            PFFile *profilePhoto = object[@"profilePhoto"];
            cell.profileImage.image = nil;

            [profilePhoto getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                cell.profileImage.image = [UIImage imageWithData:data];
            }];
        }];

        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"MMM dd, yyyy hh:mm a"];
        NSDate *deliveryDate = capsl.deliveryTime;

        cell.deliveryDateLabel.text = [NSString stringWithFormat:@"%@", [dateFormatter stringFromDate:deliveryDate]];

        NSDate *viewedAtDate = capsl.viewedAt;
        if (viewedAtDate)
        {
            cell.timerLabel.text = @"Opened";
        }
        else
        {
            cell.timerLabel.text = @"Not Opened";
        }
    }
    return cell;
}


#pragma mark - Helper Method
- (void)scrollToSoonestCapslWithCount:(NSInteger)openCapslsCount
{
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:(openCapslsCount) inSection:0];
    [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:NO];
}


#pragma mark - Saving Data for Viewed At
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

    Capsl *capsl = self.capslsArray[indexPath.row];
    long elapsedSeconds = [capsl.deliveryTime timeIntervalSinceNow];

    if ((!capsl.viewedAt) && elapsedSeconds <= 0)
    {
        capsl.viewedAt = [NSDate date];
        [capsl saveInBackground];
    }
}

#pragma mark - segue life cycle

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{

    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    Capsl *capsl = self.capslsArray[indexPath.row];

    MessageDetailViewController *messageDetailVC = segue.destinationViewController;
    messageDetailVC.chosenCapsl = capsl;

}

#pragma mark - helper methods

- (void)updateClocks
{
    for (CapslTableViewCell *cell in self.tableView.visibleCells)
    {
        NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];

        if ([self.capslsBarButtonItem.title isEqual: @"Sent Capsules"])
        {
            Capsl *capsl = self.capslsArray[indexPath.row];
            [cell updateTimeLabelForCapsl:capsl];
        }
        else
        {
            nil;
        }
    }
}


- (IBAction)onSentCapsulesButtonPressed:(UIBarButtonItem *)sender
{
    if ([self.capslsBarButtonItem.title isEqual: @"Sent Capsules"])
    {
        self.capslsBarButtonItem.title = @"Recieved Capsules";
    }
    else if ([self.capslsBarButtonItem.title isEqual:@"Recieved Capsules"])
    {
        self.capslsBarButtonItem.title = @"Sent Capsules";
    }

    [self.tableView reloadData];
}

// Alert when timer expires
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
