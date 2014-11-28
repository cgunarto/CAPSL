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

// DUMMY DATA
@dynamic reciever;
@dynamic from;

+ (void)load
{
    [self registerSubclass];
}

+ (NSString *)parseClassName
{
    return @"Capsl";
}


@end
