//
//  Contact.h
//  Capsl
//
//  Created by CHRISTINA GUNARTO on 11/28/14.
//  Copyright (c) 2014 Christina Gunarto. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Contact : NSObject

@property NSString *firstName;
@property NSString *lastName;
@property NSString *nickName;
@property NSString *allNameString;
@property NSString *number;
@property NSMutableArray *phoneNumbersArray;
@property NSData *photo;

- (NSString *) fullName;
+ (NSArray *)sortContactArrayAlphabetically:(NSMutableArray*)arrayOfContacts;

+ (void)retrieveAllContactsWithBlock:(void(^)(NSArray *))block;

@end

