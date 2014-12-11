//
//  JKCountDownTimer.m
//  Capsl
//
//  Created by Jonathan Kim on 11/27/14.
//  Copyright (c) 2014 Christina Gunarto. All rights reserved.
//

#import "JKCountDownTimer.h"
#import "Capsl.h"

@interface JKCountDownTimer ()

@end

@implementation JKCountDownTimer


// For Timer
+ (NSString *)getStatusStringWithCapsl:(Capsl *)capsl
{

    NSTimeInterval timeInterval = [capsl getTimeIntervalUntilDelivery];

    NSString *dateString = [NSString string];

    if (timeInterval <= 0)
    {
        dateString = @"Unlocked";
    }
    if (timeInterval <= 0 && capsl.viewedAt)
    {
        dateString = @"Viewed";
    }
    if (timeInterval > 0 && timeInterval <= kDayInSeconds)
    {
        dateString = [self countdownStringFromTimeInterval:timeInterval];
    }
    if (timeInterval > kDayInSeconds)
    {
        dateString = [self englishStringFromTimeInterval:timeInterval capsl:capsl];
    }

    return dateString;

}



+ (NSString *)englishStringFromTimeInterval:(NSTimeInterval)timeInterval capsl:(Capsl *)capsl
{
    NSString *timeString = [NSString string];

    NSCalendarUnit dayOfWeek = NSCalendarUnitWeekday;
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSInteger todaysDay = [calendar component:dayOfWeek fromDate:[NSDate date]];

    NSInteger daysUntilSunday = 8 - todaysDay;
    NSTimeInterval timeFromStartOfTodayThroughSaturday = kDayInSeconds * daysUntilSunday;
    NSTimeInterval timeFromStartOfTodayThroughTomorrow = kDayInSeconds * 2;

    NSDate *startOfToday = [calendar startOfDayForDate:[NSDate date]];

    NSTimeInterval timeSinceMidnightToday = [startOfToday timeIntervalSinceNow];

    NSTimeInterval timeFromNowUntilSunday = timeSinceMidnightToday + timeFromStartOfTodayThroughSaturday;
    NSTimeInterval timeFromNowUntilDayAfterTomorrow = timeSinceMidnightToday + timeFromStartOfTodayThroughTomorrow;

    //    NSDate *startOfSunday = [NSDate dateWithTimeInterval:timeFromNowUntilSunday sinceDate:[NSDate date]];

    if (timeInterval <= timeFromNowUntilDayAfterTomorrow)
    {
        timeString = @"Tomorrow";
    }
    else if (timeInterval <= timeFromNowUntilSunday)
    {
        timeString = @"This Week";
    }
    else if (timeInterval > timeFromNowUntilSunday)
    {
        NSDate *deliveryDate = capsl.deliveryTime;
        timeString = [self getDateForLater:deliveryDate];
    }

    return timeString;
}


+ (NSString *)countdownStringFromTimeInterval:(NSTimeInterval)interval
{
    NSInteger ti = (NSInteger)interval;
    NSInteger seconds = ti % 60;
    NSInteger minutes = (ti / 60) % 60;
    NSInteger hours = (ti / 3600);

    return [NSString stringWithFormat:@"%02li:%02li:%02li", (long)hours, (long)minutes, (long)seconds];
}

// For Date
+ (NSString *)getDateStringWithDate:(NSDate *)date withCapsl:(Capsl *)capsl
{
    //TODO: Refactor later
    NSDate *deliveryDate = capsl.deliveryTime;
    NSTimeInterval timeInterval = [deliveryDate timeIntervalSinceNow];

    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];

    NSString *timeString = [NSString string];

    NSCalendarUnit dayOfWeek = NSCalendarUnitWeekday;
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSInteger todaysDay = [calendar component:dayOfWeek fromDate:[NSDate date]];

    NSInteger daysUntilSunday = 8 - todaysDay;
    NSTimeInterval timeFromStartOfTodayThroughSaturday = kDayInSeconds * daysUntilSunday;

    NSDate *startOfToday = [calendar startOfDayForDate:[NSDate date]];

    NSTimeInterval timeSinceMidnightToday = [startOfToday timeIntervalSinceNow];

    NSTimeInterval timeFromNowUntilSunday = timeSinceMidnightToday + timeFromStartOfTodayThroughSaturday;

    // Setting the delivery date

    if (timeInterval > timeFromNowUntilSunday)
    {
        [dateFormatter setDateFormat:@"h:mm a"];

        timeString = [NSString stringWithFormat:@"%@", [dateFormatter stringFromDate:date]];
    }
    else
    {
        [dateFormatter setDateFormat:@"MMM d, yyyy | h:mm a"];

        timeString = [NSString stringWithFormat:@"%@", [dateFormatter stringFromDate:date]];
    }

    return timeString;
}


+ (NSString *)getDateForLater:(NSDate *)date
{
    // Setting the delivery date
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];

    [dateFormatter setDateFormat:@"MMM d, yyyy"];

    NSString *dateString = [NSString stringWithFormat:@"%@", [dateFormatter stringFromDate:date]];

    return dateString;
}


//-(instancetype)init
//{
//
//    self = [super init];
//
//    if (self)
//    {
//        abort();
//    }
//
//    return self;
//}
//
//- (instancetype)initWithDeliveryDate:(NSDate *)date withDelegate:(id<JKCountdownTimerDelegate>)delegate
//{
//    self = [super init];
//
//    if(self)
//    {
//        self.delegate = delegate;
//        self.deliveryDate = date;
//        self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateLabel) userInfo:nil repeats:YES];
//    }
//    return self;
//}
//
//
//- (void)updateLabel
//{
//    NSString *result;
//
//    long elapsedSeconds = [self.deliveryDate timeIntervalSinceDate:[NSDate date]];
////    NSLog(@"Elaped seconds:%ld seconds",elapsedSeconds);
//
//    if (elapsedSeconds >= kWeekInSeconds)
//    {
//        result = @"SOON";
//    }
//    else if (elapsedSeconds < kWeekInSeconds && elapsedSeconds >= kDayInSeconds)
//    {
//        result = @"THIS WEEK";
//    }
//    else if (elapsedSeconds < kDayInSeconds && elapsedSeconds >= kSixHoursInSeconds)
//    {
//        result = @"TODAY";
//    }
//    else if (elapsedSeconds < kSixHoursInSeconds && elapsedSeconds >= 60)
//    {
//        result = [self stringFromTimeInterval:elapsedSeconds];
//    }
//    else if (elapsedSeconds < 60 && elapsedSeconds >= 0)
//    {
//        result = [self stringForLastSixtySeconds:elapsedSeconds];
//    }
//    else if (elapsedSeconds < 0)
//    {
//        result = @"OPEN!";
//        [self.timer invalidate];
//    }
//    [self.delegate counterUpdated:result];
//
//}
//
//- (NSString *)stringFromTimeInterval:(NSTimeInterval)interval
//{
//    NSInteger ti = (NSInteger)interval;
//    NSInteger seconds = ti % 60;
//    NSInteger minutes = (ti / 60) % 60;
//    NSInteger hours = (ti / 3600);
//
//    return [NSString stringWithFormat:@"%02li:%02li:%02li", (long)hours, (long)minutes, (long)seconds];
//}
//
//- (NSString *)stringForLastSixtySeconds:(NSTimeInterval)interval
//{
//    NSInteger ti = (NSInteger)interval;
//    NSInteger seconds = ti % 60;
//
//    return [NSString stringWithFormat:@"%02li", (long)seconds];
//}
//
//
//
@end
