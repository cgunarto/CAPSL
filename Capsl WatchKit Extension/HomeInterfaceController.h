//
//  InterfaceController.h
//  Capsl WatchKit Extension
//
//  Created by Mobile Making on 3/25/15.
//  Copyright (c) 2015 Christina Gunarto. All rights reserved.
//

#import <WatchKit/WatchKit.h>
#import <Foundation/Foundation.h>
@class Capsl;

@interface HomeInterfaceController : WKInterfaceController

@property (strong, nonatomic) IBOutlet WKInterfaceLabel *nameLabel;
@property (strong, nonatomic) IBOutlet WKInterfaceImage *senderProfilePic;
@property (strong, nonatomic) IBOutlet WKInterfaceTimer *countDownTimer;

@property Capsl *capsl;

@end
