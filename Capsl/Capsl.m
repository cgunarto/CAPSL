//
//  Capsl.m
//  Capsl
//
//  Created by CHRISTINA GUNARTO on 11/25/14.
//  Copyright (c) 2014 Christina Gunarto. All rights reserved.
//

#import "Capsl.h"
#import "Capslr.h"

#define kTwoMinutesInSeconds 120
#define kTwoDaysInSeconds 172800
#define kWeekInSeconds 604800

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
@dynamic wallpaperIndex;

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

- (instancetype)initWithCurrentCapslr:(Capslr *)currentCapslr
                            withIndex:(NSNumber *)index
                      withWelcomeText:(NSString *)welcomeText
                     withTimeInterval:(NSTimeInterval)timeInterval
{
    self = [super init];

    Capslr *theCapslTeam = [Capslr objectWithoutDataWithClassName:@"Capslr" objectId:kCapslTeamObjectID];
    self.sender = theCapslTeam;
    self.recipient = currentCapslr;

    self.deliveryTime = [currentCapslr.createdAt dateByAddingTimeInterval:timeInterval];
    self.wallpaperIndex = index;
    self.text = welcomeText;
    self.type = @"multimedia";

    return self;
}

- (instancetype)initSentWithCurrentCapslr:(Capslr *)currentCapslr
                         withTimeInterval:(NSTimeInterval)timeInterval
{

    self = [super init];

    Capslr *theCapslTeam = [Capslr objectWithoutDataWithClassName:@"Capslr" objectId:kCapslTeamObjectID];
    self.sender = currentCapslr;
    self.recipient = theCapslTeam;
    self.deliveryTime = [currentCapslr.createdAt dateByAddingTimeInterval:timeInterval];
    self.viewedAt = [NSDate date];


    return self;

}

//Class Method searching for capsl by its recipient
+ (void)searchCapslByKey:(NSString *)key orderByAscending:(NSString *)date equalTo:(id)object completion:(searchCapslByRecipientBlock)complete
{
    PFQuery *query = [self query];
    [query includeKey:@"sender"];
    [query includeKey:@"recipient"];
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

- (NSTimeInterval)getTimeIntervalUntilDelivery
{
    NSDate *deliveryDate = self.deliveryTime;
    NSTimeInterval timeInterval = [deliveryDate timeIntervalSinceNow];

    return timeInterval;
}

- (NSInteger)getYearForCapsl
{

    NSDateFormatter *yearFormatter = [[NSDateFormatter alloc] init];
    yearFormatter.dateFormat = @"yyyy";

    NSInteger year = [[NSString stringWithFormat:@"%@", [yearFormatter stringFromDate:self.deliveryTime]] intValue];

    return year;

}

- (NSInteger)getMonthForCapsl
{

    NSDateFormatter *monthFormatter = [[NSDateFormatter alloc] init];
    monthFormatter.dateFormat = @"MM";

    int month = [[NSString stringWithFormat:@"%@", [monthFormatter stringFromDate:self.deliveryTime]] intValue];

    return month;

}

@end
