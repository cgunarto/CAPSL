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
#import "IndexConverter.h"
#import "UIImage+ImageEffects.h"
#import "BackgroundGenerator.h"
#import "Capsl.h"
#import "Capslr.h"

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

    self.timelineVC.showSent = self.shouldShowSent;
    self.capslVC.showSent = self.shouldShowSent;

//    [self prefersStatusBarHidden];

}

- (void)willTransitionToTraitCollection:(UITraitCollection *)newCollection withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    if (newCollection.verticalSizeClass == UIUserInterfaceSizeClassCompact)
    {
        [self.capslVC updateUserInterface];
    }

}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{

    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];

    [self.view addSubview:self.capslContainerView];
    [self.view addSubview:self.timelineContainerView];

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [self.view addSubview:self.capslContainerView];
    [self.view addSubview:self.timelineContainerView];

    [self setWallpaper];

}

-(void)setShouldShowSent:(BOOL)shouldShowSent
{
    _shouldShowSent = shouldShowSent;

    self.timelineVC.showSent = _shouldShowSent;
    self.capslVC.showSent = _shouldShowSent;

    self.capslVC.capslsArray = self.capslsArray;
    self.capslVC.sentCapslsArray = self.sentCapslsArray;

    self.capslVC.soonestUnopenedCapsl = [self getSoonestUnopenedCapslFromArray:self.capslsArray];
    self.capslVC.soonestUnopenedSentCapsl = [self getSoonestUnopenedCapslFromArray:self.sentCapslsArray];

    self.timelineVC.capslYearNumbers = [self getArrayOfYearNumbersFromCapsls:self.capslsArray];
    self.capslVC.capslYearNumbers = self.timelineVC.capslYearNumbers;
    self.timelineVC.sentCapslYearNumbers = [self getArrayOfYearNumbersFromCapsls:self.sentCapslsArray];
    self.capslVC.sentCapslYearNumbers = self.timelineVC.sentCapslYearNumbers;

    self.timelineVC.capslCounts = [self convertCapslsToDictOfYearMonthCapsuleCount:self.capslsArray];
    self.timelineVC.sentCapslCounts = [self convertCapslsToDictOfYearMonthCapsuleCount:self.sentCapslsArray];

    self.timelineVC.capslGrandArray = [self processCapsls:self.capslsArray];
    self.capslVC.capslGrandArray = self.timelineVC.capslGrandArray;
    self.timelineVC.sentCapslsGrandArray = [self processCapsls:self.sentCapslsArray];
    self.capslVC.sentCapslsGrandArray = self.timelineVC.sentCapslsGrandArray;


    [self setWallpaper];

}

// - (BOOL)prefersStatusBarHidden
//{
//    return YES;
//}

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

    [self.capslVC showCapslWithYearMultiplier:yearMultiplier andMonthIndex:monthIndex andCapslIndex:0 withAnimation:didTap];

}

- (void)timelineDidEndScrolling
{
//    self.capslVC.delegate = self;
}

#pragma mark - capsl view methods

- (void)capslsScrolledToIndex:(NSIndexPath *)indexPath
{

    NSInteger yearIndex = indexPath.section / 12;
    NSInteger monthIndex = indexPath.section % 12;
    NSIndexPath *timelineMonthIndexPath = [NSIndexPath indexPathForItem:monthIndex inSection:yearIndex];

//    if (indexPath)
//    {
//        [self.timelineVC centerCorrespondingMonthCell:timelineMonthIndexPath];
//    }
    [self.timelineVC centerCorrespondingMonthCell:timelineMonthIndexPath];

}

#pragma mark - helper methods

- (void)setWallpaper
{
    [self.wallpaperView removeFromSuperview];

    UIImage *wallpaper = [[UIImage alloc] init];

    wallpaper = [BackgroundGenerator blurImage:kTimelineWallpaper withRadius:10.0];

    if (self.shouldShowSent)
    {
//        wallpaper = [self processWallpaper:kTimelineWallpaperSent];
    }
    else
    {
//        wallpaper = [self processWallpaper:kTimelineWallpaperReceived];
    }

    self.wallpaperView = [[UIImageView alloc] initWithImage:wallpaper];
    self.wallpaperView.frame = [[UIScreen mainScreen] bounds];
    self.wallpaperView.contentMode = UIViewContentModeScaleAspectFill;
    [self.view addSubview:self.wallpaperView];
    [self.view sendSubviewToBack:self.wallpaperView];

}

- (UIImage *)processWallpaper:(UIImage *)wallpaper
{

    UIColor *tintColor = [UIColor colorWithWhite:0.3 alpha:0.1];
    wallpaper = [wallpaper applyBlurWithRadius:3 tintColor:tintColor saturationDeltaFactor:0.8 maskImage:nil];

    return wallpaper;

}

- (void)updateClocks
{

    [self.capslVC updateClocks];

}


- (NSMutableArray *)generateEmptyYear
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
    return aYearOfMonths;
}

- (NSArray *)processCapsls:(NSArray *)capsls
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
                NSMutableArray *aYearOfMonths;

                aYearOfMonths = [self generateEmptyYear];

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

    // add suffix empty year

    [arrayOfYears addObject:[self generateEmptyYear]];

    return arrayOfYears;

}

- (NSArray *)getArrayOfYearNumbersFromCapsls:(NSArray *)capsls
{

    Capsl *firstCapsl = capsls.firstObject;
    Capsl *lastCapsl = capsls.lastObject;
    NSInteger firstYear = [firstCapsl getYearForCapsl];
    NSInteger lastYear = [lastCapsl getYearForCapsl];

    NSMutableArray *yearNumbers = [@[] mutableCopy];

    for (NSInteger y = (firstYear - 1); y <= (lastYear + 1); y++)
    {
        [yearNumbers addObject:[NSString stringWithFormat:@"%li", (long)y]];
    }

    // this includes empty prefix and suffix years as well as empty years in between
    return [NSArray arrayWithArray:yearNumbers];

}

- (NSDictionary *)convertCapslsToDictOfYearMonthCapsuleCount:(NSArray *)capsls
{

    NSMutableDictionary *dictionaryOfYearKeys = [NSMutableDictionary dictionary];

    // create a dictionary where key is year and value is another dictionary with month name key, and capsule count for that month as value
    for (Capsl *capsl in capsls)
    {
        NSInteger capslYear = [capsl getYearForCapsl];
        NSInteger capslMonth = [capsl getMonthForCapsl];
        NSString *yearString = [NSString stringWithFormat:@"%ld", (long)capslYear];
        NSString *monthString = [NSString stringWithFormat:@"%ld", (long)capslMonth];

        if (![[dictionaryOfYearKeys allKeys] containsObject:yearString])
        {
            [dictionaryOfYearKeys setObject:[NSMutableDictionary dictionary] forKey:yearString];
        }

        NSMutableDictionary *dictOfMonths = [dictionaryOfYearKeys objectForKey:yearString];

        if (![[dictOfMonths allKeys] containsObject:monthString])
        {
            [dictOfMonths setObject:@0 forKey:monthString];
        }


        NSNumber *newCount = [NSNumber new];

        if ([capsl.recipient.objectId isEqualToString:kCapslTeamObjectID])
        {
            newCount = @0;
        }
        else
        {
            newCount = [NSNumber numberWithInteger:[[dictOfMonths objectForKey:monthString] integerValue] + 1];
        }

        [dictOfMonths setObject:newCount forKey:monthString];

    }

    return dictionaryOfYearKeys;
}

- (Capsl *)getSoonestUnopenedCapslFromArray:(NSArray *)dataArray
{
    NSInteger index = [IndexConverter indexForSoonestUnopenedCapsuleInArray:dataArray];
    Capsl *soonestUnopenedCapsl = dataArray[index];

    return soonestUnopenedCapsl;
}

- (void)updateTimelines
{
    [self.timelineVC updateData];
    [self.capslVC updateUserInterface];
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

    // temporary manual override to show sent vs received capsls

}

@end
