//
//  CaptureViewController.h
//  Capsl
//
//  Created by CHRISTINA GUNARTO on 11/25/14.
//  Copyright (c) 2014 Christina Gunarto. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Capsl;

@interface CaptureViewController : UIViewController
@property Capsl *createdCapsl;
@property Capsl *chosenCapsl;
@property NSData *audioData;

@property BOOL isEditing;


@end
