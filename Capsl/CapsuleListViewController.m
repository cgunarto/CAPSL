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
#import "MessageViewController.h"
#import "RecordVideoViewController.h"
#import "IndexConverter.h"

@import MediaPlayer;

@interface CapsuleListViewController () <UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate>

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property NSArray *tableViewData;
@property NSMutableArray *senderPics;
@property NSMutableArray *recipientPics;

@property (strong, nonatomic) MPMoviePlayerViewController *videoController;

@property NSInteger availableCapslsCount;
@property BOOL shouldShowMessage;
@property (strong, nonatomic) IBOutlet UILabel *promptLabel;

@end

@implementation CapsuleListViewController

//TODO: delete video segue in Storyboard
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [self.tableView reloadData];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor clearColor];
    self.availableCapslsCount = 0;

    self.senderPics = [@[] mutableCopy];
    self.recipientPics = [@[] mutableCopy];

    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.backgroundColor = [UIColor clearColor];

    // make transparent the system toolbar that is there to space the bottom of scroll
    [self.navigationController.toolbar setBackgroundImage:[UIImage new] forToolbarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    self.navigationController.navigationBar.translucent = YES;

    [self scrollToEarliestUnopenedCapsule];

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

    [self updateUserInterface];
}

- (void)updateUserInterface
{
    [self.tableView reloadData];

    [self scrollToEarliestUnopenedCapsule];

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

    [profilePhoto getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
            cell.profileImage.image = [UIImage imageWithData:data];
        }];

    [cell drawCellForCapsl:capslForCell ThatWasSent:self.shouldShowSent];

    if ([capslForCell.recipient.objectId isEqualToString:kCapslTeamObjectID])
    {
        cell.hidden = YES;
        self.promptLabel.hidden = NO;
    }
    else
    {
        self.promptLabel.hidden = YES;
    }

    return cell;
}


#pragma mark - Helper Method
- (void)scrollToEarliestUnopenedCapsule
{

    NSInteger index = [IndexConverter indexForSoonestUnopenedCapsuleInArray:self.tableViewData];

    // scroll to first unopened capsule in received, 3 capsules prior to first unopened in sent
            // sent capsules

    if (self.shouldShowSent)
    {
        // set index for 3 prior to first viewed if available, or else show first
        if (index > 3)
        {
            index = index - 3;
        }
        else if (index == 0)
        {
            index = 0;
        }
        
    }

    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
    [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:NO];


//    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:(openCapslsCount) inSection:0];
//    [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:NO];
}

- (NSArray *)reverseArray:(NSArray *)arrayToReverse
{

    NSMutableArray *newArray = [@[] mutableCopy];
    for (NSObject *object in arrayToReverse)
    {
        [newArray insertObject:object atIndex:0];
    }

    return [NSArray arrayWithArray:newArray];
    
}

#pragma mark - Saving Data for Viewed At

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Capsl *capsl = self.tableViewData[indexPath.row];

    //If it's multimedia Capsl
    if ([capsl.type isEqualToString:@"multimedia"])
    {
        BOOL capslIsUnlocked = [self shouldPerformSegueWithIdentifier:@"multimediaSegue" sender:self];
        if (capslIsUnlocked)
        {
            [self performSegueWithIdentifier:@"multimediaSegue" sender:self];

        }
    }

    //If it's a video
    else
    {
        BOOL capslIsAvailable = [self isCapslAvailableToView:capsl];
        if (capslIsAvailable)
        {
            [self playVideo:capsl];
        }
    }
}

#pragma mark Playing Video

- (void)playVideo:(Capsl *)capsl
{
    //TODO: Return to same orientation when it opens and closes
    NSURL *url = [NSURL URLWithString:capsl.video.url];
    self.videoController = [[MPMoviePlayerViewController alloc] init];
    self.videoController.moviePlayer.movieSourceType = MPMovieSourceTypeStreaming;
    [self.videoController.moviePlayer setContentURL:url];

    [self presentViewController:self.videoController animated:YES completion:nil];
}

#pragma mark - segue life cycle

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];

    Capsl *capsl = self.tableViewData[indexPath.row];
    return [self isCapslAvailableToView:capsl];
}

- (BOOL)isCapslAvailableToView:(Capsl *)capsl
{
    long elapsedSeconds = [capsl.deliveryTime timeIntervalSinceNow];

    // consideration only required if viewing received
    if (!self.shouldShowSent)
    {
        //if it's unviewed and unlocked
        if (!capsl.viewedAt && elapsedSeconds < 0)
        {
            capsl.viewedAt = [NSDate date];
            [capsl saveInBackground];

            //SENDING PUSH MESSAGE to the sender, when CAPSL is viewed by recipient
            PFQuery *pushQuery = [PFInstallation query];
            [pushQuery whereKey:@"capslr" equalTo:capsl.sender];

            PFPush *push = [[PFPush alloc]init];
            //TODO: Send push to multiple device tokens
            //TODO: Set it to open a message or the right page
            NSString *pushString = [NSString stringWithFormat:@"%@ viewed your Capsl", capsl.recipient.name];
            [push setQuery:pushQuery];
            [push setMessage:pushString];
            [push sendPushInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
             {
                 if (error)
                 {
                     NSLog(@"%@ error", error.localizedDescription);
                 }
             }];
        }

        //if it's unlocked
        if (elapsedSeconds < 0)
        {
            return YES;
        }
        else
        {
            return NO;
        }
    }

    return YES;
}



- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    Capsl *capsl = self.tableViewData[indexPath.row];

    if ([segue.identifier isEqualToString:@"multimediaSegue"])
    {
        MessageViewController *vc = segue.destinationViewController;
        vc.chosenCapsl = capsl;
        vc.isEditing = NO;
    }
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


@end
