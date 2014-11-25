//
//  Capsl.h
//  Capsl
//
//  Created by CHRISTINA GUNARTO on 11/25/14.
//  Copyright (c) 2014 Christina Gunarto. All rights reserved.
//

#import <Parse/Parse.h>
@class Capslr;

@interface Capsl : PFObject

@property Capslr *sender;
@property Capslr *recipient;

//Type indicates whether user is storing photo, video, audio, or text
@property (nonatomic, strong) NSString *type;

//Different types of user created Capsules
@property (nonatomic, strong) PFFile *photo;
@property (nonatomic, strong) PFFile *video;
@property (nonatomic, strong) PFFile *audio;
@property (nonatomic, strong) NSString *text;

@property (nonatomic, strong) NSDate *deliveryTime;

//Time at when receipient Capslr views the Capsl
@property (nonatomic, strong) NSDate *viewedAt;


@end
