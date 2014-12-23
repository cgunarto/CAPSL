//
//  JCAScrubberViewController.m
//  Timeline Test 2
//
//  Created by Mobile Making on 11/24/14.
//  Copyright (c) 2014 Alex Hsu. All rights reserved.
//

#import "JCATimelineViewController.h"
#import "JCATimelineMonthCollectionViewCell.h"
#import "JCATimeline.h"
#import <QuartzCore/QuartzCore.h>

@interface JCATimelineViewController () <UIGestureRecognizerDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

@property (strong, nonatomic) IBOutlet UICollectionView *timelineView;
@property (strong, nonatomic) IBOutlet JCATimeline *maskView;
@property (strong, nonatomic) IBOutlet UILabel *yearLabel;
@property NSArray *monthStrings;
@property NSArray *arrayOfYearNumbers;
@property NSMutableArray *arrayOfMonths;
@property NSArray *arrayOfCapslCounts;
@property NSArray *collectionViewData;

@property CGFloat timelineWidth;
//@property UIView *timelineHighlight;

@end

@implementation JCATimelineViewController

- (void)viewDidLoad
{

    [super viewDidLoad];

    self.monthStrings = @[@"JAN", @"FEB", @"MAR", @"APR", @"MAY", @"JUN", @"JUL", @"AUG", @"SEP", @"OCT", @"NOV", @"DEC"];
    self.arrayOfMonths = [[NSMutableArray alloc] init];

    for (int x = 1; x <= 4; x++)
    {
        for (NSString *monthString in self.monthStrings)
        {
            [self.arrayOfMonths addObject:monthString];
        }
    }

//    self.timelineWidth = [[UIScreen mainScreen] bounds].size.height;
    self.timelineWidth = self.view.bounds.size.height * 0.9;

    // set year label to this year
    NSDateFormatter *yearFormatter = [[NSDateFormatter alloc] init];
    [yearFormatter setDateFormat:@"yyyy"];
    self.yearLabel.text = [yearFormatter stringFromDate:[NSDate date]];

    [self.maskView addSubview:self.timelineView];

//    [self styleHighlight];


}

- (void)viewWillAppear:(BOOL)animated
{
    [self updateData];
}

- (void)viewWillLayoutSubviews
{

    [self fadeLeftEdge];

}

- (void)setCapslGrandArray:(NSArray *)capslGrandArray
{
    _capslGrandArray = capslGrandArray;
    [self updateData];

}

- (void)setSentCapslsGrandArray:(NSArray *)sentCapslsGrandArray
{
    _sentCapslsGrandArray = sentCapslsGrandArray;
    [self updateData];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - collection view delegates

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return self.collectionViewData.count;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 12;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{

    JCATimelineMonthCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];

    NSInteger countIndex = (indexPath.section * 12) + indexPath.item;
    NSString *countString = self.arrayOfCapslCounts[countIndex];

    if ([countString isEqual:[NSNull null]])
    {
        [self drawEmptyCountDotForCell:cell];
    }
    else
    {
        [self drawCountDotForCell:cell];
        cell.countLabel.text = [(NSNumber *)countString stringValue];
    }
    
    cell.monthLabel.text = self.arrayOfMonths[indexPath.item];

    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{

    return CGSizeMake(self.timelineWidth/9, self.view.frame.size.height);

}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [self centerCell:indexPath];
}

- (void)selectItemAtIndexPath:(NSIndexPath *)indexPath animated:(BOOL)animated scrollPosition:(UICollectionViewScrollPosition)scrollPosition
{

}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    [self.delegate timelineDidEndScrolling];

    NSIndexPath *selectedIndexPath = [self.timelineView indexPathsForSelectedItems].firstObject;
    [self.timelineView deselectItemAtIndexPath:selectedIndexPath animated:YES];

}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (!decelerate)
    {
        [self centerCell:nil];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self centerCell:nil];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{

    NSArray *arrayOfSelectedIndexPaths = [self.timelineView indexPathsForSelectedItems];

    NSIndexPath *indexPath = [self indexPathAtCenter];

    // checking if timeline was tapped helps to determine if Capsl view scroll should animate

    // dragged scrollview
    if (scrollView.dragging)
    {
        [self.delegate indexPathForTimelineCellAtCenter:indexPath fromTap:NO];
        self.yearLabel.text = self.arrayOfYearNumbers[indexPath.section];
    }

    // tapped scrollview
    else if (arrayOfSelectedIndexPaths.count != 0)
    {
        [self.delegate indexPathForTimelineCellAtCenter:indexPath fromTap:YES];
        self.yearLabel.text = self.arrayOfYearNumbers[indexPath.section];
    }

}

#pragma mark - drawing

- (void)styleHighlight
{

//    CGRect highlightFrame = CGRectMake(300, self.timelineWidth/2, self.timelineWidth/12, self.timelineWidth/12);
//
//    UIView *timelineHighlight = [[UIView alloc] initWithFrame:highlightFrame];
//
////    timelineHighlight.center = CGPointMake(self.timelineWidth/2, self.view.frame.size.width);
//    timelineHighlight.layer.cornerRadius = self.timelineHighlight.frame.size.width/2;
//    timelineHighlight.layer.borderWidth = 1.0;
//    timelineHighlight.layer.borderColor = [UIColor lightGrayColor].CGColor;
//    timelineHighlight.backgroundColor = [UIColor blackColor];
//    [self.timelineHighlight setHidden:NO];
//    [self.view bringSubviewToFront:self.timelineHighlight];
//
//    [self.view addSubview:timelineHighlight];


}

#pragma mark - helper methods

- (void)centerCorrespondingMonthCell:(NSIndexPath *)indexPath
{

//    [self.timelineView setContentOffset:<#(CGPoint)#> animated:NO];
//
    [self.timelineView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:NO];


}

- (void)centerCell:(NSIndexPath *)indexPath
{

    // set indexPath to cell closest to center
    if (!indexPath)
    {
        indexPath = [self indexPathAtCenter];
    }

    [self.timelineView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];

}

- (NSIndexPath *)indexPathAtCenter
{
    CGFloat yUnderCenterOfContainer = self.timelineView.contentSize.height * 0.4;
    CGFloat xUnderCenterOfContainer = self.timelineView.contentOffset.x + self.timelineWidth/2;
    NSIndexPath *indexPath = [self.timelineView indexPathForItemAtPoint:CGPointMake(xUnderCenterOfContainer, yUnderCenterOfContainer)];
    return indexPath;
}

- (void)updateData
{
    if (self.showSent == NO)
    {
        self.collectionViewData = self.capslGrandArray;
        self.arrayOfYearNumbers = self.capslYearNumbers;
        self.arrayOfCapslCounts = [self getArrayOfCapsuleCountsWithCountsDictionary:self.capslCounts];
    }
    else
    {
        self.collectionViewData = self.sentCapslsGrandArray;
        self.arrayOfYearNumbers = self.sentCapslYearNumbers;
        self.arrayOfCapslCounts = [self getArrayOfCapsuleCountsWithCountsDictionary:self.sentCapslCounts];

    }

    [self.timelineView reloadData];
}

- (NSArray *)getArrayOfCapsuleCountsWithCountsDictionary:(NSDictionary *)dict
{

    NSMutableArray *arrayOfCounts = [@[] mutableCopy];

    // create empty array to mirror array of month labels
    for (int x = 1; x <= (self.arrayOfYearNumbers.count * 12); x++)
    {
        [arrayOfCounts addObject:[NSNull null]];
    }

    NSArray *yearsWithCapsls = [dict allKeys];

    for (NSString *yearString in yearsWithCapsls)
    {

        NSDictionary *dictOfMonths = [dict objectForKey:yearString];

        NSArray *monthStrings = [dictOfMonths allKeys];

        for (NSString *month in monthStrings)
        {

            NSNumber *numberOfCapsls = [dictOfMonths objectForKey:month];
            NSInteger yearMultiplier = [self.arrayOfYearNumbers indexOfObject:yearString];
            NSInteger index = (yearMultiplier * 12) + ([month integerValue] - 1);

            // if recipient is Team Capsl do not show a count in the timeline
            if ([numberOfCapsls isEqual:@0])
            {
                break;
            }
            else
            {
                [arrayOfCounts replaceObjectAtIndex:index withObject:numberOfCapsls];
            }
        }

    }

    return arrayOfCounts;

}

- (NSArray *)getCapslCountPerMonthWithGrandArray
{
    return nil;
}

- (NSArray *)getYearNumbersWithGrandArray
{
    return nil;
}

- (void)drawEmptyCountDotForCell:(JCATimelineMonthCollectionViewCell *)cell
{

    [cell addSubview:cell.countLabel];
//    [cell removeConstraints:cell.constraints];

    [self centerDot:cell];
    NSLayoutConstraint *widthConstraint = [NSLayoutConstraint constraintWithItem:cell.countLabel attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:5.0];
    NSLayoutConstraint *heightConstraint = [NSLayoutConstraint constraintWithItem:cell.countLabel attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:5.0];

    [cell addConstraints:@[widthConstraint, heightConstraint]];


//    CGRect dotFrame = cell.countLabel.frame;
//    dotFrame.size = CGSizeMake(5.0, 5.0);
//    cell.countLabel.frame = dotFrame;
    cell.countLabel.backgroundColor = [UIColor whiteColor];
    cell.countLabel.layer.cornerRadius = 2.5;
    cell.countLabel.clipsToBounds = YES;

}

- (void)drawCountDotForCell:(JCATimelineMonthCollectionViewCell *)cell
{

    //test code
    [cell addSubview:cell.countLabel];
//    [cell removeConstraints:cell.constraints];

    [self centerDot:cell];
    NSLayoutConstraint *widthConstraint = [NSLayoutConstraint constraintWithItem:cell.countLabel attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:25.0];
    NSLayoutConstraint *heightConstraint = [NSLayoutConstraint constraintWithItem:cell.countLabel attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:25.0];

    [cell addConstraints:@[widthConstraint, heightConstraint]];

    if (self.showSent)
    {
        cell.countLabel.backgroundColor = kSentCapsuleColor;
    }
    else
    {
        cell.countLabel.backgroundColor = kReceivedCapsuleColor;
    }

    cell.countLabel.layer.cornerRadius = 12.5;
    cell.countLabel.clipsToBounds = YES;

    //end test code

/* good code    [self.view addSubview:cell];

    [self centerDot:cell];


    CGRect dotFrame = cell.countLabel.frame;
    dotFrame.size = CGSizeMake(20, 20);
    cell.countLabel.frame = dotFrame;

    if (self.showSent)
    {
        cell.countLabel.backgroundColor = kSentCapsuleColor;
    }
    else
    {
        cell.countLabel.backgroundColor = kReceivedCapsuleColor;
    }

    cell.countLabel.layer.cornerRadius = 10;
    cell.countLabel.clipsToBounds = YES;
 
 */

}

- (void)centerDot:(JCATimelineMonthCollectionViewCell *)cell
{

    NSLayoutConstraint *centerYConstraint = [NSLayoutConstraint constraintWithItem:cell.countLabel attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:cell attribute:NSLayoutAttributeBottom multiplier:0.4 constant:0];
    NSLayoutConstraint *centerXConstraint = [NSLayoutConstraint constraintWithItem:cell.countLabel attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:cell attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0];

    [cell addConstraints:@[centerXConstraint, centerYConstraint]];

}

- (void)fadeLeftEdge
{

    CAGradientLayer *gradient = [CAGradientLayer layer];

    gradient.frame = self.timelineView.frame;

    gradient.startPoint = CGPointMake(0.0, 0.5);
    gradient.endPoint = CGPointMake(1.0, 0.5);
    gradient.colors = [NSArray arrayWithObjects:
                       (__bridge id)UIColor.clearColor.CGColor,
                       UIColor.whiteColor.CGColor,
                       UIColor.whiteColor.CGColor,
                       nil];
    gradient.locations = [NSArray arrayWithObjects:
                          [NSNumber numberWithFloat:0],
                          [NSNumber numberWithFloat:1.0/20],
                          [NSNumber numberWithFloat:1.0],
                          nil];
    self.maskView.layer.mask = gradient;

}

#pragma mark - actions

- (IBAction)scrubberTapped:(UITapGestureRecognizer *)sender
{

//    CGPoint point = [sender locationInView:self.view];
//    [self.delegate scrubbedToPoint:point withGesture:sender];

}

- (IBAction)scrubberPanned:(UIPanGestureRecognizer *)sender
{

//    CGPoint point = [sender locationInView:self.view];
//    [self.delegate scrubbedToPoint:point withGesture:sender];

}

@end
