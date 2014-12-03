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


- (void)updateTimeLabelForCapsl:(Capsl *)capsl
{

    NSDate *deliveryDate = capsl.deliveryTime;
    NSTimeInterval timeInterval = [deliveryDate timeIntervalSinceNow];
    self.countdownButton.titleLabel.text = [JKCountDownTimer getStringWithTimeInterval:timeInterval];
    
}

@end