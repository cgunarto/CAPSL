//
//  TimelineCollectionViewController.h
//  Timeline Test 2
//
//  Created by Mobile Making on 11/24/14.
//  Copyright (c) 2014 Alex Hsu. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Capsl;

@protocol CapslViewDelegate <NSObject>

- (void)capslsScrolledToIndex:(NSIndexPath *)indexPath;

@end

@interface JCACapslViewController : UIViewController

@property (nonatomic, strong) NSArray *capslsArray;
@property (nonatomic, strong) NSArray *sentCapslsArray;
@property (nonatomic, strong) NSArray *capslGrandArray;
@property (nonatomic, strong) NSArray *sentCapslsGrandArray;
@property (nonatomic, strong) Capsl *soonestUnopenedCapsl;
@property (nonatomic, strong) Capsl *soonestUnopenedSentCapsl;
@property NSArray *capslYearNumbers;
@property NSArray *sentCapslYearNumbers;
@property BOOL showSent;

- (void)showCapslWithYearMultiplier:(NSInteger)yearMultiplier andMonthIndex:(NSInteger)monthIndex andCapslIndex:(NSInteger)capsl withAnimation:(BOOL)animated;
- (void)updateClocks;
- (void)updateUserInterface;

@property (nonatomic, weak) id <CapslViewDelegate> delegate;

@end
