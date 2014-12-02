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

    long elapsedSeconds = timeInterval;
    //    NSLog(@"Elaped seconds:%ld seconds",elapsedSeconds);

    if (elapsedSeconds >= kWeekInSeconds)
    {
        self.timerLabel.text = @"SOON";
    }
    else if (elapsedSeconds < kWeekInSeconds && elapsedSeconds >= kDayInSeconds)
    {
        self.timerLabel.text = @"THIS WEEK";
    }
    else if (elapsedSeconds < kDayInSeconds && elapsedSeconds >= kSixHoursInSeconds)
    {
        self.timerLabel.text = @"TODAY";
    }
    else if (elapsedSeconds < kSixHoursInSeconds && elapsedSeconds >= 60)
    {
        self.timerLabel.text = [self stringFromTimeInterval:elapsedSeconds];
    }
    else if (elapsedSeconds < 60 && elapsedSeconds >= 0)
    {
        self.timerLabel.text = [self stringForLastSixtySeconds:elapsedSeconds];
    }
    else if (elapsedSeconds < 0)
    {
        self.timerLabel.text = @"OPEN!";
    }
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
