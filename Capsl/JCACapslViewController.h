//
//  TimelineCollectionViewController.h
//  Timeline Test 2
//
//  Created by Mobile Making on 11/24/14.
//  Copyright (c) 2014 Alex Hsu. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CapslViewDelegate <NSObject>

- (void)capslsScrolledToIndex:(NSIndexPath *)indexPath;

@end

@interface JCACapslViewController : UIViewController

@property NSArray *capslGrandArray;

- (void)showCapslAtYear:(NSInteger)yearMultiplier andMonth:(NSInteger)monthIndex withAnimation:(BOOL)animated;
- (void)updateClocks;

@property (nonatomic, weak) id <CapslViewDelegate> delegate;

@end
