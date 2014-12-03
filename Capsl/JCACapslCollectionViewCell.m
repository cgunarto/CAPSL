//
//  JCACapslCollectionViewCell.m
//  Timeline Test 2
//
//  Created by Mobile Making on 11/24/14.
//  Copyright (c) 2014 Alex Hsu. All rights reserved.
//

#import "JCACapslCollectionViewCell.h"
#import "Capsl.h"
#import "JKCountDownTimer.h"

@implementation JCACapslCollectionViewCell


- (void)updateLabelsForCapsl:(Capsl *)capsl
{

    NSDate *deliveryDate = capsl.deliveryTime;
    NSTimeInterval timeInterval = [deliveryDate timeIntervalSinceNow];

    self.countdownLabel.text = [JKCountDownTimer getStringWithTimeInterval:timeInterval];
    self.deliveryDateLabel.text = [JKCountDownTimer getDateStringWithDate:deliveryDate];

//    [UIView setAnimationsEnabled:NO];
//    [self.countdownButton setTitle:[JKCountDownTimer getStringWithTimeInterval:timeInterval] forState:UIControlStateNormal];
//    [UIView setAnimationsEnabled:YES];

//    [UIView transitionWithView:self.countdownButton duration:0.5 options:UIViewAnimationOptionTransitionNone animations:^{
//        [self.countdownButton setTitle:[JKCountDownTimer getStringWithTimeInterval:timeInterval] forState:UIControlStateNormal];
//    } completion:nil];

}

@end