//
//  JCALocalNotification.m
//  Capsl
//
//  Created by CHRISTINA GUNARTO on 12/6/14.
//  Copyright (c) 2014 Christina Gunarto. All rights reserved.
//

#import "JCALocalNotification.h"
#import "Capsl.h"
#import "Capslr.h"

@implementation JCALocalNotification

//Takes in an array of Capsl Objects and create notifications for those that aren't viewed yet (capped at 64, the max)
+ (void)createLocalNotificationForUnviewedCapslFromCapslObjectsArray:(NSArray *)capslObjectsArray
{
    NSMutableArray *unviewedCapslArray = [@[]mutableCopy];
    //TODO:Refactor later
    for (Capsl *capsl in capslObjectsArray)
    {
        if (capsl.viewedAt == nil)
        {
            [unviewedCapslArray addObject:capsl];
        }
    }

    if (unviewedCapslArray.count > 64)
    {
        for (int i = 0; i < 64; i++)
        {
            Capsl *capsl = unviewedCapslArray[i];
            [self createLocalNotificationFromCapsl:capsl];
        }
    }

    else
    {
        for (Capsl *capsl in unviewedCapslArray)
        {
            [self createLocalNotificationFromCapsl:capsl];
        }
    }
}

//Takes all the notification that will be displayed at this moment and consolidates it into one notification
//Used for when application is active
+ (void)consolidateNowLocalNotificationsFromCapslObjectsArray:(NSArray *)capslObjectsArray
{
    NSMutableArray *unviewedCapslArray = [@[]mutableCopy];
    NSMutableArray *unlockedNowCapslArray = [@[]mutableCopy];
    int unlockedNow = 0;

    for (Capsl *capsl in capslObjectsArray)
    {
        if (capsl.viewedAt == nil)
        {
            [unviewedCapslArray addObject:capsl];

            //Get rid of the ones that is unlocked now or earlier to consolidate into one notification later
            NSDate *date = capsl.deliveryTime;
            if ([date timeIntervalSinceNow] <= 0)
            {
                [unviewedCapslArray removeObject:capsl];
                [unlockedNowCapslArray addObject:capsl];
                unlockedNow ++;
            }
        }
    }

    if (unlockedNow > 0)
    {
        //Create a local notification that consolidates all that is about to be fired and fire it now
        UILocalNotification* localNotification = [[UILocalNotification alloc]init];
        localNotification.fireDate = [NSDate date];
        localNotification.alertBody = [NSString stringWithFormat: @"You've got %i unlocked Capsules!", unlockedNow];
        localNotification.alertAction = @"View Message";
        localNotification.timeZone = [NSTimeZone defaultTimeZone];
        [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
    }

    //Create notifications for the remainder of unviewedCapsl that will be available later than now
    [JCALocalNotification createLocalNotificationForUnviewedCapslFromCapslObjectsArray:unviewedCapslArray];
}


//Create Local Notification from a single Capsl Object
+ (void)createLocalNotificationFromCapsl:(Capsl *)capsl
{
    UILocalNotification* localNotification = [[UILocalNotification alloc]init];
    localNotification.fireDate = capsl.deliveryTime;

    //Use first name if not use username(required at sign up)
    if (capsl.sender.name)
    {
        localNotification.alertBody = [NSString stringWithFormat: @"Message from %@ is unlocked, click to view!", capsl.sender.name];
    }
    else
    {
        localNotification.alertBody = [NSString stringWithFormat: @"Message from %@ is unlocked, click to view!", capsl.sender.username];

    }

    localNotification.alertAction = @"View Message";
    localNotification.timeZone = [NSTimeZone defaultTimeZone];
    localNotification.applicationIconBadgeNumber = [[UIApplication sharedApplication] applicationIconBadgeNumber] + 1;

    [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
}




//                        UIApplicationState state = [[UIApplication sharedApplication] applicationState];
//                        if (state == UIApplicationStateActive)

//                To check for all notification
//                NSArray *localNotifications = [[UIApplication sharedApplication] scheduledLocalNotifications];

@end
