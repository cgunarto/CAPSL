//
//  ViewCapsulesViewController.h
//  Capsl
//
//  Created by Mobile Making on 12/1/14.
//  Copyright (c) 2014 Christina Gunarto. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewCapsulesViewController : UIViewController

@property (nonatomic) NSArray *capslsArray;
@property (nonatomic) NSArray *sentCapslsArray;
@property (nonatomic) NSMutableArray *availableCapslsArray;
@property BOOL shouldShowSent;
@property UIImage *currentProfileImage;

@end
