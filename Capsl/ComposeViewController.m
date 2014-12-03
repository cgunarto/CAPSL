//
//  ComposeViewController.m
//  Capsl
//
//  Created by CHRISTINA GUNARTO on 11/25/14.
//  Copyright (c) 2014 Christina Gunarto. All rights reserved.
//

#import "ComposeViewController.h"
#import "ProfileViewController.h"
#import "Capsl.h"
#import "Capslr.h"

@interface ComposeViewController () <UITextFieldDelegate, UIActionSheetDelegate>
@property (weak, nonatomic) IBOutlet UITextField *deliveryDateTextField;
@property UIActionSheet *pickerViewPopup;
@property (weak, nonatomic) IBOutlet UITextField *deliveryTimeTextField;

@property UIDatePicker *datePicker;
@property UIDatePicker *timePicker;

@end

@implementation ComposeViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.deliveryDateTextField.delegate = self;
    self.deliveryTimeTextField.delegate = self;

    //Setting the date picker for Delivery Date Textfield
    self.datePicker = [[UIDatePicker alloc]init];
    self.datePicker.datePickerMode = UIDatePickerModeDate;
    [self.datePicker setDate:[NSDate date]];

    //set minimum Date as right now
    [self.datePicker setMinimumDate:[NSDate date]];
    [self.datePicker addTarget:self
                   action:@selector(updateDateTextField:)
         forControlEvents:UIControlEventValueChanged];

    //setting keyboard as datePicker
    [self.deliveryDateTextField setInputView:self.datePicker];

    //Setting the date picker for the Delivery Time Textfield
    self.timePicker = [[UIDatePicker alloc]init];
    self.timePicker.datePickerMode = UIDatePickerModeTime;
    [self.timePicker setDate:self.datePicker.date];
    [self.timePicker addTarget:self
                   action:@selector(updateTimeTextField:)
         forControlEvents:UIControlEventValueChanged];

    [self.deliveryTimeTextField setInputView:self.timePicker];
}

-(void)updateDateTextField:(id)sender
{
    UIDatePicker *picker = (UIDatePicker*)self.deliveryDateTextField.inputView;

    //Setting a minimum and maximum date for TimeTextField that is 24 hours of the chosen date from DateTextField
//    NSDate *now = self.datePicker.date;
//    int daysToAdd = 2;
//    NSDate *aDayFromNow = [now dateByAddingTimeInterval:60*60*24*daysToAdd];

    [self.timePicker setDate:self.datePicker.date];
//    [self.timePicker setMinimumDate:self.datePicker.date];
//    [self.timePicker setMaximumDate:aDayFromNow];

    NSDate *pickerDate = picker.date;
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"dd-MM-yyyy"];
    NSString *dateString = [dateFormat stringFromDate:pickerDate];

    //TODO: use NSDateFormatter
    self.deliveryDateTextField.text = [NSString stringWithFormat:@"%@",dateString];
}

-(void)updateTimeTextField:(id)sender
{
    UIDatePicker *picker = (UIDatePicker*)self.deliveryTimeTextField.inputView;
    //self.deliveryTimeTextField.text = [NSString stringWithFormat:@"%@",picker.date];

    NSDate *pickerDate = picker.date;
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"dd-MM-yyyy HH:mm"];
    NSString *dateString = [dateFormat stringFromDate:pickerDate];

    self.deliveryTimeTextField.text = [NSString stringWithFormat:@"%@",dateString];

    //Setting createdCapsl's delivery Time
    self.createdCapsl.deliveryTime = picker.date;
}

- (IBAction)onSendButtonPressed:(UIButton *)sender
{
    //If date is not chosen, present an alert
    if ([self.deliveryDateTextField.text isEqual: @""] || [self.deliveryTimeTextField  isEqual: @""] )
    {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"NO DELIVERY DATE CHOSEN"
                                                                       message:@"Please choose a delivery date"
                                                                preferredStyle:UIAlertControllerStyleAlert];

        UIAlertAction *okButton = [UIAlertAction actionWithTitle:@"OK"
                                                           style:UIAlertActionStyleDefault
                                                         handler:nil];
        [alert addAction:okButton];
        [self presentViewController:alert
                           animated:YES
                         completion:nil];

    }
    
    else
    {
        //Save it to Capsl
        [self.createdCapsl saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
        {
            if (!error)
            {
                Capslr *recipient= self.createdCapsl.recipient;
                NSString *message = [NSString stringWithFormat:@"Capsl sent to %@", recipient.username];

                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Message Sent!"
                                                                               message:message
                                                                        preferredStyle:UIAlertControllerStyleAlert];

                UIAlertAction *okButton = [UIAlertAction actionWithTitle:@"OK"
                                                                   style:UIAlertActionStyleDefault
                                                                 handler:nil];
                [alert addAction:okButton];
                [self presentViewController:alert
                                   animated:YES
                                 completion:nil];

            }

            else
            {
                NSLog(@"there is an error %@", error.localizedDescription);
            }
        }];
    }


}


//set Time Date
//set recipient - Capslr


//create Capsl object with file, time delivered, sender Capslr (PFUser CurrentUser)
//upload it to Parse






@end
