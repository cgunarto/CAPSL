//
//  JCALocalNotification.h
//  Capsl
//
//  Created by CHRISTINA GUNARTO on 12/6/14.
//  Copyright (c) 2014 Christina Gunarto. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Capsl;

@interface JCALocalNotification : UILocalNotification

//Create a method that takes in an Array of Cpsls and creates/saves a set of notification
//Checks if there are less than 64 and just schedules the most recent 64


+ (void)createLocalNotificationForUnviewedCapslFromCapslObjectsArray:(NSArray *)capslObjectsArray;
+ (void)consolidateNowLocalNotificationsFromCapslObjectsArray:(NSArray *)capslObjectsArray;

+ (void)createLocalNotificationFromCapsl:(Capsl *)capsl;


@end
