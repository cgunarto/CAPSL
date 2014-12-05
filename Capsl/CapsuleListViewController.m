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
@property NSArray *tableViewData;
@property NSMutableArray *senderPics;
@property NSMutableArray *recipientPics;

@property NSInteger availableCapslsCount;

@end

@implementation CapsuleListViewController


- (void)viewDidLoad
{
    [super viewDidLoad];

    //TODO: fix capslCount!!

    self.view.backgroundColor = [UIColor clearColor];


    self.tableView.contentInset = UIEdgeInsetsMake(self.navigationController.navigationBar.frame.size.height, 0, 44, 0);

    self.availableCapslsCount = 0;

    self.senderPics = [@[] mutableCopy];
    self.recipientPics = [@[] mutableCopy];

    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.backgroundColor = [UIColor clearColor];



//    for (NSDate *date in [self.capslsArray valueForKey:@"deliveryTime"])
//    {
//        if ([date timeIntervalSinceNow] < 0)
//        {
//            availableCapslsCount++;
//        }
//    }


}


-(void)setShouldShowSent:(BOOL)shouldShowSent
{
    _shouldShowSent = shouldShowSent;

    if (_shouldShowSent)
    {
        self.tableViewData = self.sentCapslsArray;
    }
    else
    {
        self.tableViewData = self.capslsArray;
    }

    [self.tableView reloadData];
}


// Automatically reloads the tableview whenever capslsArray is updated..

//-(void)setCapslsArray:(NSArray *)capslsArray
//{
//    _capslsArray = capslsArray;
//    [self.tableView reloadData];
//
//}



#pragma mark - Tableview Delegate Methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    return self.tableViewData.count;

}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CapslTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];

    Capsl *capslForCell = self.tableViewData[indexPath.row];

    PFFile *profilePhoto = [[PFFile alloc] init];

    NSMutableArray *profilePicArray = [@[] mutableCopy];

    if (self.shouldShowSent)
    {
        cell.capslrLabel.text = capslForCell.recipient.username;
        profilePhoto = capslForCell.recipient.profilePhoto;

        profilePicArray = self.recipientPics;
    }
    else
    {
        cell.capslrLabel.text = capslForCell.sender.username;
        profilePhoto = capslForCell.sender.profilePhoto;
        profilePicArray = self.senderPics;
    }


    //Sender Profile Image
    if (profilePicArray.count != 0)
    {
        cell.profileImage.image = profilePicArray[indexPath.row];

    }

    cell.profileImage.layer.cornerRadius = cell.profileImage.frame.size.width/2;
    cell.profileImage.clipsToBounds = YES;

//    if ([cell.profileImage.image isEqual:[UIImage imageNamed:@"default"]])
//    {
        [profilePhoto getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
            cell.profileImage.image = [UIImage imageWithData:data];
//            [profilePicArray replaceObjectAtIndex:indexPath.row withObject:[UIImage imageWithData:data]];
        }];
//    }
//    else
//    {
//        cell.profileImage.image = profilePicArray[indexPath.row];
//    }

    [cell drawCellForCapsl:capslForCell];

    // updating timer string...
    [cell updateLabelsForCapsl:capslForCell];

    //Capsl sent to...

    return cell;
}


#pragma mark - Helper Method
- (void)scrollToSoonestCapslWithCount:(NSInteger)openCapslsCount
{
//    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:(openCapslsCount) inSection:0];
//    [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:NO];
}


#pragma mark - Saving Data for Viewed At
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

    Capsl *capsl = self.tableViewData[indexPath.row];
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
    Capsl *capsl = self.tableViewData[indexPath.row];

    MessageDetailViewController *messageDetailVC = segue.destinationViewController;
    messageDetailVC.chosenCapsl = capsl;

}

#pragma mark - helper methods

- (void)updateClocks
{
    for (CapslTableViewCell *cell in self.tableView.visibleCells)
    {
        
        NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];

        Capsl *capsl = self.tableViewData[indexPath.row];
        [cell updateLabelsForCapsl:capsl];

    }
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
