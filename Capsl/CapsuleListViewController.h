//
//  CapsuleListViewController.h
//  Capsl
//
//  Created by CHRISTINA GUNARTO on 11/25/14.
//  Copyright (c) 2014 Christina Gunarto. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Capslr.h"

@interface CapsuleListViewController : UIViewController

@property Capslr *capslr;

@property (nonatomic)  NSArray *capslsArray;
@property (nonatomic) NSArray *sentCapslsArray;
@property NSInteger capslCount;

- (void)updateClocks;


@end
