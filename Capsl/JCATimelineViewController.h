//
//  JCAScrubberViewController.h
//  Timeline Test 2
//
//  Created by Mobile Making on 11/24/14.
//  Copyright (c) 2014 Alex Hsu. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol TimelineDelegate <NSObject>

- (void)indexPathForTimelineCellAtCenter:(NSIndexPath *)indexPath fromTap:(BOOL)didTap;

- (void)timelineDidEndScrolling;

@end

@interface JCATimelineViewController : UIViewController

@property (nonatomic) NSArray *capslGrandArray;
@property (nonatomic) NSArray *sentCapslsGrandArray;
@property (nonatomic) NSArray *capslYearNumbers;
@property (nonatomic) NSArray *sentCapslYearNumbers;
@property (nonatomic) NSDictionary *capslCounts;
@property (nonatomic) NSDictionary *sentCapslCounts;

@property BOOL showSent;

- (void)centerCorrespondingMonthCell:(NSIndexPath *)indexPath;
- (void)updateData;

@property (nonatomic, weak) id <TimelineDelegate> delegate;

@end


