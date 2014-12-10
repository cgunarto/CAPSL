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

    self.timerLabel.text = [[JKCountDownTimer getStatusStringWithCapsl:capsl] uppercaseString];
    self.deliveryDateLabel.text = [JKCountDownTimer getDateStringWithDate:capsl.deliveryTime withCapsl:capsl];
}

- (void)drawCellForCapsl:(Capsl *)capsl ThatWasSent:(BOOL)wasSent
{

    if (wasSent)
    {
        self.lozengeView.backgroundColor = kSentCapsuleColor;
    }
    else
    {
        self.lozengeView.backgroundColor = kReceivedCapsuleColor;
    }
    
    // updating timer string...
    [self updateLabelsForCapsl:capsl];

}

@end
