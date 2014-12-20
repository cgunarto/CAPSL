//
//  ViewController.h
//  Timeline Test 2
//
//  Created by Mobile Making on 11/24/14.
//  Copyright (c) 2014 Alex Hsu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JCATimelineRootViewController : UIViewController

@property NSArray *capslsArray;
@property NSArray *sentCapslsArray;
@property (nonatomic) BOOL shouldShowSent;

- (void)updateClocks;
- (void)updateTimelines;

@end

