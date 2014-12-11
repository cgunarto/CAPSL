//
//  CapslTableViewCell.m
//  Capsl
//
//  Created by Jonathan Kim on 11/27/14.
//  Copyright (c) 2014 Christina Gunarto. All rights reserved.
//

#import "CapslTableViewCell.h"
#import "JKCountDownTimer.h"
#import "UIImage+ImageEffects.h"

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

    self.countdownLabel.text = [[JKCountDownTimer getStatusStringWithCapsl:capsl] uppercaseString];
    self.deliveryDateLabel.text = [JKCountDownTimer getDateStringWithDate:capsl.deliveryTime withCapsl:capsl];
}

- (void)drawCellForCapsl:(Capsl *)capsl ThatWasSent:(BOOL)wasSent
{

    if (wasSent)
    {
        self.lozengeView.backgroundColor = [self colorForSentCapsule:capsl];
    }
    else
    {
        self.lozengeView.backgroundColor = [self colorForCapsule:capsl];
    }
    
    // updating timer string...
    [self updateLabelsForCapsl:capsl];

}

- (UIColor *)colorForCapsule:(Capsl *)capsl
{

    UIColor *color = [[UIColor alloc] init];

    NSTimeInterval timeInterval = [capsl getTimeIntervalUntilDelivery];

    color = kReceivedCapsuleColor;
    self.alpha = 1;
    self.contentView.alpha = 1.0f;

    self.countdownLabel.textColor = [UIColor whiteColor];
    self.deliveryDateLabel.textColor = [UIColor whiteColor];
    self.capslrLabel.textColor = [UIColor whiteColor];


    if (timeInterval <= 0)
    {
        // unlocked - add shimmer
    }
    if (timeInterval <= 0 && capsl.viewedAt)
    {
        //viewed - mute colors
        color = kReceivedViewedCapsuleColor;
        self.countdownLabel.textColor = kReceivedViewedTextColor;
        self.deliveryDateLabel.textColor = kReceivedViewedTextColor;
        self.capslrLabel.textColor = kReceivedViewedTextColor;

    }
    if (timeInterval > 0 && timeInterval <= kDayInSeconds)
    {
        // within 24 hrs
    }
    if (timeInterval > kDayInSeconds)
    {
        // more than 24hrs - add alpha
        self.alpha = 0.6;
        self.contentView.alpha = 0.6f;
    }

    return color;
    
}


- (UIColor *)colorForSentCapsule:(Capsl *)capsl
{

    UIColor *color = [[UIColor alloc] init];

    NSTimeInterval timeInterval = [capsl getTimeIntervalUntilDelivery];

    color = kSentCapsuleColor;
    self.alpha = 1;
    self.contentView.alpha = 1;

    self.countdownLabel.textColor = [UIColor whiteColor];
    self.deliveryDateLabel.textColor = [UIColor whiteColor];
    self.capslrLabel.textColor = [UIColor whiteColor];


    if (timeInterval <= 0)
    {
        // unlocked - add shimmer
    }
    if (timeInterval <= 0 && capsl.viewedAt)
    {
        //viewed - mute colors
        color = kSentViewedCapsuleColor;
        self.countdownLabel.textColor = kSentViewedTextColor;
        self.deliveryDateLabel.textColor = kSentViewedTextColor;
        self.capslrLabel.textColor = kSentViewedTextColor;

    }
    if (timeInterval > 0 && timeInterval <= kDayInSeconds)
    {
        // within 24 hrs
    }
    if (timeInterval > kDayInSeconds)
    {
        // more than 24hrs - add alpha
        self.alpha = 0.6;
        self.contentView.alpha = 0.6f;

    }

    return color;
    
}


@end
