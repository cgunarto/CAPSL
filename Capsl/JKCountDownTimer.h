//
//  JKCountDownTimer.h
//  Capsl
//
//  Created by Jonathan Kim on 11/27/14.
//  Copyright (c) 2014 Christina Gunarto. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CapslTableViewCell.h"

@protocol JKCountdownTimerDelegate <NSObject>

-(void)counterUpdated:(NSString *)dateString;

@end


@interface JKCountDownTimer : NSObject

@property NSTimer *timer;
@property NSDate *deliveryDate;

@property id<JKCountdownTimerDelegate>delegate;


-(instancetype)initWithDeliveryDate:(NSDate *)date withDelegate:(id<JKCountdownTimerDelegate>)delegate;

- (void)updateLabel;

@end
