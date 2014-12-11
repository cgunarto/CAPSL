//
//  AppDelegate.m
//  Capsl
//
//  Created by CHRISTINA GUNARTO on 11/25/14.
//  Copyright (c) 2014 Christina Gunarto. All rights reserved.
//

#import "AppDelegate.h"
#import <Parse/Parse.h>
#import "Capslr.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


//In regards to push notification: this is called whenuser taps the default button in the alert or tap/click the app icon
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    //Correct applicationID and client key for Parse - Capsl
    [Parse setApplicationId:@"5JY7Z39SraGkmGmWprsSCyUBRKVk9T58IPDygfl1" clientKey:@"NHIYSRSFP5tFE8VGltjdFnzeLHX5jYPVIYlZH6Fc"];

//    [PFUser logOut];

    [self.window setTintColor:[UIColor whiteColor]];
    [[UINavigationBar appearance] setTranslucent:YES];
    [[UINavigationBar appearance] setBarStyle:UIBarStyleBlackTranslucent];
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    [[UIToolbar appearance] setBarStyle:UIBarStyleBlackTranslucent];
    [[UIToolbar appearance] setTintColor:[UIColor whiteColor]];
    [[UIToolbar appearance] setTranslucent:YES];

    NSDictionary *toolBarTextAttributes = @{
                                 NSFontAttributeName: [UIFont fontWithName:@"Avenir-Book" size:18.0]
                                 };
    [[UIBarButtonItem appearance] setTitleTextAttributes:toolBarTextAttributes forState:UIControlStateNormal];

    NSDictionary *segmentedControlTextAttributes = @{
                                            NSFontAttributeName: [UIFont fontWithName:@"Avenir-Book" size:12.0]
                                            };

    [[UISegmentedControl appearance] setTitleTextAttributes:segmentedControlTextAttributes forState:UIControlStateNormal];

    [[UINavigationBar appearance] setTitleTextAttributes: @{
                                                           NSFontAttributeName: [UIFont fontWithName:@"Avenir-Medium" size:18.0]
                                                           }];

    // Register for Push Notifications
    UIUserNotificationType userNotificationTypes = (UIUserNotificationTypeAlert |
                                                    UIUserNotificationTypeBadge |
                                                    UIUserNotificationTypeSound);
    UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:userNotificationTypes
                                                                             categories:nil];
    [application registerUserNotificationSettings:settings];
    [application registerForRemoteNotifications];


    // Handle launching from a local notification
    UILocalNotification *localNotification = [launchOptions objectForKey:UIApplicationLaunchOptionsLocalNotificationKey];
    if (localNotification)
    {
        // Set icon badge number to zero
        application.applicationIconBadgeNumber = 0;
    }

    return YES;
}

#pragma mark Added for Push Notification
//TODO: check if deviceToken checking works
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    if (deviceToken)
    {
        PFInstallation *currentInstallation = [PFInstallation currentInstallation];
        [currentInstallation setDeviceTokenFromData:deviceToken];
        currentInstallation.channels = @[ @"global" ];
        [currentInstallation saveInBackground];
    }
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.

    //Resetting badge installation number to 0 for remote notification
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    if (currentInstallation.badge != 0)
    {
        currentInstallation.badge = 0;
        [currentInstallation saveEventually];
    }

    //Send a notification that kRefreshData so other VCs who are 'listening' can refresh
    [[NSNotificationCenter defaultCenter] postNotificationName:kRefreshData object:nil];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    
}

//In regards to push notification: this is called whenuser taps the DEFAULT button in the alert or tap/click the app icon
//Allows Parse to create a modal alert and display the push notification's content when a push is received when the app is active.
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    [PFPush handlePush:userInfo];
    [[NSNotificationCenter defaultCenter] postNotificationName:kRefreshData object:nil];
}

//If the app is running while local notification is delivered
- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    //TODO:Figure out how to do this with UIAlertController, can't present AlertController via AppDelegate right now
    UIApplicationState state = [application applicationState];
    if (state == UIApplicationStateActive)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"CAPSULE UNLOCKED"
                                                        message:notification.alertBody
                                                       delegate:self cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];

        // Set icon badge number to zero
        application.applicationIconBadgeNumber = 0;

        //Posting a notification so that VC that's listening can decide to refresh data
        [[NSNotificationCenter defaultCenter] postNotificationName:kRefreshData object:nil];
    }
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
