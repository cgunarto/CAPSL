//
//  ViewController.m
//  Timeline Test 2
//
//  Created by Mobile Making on 11/24/14.
//  Copyright (c) 2014 Alex Hsu. All rights reserved.
//


#import "JCATimelineRootViewController.h"
#import "JCACapslViewController.h"
#import "JCATimelineViewController.h"
#import "UIImage+ImageEffects.h"
#import "Capsl.h"

#define kNumOfTimelinePrefixYears 1

@interface JCATimelineRootViewController () <TimelineDelegate, CapslViewDelegate>

@property JCACapslViewController *capslVC;
@property JCATimelineViewController *timelineVC;
@property UIImageView *wallpaperView;
@property (strong, nonatomic) IBOutlet UIView *capslContainerView;
@property (strong, nonatomic) IBOutlet UIView *timelineContainerView;
@property UIDevice *device;

@end

@implementation JCATimelineRootViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.device = [UIDevice currentDevice];
    self.wallpaperView = [[UIImageView alloc] initWithImage:[self processWallpaper:[UIImage imageNamed:@"wallpaper"]]];
//    self.wallpaperView.frame = self.view.bounds;
    self.wallpaperView.contentMode = UIViewContentModeScaleAspectFill;
    [self.view addSubview:self.wallpaperView];

}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{

    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];

    [self.view addSubview:self.capslContainerView];
    [self.view addSubview:self.timelineContainerView];

    [self processCapsls:self.capslsArray];

}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - timeline methods

- (void)indexPathForTimelineCellAtCenter:(NSIndexPath *)indexPath fromTap:(BOOL)didTap
{

    NSInteger yearMultiplier = indexPath.section;
    NSInteger monthIndex = indexPath.item;

//    self.capslVC.delegate = nil;

    [self.capslVC showCapslAtYear:yearMultiplier andMonth:monthIndex withAnimation:didTap];

}

- (void)timelineDidEndScrolling
{
//    self.capslVC.delegate = self;
}

#pragma mark - capsl view methods

- (void)capslsScrolledToIndex:(NSIndexPath *)indexPath
{

    NSInteger yearIndex = indexPath.section / 13;
    NSInteger monthIndex = (indexPath.section % 13) - 1;
    NSIndexPath *timelineMonthIndexPath = [NSIndexPath indexPathForItem:monthIndex inSection:yearIndex];

//    if (indexPath)
//    {
//        [self.timelineVC centerCorrespondingMonthCell:timelineMonthIndexPath];
//    }
    [self.timelineVC centerCorrespondingMonthCell:timelineMonthIndexPath];

}

#pragma mark - helper methods

- (UIImage *)processWallpaper:(UIImage *)wallpaper
{

    UIColor *tintColor = [UIColor colorWithWhite:0.3 alpha:0.1];
    wallpaper = [wallpaper applyBlurWithRadius:3 tintColor:tintColor saturationDeltaFactor:0.8 maskImage:nil];

    return wallpaper;

}

- (void)processCapsls:(NSArray *)capsls
{
    NSMutableArray *arrayOfYears = [@[] mutableCopy];

    NSDateFormatter *yearFormatter = [[NSDateFormatter alloc] init];
    NSDateFormatter *monthFormatter = [[NSDateFormatter alloc] init];
    yearFormatter.dateFormat = @"yyyy";
    monthFormatter.dateFormat = @"MM";

    int yearToday = [[NSString stringWithFormat:@"%@", [yearFormatter stringFromDate:[NSDate date]]] intValue];
    int firstCapslYear = [[NSString stringWithFormat:@"%@", [yearFormatter stringFromDate:[capsls.firstObject deliveryTime]]] intValue];
    int compareYear;

    // set start of timeline based on today or first capsl, whichever is earlier
    if (firstCapslYear > yearToday)
    {
        compareYear = (yearToday - 1) - kNumOfTimelinePrefixYears;
    }
    else
    {
        compareYear = (firstCapslYear - 1) - kNumOfTimelinePrefixYears;
    }

    // create embedded array of capsls
    for (Capsl *capsl in capsls)
    {
        // get month and year for current capsl
        NSString *capslYear = [NSString stringWithFormat:@"%@", [yearFormatter stringFromDate:capsl.deliveryTime]];
        NSString *capslMonth = [NSString stringWithFormat:@"%@", [monthFormatter stringFromDate:capsl.deliveryTime]];

        // if capsls skip years, generate empty years in the array
        if (compareYear != [capslYear intValue])
        {
            int newYearPlusAnyEmptyInBetween = [capslYear intValue] - compareYear;

            for (int x = 1; x <= newYearPlusAnyEmptyInBetween; x++)
            {
                NSMutableArray *aYearOfMonths = [@[] mutableCopy];

                // add Year marker at index 0
//                [aYearOfMonths addObject:[NSString stringWithFormat:@"%i",compareYear + x]];

                // add 12 months to empty year
                for (int y = 1; y <= 12; y++)
                {
                    NSMutableArray *aMonthOfCapsls = [@[] mutableCopy];

                    Capsl *emptyCapsl = [Capsl object];

                    [aMonthOfCapsls addObject:emptyCapsl];
                    [aYearOfMonths addObject:aMonthOfCapsls];
                }

                [arrayOfYears addObject:aYearOfMonths];

            }

            compareYear = [capslYear intValue];
        }

        NSMutableArray *lastYear = [arrayOfYears lastObject][[capslMonth intValue] - 1];
        Capsl *checkCapsl = lastYear.firstObject;
        if (!checkCapsl.objectId)
        {
            [lastYear replaceObjectAtIndex:0 withObject:capsl];
        }
        else
        {
            [lastYear addObject:capsl];
        }

    }

    self.capslVC.capslGrandArray = arrayOfYears;
    self.timelineVC.capslGrandArray = arrayOfYears;

}

#pragma mark - segue life cycle

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{

    if ([segue.identifier isEqualToString:@"capslCollectionSegue"])
    {
        self.capslVC = segue.destinationViewController;
        self.capslVC.delegate = self;
    }
    else
    {
        self.timelineVC = segue.destinationViewController;
        self.timelineVC.delegate = self;
    }
    
}

@end
