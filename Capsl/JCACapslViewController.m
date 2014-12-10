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
#import <QuartzCore/QuartzCore.h>

@interface JCACapslViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

@property (strong, nonatomic) IBOutlet UICollectionView *capslView;
@property UICollectionViewFlowLayout *flowLayout;
@property CGFloat screenHeight;
@property CGFloat scrubBarMonthSegment;
@property NSArray *yearsWithCapsls;
@property NSArray *capslsInAYear;
@property NSArray *monthsOfTheYear;
@property NSArray *collectionViewData;

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
    [self updateData];
//    [self scrollToEarliestUnopenedCapsule];
}

- (void)setCapslGrandArray:(NSArray *)capslGrandArray
{
    _capslGrandArray = capslGrandArray;
    [self updateData];
//    [self scrollToEarliestUnopenedCapsule];

}

- (void)setSentCapslsGrandArray:(NSArray *)sentCapslsGrandArray
{
    _sentCapslsGrandArray = sentCapslsGrandArray;
    [self updateData];
//    [self scrollToEarliestUnopenedCapsule];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)showCapslAtYear:(NSInteger)yearMultiplier andMonth:(NSInteger)monthIndex withAnimation:(BOOL)animated
{

    NSIndexPath *monthIndexPath = [NSIndexPath indexPathForItem:0 inSection:(yearMultiplier * 12) + monthIndex];

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

    [self drawCell:cell];

    [cell updateLabelsForCapsl:capsl];

    [profilePhoto getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
        cell.profilePicView.image = [UIImage imageWithData:data];
    }];

//    cell.profilePicView.image = [UIImage imageNamed:@"profilepic1"];

    if (!capsl.objectId)
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
    CGSize cellSize = CGSizeMake(self.view.frame.size.height * 0.4, self.view.frame.size.height * 0.8);
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

#pragma mark scroll view methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    NSArray *visibleIndexPaths = [self.capslView indexPathsForVisibleItems];

    if (scrollView.dragging)
    {
        [self.delegate capslsScrolledToIndex:visibleIndexPaths.firstObject];
    }

}

#pragma mark - helper methods

- (JCACapslCollectionViewCell *)drawCell:(JCACapslCollectionViewCell *)cell
{
//    NSArray *constraints = [cell.profilePicView constraints];
//    [cell.profilePicView removeConstraints:constraints];

    NSLayoutConstraint *widthConstraint = [NSLayoutConstraint constraintWithItem:cell.profilePicView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:cell attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0];
    NSLayoutConstraint *heightConstraint = [NSLayoutConstraint constraintWithItem:cell.profilePicView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:cell.profilePicView attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0];

    [cell addSubview:cell.profilePicView];
    [cell sendSubviewToBack:cell.profilePicView];
    [cell addConstraints:@[widthConstraint, heightConstraint]];

    cell.profilePicView.layer.cornerRadius = cell.frame.size.width/2;


    [cell.profilePicView setContentMode:UIViewContentModeScaleAspectFill];
    [cell.profilePicView setClipsToBounds:YES];

//    cell.profilePicView.layer.borderColor = [UIColor blackColor].CGColor;
//    cell.profilePicView.layer.borderWidth = 1.0;

    cell.countdownLabel.layer.cornerRadius = cell.countdownLabel.frame.size.height/2;
    cell.countdownLabel.clipsToBounds = YES;

    if (self.showSent)
    {
        cell.countdownLabel.backgroundColor = kSentCapsuleColor;
    }
    else
    {
        cell.countdownLabel.backgroundColor = kReceivedCapsuleColor;
    }

    [cell layoutIfNeeded];

    return cell;
}

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

- (void)updateData
{
    if (self.showSent)
    {
        self.collectionViewData = self.sentCapslsGrandArray;
    }
    else
    {
        self.collectionViewData = self.capslGrandArray;
    }

    [self.capslView reloadData];
}

- (void)scrollToEarliestUnopenedCapsule
{

    // scroll to first unopened capsule in received, 3 capsules prior to first unopened in sent
    for (int x = 0; x < self.collectionViewData.count; x++)
    {
        Capsl *capsl = self.collectionViewData[x];

        if (!capsl.viewedAt)
        {

//            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:x inSection:0];
//            [self.collectionViewData scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:NO];

            break;
        }

    }


}



@end
