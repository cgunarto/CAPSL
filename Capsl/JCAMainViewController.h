//
//  JCASplashViewController.h
//  Capsl
//
//  Created by Mobile Making on 11/29/14.
//  Copyright (c) 2014 Christina Gunarto. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JCAMainViewController : UIViewController

@property (strong, nonatomic) IBOutlet UIToolbar *toolBar;
@property BOOL showChooseVC;

////refactor
@property (nonatomic) NSArray *capslsArray;
@property (nonatomic) NSArray *sentCapslsArray;
@property (nonatomic) NSMutableArray *availableCapslsArray;
@property UIImage *currentProfileImage;
@property BOOL shouldShowSent;

@end
