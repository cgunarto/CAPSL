//
//  Capslr.h
//  Capsl
//
//  Created by CHRISTINA GUNARTO on 11/25/14.
//  Copyright (c) 2014 Christina Gunarto. All rights reserved.
//

#import <Parse/Parse.h>

@interface Capslr : PFObject <PFSubclassing>

@property (nonatomic, strong) PFUser *user;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *username;
@property (nonatomic, strong) NSString *email;
@property (nonatomic, strong) NSString *phone;
@property (nonatomic, strong) PFFile *profilePhoto;
@property (nonatomic, strong) PFRelation *friends;

@property (nonatomic, strong) NSString *objectId;

+ (void)returnCapslrWithContactsArray:(NSArray *)Contacts withCompletion:(void(^)(NSArray *capslrObjectsArray, NSError *error))complete;


@end
