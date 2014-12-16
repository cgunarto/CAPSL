//
//  JCATimeline.m
//  Timeline Test 5
//
//  Created by Mobile Making on 11/27/14.
//  Copyright (c) 2014 Alex Hsu. All rights reserved.
//

#import "JCATimeline.h"

@implementation JCATimeline

- (void)drawRect:(CGRect)rect
{

    [[UIColor lightGrayColor] setStroke];

    //draw left segment
    UIBezierPath *leftSegment = [UIBezierPath bezierPath];
    [leftSegment moveToPoint:CGPointMake(0.0, self.frame.size.height * 0.4)];
    [leftSegment addLineToPoint:CGPointMake(self.frame.size.width/30 * 14, self.frame.size.height* 0.4)];
    leftSegment.lineWidth = 1;
    [leftSegment stroke];

    // circle
    UIBezierPath *centerArc = [UIBezierPath bezierPathWithArcCenter:CGPointMake(self.frame.size.width/2, self.frame.size.height * 0.4)
                                                         radius:self.frame.size.width/15/2
                                                     startAngle:0
                                                       endAngle:M_PI * 2
                                                      clockwise:NO];

    centerArc.lineWidth = 1;
    [centerArc stroke];

    // draw right segment
    UIBezierPath *rightSegment = [UIBezierPath bezierPath];
    [rightSegment moveToPoint:CGPointMake(self.frame.size.width/30 * 16, self.frame.size.height * 0.4)];
    [rightSegment addLineToPoint:CGPointMake(self.frame.size.width, self.frame.size.height * 0.4)];
    rightSegment.lineWidth = 1;
    [rightSegment stroke];


    // masking

//    CAGradientLayer *gradient = [CAGradientLayer layer];
//    gradient.allowsGroupOpacity = NO;
//    gradient.frame = self.bounds;
//    gradient.colors = [NSArray arrayWithObjects:
//                       (__bridge id)UIColor.clearColor.CGColor,
//                       UIColor.whiteColor.CGColor,
//                       UIColor.whiteColor.CGColor,
//                       UIColor.clearColor.CGColor,
//                       nil];
//    gradient.locations = [NSArray arrayWithObjects:
//                          [NSNumber numberWithFloat:0],
//                          [NSNumber numberWithFloat:1.0/16],
//                          [NSNumber numberWithFloat:15.0/16],
//                          [NSNumber numberWithFloat:1],
//                          nil];
//    self.layer.mask = gradient;

}

@end
