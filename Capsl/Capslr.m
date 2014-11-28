//
//  Capslr.m
//  Capsl
//
//  Created by CHRISTINA GUNARTO on 11/25/14.
//  Copyright (c) 2014 Christina Gunarto. All rights reserved.
//

#import "Capslr.h"

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


@end
