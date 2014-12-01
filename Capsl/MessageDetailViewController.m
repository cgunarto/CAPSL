//
//  MessageDetailViewController.m
//  Capsl
//
//  Created by CHRISTINA GUNARTO on 11/25/14.
//  Copyright (c) 2014 Christina Gunarto. All rights reserved.
//

#import "MessageDetailViewController.h"

@interface MessageDetailViewController ()
@property (strong, nonatomic) IBOutlet UILabel *senderLabel;
@property (strong, nonatomic) IBOutlet UILabel *deliveryDateLabel;
@property (strong, nonatomic) IBOutlet UILabel *timerLabel;

@end

@implementation MessageDetailViewController

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];


    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MM-dd-yyyy"];
    NSDate *deliveryDate = self.chosenCapsl.deliveryTime;

    self.deliveryDateLabel.text = [dateFormatter stringFromDate:deliveryDate];

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
