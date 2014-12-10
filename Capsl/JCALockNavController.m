//
//  JCALockNavController.m
//  Capsl
//
//  Created by CHRISTINA GUNARTO on 12/10/14.
//  Copyright (c) 2014 Christina Gunarto. All rights reserved.
//

#import "JCALockNavController.h"

@interface JCALockNavController ()

@end

@implementation JCALockNavController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark Lock Orientation

- (BOOL) shouldAutorotate
{
    return YES;
}

-(NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (UIInterfaceOrientation) preferredInterfaceOrientationForPresentation {
    // Return the orientation you'd prefer - this is what it launches to. The
    // user can still rotate. You don't have to implement this method, in which
    // case it launches in the current orientation
    return UIInterfaceOrientationPortrait;
}

@end
