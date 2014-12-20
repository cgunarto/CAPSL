//
//  TimelineCollectionViewController.m
//  Timeline Test 2
//
//  Created by Mobile Making on 11/24/14.
//  Copyright (c) 2014 Alex Hsu. All rights reserved.
//

#import "JCACapslViewController.h"
#import "JCACapslCollectionViewCell.h"
#import "Capsl.h"
#import "Capslr.h"
#import "JKCountDownTimer.h"
#import "IndexConverter.h"
#import "MessageViewController.h"
#import <QuartzCore/QuartzCore.h>

@import MediaPlayer;


@interface JCACapslViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

@property (strong, nonatomic) IBOutlet UICollectionView *capslView;
@property UICollectionViewFlowLayout *flowLayout;
@property CGFloat screenHeight;
@property CGFloat scrubBarMonthSegment;
@property NSArray *capslsInAYear;
@property NSArray *monthsOfTheYear;
@property NSArray *collectionViewData;
@property (strong, nonatomic) IBOutlet UILabel *promptLabel;

@property (strong, nonatomic) MPMoviePlayerViewController *videoController;

@end

@implementation JCACapslViewController

static NSString * const reuseIdentifier = @"CapslCell";

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.capslView.backgroundColor = [UIColor clearColor];
    self.flowLayout = (UICollectionViewFlowLayout *)self.capslView.collectionViewLayout;

    self.screenHeight = [[UIScreen mainScreen] bounds].size.height;
    self.scrubBarMonthSegment = self.screenHeight/12;

    self.monthsOfTheYear = @[@"Jan", @"Feb", @"Mar", @"Apr", @"May", @"Jun", @"Jul", @"Aug", @"Sep", @"Oct", @"Nov", @"Dec"];



    
    // Uncomment the following line to preserve selection between presentations
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Register cell classes
//    [self.timelineView registerClass:[JCACapslCollectionViewCell class] forCellWithReuseIdentifier:reuseIdentifier];

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self updateUserInterface];
//    [self scrollToEarliestUnopenedCapsule];
}

- (void)setCapslGrandArray:(NSArray *)capslGrandArray
{
    _capslGrandArray = capslGrandArray;
    [self updateUserInterface];
//    [self scrollToEarliestUnopenedCapsule];

}

- (void)setSentCapslsGrandArray:(NSArray *)sentCapslsGrandArray
{
    _sentCapslsGrandArray = sentCapslsGrandArray;
    [self updateUserInterface];
//    [self scrollToEarliestUnopenedCapsule];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)showCapslWithYearMultiplier:(NSInteger)yearMultiplier
                      andMonthIndex:(NSInteger)monthIndex
                      andCapslIndex:(NSInteger)capslIndex
                      withAnimation:(BOOL)animated
{

    NSIndexPath *monthIndexPath = [NSIndexPath indexPathForItem:capslIndex inSection:(yearMultiplier * 12) + monthIndex];

    UICollectionViewLayoutAttributes *attributes = [self.capslView layoutAttributesForItemAtIndexPath:monthIndexPath];
    CGRect capslRect = attributes.frame;
    CGPoint capslViewOffset = CGPointMake(capslRect.origin.x - self.flowLayout.headerReferenceSize.width, 0);
    [self.capslView setContentOffset:capslViewOffset animated:animated];

//        [self.capslView scrollToItemAtIndexPath:monthIndexPath atScrollPosition:UICollectionViewScrollPositionLeft animated:animated];

}


#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{

    return self.collectionViewData.count * 12;

}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{

    NSArray *arrayOfMonths = self.collectionViewData[section/12];
    NSArray *arrayOfCapsules = arrayOfMonths[section % 12];

//    if (section % 12 == 0)
//    {
//        return 0;
//    }
//    else
//    {
        return arrayOfCapsules.count;
//    }

}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    JCACapslCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];


    Capsl *capsl = [self getCapslWithIndexPath:indexPath];

    PFFile *profilePhoto = [[PFFile alloc] init];

    if (self.showSent)
    {
        cell.nameLabel.text = capsl.recipient.username;
        profilePhoto = capsl.recipient.profilePhoto;
    }
    else
    {
        cell.nameLabel.text = capsl.sender.username;
        profilePhoto = capsl.sender.profilePhoto;

    //    cell.nameLabel.text = self.monthsOfTheYear[indexPath.section % 12];
    }

    [cell drawCellforSentCapsl:capsl withSentStatus:self.showSent];

    [cell updateLabelsForCapsl:capsl];

    [profilePhoto getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
        cell.profilePicView.image = [UIImage imageWithData:data];
    }];

//    cell.profilePicView.image = [UIImage imageNamed:@"profilepic1"];

    if (!capsl.objectId || [capsl.recipient.objectId isEqualToString:kCapslTeamObjectID])
    {
        cell.hidden = YES;
    }
    else
    {
        cell.hidden = NO;
    }

    return cell;
}

#pragma mark <UICollectionViewDelegate>

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGSize cellSize = CGSizeMake(self.view.frame.size.height * 0.5, self.view.frame.size.height);
    return cellSize;
}


- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section
{

    NSInteger numberOfCapsls = [collectionView numberOfItemsInSection:section];

    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:0 inSection:section];
    CGSize capslSize = [self collectionView:collectionView layout:collectionViewLayout sizeForItemAtIndexPath:indexPath];
//    CGFloat lineSpacing = [self collectionView:collectionView layout:collectionViewLayout minimumLineSpacingForSectionAtIndex:section];
    CGFloat lineSpacing = self.flowLayout.minimumLineSpacing;

//    UIEdgeInsets insets = [self collectionView:collectionView layout:collectionViewLayout insetForSectionAtIndex:section];
    UIEdgeInsets insets = self.flowLayout.sectionInset;
    CGFloat insetTotal = insets.left + insets.right;

    CGFloat widthOfContent = (capslSize.width * numberOfCapsls) + (lineSpacing * (numberOfCapsls - 1)) + insetTotal;

    CGFloat footerWidth = self.view.frame.size.width - widthOfContent;

    CGSize footerSize = CGSizeMake(footerWidth, 0);

    return footerSize;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    Capsl *capsl = [self getCapslWithIndexPath:indexPath];

    if ([capsl.type isEqualToString:@"multimedia"])
    {
        BOOL capslIsUnlocked = [self shouldPerformSegueWithIdentifier:@"multimediaSegue" sender:capsl];
        if (capslIsUnlocked)
        {
            [self performSegueWithIdentifier:@"multimediaSegue" sender:capsl];
        }
    }

    //If it's a video
    if ([capsl.type isEqualToString:@"video"])
    {
        BOOL capslIsAvailable = [self isCapslAvailableToView:capsl];
        if (capslIsAvailable)
        {
            [self playVideo:capsl];
        }
    }

}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{

//    NSArray *visibleIndexPaths = [self.capslView indexPathsForVisibleItems];
//
//    [self.delegate capslsScrolledToIndex:visibleIndexPaths.firstObject];

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

#pragma mark scroll view methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{

//    NSArray *arrayOfSelectedIndexPaths = [self.capslView indexPathsForSelectedItems];
    NSArray *visibleIndexPaths = [self.capslView indexPathsForVisibleItems];

    // dragged scrollview
    if (scrollView.dragging)
    {
        [self.delegate capslsScrolledToIndex:visibleIndexPaths.firstObject];
    }
    // tapped scrollview
//    else if (arrayOfSelectedIndexPaths.count != 0)
//    {
//        [self.delegate capslsScrolledToIndex:visibleIndexPaths.firstObject];
//    }


}

#pragma mark - helper methods

- (void)updateClocks
{
    for (JCACapslCollectionViewCell *cell in self.capslView.visibleCells)
    {

        NSIndexPath *indexPath = [self.capslView indexPathForCell:cell];

        Capsl *capsl = [self getCapslWithIndexPath:indexPath];

        [cell updateLabelsForCapsl:capsl];

    }
}

- (Capsl *)getCapslWithIndexPath:(NSIndexPath *)indexPath
{

    NSArray *year = self.collectionViewData[indexPath.section / 12];
    NSArray *month = year[indexPath.section % 12];

    Capsl *capsl = month[indexPath.item];

    return capsl;

}

- (void)updateUserInterface
{
    if (self.showSent)
    {
        self.collectionViewData = self.sentCapslsGrandArray;
        Capsl *firstCapsl = self.sentCapslsArray.firstObject;
        if (self.sentCapslsArray.count == 1 && [firstCapsl.recipient.objectId isEqualToString:kCapslTeamObjectID])
        {
            self.promptLabel.hidden = NO;
        }
        else
        {
            self.promptLabel.hidden = YES;
        }
    }
    else
    {
        self.collectionViewData = self.capslGrandArray;
        self.promptLabel.hidden = YES;
    }

    [self.capslView reloadData];

    [self scrollToEarliestUnopenedCapsule];
}

- (void)scrollToEarliestUnopenedCapsule
{

    NSArray *currentArray = [NSArray array];

    if (self.showSent)
    {
        currentArray = self.sentCapslsArray;
    }
    else
    {
        currentArray = self.capslsArray;
    }

    NSInteger indexOfSoonestUnopenedCapsl = [IndexConverter indexForSoonestUnopenedCapsuleInArray:currentArray];
    Capsl *currentSoonestUnopenedCapsule = currentArray[indexOfSoonestUnopenedCapsl];

    NSInteger year = [currentSoonestUnopenedCapsule getYearForCapsl];
    NSInteger month = [currentSoonestUnopenedCapsule getMonthForCapsl];

    NSInteger multiplierForYear = [self.capslYearNumbers indexOfObject:[NSString stringWithFormat:@"%li", (long)year]];
    NSInteger monthIndex = month - 1;

    NSInteger capslIndex = [IndexConverter indexForSoonestUnopenedCapsuleInArrayInItsOwnMonth:currentArray];

    [self showCapslWithYearMultiplier:multiplierForYear andMonthIndex:monthIndex andCapslIndex:capslIndex withAnimation:YES];

//    NSInteger section = (multiplierForYear * 12 + month) - 1;

    //TODO: solve for item index based on mont
// NSIndexPath *indexPath = [NSIndexPath indexPathForItem:0 inSection:section];
//
//    [self.capslView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionLeft animated:YES];

    NSIndexPath *indexPathOfCapsl = [NSIndexPath indexPathForItem:monthIndex inSection:(multiplierForYear * 12) + monthIndex];
    [self.delegate capslsScrolledToIndex:indexPathOfCapsl];

}

#pragma mark - segue life cycle

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(Capsl*)capsl
{
    return [self isCapslAvailableToView:capsl];
}


- (BOOL)isCapslAvailableToView:(Capsl *)capsl
{
    long elapsedSeconds = [capsl.deliveryTime timeIntervalSinceNow];

    // don't open if the capsule is not ready!
    if (!self.showSent)
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

#pragma mark Segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(Capsl*)capsl
{
    if ([segue.identifier isEqualToString:@"multimediaSegue"])
    {
        MessageViewController *vc = segue.destinationViewController;
        vc.chosenCapsl = capsl;
        vc.isEditing = NO;
    }
}




@end
