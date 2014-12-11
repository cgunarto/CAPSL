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


- (void)updateLabelsForCapsl:(Capsl *)capsl
{

    self.countdownLabel.text = [[JKCountDownTimer getStatusStringWithCapsl:capsl] uppercaseString];
    self.deliveryDateLabel.text = [JKCountDownTimer getDateStringWithDate:capsl.deliveryTime withCapsl:capsl];

//    [UIView setAnimationsEnabled:NO];
//    [self.countdownButton setTitle:[JKCountDownTimer getStringWithTimeInterval:timeInterval] forState:UIControlStateNormal];
//    [UIView setAnimationsEnabled:YES];

//    [UIView transitionWithView:self.countdownButton duration:0.5 options:UIViewAnimationOptionTransitionNone animations:^{
//        [self.countdownButton setTitle:[JKCountDownTimer getStringWithTimeInterval:timeInterval] forState:UIControlStateNormal];
//    } completion:nil];

}

- (void)drawCellforSentCapsl:(Capsl *)capsl withSentStatus:(BOOL)showSent
{
    //    NSArray *constraints = [cell.profilePicView constraints];
    //    [cell.profilePicView removeConstraints:constraints];

    NSLayoutConstraint *widthConstraint = [NSLayoutConstraint constraintWithItem:self.profilePicView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0];
    NSLayoutConstraint *heightConstraint = [NSLayoutConstraint constraintWithItem:self.profilePicView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.profilePicView attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0];

    [self addSubview:self.profilePicView];
    [self sendSubviewToBack:self.profilePicView];
    [self addConstraints:@[widthConstraint, heightConstraint]];

    self.profilePicView.layer.cornerRadius = self.frame.size.width/2;


    [self.profilePicView setContentMode:UIViewContentModeScaleAspectFill];
    [self.profilePicView setClipsToBounds:YES];

    //    cell.profilePicView.layer.borderColor = [UIColor blackColor].CGColor;
    //    cell.profilePicView.layer.borderWidth = 1.0;

    self.countdownLabel.layer.cornerRadius = self.countdownLabel.frame.size.height/2;
    self.countdownLabel.clipsToBounds = YES;

    if (showSent)
    {
        self.countdownLabel.backgroundColor = [self colorForSentCapsule:capsl];
    }
    else
    {
        self.countdownLabel.backgroundColor = [self colorForCapsule:capsl];
    }
    
    [self layoutIfNeeded];
    
}

- (UIColor *)colorForSentCapsule:(Capsl *)capsl
{

    UIColor *color = [[UIColor alloc] init];

    NSTimeInterval timeInterval = [capsl getTimeIntervalUntilDelivery];

    color = kSentCapsuleColor;
    self.alpha = 1.0f;
    self.countdownLabel.textColor = [UIColor whiteColor];
    self.nameLabel.textColor = [UIColor whiteColor];
    self.deliveryDateLabel.textColor = [UIColor whiteColor];



    if (timeInterval <= 0)
    {
        // unlocked - add shimmer
    }
    if (timeInterval <= 0 && capsl.viewedAt)
    {
        //viewed - mute colors
        color = kSentViewedCapsuleColor;
        self.countdownLabel.textColor = kSentViewedTextColor;
        self.nameLabel.textColor = [UIColor colorWithWhite:0.7 alpha:1.0];
        self.deliveryDateLabel.textColor = [UIColor colorWithWhite:0.7 alpha:1.0];

    }
    if (timeInterval > 0 && timeInterval <= kDayInSeconds)
    {
        // within 24 hrs
    }
    if (timeInterval > kDayInSeconds)
    {
        // more than 24hrs - add alpha
        self.alpha = 0.5f;
    }
    
    return color;
    
}

- (UIColor *)colorForCapsule:(Capsl *)capsl
{

    UIColor *color = [[UIColor alloc] init];

    NSTimeInterval timeInterval = [capsl getTimeIntervalUntilDelivery];

    color = kReceivedCapsuleColor;
    self.alpha = 1.0f;
    self.countdownLabel.textColor = [UIColor whiteColor];
    self.nameLabel.textColor = [UIColor whiteColor];
    self.deliveryDateLabel.textColor = [UIColor whiteColor];



    if (timeInterval <= 0)
    {
        // unlocked - add shimmer
    }
    if (timeInterval <= 0 && capsl.viewedAt)
    {
        //viewed - mute colors
        color = kReceivedViewedCapsuleColor;
        self.countdownLabel.textColor = kReceivedViewedTextColor;
        self.nameLabel.textColor = [UIColor colorWithWhite:0.7 alpha:1.0];
        self.deliveryDateLabel.textColor = [UIColor colorWithWhite:0.7 alpha:1.0];

    }
    if (timeInterval > 0 && timeInterval <= kDayInSeconds)
    {
        // within 24 hrs
    }
    if (timeInterval > kDayInSeconds)
    {
        // more than 24hrs - add alpha
        self.alpha = 0.5f;
    }

    return color;

}

@end