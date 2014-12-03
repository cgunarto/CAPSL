//
//  CapslTableViewCell.m
//  Capsl
//
//  Created by Jonathan Kim on 11/27/14.
//  Copyright (c) 2014 Christina Gunarto. All rights reserved.
//

#import "CapslTableViewCell.h"
#define kSixHoursInSeconds 21600
#define kDayInSeconds 86400
#define kWeekInSeconds 604800

@implementation CapslTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}



- (void)updateTimeLabelForCapsl:(Capsl *)capsl
{

    NSDate *deliveryDate = capsl.deliveryTime;
    NSTimeInterval timeInterval = [deliveryDate timeIntervalSinceNow];
    NSString *dateString = [NSString string];

    if (timeInterval <= 0)
    {
        dateString = @"Open";
    }
    if (timeInterval > 0 && timeInterval <= kDayInSeconds)
    {
        dateString = [self countdownStringFromTimeInterval:timeInterval];
    }
    if (timeInterval > kDayInSeconds)
    {
        dateString = [self englishStringFromTimeInterval:timeInterval];
    }

    self.timerLabel.text = dateString;

}

- (NSString *)englishStringFromTimeInterval:(NSTimeInterval)timeInterval
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
        timeString = @"Later";
    }

    return timeString;
}


- (NSString *)countdownStringFromTimeInterval:(NSTimeInterval)interval
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
