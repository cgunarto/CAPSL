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
@dynamic isVerified;

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
//Return only Capslrs that have been claimed by a sign up and have the corresponding phone number
+ (void)returnCapslrWithContactsArray:(NSArray *)Contacts withCompletion:(void(^)(NSArray *capslrObjectsArray, NSError *error))complete
{
    NSMutableArray *capslrContact = [@[]mutableCopy];
    NSMutableArray *capslrArray = [@[]mutableCopy];
    NSMutableArray *allContactPhones = [@[]mutableCopy];

    //Get all the phone numbers in Contact's phonenumberarray
    for (Contact *contact in Contacts)
    {
        for (NSString *phoneNumber in contact.phoneNumbersArray)
        {
            [allContactPhones addObject:phoneNumber];
        }
    }

    PFQuery *query = [Capslr query];
    [query whereKey:@"phone" containedIn:allContactPhones];

    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
    {
        if (!error)
        {
             for (Capslr *capslr in objects)
             {
                 //Only add CAPSLRs that have a user pointer (they have been claimed by a signup), otherwise empty CAPSLR with phone numbers only will show up
                 //Empty CAPSLRs are created when a sender sends message to a phone number (not a CAPSLR user)
                 if (capslr.user)
                 {
                     [capslrArray addObject:capslr];
                 }
             }

             for (Capslr *capslr in capslrArray)
             {
                 for (Contact *contact in Contacts)
                 {
                     if ([capslr.phone containsString:contact.number])
                     {
                         [capslrContact addObject:capslr];
                         break;
                     }
                 }
             }

            complete (capslrContact, nil);
        }
    }];

//    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
//     {
//         if (!error)
//         {
//             for (Capslr *capslr in objects)
//             {
//                 //Only add CAPSLRs that have a user pointer (they have been claimed by a signup), otherwise empty CAPSLR with phone numbers only will show up
//                 //Empty CAPSLRs are created when a sender sends message to a phone number (not a CAPSLR user)
//                 if (capslr.user)
//                 {
//                     [capslrArray addObject:capslr];
//                 }
//             }
//
//             for (Contact *contact in Contacts)
//             {
//                 for (Capslr *capslr in capslrArray)
//                 {
//                     if ([capslr.phone containsString:contact.number])
//                     {
//                         [capslrContact addObject:capslr];
//                     }
//                 }
//             }
//             complete (capslrContact, nil);
//         }
//     }];
}


//Takes a PFUser current user info and then returns a Capslr
+ (void)returnCapslrFromPFUser:(PFUser *)user withCompletion:(void(^)(Capslr *currentCapslr, NSError *error))complete
{
    PFQuery *query = [Capslr query];
    [query whereKey:@"user" equalTo:user];
    [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error)
    {
        if(!error)
        {
            Capslr *capslr = (Capslr *)object;
            complete (capslr, nil);
        }
        else
        {
            complete (nil, error);
        }
    }];
}

//Returns a Cpslr with phone number
+ (void)returnCapslrFromPhone:(NSString *)phone withCompletion:(void(^)(Capslr *capslr, NSError *error))complete
{
    PFQuery *query = [Capslr query];
    [query whereKey:@"phone" equalTo:phone];
    [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error)
     {
         if(!error)
         {
             Capslr *capslr = (Capslr *)object;
             complete (capslr, nil);
         }
         else
         {
             complete (nil, error);
         }
     }];
}



@end


























