//
//  CapsuleColorizer.m
//  Capsl
//
//  Created by Mobile Making on 12/11/14.
//  Copyright (c) 2014 Christina Gunarto. All rights reserved.
//

#import "CapsuleColorizer.h"
#import "
#import "Capsl.h"

@implementation CapsuleColorizer

- (UIColor *)colorInCellCapsule:(Capsl *)capsl thatWasSent:(BOOL)showSent
{

    UIColor *color = [[UIColor alloc] init];

    NSTimeInterval timeInterval = [capsl getTimeIntervalUntilDelivery];

    color = kSentCapsuleColor;
    self.alpha = 1;
    self.countdownLabel.textColor = [UIColor whiteColor];


    if (timeInterval <= 0)
    {
        // unlocked - add shimmer
    }
    if (timeInterval <= 0 && capsl.viewedAt)
    {
        //viewed - mute colors
        color = kSentViewedCapsuleColor;
        self.countdownLabel.textColor = kSentViewedTextColor;

    }
    if (timeInterval > 0 && timeInterval <= kDayInSeconds)
    {
        // within 24 hrs
    }
    if (timeInterval > kDayInSeconds)
    {
        // more than 24hrs - add alpha
        self.alpha = 0.5;
    }
    
    return color;
    
}

@end
