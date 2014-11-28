//
//  Capslr.m
//  Capsl
//
//  Created by CHRISTINA GUNARTO on 11/25/14.
//  Copyright (c) 2014 Christina Gunarto. All rights reserved.
//

#import "Capslr.h"
#import "Contact.h"

@implementation Capslr

@dynamic user;
@dynamic name;
@dynamic username;
@dynamic email;
@dynamic phone;
@dynamic profilePhoto;
@dynamic friends;

@dynamic objectId;

+ (void)load
{
    [self registerSubclass]; // need to have this
}

+ (NSString *)parseClassName
{
    return @"Capslr"; /// have to return same name, same exact one as the class
}

//Comparing the retrieved Capslrs to see if any contacts are Capslrs (based on phone number)
+ (void)returnCapslrWithContactsArray:(NSArray *)Contacts withCompletion:(void(^)(NSArray *capslrObjectsArray, NSError *error))complete
{
    NSMutableArray *capslrContact = [@[]mutableCopy];
    NSMutableArray *capslrArray =[@[]mutableCopy];

    PFQuery *query = [Capslr query];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
     {
         if (!error)
         {
             for (Capslr *capslr in objects)
             {
                 [capslrArray addObject:capslr];
             }

             for (Contact *contact in Contacts)
             {
                 for (Capslr *capslr in capslrArray)
                 {
                     NSLog(@"%@   %@",contact.number, capslr.phone);
                     if ([contact.number isEqualToString:capslr.phone])
                     {
                         [capslrContact addObject:capslr];
                     }
                 }
             }
             complete (capslrContact, nil);
         }
     }];
}



@end
