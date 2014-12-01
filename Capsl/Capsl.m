//
//  Capsl.m
//  Capsl
//
//  Created by CHRISTINA GUNARTO on 11/25/14.
//  Copyright (c) 2014 Christina Gunarto. All rights reserved.
//

#import "Capsl.h"

@implementation Capsl

@dynamic sender;
@dynamic recipient;

//Type indicates whether user is storing photo, video, audio, or text
@dynamic type;

//Different types of user created Capsules
@dynamic photo;
@dynamic video;
@dynamic audio;
@dynamic text;

@dynamic deliveryTime;

//Time at when receipient Capslr views the Capsl
@dynamic viewedAt;


+ (void)load
{
    [self registerSubclass];
}

+ (NSString *)parseClassName
{
    return @"Capsl";
}

//Class Method searching for capsl by its recipient
+ (void)searchCapslByKey:(NSString *)key orderByAscending:(NSString *)date equalTo:(id)object completion:(searchCapslByRecipientBlock)complete
{
    PFQuery *query = [self query];
    [query includeKey:@"sender"];
    [query whereKey:key equalTo:object];
    [query orderByAscending:date];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
     {
         if (!error)
         {
             complete(objects,nil);
         }
         else
         {
             complete(nil,error);
         }
     }];
}

@end
