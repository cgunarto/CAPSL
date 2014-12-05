//
//  CapslTableViewCell.m
//  Capsl
//
//  Created by Jonathan Kim on 11/27/14.
//  Copyright (c) 2014 Christina Gunarto. All rights reserved.
//

#import "CapslTableViewCell.h"
#import "JKCountDownTimer.h"
#define kSixHoursInSeconds 21600
#define kDayInSeconds 86400
#define kWeekInSeconds 604800

@implementation CapslTableViewCell

- (void)awakeFromNib
{
    // Initialization code

    self.lozengeView.layer.cornerRadius = 44;
    [self layoutSubviews];

}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}



- (void)updateLabelsForCapsl:(Capsl *)capsl
{

    NSDate *deliveryDate = capsl.deliveryTime;
    NSTimeInterval timeInterval = [deliveryDate timeIntervalSinceNow];
    self.timerLabel.text = [[JKCountDownTimer getStringWithTimeInterval:timeInterval] uppercaseString];
    self.deliveryDateLabel.text = [JKCountDownTimer getDateStringWithDate:deliveryDate];

}

- (void)drawCellForCapsl:(Capsl *)capsl
{

    self.lozengeView.backgroundColor = kReceivedCapsuleColor;

}

@end
