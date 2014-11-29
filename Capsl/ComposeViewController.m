//
//  ComposeViewController.m
//  Capsl
//
//  Created by CHRISTINA GUNARTO on 11/25/14.
//  Copyright (c) 2014 Christina Gunarto. All rights reserved.
//

#import "ComposeViewController.h"

@interface ComposeViewController () <UITextFieldDelegate, UIActionSheetDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UITextField *deliveryDateTextField;
@property UIActionSheet *pickerViewPopup;
@property (weak, nonatomic) IBOutlet UITextField *deliveryTimeTextField;
@property (weak, nonatomic) IBOutlet UITextField *recipientTextfield;

@end

@implementation ComposeViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.imageView.image = self.chosenImage;
    self.deliveryDateTextField.delegate = self;

    UIDatePicker *datePicker = [[UIDatePicker alloc]init];

    datePicker.datePickerMode = UIDatePickerModeDate;
    [datePicker setDate:[NSDate date]];
    [datePicker addTarget:self
                   action:@selector(updateTextField:)
         forControlEvents:UIControlEventValueChanged];

    [self.deliveryDateTextField setInputView:datePicker];

    [datePicker addTarget:self
                   action:@selector(updateTextField:)
         forControlEvents:UIControlEventValueChanged];

}

-(void)updateTextField:(id)sender
{
    UIDatePicker *picker = (UIDatePicker*)self.deliveryDateTextField.inputView;
    self.deliveryDateTextField.text = [NSString stringWithFormat:@"%@",picker.date];
}





//set Time Date
//set recipient - Capslr


//create Capsl object with file, time delivered, sender Capslr (PFUser CurrentUser)
//upload it to Parse






@end
