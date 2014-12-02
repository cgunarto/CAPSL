//
//  Contact.m
//  Capsl
//
//  Created by CHRISTINA GUNARTO on 11/28/14.
//  Copyright (c) 2014 Christina Gunarto. All rights reserved.
//

#import "Contact.h"

@implementation Contact

#import "Contact.h"
@import AddressBook;

- (NSString *)fullName
{
    NSMutableString *fullString = [[NSMutableString alloc] init];

    if (self.firstName)
    {
        [fullString appendFormat:@"%@", self.firstName];
    }

    if (self.lastName)
    {
        [fullString appendFormat:@" %@", self.lastName];
    }

    if (!self.lastName && !self.firstName)
    {
        return @"Unknown";
    }

    return fullString;
}

+ (void)retrieveAllContactsWithBlock:(void(^)(NSArray *))block
{
    CFErrorRef *error = NULL;
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, error);
    ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error)
                                             {
                                                 CFArrayRef allPeople = ABAddressBookCopyArrayOfAllPeople(addressBook);
                                                 CFIndex numberOfPeople = ABAddressBookGetPersonCount(addressBook);

                                                 //Create a mutable array to add our custom Contact objects into
                                                 NSMutableArray *arrayOfContacts = [NSMutableArray array];

                                                 //Loop through all the people in 'allPeople' based on the 'numberOfPeople'
                                                 for(int i = 0; i < numberOfPeople; i++)
                                                 {
                                                     //Create contact object (this is our custom class)
                                                     Contact *contact = [[Contact alloc]init];

                                                     //Grab person from 'allPeople' based on i
                                                     ABRecordRef person = CFArrayGetValueAtIndex( allPeople, i );

                                                     //Grab whatever values we desire. (CMD + Click kABPersonFirstNameProperty for the full list)
                                                     NSString *firstName = (__bridge NSString *)(ABRecordCopyValue(person, kABPersonFirstNameProperty));
                                                     NSString *lastName = (__bridge NSString *)(ABRecordCopyValue(person, kABPersonLastNameProperty));
                                                     NSString *nickName = (__bridge NSString *)(ABRecordCopyValue(person, kABPersonNicknameProperty));

                                                     //Grabbing the profile photo
                                                     NSData *photo = CFBridgingRelease(ABPersonCopyImageDataWithFormat(person, kABPersonImageFormatOriginalSize));

                                                     //Since a person can have multiple phone numbers, we loop through the phone numbers
                                                     ABMultiValueRef phoneNumbers = ABRecordCopyValue(person, kABPersonPhoneProperty);
                                                     for (CFIndex i = 0; i < ABMultiValueGetCount(phoneNumbers); i++)
                                                     {
                                                         NSString *phoneNumber = (__bridge_transfer NSString *) ABMultiValueCopyValueAtIndex(phoneNumbers, i);

                                                         //Assign one of the phone numbers to our contact object
                                                         contact.number = phoneNumber;
                                                     }

                                                     //Check for the phone number for '+' '-' '(' ')' ' ' and remove them.
                                                     contact.number = [contact.number stringByReplacingOccurrencesOfString:@" " withString:@""];
                                                     contact.number = [contact.number stringByReplacingOccurrencesOfString:@"+" withString:@""];
                                                     contact.number = [contact.number stringByReplacingOccurrencesOfString:@"-" withString:@""];
                                                     contact.number = [contact.number stringByReplacingOccurrencesOfString:@"(" withString:@""];
                                                     contact.number = [contact.number stringByReplacingOccurrencesOfString:@")" withString:@""];
                                                     contact.number = [contact.number stringByReplacingOccurrencesOfString:@"." withString:@""];
                                                     
                                                     //Assign the first name and last name
                                                     contact.firstName = firstName;
                                                     contact.lastName = lastName;
                                                     contact.nickName = nickName;
                                                     contact.photo = photo;
                                                     
                                                     //Add the contact object to our array
                                                     if (contact.number != nil)
                                                     {
                                                         [arrayOfContacts addObject:contact];
                                                     }
                                                     //Sort array by first name
                                                     arrayOfContacts = [[self sortContactArrayAlphabetically:arrayOfContacts] mutableCopy];
                                                     
                                                 }
                                                 
                                                 //Get back on main thread
                                                 dispatch_async(dispatch_get_main_queue(), ^{
                                                     //Call block and pass in our array of contacts
                                                     block(arrayOfContacts);
                                                 });
                                             });
}

+ (NSArray *)sortContactArrayAlphabetically:(NSMutableArray*)arrayOfContacts
{
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"firstName"
                                                                     ascending:YES
                                                                      selector:@selector(localizedStandardCompare:)];
    
    NSArray *sortedContactsArray = [arrayOfContacts sortedArrayUsingDescriptors:@[sortDescriptor]];
    return sortedContactsArray;
}


@end
