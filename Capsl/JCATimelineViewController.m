//
//  JCAScrubberViewController.m
//  Timeline Test 2
//
//  Created by Mobile Making on 11/24/14.
//  Copyright (c) 2014 Alex Hsu. All rights reserved.
//

#import "JCATimelineViewController.h"
#import "JCATimelineMonthCollectionViewCell.h"
#import <QuartzCore/QuartzCore.h>

@interface JCATimelineViewController () <UIGestureRecognizerDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

@property (strong, nonatomic) IBOutlet UICollectionView *timelineView;
@property NSArray *monthStrings;
@property NSMutableArray *arrayOfMonths;
@property NSArray *collectionViewData;

@property CGFloat screenWidth;
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

    self.screenWidth = [[UIScreen mainScreen] bounds].size.height;

//    [self styleHighlight];

}

- (void)viewWillAppear:(BOOL)animated
{
    [self updateData];
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

    cell.monthLabel.text = self.arrayOfMonths[indexPath.item];

    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{

    return CGSizeMake(self.screenWidth/12, self.view.frame.size.height);

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
    }

    // tapped scrollview
    else if (arrayOfSelectedIndexPaths.count != 0)
    {
        [self.delegate indexPathForTimelineCellAtCenter:indexPath fromTap:YES];
    }

}

#pragma mark - drawing

- (void)styleHighlight
{

//    CGRect highlightFrame = CGRectMake(300, self.screenWidth/2, self.screenWidth/12, self.screenWidth/12);
//
//    UIView *timelineHighlight = [[UIView alloc] initWithFrame:highlightFrame];
//
////    timelineHighlight.center = CGPointMake(self.screenWidth/2, self.view.frame.size.width);
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
    CGFloat yUnderCenterOfContainer = self.timelineView.contentSize.height/2;
    CGFloat xUnderCenterOfContainer = self.timelineView.contentOffset.x + self.screenWidth/2;
    NSIndexPath *indexPath = [self.timelineView indexPathForItemAtPoint:CGPointMake(xUnderCenterOfContainer, yUnderCenterOfContainer)];
    return indexPath;
}

- (void)updateData
{
    if (self.showSent == NO)
    {
        self.collectionViewData = self.capslGrandArray;
    }
    else
    {
        self.collectionViewData = self.sentCapslsGrandArray;
    }

    [self.timelineView reloadData];
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
