//
//  RecordVideoViewController.h
//  Capsl
//
//  Created by CHRISTINA GUNARTO on 12/1/14.
//  Copyright (c) 2014 Christina Gunarto. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Capsl;

@interface RecordVideoViewController : UIViewController
@property Capsl *createdCapsl;

//for when BOOL isEditing
@property Capsl *chosenCapsl;

@property BOOL isEditing;

@end
