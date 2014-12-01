//
//  MessageDetailViewController.m
//  Capsl
//
//  Created by CHRISTINA GUNARTO on 11/25/14.
//  Copyright (c) 2014 Christina Gunarto. All rights reserved.
//

#import "MessageDetailViewController.h"
#import "Capslr.h"

@interface MessageDetailViewController ()
@property (strong, nonatomic) IBOutlet UILabel *senderLabel;
@property (strong, nonatomic) IBOutlet UILabel *deliveryDateLabel;
@property (strong, nonatomic) IBOutlet UILabel *timerLabel;

@end

@implementation MessageDetailViewController

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    NSLog(@"%@", self.chosenCapsl);

    // Passing Delivery Date
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MM-dd-yyyy"];
    NSDate *deliveryDate = self.chosenCapsl.deliveryTime;
    self.deliveryDateLabel.text = [dateFormatter stringFromDate:deliveryDate];

    //Sender
    PFQuery *query = [Capslr query];
    [query whereKey:@"objectId" equalTo: self.chosenCapsl.sender.objectId];
    [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {

        self.senderLabel.text = [NSString stringWithFormat:@"From: %@", object[@"username"]];
    }];

}

- (void)viewDidLoad
{
    [super viewDidLoad];
}



- (IBAction)onBackButtonPressed:(UIButton *)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}


@end
