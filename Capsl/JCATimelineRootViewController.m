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
    self.wallpaperView.contentMode = UIViewContentModeCenter;
    [self.view addSubview:self.wallpaperView];




}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{

    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];

    [self.view addSubview:self.capslContainerView];
    [self.view addSubview:self.timelineContainerView];

}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - timeline methods

- (void)indexPathForTimelineCellAtCenter:(NSIndexPath *)indexPath fromTap:(BOOL)didTap
{

    NSInteger monthIndex = indexPath.item;

//    self.capslVC.delegate = nil;

    [self.capslVC showCapsls:monthIndex withAnimation:didTap];

}

- (void)timelineDidEndScrolling
{
//    self.capslVC.delegate = self;
}

#pragma mark - capsl view methods

- (void)capslsScrolledToIndex:(NSIndexPath *)indexPath
{

    NSInteger monthIndex = indexPath.section;
    NSIndexPath *timelineMonthIndexPath = [NSIndexPath indexPathForItem:monthIndex inSection:1];

    [self.timelineVC centerCorrespondingMonthCell:timelineMonthIndexPath];

}

#pragma mark - helper methods

- (UIImage *)processWallpaper:(UIImage *)wallpaper
{

    UIColor *tintColor = [UIColor colorWithWhite:0.3 alpha:0.1];
    wallpaper = [wallpaper applyBlurWithRadius:3 tintColor:tintColor saturationDeltaFactor:0.8 maskImage:nil];

    return wallpaper;

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
