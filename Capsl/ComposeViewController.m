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
@property (weak, nonatomic) IBOutlet UITextField *deliveryTimeTextField;
@property UIActionSheet *pickerViewPopup;

@property (weak, nonatomic) IBOutlet UIDatePicker *datePickerView;

@end

@implementation ComposeViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.imageView.image = self.chosenImage;
    self.deliveryTimeTextField.delegate = self;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if ([textField isEqual:self.deliveryTimeTextField])
    {
        //TODO:how to differentiate between the two textfield?
        //resign the keyboard
        [textField resignFirstResponder];

        self.pickerViewPopup = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil, nil];

        UIDatePicker *pickerView = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, 44, 0, 0)];
        pickerView.datePickerMode = UIDatePickerModeDate;
        pickerView.hidden = NO;
        pickerView.date = [NSDate date];

        UIToolbar *pickerToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
        pickerToolbar.barStyle = UIBarStyleBlackOpaque;
        [pickerToolbar sizeToFit];

        NSMutableArray *barItems = [[NSMutableArray alloc] init];

        UIBarButtonItem *flexSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
        [barItems addObject:flexSpace];

        UIBarButtonItem *doneBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneButtonPressed:)];
        [barItems addObject:doneBtn];

        UIBarButtonItem *cancelBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelButtonPressed:)];
        [barItems addObject:cancelBtn];

        [pickerToolbar setItems:barItems animated:YES];

        [self.pickerViewPopup addSubview:pickerToolbar];
        [self.pickerViewPopup addSubview:pickerView];
        [self.pickerViewPopup showInView:self.view];
        [self.pickerViewPopup setBounds:CGRectMake(0,0,320, 464)];
    }
}


-(void)doneButtonPressed:(id)sender
{
    //Do something here here with the value selected using [pickerView date] to get that value

    [self.pickerViewPopup dismissWithClickedButtonIndex:1 animated:YES];
}

-(void)cancelButtonPressed:(id)sender
{
    [self.pickerViewPopup dismissWithClickedButtonIndex:1 animated:YES];
}

//set Time Date
//set recipient - Capslr


//create Capsl object with file, time delivered, sender Capslr (PFUser CurrentUser)
//upload it to Parse






@end
