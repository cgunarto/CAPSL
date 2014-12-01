//
//  MessageDetailViewController.m
//  Capsl
//
//  Created by CHRISTINA GUNARTO on 11/25/14.
//  Copyright (c) 2014 Christina Gunarto. All rights reserved.
//

#import "MessageDetailViewController.h"
#import "Capslr.h"
#import "JKCountDownTimer.h"

@interface MessageDetailViewController () <JKCountdownTimerDelegate>

@property (strong, nonatomic) IBOutlet UILabel *senderLabel;
@property (strong, nonatomic) IBOutlet UILabel *deliveryDateLabel;
@property (strong, nonatomic) IBOutlet UILabel *timerLabel;

//String for TIMER
@property NSString *timerString;

// ----TYPES OF MESSAGE---- //

//Text Message
@property (strong, nonatomic) IBOutlet UITextView *textView;

@end

@implementation MessageDetailViewController

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

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

    //Timer
    JKCountDownTimer *timer = [[JKCountDownTimer alloc] initWithDeliveryDate:self.chosenCapsl.deliveryTime withDelegate:self];
    [timer updateLabel];

    //Text Message
    if ([self.timerLabel.text isEqual:@"OPEN!"])
    {
        self.textView.text = self.chosenCapsl.text;
    }
    else
    {
        self.textView.text = @"NOT AVAILABLE YET";
    }

}

#pragma mark - JKTimer Delegate Method
-(void)counterUpdated:(NSString *)dateString
{
    self.timerLabel.text = dateString;
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
