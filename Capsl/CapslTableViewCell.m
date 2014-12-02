//
//  CapslTableViewCell.m
//  Capsl
//
//  Created by Jonathan Kim on 11/27/14.
//  Copyright (c) 2014 Christina Gunarto. All rights reserved.
//

#import "CapslTableViewCell.h"
#define kDayInSeconds 86400

@implementation CapslTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

//- (JKCountDownTimer *)startTimerWithDate:(NSDate *)date
//{
//    JKCountDownTimer *timer = [[JKCountDownTimer alloc] initWithDeliveryDate:date withDelegate:self];
//
//    [timer updateLabel];
//
//    return timer;
//}

-(void)counterUpdated:(NSString *)dateString
{
    self.timerLabel.text = dateString;
//    if ([self.timerLabel.text isEqual:@"OPEN!"])
//    {
//        self.timerLabel.textColor = [UIColor whiteColor];
//        self.timerLabel.backgroundColor = [UIColor blueColor];
//    }
}

- (void)updateTimeLabelForCapsl:(Capsl *)capsl
{

    NSDate *deliveryDate = capsl.deliveryTime;
    NSTimeInterval timeInterval = [deliveryDate timeIntervalSinceNow];
    NSString *dateString = [self stringFromTimeInterval:timeInterval];

    self.timerLabel.text = dateString;

}

- (NSString *)stringFromTimeInterval:(NSTimeInterval)interval
{
    NSInteger ti = (NSInteger)interval;
    NSInteger seconds = ti % 60;
    NSInteger minutes = (ti / 60) % 60;
    NSInteger hours = (ti / 3600);

    return [NSString stringWithFormat:@"%02li:%02li:%02li", (long)hours, (long)minutes, (long)seconds];
}



@end
