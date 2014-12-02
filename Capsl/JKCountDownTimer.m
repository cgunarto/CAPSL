//
//  JKCountDownTimer.m
//  Capsl
//
//  Created by Jonathan Kim on 11/27/14.
//  Copyright (c) 2014 Christina Gunarto. All rights reserved.
//

#import "JKCountDownTimer.h"
#define kSixHoursInSeconds 21600
#define kDayInSeconds 86400
#define kWeekInSeconds 604800

@interface JKCountDownTimer ()

@end

@implementation JKCountDownTimer

-(instancetype)init
{

    self = [super init];

    if (self)
    {
        abort();
    }

    return self;
}

- (instancetype)initWithDeliveryDate:(NSDate *)date withDelegate:(id<JKCountdownTimerDelegate>)delegate
{
    self = [super init];

    if(self)
    {
        self.delegate = delegate;
        self.deliveryDate = date;
        self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateLabel) userInfo:nil repeats:YES];
    }
    return self;
}


- (void)updateLabel
{
    NSString *result;

    long elapsedSeconds = [self.deliveryDate timeIntervalSinceDate:[NSDate date]];
//    NSLog(@"Elaped seconds:%ld seconds",elapsedSeconds);

    if (elapsedSeconds >= kWeekInSeconds)
    {
        result = @"SOON";
    }
    else if (elapsedSeconds < kWeekInSeconds && elapsedSeconds >= kDayInSeconds)
    {
        result = @"THIS WEEK";
    }
//    else if (elapsedSeconds < kDayInSeconds && elapsedSeconds >= kSixHoursInSeconds)
//    {
//        result = @"TODAY";
//    }
    else if (elapsedSeconds < 86400 && elapsedSeconds >= 60)
    {
        result = [self stringFromTimeInterval:elapsedSeconds];
    }
    else if (elapsedSeconds < 60 && elapsedSeconds >= 0)
    {
        result = [self stringForLastSixtySeconds:elapsedSeconds];
    }
    else if (elapsedSeconds < 0)
    {
        result = @"OPEN!";
        [self.timer invalidate];
    }
    [self.delegate counterUpdated:result];

}

- (NSString *)stringFromTimeInterval:(NSTimeInterval)interval
{
    NSInteger ti = (NSInteger)interval;
    NSInteger seconds = ti % 60;
    NSInteger minutes = (ti / 60) % 60;
    NSInteger hours = (ti / 3600);

    return [NSString stringWithFormat:@"%02li:%02li:%02li", (long)hours, (long)minutes, (long)seconds];
}

- (NSString *)stringForLastSixtySeconds:(NSTimeInterval)interval
{
    NSInteger ti = (NSInteger)interval;
    NSInteger seconds = ti % 60;

    return [NSString stringWithFormat:@"%02li", (long)seconds];
}



@end
