//
//  CrossFadeSegue.m
//  Capsl
//
//  Created by Mobile Making on 12/5/14.
//  Copyright (c) 2014 Christina Gunarto. All rights reserved.
//

#import "CrossDissolveSegue.h"

@implementation CrossDissolveSegue

- (void)perform
{

//    CATransition* transition = [CATransition animation];
//
//    transition.duration = 0.3;
//    transition.type = kCATransitionFade;
//
//    [[self.sourceViewController view].layer addAnimation:transition forKey:kCATransition];
//
//    [[self sourceViewController] presentViewController:[self destinationViewController] animated:NO completion:nil];
//    [[self sourceViewController] pushViewController:[self destinationViewController] animated:NO];



    UIViewController *sourceViewController = self.sourceViewController;
    UIViewController *destinationViewController = self.destinationViewController;

    // Add the destination view as a subview, temporarily
    [sourceViewController.view addSubview:destinationViewController.view];

    // Transformation start scale
    destinationViewController.view.alpha = 0;


    [UIView animateWithDuration:0.5
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         destinationViewController.view.alpha = 1;                     }
                     completion:^(BOOL finished){
                         [sourceViewController presentViewController:destinationViewController animated:NO completion:NULL]; // present VC
//                         [destinationViewController.view removeFromSuperview]; // remove from temp super view

                     }];


}

@end