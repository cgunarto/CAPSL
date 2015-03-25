//
//  InterfaceController.m
//  Capsl WatchKit Extension
//
//  Created by Mobile Making on 3/25/15.
//  Copyright (c) 2015 Christina Gunarto. All rights reserved.
//

#import "HomeInterfaceController.h"
#import "Capsl.h"
#import "Capslr.h"

@interface HomeInterfaceController()

@end


@implementation HomeInterfaceController

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];

    // Configure interface objects here.

    [self.nameLabel setText:self.capsl.sender.name];


}

- (void)willActivate {
    // This method is called when watch view controller is about to be visible to user
    [super willActivate];
}

- (void)didDeactivate {
    // This method is called when watch view controller is no longer visible
    [super didDeactivate];
}

@end



