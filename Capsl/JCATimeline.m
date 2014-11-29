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
    [leftSegment moveToPoint:CGPointMake(0.0, self.frame.size.height/2)];
    [leftSegment addLineToPoint:CGPointMake(self.frame.size.width/24 * 11, self.frame.size.height/2)];
    leftSegment.lineWidth = 1;
    [leftSegment stroke];

    // circle
    UIBezierPath *centerArc = [UIBezierPath bezierPathWithArcCenter:CGPointMake(self.frame.size.width/2, self.frame.size.height/2)
                                                         radius:self.frame.size.width/12/2
                                                     startAngle:0
                                                       endAngle:M_PI * 2
                                                      clockwise:NO];

    centerArc.lineWidth = 1;
    [centerArc stroke];

    // draw right segment
    UIBezierPath *rightSegment = [UIBezierPath bezierPath];
    [rightSegment moveToPoint:CGPointMake(self.frame.size.width/24 * 13, self.frame.size.height/2)];
    [rightSegment addLineToPoint:CGPointMake(self.frame.size.width, self.frame.size.height/2)];
    rightSegment.lineWidth = 1;
    [rightSegment stroke];


}

@end
